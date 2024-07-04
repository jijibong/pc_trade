import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:trade/page/quote/quote.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;

import 'config/common.dart';
import 'package:multi_split_view/multi_split_view.dart';

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
      await windowManager.setMinimumSize(const Size(1200, 720));
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
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
              return FluentApp(
                title: Common.appName,
                themeMode: appTheme.mode,
                debugShowCheckedModeBanner: false,
                color: appTheme.color,
                darkTheme: FluentThemeData(
                  brightness: Brightness.dark,
                  accentColor: appTheme.color,
                  visualDensity: VisualDensity.standard,
                ),
                theme: FluentThemeData(
                  accentColor: appTheme.color,
                  visualDensity: VisualDensity.standard,
                ),
                locale: appTheme.locale,
                home: const Homepage(),
              );
            },
          );
        });
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WindowListener {
  final MultiSplitViewController _controller = MultiSplitViewController();

  void _rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    windowManager.addListener(this);
    _controller.areas = [
      Area(data: const Quote()),
    ];
    _controller.addListener(_rebuild);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return NavigationView(
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: () {
          if (kIsWeb) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/jmaster.ico",
                    width: 8.sp,
                  ),
                  Text(
                    "  ${Common.appName}",
                    style: TextStyle(fontSize: 5.sp),
                  )
                ],
              ),
            );
          }
          return DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/jmaster.ico",
                    width: 8.sp,
                  ),
                  Text(
                    "  ${Common.appName}",
                    style: TextStyle(fontSize: 5.sp),
                  )
                ],
              ),
            ),
          );
        }(),
        actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: ToggleSwitch(
                content: const Text('台灯'),
                checked: FluentTheme.of(context).brightness.isLight,
                onChanged: (v) {
                  if (v) {
                    appTheme.mode = ThemeMode.light;
                  } else {
                    appTheme.mode = ThemeMode.dark;
                  }
                },
              ),
            ),
          ),
          if (!kIsWeb) const WindowButtons(),
        ]),
      ),
      content: Column(
        children: [
          Container(
              color: appTheme.commandBarColor,
              child: Row(
                children: [
                  Expanded(
                      child: CommandBar(
                    overflowBehavior: CommandBarOverflowBehavior.wrap,
                    compactBreakpointWidth: 0.8.sw,
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.back),
                        label: const Text('返回'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.home),
                        label: const Text('首页'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.refresh),
                        label: const Text('刷新'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.scale_volume),
                        label: const Text('放大'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.scale_up),
                        label: const Text('缩小'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.edit_create),
                        label: const Text('画图工具'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.tablet_mode),
                        label: const Text('画线下单'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.line_chart),
                        label: const Text('分时图'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('日'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('周'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('月'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('年'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('X'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('1'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('3'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('5'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('10'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('15'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('30'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('60'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('120'),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: const Text('Y'),
                        onPressed: () {},
                      ),
                      // const CommandBarSeparator(),
                    ],
                  )),
                  // Image.asset("assets/images/quote_st.png"),
                  // Image.asset("assets/images/user_st.png")
                  const Icon(FluentIcons.join_online_meeting),
                  SizedBox(width: 2.sp),
                  const Icon(FluentIcons.plug_connected), //FluentIcons.plug_disconnected
                  SizedBox(width: 2.sp),
                ],
              )),
          Expanded(
            child: MultiSplitViewTheme(
                data: MultiSplitViewThemeData(dividerPainter: DividerPainters.grooved2()),
                child: MultiSplitView(
                    onDividerDragUpdate: _onDividerDragUpdate,
                    onDividerTap: _onDividerTap,
                    controller: _controller,
                    pushDividers: true,
                    builder: (BuildContext context, Area area) => area.data)),
          )
        ],
      ),
    );
  }

  _onDividerDragUpdate(int index) {
    if (kDebugMode) {
      // print('drag update: $index');
    }
  }

  _onDividerTap(int dividerIndex) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   duration: const Duration(seconds: 1),
    //   content: Text("Tap on divider: $dividerIndex"),
    // ));
  }

  _onDividerDoubleTap(int dividerIndex) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   duration: const Duration(seconds: 1),
    //   content: Text("Double tap on divider: $dividerIndex"),
    // ));
  }

  void _removeColor(int index) {
    _controller.removeAreaAt(index);
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('提示'),
            content: const Text('确认要退出${Common.appName}吗？'),
            actions: [
              FilledButton(
                child: const Text('确定'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.destroy();
                },
              ),
              Button(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: FluentTheme.of(context).brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
