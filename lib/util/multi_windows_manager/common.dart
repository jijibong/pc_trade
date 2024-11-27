import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade/util/multi_windows_manager/platform_channel.dart';
import 'package:trade/util/multi_windows_manager/platform_model.dart';
import 'package:trade/util/multi_windows_manager/refresh_wrapper.dart';
import 'package:trade/util/multi_windows_manager/state_model.dart';
import 'package:trade/util/multi_windows_manager/tabbar_widget.dart';
import 'package:trade/util/multi_windows_manager/win32.dart';
import 'package:uuid/uuid_value.dart';
import 'package:window_manager/window_manager.dart';

import '../../config/common.dart';
import '../../main.dart';
import 'consts.dart';
import 'model.dart';
import 'multi_window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

// final globalKey = GlobalKey<NavigatorState>();

final isAndroid = isAndroid_;
final isIOS = isIOS_;
final isWindows = isWindows_;
final isMacOS = isMacOS_;
final isLinux = isLinux_;
final isDesktop = isDesktop_;
final isWeb = isWeb_;
final isWebDesktop = isWebDesktop_;
final isWebOnWindows = isWebOnWindows_;
final isWebOnLinux = isWebOnLinux_;
final isWebOnMacOs = isWebOnMacOS_;
var isMobile = isAndroid || isIOS;
int androidVersion = 0;
bool _linuxWindowResizable = true;
int windowsBuildNumber = 0;

/// only available for Windows target
DesktopType? desktopType;

bool get isMainDesktopWindow => desktopType == DesktopType.main;

String get screenInfo => screenInfo_;

/// Check if the app is running with single view mode.
// bool isSingleViewApp() {
//   return desktopType == DesktopType.cm;
// }

bool isPointInRect(Offset point, Rect rect) {
  return point.dx >= rect.left && point.dx <= rect.right && point.dy >= rect.top && point.dy <= rect.bottom;
}

/// * debug or test only, DO NOT enable in release build
bool isTest = false;
typedef SessionID = UuidValue;

typedef F = String Function(String);
typedef FMethod = String Function(String, dynamic);

typedef StreamEventHandler = Future<void> Function(Map<String, dynamic>);

get windowResizeEdgeSize => isLinux && !_linuxWindowResizable ? 0.0 : kWindowResizeEdgeSize;

String get windowFramePrefix => kWindowPrefix + (bind.isIncomingOnly() ? "incoming_" : (bind.isOutgoingOnly() ? "outgoing_" : ""));

bool get kUseCompatibleUiMode => isWindows && const [WindowsTarget.w7].contains(windowsBuildNumber.windowsVersion);

late FFI _globalFFI;

FFI get gFFI => _globalFFI;

Future<void> initGlobalFFI() async {
  debugPrint("_globalFFI init");
  _globalFFI = FFI(null);
  debugPrint("_globalFFI init end");
  // after `put`, can also be globally found by Get.find<FFI>();
  Get.put<FFI>(_globalFFI, permanent: true);
}

// Simple wrapper of built-in types for reference use.
class SimpleWrapper<T> {
  T value;
  SimpleWrapper(this.value);
}

int getWindowsTargetBuildNumber() {
  return getWindowsTargetBuildNumber_();
}

Future<Size> _adjustRestoreMainWindowSize(double? width, double? height) async {
  const double minWidth = 1;
  const double minHeight = 1;
  const double maxWidth = 6480;
  const double maxHeight = 6480;

  final defaultWidth = ((isDesktop || isWebDesktop) ? 1280 : kMobileDefaultDisplayWidth).toDouble();
  final defaultHeight = ((isDesktop || isWebDesktop) ? 720 : kMobileDefaultDisplayHeight).toDouble();
  double restoreWidth = width ?? defaultWidth;
  double restoreHeight = height ?? defaultHeight;

  if (restoreWidth < minWidth) {
    restoreWidth = defaultWidth;
  }
  if (restoreHeight < minHeight) {
    restoreHeight = defaultHeight;
  }
  if (restoreWidth > maxWidth) {
    restoreWidth = defaultWidth;
  }
  if (restoreHeight > maxHeight) {
    restoreHeight = defaultHeight;
  }
  return Size(restoreWidth, restoreHeight);
}

