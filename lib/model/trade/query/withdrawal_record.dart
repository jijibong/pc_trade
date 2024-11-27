class WithdrawalRecord {
  String? AccountName;
  String? Currency;
  num? CashMoney;
  Operation? operation;
  String? Id;
  String? Remarks;
  String? Time;
  bool selected = false;

  WithdrawalRecord({this.AccountName, this.Currency, this.CashMoney, this.operation, this.Id, this.Remarks, this.Time});

  WithdrawalRecord.fromJson(Map<String, dynamic> json) {
    AccountName = json['AccountName'];
    Currency = json['Currency'];
    CashMoney = json['CashMoney'];
    if (json['Operation'] != null) operation = Operation.fromJson(json['Operation']);
    Id = json['Id'];
    Remarks = json['Remarks'];
    Time = json['Time'];
  }
}

class Operation {
  num? Id;
  String? Name;

  Operation(this.Id, this.Name);

  Operation.fromJson(Map<String, dynamic> json) {
    Id = json['Id'];
    Name = json['Name'];
  }
}
