import 'dart:ui';
import 'package:trade/model/trade/res_hold_order.dart';

import '../k/OHLCEntity.dart';

class HoldOrder {
  String? name;
  String? code;
  String? SecurityDesc;
  int? ContractID;
  String? exCode;
  String? CurrencyType;
  int? orderSide;
  int? openClose;
  int? quantity;
  int? AvailableQty;
  double? open;
  double? margin;
  double? floatProfit;
  double? stopProfit;
  double? stopLoss;
  double? FutureContractSize;
  double? FutureTickSize;
  int? bgColor;
  int? LMESettleDate;
  int? Mode;
  double? LossPriceTicks;
  double? ProfitPriceTicks;
  double? FloatLoss;
  double? CalculatePrice;
  int? PLQuantity;
  int? TimeInForce;
  int? TPosition; //今仓数量
  int? YPosition; //昨仓数量
  int? comType; //品种类型
  int? orderType; //订单类型
  String? subComCode; //订阅用品种代码
  String? subConCode; //订阅用合约代码
  String? ExpireTime; //有效日期
  String? PositionNo;
  double? quote_lastPrice;
  double? quote_change;
  double? quote_changePer;
  double? quote_buyPrice;
  double? quote_salePrice;
  double? quote_highPrice;
  double? quote_lowPrice;
  int? quote_buyNum;
  int? quote_saleNum;
  int? quote_volume;
  List<OHLCEntity>? fsList;
  List<ResHoldOrder>? detailList;
  Map<String, String>? noMap;
  Color? color;
  bool selected = false;

  HoldOrder({
    this.name,
    this.code,
    this.SecurityDesc,
    this.ContractID,
    this.exCode,
    this.CurrencyType,
    this.orderSide,
    this.openClose,
    this.quantity,
    this.AvailableQty,
    this.open,
    this.margin,
    this.floatProfit,
    this.stopProfit,
    this.stopLoss,
    this.FutureContractSize,
    this.FutureTickSize,
    this.bgColor,
    this.LMESettleDate,
    this.Mode,
    this.LossPriceTicks,
    this.ProfitPriceTicks,
    this.FloatLoss,
    this.CalculatePrice,
    this.PLQuantity,
    this.TimeInForce,
    this.TPosition,
    this.YPosition,
    this.comType,
    this.orderType,
    this.subComCode,
    this.subConCode,
    this.ExpireTime,
    this.PositionNo,
    this.quote_lastPrice,
    this.quote_change,
    this.quote_changePer,
    this.quote_buyPrice,
    this.quote_salePrice,
    this.quote_highPrice,
    this.quote_lowPrice,
    this.quote_buyNum,
    this.quote_saleNum,
    this.quote_volume,
    this.fsList,
    this.detailList,
    this.noMap,
  });

  HoldOrder.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    SecurityDesc = json['SecurityDesc'];
    ContractID = json['ContractID'];
    exCode = json['exCode'];
    CurrencyType = json['CurrencyType'];
    orderSide = json['orderSide'];
    openClose = json['openClose'];
    quantity = json['quantity'];
    AvailableQty = json['AvailableQty'];
    open = json['open'];
    margin = json['margin'];
    floatProfit = json['floatProfit'];
    stopProfit = json['stopProfit'];
    stopLoss = json['stopLoss'];
    FutureContractSize = json['FutureContractSize'];
    FutureTickSize = json['FutureTickSize'];
    bgColor = json['bgColor'];
    LMESettleDate = json['LMESettleDate'];
    Mode = json['Mode'];
    LossPriceTicks = json['LossPriceTicks'];
    ProfitPriceTicks = json['ProfitPriceTicks'];
    FloatLoss = json['FloatLoss'];
    CalculatePrice = json['CalculatePrice'];
    PLQuantity = json['PLQuantity'];
    TimeInForce = json['TimeInForce'];
    TPosition = json['TPosition'];
    YPosition = json['YPosition'];
    comType = json['comType'];
    orderType = json['orderType'];
    subComCode = json['subComCode'];
    subConCode = json['subConCode'];
    ExpireTime = json['ExpireTime'];
    PositionNo = json['PositionNo'];
    quote_lastPrice = json['quote_lastPrice'];
    quote_change = json['quote_change'];
    quote_changePer = json['quote_changePer'];
    quote_buyPrice = json['quote_buyPrice'];
    quote_salePrice = json['quote_salePrice'];
    quote_highPrice = json['quote_highPrice'];
    quote_lowPrice = json['quote_lowPrice'];
    quote_buyNum = json['quote_buyNum'];
    quote_saleNum = json['quote_saleNum'];
    quote_volume = json['quote_volume'];
    fsList = json['fsList'] != null ? (json['fsList'] as List).map((e) => OHLCEntity.fromJson(e)).toList() : [];
    detailList = json['detailList'] != null ? (json['detailList'] as List).map((e) => ResHoldOrder.fromJson(e)).toList() : [];
    noMap = json['noMap'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'SecurityDesc': SecurityDesc,
      'ContractID': ContractID,
      'exCode': exCode,
      'CurrencyType': CurrencyType,
      'orderSide': orderSide,
      'openClose': openClose,
      'quantity': quantity,
      'AvailableQty': AvailableQty,
      'open': open,
      'margin': margin,
      'floatProfit': floatProfit,
      'stopProfit': stopProfit,
      'stopLoss': stopLoss,
      'FutureContractSize': FutureContractSize,
      'FutureTickSize': FutureTickSize,
      'bgColor': bgColor,
      'LMESettleDate': LMESettleDate,
      'Mode': Mode,
      'LossPriceTicks': LossPriceTicks,
      'ProfitPriceTicks': ProfitPriceTicks,
      'FloatLoss': FloatLoss,
      'PLQuantity': PLQuantity,
      'TimeInForce': TimeInForce,
      'TPosition': TPosition,
      'YPosition': YPosition,
      'comType': comType,
      'orderType': orderType,
      'subComCode': subComCode,
      'subConCode': subConCode,
      'ExpireTime': ExpireTime,
      'PositionNo': PositionNo,
      'quote_lastPrice': quote_lastPrice,
      'quote_change': quote_change,
      'quote_changePer': quote_changePer,
      'quote_buyPrice': quote_buyPrice,
      'quote_salePrice': quote_salePrice,
      'quote_highPrice': quote_highPrice,
      'quote_lowPrice': quote_lowPrice,
      'quote_buyNum': quote_buyNum,
      'quote_saleNum': quote_saleNum,
      'quote_volume': quote_volume,
      'fsList': fsList != null ? fsList?.map((e) => e.toJson()).toList() : [],
      'detailList': detailList != null ? detailList?.map((e) => e.toJson()).toList() : [],
      'noMap': noMap,
    };
  }
}
