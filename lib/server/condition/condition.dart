import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:trade/util/info_bar/info_bar.dart';
import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/condition/condition.dart';
import '../../util/http/http.dart';
import '../../util/http/sign_data.dart';
import '../../util/log/log.dart';

class ConditionServer {
  ///查询条件单
  static Future<List<Condition>?> queryTodayCondition() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.queryTodayCondition);
      }
      Response response = await HttpUtils.getInstance().post(Config.queryTodayCondition, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        List<Condition> conditions = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          conditions.add(Condition.fromJson(element));
        }
        return conditions;
      } else {
        // InfoBarUtils.showErrorBar(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///删除条件单
  static Future<bool> delCondition(int id) async {
    try {
      String? data;
      if (Common.signData) {
        var map = {
          "Id": id,
        };
        data = await SignData().signData(jsonEncode(map), Config.delCondition);
      }
      Response response = await HttpUtils.getInstance().post(Config.delCondition, data: data);
      logger.i(response);
      if (response.data["code"] == 0) {
        return true;
      } else {
        InfoBarUtils.showErrorDialog(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return false;
  }

  ///更新条件单
  static Future<bool> updateCondition(
    int? id,
    int OrderType,
    int TimeInForce,
    String ExpireTime,
    int OrderSide,
    double OrderPrice,
    int OrderQty,
    int PositionEffect,
    int PriceType,
    int ConditionType,
    double ConditionPrice,
  ) async {
    try {
      String? data;
      if (Common.signData) {
        var map = {
          "Id": id,
          "OrderType": OrderType,
          "TimeInForce": TimeInForce,
          "ExpireTime": ExpireTime,
          "OrderSide": OrderSide,
          "OrderPrice": OrderPrice,
          "OrderQty": OrderQty,
          "PositionEffect": PositionEffect,
          "PriceType": PriceType,
          "ConditionType": ConditionType,
          "ConditionPrice": ConditionPrice,
        };
        data = await SignData().signData(jsonEncode(map), Config.updateCondition);
      }
      Response response = await HttpUtils.getInstance().post(Config.updateCondition, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        return true;
      } else {
        InfoBarUtils.showErrorDialog(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return false;
  }

  ///添加条件单
  static Future<bool> addCondition(
      String? ExchangeNo,
      String? CommodityNo,
      int? CommodityType,
      String? ContractNo,
      int? OrderType,
      int? TimeInForce,
      String? ExpireTime,
      int? OrderSide,
      double? OrderPrice,
      int? OrderQty,
      int? PositionEffect,
      int? PriceType,
      int? ConditionType,
      double? ConditionPrice) async {
    try {
      String? data;
      if (Common.signData) {
        var map = {
          "ExchangeNo": ExchangeNo,
          "CommodityNo": CommodityNo,
          "CommodityType": CommodityType,
          "ContractNo": ContractNo,
          "OrderType": OrderType,
          "TimeInForce": TimeInForce,
          "ExpireTime": ExpireTime,
          "OrderSide": OrderSide,
          "OrderPrice": OrderPrice,
          "OrderQty": OrderQty,
          "PositionEffect": PositionEffect,
          "PriceType": PriceType,
          "ConditionType": ConditionType,
          "ConditionPrice": ConditionPrice,
        };
        data = await SignData().signData(jsonEncode(map), Config.addCondition);
      }
      Response response = await HttpUtils.getInstance().post(Config.addCondition, data: data);
      // logger.w(response);
      if (response.data["code"] == 0) {
        return true;
      } else {
        InfoBarUtils.showErrorDialog(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return false;
  }
}
