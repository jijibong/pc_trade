/**
 *@Descrption 合约初始保证金
 */
class ResInitMargin {
  FeeBean? Fee;
  MarginBean? Margin;

  ResInitMargin(this.Fee, this.Margin);

  ResInitMargin.fromJson(Map<String, dynamic> json) {
    if (json['Fee'] != null) Fee = FeeBean.fromJson(json['Fee']);
    if (json['Margin'] != null) Margin = MarginBean.fromJson(json['Margin']);
  }

  Map<String, dynamic> toJson() {
    return {
      'Fee': Fee,
      'Margin': Margin,
    };
  }
}

class FeeBean {
  int? Id;
  String? ExchangeCode;
  int? CommodityType;
  String? CommodityNo;
  String? ContractNo;
  String? ContractCode;
  int? Type;
  double? OpenFundRatio;
  double? OpenHand;
  double? CloseFundRatio;
  double? CloseHand;
  double? FeeValue;
  int? FeeType;
  String? Time;

  FeeBean(
    this.Id,
    this.ExchangeCode,
    this.CommodityType,
    this.CommodityNo,
    this.ContractNo,
    this.ContractCode,
    this.Type,
    this.OpenFundRatio,
    this.OpenHand,
    this.CloseFundRatio,
    this.CloseHand,
    this.FeeValue,
    this.FeeType,
    this.Time,
  );

  FeeBean.fromJson(Map<String, dynamic> json) {
    Id = json['Id'];
    ExchangeCode = json['ExchangeCode'];
    CommodityType = json['CommodityType'];
    CommodityNo = json['CommodityNo'];
    ContractNo = json['ContractNo'];
    ContractCode = json['ContractCode'];
    Type = json['Type'];
    OpenFundRatio = json['OpenFundRatio']?.toDouble();
    OpenHand = json['OpenHand']?.toDouble();
    CloseFundRatio = json['CloseFundRatio']?.toDouble();
    CloseHand = json['CloseHand']?.toDouble();
    FeeValue = json['FeeValue']?.toDouble();
    FeeType = json['FeeType'];
    Time = json['Time'];
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'ExchangeCode': ExchangeCode,
      'CommodityType': CommodityType,
      'CommodityNo': CommodityNo,
      'ContractNo': ContractNo,
      'ContractCode': ContractCode,
      'Type': Type,
      'OpenFundRatio': OpenFundRatio,
      'OpenHand': OpenHand,
      'CloseFundRatio': CloseFundRatio,
      'CloseHand': CloseHand,
      'FeeValue': FeeValue,
      'FeeType': FeeType,
      'Time': Time,
    };
  }
}

class MarginBean {
  int? Id;
  String? ExchangeCode;
  int? CommodityType;
  String? CommodityNo;
  String? ContractNo;
  String? ContractCode;
  String? Currency;
  int? Type;
  double? MarginValue;
  int? MarginType;
  double? BuyFundRatio;
  double? BuyHand;
  double? SellFundRatio;
  double? SellHand;
  String? Time;

  MarginBean(
    this.Id,
    this.ExchangeCode,
    this.CommodityType,
    this.CommodityNo,
    this.ContractNo,
    this.ContractCode,
    this.Currency,
    this.Type,
    this.MarginValue,
    this.MarginType,
    this.BuyFundRatio,
    this.BuyHand,
    this.SellFundRatio,
    this.SellHand,
    this.Time,
  );

  MarginBean.fromJson(Map<String, dynamic> json) {
    Id = json['Id'];
    ExchangeCode = json['ExchangeCode'];
    CommodityType = json['CommodityType'];
    CommodityNo = json['CommodityNo'];
    ContractNo = json['ContractNo'];
    ContractCode = json['ContractCode'];
    Currency = json['Currency'];
    Type = json['Type'];
    MarginValue = json['MarginValue']?.toDouble();
    MarginType = json['MarginType'];
    BuyFundRatio = json['BuyFundRatio']?.toDouble();
    BuyHand = json['BuyHand']?.toDouble();
    SellFundRatio = json['SellFundRatio']?.toDouble();
    SellHand = json['SellHand']?.toDouble();
    Time = json['Time'];
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'ExchangeCode': ExchangeCode,
      'CommodityType': CommodityType,
      'CommodityNo': CommodityNo,
      'ContractNo': ContractNo,
      'ContractCode': ContractCode,
      'Currency': Currency,
      'Type': Type,
      'MarginValue': MarginValue,
      'MarginType': MarginType,
      'BuyFundRatio': BuyFundRatio,
      'BuyHand': BuyHand,
      'SellFundRatio': SellFundRatio,
      'SellHand': SellHand,
      'Time': Time,
    };
  }
}
