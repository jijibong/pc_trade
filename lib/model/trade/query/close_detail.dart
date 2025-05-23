class CloseDetail {
  String? ExchangeNo;
  int? CommodityType;
  String? CommodityNo;
  String? ContractNo;
  String? ContractName;
  String? TradeCurrency;
  double? PositionAvgPrice;
  double? ClosePrice;
  int? CloseQty;
  int? CloseSide;
  double? CloseProfit;
  int? PositionEffect;
  String? CloseMatchTime;
  String? CreateTime;
  double? CommodityTickSize;
  bool selected = false;

  CloseDetail(
      {this.ExchangeNo,
      this.CommodityType,
      this.CommodityNo,
      this.ContractNo,
      this.ContractName,
      this.TradeCurrency,
      this.PositionAvgPrice,
      this.ClosePrice,
      this.CloseQty,
      this.CloseSide,
      this.CloseProfit,
      this.PositionEffect,
      this.CloseMatchTime,
      this.CreateTime,
      this.CommodityTickSize});

  CloseDetail.fromJson(Map<String, dynamic> json) {
    ExchangeNo = json['ExchangeNo'];
    CommodityType = json['CommodityType']?.toInt();
    CommodityNo = json['CommodityNo'];
    ContractNo = json['ContractNo'];
    ContractName = json['ContractName'];
    TradeCurrency = json['TradeCurrency'];
    PositionAvgPrice = json['PositionAvgPrice']?.toDouble();
    ClosePrice = json['ClosePrice']?.toDouble();
    CloseQty = json['CloseQty']?.toInt();
    CloseSide = json['CloseSide']?.toInt();
    CloseProfit = json['CloseProfit']?.toDouble();
    PositionEffect = json['PositionEffect']?.toInt();
    CreateTime = json['CreateTime'];
    CloseMatchTime = json['CloseMatchTime'];
    CommodityTickSize = json['CommodityTickSize']?.toDouble();
  }
}
