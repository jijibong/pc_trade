class TransactionRecord {
  String? Account;
  String? OrderNo;
  String? MatchNo;
  String? ExchangeNo;
  String? CommodityNo;
  String? ContractNo;
  String? FeeCurrency;
  String? MAccount;
  num? MatchSide;
  num? PositionEffect;
  num? MatchPrice;
  num? MatchQty;
  num? FeeValue;
  num? BasicsFeeValue;
  num? CloseProfit;
  String? CreateTime;
  String? MatchTime;
  bool selected = false;

  TransactionRecord(
      {this.Account,
      this.OrderNo,
      this.MatchNo,
      this.ExchangeNo,
      this.CommodityNo,
      this.ContractNo,
      this.FeeCurrency,
      this.MAccount,
      this.MatchSide,
      this.PositionEffect,
      this.MatchPrice,
      this.MatchQty,
      this.FeeValue,
      this.BasicsFeeValue,
      this.CloseProfit,
      this.MatchTime,
      this.CreateTime});

  TransactionRecord.fromJson(Map<String, dynamic> json) {
    Account = json['Account'];
    OrderNo = json['OrderNo'];
    MatchNo = json['MatchNo'];
    ExchangeNo = json['ExchangeNo'];
    CommodityNo = json['CommodityNo'];
    ContractNo = json['ContractNo'];
    FeeCurrency = json['FeeCurrency'];
    MAccount = json['MAccount'];
    MatchSide = json['MatchSide'];
    PositionEffect = json['PositionEffect'];
    MatchPrice = json['MatchPrice'];
    MatchQty = json['MatchQty'];
    FeeValue = json['FeeValue'];
    BasicsFeeValue = json['BasicsFeeValue'];
    CloseProfit = json['CloseProfit'];
    MatchTime = json['MatchTime'];
    CreateTime = json['CreateTime'];
  }
}
