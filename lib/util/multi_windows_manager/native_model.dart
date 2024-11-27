import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../generated_bridge.dart';

import '../../main.dart';
import 'common.dart';
import 'consts.dart';

final class RgbaFrame extends Struct {
  @Uint32()
  external int len;
  external Pointer<Uint8> data;
}

typedef F3 = Pointer<Uint8> Function(Pointer<Utf8>, int);
typedef F3Dart = Pointer<Uint8> Function(Pointer<Utf8>, Int32);
typedef HandleEvent = Future<void> Function(Map<String, dynamic> evt);

/// FFI wrapper around the native Rust core.
/// Hides the platform differences.
class PlatformFFI {
  String _dir = '';
  String _homeDir = '';
  final _eventHandlers = <String, Map<String, HandleEvent>>{};
  late RustdeskImpl _ffiBind;
  late String _appType;
  StreamEventHandler? _eventCallback;

  PlatformFFI._();

  static final PlatformFFI instance = PlatformFFI._();
  final _toAndroidChannel = const MethodChannel('mChannel');

  RustdeskImpl get ffiBind => _ffiBind;

  static get localeName => Platform.localeName;

  static get isMain => instance._appType == kAppTypeMain;

  bool registerEventHandler(String eventName, String handlerName, HandleEvent handler) {
    debugPrint('registerEventHandler $eventName $handlerName');
    var handlers = _eventHandlers[eventName];
    if (handlers == null) {
      _eventHandlers[eventName] = {handlerName: handler};
      return true;
    } else {
      if (handlers.containsKey(handlerName)) {
        return false;
      } else {
        handlers[handlerName] = handler;
        return true;
      }
    }
  }

  void unregisterEventHandler(String eventName, String handlerName) {
    debugPrint('unregisterEventHandler $eventName $handlerName');
    var handlers = _eventHandlers[eventName];
    if (handlers != null) {
      handlers.remove(handlerName);
    }
  }

  String translate(String name, String locale) => _ffiBind.translate(name: name, locale: locale);

  int getRgbaSize(SessionID sessionId, int display) => _ffiBind.sessionGetRgbaSize(sessionId: sessionId, display: display);
  void nextRgba(SessionID sessionId, int display) => _ffiBind.sessionNextRgba(sessionId: sessionId, display: display);
  void registerPixelbufferTexture(SessionID sessionId, int display, int ptr) =>
      _ffiBind.sessionRegisterPixelbufferTexture(sessionId: sessionId, display: display, ptr: ptr);
  void registerGpuTexture(SessionID sessionId, int display, int ptr) => _ffiBind.sessionRegisterGpuTexture(sessionId: sessionId, display: display, ptr: ptr);

  /// Init the FFI class, loads the native Rust core library.
  Future<void> init(String appType) async {
    _appType = appType;
    final dylib = isAndroid
        ? DynamicLibrary.open('librustdesk.so')
        : isLinux
            ? DynamicLibrary.open('librustdesk.so')
            : isWindows
                ? DynamicLibrary.open('librustdesk.dll')
                : DynamicLibrary.process();
    debugPrint('initializing FFI $_appType');
    try {
      // SYSTEM user failed
      _dir = (await getApplicationDocumentsDirectory()).path;
    } catch (e) {
      debugPrint('Failed to get documents directory: $e');
    }
    _ffiBind = RustdeskImpl(dylib);

    if (isLinux) {
      if (isMain) {
        // Start a dbus service for uri links, no need to await
        _ffiBind.mainStartDbusServer();
      }
    } else if (isMacOS && isMain) {
      // Start ipc service for uri links.
      _ffiBind.mainStartIpcUrlServer();
    }
    _startListenEvent(_ffiBind); // global event
    String id = 'NA';
    String name = 'Flutter';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      name = '${androidInfo.brand}-${androidInfo.model}';
      id = androidInfo.id.hashCode.toString();
      androidVersion = androidInfo.version.sdkInt;
    } else if (isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      name = iosInfo.utsname.machine;
      id = iosInfo.identifierForVendor.hashCode.toString();
    } else if (isLinux) {
      LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
      name = linuxInfo.name;
      id = linuxInfo.machineId ?? linuxInfo.id;
    } else if (isWindows) {
      try {
        // request windows build number to fix overflow on win7
        windowsBuildNumber = getWindowsTargetBuildNumber();
        WindowsDeviceInfo winInfo = await deviceInfo.windowsInfo;
        name = winInfo.computerName;
        id = winInfo.computerName;
      } catch (e) {
        debugPrintStack(label: "get windows device info failed: $e");
        name = "unknown";
        id = "unknown";
      }
    } else if (isMacOS) {
      MacOsDeviceInfo macOsInfo = await deviceInfo.macOsInfo;
      name = macOsInfo.computerName;
      id = macOsInfo.systemGUID ?? '';
    }
    if (isAndroid || isIOS) {
      debugPrint('_appType:$_appType,info1-id:$id,info2-name:$name,dir:$_dir,homeDir:$_homeDir');
    } else {
      debugPrint('_appType:$_appType,info1-id:$id,info2-name:$name,dir:$_dir');
    }
    // if (desktopType == DesktopType.cm) {
    //   await _ffiBind.cmInit();
    // }
    await _ffiBind.mainDeviceId(id: id);
    await _ffiBind.mainDeviceName(name: name);
    await _ffiBind.mainSetHomeDir(home: _homeDir);
    await _ffiBind.mainInit(
      appDir: _dir,
      customClientConfig: '',
    );
  }

  Future<bool> tryHandle(Map<String, dynamic> evt) async {
    final name = evt['name'];
    if (name != null) {
      final handlers = _eventHandlers[name];
      if (handlers != null) {
        if (handlers.isNotEmpty) {
          for (var handler in handlers.values) {
            await handler(evt);
          }
          return true;
        }
      }
    }
    return false;
  }

  /// Start listening to the Rust core's events and frames.
  void _startListenEvent(RustdeskImpl rustdeskImpl) {
    final appType = _appType == kAppTypeDesktopRemote ? '$_appType,$kWindowId' : _appType;
    var sink = rustdeskImpl.startGlobalEventStream(appType: appType);
    sink.listen((message) {
      () async {
        try {
          Map<String, dynamic> event = json.decode(message);
          // _tryHandle here may be more flexible than _eventCallback
          if (!await tryHandle(event)) {
            if (_eventCallback != null) {
              await _eventCallback!(event);
            }
          }
        } catch (e) {
          debugPrint('json.decode fail(): $e');
        }
      }();
    });
  }

  void setEventCallback(StreamEventHandler fun) async {
    _eventCallback = fun;
  }

  void setRgbaCallback(void Function(int, Uint8List) fun) async {}

  void startDesktopWebListener() {}

  void stopDesktopWebListener() {}

  void setMethodCallHandler(FMethod callback) {
    _toAndroidChannel.setMethodCallHandler((call) async {
      callback(call.method, call.arguments);
      return null;
    });
  }

  invokeMethod(String method, [dynamic arguments]) async {
    if (!isAndroid) return Future<bool>(() => false);
    return await _toAndroidChannel.invokeMethod(method, arguments);
  }

  void syncAndroidServiceAppDirConfigPath() {
    invokeMethod(AndroidChannel.kSyncAppDirConfigPath, _dir);
  }
}