// This function must be kept the same as the one in rust and sciter code.
// rust: libs/hbb_common/src/config.rs -> option2bool()
// sciter: Does not have the function, but it should be kept the same.
bool option2bool(String option, String value) {
  bool res;
  if (option.startsWith("enable-")) {
    res = value != "N";
  } else if (option.startsWith("allow-") || option == kOptionStopService || option == kOptionDirectServer || option == kOptionForceAlwaysRelay) {
    res = value == "Y";
  } else {
    assert(false);
    res = value != "N";
  }
  return res;
}

bool isInHomePage() {
  final controller = Get.find<DesktopTabController>();
  return controller.state.value.selected == 0;
}

Future<void> windowOnTop(int? id) async {
  if (!isDesktop) {
    return;
  }
  if (id == null) {
    // main window
    if (stateGlobal.isMinimized) {
      await windowManager.restore();
    }
    await windowManager.show();
    await windowManager.focus();
    await rustDeskWinManager.registerActiveWindow(kWindowMainId);
  } else {
    WindowController.fromWindowId(id)
      ..focus()
      ..show();
    rustDeskWinManager.call(WindowType.Main, kWindowEventShow, {"id": id});
  }
}

void reloadCurrentWindow() {
  if (Get.context != null) {
    // reload self window
    RefreshWrapper.of(Get.context!)?.rebuild();
  } else {
    debugPrint("reload current window failed, global BuildContext does not exist");
  }
}

bool mainGetLocalBoolOptionSync(String key) {
  return option2bool(key, bind.mainGetLocalOption(key: key));
}

/// return a human readable windows version
WindowsTarget getWindowsTarget(int buildNumber) {
  if (!isWindows) {
    return WindowsTarget.naw;
  }
  if (buildNumber >= 22000) {
    return WindowsTarget.w11;
  } else if (buildNumber >= 10240) {
    return WindowsTarget.w10;
  } else if (buildNumber >= 9600) {
    return WindowsTarget.w8_1;
  } else if (buildNumber >= 9200) {
    return WindowsTarget.w8;
  } else if (buildNumber >= 7601) {
    return WindowsTarget.w7;
  } else if (buildNumber >= 6002) {
    return WindowsTarget.vista;
  } else {
    // minimum support
    return WindowsTarget.xp;
  }
}

String getWindowName({WindowType? overrideType}) {
  final name = bind.mainGetAppNameSync();
  switch (overrideType ?? kWindowType) {
    case WindowType.Main:
      return name;
    case WindowType.PL:
      return "止盈止损设置";
    case WindowType.RemoteDesktop:
      return "交易";
    default:
      break;
  }
  return name;
}

String getDesktopTabLabel(String peerId, String alias) {
  String label = alias.isEmpty ? peerId : alias;
  try {
    String peer = bind.mainGetPeerSync(id: peerId);
    Map<String, dynamic> config = jsonDecode(peer);
    if (config['info']['hostname'] is String) {
      String hostname = config['info']['hostname'];
      if (hostname.isNotEmpty && !label.toLowerCase().contains(hostname.toLowerCase())) {
        label += "@$hostname";
      }
    }
  } catch (e) {
    debugPrint("Failed to get hostname:$e");
  }
  return label;
}

String getWindowNameWithId(String id, {WindowType? overrideType}) {
  final alias = bind.mainGetPeerOptionSync(id: id, key: 'alias');
  return "${getDesktopTabLabel(id, alias)} - ${getWindowName(overrideType: overrideType)}";
}

Future _saveSessionWindowPosition(WindowType windowType, int windowId, bool isMaximized, bool isFullscreen, LastWindowPosition pos) async {
  final remoteList = await DesktopMultiWindow.invokeMethod(windowId, kWindowEventGetRemoteList, null);
  getPeerPos(String peerId) {
    if (isMaximized || isFullscreen) {
      final peerPos = bind.mainGetPeerFlutterOptionSync(id: peerId, k: windowFramePrefix + windowType.name);
      var lpos = LastWindowPosition.loadFromString(peerPos);
      return LastWindowPosition(lpos?.width ?? pos.offsetWidth, lpos?.height ?? pos.offsetHeight, lpos?.offsetWidth ?? pos.offsetWidth,
              lpos?.offsetHeight ?? pos.offsetHeight, isMaximized, isFullscreen)
          .toString();
    } else {
      return pos.toString();
    }
  }

  if (remoteList != null) {
    for (final peerId in remoteList.split(',')) {
      bind.mainSetPeerFlutterOptionSync(id: peerId, k: windowFramePrefix + windowType.name, v: getPeerPos(peerId));
    }
  }
}

