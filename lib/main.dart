import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:trade/page/draw/color_picker.dart';
import 'package:trade/page/draw/draw_order.dart';
import 'package:trade/page/draw/draw_tool.dart';
import 'package:trade/page/draw/line_setting.dart';
import 'package:trade/page/home/home.dart';
import 'package:trade/page/secondary/condition.dart';
import 'package:trade/page/secondary/sector_manage.dart';
import 'package:trade/page/secondary/notification.dart';
import 'package:trade/page/secondary/pl_page.dart';
import 'package:trade/page/trade/order_page.dart';
import 'package:trade/page/trade/trade.dart';
import 'package:trade/util/multi_windows_manager/common.dart';
import 'package:trade/util/multi_windows_manager/consts.dart';
import 'package:trade/util/multi_windows_manager/multi_window_manager.dart';
import 'package:trade/util/multi_windows_manager/platform_model.dart';
import 'package:trade/util/multi_windows_manager/refresh_wrapper.dart';
import 'package:trade/util/multi_windows_manager/state_model.dart';
import 'package:trade/util/shared_preferences/shared_preferences_key.dart';
import 'package:trade/util/shared_preferences/shared_preferences_utils.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'config/common.dart';

/// Checks if the current environment is a desktop environment.
int? kWindowId;
int? tradeWindowId;
int? dOrderWindowId;
int? drawToolWindowId;
WindowType? kWindowType;
Size? size;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());

  if (isDesktop) {
    if (args.isNotEmpty && args.first == 'multi_window') {
      kWindowId = int.parse(args[1]);
      stateGlobal.setWindowId(kWindowId!);
      if (!isMacOS) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(false);
      }
      final argument = args[2].isEmpty ? <String, dynamic>{} : jsonDecode(args[2]) as Map<String, dynamic>;
      int type = argument['type'] ?? -1;
      argument['windowId'] = kWindowId;
      kWindowType = type.windowType;
      switch (kWindowType) {
        case WindowType.Trade:
          desktopType = DesktopType.trade;
          runMultiWindow(
            argument,
            kAppTypeDesktopRemote,
          );
          break;
        case WindowType.Order:
          desktopType = DesktopType.order;
          runMultiWindow(
            argument,
            kAppTypeDesktopOrder,
          );
          break;
        case WindowType.PL:
          desktopType = DesktopType.pl;
          runMultiWindow(
            argument,
            kAppTypeDesktopPL,
          );
          break;
        case WindowType.Condition:
          desktopType = DesktopType.condition;
          runMultiWindow(
            argument,
            kAppTypeDesktopCondition,
          );
          break;
        case WindowType.Draw:
          desktopType = DesktopType.draw;
          runMultiWindow(
            argument,
            kAppTypeDesktopDraw,
          );
          break;
        case WindowType.Setting:
          desktopType = DesktopType.setting;
          runMultiWindow(
            argument,
            kAppTypeDesktopLineSetting,
          );
          break;
        case WindowType.Color:
          desktopType = DesktopType.color;
          runMultiWindow(
            argument,
            kAppTypeDesktopColorPicker,
          );
          break;
        case WindowType.Notification:
          desktopType = DesktopType.notification;
          runMultiWindow(
            argument,
            kAppTypeDesktopNotification,
          );
          break;
        case WindowType.DrawOrder:
          desktopType = DesktopType.drawOrder;
          runMultiWindow(
            argument,
            kAppTypeDesktopDrawOrder,
          );
          break;
        case WindowType.SectorManage:
          desktopType = DesktopType.sectorManage;
          runMultiWindow(
            argument,
            kAppTypeDesktopSectorManage,
          );
          break;
        default:
          break;
      }
    } else {
      await flutter_acrylic.Window.initialize();
      if (defaultTargetPlatform == TargetPlatform.windows) {
        await flutter_acrylic.Window.hideWindowControls();
      }
      await windowManager.ensureInitialized();
      windowManager.setPreventClose(true);

      await initEnv(kAppTypeMain);
      await bind.mainCheckConnectStatus();
      bind.pluginSyncUi(syncTo: kAppTypeMain);
      bind.pluginListReload();
      // logger.f((await windowManager.getSize()));
      windowManager.waitUntilReadyToShow().then((_) async {
        await windowManager.setTitleBarStyle(
          TitleBarStyle.hidden,
          windowButtonVisibility: false,
        );
        windowManager
          ..setSize(const Size(1450, 850))
          ..setMinimumSize(const Size(1450, 850))
          ..setAlignment(Alignment.center)
          ..setTitle(Common.appName)
          ..setPreventClose(true)
          ..setSkipTaskbar(false)
          ..show();
      });
      runApp(const MyApp());
      rustDeskWinManager.registerActiveWindow(kWindowMainId);
      // SpUtils.clear();
      // SpUtils.remove(SpKey.myPage);
    }
  }
}

