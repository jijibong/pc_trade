import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

import '../model/draw_tools/DrawTool.dart';

class Common {
  static DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  static DateFormat ymdhmsFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static DateFormat refreshFormat = DateFormat('yyyy-MM-dd 08:30:00');
  static DateFormat secRefreshFormat = DateFormat('yyyy-MM-dd 20:30:00');
  static DateFormat detailFormat = DateFormat('HH:mm:ss');
  static NumberFormat numFormatter = NumberFormat("00");

  // static List<String> months = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"];
  // static String nowTime = "";
  static int desktopPlatform = 4;
  static int Platform = 259;
  static int screenCount = 9;
  static double dialogBorderRadius = 25;
  static double dialogPadding = 15;

  ///Config
  static const String appName = 'FCS.HK行情交易系统';
  static const String shortName = 'FCS.HK';
  static const String brokerId = "FCS.HK";
  static const int environment = 83;
  static const int platAttr = 70;
  static const String RiskUrl = "http://notice.yhrjkj.com/RevelationBook.html";

  static bool signData = true;
  static Duration connectTimeout = const Duration(seconds: 30);
  static Duration receiveTimeout = const Duration(seconds: 30);

  ///Color
  static Color darkCommandBarBgColor = HexColor('1D1E24');
  static Color lightCommandBarBgColor = HexColor('#F7F8FA');
  static Color darkExchangeTextColor = HexColor('#ffffff');
  static Color lightExchangeTextColor = HexColor('#777B88');
  static Color darkExchangeBgColor = HexColor('#545464');
  static Color lightExchangeBgColor = HexColor('#545464');
  static Color lightCommodityTextColor = HexColor('#545464');
  static Color inActiveCommodityTextColor = HexColor('#545966');

  static Color dialogTitleColor = HexColor('#2C3140');
  static Color dialogContentColor = HexColor('#424759');
  static Color dialogTextColor = HexColor('#747C8C');
  static Color dialogButtonTextColor = HexColor('#FFD200');

  static Color conditionTopBgColor = HexColor('#202632');
  static Color conditionBottomBgColor = HexColor('##101622');

  static Color quoteTitleColor = HexColor('#06DADC');
  static Color quoteDarkThemeColor = HexColor('#06DADC');
  static Color quoteCommonColor = const Color.fromARGB(0, 255, 255, 255);
  static Color quoteHighColor = HexColor('#FF4242'); //红色
  static Color quoteLowColor = const Color.fromARGB(255, 0, 220, 0);
  static Color quoteAppleUpColor = const Color.fromARGB(255, 224, 128, 224);
  static Color quoteAppleDownColor = const Color.fromARGB(255, 127, 191, 255);
  static Color quoteRedColor = HexColor('#ff204a');
  static Color quoteGreenColor = HexColor('#3aff20');

  static Color lightBgColor = HexColor('#F0F1F5');
  // static Color lightBgColor = const Color.fromARGB(1, 240, 241, 245);
  // static Color lightBgColor = hslaToColor(228, 1, 0.95, 1);
  static Color darkBgColor = HexColor('#18181C');
  static Color commandTextColor = HexColor('#777E90');
  static Color contentDarkBgColor = HexColor('#2A2C33');
  static Color contentLightBgColor = HexColor('#FFFFFF');
  static Color darkDownColor = HexColor('#00F4F2'); //青色
  static Color lightDownColor = HexColor('#00B06C'); //绿色
  static Color redTextColor = HexColor('#FF3333'); //红色

  static Color textBoxBorderDarkColor = HexColor('#393F4D'); //灰
  static Color textBoxBorderHighLightDarkColor = HexColor('#D5DAE7');
  static Color textBoxBorderLightColor = HexColor('#E1E3E8');
  static Color textBoxBorderHighLightLightColor = HexColor('#BDBFC2');

  static Color hyperlinkColor = HexColor('#CAA559');
  static Color loginButtonColor = HexColor('#DBC18C');
  static Color selectTabLightBgColor = HexColor('#D0D3D9');
  static Color unSelectTabLightBgColor = HexColor('#DCDFE6');
  static Color selectTabDarkBgColor = HexColor('#333845');
  static Color unSelectTabDarkBgColor = HexColor('#23262F');

  static Color dashDividerColor = HexColor('#51515B');

