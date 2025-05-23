import 'dart:convert';
import 'dart:math';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart' hide Condition;
import 'package:provider/provider.dart';
import 'package:trade/server/login/login.dart';
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
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
import '../../util/widget/number_box.dart';

class DrawOrder extends StatefulWidget {
  final Map<String, dynamic> params;

  const DrawOrder({super.key, required this.params});

  @override
  State<DrawOrder> createState() => _DrawOrderState();
}

class _DrawOrderState extends State<DrawOrder> with MultiWindowListener {
  late AppTheme appTheme;
  Color selectedColor = Colors.white;
  ScrollController scrollController = ScrollController();
  double boxWidth = 88;
  double padWidth = 18;
  int num = 1;
  int type = 1;
  Color color = Colors.white;
  Color selectBuy = Colors.red;
  Color selectSale = Colors.green;
  Color selectClose = Colors.yellow;
  String selectedPrice = "市价";
  List priceList = ["画线价", "对手价", "超价", "市价"];

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
      }
    });

    await DesktopMultiWindow.invokeMethod(kMainWindowId, drawOrderWindowId, {"id": kWindowId});
    notifyOrder();
  }

  notifyOrder() async {
    var tmp = {"type": type, "num": num, "priceType": selectedPrice};
    String temp = jsonEncode(tmp);
    await rustDeskWinManager.call(WindowType.Main, kOrderEvent, temp);
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
              Expanded(
                  child: const Text(
                "画线下单",
                style: TextStyle(fontSize: 13, color: Colors.white),
              ).marginOnly(left: 2))
            ]),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("数量"),
              Container(
                width: boxWidth,
                height: 35,
                margin: EdgeInsets.symmetric(horizontal: padWidth),
                child: NumberBox(
                  value: num,
                  min: 1,
                  max: 10000000,
                  clearButton: false,
                  onChanged: (v) => setState(() {
                    num = max(1, v ?? 1);
                    notifyOrder();
                  }),
                ),
              ),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: type == 1 ? selectBuy : color),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  child: Text(
                    "买",
                    style: TextStyle(color: type == 1 ? selectBuy : color),
                  ),
                ),
                onTap: () async {
                  type = type == 1 ? 0 : 1;
                  notifyOrder();
                  if (mounted) setState(() {});
                },
              ).marginOnly(right: 10),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: type == 2 ? selectSale : color),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  child: Text(
                    "卖",
                    style: TextStyle(color: type == 2 ? selectSale : color),
                  ),
                ),
                onTap: () {
                  type = type == 2 ? 0 : 2;
                  notifyOrder();
                  if (mounted) setState(() {});
                },
              ).marginOnly(right: 10),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: type == 3 ? selectClose : color),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  child: Text(
                    "平",
                    style: TextStyle(color: type == 3 ? selectClose : color),
                  ),
                ),
                onTap: () {
                  type = type == 3 ? 0 : 3;
                  notifyOrder();
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
          Row(children: [
            const Text("下单价"),
            Flexible(
                child: Container(
              height: 35,
              margin: EdgeInsets.symmetric(horizontal: padWidth),
              child: ComboBox<String>(
                value: selectedPrice,
                // isExpanded: true,
                items: priceList.map((e) {
                  return ComboBoxItem<String>(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (v) => setState(() {
                  selectedPrice = v!;
                  notifyOrder();
                }),
              ),
            )),
          ]).marginOnly(bottom: padWidth),
          const Text("说明：画线下单为本地条件单，需要保持在线")
        ],
      ).paddingOnly(left: padWidth),
    );
  }
}
