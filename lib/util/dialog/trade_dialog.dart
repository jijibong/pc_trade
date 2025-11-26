import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import '../../config/common.dart';
import '../../model/position/add_order.dart';
import '../../model/quote/order_type.dart';
import '../../model/quote/position_effect_type.dart';
import '../../model/quote/side_type.dart';
import '../../server/trade/deal.dart';
import '../theme/theme.dart';

class TradeDialog {
  Widget addOrderDialog(AddOrder order) {
    String type = order.OrderSide == SideType.SIDE_SELL ? "卖出" : "买入";
    String open = order.PositionEffect == PositionEffectType.PositionEffect_OPEN ? "开仓" : "平仓";
    String mPrice = "";
    switch (order.OrderType) {
      case Order_Type.ORDER_TYPE_LIMIT:
        mPrice = "${order.OrderPrice ?? 0}";
        break;
      case Order_Type.ORDER_TYPE_STOP_LIMIT:
        mPrice = "触发价：${order.OrderPrice}止损价：${order.StopPrice}";
        break;
    }
    return ContentDialog(
      style: ContentDialogThemeData(
          padding: const EdgeInsets.all(5),
          bodyPadding: EdgeInsets.zero,
          decoration: BoxDecoration(color: Common.contentLightBgColor, borderRadius: BorderRadius.circular(20))),
      content: SizedBox(
        height: 380,
        width: 280,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(FluentIcons.cancel))
              ],
            ),
            const Spacer(),
            dialogItem("合约代码", order.code),
            dialogItem("合约名称", order.name),
            dialogItem("买卖", type),
            dialogItem("开平", open),
            dialogItem("下单类型", order.OrderType == Order_Type.ORDER_TYPE_MARKET ? "市价" : "限价"),
            if (order.OrderType != Order_Type.ORDER_TYPE_MARKET) dialogItem("下单价格", mPrice),
            dialogItem("下单数量", order.OrderQty.toString()),
            const Spacer(
              flex: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.contentLightBgColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6, horizontal: 28)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), side: BorderSide(color: Common.dialogContentBorderBgColor)))),
                  onPressed: () async {
                    Get.back();
                  },
                  child: Text('取消', style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.w500)),
                ),
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6, horizontal: 28)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  onPressed: () {
                    Get.back();
                    addOrder(
                        order.ExchangeNo ?? '',
                        order.CommodityNo ?? '',
                        order.ContractNo ?? '',
                        order.CommodityType ?? 0,
                        order.OrderType ?? 0,
                        order.TimeInForce ?? 0,
                        order.ExpireTime ?? '',
                        order.OrderSide ?? 0,
                        order.OrderPrice ?? 0,
                        order.StopPrice ?? 0,
                        order.OrderQty ?? 0,
                        order.PositionEffect ?? 0);
                  },
                  child: Text(
                    '确定',
                    style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ).marginOnly(bottom: 28)
          ],
        ),
      ),
    );
  }

  // Widget cancelDialog(DelegateOrder order, void Function() function) {
  //   return Theme(
  //       data: ThemeData.light(),
  //       child: CupertinoAlertDialog(
  //         title: const Text(
  //           "撤单",
  //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
  //         ),
  //         content: Column(
  //           children: [
  //             dialogItem("合约名称", order.name),
  //             dialogItem("合约代码", order.code),
  //             dialogItem("委托价格", order.price.toString()),
  //             dialogItem("委托数量", order.deleNum.toString()),
  //             dialogItem("委托状态", order.state),
  //             dialogItem("委托日期", order.date),
  //           ],
  //         ),
  //         actions: [
  //           CupertinoDialogAction(
  //             child: Text(
  //               "取消",
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             onPressed: () {
  //               Get.back();
  //             },
  //           ),
  //           Container(
  //               color: Common.trade_blue,
  //               child: CupertinoDialogAction(
  //                 child: const Text("确认撤单", style: TextStyle(color: Colors.white)),
  //                 onPressed: () async {
  //                   await DealServer.cancelOrder(order.deleNo ?? "").then((value) {
  //                     if (value) {
  //                       Get.back();
  //                       function();
  //                     }
  //                   });
  //                 },
  //               )),
  //         ],
  //       ));
  // }

  Widget dialogItem(String title, String? content) {
    return Container(
      padding: const EdgeInsets.only(top: 18),
      child: Row(children: [
        Expanded(
            child: Text(
          title,
          textAlign: TextAlign.end,
          style: TextStyle(color: Common.commandTextColor),
        )),
        const SizedBox(
          width: 32,
        ),
        Expanded(child: Text(content ?? "--", textAlign: TextAlign.start, style: TextStyle(color: Common.contentDarkBgColor)))
      ]),
    );
  }

  /// 下单
  void addOrder(String ExchangeNo, String CommodityNo, String ContractNo, int CommodityType, int OrderType, int TimeInForce, String ExpireTime,
      int OrderSide, double OrderPrice, double StopPrice, int OrderQty, int PositionEffect) async {
    await DealServer.addOrder(ExchangeNo, CommodityNo, ContractNo, CommodityType, OrderType, TimeInForce, ExpireTime, OrderSide, OrderPrice,
        StopPrice, OrderQty, PositionEffect, "");
  }
}
