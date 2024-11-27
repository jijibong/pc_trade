class CloseDetail {
  String? ExchangeNo;
  String? CommodityNo;
  String? ContractNo;
  String? TradeCurrency;
  num? PositionAvgPrice;
  num? ClosePrice;
  num? CloseQty;
  num? CloseSide;
  num? CloseProfit;
  num? Yesterday;
  String? CloseMatchTime;
  String? Account;
  bool selected = false;

  CloseDetail(
      {this.ExchangeNo,
        this.CommodityNo,
        this.ContractNo,
        this.TradeCurrency,
        this.PositionAvgPrice,
        this.ClosePrice,
        this.CloseQty,
        this.CloseSide,
        this.CloseProfit,
        this.Yesterday,
        this.CloseMatchTime,
        this.Account});

  CloseDetail.fromJson(Map<String, dynamic> json) {
    ExchangeNo = json['ExchangeNo'];
    CommodityNo = json['CommodityNo'];
    ContractNo = json['ContractNo'];
    TradeCurrency = json['TradeCurrency'];
    PositionAvgPrice = json['PositionAvgPrice'];
    ClosePrice = json['ClosePrice'];
    CloseQty = json['CloseQty'];
    CloseSide = json['CloseSide'];
    CloseProfit = json['CloseProfit'];
    Yesterday = json['Yesterday'];
    CloseMatchTime = json['CloseMatchTime'];
    Account = json['Account'];
  }
}
