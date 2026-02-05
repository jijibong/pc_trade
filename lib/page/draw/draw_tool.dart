import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide ComboBox, ComboBoxItem;
import 'package:get/get.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';
import '../../model/draw_tools/DrawTool.dart';
import '../../util/widget/combo_box.dart';

import '../../config/common.dart';
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
  final ThemeController themeController = Get.find<ThemeController>();
  List<int> typeList = [];
  Size dropDownSize = const Size(50, 15);

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
      } else if (call.method == toggleTheme) {
        if (call.arguments == themeController.isDarkMode.value) return;
        themeController.toggleTheme();
        if (mounted) setState(() {});
      }
    });
    await DesktopMultiWindow.invokeMethod(kMainWindowId, drawLineWindowId, {"id": kWindowId});
  }

  notifyOrder() async {
    await DesktopMultiWindow.invokeMethod(kMainWindowId, kDrawEvent, typeList);
  }

  @override
  void onWindowClose() async {
    notMainWindowClose(WindowController windowController) async {
      await windowController.hide();
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
    return NavigationView(
      appBar: NavigationAppBar(
          automaticallyImplyLeading: false,
          height: 30,
          backgroundColor: themeController.isDarkMode.value ? Common.dialogDarkBgColor : Common.dialogLightBgColor,
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
            child: Container(
              color: Colors.transparent,
            ),
          ),
          actions: IconButton(
              icon: Icon(
                FluentIcons.chrome_close,
                color: Common.commandTextColor,
              ),
              onPressed: () {
                Future.delayed(Duration.zero, () async {
                  await WindowController.fromWindowId(kWindowId!).hide();
                  await rustDeskWinManager.closeWindowByType(WindowType.Color);
                  // await DesktopMultiWindow.invokeMethod(
                  //     kMainWindowId, kDrawEvent, jsonEncode({"pathType": 0, "colorValue": 0, "widthType": 0, "lineType": 0}));
                });
              })),
      content: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        color: themeController.isDarkMode.value ? Common.dialogDarkBgColor : Common.dialogLightBgColor,
        child: Column(
          children: [
            Text(
              "画线工具箱",
              style: TextStyle(fontSize: 18, color: themeController.theme.acrylicBackgroundColor, fontWeight: FontWeight.bold),
            ),
            // Row(
            //   children: [
            //     titleWidget("颜色"),
            //     GestureDetector(
            //       child: Container(
            //         height: 22,
            //         width: 22,
            //         decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(4)),
            //       ),
            //       onTap: () async {
            //         // await rustDeskWinManager.newColorPicker("colorPicker");
            //         await rustDeskWinManager.newColorPicker("colorPicker", preWindowId: windowId());
            //       },
            //     ),
            //     const Spacer(),
            //     titleWidget("线型"),
            //     SizedBox(
            //       width: 72,
            //       height: 26,
            //       child: ComboBox(
            //         value: lineType,
            //         popupColor: themeController.isDarkMode.value ? Common.comboDarkColor : Common.lightBgColor,
            //         items: [
            //           ComboBoxItem(
            //             value: 1,
            //             child: CustomPaint(
            //               size: dropDownSize,
            //               painter: HorizontalLine(color: themeController.theme.acrylicBackgroundColor),
            //             ),
            //           ),
            //           ComboBoxItem(
            //             value: 2,
            //             child: CustomPaint(
            //               size: dropDownSize,
            //               painter: DashedLinePainter(color: themeController.theme.acrylicBackgroundColor),
            //             ),
            //           ),
            //           ComboBoxItem(
            //             value: 3,
            //             child: CustomPaint(
            //               size: dropDownSize,
            //               painter: DashedLinePainter(list: [1, 4], color: themeController.theme.acrylicBackgroundColor),
            //             ),
            //           ),
            //           ComboBoxItem(
            //             value: 4,
            //             child: CustomPaint(
            //               size: dropDownSize,
            //               painter: DashedLinePainter(list: [4, 1, 1], color: themeController.theme.acrylicBackgroundColor),
            //             ),
            //           ),
            //         ],
            //         onChanged: (v) {
            //           lineType = v ?? 1;
            //           setState(() {});
            //         },
            //       ),
            //     ),
            //     const Spacer(),
            //     titleWidget("粗细"),
            //     SizedBox(
            //         width: 72,
            //         height: 26,
            //         child: ComboBox(
            //           value: fineness,
            //           popupColor: themeController.isDarkMode.value ? Common.comboDarkColor : Common.lightBgColor,
            //           items: [
            //             ComboBoxItem(
            //               value: 1,
            //               child: CustomPaint(
            //                 size: dropDownSize,
            //                 painter: HorizontalLine(color: themeController.theme.acrylicBackgroundColor),
            //               ),
            //             ),
            //             ComboBoxItem(
            //               value: 2,
            //               child: CustomPaint(
            //                 size: dropDownSize,
            //                 painter: HorizontalLine(width: 3, color: themeController.theme.acrylicBackgroundColor),
            //               ),
            //             ),
            //             ComboBoxItem(
            //               value: 3,
            //               child: CustomPaint(
            //                 size: dropDownSize,
            //                 painter: HorizontalLine(width: 5, color: themeController.theme.acrylicBackgroundColor),
            //               ),
            //             ),
            //           ],
            //           onChanged: (v) {
            //             fineness = v ?? 1;
            //             // if (type != 0) notifyOrder();
            //             setState(() {});
            //           },
            //         ))
            //   ],
            // ).marginSymmetric(vertical: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: themeController.isDarkMode.value ? Common.comboDarkColor : Common.lightBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: themeController.isDarkMode.value ? Common.checkBoxBorderDarkColor : Colors.transparent)),
              padding: const EdgeInsets.symmetric(vertical: 20),
              margin: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Text(
                    "趋势",
                    style: TextStyle(color: Common.commandTextColor, fontSize: 12),
                  ).marginOnly(bottom: 20),
                  Row(
                    children: Common().drawToolTypes.sublist(0, 4).map((e) => Expanded(child: item(e))).toList(),
                  ).marginOnly(bottom: 20),
                  Row(
                    children: [...Common().drawToolTypes.sublist(4, 7).map((e) => Expanded(child: item(e))), const Spacer()],
                  ),
                  // Wrap(children: [
                  //   item(1, "趋势线", StraightLine()),
                  //   item(2, "射线", RayLine()),
                  //   item(3, "水平线", HorizontalLine()),
                  //   item(4, "竖线", VerticalLine()),
                  //   item(5, "线段", LineSegment()),
                  //   item(6, "通道线", ParallelLines()),
                  //   item(7, "平行线", HorizontalParallelLines()),
                  // ]),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: themeController.isDarkMode.value ? Common.comboDarkColor : Common.lightBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: themeController.isDarkMode.value ? Common.checkBoxBorderDarkColor : Colors.transparent)),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    "时空",
                    style: TextStyle(color: Common.commandTextColor, fontSize: 12),
                  ).marginOnly(bottom: 20),
                  Row(
                    children: Common().drawToolTypes.sublist(7, 11).map((e) => Expanded(child: item(e))).toList(),
                  ).marginOnly(bottom: 20),
                  Row(
                    children: Common().drawToolTypes.sublist(11, 15).map((e) => Expanded(child: item(e))).toList(),
                  ).marginOnly(bottom: 20),
                  Row(
                    children: [...Common().drawToolTypes.sublist(15, 18).map((e) => Expanded(child: item(e))), const Spacer()],
                  ),
                  // Wrap(children: [
                  //   item(8, "矩形", SquarePainter()),
                  //   item(9, "三角线", TrianglePainter()),
                  //   item(10, "圆弧", UShapePainter()),
                  //   item(11, "甘氏线", GansLinePainter()),
                  //   item(12, "阻速线", ResistanceLinePainter()),
                  //   item(13, "对称角度线", SymmetricalAngleLinePainter()),
                  //   item(14, "圆", RoundPainter()),
                  //   item(15, "椭圆", EllipsePainter()),
                  //   item(16, "上45度", DegreesUpPainter()),
                  //   item(17, "下45度", DegreesDownPainter()),
                  //   item(18, "多圆弧", MultipleArcsPainter()),
                  // ]),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8, horizontal: 30)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  onPressed: () async {
                    notifyOrder();
                    await WindowController.fromWindowId(kWindowId!).hide();
                    await rustDeskWinManager.closeWindowByType(WindowType.Color);
                  },
                  child: Text(
                    '保存',
                    style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget titleWidget(String text) {
    return Text(
      text,
      style: TextStyle(color: Common.commandTextColor, fontSize: 12),
    ).marginOnly(right: 12);
  }

  Widget item(DrawToolObj drawToolObj) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
            style: CheckboxThemeData(
              uncheckedDecoration: WidgetStatePropertyAll(
                BoxDecoration(
                  color: themeController.isDarkMode.value ? Common.checkedBoxDarkBgColor : Common.dialogLightBgColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: themeController.isDarkMode.value ? Common.checkBoxBorderDarkColor : Common.checkBoxBorderLightColor),
                ),
              ),
            ),
            checked: typeList.contains(drawToolObj.index),
            onChanged: (e) {
              if (typeList.contains(drawToolObj.index)) {
                typeList.remove(drawToolObj.index);
              } else {
                typeList.add(drawToolObj.index);
              }
              if (mounted) setState(() {});
            }).marginOnly(right: 12),
        Image.asset(drawToolObj.iconPath, width: 20),
      ],
    );
  }
}
