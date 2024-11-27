import 'dart:convert';

import 'package:dio/dio.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/delegation/res_del_order.dart';
import '../../util/http/http.dart';
import '../../util/http/sign_data.dart';
import '../../util/log/log.dart';

class DelegationServer {
  ///查询当日委托记录
  static Future<List<ResDelOrder>?> queryDelOrder() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.queryDelOrder);
      }
      Response response = await HttpUtils.getInstance().post(Config.queryDelOrder, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        List<ResDelOrder> resDelOrder = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          resDelOrder.add(ResDelOrder.fromJson(element));
        }
        return resDelOrder;
      } else {
        logger.e("查询委托记录错误：$response");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///查询历史委托记录
  static Future<List<ResDelOrder>?> queryHisDelOrder(String startTime, String endTime) async {
    try {
      String? data;
      if (Common.signData) {
        var map = {
          "StartTime": startTime,
          "EndTime": endTime,
        };
        data = await SignData().signData(jsonEncode(map), Config.queryHisDelOrder);
      }
      Response response = await HttpUtils.getInstance().post(Config.queryHisDelOrder, data: data);
      logger.w(response);
      if (response.data["code"] == 0) {
        List<ResDelOrder> resDelOrder = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          resDelOrder.add(ResDelOrder.fromJson(element));
        }
        return resDelOrder;
      } else {
        logger.e("查询委托记录错误：$response");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }
}
