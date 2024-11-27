import 'package:dio/dio.dart';

import '../../config/config.dart';
import '../../model/trade/query/capital.dart';
import '../../model/trade/query/close_detail.dart';
import '../../model/trade/query/position_detail.dart';
import '../../model/trade/query/position_summary.dart';
import '../../model/trade/query/transaction_record.dart';
import '../../model/trade/query/withdrawal_record.dart';
import '../../util/http/http.dart';
import '../../util/log/log.dart';

///交易相关查询
class SettleServer {
  ///成交记录
  static Future<List<TransactionRecord>> getFillRecord(num? accountId, String startTime, String endTime) async {
    try {
      Response response = await HttpUtils.getInstance().post(Config.FILLRECORD, data: {
        "AccountId": accountId,
        "StartTime": startTime,
        "EndTime": endTime,
        "Page": {"CurrPage": 0, "PageSize": 10000, "PageFlag": false}
      });
      logger.i(response.data);
      List<TransactionRecord> data = [];
      List<dynamic> list = response.data["data"]["Params"] ?? [];
      data.addAll(list.map((e) => TransactionRecord.fromJson(e)));
      return data;
    } on DioException {
      rethrow;
    }
  }

  ///平仓明细
  static Future<List<CloseDetail>> getCloseDetailed(num? accountId, String startTime, String endTime, int condition) async {
    try {
      Response response = await HttpUtils.getInstance().post(Config.CLOSEDETAILED, data: {
        "AccountId": accountId,
        "StartTime": startTime,
        "EndTime": endTime,
        "Condition": condition,
        "Page": {"CurrPage": 0, "PageSize": 10000, "PageFlag": false}
      });
      logger.i(response.data);
      List<CloseDetail> data = [];
      List<dynamic> list = response.data["data"]["Params"] ?? [];
      data.addAll(list.map((e) => CloseDetail.fromJson(e)));
      return data;
    } on DioException {
      rethrow;
    }
  }

  ///持仓明细
  static Future<List<PositionDetail>> getPositionDetailed(num? accountId, String startTime, String endTime, int condition) async {
    try {
      Response response = await HttpUtils.getInstance().post(Config.POSITIONDETAILED, data: {
        "AccountId": accountId,
        "StartTime": startTime,
        "EndTime": endTime,
        "Condition": condition,
        "Page": {"CurrPage": 0, "PageSize": 10000, "PageFlag": false}
      });
      logger.i(response.data);
      List<PositionDetail> data = [];
      List<dynamic> list = response.data["data"]["Params"] ?? [];
      data.addAll(list.map((e) => PositionDetail.fromJson(e)));
      return data;
    } on DioException {
      rethrow;
    }
  }

  ///出入金记录
  static Future<List<WithdrawalRecord>> getCashReport(num? accountId, String startTime, String endTime) async {
    try {
      Response response = await HttpUtils.getInstance().post(Config.GET_CASHREPORT, data: {
        "AccountId": accountId,
        "StartTime": startTime,
        "EndTime": endTime,
        "Page": {"CurrPage": 0, "PageSize": 10000, "PageFlag": false}
      });
      logger.i(response.data);
      List<WithdrawalRecord> data = [];
      List<dynamic> list = response.data["data"]["Params"] ?? [];
      data.addAll(list.map((e) => WithdrawalRecord.fromJson(e)));
      return data;
    } on DioException {
      rethrow;
    }
  }

  ///持仓汇总
  static Future<List<PositionSummary>> getPositionSummary(num? accountId, String startTime, String endTime, int condition) async {
    try {
      Response response = await HttpUtils.getInstance().post(Config.POSITIONSUMMARY, data: {
        "AccountId": accountId,
        "StartTime": startTime,
        "EndTime": endTime,
        "Condition": condition,
        "Page": {"CurrPage": 0, "PageSize": 10000, "PageFlag": false}
      });
      logger.i(response.data);
      List<PositionSummary> data = [];
      List<dynamic> list = response.data["data"] ?? [];
      data.addAll(list.map((e) => PositionSummary.fromJson(e)));
      return data;
    } on DioException {
      rethrow;
    }
  }

  ///查询资金结算信息报表
  static Future<List<Capital>> getCapital(num? accountId, String? startTime, String? endTime, int condition) async {
    try {
      Response response = await HttpUtils.getInstance()
          .post(Config.GET_CAPITAL, data: {"AccountId": accountId, "Condition": condition, "StartTime": startTime, "EndTime": endTime});
      logger.i(response.data);
      List<Capital> data = [];
      List<dynamic> list = response.data["data"] ?? [];
      data.addAll(list.map((e) => Capital.fromJson(e)));
      if (data.isNotEmpty) {
        data.sort((b, a) {
          String? theCurrency = a.Currency;
          String? otherCurrency = b.Currency;
          if (theCurrency == null || otherCurrency == null) {
            return 0;
          }
          if (theCurrency == "JB") {
            return 1;
          } else if (theCurrency == "USD") {
            if (otherCurrency == "JB") {
              return 0;
            }
            return 1;
          } else if (theCurrency == "HKD") {
            if (otherCurrency == "JB" || otherCurrency == "USD") {
              return 0;
            }
            return 1;
          } else if (theCurrency == "JPY") {
            if (otherCurrency == "JB" || otherCurrency == "USD" || otherCurrency == "HKD") {
              return 0;
            }
            return 1;
          } else if (theCurrency == "GBP") {
            if (otherCurrency == "JB" || otherCurrency == "USD" || otherCurrency == "HKD" || otherCurrency == "JPY") {
              return 0;
            }
            return 1;
          } else if (theCurrency == "EUR") {
            if (otherCurrency == "JB" || otherCurrency == "USD" || otherCurrency == "HKD" || otherCurrency == "JPY" || otherCurrency == "GBP") {
              return 0;
            }
            return 1;
          } else if (theCurrency == "CNH") {
            return -1;
          } else {
            return 0;
          }
        });
      }
      return data;
    } on DioException {
      rethrow;
    }
  }
}
