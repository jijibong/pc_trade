import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class Common {
  static DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  static DateFormat ymdhmsFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static DateFormat refreshFormat = DateFormat('yyyy-MM-dd 08:30:00');
  static DateFormat secRefreshFormat = DateFormat('yyyy-MM-dd 20:30:00');
  static DateFormat detailFormat = DateFormat('HH:mm:ss');
  static NumberFormat numFormatter = NumberFormat("00");
  // static List<String> months = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"];
  // static String nowTime = "";
  static int desktopPlatform = 4; ///Todo
  static int Platform = 259;

  ///Config
  static const String appName = 'FCS.HK行情交易系统（模拟）';
  static String brokerId = "FCS.HK";
  static int environment = 83;
  static int platAttr = 70;
  static String RiskUrl = "http://notice.yhrjkj.com/RevelationBook.html";


  static bool signData = true;
  static Duration connectTimeout = const Duration(seconds: 30);
  static Duration receiveTimeout = const Duration(seconds: 30);

  ///Color
  static Color darkCommandBarColor = HexColor('#2B313F');
  static Color lightCommandBarColor = Colors.white;
  static Color quoteTitleColor = HexColor('#05ECED');
  static Color exchangeTextColor = HexColor('#777B88');
  static Color exchangeBgColor = HexColor('#545464');

  ///Size
  static double optionWidgetWidth = 40;

}
