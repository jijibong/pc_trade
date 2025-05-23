class WithdrawalRecord {
  String? AccountName;
  String? Currency;
  double? CashInValue;
  double? CashOutValue;
  Operation? operation;
  String? Id;
  String? Remarks;
  String? CreateTime;
  bool selected = false;

  WithdrawalRecord({this.AccountName, this.Currency, this.CashInValue, this.CashOutValue, this.operation, this.Id, this.Remarks, this.CreateTime});

  WithdrawalRecord.fromJson(Map<String, dynamic> json) {
    AccountName = json['AccountName'];
    Currency = json['Currency'];
    CashInValue = json['CashInValue']?.toDouble();
    CashOutValue = json['CashOutValue']?.toDouble();
    if (json['Operation'] != null) operation = Operation.fromJson(json['Operation']);
    Id = json['Id'];
    Remarks = json['Remarks'];
    CreateTime = json['CreateTime'];
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