/// return null means center
Future<OffsetDevicePixelRatio?> _adjustRestoreMainWindowOffset(
  double? left,
  double? top,
  double? width,
  double? height,
) async {
  if (left == null || top == null || width == null || height == null) {
    return null;
  }

  double? frameLeft;
  double? frameTop;
  double? frameRight;
  double? frameBottom;
  double devicePixelRatio = 1.0;

  if (isDesktop || isWebDesktop) {
    for (final screen in await window_size.getScreenList()) {
      if (isPointInRect(Offset(left, top), screen.visibleFrame)) {
        devicePixelRatio = screen.scaleFactor;
      }
      frameLeft = frameLeft == null ? screen.visibleFrame.left : min(screen.visibleFrame.left, frameLeft);
      frameTop = frameTop == null ? screen.visibleFrame.top : min(screen.visibleFrame.top, frameTop);
      frameRight = frameRight == null ? screen.visibleFrame.right : max(screen.visibleFrame.right, frameRight);
      frameBottom = frameBottom == null ? screen.visibleFrame.bottom : max(screen.visibleFrame.bottom, frameBottom);
    }
  }
  if (frameLeft == null) {
    frameLeft = 0.0;
    frameTop = 0.0;
    frameRight = ((isDesktop || isWebDesktop) ? kDesktopMaxDisplaySize : kMobileMaxDisplaySize).toDouble();
    frameBottom = ((isDesktop || isWebDesktop) ? kDesktopMaxDisplaySize : kMobileMaxDisplaySize).toDouble();
  }
  const minWidth = 10.0;
  if ((left + minWidth) > frameRight! || (top + minWidth) > frameBottom! || (left + width - minWidth) < frameLeft || top < frameTop!) {
    return null;
  } else {
    return OffsetDevicePixelRatio(Offset(left, top), devicePixelRatio);
  }
}

