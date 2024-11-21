import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:trade/page/home/home.dart';
import 'package:trade/page/secondary/condition.dart';
import 'package:trade/page/secondary/pl_page.dart';
import 'package:trade/page/trade/trade.dart';
import 'package:trade/util/multi_windows_manager/common.dart';
import 'package:trade/util/multi_windows_manager/consts.dart';
import 'package:trade/util/multi_windows_manager/multi_window_manager.dart';
import 'package:trade/util/multi_windows_manager/platform_model.dart';
import 'package:trade/util/multi_windows_manager/refresh_wrapper.dart';
import 'package:trade/util/multi_windows_manager/state_model.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'config/common.dart';

/// Checks if the current environment is a desktop environment.
int? kWindowId;
WindowType? kWindowType;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && [TargetPlatform.windows].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

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
        case WindowType.RemoteDesktop:
          desktopType = DesktopType.remote;
          runMultiWindow(
            argument,
            kAppTypeDesktopRemote,
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
      // gFFI.serverModel.startService();
      bind.pluginSyncUi(syncTo: kAppTypeMain);
      bind.pluginListReload();

      runApp(const MyApp());

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

      rustDeskWinManager.registerActiveWindow(kWindowMainId);
    }
  }
}

Future<void> initEnv(String appType) async {
  await platformFFI.init(appType);
  await initGlobalFFI();
}

void runMultiWindow(
  Map<String, dynamic> argument,
  String appType,
) async {
  await initEnv(appType);
  final title = getWindowName();
  WindowController.fromWindowId(kWindowId!).setPreventClose(true);
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
        ..setFrame(const Offset(0, 0) & const Size(1240, 512))
        ..setTitle("交易")
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
        ..setFrame(const Offset(0, 0) & const Size(700, 380))
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
        ..setFrame(const Offset(0, 0) & const Size(680, 580))
        ..setTitle("条件单修改")
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
) {
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
                  themeMode: _appTheme.mode,
                  theme: FluentThemeData(
                    visualDensity: VisualDensity.standard,
                  ),
                  home: MultiProvider(
                      providers: [ChangeNotifierProvider.value(value: gFFI.ffiModel), ChangeNotifierProvider.value(value: _appTheme)],
                      child: Trade(params: argument)),
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
              ));
        }),
  ));
}

void _runPLApp(
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
          themeMode: _appTheme.mode,
          theme: FluentThemeData(
            visualDensity: VisualDensity.standard,
          ),
          home: MultiProvider(
              providers: [ChangeNotifierProvider.value(value: gFFI.ffiModel), ChangeNotifierProvider.value(value: _appTheme)], child: PlPage(params: argument)),
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
          themeMode: _appTheme.mode,
          theme: FluentThemeData(
            visualDensity: VisualDensity.standard,
          ),
          home: MultiProvider(
              providers: [ChangeNotifierProvider.value(value: gFFI.ffiModel), ChangeNotifierProvider.value(value: _appTheme)],
              child: ConditionPage(params: argument)),
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

final _appTheme = AppTheme();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: gFFI.ffiModel),
              ChangeNotifierProvider.value(
                value: _appTheme,
                builder: (context, child) {
                  final appTheme = context.watch<AppTheme>();
                  return AnimatedFluentTheme(
                    data: FluentThemeData(visualDensity: VisualDensity.standard),
                    child: GetMaterialApp(
                      debugShowCheckedModeBanner: false,
                      localizationsDelegates: const [
                        FluentLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      supportedLocales: [appTheme.locale],
                      builder: (context, child) {
                        return AnimatedFluentTheme(
                          data: FluentThemeData(),
                          child: child!,
                        );
                      },
                      // navigatorObservers: [BotToastNavigatorObserver()],
                      title: Common.appName,
                      locale: appTheme.locale,
                      home: FluentApp(
                        debugShowCheckedModeBanner: false,
                        themeMode: appTheme.mode,
                        color: appTheme.color,
                        darkTheme: FluentThemeData(
                          brightness: Brightness.dark,
                          visualDensity: VisualDensity.standard,
                        ),
                        theme: FluentThemeData(
                          visualDensity: VisualDensity.standard,
                        ),
                        home: const Homepage(),
                      ),
                    ),
                  );
                },
              )
            ],
          );
        });
  }
}
