import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import '../config/common.dart';
import '../model/position/add_order.dart';
import '../model/quote/order_type.dart';
import '../model/quote/position_effect_type.dart';
import '../model/quote/side_type.dart';
import '../server/trade/deal.dart';
import 'theme/theme.dart';

class TradeDialog {
  Widget addOrderDialog(AddOrder order, {void Function()? function}) {
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
    final appTheme = AppTheme();
    return ContentDialog(
      style: ContentDialogThemeData(
          padding: EdgeInsets.zero,
          bodyPadding: EdgeInsets.zero,
          decoration: BoxDecoration(color: appTheme.unColor, borderRadius: BorderRadius.zero)),
      content: Container(
        height: 300,
        color: Common.dialogContentColor,
        child: Column(
          children: [
            Container(
              color: Common.dialogTitleColor,
              margin: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/jmaster.ico",
                    width: 20,
                  ),
                  Expanded(
                    child: Text(
                      Common.appName,
                      style: TextStyle(color: appTheme.color),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(FluentIcons.cancel))
                ],
              ),
            ),
            dialogItem("合约代码", order.code),
            dialogItem("合约名称", order.name),
            dialogItem("买卖", type),
            dialogItem("开平", open),
            dialogItem("下单类型", order.OrderType == Order_Type.ORDER_TYPE_MARKET ? "市价" : "限价"),
            if (order.OrderType != Order_Type.ORDER_TYPE_MARKET) dialogItem("下单价格", mPrice),
            dialogItem("下单数量", order.OrderQty.toString()),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                      shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                  child: const Text(
                    "下单",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Get.back();
                    addOrder(
                        order.name ?? '',
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
                        order.PositionEffect ?? 0,
                        order.needBackHand);
                    if (function != null) {
                      function();
                    }
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
                    Get.back();
                  },
                ),
              ],
            )
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
      padding: const EdgeInsets.only(top: 6),
      child: Row(children: [
        Expanded(
            child: Text(
          title,
          textAlign: TextAlign.end,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        )),
        const SizedBox(
          width: 15,
        ),
        Expanded(child: Text(content ?? "--", textAlign: TextAlign.start, style: const TextStyle(color: Colors.white, fontSize: 16)))
      ]),
    );
  }

  /// 下单
  void addOrder(String name, String ExchangeNo, String CommodityNo, String ContractNo, int CommodityType, int OrderType, int TimeInForce,
      String ExpireTime, int OrderSide, double OrderPrice, double StopPrice, int OrderQty, int PositionEffect, bool needBackHand) async {
    String str = name;
    str += OrderSide == SideType.SIDE_SELL ? "卖" : "买";
    str += PositionEffect == PositionEffectType.PositionEffect_OPEN ? "开" : "平";

    int qty = 0;
    //正常操作开仓，平仓
    qty = OrderQty;
    final String msg = "$str$qty手";
    // String localOrderId = DeviceUtil.createLocalOrderId();
    // if (needBackHand) {
    //   await SpUtils.set(localOrderId, TradeOperation.BackHand);
    // }
    await DealServer.addOrder(ExchangeNo, CommodityNo, ContractNo, CommodityType, OrderType, TimeInForce, ExpireTime, OrderSide, OrderPrice,
            StopPrice, OrderQty, PositionEffect, "")
        .then((value) {
      if (value) {
        // InfoBarUtils.showSuccessBar("$msg服务器已接收订单");
      }
    });
  }
}
