class KTime {
  //分时
  static const int FS = -1;
  //1分钟
  static const int M_1 = 0;
  //5分钟
  static const int M_5 = 1;
  //10分钟
  static const int M_10 = 2;
  //15分钟
  static const int M_15 = 3;
  //30分钟
  static const int M_30 = 4;
  //1小时
  static const int H_1 = 5;
  //一天
  static const int DAY = 6;
  //3分钟
  static const int M_3 = 7;
  //一周
  static const int WEEK = 8;
  //一月
  static const int MON = 9;
  //4小时
  static const int H_4 = 10;

  // /// 获取K线周期
  // static int getPeriod(String str) {
  //   int period = 0;
  //   switch (str) {
  //     case "分时":
  //       period = KTime.FS;
  //       break;
  //
  //     case "1分钟":
  //       period = KTime.M_1;
  //       break;
  //
  //     case "5分钟":
  //       period = KTime.M_5;
  //       break;
  //
  //     case "10分钟":
  //       period = KTime.M_10;
  //       break;
  //
  //     case "15分钟":
  //       period = KTime.M_15;
  //       break;
  //
  //     case "30分钟":
  //       period = KTime.M_30;
  //       break;
  //
  //     case "1小时":
  //       period = KTime.H_1;
  //       break;
  //
  //     case "4小时":
  //       period = KTime.H_4;
  //       break;
  //
  //     case "日线":
  //       period = KTime.DAY;
  //       break;
  //
  //     case "一周":
  //       period = KTime.WEEK;
  //       break;
  //
  //     case "一月":
  //       period = KTime.MON;
  //       break;
  //   }
  //   return period;
  // }
}
