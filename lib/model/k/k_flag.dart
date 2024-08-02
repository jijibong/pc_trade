/// K线周期时间标识

class KPFlag {
  static const int Minute = 1;
  static const int Hour = 2;
  static const int Day = 3;
  static const int Week = 4;
  static const int Month = 5;
  static const int Year = 6;
  String? name;
  int? flag;
  int? max;

  KPFlag({
    this.name,
    this.flag,
    this.max,
  });
}