Future<void> initEnv(String appType) async {
  await platformFFI.init(appType);
  await initGlobalFFI();
}

bool get isWindows11 {
  if (!Platform.isWindows) return false;
  final version = Platform.operatingSystemVersion;
  return version.contains('10.0.22');
}

void runMultiWindow(
  Map<String, dynamic> argument,
  String appType,
) async {
  await initEnv(appType);
  final title = getWindowName();
  String? string = await SpUtils.getString(SpKey.screenSize);
  Size size = PlatformDispatcher.instance.implicitView!.physicalSize / PlatformDispatcher.instance.implicitView!.devicePixelRatio;
  if (string != null) {
    Map map = jsonDecode(string);
    size = Size(map["width"], map["height"]);
  }
  if (isWindows11) {
    size = Size(size.width * 1.5, size.height * 2);
  }
  WindowController.fromWindowId(kWindowId!).setPreventClose(false);
  switch (appType) {
    case kAppTypeDesktopRemote:
      _runTradeApp(
        title,
        argument,
      );
      if (kUseCompatibleUiMode) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(true);
      }
      WindowController.fromWindowId(kWindowId!)
        ..setFrame(const Offset(0, 0) & Size(size.width * 0.65, size.height * 0.53))
        ..setTitle("交易")
        ..center()
        ..show();
      break;
    case kAppTypeDesktopOrder:
      _runOrderApp(
        title,
        argument,
      );
      if (kUseCompatibleUiMode) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(true);
      }
      WindowController.fromWindowId(kWindowId!)
        ..setFrame(const Offset(0, 0) & Size(size.width * 0.45, size.height * 0.56))
        ..setTitle("")
        ..center()
        ..show();
      break;
    case kAppTypeDesktopPL:
      _runPLApp(
        title,
        argument,
      );
      if (kUseCompatibleUiMode) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(true);
      }
      WindowController.fromWindowId(kWindowId!)
        ..setFrame(const Offset(0, 0) & Size(size.width * 0.43, size.height * 0.35))
        ..setTitle("止盈止损")
        ..center()
        ..show();
      break;
    case kAppTypeDesktopCondition:
      _runConditionApp(
        title,
        argument,
      );
      if (kUseCompatibleUiMode) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(true);
      }
      WindowController.fromWindowId(kWindowId!)
        ..setFrame(const Offset(0, 0) & Size(size.width * 0.35, size.height * 0.53))
        ..setTitle("条件单修改")
        ..center()
        ..show();
      break;
    case kAppTypeDesktopDraw:
      _runDrawApp(
        title,
        argument,
      );
      if (kUseCompatibleUiMode) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(true);
      }
      WindowController.fromWindowId(kWindowId!)
        ..setFrame(const Offset(0, 0) & const Size(380, 495))
        ..setTitle("画线工具箱")
        ..center()
        ..show();
      break;
    case kAppTypeDesktopLineSetting:
      _runDrawSetting(
        title,
        argument,
      );
      if (kUseCompatibleUiMode) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(true);
      }
      WindowController.fromWindowId(kWindowId!)
        ..setFrame(const Offset(0, 0) & Size(size.width * 0.26, size.height * 0.4))
        ..setTitle("画线属性")
        ..center()
        ..show();
      break;
    case kAppTypeDesktopColorPicker:
      _runColorPicker(
        title,
        argument,
      );
      if (kUseCompatibleUiMode) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(true);
      }
      WindowController.fromWindowId(kWindowId!)
        ..setFrame(const Offset(0, 0) & Size(size.width * 0.35, size.height * 0.35))
        ..setTitle("颜色")
        ..center()
        ..show();
      break;
    case kAppTypeDesktopDrawOrder:
      _runDrawOrderApp(
        title,
        argument,
      );
      if (kUseCompatibleUiMode) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(true);
      }
      WindowController.fromWindowId(kWindowId!)
        ..setFrame(const Offset(0, 0) & Size(size.width * 0.17, size.height * 0.22))
        ..setTitle("画线下单")
        ..center()
        ..show();
      break;
    case kAppTypeDesktopNotification:
      _runLocalNotification(
        title,
        argument,
      );
      if (kUseCompatibleUiMode) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(true);
      }

      WindowController.fromWindowId(kWindowId!)
        ..setFrame(Offset(size.width - 315, size.height - 340) & const Size(315, 300))
        ..setTitle("提示")
        ..show();
      break;
    case kAppTypeDesktopSectorManage:
      _runSectorManage(
        title,
        argument,
      );
      if (kUseCompatibleUiMode) {
        WindowController.fromWindowId(kWindowId!).showTitleBar(true);
      }
      WindowController.fromWindowId(kWindowId!)
        ..setFrame(const Offset(0, 0) & Size(size.width * 0.28, size.height * 0.35))
        ..setTitle("管理板块")
        ..center()
        ..show();
      break;
    default:
      exit(0);
  }
}

