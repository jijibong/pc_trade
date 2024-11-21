import 'dart:ui';

class Contract {
  num? id; //主键
  String? name; //合约名称
  String? comName; //品种名称
  String? code; //合约代码
  String? exCode; //市场代码
  int? comType; //品种类型
  String? subComCode; //订阅用品种代码
  String? subConCode; //订阅用合约代码
  String? timeStr; //行情时间
  String? trTime; //交易时间
  String? changeFlag; //看涨看跌标识
  String? currency; //币种编号
  String? tradeState; //交易状态
  String? positionTrend; //持仓走势
  num? comId; //品种
  num? conId; //合约ID
  num? optionId; //自选
  int? optionSort; //自选排序
  num? contractID; //交易服务器合约id
  num? timeStamps; //行情时间戳
  num? lastPrice; //最新价
  String? lastPriceString = "--"; //最新价String
  Color? lastPriceColor;
  num? change; //涨跌
  String? changeString = "0"; //涨跌String
  Color? changeColor;
  num? changePer; //涨跌幅
  String? changePerString = "0%"; //涨跌幅String
  num? buyPrice; //买价
  num? salePrice; //卖价
  String? buyPriceString = "0.0"; //买价String
  String? salePriceString = "0.0"; //卖价String
  Color? buyPriceColor;
  Color? salePriceColor;
  Color? volumeColor;
  num? volume; //成交量
  num? lastVolume; //最新成交量
  num? turnOver; //成交额
  num? highPrice; //最高价
  num? lowPrice; //最低价
  String? high = "0.0"; //最高价String
  String? low = "0.0"; //最低价String
  Color? highColor;
  Color? lowColor;
  num? prePrice; //昨日收盘价
  num? preSettlePrice; //昨日结算价
  num? settlePrice; //结算价
  num? openPrice; //开盘价
  Color? openColor;
  num? execPrice; //执行价
  num? prePosition; //昨持仓量
  Color? positionColor;
  num? position; //持仓量
  num? hisHigh; //历史最高价
  num? hisLow; //历史最低价
  num? limitPrice; //涨停价
  num? stopPrice; //跌停价
  num? averPrice; //均价
  num? implieBuy; //隐含买价
  int? implieBuyNum; //隐含买量
  num? implieSale; //隐含卖价
  int? implieSaleNum; //隐含卖量
  num? virtuality; //今虚实度
  num? preVirtuality; //昨虚实度
  num? in_vouume; //内盘量
  num? out_vouume; //外盘量
  num? turn_rate; //换手率
  num? five_aver; //五日均量
  num? pe_rate; //市盈率
  num? all_marketValue; //总市值
  num? cir_marketValue; //流通市值
  num? rise_speed; //涨速
  num? amplitude; //振幅
  num? delegateBuy; //委买总量
  num? delegateSale; //委卖总量
  Color? delegateBuyColor;
  Color? delegateSaleColor;
  num? futureTickSize; //期货合约跳价
  num? contractSize; //合约乘数
  num? initial; //合约单笔初始保证金
  int? trCount; //合约上日成交量，计算主力合约
  int? orderNum; //排序字段
  // List<ContractItem>? contractItems;
  List<Contract>? contractItems; //子合约集合
  List<Level2>? level2List; //深度行情
  int? itemType;
  bool? optional = false;
  bool? selected = false;
  bool? isMain; //是否是主力

  Contract({
    this.id,
    this.name,
    this.comName,
    this.code,
    this.exCode,
    this.comType,
    this.subComCode,
    this.subConCode,
    this.timeStr,
    this.trTime,
    this.changeFlag,
    this.currency,
    this.tradeState,
    this.positionTrend,
    this.comId,
    this.conId,
    this.optionId,
    this.optionSort,
    this.contractID,
    this.timeStamps,
    this.lastPrice,
    this.change,
    this.changePer,
    this.buyPrice,
    this.salePrice,
    this.volume,
    this.lastVolume,
    this.turnOver,
    this.highPrice,
    this.lowPrice,
    this.prePrice,
    this.preSettlePrice,
    this.settlePrice,
    this.openPrice,
    this.execPrice,
    this.prePosition,
    this.position,
    this.hisHigh,
    this.hisLow,
    this.limitPrice,
    this.stopPrice,
    this.averPrice,
    this.implieBuy,
    this.implieBuyNum,
    this.implieSale,
    this.implieSaleNum,
    this.virtuality,
    this.preVirtuality,
    this.in_vouume,
    this.out_vouume,
    this.turn_rate,
    this.five_aver,
    this.pe_rate,
    this.all_marketValue,
    this.cir_marketValue,
    this.rise_speed,
    this.amplitude,
    this.delegateBuy,
    this.delegateSale,
    this.futureTickSize,
    this.contractSize,
    this.initial,
    this.trCount,
    this.orderNum,
    this.contractItems,
    this.level2List,
    this.itemType,
    this.optional,
    this.selected,
    this.isMain,
  });

  void setLevel2(Level2 level, int pos) {
    if (level.price != null && level.price! > 0) {
      level2List?[pos].price = level.price;
    }

    if (level.volume != null && level.volume! > 0) {
      level2List?[pos].volume = level.volume;
    }
  }

