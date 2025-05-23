class Capital {
  double? TermEnd;
  double? TermInitial;
  double? Equity;
  double? Available;
  double? OccupyDeposit;
  double? CashInValue;
  double? CashOutValue;
  double? Fee;
  double? CloseProfit;
  double? FloatProfit;
  double? FrozenDeposit;
  String? Currency;
  bool selected = false;

  Capital(
      {this.TermEnd,
      this.TermInitial,
      this.Equity,
      this.Available,
      this.OccupyDeposit,
      this.CashInValue,
      this.CashOutValue,
      this.Fee,
      this.CloseProfit,
      this.FloatProfit,
      this.FrozenDeposit,
      this.Currency});

  Capital.fromJson(Map<String, dynamic> json) {
    TermEnd = json['TermEnd']?.toDouble();
    TermInitial = json['TermInitial']?.toDouble();
    Equity = json['Equity']?.toDouble();
    Available = json['Available']?.toDouble();
    OccupyDeposit = json['OccupyDeposit']?.toDouble();
    CashInValue = json['CashInValue']?.toDouble();
    CashOutValue = json['CashOutValue']?.toDouble();
    Fee = json['Fee']?.toDouble();
    CloseProfit = json['CloseProfit']?.toDouble();
    FloatProfit = json['FloatProfit']?.toDouble();
    FrozenDeposit = json['FrozenDeposit']?.toDouble();
    Currency = json['Currency'];
  }
}
