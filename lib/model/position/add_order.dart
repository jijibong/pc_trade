class AddOrder {
  String? ExchangeNo;
  String? CommodityNo;
  String? ContractNo;
  String? name;
  String? code;
  int? CommodityType;
  int? OrderType;
  int? TimeInForce;
  String? ExpireTime;
  int? OrderSide;
  double? OrderPrice;
  double? StopPrice;
  double? ProfitPriceTicks;
  double? LossPriceTicks;
  int? OrderQty;
  int? PositionEffect;
  String? ClientOrderId;
  bool needBackHand=false;

  AddOrder({
    this.ExchangeNo,
    this.CommodityNo,
    this.ContractNo,
    this.name,
    this.code,
    this.CommodityType,
    this.OrderType,
    this.TimeInForce,
    this.ExpireTime,
    this.OrderSide,
    this.OrderPrice,
    this.StopPrice,
    this.ProfitPriceTicks,
    this.LossPriceTicks,
    this.OrderQty,
    this.PositionEffect,
    this.ClientOrderId,
  });

  Map<String, dynamic> toJson() {
    return {
      'ExchangeNo': ExchangeNo,
      'CommodityNo': CommodityNo,
      'ContractNo': ContractNo,
      'name': name,
      'code': code,
      'CommodityType': CommodityType,
      'OrderType': OrderType,
      'TimeInForce': TimeInForce,
      'ExpireTime': ExpireTime,
      'OrderSide': OrderSide,
      'OrderPrice': OrderPrice,
      'StopPrice': StopPrice,
      'ProfitPriceTicks': ProfitPriceTicks,
      'LossPriceTicks': LossPriceTicks,
      'OrderQty': OrderQty,
      'PositionEffect': PositionEffect,
      'ClientOrderId': ClientOrderId,
    };
  }
}
