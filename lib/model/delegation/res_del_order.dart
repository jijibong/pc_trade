class ResDelOrder {
  String? CommodityNo; //商品编号
  int? CommodityType; //商品类型
  double? CommodityTickSize; //合约跳价
  String? ContractName; //合约名称
  String? ContractNo; //合约编号
  String? CreateTime; //订单生成时间
  int? ErrorCode; //错误吗码
  String? ErrorText; //错误信息
  String? ExchangeNo; //交易所编号
  String? ExpireTime; //到期时间
  String? OrderId; //订单ID
  String? TradeCurrency; //币种编号
  double? OrderPrice; //委托价格
  double? MatchPrice; //成交价格
  int? OrderQty; //委托数量
  int? MatchQty; //成交数量
  int? OrderSide; //买卖类型
  int? OrderState; //订单类型
  int? OrderType; //订单类型
  int? PositionEffect; //开平类型
  double? StopPrice; //止损价格
  int? TimeInForce; //到期类型
  int? OrderOpType; //报单来源

  ResDelOrder({
    this.CommodityNo,
    this.CommodityType,
    this.CommodityTickSize,
    this.ContractName,
    this.ContractNo,
    this.CreateTime,
    this.ErrorCode,
    this.ErrorText,
    this.ExchangeNo,
    this.ExpireTime,
    this.OrderId,
    this.TradeCurrency,
    this.OrderPrice,
    this.MatchPrice,
    this.OrderQty,
    this.MatchQty,
    this.OrderSide,
    this.OrderState,
    this.OrderType,
    this.PositionEffect,
    this.StopPrice,
    this.TimeInForce,
    this.OrderOpType,
  });

  ResDelOrder.fromJson(Map<String, dynamic> json) {
    CommodityNo = json['CommodityNo'];
    CommodityType = json['CommodityType'];
    CommodityTickSize = json['CommodityTickSize']?.toDouble();
    ContractName = json['ContractName'];
    ContractNo = json['ContractNo'];
    CreateTime = json['CreateTime'];
    ErrorCode = json['ErrorCode'];
    ErrorText = json['ErrorText'];
    ExchangeNo = json['ExchangeNo'];
    ExpireTime = json['ExpireTime'];
    OrderId = json['OrderId'];
    TradeCurrency = json['TradeCurrency'];
    OrderPrice = json['OrderPrice']?.toDouble();
    MatchPrice = json['MatchPrice']?.toDouble();
    OrderQty = json['OrderQty'];
    MatchQty = json['MatchQty'];
    OrderSide = json['OrderSide'];
    OrderState = json['OrderState'];
    OrderType = json['OrderType'];
    PositionEffect = json['PositionEffect'];
    StopPrice = json['StopPrice']?.toDouble();
    TimeInForce = json['TimeInForce'];
    OrderOpType = json['OrderOpType'];
  }

  Map<String, dynamic> toJson() {
    return {
      'CommodityNo': CommodityNo,
      'CommodityType': CommodityType,
      'CommodityTickSize': CommodityTickSize,
      'ContractName': ContractName,
      'ContractNo': ContractNo,
      'CreateTime': CreateTime,
      'ErrorCode': ErrorCode,
      'ErrorText': ErrorText,
      'ExchangeNo': ExchangeNo,
      'ExpireTime': ExpireTime,
      'OrderId': OrderId,
      'TradeCurrency': TradeCurrency,
      'OrderPrice': OrderPrice,
      'MatchPrice': MatchPrice,
      'OrderQty': OrderQty,
      'MatchQty': MatchQty,
      'OrderSide': OrderSide,
      'OrderState': OrderState,
      'OrderType': OrderType,
      'PositionEffect': PositionEffect,
      'StopPrice': StopPrice,
      'TimeInForce': TimeInForce,
      'OrderOpType': OrderOpType,
    };
  }
}
