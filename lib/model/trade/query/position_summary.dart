class PositionSummary {
  String? Account;
  String? ExchangeCode;
  String? ContractCode;
  num? BuyPositionQty;
  num? BuyAverage;
  num? SellPositionQty;
  num? SellAverage;
  num? Yesterday;
  num? PositionProfit;
  num? MarginValue;
  bool selected = false;

  PositionSummary(
      {this.Account,
      this.ExchangeCode,
      this.ContractCode,
      this.BuyPositionQty,
      this.BuyAverage,
      this.SellPositionQty,
      this.SellAverage,
      this.Yesterday,
      this.PositionProfit,
      this.MarginValue});

  PositionSummary.fromJson(Map<String, dynamic> json) {
    Account = json['Account'];
    ExchangeCode = json['ExchangeCode'];
    ContractCode = json['ContractCode'];
    BuyPositionQty = json['BuyPositionQty'];
    BuyAverage = json['BuyAverage'];
    SellPositionQty = json['SellPositionQty'];
    SellAverage = json['SellAverage'];
    Yesterday = json['Yesterday'];
    PositionProfit = json['PositionProfit'];
    MarginValue = json['MarginValue'];
  }
}
