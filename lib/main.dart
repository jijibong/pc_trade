import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:trade/page/home/home.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'config/common.dart';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && [TargetPlatform.windows].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await flutter_acrylic.Window.hideWindowControls();
    }
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      windowManager
        ..setSize(const Size(1450, 850))
        ..setMinimumSize(const Size(1450, 850))
        ..setAlignment(Alignment.center)
        ..show()
        ..setPreventClose(true)
        ..setSkipTaskbar(false);
    });
  }
  runApp(const MyApp());
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
          return ChangeNotifierProvider.value(
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
                  builder: BotToastInit(),
                  navigatorObservers: [BotToastNavigatorObserver()],
                  title: Common.appName,
                  locale: appTheme.locale,
                  home: FluentApp(
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
          );
        });
  }
}
