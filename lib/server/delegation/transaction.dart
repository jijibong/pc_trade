import 'dart:convert';

import 'package:dio/dio.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/delegation/res_comm_order.dart';
import '../../util/http/http.dart';
import '../../util/http/sign_data.dart';
import '../../util/log/log.dart';

class TransactionServer {
  ///查询当日委托记录
  static Future<List<ResComOrder>?> queryComOrder() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.queryComOrder);
      }
      Response response = await HttpUtils.getInstance().post(Config.queryComOrder, data: data);
      // logger.w(response);
      if (response.data["code"] == 0 ) {
        List<ResComOrder> resComOrder = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          resComOrder.add(ResComOrder.fromJson(element));
        }
        return resComOrder;
      } else {
        logger.e("暂无委托记录：$response");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///查询历史委托记录
  static Future<List<ResComOrder>?> queryHisComOrder(String startTime, String endTime) async {
    try {
      String? data;
      if (Common.signData) {
        var map = {
          "StartTime": startTime,
          "EndTime": endTime,
        };
        data = await SignData().signData(jsonEncode(map), Config.queryHisComOrder);
      }
      Response response = await HttpUtils.getInstance().post(Config.queryHisComOrder, data: data);
      // logger.w(response);
      if (response.data["code"] == 0 ) {
        List<ResComOrder> resDelOrder = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          resDelOrder.add(ResComOrder.fromJson(element));
        }
        return resDelOrder;
      } else {
        logger.e("暂无委托记录：$response");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }
}
