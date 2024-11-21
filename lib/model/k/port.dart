import 'package:flutter/material.dart';
import 'package:trade/model/k/transverse_line.dart';
import 'package:trade/model/k/vertical_line.dart';

import 'OHLCEntity.dart';
import 'golden_line.dart';
import 'oblique_line.dart';

/**
 * 项目中所用到的全局静态变量
 */
class Port {
  /**是否切换了数据时间*/
//	  static bool SWITHING_TIME = false;
  /**是否切换了商品代码*/
//	  static bool SWITHING_CODE = false;
  /**是否切换了指标*/
  static bool SWITHING_INDEX = false;
  /**是否切换了指标周期*/
  static bool SWITHING_PERIOD = false;
  /**是否添加了数据*/
//	  static bool ADD_DATA = false;
  /**是否需要添加数据*/
//	  static bool isAddData = true;
  /**是否到达最后一根数据*/
//	  static bool isReachLast = false;
  /**是否发送方向改变消息*/
//	  static bool isSend = true;
  /**是否绘制下表格*/
  static bool isDrawLower = true;
  /**当前所选K线形态索引*/
//	  static int KLINE_INDEX = 0;
  /**当前屏幕方向标记,默认竖向0*/
  static int orientationFlag = 0;
  /**绘图时屏幕方向识别,默认竖向0*/
  static int drawFlag = 0;
  /**当前所选商品代码*/
//	  static String mCode = Config.initCode;
  /**当前所选周期*/
  static const int mTime = -1;
  /**当前所选市场，默认0齐鲁*/
//	  static int mMarket = Config.initMarketCode;
  /**蜡烛宽度*/
  static double CandleWidth = 3;

  /** 默认画笔线宽*/
  static const double StrokeWidth = 1;

  ///////////////指标线属性////////////////////
  /**MACD	长周期*/
  static int macdLPeriod = 26;
  /**MACD	短周期*/
  static int macdSPeriod = 12;
  /**MACD	周期*/
  static int macdPeriod = 9;
  /**RSI	周期*/
  static int rsiPeriod = 14;
  /**DMI	周期*/
  static int dmiPeriod = 14;
  /**布林线	周期*/
  static int BollingerPeriod = 26;
  /**布林线	标准差*/
  static double BollingerSD = 2;
  /**多空线	周期*/
  static int DKXPeriod = 20;
  /**多空线	周期*/
  static int MADKXPeriod = 10;
  /**均线	周期1*/
  static int CostOnePeriod = 5;
  /**均线	周期2*/
  static int CostTwoPeriod = 10;
  /**均线	周期3*/
  static int CostThreePeriod = 20;
  /**均线	周期4*/
  static int CostFourPeriod = 40;
  /**均线	周期5*/
  static int CostFivePeriod = 60;
  /**瀑布线	周期1*/
  static int FallPeriod1 = 4;
  /**瀑布线	周期2*/
  static int FallPeriod2 = 6;
  /**瀑布线	周期3*/
  static int FallPeriod3 = 9;
  /**瀑布线	周期4*/
  static int FallPeriod4 = 13;
  /**瀑布线	周期5*/
  static int FallPeriod5 = 18;
  /**瀑布线	周期6*/
  static int FallPeriod6 = 24;
  /**鳄鱼线	下巴周期*/
  static int JawPeriod = 13;
  /**鳄鱼线	下巴速度*/
  static int JawSpeed = 8;
  /**鳄鱼线	牙齿周期*/
  static int TeethPeriod = 8;
  /**鳄鱼线	牙齿速度*/
  static int TeethSpeed = 5;
  /**鳄鱼线	嘴唇周期*/
  static int LipsPeriod = 5;
  /**鳄鱼线	嘴唇速度*/
  static int LipsSpeed = 3;
  /**MIKE线	周期*/
  static int MikePeriod = 12;
  /**KDJ周期*/
  static int KDJPeriod = 9;
  /**KDJ m1*/
  static int KDJ_M1 = 3;
  /**KDJ m2*/
  static int KDJ_M2 = 3;
  /**WR1 周期*/
  static int Wr1Period = 10;
  /**WR2 周期*/
  static int Wr2Period = 6;
  /**CCI周期*/
  static int CCIPeriod = 14;
  /**ATR周期*/
  static int ATRPeriod = 14;
  /**BIAS1周期*/
  static int BIAS1Period = 6;
  /**BIAS2周期*/
  static int BIAS2Period = 12;
  /**BIAS3周期*/
  static int BIAS3Period = 24;
  /**PSY周期*/
  static int PSYPeriod = 12;
  /**PSYMA周期*/
  static int PSYMAPeriod = 6;
  /**TRIX周期*/
  static int TRIXPeriod = 12;
  /**MATRIX周期*/
  static int TRIXMAPeriod = 9;
  /**VR周期*/
  static int VRPeriod = 26;
  /**顾比均线周期1*/
  static int GUBIPeriod1 = 3;
  /**顾比均线周期2*/
  static int GUBIPeriod2 = 5;
  /**顾比均线周期3*/
  static int GUBIPeriod3 = 8;
  /**顾比均线周期4*/
  static int GUBIPeriod4 = 10;
  /**顾比均线周期5*/
  static int GUBIPeriod5 = 12;
  /**顾比均线周期6*/
  static int GUBIPeriod6 = 15;
  /**顾比均线周期7*/
  static int GUBIPeriod7 = 30;
  /**顾比均线周期8*/
  static int GUBIPeriod8 = 35;
  /**顾比均线周期9*/
  static int GUBIPeriod9 = 40;
  /**顾比均线周期10*/
  static int GUBIPeriod10 = 45;
  /**顾比均线周期11*/
  static int GUBIPeriod11 = 50;
  /**顾比均线周期12*/
  static int GUBIPeriod12 = 60;