Future<bool> restoreWindowPosition(WindowType type, {int? windowId, String? peerId, int? display}) async {
  if (bind.mainGetEnv(key: "DISABLE_RUSTDESK_RESTORE_WINDOW_POSITION").isNotEmpty) {
    return false;
  }
  if (type != WindowType.Main && windowId == null) {
    debugPrint("Error: windowId cannot be null when saving positions for sub window");
    return false;
  }

  bool isRemotePeerPos = false;
  String? pos;
  // No need to check mainGetLocalBoolOptionSync(kOptionOpenNewConnInTabs)
  // Though "open in tabs" is true and the new window restore peer position, it's ok.
  if (type == WindowType.RemoteDesktop && windowId != null && peerId != null) {
    final peerPos = bind.mainGetPeerFlutterOptionSync(id: peerId, k: windowFramePrefix + type.name);
    if (peerPos.isNotEmpty) {
      pos = peerPos;
    }
    isRemotePeerPos = pos != null;
  }
  pos ??= bind.getLocalFlutterOption(k: windowFramePrefix + type.name);

  var lpos = LastWindowPosition.loadFromString(pos);
  if (lpos == null) {
    debugPrint("no window position saved, ignoring position restoration");
    return false;
  }
  if (type == WindowType.RemoteDesktop) {
    if (!isRemotePeerPos && windowId != null) {
      if (lpos.offsetWidth != null) {
        lpos.offsetWidth = lpos.offsetWidth! + windowId * kNewWindowOffset;
      }
      if (lpos.offsetHeight != null) {
        lpos.offsetHeight = lpos.offsetHeight! + windowId * kNewWindowOffset;
      }
    }
    if (display != null) {
      if (lpos.offsetWidth != null) {
        lpos.offsetWidth = lpos.offsetWidth! + display * kNewWindowOffset;
      }
      if (lpos.offsetHeight != null) {
        lpos.offsetHeight = lpos.offsetHeight! + display * kNewWindowOffset;
      }
    }
  }

  final size = await _adjustRestoreMainWindowSize(lpos.width, lpos.height);
  final offsetDevicePixelRatio = await _adjustRestoreMainWindowOffset(
    lpos.offsetWidth,
    lpos.offsetHeight,
    size.width,
    size.height,
  );
  debugPrint(
      "restore lpos: ${size.width}/${size.height}, offset:${offsetDevicePixelRatio?.offset.dx}/${offsetDevicePixelRatio?.offset.dy}, devicePixelRatio:${offsetDevicePixelRatio?.devicePixelRatio}, isMaximized: ${lpos.isMaximized}, isFullscreen: ${lpos.isFullscreen}");

  switch (type) {
    case WindowType.Main:
      // https://github.com/rustdesk/rustdesk/issues/8038
      // `setBounds()` in `window_manager` will use the current devicePixelRatio.
      // So we need to adjust the offset by the scale factor.
      // https://github.com/rustdesk-org/window_manager/blob/f19acdb008645366339444a359a45c3257c8b32e/windows/window_manager.cpp#L701
      if (isWindows) {
        double? curDevicePixelRatio;
        Offset curPos = await windowManager.getPosition();
        for (final screen in await window_size.getScreenList()) {
          if (isPointInRect(curPos, screen.visibleFrame)) {
            curDevicePixelRatio = screen.scaleFactor;
          }
        }
        if (curDevicePixelRatio != null && curDevicePixelRatio != 0 && offsetDevicePixelRatio != null) {
          if (offsetDevicePixelRatio.devicePixelRatio != 0) {
            final scale = offsetDevicePixelRatio.devicePixelRatio / curDevicePixelRatio;
            offsetDevicePixelRatio.offset = offsetDevicePixelRatio.offset.scale(scale, scale);
            debugPrint("restore new offset: ${offsetDevicePixelRatio.offset.dx}/${offsetDevicePixelRatio.offset.dy}, scale:$scale");
          }
        }
      }
      restorePos() async {
        if (offsetDevicePixelRatio == null) {
          await windowManager.center();
        } else {
          await windowManager.setPosition(offsetDevicePixelRatio.offset);
        }
      }
      if (lpos.isMaximized == true) {
        await restorePos();
        if (!(bind.isIncomingOnly() || bind.isOutgoingOnly())) {
          await windowManager.maximize();
        }
      } else {
        if (!bind.isIncomingOnly() || bind.isOutgoingOnly()) {
          await windowManager.setSize(size);
        }
        await restorePos();
      }
      return true;
    default:
      final wc = WindowController.fromWindowId(windowId!);
      restoreFrame() async {
        if (offsetDevicePixelRatio == null) {
          await wc.center();
        } else {
          final frame = Rect.fromLTWH(offsetDevicePixelRatio.offset.dx, offsetDevicePixelRatio.offset.dy, size.width, size.height);
          await wc.setFrame(frame);
        }
      }
      if (lpos.isFullscreen == true) {
        if (!isMacOS) {
          await restoreFrame();
        }
        // An duration is needed to avoid the window being restored after fullscreen.
        Future.delayed(const Duration(milliseconds: 300), () async {
          if (kWindowId == windowId) {
            stateGlobal.setFullscreen(true);
          } else {
            // If is not current window, we need to send a fullscreen message to `windowId`
            DesktopMultiWindow.invokeMethod(windowId, kWindowEventSetFullscreen, 'true');
          }
        });
      } else if (lpos.isMaximized == true) {
        await restoreFrame();
        // An duration is needed to avoid the window being restored after maximized.
        Future.delayed(const Duration(milliseconds: 300), () async {
          await wc.maximize();
        });
      } else {
        await restoreFrame();
      }
      break;
  }
  return false;
}