void _runTradeApp(
  String title,
  Map<String, dynamic> argument,
) async {
  runApp(RefreshWrapper(
    builder: (context) => ScreenUtilInit(
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetBuilder<ThemeController>(builder: (themeController) {
            return FluentApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                FluentLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('zh')],
              home: Trade(params: argument),
              navigatorKey: Get.key,
            );
          });
        }),
  ));
}

void _runOrderApp(
  String title,
  Map<String, dynamic> argument,
) async {
  runApp(RefreshWrapper(
    builder: (context) => ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return AnimatedFluentTheme(
              data: FluentThemeData(visualDensity: VisualDensity.standard),
              child: GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: title,
                home: FluentApp(
                  debugShowCheckedModeBanner: false,
                  darkTheme: FluentThemeData(
                    brightness: Brightness.dark,
                    visualDensity: VisualDensity.standard,
                  ),
                  theme: FluentThemeData(
                    visualDensity: VisualDensity.standard,
                  ),
                  home: OrderPage(params: argument),
                  localizationsDelegates: const [
                    FluentLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('en'), Locale('zh')],
                ),
                builder: (context, child) {
                  child = _keepScaleBuilder(context, child);
                  return child;
                },
              ));
        }),
  ));
}

void _runPLApp(
  String title,
  Map<String, dynamic> argument,
) async {
  runApp(RefreshWrapper(
    builder: (context) => AnimatedFluentTheme(
      data: FluentThemeData(visualDensity: VisualDensity.standard),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        home: FluentApp(
          debugShowCheckedModeBanner: false,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            visualDensity: VisualDensity.standard,
          ),
          theme: FluentThemeData(
            visualDensity: VisualDensity.standard,
          ),
          home: PlPage(params: argument),
        ),
        localizationsDelegates: const [
          FluentLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        builder: (context, child) {
          child = _keepScaleBuilder(context, child);
          return child;
        },
      ),
    ),
  ));
}

void _runConditionApp(
  String title,
  Map<String, dynamic> argument,
) {
  runApp(RefreshWrapper(
    builder: (context) => AnimatedFluentTheme(
      data: FluentThemeData(visualDensity: VisualDensity.standard),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        home: FluentApp(
          debugShowCheckedModeBanner: false,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            visualDensity: VisualDensity.standard,
          ),
          theme: FluentThemeData(
            visualDensity: VisualDensity.standard,
          ),
          home: ConditionPage(params: argument),
        ),
        localizationsDelegates: const [
          FluentLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        builder: (context, child) {
          child = _keepScaleBuilder(context, child);
          return child;
        },
      ),
    ),
  ));
}