  ///////////////指标线线逻辑判断////////////////////
  /**是否绘制MACD*/
  static bool isDrawMacd = true;
  /**是否绘制RSI*/
  static bool isDrawRsi = false;
  /**是否绘制DMI*/
  static bool isDrawDmi = false;
  /**是否绘制布林线*/
  static bool isDrawBollinger = true;
  /**是否绘制多空线*/
  static bool isDrawDKX = false;
  /**是否绘制均线*/
  static bool isDrawCost = false;
  /**是否绘制均线1*/
  static bool isDrawCost1 = true;
  /**是否绘制均线2*/
  static bool isDrawCost2 = true;
  /**是否绘制均线3*/
  static bool isDrawCost3 = true;
  /**是否绘制均线4*/
  static bool isDrawCost4 = true;
  /**是否绘制均线5*/
  static bool isDrawCost5 = true;
  /**是否绘制瀑布线*/
  static bool isDrawFall = false;
  /**是否绘制鳄鱼线*/
  static bool isDrawAlligator = false;
  /**是否绘制KDJ线*/
  static bool isDrawKDJ = false;
  /**是否绘制WR线*/
  static bool isDrawWR = false;
  /**是否绘制CCI线*/
  static bool isDrawCCI = false;
  /**是否绘制ATR线*/
  static bool isDrawATR = false;
  /**是否绘制BIAS线*/
  static bool isDrawBIAS = false;
  /**是否绘制PSY线*/
  static bool isDrawPSY = false;
  /**是否绘制TRIX线*/
  static bool isDrawTRIX = false;
  /**是否绘制成交量线*/
  static bool isDrawVol = true;
  /**是否绘制VR线*/
  static bool isDrawVR = false;
  /**是否绘制MIKE线*/
  static bool isDrawMIKE = false;
  /**是否绘制顾比均线*/
  static bool isDrawGUBI = false;
  /**均线指标线类型*/
  static int cost_indexType = 0;
  /**均线价格类型*/
  static int cost_priceType = 2;
  /**布林带价格类型*/
  static int Bollinger_priceType = 2;
  /**瀑布线价格类型*/
  static int Fall_priceType = 2;
  /**MACD价格类型*/
  static int MACD_priceType = 2;
  /**RSI价格类型*/
  static int RSI_priceType = 2;
  /**BIAS价格类型*/
  static int BIAS_priceType = 2;
  /**顾比均线指标线类型*/
  static int GUBI_indexType = 0;
  /**类型是否被改变*/
  static bool type_changed = false;

