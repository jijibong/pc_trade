import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox, DatePicker, TimePicker;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

import '../../config/common.dart';
import '../../main.dart';
import '../../model/k/draw_tool_line.dart';
import '../../util/log/log.dart';
import '../../util/widget/number_box.dart';
import '../../util/picker/date_picker.dart';
import '../../util/picker/time_picker.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import 'draw_icons.dart';

class LineSetting extends StatefulWidget {
  final Map<String, dynamic> params;

  const LineSetting({super.key, required this.params});

  @override
  State<LineSetting> createState() => _LineSettingState();
}

class _LineSettingState extends State<LineSetting> with MultiWindowListener {
  late AppTheme appTheme;
  Size dropDownSize = const Size(200, 15);
  int currentIndex = 0;
  double boxHeight = 34;
  DrawToolLine drawToolLine = DrawToolLine(colorValue: Colors.white.colorValue);
  static DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");

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
      if (call.method == kWindowEventNewColorPicker) {
        windowOnTop(windowId());
        var temp = jsonDecode(widget.params["hold"]);
        drawToolLine = DrawToolLine.fromJson(temp);
        if (mounted) setState(() {});
      } else if (call.method == kWindowEventSelectColor) {
        drawToolLine.colorValue = call.arguments["color"];
        if (mounted) setState(() {});
      }
    });

    var temp = jsonDecode(widget.params["hold"]);
    logger.i(temp);
    drawToolLine = DrawToolLine.fromJson(temp);
    if (mounted) setState(() {});
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
                  "画线属性",
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
          children: [
            Row(
              children: [
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          setState(() => currentIndex = 0);
                        },
                        child: Container(
                          color: currentIndex == 0 ? Colors.blue.darkest : appTheme.exchangeTextColor,
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "端点设置",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: currentIndex == 0 ? Colors.white : Colors.black),
                          ),
                        ))),
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          setState(() => currentIndex = 1);
                        },
                        child: Container(
                          color: currentIndex == 1 ? Colors.blue : appTheme.exchangeTextColor,
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "画线风格",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: currentIndex == 1 ? Colors.white : Colors.black),
                          ),
                        ))),
              ],
            ),
            Expanded(
                child: currentIndex == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("端点1"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("时间").marginOnly(right: 10),
                              DatePicker(
                                selected: format.parse(drawToolLine.firstPointX!),
                                fieldFlex: const [3, 3, 2], // Same order as fieldOrder
                                onChanged: (time) => setState(() => drawToolLine.firstPointX = format.format(time)),
                              ),
                              TimePicker(
                                selected: format.parse(drawToolLine.firstPointX!),
                                onChanged: (time) => setState(() => drawToolLine.firstPointX = format.format(time)),
                                hourFormat: HourFormat.HH,
                              ),
                              const Text("价格").marginSymmetric(horizontal: 10),
                              Expanded(
                                child: Container(
                                  height: boxHeight,
                                  margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                                  child: NumberBox(
                                    value: drawToolLine.firstPointY,
                                    onChanged: (v) => setState(() => drawToolLine.firstPointY = v),
                                    smallChange: 0.1,
                                    clearButton: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (drawToolLine.secondPointX != null && drawToolLine.secondPointY != null) const Text("端点2").marginOnly(top: 10),
                          if (drawToolLine.secondPointX != null && drawToolLine.secondPointY != null)
                            Row(
                              children: [
                                const Text("时间").marginOnly(right: 10),
                                DatePicker(
                                  selected: format.parse(drawToolLine.secondPointX!),
                                  fieldFlex: const [3, 3, 2], // Same order as fieldOrder
                                  onChanged: (time) => setState(() => drawToolLine.secondPointX = format.format(time)),
                                ),
                                TimePicker(
                                  selected: format.parse(drawToolLine.secondPointX!),
                                  onChanged: (time) => setState(() => drawToolLine.secondPointX = format.format(time)),
                                  hourFormat: HourFormat.HH,
                                ),
                                const Text("价格").marginSymmetric(horizontal: 10),
                                Expanded(
                                  child: Container(
                                    height: boxHeight,
                                    margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                                    child: NumberBox(
                                      value: drawToolLine.secondPointY,
                                      onChanged: (v) => setState(() => drawToolLine.secondPointY = v),
                                      smallChange: 0.1,
                                      clearButton: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (drawToolLine.thirdPointX != null && drawToolLine.thirdPointY != null) const Text("端点3").marginOnly(top: 10),
                          if (drawToolLine.thirdPointX != null && drawToolLine.thirdPointY != null)
                            Row(
                              children: [
                                const Text("时间").marginOnly(right: 10),
                                DatePicker(
                                  selected: format.parse(drawToolLine.thirdPointX!),
                                  fieldFlex: const [3, 3, 2], // Same order as fieldOrder
                                  onChanged: (time) => setState(() => drawToolLine.thirdPointX = format.format(time)),
                                ),
                                TimePicker(
                                  selected: format.parse(drawToolLine.thirdPointX!),
                                  onChanged: (time) => setState(() => drawToolLine.thirdPointX = format.format(time)),
                                  hourFormat: HourFormat.HH,
                                ),
                                const Text("价格").marginSymmetric(horizontal: 10),
                                Expanded(
                                  child: Container(
                                    height: boxHeight,
                                    margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                                    child: NumberBox(
                                      value: drawToolLine.thirdPointY,
                                      onChanged: (v) => setState(() => drawToolLine.thirdPointY = v),
                                      smallChange: 0.1,
                                      clearButton: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ).marginAll(20)
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                const Text("颜色"),
                                GestureDetector(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    color: Color(drawToolLine.colorValue ?? 4294967295),
                                    height: 30,
                                    width: 250,
                                  ),
                                  onTap: () async {
                                    await rustDeskWinManager.newColorPicker("colorPicker", preWindowId: windowId());
                                  },
                                )
                              ],
                            ),
                            Row(
                              children: [
                                const Text("粗细"),
                                SizedBox(
                                    width: 250,
                                    child: ComboBox(
                                      value: drawToolLine.widthType,
                                      items: [
                                        ComboBoxItem(
                                          value: 1,
                                          child: CustomPaint(
                                            size: dropDownSize,
                                            painter: HorizontalLine(),
                                          ),
                                        ),
                                        ComboBoxItem(
                                          value: 2,
                                          child: CustomPaint(
                                            size: dropDownSize,
                                            painter: HorizontalLine(width: 3),
                                          ),
                                        ),
                                        ComboBoxItem(
                                          value: 3,
                                          child: CustomPaint(
                                            size: dropDownSize,
                                            painter: HorizontalLine(width: 5),
                                          ),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        drawToolLine.widthType = v;
                                        setState(() {});
                                      },
                                    )).marginOnly(left: 10),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("线型"),
                                SizedBox(
                                    width: 250,
                                    child: ComboBox(
                                      value: drawToolLine.lineType,
                                      items: [
                                        ComboBoxItem(
                                          value: 1,
                                          child: CustomPaint(
                                            size: dropDownSize,
                                            painter: HorizontalLine(),
                                          ),
                                        ),
                                        ComboBoxItem(
                                          value: 2,
                                          child: CustomPaint(
                                            size: dropDownSize,
                                            painter: DashedLinePainter(),
                                          ),
                                        ),
                                        ComboBoxItem(
                                          value: 3,
                                          child: CustomPaint(
                                            size: dropDownSize,
                                            painter: DashedLinePainter(list: [1, 4]),
                                          ),
                                        ),
                                        ComboBoxItem(
                                          value: 4,
                                          child: CustomPaint(
                                            size: dropDownSize,
                                            painter: DashedLinePainter(list: [4, 1, 1]),
                                          ),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        drawToolLine.lineType = v;
                                        setState(() {});
                                      },
                                    )).marginOnly(left: 10),
                              ],
                            ),
                          ],
                          // ),
                        ),
                      )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                      shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                  child: const Text(
                    "确认",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () async {
                    String json = jsonEncode(drawToolLine.toJson());
                    await DesktopMultiWindow.invokeMethod(kMainWindowId, setLine, {"line": json});
                    Future.delayed(Duration.zero, () async {
                      await WindowController.fromWindowId(kWindowId!).hide();
                    });
                  },
                ),
                Button(
                  style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                  child: const Text(
                    "取消",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Future.delayed(Duration.zero, () async {
                      await WindowController.fromWindowId(kWindowId!).hide();
                    });
                  },
                ),
              ],
            ).marginSymmetric(vertical: 15),
          ],
        ).paddingAll(10));
  }
}
