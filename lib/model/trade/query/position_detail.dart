class PositionDetail {
  String? PositionNo;
  String? ExchangeNo;
  String? CommodityNo;
  String? ContractNo;
  String? TradeCurrency;
  num? MatchSide;
  num? PositionEffect;
  num? Yesterday;
  num? PositionPrice;
  num? PositionQty;
  num? Today;
  num? PositionProfit;
  String? CreateTime;
  bool selected = false;

  PositionDetail(
      {this.PositionNo,
      this.ExchangeNo,
      this.CommodityNo,
      this.ContractNo,
      this.TradeCurrency,
      this.MatchSide,
      this.PositionEffect,
      this.Yesterday,
      this.PositionPrice,
      this.PositionQty,
      this.Today,
      this.PositionProfit,
      this.CreateTime});

  PositionDetail.fromJson(Map<String, dynamic> json) {
    PositionNo = json['PositionNo'];
    ExchangeNo = json['ExchangeNo'];
    CommodityNo = json['CommodityNo'];
    ContractNo = json['ContractNo'];
    TradeCurrency = json['TradeCurrency'];
    MatchSide = json['MatchSide'];
    PositionEffect = json['PositionEffect'];
    Yesterday = json['Yesterday'];
    PositionPrice = json['PositionPrice'];
    PositionQty = json['PositionQty'];
    Today = json['Today'];
    PositionProfit = json['PositionProfit'];
    CreateTime = json['CreateTime'];
  }
}
