import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:flutter/material.dart' show Material;
import 'package:get/get.dart' hide Condition;
import 'package:provider/provider.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

import '../../main.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import 'draw_icons.dart';

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
  List colors = [];
  int type = 0;
  Size defaultSize = const Size(15, 15);

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
      // await rustDeskWinManager.call(WindowType.Main, kWindowEventHide, {"id": kWindowId!});
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
                Future.delayed(Duration.zero, () async {
                  await WindowController.fromWindowId(kWindowId!).hide();
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
                  item(1, "趋势线", StraightLine()),
                  item(2, "射线", RayLine()),
                  item(3, "水平线", HorizontalLine()),
                  item(4, "竖线", VerticalLine()),
                  item(5, "线段", LineSegment()),
                  item(6, "通道线", ParallelLines()),
                  item(7, "平行线", HorizontalParallelLines()),
                ]),
                const Padding(padding: EdgeInsets.only(top: 15, bottom: 5), child: Text("时空")),
                Wrap(children: [
                  item(8, "矩线", SquarePainter()),
                  item(9, "三角线", TrianglePainter()),
                  item(10, "圆弧", UShapePainter()),
                  item(11, "甘氏线", GansLinePainter()),
                  item(12, "阻速线", ResistanceLinePainter()),
                  item(13, "对称角度线", SymmetricalAngleLinePainter()),
                  item(14, "圆", RoundPainter()),
                ])
              ],
            ),
          )),
          const Divider(),
          // Expanded(
          //     child: Container(
          //   padding: const EdgeInsets.all(8),
          //   child: Column(
          //     children: [
          //       Row(
          //         children: [
          //           const Text("颜色"),
          //           Container(
          //             margin: const EdgeInsets.all(5),
          //             color: appTheme.drawColor,
          //             width: 88,
          //             height: 20,
          //           )
          //         ],
          //       ),
          //       Row(
          //         children: [
          //           const Text("粗细"),
          //           Container(
          //             margin: const EdgeInsets.all(5),
          //             color: appTheme.drawColor,
          //             width: 88,
          //             height: 20,
          //             // child: ComboBox(
          //             //   value: selectedColor,
          //             //   items: colors.entries.map((e) {
          //             //     return ComboBoxItem(
          //             //       value: e.key,
          //             //       child: Text(e.key),
          //             //     );
          //             //   }).toList(),
          //             //   onChanged: (color) => setState(() => selectedColor = color),
          //             // ),
          //           ),
          //         ],
          //       ),
          //       Row(
          //         children: [
          //           const Text("线型"),
          //           Container(
          //             margin: const EdgeInsets.all(5),
          //             color: appTheme.drawColor,
          //             width: 88,
          //             height: 20,
          //           )
          //           // ComboBox<String>(
          //           //   value: selectedColor,
          //           //   items: colors.entries.map((e) {
          //           //     return ComboBoxItem(
          //           //       child: Text(e.key),
          //           //       value: e.key,
          //           //     );
          //           //   }).toList(),
          //           //   onChanged: disabled ? null : (color) => setState(() => selectedColor = color),
          //           // ),
          //         ],
          //       ),
          //     ],
          //   ),
          // )),
        ],
      ),
    );
  }

  Widget item(int index, String message, CustomPainter painter) {
    return GestureDetector(
      child: Tooltip(
        message: message,
        style: const TooltipThemeData(
          preferBelow: true,
          textStyle: TextStyle(decoration: TextDecoration.none, color: Colors.white),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
          ),
          padding: const EdgeInsets.all(3),
          child: RepaintBoundary(
              child: CustomPaint(
            size: defaultSize,
            painter: painter,
          )),
        ),
      ),
      onTap: () {
        type = index;
        if (mounted) setState(() {});
      },
    );
  }
}
