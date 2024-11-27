import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../../model/k/OHLCEntity.dart';
import '../../../model/k/k_chart_data/AlligatorEntity.dart';
import '../../../model/k/k_chart_data/BIASEntity.dart';
import '../../../model/k/k_chart_data/BollingerEntity.dart';
import '../../../model/k/k_chart_data/CCIEntity.dart';
import '../../../model/k/k_chart_data/CostLineEntity.dart';
import '../../../model/k/k_chart_data/FallLineEntity.dart';
import '../../../model/k/k_chart_data/KDJEntity.dart';
import '../../../model/k/k_chart_data/MACDEntity.dart';
import '../../../model/k/k_chart_data/PSYEntity.dart';
import '../../../model/k/k_chart_data/RSIEntity.dart';
import '../../../model/k/k_chart_data/VREntity.dart';
import '../../../model/k/k_chart_data/VolEntity.dart';
import '../../../model/k/k_chart_data/WREntity.dart';
import '../../../model/k/k_preiod.dart';
import '../../../model/k/port.dart';
import '../../../model/k/trade_time.dart';
import '../../log/log.dart';
import '../../utils/k_util.dart';
import '../../utils/utils.dart';
import 'base_k_chart_painter.dart';
import 'crossLine_view.dart';
import 'method_util.dart';

class SubChartPainter extends CustomPainter {
  /// MACD数据
  MACDEntity? mMACDData;

  /// RSI数据
  RSIEntity? mRSIData;

  /// KDJ线数据
  KDJEntity? mKDJData;

  /// WR线数据
  WREntity? mWRData;

  /// CCI线数据
  CCIEntity? mCCIData;

  /// BIAS线数据
  BIASEntity? mBIASData;

  /// PSY线数据
  PSYEntity? mPSYData;

  /// 成交量线数据
  VolEntity? mVolData;

  /// VR线数据
  VREntity? mVRData;

  /////////////指标线属性////////////////////
  /// MACD	长周期
  static int macdLPeriod = 26;

  /// MACD	短周期
  static int macdSPeriod = 12;

  /// MACD	周期
  static int macdPeriod = 9;

  /// RSI	周期
  static int rsiPeriod = 14;

  /// KDJ周期
  static int KDJPeriod = 9;

  /// KDJ m1
  static int KDJ_M1 = 3;

  /// KDJ m2
  static int KDJ_M2 = 3;

  /// WR1 周期
  static int Wr1Period = 10;

  /// WR2 周期
  static int Wr2Period = 6;

  /// CCI周期
  static int CCIPeriod = 14;

  /// BIAS1周期
  static int BIAS1Period = 6;

  /// BIAS2周期
  static int BIAS2Period = 12;

  /// BIAS3周期
  static int BIAS3Period = 24;

  /// PSY周期
  static int PSYPeriod = 12;

  /// PSYMA周期
  static int PSYMAPeriod = 6;

  /// VR线周期12
  static int VRPeriod = 26;

  int CANDLE_INTERVAL = 2;
  double timeDownChartHeight = 1;
  List<OHLCEntity> mOHLCData = [];
  static double leftMarginSpace = getStringWidth("000.000", TextPainter(), size: Port.ChartTextSize);
  static double halfTextHeight = getStringHeight("0", TextPainter(), size: Port.ChartTextSize) / 2;
  TextPainter textPaint = TextPainter();
  bool isDrawVOL = true;
  bool isDrawVR = false;
  bool isDrawMACD = false;
  bool isDrawKDJ = false;
  bool isDrawRSI = false;
  bool isDrawCCI = false;
  bool isDrawBIAS = false;
  bool isDrawOBV = false;
  bool isDrawWR = false;
  bool isDrawDMA = false;
  bool isDrawPSY = false;
  bool isDrawMACDBANG = false;
  double mCandleWidth = Port.CandleWidth;
  int mDataStartIndext = 0;
  int mShowDataNum = 180;

  SubChartPainter({
    required this.mCandleWidth,
    required this.mDataStartIndext,
    required this.mShowDataNum,
    required this.isDrawVOL,
    required this.isDrawVR,
    required this.isDrawMACD,
    required this.isDrawKDJ,
    required this.isDrawRSI,
    required this.isDrawCCI,
    required this.isDrawBIAS,
    required this.isDrawOBV,
    required this.isDrawWR,
    required this.isDrawDMA,
    required this.isDrawPSY,
    required this.isDrawMACDBANG,
    required this.mOHLCData,
    required this.mMACDData,
    required this.mRSIData,
    required this.mKDJData,
    required this.mWRData,
    required this.mCCIData,
    required this.mBIASData,
    required this.mPSYData,
    required this.mVolData,
    required this.mVRData,
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    if (mOHLCData.isEmpty) {
      return;
    }
    drawUpperRegion(canvas, size);
    drawBorders(canvas, size.height, size.width);
  }

  void drawUpperRegion(Canvas canvas, Size size) {
    //绘制MACD
    if (isDrawMACD && mMACDData != null) {
      //绘制MACD
      mMACDData?.drawMACD(canvas, size.height, size.width, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, leftMarginSpace, halfTextHeight,
          macdLPeriod, macdSPeriod, macdPeriod);
    }

    //绘制RSI
    if (isDrawRSI && mRSIData != null) {
      mRSIData?.drawRSI(
          canvas, size.height, size.width, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, leftMarginSpace, halfTextHeight, rsiPeriod);
    }

    //绘制KDJ
    if (isDrawKDJ && mKDJData != null) {
      mKDJData?.drawKDJ(canvas, size.height, size.width, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, leftMarginSpace, halfTextHeight,
          KDJPeriod, KDJ_M1, KDJ_M2);
    }

    //绘制WR
    if (isDrawWR && mWRData != null) {
      mWRData?.drawWR(canvas,  size.height, size.width, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, leftMarginSpace, halfTextHeight, Wr1Period, Wr2Period);
    }

    //绘制CCI
    if (isDrawCCI && mCCIData != null) {
      mCCIData?.drawCCI(
          canvas, size.height, size.width, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, leftMarginSpace, halfTextHeight, CCIPeriod);
    }

    //绘制BIAS
    if (isDrawBIAS && mBIASData != null) {
      mBIASData?.drawBIAS(canvas, size.height, size.width, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, leftMarginSpace, halfTextHeight, BIAS1Period, BIAS2Period, BIAS3Period);
    }

    //绘制PSY
    if (isDrawPSY && mPSYData != null) {
      mPSYData?.drawPSY(canvas,  size.height, size.width, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, leftMarginSpace, halfTextHeight, PSYPeriod, PSYMAPeriod);
    }

    //绘制成交量
    if (isDrawVOL && mVolData != null) {
      mVolData?.drawVol(canvas,  size.height, size.width, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, leftMarginSpace, halfTextHeight);
    }

    //绘制vr
    if (isDrawVR && mVRData != null) {
      mVRData?.drawVR(canvas, size.height, size.width, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, leftMarginSpace, halfTextHeight, VRPeriod);
    }
  }

  void drawBorders(Canvas canvas, double viewHeight, double viewWidth) {
    Paint girdPaint = MethodUntil().getDrawPaint(Port.girdColor);
    canvas.drawLine(Offset(leftMarginSpace, 0), Offset(leftMarginSpace, viewHeight), girdPaint);
    canvas.drawLine(Offset(0, viewHeight), Offset(viewWidth, viewHeight), girdPaint);
  }

  static double getStringWidth(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? Port.ChartTextSize))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.width;
  }

  static double getStringHeight(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? Port.ChartTextSize))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.height;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    throw UnimplementedError();
  }
}
