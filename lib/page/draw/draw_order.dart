import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox, ComboBox, ComboBoxItem;
import 'package:get/get.dart' hide Condition;
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

import '../../config/common.dart';
import '../../main.dart';
import '../../model/quote/contract.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/widget/number_box.dart';
import '../../util/widget/combo_box.dart';

///画线下单
class DrawOrder extends StatefulWidget {
  final Map<String, dynamic> params;

  const DrawOrder({super.key, required this.params});

  @override
  State<DrawOrder> createState() => _DrawOrderState();
}

class _DrawOrderState extends State<DrawOrder> with MultiWindowListener {
  final ThemeController themeController = Get.find<ThemeController>();
  Color selectedColor = Colors.white;
  ScrollController scrollController = ScrollController();
  int num = 1;
  int type = 1;
  Color color = Colors.white;
  Color selectBuy = Colors.red;
  Color selectSale = Colors.green;
  Color selectClose = Colors.yellow;
  String selectedPrice = "市价";
  List priceList = ["画线价", "对手价", "超价", "市价"];
  Contract? contract; //合约

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
      if (call.method == kWindowEventDrawOrder) {
        windowOnTop(windowId());
      } else if (call.method == drawDoneEvent) {
        type = 0;
        if (mounted) setState(() {});
      } else if (call.method == toggleTheme) {
        if (call.arguments == themeController.isDarkMode.value) return;
        themeController.toggleTheme();
        if (mounted) setState(() {});
      }
    });

    if (widget.params['contract'] != null) {
      contract = Contract.fromJson(jsonDecode(widget.params['contract']));
    }

    await DesktopMultiWindow.invokeMethod(kMainWindowId, drawOrderWindowId, {"id": kWindowId});
    notifyOrder();
  }

  notifyOrder() async {
    var tmp = {"type": type, "num": num, "priceType": selectedPrice};
    String temp = jsonEncode(tmp);
    await DesktopMultiWindow.invokeMethod(kMainWindowId, kOrderEvent, temp);
  }

  @override
  void onWindowClose() async {
    await WindowController.fromWindowId(kWindowId!).hide();
    await DesktopMultiWindow.invokeMethod(kMainWindowId, kWindowEventHide, {"id": kWindowId});
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
                  });
                })),
        content: Container(
          padding: const EdgeInsets.only(left: 20),
          color: themeController.isDarkMode.value ? Common.dialogDarkBgColor : Common.dialogLightBgColor,
          child: Column(
            children: [
              Text("画线下单", style: TextStyle(fontSize: 16, color: themeController.theme.acrylicBackgroundColor, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  titleWidget("合约"),
                  Text(
                    contract?.name ?? "--",
                    style: TextStyle(color: themeController.theme.acrylicBackgroundColor),
                  )
                ],
              ).marginSymmetric(vertical: 12),
              Row(
                children: [
                  titleWidget("手数"),
                  SizedBox(
                    height: 34,
                    width: 88,
                    child: NumberBox(
                      decoration: WidgetStatePropertyAll(BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: themeController.isDarkMode.value ? Common.comboDarkColor : Common.contentLightBgColor)),
                      style: TextStyle(fontSize: 12, color: themeController.theme.acrylicBackgroundColor),
                      value: num,
                      min: 1,
                      clearButton: false,
                      onChanged: (v) => setState(() => num = v ?? 1),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  titleWidget("方向"),
                  RadioButton(
                      checked: type == 0,
                      style: radioButtonThemeData(),
                      onChanged: (checked) {
                        if (checked) {
                          type = 0;
                          setState(() {});
                        }
                      }),
                  Text("  买", style: TextStyle(fontSize: 12, color: themeController.theme.acrylicBackgroundColor)),
                  RadioButton(
                      checked: type == 1,
                      style: radioButtonThemeData(),
                      onChanged: (checked) {
                        if (checked) {
                          type = 1;
                          if (mounted) setState(() {});
                        }
                      }).marginOnly(left: 15),
                  Text("  卖", style: TextStyle(fontSize: 12, color: themeController.theme.acrylicBackgroundColor)),
                  RadioButton(
                      checked: type == 2,
                      style: radioButtonThemeData(),
                      onChanged: (checked) {
                        if (checked) {
                          type = 2;
                          if (mounted) setState(() {});
                        }
                      }).marginOnly(left: 15),
                  Text("  平", style: TextStyle(fontSize: 12, color: themeController.theme.acrylicBackgroundColor)),
                  RadioButton(
                      checked: type == 3,
                      style: radioButtonThemeData(),
                      onChanged: (checked) {
                        if (checked) {
                          type = 3;
                          if (mounted) setState(() {});
                        }
                      }).marginOnly(left: 15),
                  Text("  反", style: TextStyle(fontSize: 12, color: themeController.theme.acrylicBackgroundColor)),
                ],
              ).marginSymmetric(vertical: 12),
              Row(children: [
                titleWidget("价格"),
                SizedBox(
                    height: 34,
                    width: 88,
                    child: ComboBox<String>(
                      value: selectedPrice,
                      focusColor: Colors.transparent,
                      backgroundColor: themeController.isDarkMode.value ? Common.comboDarkColor : Common.contentLightBgColor,
                      iconEnabledColor: themeController.theme.acrylicBackgroundColor,
                      popupColor: themeController.isDarkMode.value ? Common.comboDarkColor : Common.contentLightBgColor,
                      items: priceList.map((e) {
                        return ComboBoxItem<String>(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(fontSize: 12, color: themeController.theme.acrylicBackgroundColor),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() {
                        selectedPrice = v!;
                        notifyOrder();
                      }),
                    )),
                IconButton(
                    icon: Image.asset(
                      "assets/images/icon_eraser@3x.png",
                      width: Common.iconImageWidth - 5,
                    ),
                    onPressed: () async {
                      await DesktopMultiWindow.invokeMethod(kMainWindowId, delLines);
                    }).marginOnly(left: 5),
              ]),
            ],
          ),
        ));
  }

  Widget titleWidget(String text) {
    return SizedBox(
      width: 50,
      child: Text(
        text,
        style: TextStyle(color: Common.commandTextColor, fontSize: 12),
      ),
    );
  }

  RadioButtonThemeData radioButtonThemeData() {
    return RadioButtonThemeData(
      checkedDecoration: WidgetStateProperty.resolveWith((states) {
        return BoxDecoration(
          border: Border.all(
            color: Common.tradeCloseButtonColor,
            width: !states.isDisabled
                ? states.isHovered && !states.isPressed
                    ? 4.4
                    : 6.0
                : 5.0,
          ),
          color: Common.dialogLightBgColor,
          shape: BoxShape.circle,
        );
      }),
      uncheckedDecoration: WidgetStateProperty.resolveWith((states) {
        return BoxDecoration(
          border: Border.all(
            color: themeController.isDarkMode.value ? Common.radioBorderDarkColor : Common.radioBorderLightColor,
          ),
          shape: BoxShape.circle,
        );
      }),
    );
  }
}
