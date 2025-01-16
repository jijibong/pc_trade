import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../log/log.dart';
import 'common.dart';
import 'consts.dart';

/// must keep the order
// ignore: constant_identifier_names
enum WindowType { Main, Trade, PL, Condition, Draw, Notification, Unknown }

extension Index on int {
  WindowType get windowType {
    switch (this) {
      case 0:
        return WindowType.Main;
      case 1:
        return WindowType.Trade;
      case 2:
        return WindowType.PL;
      case 3:
        return WindowType.Condition;
      case 4:
        return WindowType.Draw;
      case 5:
        return WindowType.Notification;
      default:
        return WindowType.Unknown;
    }
  }
}

class MultiWindowCallResult {
  int windowId;
  dynamic result;

  MultiWindowCallResult(this.windowId, this.result);
}

/// Window Manager
/// mainly use it in `Main Window`
/// use it in sub window is not recommended
class RustDeskMultiWindowManager {
  RustDeskMultiWindowManager._();

  static final instance = RustDeskMultiWindowManager._();

  final Set<int> _inactiveWindows = {};
  final Set<int> _activeWindows = {};
  final List<AsyncCallback> _windowActiveCallbacks = List.empty(growable: true);
  final List<int> _tradeWindows = List.empty(growable: true);
  final List<int> _plWindows = List.empty(growable: true);
  final List<int> _conditionWindows = List.empty(growable: true);
  final List<int> _drawWindows = List.empty(growable: true);
  final List<int> _notificationWindows = List.empty(growable: true);

  // This function must be called in the main window thread.
  // Because the _remoteDesktopWindows is managed in that thread.
  openMonitorSession(int windowId, String peerId, int display, int displayCount, Rect? screenRect) async {
    if (_tradeWindows.length > 1) {
      for (final windowId in _tradeWindows) {
        if (await DesktopMultiWindow.invokeMethod(
            windowId,
            kWindowEventActiveDisplaySession,
            jsonEncode({
              'id': peerId,
              'display': display,
            }))) {
          return;
        }
      }
    }

    final displays = display == kAllDisplayValue ? List.generate(displayCount, (index) => index) : [display];
    var params = {
      'type': WindowType.Trade.index,
      'id': peerId,
      'tab_window_id': windowId,
      'display': display,
      'displays': displays,
    };
    if (screenRect != null) {
      params['screen_rect'] = {
        'l': screenRect.left,
        't': screenRect.top,
        'r': screenRect.right,
        'b': screenRect.bottom,
      };
    }
    await _newSession(
      false,
      WindowType.Trade,
      kWindowEventNewRemoteDesktop,
      peerId,
      _tradeWindows,
      jsonEncode(params),
      screenRect: screenRect,
    );
  }

  Future<int> newSessionWindow(
    WindowType type,
    String remoteId,
    String msg,
    List<int> windows,
    bool withScreenRect,
  ) async {
    final windowController = await DesktopMultiWindow.createWindow(msg);
    final windowId = windowController.windowId;
    if (!withScreenRect) {
      windowController
          // ..setFrame(const Offset(0, 0) & const Size(1240, 512))
          // ..center()
          .setTitle(getWindowNameWithId(
        remoteId,
        overrideType: type,
      ));
    } else {
      windowController.setTitle(getWindowNameWithId(
        remoteId,
        overrideType: type,
      ));
    }
    if (isMacOS) {
      Future.microtask(() => windowController.show());
    }
    registerActiveWindow(windowId);
    windows.add(windowId);
    return windowId;
  }

