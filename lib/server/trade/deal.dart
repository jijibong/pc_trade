import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart' hide Response;
import 'package:trade/util/info_bar/info_bar.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/delegation/res_del_order.dart';
import '../../model/trade/margin.dart';
import '../../model/user/user.dart';
import '../../util/http/http.dart';
import '../../util/http/sign_data.dart';
import '../../util/log/log.dart';
import '../../util/theme/theme.dart';

class DealServer {
  /// 查询合约初始保证金
  static Future<ResInitMargin?> getInitMargin(String? ExchangeNo, String? CommodityNo, int? CommodityType, String? ContractNo) async {
    try {
      String? data;
      if (Common.signData) {
        Map<String, Object?> map = {
          "ExchangeNo": ExchangeNo,
          "CommodityNo": CommodityNo,
          "CommodityType": CommodityType,
          "ContractNo": ContractNo,
        };
        data = await SignData().signData(jsonEncode(map), Config.queryContractMargin);
      }
      Response response = await HttpUtils.getInstance().post(Config.queryContractMargin, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        ResInitMargin resInitMargin = ResInitMargin.fromJson(response.data["data"]);
        return resInitMargin;
      } else {
        InfoBarUtils.showWarningBar("未设置保证金,${response.data["msg"]}");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  /// 下单
  static Future<bool> addOrder(String ExchangeNo, String CommodityNo, String ContractNo, int CommodityType, int OrderType, int TimeInForce, String ExpireTime,
      int OrderSide, double OrderPrice, double StopPrice, int OrderQty, int PositionEffect, String ClientOrderId) async {
    try {
      String? data;
      if (Common.signData) {
        Map<String, Object?> map = {
          "ExchangeNo": ExchangeNo,
          "CommodityNo": CommodityNo,
          "ContractNo": ContractNo,
          "CommodityType": CommodityType,
          "OrderType": OrderType,
          "TimeInForce": TimeInForce,
          "ExpireTime": ExpireTime,
          "OrderSide": OrderSide,
          "OrderPrice": OrderPrice,
          "StopPrice": StopPrice,
          "OrderQty": OrderQty,
          "PositionEffect": PositionEffect,
          "ClientOrderId": ClientOrderId,
        };
        data = await SignData().signData(jsonEncode(map), Config.addOrder);
      }
      Response response = await HttpUtils.getInstance().post(Config.addOrder, data: data);
      logger.i(response);
      if (response.data["code"] == 0) {
        InfoBarUtils.showSuccessBar("下单成功");
        return true;
      } else {
        // InfoBarUtils.showWarningBar(response.data["msg"]);
        if (UserUtils.appContext != null) {
          final appTheme = AppTheme();
          showDialog(
              context: UserUtils.appContext!,
              builder: (BuildContext context) {
                return ContentDialog(
                  style: ContentDialogThemeData(
                      padding: EdgeInsets.zero,
                      bodyPadding: EdgeInsets.zero,
                      decoration: BoxDecoration(color: appTheme.color, borderRadius: BorderRadius.zero)),
                  content: Container(
                    height: 200,
                    color: Common.dialogContentColor,
                    alignment: Alignment.center,
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
                        Expanded(
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FluentIcons.warning,
                                    size: 36,
                                    color: Colors.yellow,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Flexible(child: Text(response.data["msg"])),
                                ],
                              )),
                        ),
                        Button(
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                              shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                          child: const Text(
                            "确定",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        )
                      ],
                    ),
                  ),
                );
              });
        } else {
          InfoBarUtils.showWarningBar(response.data["msg"]);
        }
      }
    } on DioException {
      rethrow;
    }
    return false;
  }

  /// 反手
  static Future<bool> reverseOrder(
      String ExchangeNo, int CommodityType, String CommodityNo, String ContractNo, int OrderSide, double OrderPrice, int OrderQty) async {
    try {
      String? data;
      if (Common.signData) {
        Map<String, Object?> map = {
          "ExchangeNo": ExchangeNo,
          "CommodityNo": CommodityNo,
          "ContractNo": ContractNo,
          "CommodityType": CommodityType,
          "OrderSide": OrderSide,
          "OrderPrice": OrderPrice,
          "OrderQty": OrderQty,
        };
        data = await SignData().signData(jsonEncode(map), Config.reverseOrder);
      }
      Response response = await HttpUtils.getInstance().post(Config.reverseOrder, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        return true;
      } else {
        // logger.e("下单失败,${response.data["msg"]}");
        InfoBarUtils.showWarningBar(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return false;
  }

  /// 撤单
  static Future<bool> cancelOrder(String orderId) async {
    try {
      String? data;
      if (Common.signData) {
        Map<String, Object?> map = {
          "OrderId": orderId,
        };
        data = await SignData().signData(jsonEncode(map), Config.cancleOrder);
      }
      Response response = await HttpUtils.getInstance().post(Config.cancleOrder, data: data);
      logger.i(response);
      if (response.data["code"] == 0) {
        return true;
      } else {
        // logger.e("撤单失败,${response.data["msg"]}");
        InfoBarUtils.showWarningBar(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return false;
  }

  /// 查询可撤单记录
  static Future<List<ResDelOrder>?> queryCancelOrder() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.queryCancle);
      }
      Response response = await HttpUtils.getInstance().post(Config.queryCancle, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        List<ResDelOrder> resDels = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          resDels.add(ResDelOrder.fromJson(element));
        }
        return resDels;
      } else {
        logger.e("下单失败,${response.data["msg"]}");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }
}
