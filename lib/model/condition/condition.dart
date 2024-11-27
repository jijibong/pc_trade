class Condition {
  int? Id;
  String? ConditionOrderNo;
  String? ExchangeNo;
  int? CommodityType;
  String? CommodityNo;
  String? ContractNo;
  String? ContractName;
  String? ContractShortName;
  int? PriceType;
  int? ConditionType;
  double? ConditionPrice;
  int? OrderType;
  int? TimeInForce;
  String? ExpireTime;
  int? OrderSide;
  int? PositionEffect;
  double? OrderPrice;
  int? OrderQty;
  int? Status;
  String? SubmitResultsMsg;
  String? CreateAt;
  String? UpdateAt;
  bool? isExpand;
  int? bgColor;
  int? UpdateStamp;
  bool selected = false;

  Condition({
    this.Id,
    this.ConditionOrderNo,
    this.ExchangeNo,
    this.CommodityType,
    this.CommodityNo,
    this.ContractNo,
    this.ContractName,
    this.ContractShortName,
    this.PriceType,
    this.ConditionType,
    this.ConditionPrice,
    this.OrderType,
    this.TimeInForce,
    this.ExpireTime,
    this.OrderSide,
    this.PositionEffect,
    this.OrderPrice,
    this.OrderQty,
    this.Status,
    this.SubmitResultsMsg,
    this.CreateAt,
    this.UpdateAt,
    this.isExpand,
    this.bgColor,
    this.UpdateStamp,
  });

  Condition.fromJson(Map<String, dynamic> json) {
    Id = json['Id'];
    ConditionOrderNo = json['ConditionOrderNo'];
    ExchangeNo = json['ExchangeNo'];
    CommodityType = json['CommodityType'];
    CommodityNo = json['CommodityNo'];
    ContractNo = json['ContractNo'];
    ContractName = json['ContractName'];
    ContractShortName = json['ContractShortName'];
    PriceType = json['PriceType'];
    ConditionType = json['ConditionType'];
    ConditionPrice = json['ConditionPrice']?.toDouble();
    OrderType = json['OrderType'];
    TimeInForce = json['TimeInForce'];
    ExpireTime = json['ExpireTime'];
    OrderSide = json['OrderSide'];
    PositionEffect = json['PositionEffect'];
    OrderPrice = json['OrderPrice']?.toDouble();
    OrderQty = json['OrderQty'];
    Status = json['Status'];
    SubmitResultsMsg = json['SubmitResultsMsg'];
    CreateAt = json['CreateAt'];
    UpdateAt = json['UpdateAt'];
    isExpand = json['isExpand'];
    bgColor = json['bgColor'];
    UpdateStamp = json['UpdateStamp'];
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'ConditionOrderNo': ConditionOrderNo,
      'ExchangeNo': ExchangeNo,
      'CommodityType': CommodityType,
      'CommodityNo': CommodityNo,
      'ContractNo': ContractNo,
      'ContractName': ContractName,
      'ContractShortName': ContractShortName,
      'PriceType': PriceType,
      'ConditionType': ConditionType,
      'ConditionPrice': ConditionPrice,
      'OrderType': OrderType,
      'TimeInForce': TimeInForce,
      'ExpireTime': ExpireTime,
      'OrderSide': OrderSide,
      'PositionEffect': PositionEffect,
      'OrderPrice': OrderPrice,
      'OrderQty': OrderQty,
      'Status': Status,
      'SubmitResultsMsg': SubmitResultsMsg,
      'CreateAt': CreateAt,
      'UpdateAt': UpdateAt,
      'isExpand': isExpand,
      'bgColor': bgColor,
      'UpdateStamp': UpdateStamp,
    };
  }
}