  //////////////////////////////界面风格////////////////////////////////////
  /**引线Color颜色*/
  static Color downLeadColor = const Color.fromRGBO(115, 137, 138, 1);
  /**阳烛上涨Color,默认红色*/
  static Color yangCandleColor = const Color.fromRGBO(255, 32, 74, 1);
  /**阴烛下跌Color,默认绿色*/
  static Color yingCandleColor = const Color.fromRGBO(115, 248, 250, 1);
  /**网格Color,默认黑色*/
  // static Color girdColor = const Color.fromRGBO(110, 0, 0, 1);
  static Color girdColor = const Color.fromRGBO(255, 32, 74, 1);
  /**跳线Color,默认蓝色*/
  static Color jumpColor = const Color.fromRGBO(255, 32, 74, 1);
  /**前景Color,默认绿色*/
  static Color foreGroundColor = const Color.fromRGBO(110, 0, 0, 1);
  /**背景Color,默认白色*/
  static Color backGroundColor = const Color.fromRGBO(21, 24, 37, 1);
  /**文字Color,默认红色*/
  static Color chartTxtColor = const Color.fromRGBO(255, 32, 74, 1);
  /**游标Color,默认黄色*/
  static Color cursorYellowColor = const Color.fromRGBO(255, 240, 0, 1);
  static Color cursorGrayColor = const Color.fromRGBO(172, 172, 172, 1);
  /**竖线Color,默认红色*/
  static Color verticalColor = Colors.red;
  /**横线Color,默认红色*/
  static Color transLineColor = Colors.red;
  /**斜线Color,默认红色*/
  static Color obliqueLineColor = Colors.red;
  /**黄金分割线Color,默认红色*/
  static Color goldenLineColor = Colors.red;

