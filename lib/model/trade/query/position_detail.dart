class PositionDetail {
  String? PositionNo;
  String? ExchangeNo;
  int? CommodityType;
  String? CommodityNo;
  String? ContractNo;
  String? ContractName;
  String? TradeCurrency;
  double? OpenCost;
  double? PreClose;
  double? PositionPrice;
  int? PositionQty;
  int? AvailableQty;
  int? MatchSide;
  int? PositionEffect;
  double? MarginValue;
  double? FeeValue;
  double? PositionProfit;
  double? CommodityTickSize;
  double? CalculatePrice;
  String? CreateTime;
  bool selected = false;

  PositionDetail({
    this.PositionNo,
    this.ExchangeNo,
    this.CommodityType,
    this.CommodityNo,
    this.ContractNo,
    this.ContractName,
    this.TradeCurrency,
    this.OpenCost,
    this.PreClose,
    this.PositionPrice,
    this.PositionQty,
    this.AvailableQty,
    this.MatchSide,
    this.PositionEffect,
    this.MarginValue,
    this.FeeValue,
    this.PositionProfit,
    this.CommodityTickSize,
    this.CalculatePrice,
    this.CreateTime,
  });

  PositionDetail.fromJson(Map<String, dynamic> json) {
    PositionNo = json['PositionNo'];
    ExchangeNo = json['ExchangeNo'];
    CommodityType = json['CommodityType']?.toInt();
    CommodityNo = json['CommodityNo'];
    ContractNo = json['ContractNo'];
    ContractName = json['ContractName'];
    TradeCurrency = json['TradeCurrency'];
    OpenCost = json['OpenCost']?.toDouble();
    PreClose = json['PreClose']?.toDouble();
    PositionPrice = json['PositionPrice']?.toDouble();
    PositionQty = json['PositionQty']?.toInt();
    AvailableQty = json['AvailableQty']?.toInt();
    MatchSide = json['MatchSide']?.toInt();
    PositionEffect = json['PositionEffect']?.toInt();
    MarginValue = json['MarginValue']?.toDouble();
    FeeValue = json['FeeValue']?.toDouble();
    PositionProfit = json['PositionProfit']?.toDouble();
    CommodityTickSize = json['CommodityTickSize']?.toDouble();
    CalculatePrice = json['CalculatePrice']?.toDouble();
    CreateTime = json['CreateTime'];
  }
}
