class Option {
  num? id;
  String? excd;
  String? scode;
  String? comCode;
  int? comType;
  num? userId;
  bool? isMain;
  bool? isTitle;

  Option({
    this.id,
    this.excd,
    this.scode,
    this.comCode,
    this.comType,
    this.userId,
    this.isMain,
    this.isTitle,
  });

  Option.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    excd = json['excd'];
    scode = json['scode'];
    comCode = json['comCode'];
    comType = json['comType'];
    userId = json['userId'];
    isMain = json['isMain'];
    isTitle = json['isTitle'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'excd': excd,
      'scode': scode,
      'comCode': comCode,
      'comType': comType,
      'userId': userId,
      'isMain': isMain,
      'isTitle': isTitle,
    };
  }
}