  ///////////////////////K线界面//////////////////////////
  /**是否绘制蜡烛图*/
  static bool isDrawCandle = true;
  /**是否绘制宝塔图*/
  static bool isDrawTower = false;
  /**是否绘制HN图*/
  static bool isDrawHN = false;
//	/**是否绘制辅助线*/
//	  static bool isDrawAssist = false;
//	/**是否绘制横线*/
//	  static bool isDrawTransLine = false;
//	/**是否绘制竖线*/
//	  static bool isDrawVertiLine = false;
//	/**是否绘制斜线*/
//	  static bool isDrawObliLine = false;
//	/**是否绘制黄金分割线*/
//	  static bool isDrawGoldenLine = false;
//	/**宝塔线数据*/
//	 static List<TwrLineData> twrLineDatas =  ArrayList<TwrLineData>();//宝塔线数据
//	/**HN线数据*/
//	 static List<HNLineData> HNLineDatas =  ArrayList<HNLineData>();//hn线数据
  /**后台计算数据*/
  // static List<OHLCEntity> ServiceList =  [];//后台计算数据线数据
//	/**瀑布线智能识别数据*/
//	 static List<IdentifyFall> IFallDatas =  ArrayList<IdentifyFall>();//瀑布线智能识别数据
  /**横线数据*/
  static List<TransverseLine> transverseList = []; //横线数据
  /**竖线数据*/
  static List<VerticalLine> verticalList = []; //竖线数据
  /**斜线数据*/
  static List<ObliqueLine> ObliqueList = []; //斜线数据
  /**黄金分割线数据*/
  static List<GoldenLine> GoldenList = []; //黄金分割线数据
  /**周期一均线颜色*/
  static Color costOneColor = const Color.fromRGBO(255, 255, 255, 1);
  /**周期二均线颜色*/
  static Color costTwoColor = const Color.fromRGBO(255, 240, 0, 1);
  /**周期三均线颜色*/
  static Color costThreeColor = const Color.fromRGBO(255, 14, 235, 1);
  /**周期四均线颜色*/
  static Color costFourColor = const Color.fromRGBO(58, 255, 32, 1);
  /**周期五均线颜色*/
  static Color costFiveColor = const Color.fromRGBO(28, 220, 255, 1);
  /**鳄鱼线鳄颜色*/
  static Color jawColor = const Color.fromRGBO(255, 255, 255, 1);
  /**鳄鱼线齿颜色*/
  static Color teethColor = const Color.fromRGBO(255, 240, 0, 1);
  /**鳄鱼线唇颜色*/
  static Color lipsColor = const Color.fromRGBO(255, 14, 235, 1);
  /**DKX颜色*/
  static Color DKXColor = const Color.fromRGBO(255, 255, 255, 1);
  /**MADKX颜色*/
  static Color MADKXColor = const Color.fromRGBO(130, 240, 0, 1);
  /**Bollinger上线颜色*/
  static Color BollingerUpColor = const Color.fromRGBO(255, 255, 255, 1);
  /**Bollinger中线颜色*/
  static Color BollingerMidColor = const Color.fromRGBO(255, 240, 0, 1);
  /**Bollinger下线颜色*/
  static Color BollingerDownColor = const Color.fromRGBO(255, 14, 235, 1);
  /**瀑布线1颜色*/
  static Color fall1Color = const Color.fromRGBO(255, 255, 255, 1);
  /**瀑布线2颜色*/
  static Color fall2Color = const Color.fromRGBO(255, 240, 0, 1);
  /**瀑布线3颜色*/
  static Color fall3Color = const Color.fromRGBO(255, 14, 235, 1);
  /**瀑布线4颜色*/
  static Color fall4Color = const Color.fromRGBO(58, 255, 32, 1);
  /**瀑布线5颜色*/
  static Color fall5Color = const Color.fromRGBO(28, 220, 255, 1);
  /**瀑布线6颜色*/
  static Color fall6Color = const Color.fromRGBO(255, 120, 0, 1);
  /**MACD快速线颜色*/
  static Color macdFastColor = const Color.fromRGBO(255, 255, 255, 1);
  /**MACD慢速线颜色*/
  static Color macdSlowColor = const Color.fromRGBO(255, 240, 0, 1);
  /**MACD柱状线上颜色*/
  static Color macdUpColor = const Color.fromRGBO(255, 32, 74, 1);
  /**MACD柱状线下颜色*/
  static Color macdDownColor = const Color.fromRGBO(115, 248, 250, 1);
  /**DMI adx颜色*/
  static Color dmiADXColor = const Color.fromRGBO(255, 255, 255, 1);
  /**DMI +DI颜色*/
  static Color dmiUPColor = const Color.fromRGBO(255, 240, 0, 1);
  /**DMI -DI颜色*/
  static Color dmiDownColor = const Color.fromRGBO(255, 14, 235, 1);
  /**RSI颜色*/
  static Color rsiColor = const Color.fromRGBO(255, 255, 255, 1);
  /**KDJ K线颜色*/
  static Color KDJ_KColor = const Color.fromRGBO(255, 255, 255, 1);
  /**KDJ D线颜色*/
  static Color KDJ_DColor = const Color.fromRGBO(255, 240, 0, 1);
  /**KDJ J线颜色*/
  static Color KDJ_JColor = const Color.fromRGBO(255, 14, 235, 1);
  /**WR1线颜色*/
  static Color WR1Color = const Color.fromRGBO(255, 255, 255, 1);
  /**WR2线颜色*/
  static Color WR2Color = const Color.fromRGBO(255, 240, 0, 1);
  /**CCI线颜色*/
  static Color CCIColor = const Color.fromRGBO(255, 255, 255, 1);
  /**ATR线颜色*/
  static Color ATRColor = const Color.fromRGBO(255, 255, 255, 1);
  /**TR线颜色*/
  static Color TRColor = const Color.fromRGBO(255, 240, 0, 1);
  /**BIAS1线颜色*/
  static Color BIAS1Color = const Color.fromRGBO(255, 255, 255, 1);
  /**BIAS2线颜色*/
  static Color BIAS2Color = const Color.fromRGBO(255, 240, 0, 1);
  /**BIAS3线颜色*/
  static Color BIAS3Color = const Color.fromRGBO(255, 14, 235, 1);
  /**PSY线颜色*/
  static Color PSYColor = const Color.fromRGBO(255, 255, 255, 1);
  /**PSYMA线颜色*/
  static Color PSYMAColor = const Color.fromRGBO(255, 240, 0, 1);
  /**TRIX线颜色*/
  static Color TRIXColor = const Color.fromRGBO(255, 255, 255, 1);
  /**TRIXMA线颜色*/
  static Color TRIXMAColor = const Color.fromRGBO(255, 240, 0, 1);
  /**MIKE WR线颜色*/
  static Color MIKE_WRColor = const Color.fromRGBO(255, 255, 255, 1);
  /**MIKE MR线颜色*/
  static Color MIKE_MRColor = const Color.fromRGBO(255, 240, 0, 1);
  /**MIKE SR线颜色*/
  static Color MIKE_SRColor = const Color.fromRGBO(255, 14, 235, 1);
  /**MIKE WS线颜色*/
  static Color MIKE_WSColor = const Color.fromRGBO(58, 255, 32, 1);
  /**MIKE MS线颜色*/
  static Color MIKE_MSColor = const Color.fromRGBO(28, 220, 255, 1);
  /**MIKE SS线颜色*/
  static Color MIKE_SSColor = const Color.fromRGBO(255, 120, 0, 1);
  /**顾比短周期线颜色*/
  static Color GUBI_SColor = const Color.fromRGBO(255, 255, 255, 1);
  /**顾比长周期线颜色*/
  static Color GUBI_LColor = const Color.fromRGBO(255, 240, 0, 1);
  /**成交量涨线颜色*/
  static Color VolUp_Color = const Color.fromRGBO(255, 32, 74, 1);
  /**成交量跌线颜色*/
  static Color VolDown_Color = const Color.fromRGBO(115, 248, 250, 1);
  /**成交量平线颜色*/
  static Color VolEqu_Color = const Color.fromRGBO(255, 255, 255, 1);
  /**VR线颜色*/
  static Color VR_Color = const Color.fromRGBO(255, 32, 74, 1);
  /**周期一均线宽度*/
  static List<double> costWidth = [1, 1, 1, 1, 1];
  /**鳄鱼线鳄宽度*/
  static List<int> alligatorWidth = [1, 1, 1];
  /**DKX宽度*/
  static List<double> DKXWidth = [1, 1];
  /**Bollinger上线宽度*/
  static List<double> BollingerWidth = [1, 1, 1];
  /**瀑布线1宽度*/
  static List<double> fallWidth = [1, 1, 1, 1, 1, 1];
  /**MACD快速线宽度*/
  static List<double> macdWidth = [1, 1, 2, 2];
  /**DMI adx宽度*/
  static List<double> dmiWidth = [1, 1, 1];
  /**KDJ 宽度*/
  static List<double> KDJWidth = [1, 1, 1];
  /**WR 宽度*/
  static List<double> WRWidth = [1, 1];
  /**CCI 宽度*/
  static List<double> CCIWidth = [1];
  /**ATR 宽度*/
  static List<double> ATRWidth = [1, 1];
  /**BIAS 宽度*/
  static List<double> BIASWidth = [1, 1, 1];
  /**PSY 宽度*/
  static List<double> PSYWidth = [1, 1];
  /**TRIX 宽度*/
  static List<double> TRIXWidth = [1, 1];
  /**MIKE 宽度*/
  static List<double> MIKEWidth = [1, 1, 1, 1, 1, 1];
  /**顾比均线 宽度*/
  static List<double> GUBIWidth = [1, 1];
  /**RSI宽度*/
  static double rsiWidth = 1;
  /**图表字体大小，单位dp,需要适配转化为px使用*/
  static double ChartTextSize = 14;
  static double defult_margin_top = 12;
  static double defult_icon_width = 25;
  static double text_check = 10;

  //////////智能决策////////////
  /**是否使用瀑布线智能决策*/
  static bool isSmartFall = false;
  /**切换了智能系统*/
  static bool isSwithSmart = false;
  /**是否第一次打开三体智能*/
  static bool isFirstSmart = false;
  /**是否打开三体推送*/
  static bool isSmartPro = true;
  /**是否打开三体声音*/
  static bool isSmartVoice = true;
  /**是否打开三体震动*/
  static bool isSmartVibi = true;
  ////////////分时图////////////
  /**是否绘制分时图*/
  static bool isDrawTime = true;
}
