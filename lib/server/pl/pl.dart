import 'dart:convert';

import 'package:dio/dio.dart';
import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/pl/pl.dart';
import '../../util/http/http.dart';
import '../../util/http/sign_data.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';

class PLServer {
  ///查询止盈止损记录
  static Future<List<PLRecord>?> getHisPLRecord(String? ExchangeNo, String? CommodityNo, String? ContractNo, int? CommodityType, int? MatchSide) async {
    try {
      String? data;
      if (Common.signData) {
        Map<String, Object?> map = {
          "ExchangeNo": ExchangeNo,
          "CommodityNo": CommodityNo,
          "ContractNo": ContractNo,
          "CommodityType": CommodityType,
          "MatchSide": MatchSide
        };
        data = await SignData().signData(jsonEncode(map), Config.queryPL);
      }
      Response response = await HttpUtils.getInstance().post(Config.queryPL, data: data);
      logger.w(response);
      if (response.data["code"] == 0) {
        List<PLRecord> pLRecords = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          pLRecords.add(PLRecord.fromJson(element));
        }
        return pLRecords;
      } else {
        InfoBarUtils.showWarningBar(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///设置止盈止损
  static Future<List<PLRecord>?> setPL(String? ExchangeNo, String? CommodityNo, int? CommodityType, String? ContractNo, int? MatchSide, int? OrderQty,
      int? CloseType, int? PositionType, double? StopWin, double? StopLoss, double? FloatLoss) async {
    try {
      String? data;
      if (Common.signData) {
        Map<String, Object?> map = {
          "ExchangeNo": ExchangeNo,
          "CommodityNo": CommodityNo,
          "ContractNo": ContractNo,
          "CommodityType": CommodityType,
          "MatchSide": MatchSide,
          "OrderQty": OrderQty,
          "CloseType": CloseType,
          "StopWin": StopWin,
          "StopLoss": StopLoss,
          "FloatLoss": FloatLoss,
          "PositionType": PositionType
        };
        data = await SignData().signData(jsonEncode(map), Config.setPL);
      }
      Response response = await HttpUtils.getInstance().post(Config.setPL, data: data);
      logger.i(response);
      if (response.data["code"] == 0) {
        List<PLRecord> pLRecords = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          pLRecords.add(PLRecord.fromJson(element));
        }
        return pLRecords;
      } else {
        InfoBarUtils.showWarningBar(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///修改止盈止损
  static Future<List<PLRecord>?> modifyPL(String? ExchangeNo, String? CommodityNo, int? CommodityType, String? ContractNo, int? MatchSide, int? OrderQty,
      int? CloseType, int? RecordId, double? StopWin, double? StopLoss, double? FloatLoss) async {
    try {
      String? data;
      if (Common.signData) {
        Map<String, Object?> map = {
          "ExchangeNo": ExchangeNo,
          "CommodityNo": CommodityNo,
          "ContractNo": ContractNo,
          "CommodityType": CommodityType,
          "MatchSide": MatchSide,
          "RecordId": RecordId,
          "OrderQty": OrderQty,
          "CloseType": CloseType,
          "StopWin": StopWin,
          "StopLoss": StopLoss,
          "FloatLoss": FloatLoss,
        };
        data = await SignData().signData(jsonEncode(map), Config.modifyPL);
      }
      Response response = await HttpUtils.getInstance().post(Config.modifyPL, data: data);
      logger.i(response);
      if (response.data["code"] == 0) {
        List<PLRecord> pLRecords = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          pLRecords.add(PLRecord.fromJson(element));
        }
        return pLRecords;
      } else {
        InfoBarUtils.showWarningBar(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///打开关闭止盈止损记录
  static Future<List<PLRecord>?> enablePLRecord(
      String? ExchangeNo, String? CommodityNo, int? CommodityType, String? ContractNo, int? MatchSide, int? RecordId, bool Enable) async {
    try {
      String? data;
      if (Common.signData) {
        Map<String, Object?> map = {
          "ExchangeNo": ExchangeNo,
          "CommodityNo": CommodityNo,
          "ContractNo": ContractNo,
          "CommodityType": CommodityType,
          "MatchSide": MatchSide,
          "RecordId": RecordId,
          "Enable": Enable,
        };
        data = await SignData().signData(jsonEncode(map), Config.enablePL);
      }
      Response response = await HttpUtils.getInstance().post(Config.enablePL, data: data);
      logger.i(response);
      if (response.data["code"] == 0) {
        List<PLRecord> pLRecords = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          pLRecords.add(PLRecord.fromJson(element));
        }
        return pLRecords;
      } else {
        InfoBarUtils.showWarningBar(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///删除止盈止损记录
  static Future<List<PLRecord>?> delPLRecord(
      String? ExchangeNo, String? CommodityNo, String? ContractNo, int? CommodityType, int? MatchSide, int? RecordId) async {
    try {
      String? data;
      if (Common.signData) {
        Map<String, Object?> map = {
          "ExchangeNo": ExchangeNo,
          "CommodityNo": CommodityNo,
          "ContractNo": ContractNo,
          "CommodityType": CommodityType,
          "MatchSide": MatchSide,
          "RecordId": RecordId,
        };
        data = await SignData().signData(jsonEncode(map), Config.delPL);
      }
      Response response = await HttpUtils.getInstance().post(Config.delPL, data: data);
      logger.w(response);
      if (response.data["code"] == 0) {
        List<PLRecord> pLRecords = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          pLRecords.add(PLRecord.fromJson(element));
        }
        return pLRecords;
      } else {
        InfoBarUtils.showWarningBar(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return null;
  }
}
