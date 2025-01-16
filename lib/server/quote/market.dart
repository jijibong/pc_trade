import 'dart:convert';

import 'package:dio/dio.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/k/OHLCEntity.dart';
import '../../model/k/k_preiod.dart';
import '../../model/option/option_server.dart';
import '../../model/option/req_order_option.dart';
import '../../model/quote/close_today.dart';
import '../../model/quote/commodity.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../../util/http/http.dart';
import '../../util/http/md_http.dart';
import '../../util/http/sign_data.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';
import '../../util/utils/market_util.dart';
import '../../util/utils/utils.dart';


class MarketServer {
  ///查询更新时间
  static Future<String?> queryCodeUpdateTime() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.queryCodeUpdateTime);
      }
      Response response = await MdHttpUtils.getInstance().post(Config.queryCodeUpdateTime, data: data);
      // logger.w(response);
      if (response.data["code"] == 0) {
        return response.data["data"];
      } else {
        logger.e("查询更新时间表错误：$response");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///查询优先平今品种
  static Future<List<ComCloseToday>?> queryCloseToday() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.queryCloseToday);
      }
      Response response = await MdHttpUtils.getInstance().post(Config.queryCloseToday, data: data);
      // logger.w(response);
      if (response.data["code"] == 0) {
        List<ComCloseToday> comCloseToday = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          comCloseToday.add(ComCloseToday.fromJson(element));
        }
        return comCloseToday;
      } else {
        logger.e("查询优先平今品种错误：$response");
        return null;
      }
    } on DioException {
      rethrow;
    }
  }

  ///查询交易所
  static Future<List<Exchange>?> queryExchangeUrl() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.queryExchangeUrl);
      }
      Response response = await MdHttpUtils.getInstance().post(Config.queryExchangeUrl, data: data);
      // logger.w(response);
      if (response.data["code"] == 0) {
        List<Exchange> exchanges = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          exchanges.add(Exchange.fromJson(element));
        }
        return exchanges;
      } else {
        logger.e("查询交易所错误：$response");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///查询合约
  static Future<List<Commodity>?> queryAllContractUrl() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.queryAllContractUrl);
      }
      Response response = await MdHttpUtils.getInstance().post(Config.queryAllContractUrl, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        List<Commodity> commodityList = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          commodityList.add(Commodity.fromJson(element));
        }
        return commodityList;
      } else {
        logger.e("查询合约错误：$response");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  /// 查询用户自选
  static Future<List<Contract>?> queryOption() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.queryOption);
      }
      Response response = await HttpUtils.getInstance().post(Config.queryOption, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        List<Contract> list = [];
        List<dynamic> tmp = response.data["data"] ?? [];
        for (var element in tmp) {
          OptionServer server = OptionServer.fromJson(element);
          list.add(Contract(
            isMain: server.isMain,
            name: server.contracts?.shortName,
            comName: server.shortName,
            code: server.contracts?.contractCode,
            exCode: server.exchangeNo,
            comType: server.commodityType,
            subComCode: server.commodityNo,
            subConCode: server.contracts?.contractNo,
            comId: server.commodityId,
            conId: server.contracts?.id,
            contractID: server.contracts?.id,
            optionId: server.id,
            optionSort: server.serialNum,
            preSettlePrice: server.contracts?.preClose,
            futureTickSize: server.commodityTickSize,
            contractSize: server.contractSize,
            currency: server.tradeCurrency,
            trTime: server.tradeTime,
          ));
        }
        list.sort((lhs, rhs) {
          if (lhs.optionSort == null) {
            return 1;
          }
          if (rhs.optionSort == null) {
            return -1;
          }
          if (lhs.optionSort == rhs.optionSort) {
            return 0;
          } else {
            return lhs.optionSort! > rhs.optionSort! ? 1 : -1;
          }
        });
        MarketUtils.setOptionList(list);
        return list;
      } else {
        return [];
      }
    } on DioException {
      rethrow;
    }
  }

  ///添加自选
  static Future<bool> addOption(Contract contract) async {
    try {
      String? data;
      if (Common.signData) {
        var map = {
          "ExchangeNo": contract.exCode,
          "CommodityNo": contract.subComCode,
          "CommodityType": contract.comType,
          "ContractNo": contract.code,
          "IsMain": contract.isMain,
        };
        data = await SignData().signData(jsonEncode(map), Config.addOption);
      }
      Response response = await HttpUtils.getInstance().post(Config.addOption, data: data);
      logger.w(response);
      if (response.data["code"] == 0) {
        return true;
      } else {
        InfoBarUtils.showErrorBar("添加自选失败:${response.data["msg"] ?? ""}");
      }
    } on DioException {
      rethrow;
    }
    return false;
  }

  ///删除自选
  static Future<List<Contract>?> delOption(List<Contract> contracts) async {
    try {
      List list = [];
      list.addAll(contracts.map((element) => {
            "ExchangeNo": element.exCode,
            "CommodityNo": element.subComCode,
            "CommodityType": element.comType,
            "ContractNo": element.code,
            "IsMain": element.isMain,
          }));
      var map = {"Options": list};
      String data = jsonEncode(map);
      if (Common.signData) {
        data = await SignData().signData(data, Config.delOption);
      }
      Response response = await HttpUtils.getInstance().post(Config.delOption, data: data);
      // logger.w(response);
      if (response.data["code"] == 0) {
        List<Contract> contractList = [];
        List<dynamic> responseData = response.data["data"] ?? [];
        for (var element in responseData) {
          OptionServer server = OptionServer.fromJson(element);
          Contract con = Contract(
            isMain: server.isMain,
            name: server.contracts?.shortName,
            comName: server.shortName,
            code: server.contracts?.contractCode,
            exCode: server.exchangeNo,
            comType: server.commodityType,
            subComCode: server.commodityNo,
            subConCode: server.contracts?.contractNo,
            comId: server.commodityId,
            conId: server.contracts?.id,
            contractID: server.contracts?.id,
            optionId: server.id,
            optionSort: server.serialNum,
            preSettlePrice: server.contracts?.preClose,
            futureTickSize: server.commodityTickSize,
            contractSize: server.contractSize,
            currency: server.tradeCurrency,
            trTime: server.tradeTime,
          );
          contractList.add(con);
        }
        contractList.sort((lhs, rhs) {
          if (lhs.optionSort == null) {
            return 1;
          }
          if (rhs.optionSort == null) {
            return -1;
          }
          if (lhs.optionSort == rhs.optionSort) {
            return 0;
          } else {
            return lhs.optionSort! > rhs.optionSort! ? 1 : -1;
          }
        });
        MarketUtils.setOptionList(contractList);
        return contractList;
      } else {
        InfoBarUtils.showErrorBar("删除自选失败:${response.data["msg"]}");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///自选排序
  static Future<List<Contract>?> orderOption(List<ReqOrderOption> idList) async {
    try {
      List list = [];
      for (var req in idList) {
        var map = {"Id": req.Id, "SerialNum": req.Sort};
        list.add(map);
      }
      var result = {"Options": list};
      String data = jsonEncode(result);

      if (Common.signData) {
        data = await SignData().signData(data, Config.orderOption);
      }
      Response response = await HttpUtils.getInstance().post(Config.orderOption, data: data);
      // logger.w(response);
      if (response.data["code"] == 0) {
        List<Contract> contractList = [];
        List<dynamic> responseData = response.data["data"] ?? [];
        for (var element in responseData) {
          OptionServer server = OptionServer.fromJson(element);
          Contract con = Contract(
            name: server.contracts?.shortName,
            code: server.contracts?.contractCode,
            exCode: server.exchangeNo,
            comType: server.commodityType,
            subComCode: server.commodityNo,
            subConCode: server.contracts?.contractNo,
            comId: server.commodityId,
            conId: server.contracts?.id,
            contractID: server.contracts?.id,
            optionId: server.id,
            optionSort: server.serialNum,
            preSettlePrice: server.contracts?.preClose,
            futureTickSize: server.commodityTickSize,
            contractSize: server.contractSize,
            currency: server.tradeCurrency,
            trTime: server.tradeTime,
          );
          contractList.add(con);
        }
        contractList.sort((lhs, rhs) {
          if (lhs.optionSort == null) {
            return 1;
          }
          if (rhs.optionSort == null) {
            return -1;
          }
          if (lhs.optionSort == rhs.optionSort) {
            return 0;
          } else {
            return lhs.optionSort! > rhs.optionSort! ? 1 : -1;
          }
        });
        MarketUtils.setOptionList(contractList);
        return contractList;
      } else {
        InfoBarUtils.showErrorBar("编辑自选失败:${response.data["msg"]}");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///查询K线
  static Future<List<OHLCEntity>?> queryKline(Contract con, int kType, num unixTime, int count) async {
    try {
      String? data;
      if (Common.signData) {
        String? code = con.subConCode;
        if (con.isMain == true) {
          code = "0000";
        }
        String key = "${con.exCode},${String.fromCharCode(con.comType ?? 0)},${con.subComCode},$code";
        var map = {
          "Key": key,
          "KType": kType,
          "UnixTime": unixTime,
          "Count": count,
        };
        data = await SignData().signData(jsonEncode(map), Config.queryKline);
      }
      Response response = await MdHttpUtils.getInstance().post(Config.queryKline, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        List<OHLCEntity> oHLCEntity = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          OHLCEntity tmp = OHLCEntity.fromJson(element);
          if (tmp.date != "0001-01-01") {
            String strTime = "${tmp.date} ${tmp.time}";
            int timeStamp = Utils.getTimeStamp10(strTime);
            tmp.timeStamp = timeStamp;
          }
          oHLCEntity.add(tmp);
        }
        if (oHLCEntity.isNotEmpty) {
          oHLCEntity.sort((lhs, rhs) {
            if (lhs.timeStamp == null) {
              return 1;
            }
            if (rhs.timeStamp == null) {
              return -1;
            }
            if (lhs.timeStamp == rhs.timeStamp) {
              return 0;
            } else {
              return lhs.timeStamp! > rhs.timeStamp! ? 1 : -1;
            }
          });
        }
        return oHLCEntity;
      } else {
        InfoBarUtils.showErrorBar("K线请求失败:${response.data["msg"]}");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///查询自定义K线
  static Future<List<OHLCEntity>?> customKline(Contract con, KPeriod mPeriod, num unixTime, int count) async {
    try {
      String? data;
      if (Common.signData) {
        String? code = con.subConCode;
        if (con.isMain == true) {
          code = "0000";
        }
        String key = "${con.exCode},${String.fromCharCode(con.comType ?? 0)},${con.subComCode},$code";
        var map = {
          "Key": key,
          "Period": mPeriod.period,
          "UnixTime": unixTime,
          "Count": count,
          "Flag": mPeriod.kpFlag,
        };
        data = await SignData().signData(jsonEncode(map), Config.customKline);
      }
      Response response = await MdHttpUtils.getInstance().post(Config.customKline, data: data);
      // logger.w(response);
      if (response.data["code"] == 0) {
        List<OHLCEntity> oHLCEntity = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          OHLCEntity tmp = OHLCEntity.fromJson(element);
          if (tmp.date != "0001-01-01") {
            String strTime = "${tmp.date} ${tmp.time}";
            int timeStamp = Utils.getTimeStamp10(strTime);
            tmp.timeStamp = timeStamp;
          }
          oHLCEntity.add(tmp);
        }
        if (oHLCEntity.isNotEmpty) {
          oHLCEntity.sort((lhs, rhs) {
            if (lhs.timeStamp == null) {
              return 1;
            }
            if (rhs.timeStamp == null) {
              return -1;
            }
            if (lhs.timeStamp == rhs.timeStamp) {
              return 0;
            } else {
              return lhs.timeStamp! > rhs.timeStamp! ? 1 : -1;
            }
          });
        }
        return oHLCEntity;
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///查询分时
  static Future<List<OHLCEntity>?> queryFs(Contract con) async {
    try {
      String? data;
      if (Common.signData) {
        String? code = con.subConCode;
        if (con.isMain == true) {
          code = "0000";
        }
        String key = "${con.exCode},${String.fromCharCode(con.comType ?? 0)},${con.subComCode},$code";
        var map = {"Key": key};
        data = await SignData().signData(jsonEncode(map), Config.queryFs);
      }
      Response response = await MdHttpUtils.getInstance().post(Config.queryFs, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        List<OHLCEntity> oHLCEntity = [];
        List<dynamic> list = response.data["data"] ?? [];
        for (var element in list) {
          OHLCEntity tmp = OHLCEntity.fromJson(element);
          String strTime = "${tmp.date} ${tmp.time}";
          int timeStamp = Utils.getTimeStamp10(strTime);
          tmp.timeStamp = timeStamp;
          oHLCEntity.add(tmp);
        }
        if (oHLCEntity.isNotEmpty) {
          oHLCEntity.sort((lhs, rhs) {
            if (lhs.timeStamp == null) {
              return 1;
            }
            if (rhs.timeStamp == null) {
              return -1;
            }
            if (lhs.timeStamp == rhs.timeStamp) {
              return 0;
            } else {
              return lhs.timeStamp! > rhs.timeStamp! ? 1 : -1;
            }
          });

          for (int i = 0; i < oHLCEntity.length; i++) {
            num? average = 0;
            if (i == 0) {
              average = oHLCEntity[i].close;
            } else {
              double price = 0;
              for (int j = 0; j <= i; j++) {
                price = price + oHLCEntity[j].close!;
              }
              average = price / (i + 1);
            }
            oHLCEntity[i].average = average;
          }
        }
        return oHLCEntity;
      } else {
        InfoBarUtils.showErrorBar(response.data["msg"]);
      }
    } on DioException {
      rethrow;
    }
    return null;
  }
}
