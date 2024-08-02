class OptionServer {
  num? id;
  num? commodityId;
  String? exchangeNo;
  int? commodityType;
  String? commodityNo;
  String? commodityName;
  String? shortName;
  String? commodityEngName;
  String? tradeCurrency;
  num? contractSize;
  int? openCloseMode;
  num? strikePriceTimes;
  num? commodityTickSize;
  String? tradeTime;
  num? mfContract;
  String? updateTime;
  int? updataStatus;
  int? serialNum;
  bool? isMain;
  ContractsBean? contracts;

  OptionServer({
    this.id,
    this.commodityId,
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
    this.updateTime,
    this.updataStatus,
    this.serialNum,
    this.isMain,
    this.contracts,
  });

  OptionServer.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    commodityId = json['CommodityId'];
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
    updateTime = json['UpdateTime'];
    updataStatus = json['UpdataStatus'];
    serialNum = json['SerialNum'];
    isMain = json['IsMain'];
    contracts = ContractsBean.fromJson(json['Contracts']);
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CommodityId': commodityId,
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
      'UpdateTime': updateTime,
      'UpdataStatus': updataStatus,
      'SerialNum': serialNum,
      'IsMain': isMain,
      'Contracts': contracts?.toJson(),
    };
  }
}

class ContractsBean {
  num? commodity;
  String? contractCode;
  String? contractExpDate;
  String? contractName;
  String? shortName;
  String? contractNo;
  int? contractType;
  String? firstNoticeDate;
  num? id;
  String? lastTradeDate;
  int? trCount;
  int? updataStatus;
  String? updateTime;
  num? preClose;

  ContractsBean({
    this.commodity,
    this.contractCode,
    this.contractExpDate,
    this.contractName,
    this.shortName,
    this.contractNo,
    this.contractType,
    this.firstNoticeDate,
    this.id,
    this.lastTradeDate,
    this.trCount,
    this.updataStatus,
    this.updateTime,
    this.preClose,
  });

  ContractsBean.fromJson(Map<String, dynamic> json) {
    commodity = json['Commodity'];
    contractCode = json['ContractCode'];
    contractExpDate = json['ContractExpDate'];
    contractName = json['ContractName'];
    shortName = json['ShortName'];
    contractNo = json['ContractNo'];
    contractType = json['ContractType'];
    firstNoticeDate = json['FirstNoticeDate'];
    id = json['Id'];
    lastTradeDate = json['LastTradeDate'];
    trCount = json['TrCount'];
    updataStatus = json['UpdataStatus'];
    updateTime = json['UpdateTime'];
    preClose = json['PreClose'];
  }

  Map<String, dynamic> toJson() {
    return {
      'Commodity': commodity,
      'ContractCode': contractCode,
      'ContractExpDate': contractExpDate,
      'ContractName': contractName,
      'ShortName': shortName,
      'ContractNo': contractNo,
      'ContractType': contractType,
      'FirstNoticeDate': firstNoticeDate,
      'Id': id,
      'LastTradeDate': lastTradeDate,
      'TrCount': trCount,
      'UpdataStatus': updataStatus,
      'UpdateTime': updateTime,
      'PreClose': preClose,
    };
  }
}
