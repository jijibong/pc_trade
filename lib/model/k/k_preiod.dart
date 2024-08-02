class KPeriod {
  num? id; //主键
  String? name;
  int? period;
  int? cusType; //周期类型，1-可订阅周期，2-自定义周期
  int? kpFlag; //周期标识，1-分钟，2-小时，3-天，4-周，5-月，6-年
  bool? isDel; //是否已删除
  bool? isSelected = false;
  int? tabType;

  KPeriod({
    this.id,
    this.name,
    this.period,
    this.cusType,
    this.kpFlag,
    this.isDel,
    this.isSelected,
    this.tabType,
  });

  KPeriod.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    period = json['period'];
    cusType = json['cusType'];
    kpFlag = json['kpFlag'];
    isDel = json['isDel'];
    isSelected = json['isSelected'];
    tabType = json['tabType'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'period': period,
      'cusType': cusType,
      'kpFlag': kpFlag,
      'isDel': isDel,
      'isSelected': isSelected,
      'tabType': tabType,
    };
  }
}
