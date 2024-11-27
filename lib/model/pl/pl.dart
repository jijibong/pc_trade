class PLRecord {
  bool isSelected = false;
  int? Id;
  int? RealQty;
  double? StopWin;
  double? StopLoss;
  double? FloatLoss;
  int? State;
  int? CloseType;
  int? PositionType;
  String? CloseTime;
  String? CreateAt;
  bool selected = false;

  PLRecord({
    this.Id,
    this.RealQty,
    this.StopWin,
    this.StopLoss,
    this.FloatLoss,
    this.State,
    this.CloseType,
    this.PositionType,
    this.CloseTime,
    this.CreateAt,
  });

  PLRecord.fromJson(Map<String, dynamic> json) {
    Id = json['Id'];
    RealQty = json['RealQty'];
    StopWin = json['StopWin']?.toDouble();
    StopLoss = json['StopLoss']?.toDouble();
    FloatLoss = json['FloatLoss']?.toDouble();
    State = json['State'];
    CloseType = json['CloseType'];
    PositionType = json['PositionType'];
    CloseTime = json['CloseTime'];
    CreateAt = json['CreateAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'RealQty': RealQty,
      'StopWin': StopWin,
      'StopLoss': StopLoss,
      'FloatLoss': FloatLoss,
      'State': State,
      'CloseType': CloseType,
      'PositionType': PositionType,
      'CloseTime': CloseTime,
      'CreateAt': CreateAt,
    };
  }
}
