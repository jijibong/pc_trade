import 'dart:convert';

class Order_Type {
  //市价49
  static const int ORDER_TYPE_MARKET = 49;
  //限价50
  static const int ORDER_TYPE_LIMIT = 50;
  //市价止损
  static const int ORDER_TYPE_STOP_MARKET = 51;
  //限价止损
  static const int ORDER_TYPE_STOP_LIMIT = 52;
  //期权行权
  static const int ORDER_TYPE_OPT_EXEC = 53;
  //期权弃权
  static const int ORDER_TYPE_OPT_ABANDON = 54;
  //询价
  static const int ORDER_TYPE_REQQUOT = 55;
  //应价
  static const int ORDER_TYPE_RSPQUOT = 56;
  //冰山单
  static const int ORDER_TYPE_ICEBERG = 57;
  //影子单
  static const int ORDER_TYPE_GHOST = 65;
  //港交所竞价单
  static const int ORDER_TYPE_HKEX_AUCTION = 66;
  //互换
  static const int ORDER_TYPE_SWAP = 67;
}

class OrderOpType {
  //正常操作
  static final int ORDEROPERATION_NONE = ascii.encode('0').first;
  //内部强平
  static final int ORDEROPERATION_CLOSE = ascii.encode('1').first;
  //反手
  static final int ORDEROPERATION_REVERSE = ascii.encode('2').first;
  //锁仓
  static final int ORDEROPERATION_LOCKP = ascii.encode('3').first;
  //撤单
  static final int ORDEROPERATION_CANCAL = ascii.encode('4').first;
  //管理开仓
  static final int ORDEROPERATION_MTG_OPEN = ascii.encode('5').first;
  //持仓修正
  static final int ORDEROPERATION_MTG_MTF = ascii.encode('6').first;
  //管理强平
  static final int ORDEROPERATION_MTG_CLOSE = ascii.encode('7').first;
  //止盈止损
  static final int ORDEROPERATION_PL_CLOSE = ascii.encode('8').first;

  static String getName(int? type) {
    String name = "";

    if (type == ORDEROPERATION_NONE) {
      name = "正常操作";
    } else if (type == ORDEROPERATION_CLOSE) {
      name = "系统强平";
    } else if (type == ORDEROPERATION_REVERSE) {
      name = "反手";
    } else if (type == ORDEROPERATION_LOCKP) {
      name = "锁仓";
    } else if (type == ORDEROPERATION_CANCAL) {
      name = "撤单";
    } else if (type == ORDEROPERATION_MTG_OPEN) {
      name = "管理开仓";
    } else if (type == ORDEROPERATION_MTG_MTF) {
      name = "持仓修正";
    } else if (type == ORDEROPERATION_MTG_CLOSE) {
      name = "人工强平";
    } else if (type == ORDEROPERATION_PL_CLOSE) {
      name = "止盈止损";
    } else {
      name = "正常操作";
    }
    return name;
  }
}