void _runDrawApp(
  String title,
  Map<String, dynamic> argument,
) {
  runApp(RefreshWrapper(
    builder: (context) => AnimatedFluentTheme(
      data: FluentThemeData(visualDensity: VisualDensity.standard),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        home: FluentApp(
          debugShowCheckedModeBanner: false,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            visualDensity: VisualDensity.standard,
          ),
          theme: FluentThemeData(
            visualDensity: VisualDensity.standard,
          ),
          home: DrawTool(params: argument),
        ),
        localizationsDelegates: const [
          FluentLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        builder: (context, child) {
          child = _keepScaleBuilder(context, child);
          return child;
        },
      ),
    ),
  ));
}

void _runDrawSetting(
  String title,
  Map<String, dynamic> argument,
) {
  runApp(RefreshWrapper(
    builder: (context) => AnimatedFluentTheme(
      data: FluentThemeData(visualDensity: VisualDensity.standard),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        home: FluentApp(
          debugShowCheckedModeBanner: false,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            visualDensity: VisualDensity.standard,
          ),
          theme: FluentThemeData(
            visualDensity: VisualDensity.standard,
          ),
          home: LineSetting(params: argument),
        ),
        localizationsDelegates: const [
          FluentLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        builder: (context, child) {
          child = _keepScaleBuilder(context, child);
          return child;
        },
      ),
    ),
  ));
}

void _runColorPicker(
  String title,
  Map<String, dynamic> argument,
) {
  runApp(RefreshWrapper(
    builder: (context) => AnimatedFluentTheme(
      data: FluentThemeData(visualDensity: VisualDensity.standard),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        home: FluentApp(
          debugShowCheckedModeBanner: false,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            visualDensity: VisualDensity.standard,
          ),
          theme: FluentThemeData(
            visualDensity: VisualDensity.standard,
          ),
          home: ColorPickerPage(params: argument),
        ),
        localizationsDelegates: const [
          FluentLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        builder: (context, child) {
          child = _keepScaleBuilder(context, child);
          return child;
        },
      ),
    ),
  ));
}

void _runDrawOrderApp(
  String title,
  Map<String, dynamic> argument,
) {
  runApp(RefreshWrapper(
    builder: (context) => AnimatedFluentTheme(
      data: FluentThemeData(visualDensity: VisualDensity.standard),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        home: FluentApp(
          debugShowCheckedModeBanner: false,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            visualDensity: VisualDensity.standard,
          ),
          theme: FluentThemeData(
            visualDensity: VisualDensity.standard,
          ),
          home: DrawOrder(params: argument),
        ),
        localizationsDelegates: const [
          FluentLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        builder: (context, child) {
          child = _keepScaleBuilder(context, child);
          return child;
        },
      ),
    ),
  ));
}

void _runLocalNotification(
  String title,
  Map<String, dynamic> argument,
) {
  runApp(RefreshWrapper(
    builder: (context) => AnimatedFluentTheme(
      data: FluentThemeData(visualDensity: VisualDensity.standard),
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        darkTheme: FluentThemeData(
          brightness: Brightness.dark,
          visualDensity: VisualDensity.standard,
        ),
        theme: FluentThemeData(
          visualDensity: VisualDensity.standard,
        ),
        localizationsDelegates: const [
          FluentLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        builder: (context, child) {
          child = _keepScaleBuilder(context, child);
          return child;
        },
        home: LocalNotification(params: argument),
      ),
    ),
  ));
}

void _runSectorManage(
  String title,
  Map<String, dynamic> argument,
) {
  runApp(RefreshWrapper(
    builder: (context) => AnimatedFluentTheme(
      data: FluentThemeData(visualDensity: VisualDensity.standard),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        home: FluentApp(
          debugShowCheckedModeBanner: false,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            visualDensity: VisualDensity.standard,
          ),
          theme: FluentThemeData(
            visualDensity: VisualDensity.standard,
          ),
          home: SectorManage(params: argument),
        ),
        localizationsDelegates: const [
          FluentLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        builder: (context, child) {
          child = _keepScaleBuilder(context, child);
          return child;
        },
      ),
    ),
  ));
}

Widget _keepScaleBuilder(BuildContext context, Widget? child) {
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: const TextScaler.linear(1.0),
    ),
    child: child ?? Container(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetBuilder<ThemeController>(builder: (themeController) {
            return FluentApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                FluentLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('zh')],
              theme: themeController.theme,
              title: Common.appName,
              home: const Homepage(),
              navigatorKey: Get.key,
            );
          });
        });
  }
}
