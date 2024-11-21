import 'contract.dart';

class Exchange {
  // bool? isSelect;
  num? editStatus;
  num? tabType;
  num? id;
  String? exchangeNo;
  String? exchangeName;
  String? updateTime;
  num? updataStatus;
  num? orderNum;
  num? orderUser;
  num? marketPriceTrade;
  List<Contract>? contracts = [];

  Exchange({
    this.editStatus,
    this.tabType,
    this.id,
    this.exchangeNo,
    this.exchangeName,
    this.updateTime,
    this.updataStatus,
    this.orderNum,
    this.orderUser,
    this.marketPriceTrade,
  });

  Exchange.fromJson(Map<String, dynamic> json) {
    editStatus = json['editStatus'];
    tabType = json['tabType'];
    id = json['Id'];
    exchangeNo = json['ExchangeNo'];
    exchangeName = json['ExchangeName'];
    updateTime = json['UpdateTime'];
    updataStatus = json['UpdataStatus'];
    orderNum = json['OrderNum'];
    orderUser = json['OrderUser'];
    marketPriceTrade = json['MarketPriceTrade'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['editStatus'] = editStatus;
    data['tabType'] = tabType;
    data['Id'] = id;
    data['ExchangeNo'] = exchangeNo;
    data['ExchangeName'] = exchangeName;
    data['UpdateTime'] = updateTime;
    data['UpdataStatus'] = updataStatus;
    data['OrderNum'] = orderNum;
    data['OrderUser'] = orderUser;
    data['MarketPriceTrade'] = marketPriceTrade;
    return data;
  }
}
