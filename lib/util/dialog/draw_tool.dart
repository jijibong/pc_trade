import 'package:fluent_ui/fluent_ui.dart' hide ComboBox, ComboBoxItem;
import 'package:get/get.dart';
import '../../page/draw/draw_icons.dart';
import '../../util/widget/combo_box.dart';

import '../../config/common.dart';
import '../multi_windows_manager/multi_window_manager.dart';
import '../theme/theme.dart';

class DrawToolDialog {
  final ThemeController themeController = Get.find<ThemeController>();
  Color selectedColor = Colors.white;
  int type = 0;
  int fineness = 1;
  int lineType = 1;
  double defaultWidth = 20.0;
  // Size defaultSize = const Size(15, 15);
  Size dropDownSize = const Size(30, 15);

  Widget drawTool(Function() fun) {
    selectedColor = themeController.theme.acrylicBackgroundColor;
    return ContentDialog(
        style: themeController.theme.dialogTheme,
        constraints: const BoxConstraints(
          maxWidth: 360,
          maxHeight: 495,
        ),
        content: StatefulBuilder(builder: (_, setState) {
          return Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Image.asset(
                      "assets/images/icon_close@3x.png",
                      width: 22,
                    ))
              ],
            ),
            const Text(
              "画线工具箱",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                titleWidget("颜色"),
                GestureDetector(
                  child: Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(4)),
                  ),
                  onTap: () async {
                    await rustDeskWinManager.newColorPicker("colorPicker");
                    // await rustDeskWinManager.newColorPicker("colorPicker", preWindowId: windowId());
                  },
                ),
                const Spacer(),
                titleWidget("线型"),
                SizedBox(
                  width: 72,
                  height: 26,
                  child: ComboBox(
                    value: lineType,
                    popupColor: themeController.isDarkMode.value ? Common.comboDarkColor : Common.lightBgColor,
                    items: [
                      ComboBoxItem(
                        value: 1,
                        child: CustomPaint(
                          size: dropDownSize,
                          painter: HorizontalLine(color: themeController.theme.acrylicBackgroundColor),
                        ),
                      ),
                      ComboBoxItem(
                        value: 2,
                        child: CustomPaint(
                          size: dropDownSize,
                          painter: DashedLinePainter(color: themeController.theme.acrylicBackgroundColor),
                        ),
                      ),
                      ComboBoxItem(
                        value: 3,
                        child: CustomPaint(
                          size: dropDownSize,
                          painter: DashedLinePainter(list: [1, 4], color: themeController.theme.acrylicBackgroundColor),
                        ),
                      ),
                      ComboBoxItem(
                        value: 4,
                        child: CustomPaint(
                          size: dropDownSize,
                          painter: DashedLinePainter(list: [4, 1, 1], color: themeController.theme.acrylicBackgroundColor),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      lineType = v ?? 1;
                      setState(() {});
                    },
                  ),
                ),
                const Spacer(),
                titleWidget("粗细"),
                SizedBox(
                    width: 72,
                    height: 26,
                    child: ComboBox(
                      value: fineness,
                      popupColor: themeController.isDarkMode.value ? Common.comboDarkColor : Common.lightBgColor,
                      items: [
                        ComboBoxItem(
                          value: 1,
                          child: CustomPaint(
                            size: dropDownSize,
                            painter: HorizontalLine(color: themeController.theme.acrylicBackgroundColor),
                          ),
                        ),
                        ComboBoxItem(
                          value: 2,
                          child: CustomPaint(
                            size: dropDownSize,
                            painter: HorizontalLine(width: 3, color: themeController.theme.acrylicBackgroundColor),
                          ),
                        ),
                        ComboBoxItem(
                          value: 3,
                          child: CustomPaint(
                            size: dropDownSize,
                            painter: HorizontalLine(width: 5, color: themeController.theme.acrylicBackgroundColor),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        fineness = v ?? 1;
                        // if (type != 0) notifyOrder();
                        setState(() {});
                      },
                    ))
              ],
            ).marginSymmetric(vertical: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: themeController.isDarkMode.value ? Common.comboDarkColor : Common.lightBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: themeController.isDarkMode.value ? Common.checkBoxBorderDarkColor : Colors.transparent)),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    "趋势",
                    style: TextStyle(color: Common.commandTextColor, fontSize: 12),
                  ).marginOnly(bottom: 20),
                  Row(
                    children: [
                      Expanded(child: item(1, "趋势线", "assets/images/hx_icon_1@3x.png")),
                      Expanded(child: item(2, "射线", "assets/images/hx_icon_2@3x.png")),
                      Expanded(child: item(3, "水平线", "assets/images/hx_icon_3@3x.png")),
                      Expanded(child: item(4, "竖线", "assets/images/hx_icon_4@3x.png")),
                    ],
                  ).marginOnly(bottom: 20),
                  Row(
                    children: [
                      Expanded(child: item(5, "线段", "assets/images/hx_icon_5@3x.png")),
                      Expanded(child: item(6, "通道线", "assets/images/hx_icon_6@3x.png")),
                      Expanded(child: item(7, "平行线", "assets/images/hx_icon_7@3x.png")),
                      const Spacer()
                    ],
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
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Text(
                    "时空",
                    style: TextStyle(color: Common.commandTextColor, fontSize: 12),
                  ).marginOnly(bottom: 20),
                  Row(
                    children: [
                      Expanded(child: item(8, "矩形", "assets/images/hx_icon_8@3x.png")),
                      Expanded(child: item(9, "三角线", "assets/images/hx_icon_9@3x.png")),
                      Expanded(child: item(10, "圆弧", "assets/images/hx_icon_10@3x.png")),
                      Expanded(child: item(11, "甘氏线", "assets/images/hx_icon_11@3x.png")),
                    ],
                  ).marginOnly(bottom: 20),
                  Row(
                    children: [
                      Expanded(child: item(12, "阻速线", "assets/images/hx_icon_12@3x.png")),
                      Expanded(child: item(13, "对称角度线", "assets/images/hx_icon_13@3x.png")),
                      Expanded(child: item(14, "圆", "assets/images/hx_icon_14@3x.png")),
                      Expanded(child: item(15, "椭圆", "assets/images/hx_icon_15@3x.png")),
                    ],
                  ).marginOnly(bottom: 20),
                  Row(
                    children: [
                      Expanded(child: item(16, "上45度", "assets/images/hx_icon_16@3x.png")),
                      Expanded(child: item(17, "下45度", "assets/images/hx_icon_17@3x.png")),
                      Expanded(child: item(18, "多圆弧", "assets/images/hx_icon_18@3x.png")),
                      const Spacer()
                    ],
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
            )
          ]);
        }));
  }

  Widget titleWidget(String text) {
    return Text(
      text,
      style: TextStyle(color: Common.commandTextColor, fontSize: 12),
    ).marginOnly(right: 12);
  }

  Widget item(int index, String message, String address) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
            checked: type == index,
            onChanged: (e) {
              type = index;
              // notifyOrder();
              // if (mounted) setState(() {});
            }).marginOnly(right: 12),
        Image.asset(address, width: defaultWidth),
        // RepaintBoundary(
        //     child: CustomPaint(
        //   size: defaultSize,
        //   painter: painter,
        // )),
      ],
    );
  }
}
