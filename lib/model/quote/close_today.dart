class ComCloseToday {
  num? id;
  num? exchangeId;
  String? exchangeNo;
  num? commodityType;
  String? commodityNo;
  String? commodityName;
  String? shortName;
  String? commodityEngName;
  String? tradeCurrency;
  num? contractSize;
  num? openCloseMode;
  num? strikePriceTimes;
  num? commodityTickSize;
  String? tradeTime;
  num? mfContract;
  num? orderNum;
  String? updateTime;
  num? updataStatus;
  bool? select = true;

  ComCloseToday({
    this.id,
    this.exchangeId,
    this.exchangeNo,
    this.commodityType,
    this.commodityNo,
    this.commodityName,
    this.shortName,
    this.commodityEngName,
    this.tradeCurrency,
    this.contractSize,
    this.openCloseMode,
    this.strikePriceTimes,
    this.commodityTickSize,
    this.tradeTime,
    this.mfContract,
    this.orderNum,
    this.updateTime,
    this.updataStatus,
    this.select,
  });

  ComCloseToday.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    exchangeId = json['Exchange_id'];
    exchangeNo = json['ExchangeNo'];
    commodityType = json['CommodityType'];
    commodityNo = json['CommodityNo'];
    commodityName = json['CommodityName'];
    shortName = json['ShortName'];
    commodityEngName = json['CommodityEngName'];
    tradeCurrency = json['TradeCurrency'];
    contractSize = json['ContractSize'];
    openCloseMode = json['OpenCloseMode'];
    strikePriceTimes = json['StrikePriceTimes'];
    commodityTickSize = json['CommodityTickSize'];
    tradeTime = json['TradeTime'];
    mfContract = json['MfContract'];
    orderNum = json['OrderNum'];
    updateTime = json['UpdateTime'];
    updataStatus = json['UpdataStatus'];
    select = json['select'];
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Exchange_id': exchangeId,
      'ExchangeNo': exchangeNo,
      'CommodityType': commodityType,
      'CommodityNo': commodityNo,
      'CommodityName': commodityName,
      'ShortName': shortName,
      'CommodityEngName': commodityEngName,
      'TradeCurrency': tradeCurrency,
      'ContractSize': contractSize,
      'OpenCloseMode': openCloseMode,
      'StrikePriceTimes': strikePriceTimes,
      'CommodityTickSize': commodityTickSize,
      'TradeTime': tradeTime,
      'MfContract': mfContract,
      'OrderNum': orderNum,
      'UpdateTime': updateTime,
      'UpdataStatus': updataStatus,
      'select': select,
    };
  }
}