  static Color dialogDarkBgColor = HexColor('#292B33');
  static Color dialogLightBgColor = HexColor('#FFFFFF');
  static Color dialogContentBorderBgColor = HexColor('#E6E8EC');

  static Color lightScrollBarColor = HexColor('#6A738F');
  static Color darkScrollBarColor = HexColor('#52545F');

  static Color checkBoxBorderLightColor = HexColor('#E6E8EC');
  static Color checkBoxBorderDarkColor = HexColor('#393F4D');

  static Color tradeButtonColor = HexColor('#F5F6FA');
  static Color tradeTypeButtonColor = HexColor('#EAEDF5');
  static Color selectedRadioButtonColor = HexColor('#DBC18C');
  static Color tradeCloseButtonColor = HexColor('#E6CA93');
  static Color containerBgColor = HexColor('#FAFBFF');
  static Color radioBorderLightColor = HexColor('#D3D5D9');
  static Color radioBorderDarkColor = HexColor('#3D4352');
  static Color comboDarkColor = HexColor('#25272E');
  static Color collectIconDarkColor = HexColor('#333745');
  static Color greenButtonColor = HexColor('#1ABC7E');
  static Color goldenTextColor = HexColor('#A0792C');
  static Color checkedBoxDarkBgColor = HexColor('#212329');

  static Color msgTimeLightColor = HexColor('#A2A9B0');
  static Color msgDarkBgColor = HexColor('#1D1E24');
  static Color msgDividerDarkBgColor = HexColor('#353945');

  ///Size
  static double optionWidgetWidth = 40;
  static double iconImageWidth = 22;

  var drawToolTypes = [
    DrawToolObj(index: 1, name: '趋势线', iconPath: 'assets/images/hx_icon_1@3x.png'),
    DrawToolObj(index: 2, name: '射线', iconPath: 'assets/images/hx_icon_2@3x.png'),
    DrawToolObj(index: 3, name: '水平线', iconPath: 'assets/images/hx_icon_3@3x.png'),
    DrawToolObj(index: 4, name: '竖线', iconPath: 'assets/images/hx_icon_4@3x.png'),
    DrawToolObj(index: 5, name: '线段', iconPath: 'assets/images/hx_icon_5@3x.png'),
    DrawToolObj(index: 6, name: '通道线', iconPath: 'assets/images/hx_icon_6@3x.png'),
    DrawToolObj(index: 7, name: '平行线', iconPath: 'assets/images/hx_icon_7@3x.png'),
    DrawToolObj(index: 8, name: '矩形', iconPath: 'assets/images/hx_icon_8@3x.png'),
    DrawToolObj(index: 9, name: '三角线', iconPath: 'assets/images/hx_icon_9@3x.png'),
    DrawToolObj(index: 10, name: '圆弧', iconPath: 'assets/images/hx_icon_10@3x.png'),
    DrawToolObj(index: 11, name: '甘氏线', iconPath: 'assets/images/hx_icon_11@3x.png'),
    DrawToolObj(index: 12, name: '阻速线', iconPath: 'assets/images/hx_icon_12@3x.png'),
    DrawToolObj(index: 13, name: '对称角度线', iconPath: 'assets/images/hx_icon_13@3x.png'),
    DrawToolObj(index: 14, name: '圆', iconPath: 'assets/images/hx_icon_14@3x.png'),
    DrawToolObj(index: 15, name: '椭圆', iconPath: 'assets/images/hx_icon_15@3x.png'),
    DrawToolObj(index: 16, name: '上45度', iconPath: 'assets/images/hx_icon_16@3x.png'),
    DrawToolObj(index: 17, name: '下45度', iconPath: 'assets/images/hx_icon_17@3x.png'),
    DrawToolObj(index: 18, name: '多圆弧', iconPath: 'assets/images/hx_icon_18@3x.png'),
  ];
}

///multi_windows
final isAndroid_ = Platform.isAndroid;
final isIOS_ = Platform.isIOS;
final isWindows_ = Platform.isWindows;
final isMacOS_ = Platform.isMacOS;
final isLinux_ = Platform.isLinux;
final isWeb_ = false;
final isWebDesktop_ = false;

final isDesktop_ = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

String get screenInfo_ => '';

final isWebOnWindows_ = false;
final isWebOnLinux_ = false;
final isWebOnMacOS_ = false;