  Future<MultiWindowCallResult> _newSession(
    bool openInTabs,
    WindowType type,
    String methodName,
    String remoteId,
    List<int> windows,
    String msg, {
    Rect? screenRect,
  }) async {
    if (openInTabs) {
      if (windows.isEmpty) {
        //首次打开
        final windowId = await newSessionWindow(type, remoteId, msg, windows, screenRect != null);
        return MultiWindowCallResult(windowId, null);
      } else {
        //多次打开
        if (methodName == kWindowEventNewNotification) {
          return Future.delayed(const Duration(milliseconds: 500), () {
            return call(type, methodName, msg);
          });
        }
        return call(type, methodName, msg);
      }
    } else {
      if (_inactiveWindows.isNotEmpty) {
        for (final windowId in windows) {
          if (_inactiveWindows.contains(windowId)) {
            if (screenRect == null) {
              await restoreWindowPosition(type, windowId: windowId, peerId: remoteId);
            }
            await DesktopMultiWindow.invokeMethod(windowId, methodName, msg);
            // if (methodName != kWindowEventNewRemoteDesktop) {
            //   WindowController.fromWindowId(windowId).show();
            // }
            registerActiveWindow(windowId);
            return MultiWindowCallResult(windowId, null);
          }
        }
      }
      final windowId = await newSessionWindow(type, remoteId, msg, windows, screenRect != null);
      return MultiWindowCallResult(windowId, null);
    }
  }

  Future<MultiWindowCallResult> newSession(
    WindowType type,
    String methodName,
    String remoteId,
    List<int> windows, {
    String? password,
    bool? forceRelay,
    String? contract,
    String? hold,
  }) async {
    var params = {"type": type.index, "id": remoteId, "password": password, "forceRelay": forceRelay};
    if (contract != null) {
      params['contract'] = contract;
    }
    if (hold != null) {
      params['hold'] = hold;
    }
    final msg = jsonEncode(params);

    // separate window for file transfer is not supported
    bool openInTabs = type != WindowType.Trade || mainGetLocalBoolOptionSync(kOptionOpenNewConnInTabs);
    if (windows.length > 1 || !openInTabs) {
      for (final windowId in windows) {
        if (await DesktopMultiWindow.invokeMethod(windowId, kWindowEventActiveSession, remoteId)) {
          return MultiWindowCallResult(windowId, null);
        }
      }
    }

    return _newSession(openInTabs, type, methodName, remoteId, windows, msg);
  }

  Future<MultiWindowCallResult> newRemoteDesktop(
    String remoteId, {
    String? password,
    String? contract,
    bool? forceRelay,
  }) async {
    return await newSession(
      WindowType.Trade,
      kWindowEventNewRemoteDesktop,
      remoteId,
      _tradeWindows,
      password: password,
      forceRelay: forceRelay,
      contract: contract,
    );
  }

  Future<MultiWindowCallResult> newPL(String remoteId, {String? password, bool? forceRelay, String? hold}) async {
    return await newSession(
      WindowType.PL,
      kWindowEventNewPL,
      remoteId,
      _plWindows,
      password: password,
      forceRelay: forceRelay,
      hold: hold,
    );
  }

  Future<MultiWindowCallResult> newCondition(String remoteId, {String? password, bool? forceRelay, String? hold}) async {
    return await newSession(
      WindowType.Condition,
      kWindowEventNewCondition,
      remoteId,
      _conditionWindows,
      password: password,
      forceRelay: forceRelay,
      hold: hold,
    );
  }

  Future<MultiWindowCallResult> newDrawTool(String remoteId, {String? password, bool? forceRelay, String? hold}) async {
    return await newSession(
      WindowType.Draw,
      kWindowEventNewDraw,
      remoteId,
      _drawWindows,
      password: password,
      forceRelay: forceRelay,
      hold: hold,
    );
  }

  Future<MultiWindowCallResult> newLocalNotification(String remoteId, {String? password, bool? forceRelay, String? hold}) async {
    return await newSession(
      WindowType.Notification,
      kWindowEventNewNotification,
      remoteId,
      _notificationWindows,
      password: password,
      forceRelay: forceRelay,
      hold: hold,
    );
  }

  Future<MultiWindowCallResult> call(WindowType type, String methodName, dynamic args) async {
    final wnds = _findWindowsByType(type);
    if (wnds.isEmpty) {
      return MultiWindowCallResult(kInvalidWindowId, null);
    }
    for (final windowId in wnds) {
      if (_activeWindows.contains(windowId)) {
        final res = await DesktopMultiWindow.invokeMethod(windowId, methodName, args);
        return MultiWindowCallResult(windowId, res);
      }
    }
    final res = await DesktopMultiWindow.invokeMethod(wnds[0], methodName, args);
    return MultiWindowCallResult(wnds[0], res);
  }

