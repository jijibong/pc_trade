import 'dart:convert';

import 'package:trade/util/utils/utils.dart';

import '../../model/option/option.dart';
import '../../model/quote/commodity.dart';
import '../../model/quote/contract.dart';
import '../shared_preferences/shared_preferences_key.dart';
import '../shared_preferences/shared_preferences_utils.dart';

class MarketUtils {
  /// 实时行情Map
  static Map<String, Contract> varietyMap = {};
  static Map<String, List<Contract>> quoteListMap = {};
  static List<Contract> contractList = [];
  static List<Contract> optionList = [];
  static List<Commodity> commodityList = [];

  /// 保存实时数据
  static void setDataList(String exCode, List<Contract> list) {
    if (list.isNotEmpty) {
      quoteListMap[exCode] = list;
      for (var con in list) {
        if (con.code != null) {
          varietyMap["${con.exCode}${con.code}${con.comType}"] = con;
        }
      }
      SpUtils.set(SpKey.varietyMap, jsonEncode(varietyMap));
    }
  }

  ///保存用户自选列表
  static void setOptionList(List<Contract> list) {
    optionList.clear();
    optionList.addAll(list);
  }

  ///获取本地自选
  static Future<List<Contract>> getLocalOptions() async {
    List<Contract> list = [];
    String? optionString = await SpUtils.getString(SpKey.option);
    if (optionString != null && optionString != "") {
      List optionList = jsonDecode(optionString);
      for (var element in optionList) {
        var value = Option.fromJson(element);
        for (var e in contractList) {
          if (e.exCode == value.excd && e.code == value.scode && e.comType == value.comType) {
            e.optionId = value.id;
            e.isMain = value.isMain;
            list.add(e);
          }
        }
      }
    }
    list = [
      ...{...list}
    ];
    return list;
  }

  ///根据市场代码获取实时数据列表
  static List<Contract> getDataVarietys(String? exCode) {
    if (exCode == null) return [];
    List<Contract> list = [];
    if (quoteListMap[exCode] != null) {
      list = quoteListMap[exCode]!;
    }
    return list;
  }

  ///根据标识获取实时品种
  static Contract? getVariety(String? excd, String? code, int? comType) {
    Contract? contract;
    if (varietyMap.containsKey("$excd$code$comType")) {
      contract = varietyMap["$excd$code$comType"];
    } else {
      for (var element in contractList) {
        if (excd == element.exCode && code == element.code && comType == element.comType) {
          contract = element;
          contract.level2List = Utils.getLevel2List();
          setVariety(contract);
          break;
        }
      }
    }

    // if (contract != null) {
    //   contract.isMain = false;
    // }
    return contract;
  }

  /// 替换实时品种数据
  static void setVariety(Contract? con) {
    if (con != null && con.code != null && con.code!.isNotEmpty) {
      if (!varietyMap.containsKey("${con.exCode}${con.code}${con.comType}")) {
        varietyMap["${con.exCode}${con.code}${con.comType}"] = con;
      }
    }
  }

  /// 保存实时数据
  static void updateVariety(Contract? variety) {
    if (variety != null && variety.code != null && variety.lastPrice! > 0) {
      if (varietyMap.containsKey("${variety.exCode}${variety.code}${variety.comType}")) {
        Contract? data = varietyMap["${variety.exCode}${variety.code}${variety.comType}"];
        if (variety.lastPrice == 0) {
          variety.lastPrice = data?.lastPrice;
        } else {
          data?.lastPrice = variety.lastPrice;
        }
        if (data?.openPrice == 0 || variety.openPrice! > 0) data?.openPrice = variety.openPrice;
        if (data?.prePrice == 0 || variety.prePrice! > 0) data?.prePrice = variety.prePrice;
        if (data?.limitPrice == 0 || variety.limitPrice! > 0) data?.limitPrice = variety.limitPrice;
        if (data?.stopPrice == 0 || variety.stopPrice! > 0) data?.stopPrice = variety.stopPrice;
        if (data?.buyPrice == 0 || (variety.buyPrice != null && variety.buyPrice! > 0)) data?.buyPrice = variety.buyPrice;
        if (data?.salePrice == 0 || (variety.salePrice != null && variety.salePrice! > 0)) data?.salePrice = variety.salePrice;
        if (data?.preSettlePrice == 0 || variety.preSettlePrice! > 0) data?.preSettlePrice = variety.preSettlePrice;
        if (data?.volume == 0 || (variety.volume != null && variety.volume! > 0)) data?.volume = variety.volume;
        if (data?.position == 0 || (variety.position != null && variety.position! > 0)) data?.position = variety.position;

        data?.timeStr = variety.timeStr;

        if (data?.highPrice == 0) {
          data?.highPrice = variety.highPrice;
        } else if (variety.highPrice != 0 && variety.highPrice != data?.highPrice) {
          data?.highPrice = variety.highPrice;
        }

        if (data?.lowPrice == 0) {
          data?.lowPrice = variety.lowPrice;
        } else if (variety.lowPrice != 0 && variety.lowPrice != data?.lowPrice) {
          data?.lowPrice = variety.lowPrice;
        }

        if (data?.name == null || data?.name == "") data?.name = variety.name;

        //level2深度行情

        for (int i = 0; i < variety.level2List!.length; i++) {
          data?.setLevel2(variety.level2List![i], i);
        }
      } else {
        varietyMap["${variety.exCode}${variety.code}${variety.comType}"] = variety;
      }
    }
  }

  ///自选管理
  // static Future<bool> manageOption(Contract? con, bool add) async {
  // if (con == null) {
  //   ToastUtil.showWarningToast("合约错误");
  //   return false;
  // }
  // if (LoginServer.isLogin) {
  //   if (add) {
  //     await MarketServer.addOption(con).then((value) {
  //       if (value) {
  //         ToastUtil.showSimpleToast("${con.name}已加入自选");
  //         Utils.operateOption(con, true, UserUtils.currentUser!.id!);
  //         return true;
  //       }
  //     });
  //   } else {
  //     MarketServer.delOption([con]).then((value) {
  //       if (value != null) {
  //         ToastUtil.showSimpleToast("${con.name}已移出自选");
  //         Utils.operateOption(con, false, UserUtils.currentUser!.id!);
  //         return true;
  //       }
  //     });
  //   }
  // } else {
  //   if (add) {
  //     Utils.operateOption(con, true, 0);
  //     ToastUtil.showSimpleToast("添加自选成功");
  //     return true;
  //   } else {
  //     Utils.operateOption(con, false, 0);
  //     ToastUtil.showSimpleToast("删除自选成功");
  //     return true;
  //   }
  // }
  // return false;
  // }
}
