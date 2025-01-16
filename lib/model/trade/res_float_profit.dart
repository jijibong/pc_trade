class ResFloatProfit {
  double? CalculatePrice;
  String? PositionNo;
  double? PositionProfit;
  String? UpdateTime;

  ResFloatProfit({
    this.CalculatePrice,
    this.PositionNo,
    this.PositionProfit,
    this.UpdateTime,
  });

  ResFloatProfit.fromJson(Map<String, dynamic> json) {
    CalculatePrice = json['CalculatePrice'];
    PositionNo = json['PositionNo'];
    PositionProfit = json['PositionProfit'];
    UpdateTime = json['UpdateTime'];
  }

  Map<String, dynamic> toJson() {
    return {
      'UpdateTime': UpdateTime,
      'PositionProfit': PositionProfit,
      'CalculatePrice': CalculatePrice,
      'PositionNo': PositionNo,
    };
  }
}
