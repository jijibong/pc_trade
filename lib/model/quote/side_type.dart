import 'dart:convert';

class SideType {
  //无
  static int SIDE_NONE = ascii.encode('N').first;
  //买入
  static int SIDE_BUY = ascii.encode('B').first;
  //卖出
  static int SIDE_SELL = ascii.encode('S').first;
}
