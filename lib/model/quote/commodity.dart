class Commodity {
  num? id;
  String? commodityEngName;
  num? commodityId;
  String? commodityName;
  String? shortName;
  String? commodityNo;
  num? commodityTickSize;
  int? commodityType;
  num? contractSize;
  String? exchangeNo;
  num? mfContract;
  num? openCloseMode;
  num? strikePriceTimes;
  String? tradeCurrency;
  String? tradeTime;
  num? updataStatus;
  int? orderNum;
  num? marketPriceTrade;
  String? updateTime;
  List<ContractsBean>? contracts;
  List<ContractChild>? contractList;

  Commodity({
    this.id,
    this.commodityEngName,
    this.commodityId,
    this.commodityName,
    this.shortName,
    this.commodityNo,
    this.commodityTickSize,
    this.commodityType,
    this.contractSize,
    this.exchangeNo,
    this.mfContract,
    this.openCloseMode,
    this.strikePriceTimes,
    this.tradeCurrency,
    this.tradeTime,
    this.updataStatus,
    this.orderNum,
    this.marketPriceTrade,
    this.updateTime,
    this.contracts,
    this.contractList,
  });

  Commodity.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    commodityEngName = json['CommodityEngName'];
    commodityId = json['CommodityId'];
    commodityName = json['CommodityName'];
    shortName = json['ShortName'];
    commodityNo = json['CommodityNo'];
    commodityTickSize = json['CommodityTickSize'];
    commodityType = json['CommodityType'];
    contractSize = json['ContractSize'];
    exchangeNo = json['ExchangeNo'];
    mfContract = json['MfContract'];
    openCloseMode = json['OpenCloseMode'];
    strikePriceTimes = json['StrikePriceTimes'];
    tradeCurrency = json['TradeCurrency'];
    tradeTime = json['TradeTime'];
    updataStatus = json['UpdataStatus'];
    orderNum = json['OrderNum'];
    marketPriceTrade = json['MarketPriceTrade'];
    updateTime = json['UpdateTime'];
    contracts = json['Contracts'] != null ? (json['Contracts'] as List).map((e) => ContractsBean.fromJson(e)).toList() : [];
    contractList = json['ContractChild'] != null ? (json['ContractChild'] as List).map((e) => ContractChild.fromJson(e)).toList() : [];
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CommodityEngName': commodityEngName,
      'CommodityId': commodityId,
      'CommodityName': commodityName,
      'ShortName': shortName,
      'CommodityNo': commodityNo,
      'CommodityTickSize': commodityTickSize,
      'CommodityType': commodityType,
      'ContractSize': contractSize,
      'ExchangeNo': exchangeNo,
      'MfContract': mfContract,
      'OpenCloseMode': openCloseMode,
      'StrikePriceTimes': strikePriceTimes,
      'TradeCurrency': tradeCurrency,
      'TradeTime': tradeTime,
      'UpdataStatus': updataStatus,
      'OrderNum': orderNum,
      'MarketPriceTrade': marketPriceTrade,
      'UpdateTime': updateTime,
      'Contracts': contracts?.map((e) => e.toJson()).toList(),
      'ContractChild': contractList?.map((e) => e.toJson()).toList(),
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

class ContractChild {
  num? id;
  num? cid;
  num? commodity;
  String? contractCode;
  String? contractExpDate;
  String? contractName;
  String? shortName;
  String? contractNo;
  int? contractType;
  String? firstNoticeDate;
  String? lastTradeDate;
  int? trCount;
  int? updataStatus;
  String? updateTime;
  num? preClose;


  ContractChild({
    this.id,
    this.cid,
    this.commodity,
    this.contractCode,
    this.contractExpDate,
    this.contractName,
    this.shortName,
    this.contractNo,
    this.contractType,
    this.firstNoticeDate,
    this.lastTradeDate,
    this.trCount,
    this.updataStatus,
    this.updateTime,
    this.preClose,
  });

  ContractChild.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    cid = json['cid'];
    commodity = json['Commodity'];
    contractCode = json['ContractCode'];
    contractExpDate = json['ContractExpDate'];
    contractName = json['ContractName'];
    shortName = json['ShortName'];
    contractNo = json['ContractNo'];
    contractType = json['ContractType'];
    firstNoticeDate = json['FirstNoticeDate'];
    lastTradeDate = json['LastTradeDate'];
    trCount = json['TrCount'];
    updataStatus = json['UpdataStatus'];
    updateTime = json['UpdateTime'];
    preClose = json['PreClose'];
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'cid': cid,
      'Commodity': commodity,
      'ContractCode': contractCode,
      'ContractExpDate': contractExpDate,
      'ContractName': contractName,
      'ShortName': shortName,
      'ContractNo': contractNo,
      'ContractType': contractType,
      'FirstNoticeDate': firstNoticeDate,
      'LastTradeDate': lastTradeDate,
      'TrCount': trCount,
      'UpdataStatus': updataStatus,
      'UpdateTime': updateTime,
      'PreClose': preClose,
    };
  }
}
