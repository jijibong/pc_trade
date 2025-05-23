class TransactionRecord {
  String? ExchangeNo;
  String? ClientOrderId;
  int? CommodityType;
  String? CommodityNo;
  String? ContractNo;
  String? ContractName;
  String? MatchNo;
  String? OrderId;
  double? MatchPrice;
  int? MatchQty;
  int? MatchSide;
  int? PositionEffect;
  String? MatchTime;
  String? FeeCurrency;
  double? FeeValue;
  String? CreateTime;
  double? CommodityTickSize;
  bool selected = false;

  TransactionRecord(
      {this.ExchangeNo,
      this.ClientOrderId,
      this.MatchNo,
      this.OrderId,
      this.CommodityType,
      this.CommodityNo,
      this.ContractNo,
      this.FeeCurrency,
      this.ContractName,
      this.MatchSide,
      this.PositionEffect,
      this.MatchPrice,
      this.MatchQty,
      this.FeeValue,
      this.CommodityTickSize,
      this.MatchTime,
      this.CreateTime});

  TransactionRecord.fromJson(Map<String, dynamic> json) {
    ClientOrderId = json['ClientOrderId'];
    OrderId = json['OrderId'];
    MatchNo = json['MatchNo'];
    ExchangeNo = json['ExchangeNo'];
    CommodityNo = json['CommodityNo'];
    ContractNo = json['ContractNo'];
    FeeCurrency = json['FeeCurrency'];
    ContractName = json['ContractName'];
    MatchSide = json['MatchSide']?.toInt();
    PositionEffect = json['PositionEffect']?.toInt();
    MatchPrice = json['MatchPrice']?.toDouble();
    MatchQty = json['MatchQty']?.toInt();
    FeeValue = json['FeeValue']?.toDouble();
    CommodityTickSize = json['CommodityTickSize']?.toDouble();
    CommodityType = json['CloseProfit']?.toInt();
    MatchTime = json['MatchTime'];
    CreateTime = json['CreateTime'];
  }
}
