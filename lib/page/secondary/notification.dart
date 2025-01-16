import 'dart:convert';
import 'dart:math';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

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
    return NavigationView(
      appBar: NavigationAppBar(
          automaticallyImplyLeading: false,
          height: 30,
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
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Image.asset('assets/images/jmaster.ico', width: 16, height: 16),
                  const Text(
                    "  提示  ",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                  Expanded(child: Container())
                ]),
              )),
          actions: IconButton(
              icon: const Icon(
                FluentIcons.chrome_close,
                color: Colors.white,
              ),
              onPressed: () {
                Future.delayed(Duration.zero, () async {
                  resDelOrderList.clear();
                  await WindowController.fromWindowId(kWindowId!).hide();
                });
              })),
      content: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          Column(
            children: [
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
                        Image.asset(resDelOrderList[index].ErrorText == "成功" ? "assets/images/success.png" : "assets/images/warning.png"),
                        Text(resDelOrderList[index].ErrorText == "成功" ? "完全成交" : resDelOrderList[index].ErrorText ?? "",
                                style: TextStyle(color: Colors.yellow))
                            .marginOnly(top: 8),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${resDelOrderList[index].CommodityNo ?? "--"}${resDelOrderList[index].ContractNo ?? "--"}")
                                      .marginOnly(bottom: 10),
                                  Text(resDelOrderList[index].CreateTime?.substring(11) ?? "--"),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${resDelOrderList[index].OrderType == Order_Type.ORDER_TYPE_MARKET ? "市价" : resDelOrderList[index].OrderPrice}")
                                      .marginOnly(bottom: 10),
                                  Text(
                                      "${resDelOrderList[index].OrderSide == SideType.SIDE_SELL ? "卖" : "买"}${PositionEffectType.getShortName(resDelOrderList[index].PositionEffect)}${resDelOrderList[index].OrderQty}手"),
                                ],
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
                      child: const Text("上一条"),
                      onPressed: () {
                        if (controller.page == 0) return;
                        controller.jumpToPage(max(0, (controller.page ?? 0).toInt() - 1));
                      }),
                  Button(
                      child: const Text("下一条"),
                      onPressed: () {
                        if ((controller.page ?? 0) + 1 == resDelOrderList.length) return;
                        controller.jumpToPage(min(resDelOrderList.length, (controller.page ?? 0).toInt() + 1));
                      })
                ],
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
          Positioned(
            child: Text("$pageIndex/${resDelOrderList.length}"),
          )
        ],
      ),
    );
  }
}
