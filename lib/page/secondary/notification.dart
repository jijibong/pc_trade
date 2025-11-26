import 'dart:convert';
import 'dart:math';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../config/common.dart';
import '../../main.dart';
import '../../model/delegation/res_del_order.dart';
import '../../model/quote/order_type.dart';
import '../../model/quote/position_effect_type.dart';
import '../../model/quote/side_type.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';

class LocalNotification extends StatefulWidget {
  final Map<String, dynamic> params;

  const LocalNotification({super.key, required this.params});

  @override
  State<LocalNotification> createState() => _LocalNotificationState();
}

class _LocalNotificationState extends State<LocalNotification> with MultiWindowListener {
  List<ResDelOrder> resDelOrderList = [];
  int pageIndex = 1;
  PageController controller = PageController();

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
    if (widget.params['hold'] != null && widget.params['hold'] != '') {
      resDelOrderList.insert(0, ResDelOrder.fromJson(jsonDecode(widget.params['hold'])));
      if (mounted) setState(() {});
    }
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
    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      if (call.method == kWindowEventNewNotification) {
        windowOnTop(windowId());
        Map<String, dynamic> map = jsonDecode(call.arguments);
        String holdString = map["hold"];
        ResDelOrder res = ResDelOrder.fromJson(jsonDecode(holdString));
        resDelOrderList.insert(0, res);
        if (mounted) setState(() {});
      }
    });
    initData();
  }

  @override
  void dispose() {
    DesktopMultiWindow.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Common.contentLightBgColor,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () async {
                        await WindowController.fromWindowId(kWindowId!).hide();
                      },
                      icon: const Icon(FluentIcons.cancel))
                ],
              ).paddingOnly(top: 5)),
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: resDelOrderList.length,
              onPageChanged: (index) {
                pageIndex = index + 1;
                if (mounted) setState(() {});
              },
              itemBuilder: (_, index) {
                return Column(
                  children: [
                    Image.asset(
                      resDelOrderList[index].ErrorText == "成功" ? "assets/images/pic_yipaidui@3x.png" : "assets/images/pic_fail@3x.png",
                      width: 115,
                    ),
                    Text(resDelOrderList[index].ErrorText == "成功" ? "完全成交" : resDelOrderList[index].ErrorText ?? "",
                            style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.bold))
                        .marginOnly(top: 8),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                          color: Common.tradeButtonColor,
                          border: Border.all(color: Common.dialogContentBorderBgColor),
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            resDelOrderList[index].CreateTime?.substring(11) ?? "--",
                            style: TextStyle(color: Common.commandTextColor),
                          ),
                          Text(
                            "${resDelOrderList[index].CommodityNo ?? "--"}${resDelOrderList[index].ContractNo ?? "--"}",
                            style: TextStyle(color: Common.commandTextColor),
                          ),
                          Text(
                            "${resDelOrderList[index].OrderType == Order_Type.ORDER_TYPE_MARKET ? "市价" : resDelOrderList[index].OrderPrice}",
                            style: TextStyle(color: Common.contentDarkBgColor),
                          ),
                          Text(
                            "${resDelOrderList[index].OrderSide == SideType.SIDE_SELL ? "卖" : "买"}${PositionEffectType.getShortName(resDelOrderList[index].PositionEffect)}${resDelOrderList[index].OrderQty}手",
                            style: TextStyle(color: Common.contentDarkBgColor),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.contentLightBgColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), side: BorderSide(color: Common.dialogContentBorderBgColor)))),
                  child: const Text("上一条"),
                  onPressed: () {
                    if (controller.page == 0) return;
                    controller.jumpToPage(max(0, (controller.page ?? 0).toInt() - 1));
                  }),
              Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.contentLightBgColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), side: BorderSide(color: Common.dialogContentBorderBgColor)))),
                  child: const Text("下一条"),
                  onPressed: () {
                    if ((controller.page ?? 0) + 1 == resDelOrderList.length) return;
                    controller.jumpToPage(min(resDelOrderList.length, (controller.page ?? 0).toInt() + 1));
                  })
            ],
          ).marginOnly(top: 20)
        ],
      ),
    );
  }
}
