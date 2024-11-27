class ResHoldOrder {
  String? CommodityNo;
  int? CommodityType;
  String? ContractName;
  String? ContractNo;
  double? ContractSize;
  String? CreateTime;
  String? ExchangeNo;
  double? MarginValue;
  int? MatchSide;
  int? PositionEffect;
  int? PositionType;
  double? PositionPrice;
  double? PositionProfit;
  double? CalculatePrice;
  int? PositionQty;
  int? AvailableQty;
  String? TradeCurrency;
  String? PositionNo;
  double? CommodityTickSize;
  String? ContractCode;
  String? TradeTime;

  ResHoldOrder({
    this.CommodityNo,
    this.CommodityType,
    this.ContractName,
    this.ContractNo,
    this.ContractSize,
    this.CreateTime,
    this.ExchangeNo,
    this.MarginValue,
    this.MatchSide,
    this.PositionEffect,
    this.PositionType,
    this.PositionPrice,
    this.PositionProfit,
    this.CalculatePrice,
    this.PositionQty,
    this.AvailableQty,
    this.TradeCurrency,
    this.PositionNo,
    this.CommodityTickSize,
    this.ContractCode,
    this.TradeTime,
  });

  ResHoldOrder.fromJson(Map<String, dynamic> json) {
    CommodityNo = json['CommodityNo'];
    CommodityType = json['CommodityType'];
    ContractName = json['ContractName'];
    ContractNo = json['ContractNo'];
    ContractSize = json['ContractSize']?.toDouble();
    CreateTime = json['CreateTime'];
    ExchangeNo = json['ExchangeNo'];
    MarginValue = json['MarginValue']?.toDouble();
    MatchSide = json['MatchSide'];
    PositionEffect = json['PositionEffect'];
    PositionType = json['PositionType'];
    PositionPrice = json['PositionPrice']?.toDouble();
    PositionProfit = json['PositionProfit']?.toDouble();
    CalculatePrice = json['CalculatePrice']?.toDouble();
    PositionQty = json['PositionQty'];
    AvailableQty = json['AvailableQty'];
    TradeCurrency = json['TradeCurrency'];
    PositionNo = json['PositionNo'];
    CommodityTickSize = json['CommodityTickSize']?.toDouble();
    ContractCode = json['ContractCode'];
    TradeTime = json['TradeTime'];
  }

  Map<String, dynamic> toJson() {
    return {
      'CommodityNo': CommodityNo,
      'CommodityType': CommodityType,
      'ContractName': ContractName,
      'ContractNo': ContractNo,
      'ContractSize': ContractSize,
      'CreateTime': CreateTime,
      'ExchangeNo': ExchangeNo,
      'MarginValue': MarginValue,
      'MatchSide': MatchSide,
      'PositionEffect': PositionEffect,
      'PositionType': PositionType,
      'PositionPrice': PositionPrice,
      'PositionProfit': PositionProfit,
      'CalculatePrice': CalculatePrice,
      'PositionQty': PositionQty,
      'AvailableQty': AvailableQty,
      'TradeCurrency': TradeCurrency,
      'PositionNo': PositionNo,
      'CommodityTickSize': CommodityTickSize,
      'ContractCode': ContractCode,
      'TradeTime': TradeTime,
    };
  }
}