/// Save window position and size on exit
/// Note that windowId must be provided if it's subwindow
Future<void> saveWindowPosition(WindowType type, {int? windowId}) async {
  if (type != WindowType.Main && windowId == null) {
    debugPrint("Error: windowId cannot be null when saving positions for sub window");
  }

  late Offset position;
  late Size sz;
  late bool isMaximized;
  bool isFullscreen = stateGlobal.fullscreen.isTrue;
  setPreFrame() {
    final pos = bind.getLocalFlutterOption(k: windowFramePrefix + type.name);
    var lpos = LastWindowPosition.loadFromString(pos);
    position = Offset(lpos?.offsetWidth ?? position.dx, lpos?.offsetHeight ?? position.dy);
    sz = Size(lpos?.width ?? sz.width, lpos?.height ?? sz.height);
  }

  switch (type) {
    case WindowType.Main:
      // Checking `bind.isIncomingOnly()` is a simple workaround for MacOS.
      // `await windowManager.isMaximized()` will always return true
      // if is not resizable. The reason is unknown.
      //
      // `setResizable(!bind.isIncomingOnly());` in main.dart
      isMaximized = bind.isIncomingOnly() ? false : await windowManager.isMaximized();
      if (isFullscreen || isMaximized) {
        setPreFrame();
      } else {
        position = await windowManager.getPosition();
        sz = await windowManager.getSize();
      }
      break;
    default:
      final wc = WindowController.fromWindowId(windowId!);
      isMaximized = await wc.isMaximized();
      if (isFullscreen || isMaximized) {
        setPreFrame();
      } else {
        final Rect frame;
        try {
          frame = await wc.getFrame();
        } catch (e) {
          debugPrint("Failed to get frame of window $windowId, it may be hidden");
          return;
        }
        position = frame.topLeft;
        sz = frame.size;
      }
      break;
  }
  if (isWindows) {
    const kMinOffset = -10000;
    const kMaxOffset = 10000;
    if (position.dx < kMinOffset || position.dy < kMinOffset || position.dx > kMaxOffset || position.dy > kMaxOffset) {
      debugPrint("Invalid position: $position, ignore saving position");
      return;
    }
  }

  final pos = LastWindowPosition(sz.width, sz.height, position.dx, position.dy, isMaximized, isFullscreen);
  debugPrint(
      "Saving frame: $windowId: ${pos.width}/${pos.height}, offset:${pos.offsetWidth}/${pos.offsetHeight}, isMaximized:${pos.isMaximized}, isFullscreen:${pos.isFullscreen}");

  await bind.setLocalFlutterOption(k: windowFramePrefix + type.name, v: pos.toString());

  if (type == WindowType.RemoteDesktop && windowId != null) {
    await _saveSessionWindowPosition(type, windowId, isMaximized, isFullscreen, pos);
  }
}

/// Window status callback
Future<void> onActiveWindowChanged() async {
  // print(
  //     "[MultiWindowHandler] active window changed: ${rustDeskWinManager.getActiveWindows()}");
  if (rustDeskWinManager.getActiveWindows().isEmpty) {
    // close all sub windows
    try {
      if (isLinux) {
        await Future.wait([saveWindowPosition(WindowType.Main), rustDeskWinManager.closeAllSubWindows()]);
      } else {
        await rustDeskWinManager.closeAllSubWindows();
      }
    } catch (err) {
      debugPrintStack(label: "$err");
    } finally {
      debugPrint("Start closing RustDesk...");
      await windowManager.setPreventClose(false);
      await windowManager.close();
      if (isMacOS) {
        // If we call without delay, `flutter/macos/Runner/MainFlutterWindow.swift` can handle the "terminate" event.
        // But the app will not close.
        //
        // No idea why we need to delay here, `terminate()` itself is also an async function.
        Future.delayed(Duration.zero, () {
          RdPlatformChannel.instance.terminate();
        });
      }
    }
  }
}

enum DesktopType {
  main,
  remote,
  pl,
  condition,
}

class OffsetDevicePixelRatio {
  Offset offset;
  final double devicePixelRatio;
  OffsetDevicePixelRatio(this.offset, this.devicePixelRatio);
}

class LastWindowPosition {
  double? width;
  double? height;
  double? offsetWidth;
  double? offsetHeight;
  bool? isMaximized;
  bool? isFullscreen;

  LastWindowPosition(this.width, this.height, this.offsetWidth, this.offsetHeight, this.isMaximized, this.isFullscreen);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "width": width,
      "height": height,
      "offsetWidth": offsetWidth,
      "offsetHeight": offsetHeight,
      "isMaximized": isMaximized,
      "isFullscreen": isFullscreen,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  static LastWindowPosition? loadFromString(String content) {
    if (content.isEmpty) {
      return null;
    }
    try {
      final m = jsonDecode(content);
      return LastWindowPosition(m["width"], m["height"], m["offsetWidth"], m["offsetHeight"], m["isMaximized"], m["isFullscreen"]);
    } catch (e) {
      debugPrintStack(label: 'Failed to load LastWindowPosition "$content" ${e.toString()}');
      return null;
    }
  }
}

