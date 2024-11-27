///成交记录
class ResComOrder {
  String? CommodityNo;
  int? CommodityType;
  String? ContractName;
  String? ContractNo;
  String? FeeCurrency;
  double? FeeValue;
  String? MatchNo;
  double? MatchPrice;
  int? MatchQty;
  int? MatchSide;
  String? MatchTime;
  String? OrderId;
  int? PositionEffect;
  double? CommodityTickSize; //合约跳价

  ResComOrder({
    this.CommodityNo,
    this.CommodityType,
    this.ContractName,
    this.ContractNo,
    this.FeeCurrency,
    this.FeeValue,
    this.MatchNo,
    this.MatchPrice,
    this.MatchQty,
    this.MatchSide,
    this.MatchTime,
    this.OrderId,
    this.PositionEffect,
    this.CommodityTickSize,
  });

  ResComOrder.fromJson(Map<String, dynamic> json) {
    CommodityNo = json['CommodityNo'];
    CommodityType = json['CommodityType'];
    ContractName = json['ContractName'];
    ContractNo = json['ContractNo'];
    FeeCurrency = json['FeeCurrency'];
    FeeValue = json['FeeValue']?.toDouble();
    MatchNo = json['MatchNo'];
    MatchPrice = json['MatchPrice']?.toDouble();
    MatchQty = json['MatchQty'];
    MatchSide = json['MatchSide'];
    MatchTime = json['MatchTime'];
    OrderId = json['OrderId'];
    PositionEffect = json['PositionEffect'];
    CommodityTickSize = json['CommodityTickSize']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'CommodityNo': CommodityNo,
      'CommodityType': CommodityType,
      'ContractName': ContractName,
      'ContractNo': ContractNo,
      'FeeCurrency': FeeCurrency,
      'FeeValue': FeeValue,
      'MatchNo': MatchNo,
      'MatchPrice': MatchPrice,
      'MatchQty': MatchQty,
      'MatchSide': MatchSide,
      'MatchTime': MatchTime,
      'OrderId': OrderId,
      'PositionEffect': PositionEffect,
      'CommodityTickSize': CommodityTickSize,
    };
  }
}
