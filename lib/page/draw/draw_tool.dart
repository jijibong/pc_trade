import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart' hide Condition;
import 'package:provider/provider.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../main.dart';
import '../../model/condition/condition.dart';
import '../../model/quote/order_type.dart';
import '../../model/quote/position_effect_type.dart';
import '../../model/quote/side_type.dart';
import '../../model/user/user.dart';
import '../../server/condition/condition.dart';
import '../../util/http/http.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
import '../../util/widget/number_box.dart';

class DrawTool extends StatefulWidget {
  final Map<String, dynamic> params;

  const DrawTool({super.key, required this.params});

  @override
  State<DrawTool> createState() => _DrawToolState();
}

class _DrawToolState extends State<DrawTool> with MultiWindowListener {
  late AppTheme appTheme;
  Color selectedColor = Colors.white;
  ScrollController scrollController = ScrollController();

  int windowId() {
    return widget.params["windowId"];
  }

  void startDragging(bool isMainWindow) {
    if (isMainWindow) {
      windowManager.startDragging();
    } else {
      WindowController.fromWindowId(kWindowId!).startDragging();
    }
  }

  void setMovable(bool isMainWindow, bool movable) {
    if (isMainWindow) {
      windowManager.setMovable(movable);
    } else {
      WindowController.fromWindowId(kWindowId!).setMovable(movable);
    }
  }

  initData() async {
    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      if (call.method == kWindowEventNewDraw) {
        windowOnTop(windowId());
      }
    });
  }

  @override
  void onWindowClose() async {
    notMainWindowClose(WindowController windowController) async {
      await windowController.hide();
      await rustDeskWinManager.call(WindowType.Main, kWindowEventHide, {"id": kWindowId!});
    }

    final controller = WindowController.fromWindowId(kWindowId!);
    await notMainWindowClose(controller);
    super.onWindowClose();
  }

  @override
  void initState() {
    super.initState();
    DesktopMultiWindow.addListener(this);
    initData();
  }

  @override
  void dispose() {
    DesktopMultiWindow.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appTheme = context.watch<AppTheme>();
    return NavigationView(
      appBar: NavigationAppBar(
          automaticallyImplyLeading: false,
          height: 30,
          backgroundColor: appTheme.commandBarColor,
          title: GestureDetector(
            onPanStart: (_) => startDragging(false),
            onPanCancel: () {
              if (isMacOS) {
                setMovable(false, false);
              }
            },
            onPanEnd: (_) {
              if (isMacOS) {
                setMovable(false, false);
              }
            },
            child: Row(children: [
              Image.asset('assets/images/jmaster.ico', width: 16, height: 16),
              Expanded(
                  child: const Text(
                "画线工具箱",
                style: TextStyle(fontSize: 13, color: Colors.white),
              ).marginOnly(left: 2))
            ]).marginOnly(
              left: 2,
              right: 2,
            ),
          ),
          actions: IconButton(
              icon: const Icon(
                FluentIcons.chrome_close,
                color: Colors.white,
              ),
              onPressed: () {
                // WindowController.fromWindowId(windowId()).hide();
                Future.delayed(Duration.zero, () async {
                  await WindowController.fromWindowId(kWindowId!).close();
                });
              })),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text("趋势"),
                const SizedBox(
                  height: 5,
                ),
                Wrap(children: [
                  GestureDetector(
                    child: Icon(FluentIcons.line),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.line),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.line),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.line),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.line),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.line),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.line),
                    onTap: () {},
                  ),
                ]),
                Padding(padding: EdgeInsets.symmetric(vertical: 5), child: Text("时空")),
                Wrap(children: [
                  GestureDetector(
                    child: Icon(FluentIcons.square_shape),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.square_shape),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.square_shape),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.square_shape),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.square_shape),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.square_shape),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.square_shape),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.square_shape),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.square_shape),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(FluentIcons.square_shape),
                    onTap: () {},
                  ),
                ])
              ],
            ),
          )),
          const Divider(),
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("颜色"),
                    Container(
                      margin: const EdgeInsets.all(5),
                      color: appTheme.drawColor,
                      width: 88,
                      height: 20,
                    )
                  ],
                ),
                Row(
                  children: [
                    const Text("粗细"),
                    Container(
                      margin: const EdgeInsets.all(5),
                      color: appTheme.drawColor,
                      width: 88,
                      height: 20,
                      // child: ComboBox<String>(
                      //   value: selectedColor,
                      //   items: colors.entries.map((e) {
                      //     return ComboBoxItem(
                      //       value: e.key,
                      //       child: Text(e.key),
                      //     );
                      //   }).toList(),
                      //   onChanged: (color) => setState(() => selectedColor = color),
                      // ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("线型"),
                    Container(
                      margin: const EdgeInsets.all(5),
                      color: appTheme.drawColor,
                      width: 88,
                      height: 20,
                    )
                    // ComboBox<String>(
                    //   value: selectedColor,
                    //   items: colors.entries.map((e) {
                    //     return ComboBoxItem(
                    //       child: Text(e.key),
                    //       value: e.key,
                    //     );
                    //   }).toList(),
                    //   onChanged: disabled ? null : (color) => setState(() => selectedColor = color),
                    // ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