class MyTheme {
  MyTheme._();

  static const Color grayBg = Color(0xFFEFEFF2);
  static const Color accent = Color(0xFF0071FF);
  static const Color accent50 = Color(0x770071FF);
  static const Color accent80 = Color(0xAA0071FF);
  static const Color canvasColor = Color(0xFF212121);
  static const Color border = Color(0xFFCCCCCC);
  static const Color idColor = Color(0xFF00B6F0);
  static const Color darkGray = Color.fromARGB(255, 148, 148, 148);
  static const Color cmIdColor = Color(0xFF21790B);
  static const Color dark = Colors.black87;
  static const Color button = Color(0xFF2C8CFF);
  static const Color hoverBorder = Color(0xFF999999);

  // ListTile
  static const ListTileThemeData listTileTheme = ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
  );

  static SwitchThemeData switchTheme() {
    return SwitchThemeData(splashRadius: (isDesktop || isWebDesktop) ? 0 : kRadialReactionRadius);
  }

  static RadioThemeData radioTheme() {
    return RadioThemeData(splashRadius: (isDesktop || isWebDesktop) ? 0 : kRadialReactionRadius);
  }

  // Checkbox
  static const CheckboxThemeData checkboxTheme = CheckboxThemeData(
    splashRadius: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
  );

  // TextButton
  // Value is used to calculate "dialog.actionsPadding"
  static const double mobileTextButtonPaddingLR = 20;

  // TextButton on mobile needs a fixed padding, otherwise small buttons
  // like "OK" has a larger left/right padding.
  static TextButtonThemeData mobileTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: mobileTextButtonPaddingLR),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  );

  //tooltip
  static TooltipThemeData tooltipTheme() {
    return TooltipThemeData(
      waitDuration: Duration(seconds: 1, milliseconds: 500),
    );
  }

  // Dialogs
  static const double dialogPadding = 24;

  // padding bottom depends on content (some dialogs has no content)
  static EdgeInsets dialogTitlePadding({bool content = true}) {
    final double p = dialogPadding;

    return EdgeInsets.fromLTRB(p, p, p, content ? 0 : p);
  }

  // padding bottom depends on actions (mobile has dialogs without actions)
  static EdgeInsets dialogContentPadding({bool actions = true}) {
    final double p = dialogPadding;

    return (isDesktop || isWebDesktop) ? EdgeInsets.fromLTRB(p, p, p, actions ? (p - 4) : p) : EdgeInsets.fromLTRB(p, p, p, actions ? (p / 2) : p);
  }

  static EdgeInsets dialogActionsPadding() {
    final double p = dialogPadding;

    return (isDesktop || isWebDesktop) ? EdgeInsets.fromLTRB(p, 0, p, (p - 4)) : EdgeInsets.fromLTRB(p, 0, (p - mobileTextButtonPaddingLR), (p / 2));
  }

  static EdgeInsets dialogButtonPadding = (isDesktop || isWebDesktop) ? EdgeInsets.only(left: dialogPadding) : EdgeInsets.only(left: dialogPadding / 3);

  static ScrollbarThemeData scrollbarTheme = ScrollbarThemeData(
    thickness: MaterialStateProperty.all(6),
    thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
      if (states.contains(MaterialState.dragged)) {
        return Colors.grey[900];
      } else if (states.contains(MaterialState.hovered)) {
        return Colors.grey[700];
      } else {
        return Colors.grey[500];
      }
    }),
    crossAxisMargin: 4,
  );

  static ScrollbarThemeData scrollbarThemeDark = scrollbarTheme.copyWith(
    thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
      if (states.contains(MaterialState.dragged)) {
        return Colors.grey[100];
      } else if (states.contains(MaterialState.hovered)) {
        return Colors.grey[300];
      } else {
        return Colors.grey[500];
      }
    }),
  );

  static ThemeData lightTheme = ThemeData(
    // https://stackoverflow.com/questions/77537315/after-upgrading-to-flutter-3-16-the-app-bar-background-color-button-size-and
    useMaterial3: false,
    brightness: Brightness.light,
    hoverColor: Color.fromARGB(255, 224, 224, 224),
    scaffoldBackgroundColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      shadowColor: Colors.transparent,
    ),
    dialogTheme: DialogTheme(
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(
          width: 1,
          color: grayBg,
        ),
      ),
    ),
    scrollbarTheme: scrollbarTheme,
    inputDecorationTheme: isDesktop
        ? InputDecorationTheme(
            fillColor: grayBg,
            filled: true,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )
        : null,
    textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 19, color: Colors.black87),
        titleSmall: TextStyle(fontSize: 14, color: Colors.black87),
        bodySmall: TextStyle(fontSize: 12, color: Colors.black87, height: 1.25),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black87, height: 1.25),
        labelLarge: TextStyle(fontSize: 16.0, color: MyTheme.accent80)),
    cardColor: grayBg,
    hintColor: Color(0xFFAAAAAA),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.black87,
    ),
    tooltipTheme: tooltipTheme(),
    splashColor: (isDesktop || isWebDesktop) ? Colors.transparent : null,
    highlightColor: (isDesktop || isWebDesktop) ? Colors.transparent : null,
    splashFactory: (isDesktop || isWebDesktop) ? NoSplash.splashFactory : null,
    textButtonTheme: (isDesktop || isWebDesktop)
        ? TextButtonThemeData(
            style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
          )
        : mobileTextButtonTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyTheme.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: grayBg,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    switchTheme: switchTheme(),
    radioTheme: radioTheme(),
    checkboxTheme: checkboxTheme,
    listTileTheme: listTileTheme,
    menuBarTheme: MenuBarThemeData(style: MenuStyle(backgroundColor: MaterialStatePropertyAll(Colors.white))),
    colorScheme: ColorScheme.light(primary: Colors.blue, secondary: accent, background: grayBg),
    popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: (isDesktop || isWebDesktop) ? Color(0xFFECECEC) : Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        )),
  ).copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ColorThemeExtension.light,
      TabbarTheme.light,
    ],
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    hoverColor: Color.fromARGB(255, 45, 46, 53),
    scaffoldBackgroundColor: Color(0xFF18191E),
    dialogBackgroundColor: Color(0xFF18191E),
    appBarTheme: AppBarTheme(
      shadowColor: Colors.transparent,
    ),
    dialogTheme: DialogTheme(
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(
          width: 1,
          color: Color(0xFF24252B),
        ),
      ),
    ),
    scrollbarTheme: scrollbarThemeDark,
    inputDecorationTheme: (isDesktop || isWebDesktop)
        ? InputDecorationTheme(
            fillColor: Color(0xFF24252B),
            filled: true,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )
        : null,
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 19),
      titleSmall: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 12, height: 1.25),
      bodyMedium: TextStyle(fontSize: 14, height: 1.25),
      labelLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: accent80,
      ),
    ),
    cardColor: Color(0xFF24252B),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.white70,
    ),
    tooltipTheme: tooltipTheme(),
    splashColor: (isDesktop || isWebDesktop) ? Colors.transparent : null,
    highlightColor: (isDesktop || isWebDesktop) ? Colors.transparent : null,
    splashFactory: (isDesktop || isWebDesktop) ? NoSplash.splashFactory : null,
    textButtonTheme: (isDesktop || isWebDesktop)
        ? TextButtonThemeData(
            style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
              disabledForegroundColor: Colors.white70,
              foregroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
          )
        : mobileTextButtonTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyTheme.accent,
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white70,
        disabledBackgroundColor: Colors.white10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Color(0xFF24252B),
        side: BorderSide(color: Colors.white12, width: 0.5),
        disabledForegroundColor: Colors.white70,
        foregroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    switchTheme: switchTheme(),
    radioTheme: radioTheme(),
    checkboxTheme: checkboxTheme,
    listTileTheme: listTileTheme,
    menuBarTheme: MenuBarThemeData(style: MenuStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFF121212)))),
    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      secondary: accent,
      background: Color(0xFF24252B),
    ),
    popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.white24),
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    )),
  ).copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ColorThemeExtension.dark,
      TabbarTheme.dark,
    ],
  );

  static ThemeMode getThemeModePreference() {
    return themeModeFromString(bind.mainGetLocalOption(key: kCommConfKeyTheme));
  }

  static ThemeMode currentThemeMode() {
    final preference = getThemeModePreference();
    if (preference == ThemeMode.system) {
      if (WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light) {
        return ThemeMode.light;
      } else {
        return ThemeMode.dark;
      }
    } else {
      return preference;
    }
  }

  static ColorThemeExtension color(BuildContext context) {
    return Theme.of(context).extension<ColorThemeExtension>()!;
  }

  static ThemeMode themeModeFromString(String v) {
    switch (v) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class ColorThemeExtension extends ThemeExtension<ColorThemeExtension> {
  const ColorThemeExtension({
    required this.border,
    required this.border2,
    required this.border3,
    required this.highlight,
    required this.drag_indicator,
    required this.shadow,
    required this.errorBannerBg,
    required this.me,
    required this.toastBg,
    required this.toastText,
    required this.divider,
  });

  final Color? border;
  final Color? border2;
  final Color? border3;
  final Color? highlight;
  final Color? drag_indicator;
  final Color? shadow;
  final Color? errorBannerBg;
  final Color? me;
  final Color? toastBg;
  final Color? toastText;
  final Color? divider;

  static final light = ColorThemeExtension(
    border: const Color(0xFFCCCCCC),
    border2: const Color(0xFFBBBBBB),
    border3: Colors.black26,
    highlight: const Color(0xFFE5E5E5),
    drag_indicator: Colors.grey[800],
    shadow: Colors.black,
    errorBannerBg: const Color(0xFFFDEEEB),
    me: Colors.green,
    toastBg: Colors.black.withOpacity(0.6),
    toastText: Colors.white,
    divider: Colors.black38,
  );

  static final dark = ColorThemeExtension(
    border: const Color(0xFF555555),
    border2: const Color(0xFFE5E5E5),
    border3: Colors.white24,
    highlight: const Color(0xFF3F3F3F),
    drag_indicator: Colors.grey,
    shadow: Colors.grey,
    errorBannerBg: const Color(0xFF470F2D),
    me: Colors.greenAccent,
    toastBg: Colors.white.withOpacity(0.6),
    toastText: Colors.black,
    divider: Colors.white38,
  );

  @override
  ThemeExtension<ColorThemeExtension> copyWith({
    Color? border,
    Color? border2,
    Color? border3,
    Color? highlight,
    Color? drag_indicator,
    Color? shadow,
    Color? errorBannerBg,
    Color? me,
    Color? toastBg,
    Color? toastText,
    Color? divider,
  }) {
    return ColorThemeExtension(
      border: border ?? this.border,
      border2: border2 ?? this.border2,
      border3: border3 ?? this.border3,
      highlight: highlight ?? this.highlight,
      drag_indicator: drag_indicator ?? this.drag_indicator,
      shadow: shadow ?? this.shadow,
      errorBannerBg: errorBannerBg ?? this.errorBannerBg,
      me: me ?? this.me,
      toastBg: toastBg ?? this.toastBg,
      toastText: toastText ?? this.toastText,
      divider: divider ?? this.divider,
    );
  }

  @override
  ThemeExtension<ColorThemeExtension> lerp(ThemeExtension<ColorThemeExtension>? other, double t) {
    if (other is! ColorThemeExtension) {
      return this;
    }
    return ColorThemeExtension(
      border: Color.lerp(border, other.border, t),
      border2: Color.lerp(border2, other.border2, t),
      border3: Color.lerp(border3, other.border3, t),
      highlight: Color.lerp(highlight, other.highlight, t),
      drag_indicator: Color.lerp(drag_indicator, other.drag_indicator, t),
      shadow: Color.lerp(shadow, other.shadow, t),
      errorBannerBg: Color.lerp(shadow, other.errorBannerBg, t),
      me: Color.lerp(shadow, other.me, t),
      toastBg: Color.lerp(shadow, other.toastBg, t),
      toastText: Color.lerp(shadow, other.toastText, t),
      divider: Color.lerp(shadow, other.divider, t),
    );
  }
}