  List<int> _findWindowsByType(WindowType type) {
    switch (type) {
      case WindowType.Main:
        return [kMainWindowId];
      case WindowType.Trade:
        return _tradeWindows;
      case WindowType.PL:
        return _plWindows;
      case WindowType.Condition:
        return _conditionWindows;
      case WindowType.Draw:
        return _drawWindows;
      case WindowType.Notification:
        return _notificationWindows;
      case WindowType.Unknown:
        break;
    }
    return [];
  }

  void clearWindowType(WindowType type) {
    switch (type) {
      case WindowType.Main:
        return;
      case WindowType.Trade:
        _tradeWindows.clear();
        break;
      case WindowType.PL:
        _plWindows.clear();
        break;
      case WindowType.Condition:
        _conditionWindows.clear();
        break;
      case WindowType.Draw:
        _drawWindows.clear();
        break;
      case WindowType.Notification:
        _notificationWindows.clear();
        break;
      case WindowType.Unknown:
        break;
    }
  }

  void setMethodHandler(Future<dynamic> Function(MethodCall call, int fromWindowId)? handler) {
    DesktopMultiWindow.setMethodHandler(handler);
  }

  Future<void> closeAllSubWindows() async {
    await Future.wait(WindowType.values.map((e) => _closeWindows(e)));
  }

  Future<void> _closeWindows(WindowType type) async {
    if (type == WindowType.Main) {
      // skip main window, use window manager instead
      return;
    }

    List<int> windows = [];
    try {
      windows = _findWindowsByType(type);
    } catch (e) {
      debugPrint('Failed to getAllSubWindowIds of $type, $e');
      return;
    }

    if (windows.isEmpty) {
      return;
    }
    for (final wId in windows) {
      debugPrint("closing multi window, type: ${type.toString()} id: $wId");
      await saveWindowPosition(type, windowId: wId);
      try {
        await WindowController.fromWindowId(wId).setPreventClose(false);
        await WindowController.fromWindowId(wId).close();
        _activeWindows.remove(wId);
      } catch (e) {
        debugPrint("$e");
        return;
      }
    }
    clearWindowType(type);
  }

  Future<List<int>> getAllSubWindowIds() async {
    try {
      final windows = await DesktopMultiWindow.getAllSubWindowIds();
      return windows;
    } catch (err) {
      if (err is AssertionError) {
        return [];
      } else {
        rethrow;
      }
    }
  }

  Set<int> getActiveWindows() {
    return _activeWindows;
  }

  Future<void> _notifyActiveWindow() async {
    for (final callback in _windowActiveCallbacks) {
      await callback.call();
    }
  }

  Future<void> registerActiveWindow(int windowId) async {
    _activeWindows.add(windowId);
    _inactiveWindows.remove(windowId);
    await _notifyActiveWindow();
  }

  /// Remove active window which has [`windowId`]
  ///
  /// [Availability]
  /// This function should only be called from main window.
  /// For other windows, please post a unregister(hide) event to main window handler:
  /// `rustDeskWinManager.call(WindowType.Main, kWindowEventHide, {"id": windowId!});`
  Future<void> unregisterActiveWindow(int windowId) async {
    _activeWindows.remove(windowId);
    if (windowId != kMainWindowId) {
      _inactiveWindows.add(windowId);
    }
    await _notifyActiveWindow();
  }

  void registerActiveWindowListener(AsyncCallback callback) {
    _windowActiveCallbacks.add(callback);
  }

  void unregisterActiveWindowListener(AsyncCallback callback) {
    _windowActiveCallbacks.remove(callback);
  }

  // This function is called from the main window.
  // It will query the active remote windows to get their coords.
  Future<List<String>> getOtherRemoteWindowCoords(int wId) async {
    List<String> coords = [];
    for (final windowId in _tradeWindows) {
      if (windowId != wId) {
        if (_activeWindows.contains(windowId)) {
          final res = await DesktopMultiWindow.invokeMethod(windowId, kWindowEventRemoteWindowCoords, '');
          if (res != null) {
            coords.add(res);
          }
        }
      }
    }
    return coords;
  }
}

final rustDeskWinManager = RustDeskMultiWindowManager.instance;