  Contract.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    comName = json['comName'];
    code = json['code'];
    exCode = json['exCode'];
    comType = json['comType'];
    subComCode = json['subComCode'];
    subConCode = json['subConCode'];
    timeStr = json['timeStr'];
    trTime = json['trTime'];
    changeFlag = json['changeFlag'];
    currency = json['currency'];
    tradeState = json['tradeState'];
    positionTrend = json['positionTrend'];
    comId = json['comId'];
    conId = json['conId'];
    optionId = json['optionId'];
    optionSort = json['optionSort'];
    contractID = json['contractID'];
    timeStamps = json['timeStamps'];
    lastPrice = json['lastPrice'];
    change = json['change'];
    changePer = json['changePer'];
    buyPrice = json['buyPrice'];
    salePrice = json['salePrice'];
    volume = json['volume'];
    lastVolume = json['lastVolume'];
    turnOver = json['turnOver'];
    highPrice = json['highPrice'];
    lowPrice = json['lowPrice'];
    prePrice = json['prePrice'];
    preSettlePrice = json['preSettlePrice'];
    settlePrice = json['settlePrice'];
    openPrice = json['openPrice'];
    execPrice = json['execPrice'];
    prePosition = json['prePosition'];
    position = json['position'];
    hisHigh = json['hisHigh'];
    hisLow = json['hisLow'];
    limitPrice = json['limitPrice'];
    stopPrice = json['stopPrice'];
    averPrice = json['averPrice'];
    implieBuy = json['implieBuy'];
    implieBuyNum = json['implieBuyNum'];
    implieSale = json['implieSale'];
    implieSaleNum = json['implieSaleNum'];
    virtuality = json['virtuality'];
    preVirtuality = json['preVirtuality'];
    in_vouume = json['in_vouume'];
    out_vouume = json['out_vouume'];
    turn_rate = json['turn_rate'];
    five_aver = json['five_aver'];
    pe_rate = json['pe_rate'];
    all_marketValue = json['all_marketValue'];
    cir_marketValue = json['cir_marketValue'];
    rise_speed = json['rise_speed'];
    amplitude = json['amplitude'];
    delegateBuy = json['delegateBuy'];
    delegateSale = json['delegateSale'];
    futureTickSize = json['futureTickSize'];
    contractSize = json['contractSize'];
    initial = json['initial'];
    trCount = json['trCount'];
    orderNum = json['orderNum'];
    contractItems = json['contractItems'] != null ? (json['contractItems'] as List).map((e) => Contract.fromJson(e)).toList() : [];
    level2List = json['level2List'] != null ? (json['level2List'] as List).map((e) => Level2.fromJson(e)).toList() : [];
    itemType = json['itemType'];
    optional = json['optional'];
    isMain = json['isMain'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'comName': comName,
      'code': code,
      'exCode': exCode,
      'comType': comType,
      'subComCode': subComCode,
      'subConCode': subConCode,
      'timeStr': timeStr,
      'trTime': trTime,
      'changeFlag': changeFlag,
      'currency': currency,
      'tradeState': tradeState,
      'positionTrend': positionTrend,
      'comId': comId,
      'conId': conId,
      'optionId': optionId,
      'optionSort': optionSort,
      'contractID': contractID,
      'timeStamps': timeStamps,
      'lastPrice': lastPrice,
      'change': change,
      'changePer': changePer,
      'buyPrice': buyPrice,
      'salePrice': salePrice,
      'volume': volume,
      'lastVolume': lastVolume,
      'turnOver': turnOver,
      'highPrice': highPrice,
      'lowPrice': lowPrice,
      'prePrice': prePrice,
      'preSettlePrice': preSettlePrice,
      'settlePrice': settlePrice,
      'openPrice': openPrice,
      'execPrice': execPrice,
      'prePosition': prePosition,
      'position': position,
      'hisHigh': hisHigh,
      'hisLow': hisLow,
      'limitPrice': limitPrice,
      'stopPrice': stopPrice,
      'averPrice': averPrice,
      'implieBuy': implieBuy,
      'implieBuyNum': implieBuyNum,
      'implieSale': implieSale,
      'implieSaleNum': implieSaleNum,
      'virtuality': virtuality,
      'preVirtuality': preVirtuality,
      'in_vouume': in_vouume,
      'out_vouume': out_vouume,
      'turn_rate': turn_rate,
      'five_aver': five_aver,
      'pe_rate': pe_rate,
      'all_marketValue': all_marketValue,
      'cir_marketValue': cir_marketValue,
      'rise_speed': rise_speed,
      'amplitude': amplitude,
      'delegateBuy': delegateBuy,
      'delegateSale': delegateSale,
      'futureTickSize': futureTickSize,
      'contractSize': contractSize,
      'initial': initial,
      'trCount': trCount,
      'orderNum': orderNum,
      'contractItems': contractItems != null ? contractItems?.map((e) => e.toJson()).toList() : [],
      'level2List': level2List != null ? level2List?.map((e) => e.toJson()).toList() : [],
      'itemType': itemType,
      'optional': optional,
      'isMain': isMain,
    };
  }
}

// class ContractItem {
//   String? name;
//   bool optional = false;
//   SuperTooltipController tooltipController = SuperTooltipController();
//
//   ContractItem({
//     this.name,
//   });
//
//   ContractItem.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//     };
//   }
// }

class Level2 {
  num? price;
  num? volume;

  Level2({
    this.price,
    this.volume,
  });

  Level2.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    volume = json['volume'];
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'volume': volume,
    };
  }
}
