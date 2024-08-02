class ResFund {
  /**
   * Cname : 基币
   * Currency : JB
   * PreBalance : 0
   * PreEquity : 0
   * PreAvailable1 : 0
   * FrozenFee : 279
   * FrozenDeposit : 62580
   * Fee : 360
   * OccupyDeposit : 97132
   * TermInitial : 99999999
   * CashInValue : 0
   * CashOutValue : 0
   * CloseProfit : 0
   * Balance : 99999639
   * Equity : 99999639
   * Available : 99839927
   */
  String? Cname;
  String? Currency;
  double? PreBalance;
  double? PreEquity;
  double? PreAvailable1;
  double? FrozenFee;
  double? FrozenDeposit;
  double? Fee;
  double? OccupyDeposit;
  double? TermInitial;
  double? CashInValue;
  double? CashOutValue;
  double? CloseProfit;
  double? Balance;
  double? Equity;
  double? Available;
  double? FloatProfit;

  ResFund({
    this.Cname,
    this.Currency,
    this.PreBalance,
    this.PreEquity,
    this.PreAvailable1,
    this.FrozenFee,
    this.FrozenDeposit,
    this.Fee,
    this.OccupyDeposit,
    this.TermInitial,
    this.CashInValue,
    this.CashOutValue,
    this.CloseProfit,
    this.Balance,
    this.Equity,
    this.Available,
    this.FloatProfit,
  });

  ResFund.fromJson(Map<String, dynamic> json) {
    Cname = json['Cname'];
    Currency = json['Currency'];
    PreBalance = json['PreBalance']?.toDouble();
    PreEquity = json['PreEquity']?.toDouble();
    PreAvailable1 = json['PreAvailable1']?.toDouble();
    FrozenFee = json['FrozenFee']?.toDouble();
    FrozenDeposit = json['FrozenDeposit']?.toDouble();
    Fee = json['Fee']?.toDouble();
    OccupyDeposit = json['OccupyDeposit']?.toDouble();
    TermInitial = json['TermInitial']?.toDouble();
    CashInValue = json['CashInValue']?.toDouble();
    CashOutValue = json['CashOutValue']?.toDouble();
    CloseProfit = json['CloseProfit']?.toDouble();
    Balance = json['Balance']?.toDouble();
    Equity = json['Equity']?.toDouble();
    Available = json['Available']?.toDouble();
    FloatProfit = json['FloatProfit']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Cname'] = Cname;
    data['Currency'] = Currency;
    data['PreBalance'] = PreBalance;
    data['PreEquity'] = PreEquity;
    data['PreAvailable1'] = PreAvailable1;
    data['FrozenFee'] = FrozenFee;
    data['FrozenDeposit'] = FrozenDeposit;
    data['Fee'] = Fee;
    data['OccupyDeposit'] = OccupyDeposit;
    data['TermInitial'] = TermInitial;
    data['CashInValue'] = CashInValue;
    data['CashOutValue'] = CashOutValue;
    data['CloseProfit'] = CloseProfit;
    data['Balance'] = Balance;
    data['Equity'] = Equity;
    data['Available'] = Available;
    data['FloatProfit'] = FloatProfit;
    return data;
  }
}
