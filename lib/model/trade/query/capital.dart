class Capital {
  num? TermEnd;
  num? TermInitial;
  num? Equity;
  num? Available1;
  num? OccupyDeposit;
  num? CashValue;
  num? Fee;
  num? CloseProfit;
  num? PositionFloat;
  String? Currency;
  bool selected = false;

  Capital(
      {this.TermEnd,
      this.TermInitial,
      this.Equity,
      this.Available1,
      this.OccupyDeposit,
      this.CashValue,
      this.Fee,
      this.CloseProfit,
      this.PositionFloat,
      this.Currency});

  Capital.fromJson(Map<String, dynamic> json) {
    TermEnd = json['TermEnd'];
    TermInitial = json['TermInitial'];
    Equity = json['Equity'];
    Available1 = json['Available1'];
    OccupyDeposit = json['OccupyDeposit'];
    CashValue = json['CashValue'];
    Fee = json['Fee'];
    CloseProfit = json['CloseProfit'];
    PositionFloat = json['PositionFloat'];
    Currency = json['Currency'];
  }
}
