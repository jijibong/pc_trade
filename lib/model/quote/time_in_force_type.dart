class TimeInForceType {
  //当日有效
  static const int ORDER_TIMEINFORCE_GFD = 48;
  //取消前有效
  static const int ORDER_TIMEINFORCE_GTC = 49;
  //指定日期前有效
  static const int ORDER_TIMEINFORCE_GTD = 50;
  //FAK或IOC
  static const int ORDER_TIMEINFORCE_FAK = 51;
  //FOK
  static const int ORDER_TIMEINFORCE_FOK = 52;
}
