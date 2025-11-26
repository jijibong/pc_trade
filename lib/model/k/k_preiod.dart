import 'k_flag.dart';
import 'k_time.dart';

class KPeriod {
  num? id; //主键
  String? name;
  int? period;
  int? cusType; //周期类型，1-可订阅周期，2-自定义周期
  int? kpFlag; //周期标识，1-分钟，2-小时，3-天，4-周，5-月，6-年
  String? periodType;

  KPeriod({
    this.id,
    this.name,
    this.period,
    this.cusType,
    this.kpFlag,
    this.periodType,
  });

  KPeriod.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    period = json['period'];
    cusType = json['cusType'];
    kpFlag = json['kpFlag'];
    periodType = json['periodType'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'period': period,
      'cusType': cusType,
      'kpFlag': kpFlag,
      'periodType': periodType,
    };
  }

  static getDefaultKPeriodList() {
    return [
      KPeriod(name: "1分钟", period: KTime.M_1, cusType: 1, kpFlag: KPFlag.Minute, periodType: "分钟"),
      KPeriod(name: "3分钟", period: KTime.M_3, cusType: 1, kpFlag: KPFlag.Minute, periodType: "分钟"),
      KPeriod(name: "5分钟", period: KTime.M_5, cusType: 1, kpFlag: KPFlag.Minute, periodType: "分钟"),
      KPeriod(name: "15分钟", period: KTime.M_15, cusType: 1, kpFlag: KPFlag.Minute, periodType: "分钟"),
      KPeriod(name: "1小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour, periodType: "小时"),
      KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day, periodType: "日"),
      KPeriod(name: "周", period: 1, cusType: 2, kpFlag: KPFlag.Week, periodType: "周"),
      KPeriod(name: "月", period: 1, cusType: 2, kpFlag: KPFlag.Month, periodType: "月"),
      KPeriod(name: "年", period: 1, cusType: 2, kpFlag: KPFlag.Year, periodType: "年"),
    ];
  }

  static bool isCusPeriod(int flag, int period) {
    switch (flag) {
      case KPFlag.Minute:
        switch (period) {
          case 1:
          case 3:
          case 5:
          case 10:
          case 15:
          case 30:
          case 60:
            return false;
        }
        break;

      case KPFlag.Hour:
      case KPFlag.Day:
        switch (period) {
          case 1:
            return false;
        }
        break;
    }
    return true;
  }

  static int getSubPeriod(int flag, int period) {
    int result = period;
    switch (flag) {
      case KPFlag.Minute:
        switch (period) {
          case 1:
            result = KTime.M_1;
            break;

          case 3:
            result = KTime.M_3;
            break;

          case 5:
            result = KTime.M_5;
            break;

          case 10:
            result = KTime.M_10;
            break;

          case 15:
            result = KTime.M_15;
            break;

          case 30:
            result = KTime.M_30;
            break;

          case 60:
            result = KTime.H_1;
            break;
        }
        break;

      case KPFlag.Hour:
        result = KTime.H_1;
        break;

      case KPFlag.Day:
        result = KTime.DAY;
        break;
    }

    return result;
  }
}
