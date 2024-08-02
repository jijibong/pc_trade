import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../../model/k/OHLCEntity.dart';
import '../../../model/k/k_chart_data/ATREntity.dart';
import '../../../model/k/k_chart_data/AlligatorEntity.dart';
import '../../../model/k/k_chart_data/BIASEntity.dart';
import '../../../model/k/k_chart_data/BollingerEntity.dart';
import '../../../model/k/k_chart_data/CCIEntity.dart';
import '../../../model/k/k_chart_data/CostLineEntity.dart';
import '../../../model/k/k_chart_data/DKXEntity.dart';
import '../../../model/k/k_chart_data/DMIEntity.dart';
import '../../../model/k/k_chart_data/FallLineEntity.dart';
import '../../../model/k/k_chart_data/GUBIEntity.dart';
import '../../../model/k/k_chart_data/KDJEntity.dart';
import '../../../model/k/k_chart_data/MACDEntity.dart';
import '../../../model/k/k_chart_data/MIKEEntity.dart';
import '../../../model/k/k_chart_data/PSYEntity.dart';
import '../../../model/k/k_chart_data/RSIEntity.dart';
import '../../../model/k/k_chart_data/TRIXEntity.dart';
import '../../../model/k/k_chart_data/VREntity.dart';
import '../../../model/k/k_chart_data/VolEntity.dart';
import '../../../model/k/k_chart_data/WREntity.dart';
import '../../../model/k/k_preiod.dart';
import '../../../model/k/port.dart';
import '../../../model/k/trade_time.dart';
import '../../event_bus/eventBus_utils.dart';
import '../../event_bus/events.dart';
import '../../log/log.dart';
import '../../utils/k_util.dart';
import '../../utils/utils.dart';
import 'base_k_chart_painter.dart';
import 'crossLine_view.dart';
import 'method_util.dart';

class ChartPainter extends BaseKChartPainter {
  Color DEFAULT_AXIS_Y_TEXT_COLOR = Colors.black;
  Color DEFAULT_AXIS_X_TEXT_COLOR = Colors.black;
  int MIN_MOVE_DISTANCE = 15;
  int CANDLE_INTERVAL = 2;
  double MIN_CANDLE_WIDTH = 3;
  double DEFAULT_CANDLE_WIDTH = 9;
  Color whiteColor = const Color.fromRGBO(255, 255, 255, 1);
  double timeDownChartHeight = 1;
  double mPointWidth = 1;
  List<OHLCEntity> mOHLCData = [];
  List<OHLCEntity> mDayList = [];
  int mTimeStartIndext = 0;
  int mTimeShowNum = 1380;
  int mShowNum = 35, mStartIndex = 0;
  double timeMarginRight = getStringWidth("00000000", TextPainter());
  double timeMarginLeft = getStringWidth("00000000", TextPainter());
  int mPreSize = 0;
  int mOrder = 0;
  static double lastClose = 0;
  String chartExCode = "";
  String chartCode = "";
  /** 十字线辅助绘制 */
  late CrossLineView mCrossLineView;
  // 下部表的数据
  /** MACD数据 */
  MACDEntity? mMACDData;
  /** DMI数据 */
  DMIEntity? mDMIData;
  /** RSI数据 */
  RSIEntity? mRSIData;
  /** 布林带数据 */
  BollingerEntity? mBollingerData;
  /** 多空线数据 */
  DKXEntity? mDKXData;
  /** 均线数据 */
  CostLineEntity? mCostData;
  /** 瀑布线数据 */
  FallLineEntity? mFallData;
  /** 鳄鱼线数据 */
  AlligatorEntity? mAlligatorData;
  /** KDJ线数据 */
  KDJEntity? mKDJData;
  /** WR线数据 */
  WREntity? mWRData;
  /** CCI线数据 */
  CCIEntity? mCCIData;
  /** ATR线数据 */
  ATREntity? mATRData;
  /** BIAS线数据 */
  BIASEntity? mBIASData;
  /** PSY线数据 */
  PSYEntity? mPSYData;
  /** TRIX线数据 */
  TRIXEntity? mTRIXData;
  /** MIKE线数据 */
  MIKEEntity? mMIKEData;
  /** MIKE线数据 */
  GUBIEntity? mGUBIData;
  /** 成交量线数据 */
  VolEntity? mVolData;
  /** VR线数据 */
  VREntity? mVRData;

  /////////////指标线属性////////////////////
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
  static double BollingerSD = 2.000;
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
  /**VR线周期12*/
  static int VRPeriod = 26;

  Paint yangPaint = Paint();
  Paint yingPaint = Paint();
  TextPainter redPaint = TextPainter();
  TextPainter greenPaint = TextPainter();
  Paint cursorPaint = MethodUntil().getDrawPaint(Port.cursorYellowColor); //游标画笔
  Paint girdPaint = MethodUntil().getDrawPaint(Port.girdColor); //网格画笔
  Paint whitePaint = MethodUntil().getDrawPaint(const Color.fromRGBO(255, 255, 255, 1)); //白色画笔
  Paint bluePaint = MethodUntil().getDrawPaint(const Color.fromRGBO(28, 220, 255, 1)); //蓝色画笔
  Paint yellowPaint = MethodUntil().getDrawPaint(const Color.fromRGBO(255, 240, 0, 1)); //黄色画笔
  TextPainter textPaint = TextPainter();
  bool SWITHING_TIME = false;
  bool SWITHING_CODE = false;
  bool SWITHING_INDEX = false;
  bool SWITHING_PERIOD = false;
  bool ADD_DATA = false;
  bool type_changed = false;
  bool isReachLast = false;
  bool isSend = true;

  bool isDrawMacd = true;
  bool isDrawRsi = false;
  bool isDrawDmi = false;
  bool isDrawBollinger = true;
  bool isDrawDKX = false;
  bool isDrawCost = false;
  bool isDrawCost1 = true;
  bool isDrawCost2 = true;
  bool isDrawCost3 = false;
  bool isDrawCost4 = false;
  bool isDrawCost5 = true;
  bool isDrawFall = false;
  bool isDrawAlligator = false;
  bool isDrawKDJ = false;
  bool isDrawWR = false;
  bool isDrawCCI = false;
  bool isDrawATR = false;
  bool isDrawBIAS = false;
  bool isDrawPSY = false;
  bool isDrawTRIX = false;
  bool isDrawMIKE = false;
  bool isDrawGUBI = false;
  bool isDrawVolume = true;
  bool isDrawVR = false;
  bool isDrawCrossLine = false;
  bool isDrawCandle = true;
  bool isDrawTower = false;
  bool isDrawHN = false;
  bool isSmartFall = false;
  bool isSwithSmart = false;
  bool isFirstSmart = false;
  static List<TradeTime> mTradeTimes = [];
  static List<String> mFsTimes = [];
  static int mFsCount = 0;
  double kChartViewHeight = 0;
  static double kChartViewWidth = 0;
  KPeriod mKPeriod = KPeriod();
  double mCandleWidth = Port.CandleWidth;
  double mMaxPrice = -1;
  double mMinPrice = -1;
  double currentX = -1;
  double currentY = -1;
  double mChartWidth = 0;
  int mDataStartIndext = 0;
  int mShowDataNum = 180;
  int MIN_CANDLE_NUM = 12;
  bool isDrawTime = true;
  bool isDrawTimeDown = true;

  ChartPainter({
    required this.isDrawTime,
    required this.mKPeriod,
    required this.mOHLCData,
    required this.SWITHING_TIME,
    required this.SWITHING_CODE,
    required this.SWITHING_INDEX,
    required this.SWITHING_PERIOD,
    required this.ADD_DATA,
    required this.type_changed,
    required this.mCandleWidth,
    required this.mChartWidth,
    required this.mMaxPrice,
    required this.mMinPrice,
    required this.currentX,
    required this.currentY,
    required this.mDataStartIndext,
    required this.mShowDataNum,
    required this.MIN_CANDLE_NUM,
    required this.isDrawMacd,
    required this.isDrawRsi,
    required this.isDrawDmi,
    required this.isDrawBollinger,
    required this.isDrawDKX,
    required this.isDrawCost,
    required this.isDrawCost1,
    required this.isDrawCost2,
    required this.isDrawCost3,
    required this.isDrawCost4,
    required this.isDrawCost5,
    required this.isDrawFall,
    required this.isDrawAlligator,
    required this.isDrawKDJ,
    required this.isDrawWR,
    required this.isDrawCCI,
    required this.isDrawATR,
    required this.isDrawBIAS,
    required this.isDrawPSY,
    required this.isDrawTRIX,
    required this.isDrawMIKE,
    required this.isDrawGUBI,
    required this.isDrawVolume,
    required this.isDrawVR,
    required this.isDrawCrossLine,
    required this.mPreSize,
    required this.mMACDData,
    required this.mDMIData,
    required this.mRSIData,
    required this.mBollingerData,
    required this.mDKXData,
    required this.mCostData,
    required this.mFallData,
    required this.mAlligatorData,
    required this.mKDJData,
    required this.mWRData,
    required this.mCCIData,
    required this.mATRData,
    required this.mBIASData,
    required this.mPSYData,
    required this.mTRIXData,
    required this.mMIKEData,
    required this.mGUBIData,
    required this.mVolData,
    required this.mVRData,
    required this.isDrawTimeDown,
  }) : super(isDrawTime: isDrawTime) {
    EventBusUtil.getInstance().on<QuoteEvent>().listen((event) {});
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    kChartViewHeight = size.height;
    kChartViewWidth = size.width;
    Port.drawFlag = 0;
    if (mOHLCData.isEmpty) {
      return;
    }
    if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
      return;
    }
    canvas.save();
    if (isDrawTime) {
      timeMarginLeft = 2.0;
      timeMarginRight = 2.0;
      int number = 1380;
      if (mFsCount != 0) {
        number = mFsCount;
      } else {
        if (chartExCode == "股票") {
          number = 240;
        } else {
          number = 1380;
        }
      }

      mPointWidth = (size.width - timeMarginLeft - timeMarginRight) / number;

      if (mPointWidth == 0) return;
      timeDownChartHeight = isDrawTimeDown == true ? (size.height - MARGINBOTTOM - MARGINTOP) / (DEFAULT_TIME_LATITUDE_NUM + 1) * 3 : 0;
      num latitudeSpacing = (size.height - MARGINBOTTOM - MARGINTOP - timeDownChartHeight) / (DEFAULT_TIME_LATITUDE_NUM + 1);
      num longitudeSpacing = (size.width - timeMarginLeft - timeMarginRight) / (DEFAULT_TIME_LOGITUDE_NUM + 1);
      _drawLatitudes(canvas, latitudeSpacing);
      _drawLongitudes(canvas, longitudeSpacing);
      _drawTimeUpper(canvas, longitudeSpacing);
    } else {
      mRightArea = BaseKChartPainter.mCursorWidth;
      _drawUpperRegion(canvas);
      _drawAssistLine(canvas);
      _drawTitles(canvas);
    }
    canvas.restore();
  }

  void _drawLatitudes(Canvas canvas, num latitudeSpacing) {
    girdPaint
      ..color = Port.girdColor
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 0.5;

    for (int i = 1; i <= DEFAULT_TIME_LATITUDE_NUM; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(timeMarginLeft, MARGINTOP + latitudeSpacing * i);
      path.lineTo(kChartViewWidth - timeMarginRight, MARGINTOP + latitudeSpacing * i);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        girdPaint,
      );
    }

    lastClose = lastClose == 0 ? mMinPrice + ((mMaxPrice - mMinPrice) / 2) : lastClose;
    double max = mMaxPrice;
    double min = mMinPrice;
    double maxHeight = (max - lastClose) > (lastClose - min) ? (max - lastClose) : (lastClose - min);
    double perPrice = maxHeight / 4;
    for (int i = 3; i > 0; i--) {
      String text = Utils.getPointNum(lastClose + perPrice * (4 - i));
      double percent = (perPrice * (4 - i)) / lastClose * 100;
      String textPercent = "${Utils.getLimitNum(percent, 2)}%";
      double leftX = 0, leftY = 0, rightX = 0;
      leftX = timeMarginLeft;
      leftY = MARGINTOP + latitudeSpacing * i;
      rightX = kChartViewWidth - getStringWidth(textPercent, redPaint, size: DEFAULT_AXIS_TITLE_SIZE);
      redPaint
        ..text = TextSpan(text: text, style: TextStyle(color: const Color.fromRGBO(230, 56, 89, 1), fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(leftX, leftY));
      redPaint
        ..text = TextSpan(text: textPercent, style: TextStyle(color: const Color.fromRGBO(230, 56, 89, 1), fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(rightX, leftY));
    }

    for (int i = 7; i > 4; i--) {
      String text = Utils.getPointNum(lastClose - perPrice * (i - 4));
      double percent = (perPrice * (i - 4)) / lastClose * 100;
      String textPercent = "-${Utils.getLimitNum(percent, 2)}%";
      double leftX = 0, leftY = 0, rightX = 0;
      if (Port.drawFlag == 1) {
        leftX = timeMarginLeft - getStringWidth(text, greenPaint);
        leftY = MARGINTOP + latitudeSpacing * i + getStringHeight(text, greenPaint) / 2;
        rightX = kChartViewWidth - timeMarginRight;
      } else {
        leftX = timeMarginLeft;
        leftY = MARGINTOP + latitudeSpacing * i;
        rightX = kChartViewWidth - getStringWidth(textPercent, greenPaint, size: DEFAULT_AXIS_TITLE_SIZE);
      }
      greenPaint
        ..text = TextSpan(text: text, style: TextStyle(color: const Color.fromRGBO(58, 255, 32, 1), fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(leftX, leftY));
      greenPaint
        ..text = TextSpan(text: textPercent, style: TextStyle(color: const Color.fromRGBO(58, 255, 32, 1), fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(rightX, leftY));
    }
    double leftX = 0, leftY = 0, rightX = 0;
    leftX = timeMarginLeft;
    leftY = MARGINTOP + latitudeSpacing * 4;
    rightX = kChartViewWidth - getStringWidth("0.00%", textPaint, size: DEFAULT_AXIS_TITLE_SIZE);
    redPaint
      ..text = TextSpan(text: Utils.getPointNum(lastClose), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftX, leftY));
    redPaint
      ..text = TextSpan(text: "0.00%", style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(rightX, leftY));
  }

  void _drawLongitudes(Canvas canvas, num longitudeSpacing) {
    Paint paint = Paint()
      ..color = Port.girdColor
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 1;

    if (mFsTimes.isNotEmpty) {
      drawTime(canvas, paint, textPaint);
    } else {
      for (int i = 1; i <= DEFAULT_TIME_LOGITUDE_NUM; i++) {
        Path path = Path(); // 绘制虚线
        path.moveTo(timeMarginLeft + longitudeSpacing * i, MARGINTOP.toDouble());
        path.lineTo(timeMarginLeft + longitudeSpacing * i, TIME_UPER_CHART_BOTTOM);
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawTimeUpper(Canvas canvas, num longitudeSpacing) {
    bluePaint.strokeWidth = 1;
    yellowPaint.strokeWidth = 1;
    double closeY = 0.0;
    double averageY = 0.0;
    double nextCloseY = 0.0;
    double nextAverageY = 0.0;
    double startX = 0.0;
    double nextX = 0.0;
    lastClose = lastClose == 0 ? mMinPrice + ((mMaxPrice - mMinPrice) / 2) : lastClose;
    double max = mMaxPrice;
    double min = mMinPrice;
    double maxHeight = (max - lastClose) > (lastClose - min) ? (max - lastClose) : (lastClose - min); //最大价差
    max = lastClose + maxHeight;
    min = lastClose - maxHeight;
    double rate = (kChartViewHeight - MARGINBOTTOM - MARGINTOP - timeDownChartHeight) / (max - min); //计算最小单位
    if (rate.isInfinite) {
      logger.d("rate.isInfinite  max:$max   min:$max   lastClose:$lastClose");
      return;
    }
    int showNum = 0;
    showNum = (kChartViewWidth - timeMarginLeft - timeMarginRight) ~/ mPointWidth;
    for (int i = 0; i < showNum; i++) {
      int num = (i + 1) >= showNum ? showNum - 1 : i + 1;
      startX = mPointWidth * i + timeMarginLeft;
      nextX = mPointWidth * num + timeMarginLeft;
      if (i >= mOHLCData.length) break;

      if (i < mOHLCData.length) {
        int next = (i + 1) >= mOHLCData.length ? mOHLCData.length - 1 : i + 1;
        closeY = (max - (mOHLCData[i].close ?? 0)) * rate + MARGINTOP;
        averageY = (max - (mOHLCData[i].average ?? 0)) * rate + MARGINTOP;
        nextCloseY = (max - (mOHLCData[next].close ?? 0)) * rate + MARGINTOP;
        nextAverageY = (max - (mOHLCData[next].average ?? 0)) * rate + MARGINTOP;
        canvas.drawLine(Offset(startX, closeY), Offset(nextX, nextCloseY), bluePaint); //绘制收盘价
        canvas.drawLine(Offset(startX, averageY), Offset(nextX, nextAverageY), yellowPaint); //绘制收盘价
      }
    }
    //绘制成交量
    if (mVolData != null && isDrawTimeDown) {
      mVolData?.drawFenshiVol(canvas, kChartViewHeight, kChartViewWidth, mPointWidth, BaseKChartPainter.TimeMarginLeft, MARGINBOTTOM, TIME_LOWER_CHART_TOP,
          BaseKChartPainter.TimeMarginRight);
    }

    //绘制十字线
    if (currentX != -1 && currentY != -1 && isDrawCrossLine) {
      num lowerHeight = kChartViewHeight - MARGINBOTTOM - TIME_LOWER_CHART_TOP;
      CrossLineView.drawCrossLine(canvas, kChartViewHeight, kChartViewWidth, lowerHeight, currentX, currentY, mPointWidth, MARGINTOP, MARGINBOTTOM,
          timeMarginLeft, timeMarginRight, showNum, 0, mOHLCData, isDrawTime, lastClose, mKPeriod);
    }
  }

  void _drawUpperRegion(Canvas canvas) {
    yangPaint
      ..color = Port.yangCandleColor
      ..strokeWidth = Port.StrokeWidth
      ..style = PaintingStyle.stroke;
    yingPaint
      ..color = Port.yingCandleColor
      ..strokeWidth = Port.StrokeWidth;
    whitePaint.color = Colors.white;

    double rate = (mUperChartHeight - DEFAULT_AXIS_TITLE_SIZE - 10) / (mMaxPrice - mMinPrice); //计算最小单位
    double textBottom = MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 10;
    for (int i = 0; i < mShowDataNum && mDataStartIndext + i < mOHLCData.length; i++) {
      OHLCEntity entity = mOHLCData[mDataStartIndext + i];
      String date = "${entity.date} ${entity.time?.substring(0, 5)}";

      double startX = BaseKChartPainter.MARGINLEFT + mCandleWidth * i + mCandleWidth;
      double left = startX - (mCandleWidth - CANDLE_INTERVAL) / 2;
      double right = startX + (mCandleWidth - CANDLE_INTERVAL) / 2;

      //绘制K线
      if (isDrawCandle) {
        double open = (mMaxPrice - (entity.open ?? 0)) * rate + textBottom;
        double close = (mMaxPrice - (entity.close ?? 0)) * rate + textBottom;
        double high = (mMaxPrice - (entity.high ?? 0)) * rate + textBottom;
        double low = (mMaxPrice - (entity.low ?? 0)) * rate + textBottom;
        if (open < close) {
          canvas.drawLine(Offset(startX, high), Offset(startX, low), yingPaint);
          canvas.drawRect(Rect.fromLTRB(left, open, right, close), yingPaint);
        } else if (open == close) {
          canvas.drawLine(Offset(left, open), Offset(right, open), whitePaint);
          canvas.drawLine(Offset(startX, high), Offset(startX, low), whitePaint);
        } else {
          if (high < close) canvas.drawLine(Offset(startX, high), Offset(startX, close), yangPaint);
          if (low > open) canvas.drawLine(Offset(startX, open), Offset(startX, low), yangPaint);
          canvas.drawRect(Rect.fromLTRB(left, close, right, open), yangPaint);
        }
      }

      //绘制日期
      double y = kChartViewHeight - MARGINBOTTOM / 2;
      if (i == 0) {
        double x = BaseKChartPainter.MARGINLEFT + mCandleWidth * i + mCandleWidth / 2;
        textPaint
          ..text = TextSpan(text: date, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(x, y));
      } else if (i == mShowDataNum - 1) {
        double x = (BaseKChartPainter.MARGINLEFT + mCandleWidth * i + 2 * mCandleWidth + mCandleWidth / 2) -
            getStringWidth(date, textPaint, size: DEFAULT_AXIS_TITLE_SIZE + 2);
        textPaint
          ..text = TextSpan(text: date, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(x, y));
      }
    }

    //绘制价格指示线
    double closeHigh = (mMaxPrice - (mOHLCData[mOHLCData.length - 1].close ?? 0)) * rate + textBottom;
    if (closeHigh <= mUperChartHeight + MARGINTOP && closeHigh >= 0) {
      if (mDataStartIndext + mShowDataNum < mOHLCData.length) {
        cursorPaint.color = Port.cursorGrayColor;
      } else {
        cursorPaint.color = Port.cursorYellowColor;
      }

      Path path = Path();
      path.moveTo(BaseKChartPainter.MARGINLEFT + mChartWidth, closeHigh);
      path.lineTo(BaseKChartPainter.MARGINLEFT + mChartWidth + BaseKChartPainter.mCursorWidth, closeHigh - 3);
      path.lineTo(BaseKChartPainter.MARGINLEFT + mChartWidth + BaseKChartPainter.mCursorWidth, closeHigh + 3);
      path.close();
      canvas.drawPath(path, cursorPaint);
    }
    drawHighLowPoint(canvas, rate, textBottom);
    //绘制鳄鱼线
    if (isDrawAlligator && mAlligatorData != null) {
      mAlligatorData?.drawAlligator(canvas, mDataStartIndext, mShowDataNum, mCandleWidth, mMaxPrice, mMinPrice, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT,
          MARGINTOP, mUperChartHeight, JawPeriod, JawSpeed, TeethPeriod, TeethSpeed, LipsPeriod, LipsSpeed);
    }

    //绘制瀑布线
    if (isDrawFall && isSmartFall == false && mFallData != null) {
      mFallData?.drawFall(canvas, mDataStartIndext, mShowDataNum, mCandleWidth, mMaxPrice, mMinPrice, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT, MARGINTOP,
          mUperChartHeight, FallPeriod1, FallPeriod2, FallPeriod3, FallPeriod4, FallPeriod5, FallPeriod6);
    }

    //绘制均线
    if (isDrawCost && mCostData != null) {
      mCostData?.drawCOST(
          canvas,
          mDataStartIndext,
          mShowDataNum,
          mCandleWidth,
          mMaxPrice,
          mMinPrice,
          CANDLE_INTERVAL,
          BaseKChartPainter.MARGINLEFT,
          MARGINTOP,
          mUperChartHeight,
          CostOnePeriod,
          CostTwoPeriod,
          CostThreePeriod,
          CostFourPeriod,
          CostFivePeriod,
          isDrawCost1,
          isDrawCost2,
          isDrawCost3,
          isDrawCost4,
          isDrawCost5);
    }

    //顾比均线
    if (isDrawGUBI && mGUBIData != null) {
      mGUBIData?.drawGUBI(
          canvas,
          mDataStartIndext,
          mShowDataNum,
          mCandleWidth,
          mMaxPrice,
          mMinPrice,
          CANDLE_INTERVAL,
          BaseKChartPainter.MARGINLEFT,
          MARGINTOP,
          mUperChartHeight,
          GUBIPeriod1,
          GUBIPeriod2,
          GUBIPeriod3,
          GUBIPeriod4,
          GUBIPeriod5,
          GUBIPeriod6,
          GUBIPeriod7,
          GUBIPeriod8,
          GUBIPeriod9,
          GUBIPeriod10,
          GUBIPeriod11,
          GUBIPeriod12);
    }

    //绘制DKX
    if (isDrawDKX && mDKXData != null) {
      mDKXData?.drawDKX(canvas, mDataStartIndext, mShowDataNum, mCandleWidth, mMaxPrice, mMinPrice, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT, MARGINTOP,
          mUperChartHeight, DKXPeriod, MADKXPeriod);
    }

    //绘制布林线
    if (isDrawBollinger && mBollingerData != null) {
      mBollingerData?.drawBollinger(canvas, mDataStartIndext, mShowDataNum, mCandleWidth, mMaxPrice, mMinPrice, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT,
          MARGINTOP, mUperChartHeight, BollingerPeriod, BollingerSD);
    }

    //绘制MIKE线
    if (isDrawMIKE && mMIKEData != null) {
      mMIKEData?.drawMIKE(canvas, mDataStartIndext, mShowDataNum, mCandleWidth, mMaxPrice, mMinPrice, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT, MARGINTOP,
          mUperChartHeight, MikePeriod);
    }

    //绘制MACD
    if (isDrawMacd && mMACDData != null) {
      //绘制MACD
      mMACDData?.drawMacd(canvas, kChartViewHeight, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL,
          BaseKChartPainter.MARGINLEFT, MARGINBOTTOM, BaseKChartPainter.LOWER_CHART_TOP, mRightArea, macdLPeriod, macdSPeriod, macdPeriod);
    }

    //绘制RSI
    if (isDrawRsi && mRSIData != null) {
      mRSIData?.drawRsi(canvas, kChartViewHeight, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT,
          MARGINBOTTOM, BaseKChartPainter.LOWER_CHART_TOP, mRightArea, rsiPeriod);
    }

    //绘制DMI
    if (isDrawDmi && mDMIData != null) {
      mDMIData?.drawDmi(canvas, kChartViewHeight, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT,
          MARGINBOTTOM, BaseKChartPainter.LOWER_CHART_TOP, mRightArea, dmiPeriod);
    }

    //绘制KDJ
    if (isDrawKDJ && mKDJData != null) {
      mKDJData?.drawKDJ(canvas, kChartViewHeight, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT,
          MARGINBOTTOM, BaseKChartPainter.LOWER_CHART_TOP, mRightArea, KDJPeriod, KDJ_M1, KDJ_M2);
    }

    //绘制WR
    if (isDrawWR && mWRData != null) {
      mWRData?.drawWR(canvas, kChartViewHeight, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT,
          MARGINBOTTOM, BaseKChartPainter.LOWER_CHART_TOP, mRightArea, Wr1Period, Wr2Period);
    }

    //绘制CCI
    if (isDrawCCI && mCCIData != null) {
      mCCIData?.drawCCI(canvas, kChartViewHeight, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT,
          MARGINBOTTOM, BaseKChartPainter.LOWER_CHART_TOP, mRightArea, CCIPeriod);
    }

    //绘制ATR
    if (isDrawATR && mATRData != null) {
      mATRData?.drawATR(canvas, kChartViewHeight, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT,
          MARGINBOTTOM, BaseKChartPainter.LOWER_CHART_TOP, mRightArea, ATRPeriod);
    }

    //绘制BIAS
    if (isDrawBIAS && mBIASData != null) {
      mBIASData?.drawBIAS(canvas, kChartViewHeight, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL,
          BaseKChartPainter.MARGINLEFT, MARGINBOTTOM, BaseKChartPainter.LOWER_CHART_TOP, mRightArea, BIAS1Period, BIAS2Period, BIAS3Period);
    }

    //绘制PSY
    if (isDrawPSY && mPSYData != null) {
      mPSYData?.drawPSY(canvas, kChartViewHeight, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT,
          MARGINBOTTOM, BaseKChartPainter.LOWER_CHART_TOP, mRightArea, PSYPeriod, PSYMAPeriod);
    }

    //绘制TRIX
    if (isDrawTRIX && mTRIXData != null) {
      mTRIXData?.drawTRIX(canvas, kChartViewHeight, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL,
          BaseKChartPainter.MARGINLEFT, MARGINBOTTOM, BaseKChartPainter.LOWER_CHART_TOP, mRightArea, TRIXPeriod, TRIXMAPeriod);
    }

    //绘制成交量
    if (isDrawVolume && mVolData != null) {
      mVolData?.drawVol(canvas, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT, MARGINBOTTOM,
          BaseKChartPainter.LOWER_CHART_TOP, BaseKChartPainter.MID_CHART_TOP, mRightArea);
    }

    //绘制vr
    if (isDrawVR && mVRData != null) {
      mVRData?.drawVR(canvas, kChartViewWidth, mDataStartIndext, mShowDataNum, mCandleWidth, CANDLE_INTERVAL, BaseKChartPainter.MARGINLEFT, MARGINBOTTOM,
          BaseKChartPainter.LOWER_CHART_TOP, BaseKChartPainter.MID_CHART_TOP, mRightArea, VRPeriod);
    }
  }

  void _drawAssistLine(Canvas canvas) {
    Paint paintT = MethodUntil().getDrawPaint(Port.transLineColor);
    paintT
      ..strokeWidth = 2.0
      ..isAntiAlias = false;

    Paint paintV = MethodUntil().getDrawPaint(Port.verticalColor);
    paintV
      ..strokeWidth = 2.0
      ..isAntiAlias = false;

    Paint paintO = MethodUntil().getDrawPaint(Port.obliqueLineColor);
    paintO
      ..strokeWidth = 2.0
      ..isAntiAlias = false;

    Paint paintG = MethodUntil().getDrawPaint(Port.goldenLineColor);
    paintG
      ..strokeWidth = 2.0
      ..isAntiAlias = false;

    Paint redTPaint = MethodUntil().getDrawPaint(Port.transLineColor);
    Paint redVPaint = MethodUntil().getDrawPaint(Port.verticalColor);
    TextPainter redGPaint = TextPainter(); //MethodUntil().getDrawPaint(Port.goldenLineColor)
    // Paint redOPaint = MethodUntil().getDrawPaint(Port.obliqueLineColor);
    // textPaint.setColor(Color.WHITE);
    // redTPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);
    // redVPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);
    // redOPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);
    // redGPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);
    // textPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);

    // 绘制横线
    for (int i = 0; i < Port.transverseList.length; i++) {
      bool isShow = KUtils.isShowTrans(Port.transverseList[i], this, mMaxPrice, mMinPrice); //是否在当前屏幕内
      String code = Port.transverseList[i].code;
      if (Port.transverseList[i].isSelect == false && isShow && code == chartCode) {
        double Y = KUtils.getTransY(Port.transverseList[i], this, mMaxPrice, mMinPrice);
        String price = Utils.getPointNum(Port.transverseList[i].price);
        //画横线
        canvas.drawLine(Offset(BaseKChartPainter.MARGINLEFT, Y), Offset(BaseKChartPainter.MARGINLEFT + mChartWidth, Y), paintT);
        //绘制价格
        double left, top, right, bottom, priceX, priceY;
        priceX = BaseKChartPainter.MARGINLEFT + mChartWidth + 5;
        priceY = Y + getStringHeight(price, textPaint) / 2;
        left = BaseKChartPainter.MARGINLEFT + mChartWidth;
        top = Y - getStringHeight(price, textPaint) / 2 - 5;
        right = left + getStringWidth(price, textPaint) + 15;
        bottom = Y + getStringHeight(price, textPaint) / 2 + 5;
        // if (Port.drawFlag == 1) {
        //   priceX = BaseKChartPainter.MARGINLEFT + mChartWidth + 5;
        //   priceY = Y + getStringHeight(price, textPaint) / 2;
        //   left = BaseKChartPainter.MARGINLEFT + mChartWidth;
        //   top = Y - getStringHeight(price, textPaint) / 2 - 5;
        //   right = left + getStringWidth(price, textPaint) + 15;
        //   bottom = Y + getStringHeight(price, textPaint) / 2 + 5;
        // } else {
        priceX = BaseKChartPainter.MARGINLEFT + -getStringWidth(price, textPaint) - 15;
        priceY = Y + getStringHeight(price, textPaint) / 2;
        left = BaseKChartPainter.MARGINLEFT + mChartWidth - getStringWidth(price, textPaint) - 15;
        top = Y - getStringHeight(price, textPaint) / 2 - 5;
        right = left + getStringWidth(price, textPaint) + 15;
        bottom = Y + getStringHeight(price, textPaint) / 2 + 5;
        // }

        canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), redTPaint);
        redPaint
          ..text = TextSpan(text: price, style: TextStyle(color: Colors.white, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(priceX, priceY));
      }
    }

    // 绘制竖线
    for (int i = 0; i < Port.verticalList.length; i++) {
      bool isShow = KUtils.isShowX(Port.verticalList[i], this, mDataStartIndext, mShowDataNum); //是否在当前屏幕内
      String code = Port.verticalList[i].code;
      if (Port.verticalList[i].isSelect == false && isShow && code == chartCode) {
        double X = KUtils.getVerticalX(Port.verticalList[i], this, mDataStartIndext, mShowDataNum, mCandleWidth);
        String date = Port.verticalList[i].date;
        //画竖线
        canvas.drawLine(Offset(X, MARGINTOP), Offset(X, kChartViewHeight - MARGINBOTTOM), paintV);
        //绘制时间
        double dateX = X - getStringWidth(date, textPaint) / 2;
        double dateY = kChartViewHeight - MARGINBOTTOM + getStringHeight(date, textPaint) + 5;
        double left = X - getStringWidth(date, textPaint) / 2 - 10;
        double top = kChartViewHeight - MARGINBOTTOM;
        double right = X + getStringWidth(date, textPaint) / 2 + 10;
        double bottom = top + getStringHeight(date, textPaint) + 10;

        canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), redVPaint);
        redPaint
          ..text = TextSpan(text: date, style: TextStyle(color: Colors.white, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(dateX, dateY));
      }
    }

    // 绘制斜线
    for (int i = 0; i < Port.ObliqueList.length; i++) {
      bool isShow = KUtils.isShowOblique(Port.ObliqueList[i], this, mStartIndex, mShowDataNum, mMaxPrice, mMinPrice); //是否在当前屏幕内
      String code = Port.ObliqueList[i].code;
      if (Port.ObliqueList[i].isSelect == false && isShow && code == chartCode) {
        double startY = KUtils.getChartObliqueY(Port.ObliqueList[i], Port.ObliqueList[i].startPrice, this, mMaxPrice, mMinPrice);
        double endY = KUtils.getChartObliqueY(Port.ObliqueList[i], Port.ObliqueList[i].endPrice, this, mMaxPrice, mMinPrice);
        double startX = (KUtils.getKNumber(Port.ObliqueList[i].startDate, this, mStartIndex, mShowDataNum) * mCandleWidth);
        double endX = (KUtils.getKNumber(Port.ObliqueList[i].endDate, this, mStartIndex, mShowDataNum) * mCandleWidth);

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paintO);
      }
    }

    // 绘制黄金分割线
    for (int i = 0; i < Port.GoldenList.length; i++) {
      bool isShow = KUtils.isShowGolden(Port.GoldenList[i], this, mStartIndex, mShowDataNum, mMaxPrice, mMinPrice); //是否在当前屏幕内
      String code = Port.GoldenList[i].code;
      if (Port.GoldenList[i].isSelect == false && isShow && code == chartCode) {
        double startY = KUtils.getChartGoldenY(Port.GoldenList[i], Port.GoldenList[i].startPrice, this, mMaxPrice, mMinPrice);
        double endY = KUtils.getChartGoldenY(Port.GoldenList[i], Port.GoldenList[i].endPrice, this, mMaxPrice, mMinPrice);
        double startX = (KUtils.getKNumber(Port.GoldenList[i].startDate, this, mStartIndex, mShowDataNum) * mCandleWidth + BaseKChartPainter.MARGINLEFT);
        double endX = (KUtils.getKNumber(Port.GoldenList[i].endDate, this, mStartIndex, mShowDataNum) * mCandleWidth + BaseKChartPainter.MARGINLEFT);

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paintG);
        KUtils.drawGolden(canvas, Port.GoldenList[i], this, redGPaint, paintG, mCandleWidth, mMaxPrice, mMinPrice, mStartIndex, mShowDataNum);
      }
    }
  }

  void _drawTitles(Canvas canvas) {
    double perPrice = (mMaxPrice - mMinPrice) / (DEFAULT_UPER_LATITUDE_NUM + 1); //计算每一格纬线框所占有的价格
    for (int i = 1; i <= DEFAULT_UPER_LATITUDE_NUM; i++) {
      if (i == 1 || i == DEFAULT_UPER_LATITUDE_NUM) {
        textPaint
          ..text = TextSpan(text: Utils.getPointNum(mMinPrice + perPrice * i), style: TextStyle(color: Colors.white, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(BaseKChartPainter.MARGINLEFT, UPER_CHART_BOTTOM - latitudeSpacing * i));
      }
    }

    // 绘制十字线
    if (currentX != -1 && currentY != -1 && isDrawCrossLine) {
      CrossLineView.drawCrossLine(canvas, kChartViewHeight, kChartViewWidth, mLowerChartHeight, currentX, currentY, mCandleWidth, MARGINTOP, MARGINBOTTOM,
          BaseKChartPainter.MARGINLEFT, mRightArea, mShowDataNum, mDataStartIndext, mOHLCData, isDrawTime, lastClose, mKPeriod);
    }
  }

  void drawHighLowPoint(Canvas canvas, double rate, double textBottom) {
    yangPaint.style = PaintingStyle.fill;
    num minPrice = mOHLCData[mDataStartIndext].low ?? 0;
    num maxPrice = mOHLCData[mDataStartIndext].high ?? 0;
    int minLoc = mDataStartIndext;
    int maxLoc = mDataStartIndext;
    for (int i = 0; i < mShowDataNum && mDataStartIndext + i < mOHLCData.length; i++) {
      OHLCEntity entity = mOHLCData[mDataStartIndext + i];
      if ((entity.low ?? 0) < minPrice) {
        minPrice = entity.low ?? 0;
        minLoc = i;
      }

      if ((entity.high ?? 0) > maxPrice) {
        maxPrice = entity.high ?? 0;
        maxLoc = i;
      }
    }

    double minX = BaseKChartPainter.MARGINLEFT + mCandleWidth * minLoc + mCandleWidth;
    double maxX = BaseKChartPainter.MARGINLEFT + mCandleWidth * maxLoc + mCandleWidth;
    double high = (mMaxPrice - maxPrice) * rate + textBottom;
    double low = (mMaxPrice - minPrice) * rate + textBottom;

    String maxText = maxPrice.toString();
    String minText = minPrice.toString();
    if (high < textBottom + getStringHeight(maxText, textPaint) + 10) {
      maxText = "$maxText<---";
      high = textBottom + getStringHeight(maxText, textPaint) + 10;
      if (maxX - getStringWidth(maxText, textPaint) > BaseKChartPainter.MARGINLEFT) {
        maxX = maxX - getStringWidth(maxText, textPaint);
      } else {
        maxText = maxText.replaceAll("<---", "");
        maxText = "--->$maxText";
      }
    } else {
      maxX = maxX - getStringWidth(maxText, textPaint) / 2;
      if (maxX - getStringWidth(maxText, textPaint) / 2 > BaseKChartPainter.MARGINLEFT) {
        maxX = maxX - getStringWidth(maxText, textPaint) / 2;
      } else {
        maxText = "--->$maxText";
      }
    }

    if (low > UPER_CHART_BOTTOM - getStringHeight(minText, textPaint) - 10) {
      minText = "$minText<---";
      low = UPER_CHART_BOTTOM - getStringHeight(minText, textPaint) - 10;
      if (minX - getStringWidth(minText, textPaint) > BaseKChartPainter.MARGINLEFT) {
        minX = minX - getStringWidth(minText, textPaint);
      } else {
        minText = minText.replaceAll("<---", "");
        minText = "--->$minText";
      }
    } else {
      if (minX - getStringWidth(minText, textPaint) / 2 > BaseKChartPainter.MARGINLEFT) {
        minX = minX - getStringWidth(minText, textPaint) / 2;
      } else {
        minText = "--->$minText";
      }
      low = low + getStringHeight(minText, textPaint);
    }

    textPaint
      ..text = TextSpan(text: maxText, style: TextStyle(color: Port.yangCandleColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(maxX, high));
    textPaint
      ..text = TextSpan(text: minText, style: TextStyle(color: Port.yingCandleColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(minX, low));
  }

  void drawTime(Canvas canvas, Paint linePaint, TextPainter textPaint) {
    if (mFsTimes.length == 2) {
      double x, y;
      String startStr = mFsTimes[0].substring(0, 16);
      String timeStr = Utils.getHourTime(mFsTimes[mFsTimes.length - 1]);
      //第一个时间
      timeStr = Utils.getHourTime(Utils.timeMillisToString(Utils.StringToTime10(startStr)));
      x = timeMarginLeft;
      // y = kChartViewHeight - MARGINBOTTOM - timeDownChartHeight + getStringHeight(timeStr, textPaint);
      y = kChartViewHeight - MARGINBOTTOM + getStringHeight(timeStr, textPaint);
      textPaint
        ..text = TextSpan(text: timeStr, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(x, y));

      //最后一个时间
      timeStr = Utils.getHourTime(mFsTimes[mFsTimes.length - 1]);
      x = (kChartViewWidth - timeMarginRight - getStringWidth(timeStr, textPaint));
      y = kChartViewHeight - MARGINBOTTOM + getStringHeight(timeStr, textPaint);
      // y = kChartViewHeight - MARGINBOTTOM - timeDownChartHeight + getStringHeight(timeStr, textPaint);
      textPaint
        ..text = TextSpan(text: timeStr, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(x, y));

      //第1,2,3,4个时间
      // for (int i = 0; i <= 3; i++) {
      //   timeStr = Utils.getHourTime(Utils.timeMillisToString(Utils.StringToTime10(startStr) + i * period * 60));
      //   if (i == 0) {
      //     x = (timeMarginLeft + i * period * mPointWidth);
      //   } else {
      //     x = (timeMarginLeft + i * period * mPointWidth - getStringWidth(timeStr, textPaint) / 2);
      //   }
      //   y = kChartViewHeight - MARGINBOTTOM - timeDownChartHeight + getStringHeight(timeStr, textPaint);
      //   textPaint
      //     ..text = TextSpan(text: timeStr, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
      //     ..textDirection = TextDirection.ltr
      //     ..layout()
      //     ..paint(canvas, Offset(x, y));
      // }
    } else if (mFsTimes.length >= 4) {
      //取自身时间段，每段都画出来

      for (int i = 1; i <= mFsTimes.length - 2; i++) {
        if (i % 2 != 0) {
          int period = 0;
          for (int j = 0; j <= i; j = j + 2) {
            int start = int.parse(Utils.getLongTime(mFsTimes[j]));
            int end = int.parse(Utils.getLongTime(mFsTimes[j + 1]));
            period += (end - start) ~/ 60;
          }

          double x, y;
          String timeStr = "${Utils.getHourTime(mFsTimes[i])}/${Utils.getHourTime(mFsTimes[i + 1])}";
          x = (timeMarginLeft + period * mPointWidth - getStringWidth(timeStr, textPaint) / 2);
          y = kChartViewHeight - MARGINBOTTOM - timeDownChartHeight + getStringHeight(timeStr, textPaint);
          textPaint
            ..text = TextSpan(text: timeStr, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
            ..textDirection = TextDirection.ltr
            ..layout()
            ..paint(canvas, Offset(x, y));
        }
      }

      double x, y;
      //最后一个时间
      String timeStr = Utils.getHourTime(mFsTimes[mFsTimes.length - 1]);
      x = kChartViewWidth - timeMarginRight - getStringWidth(timeStr, textPaint, size: DEFAULT_AXIS_TITLE_SIZE + 2);
      y = kChartViewHeight - MARGINBOTTOM - timeDownChartHeight + getStringHeight(timeStr, textPaint, size: DEFAULT_AXIS_TITLE_SIZE + 2);
      textPaint
        ..text = TextSpan(text: timeStr, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(x, y));

      //第一个时间
      timeStr = Utils.getHourTime(mFsTimes.first);
      x = timeMarginLeft;
      y = kChartViewHeight - MARGINBOTTOM - timeDownChartHeight + getStringHeight(timeStr, textPaint, size: DEFAULT_AXIS_TITLE_SIZE + 2);
      textPaint
        ..text = TextSpan(text: timeStr, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(x, y));
    }
  }

  List<OHLCEntity> getOHLCData() {
    List<OHLCEntity> list = [];
    if (mOHLCData.isNotEmpty) {
      list.addAll(mOHLCData);
    }
    return list;
  }

  /// 设置交易时间
  static void setTradeTimes(String? tradeTimes) {
    if (tradeTimes != null) {
      List list = jsonDecode(tradeTimes);
      mTradeTimes.clear();
      mTradeTimes.addAll(list.map((e) => TradeTime.fromJson(e)).toList());
    } else {
      TradeTime tradeTime = TradeTime(Start: "06:00:00", End: "05:00:00");
      mTradeTimes.add(tradeTime);
    }
  }

  static void calcFsTime(String staDate, String staTime) {
    List<String> list = [];
    if (mTradeTimes.isNotEmpty) {
      String? openTime = "$staDate ${mTradeTimes[0].Start}";
      String? closeTime = "$staDate ${mTradeTimes[mTradeTimes.length - 1].End}";
      String nDate = staDate;
      String nTime = staTime;

      String preTime = openTime;
      if (Utils.compareDate(openTime, closeTime) == -1) {
        //收盘早于开盘

        if (Utils.compareDate(openTime, "$staDate $nTime") == -1) {
          if (Utils.getWeek(nDate) == 1) {
            //星期一
            nDate = Utils.getDayBefore(nDate, 3);
          } else {
            nDate = Utils.getDayBefore(nDate, 1);
          }
        }

        for (int i = 0; i < mTradeTimes.length; i++) {
          String indexStart = "$staDate ${mTradeTimes[i].Start}";
          String indexEnd = "$staDate ${mTradeTimes[i].End}";
          if (Utils.compareDate(indexStart, indexEnd) == -1) {
            String start = "$nDate ${mTradeTimes[i].Start}";
            nDate = Utils.getDayAfter(nDate, 1);
            String end = "$nDate ${mTradeTimes[i].End}";
            list.add(start);
            list.add(end);

            if (Utils.getWeek(nDate) == 6) {
              nDate = Utils.getDayAfter(nDate, 2);
            }
          } else {
            if (Utils.compareDate(indexStart, preTime) == 1) {
              if (Utils.getWeek(nDate) == 5) {
                //周五
                nDate = Utils.getDayAfter(nDate, 3);
                String start = "$nDate ${mTradeTimes[i].Start}";
                String end = "$nDate ${mTradeTimes[i].End}";
                list.add(start);
                list.add(end);
              } else {
                nDate = Utils.getDayAfter(nDate, 1);
                String start = "$nDate ${mTradeTimes[i].Start}";
                String end = "$nDate ${mTradeTimes[i].End}";
                list.add(start);
                list.add(end);
              }
            } else {
              String start = "$nDate ${mTradeTimes[i].Start}";
              String end = "$nDate ${mTradeTimes[i].End}";
              list.add(start);
              list.add(end);
            }
          }
          preTime = indexEnd;
        }
      } else {
        //开盘早于收盘
        for (int i = 0; i < mTradeTimes.length; i++) {
          String start = "$nDate ${mTradeTimes[i].Start}";
          String end = "$nDate ${mTradeTimes[i].End}";
          list.add(start);
          list.add(end);
        }
      }
    }

    // for (int i = 0; i < list.length; i++) {
    //   Log.e("交易时间hxj", list[i]);
    // }

    mFsTimes.clear();
    mFsTimes.addAll(list);

    //计算分时数量
    mFsCount = 0;
    for (int i = 0; i < mFsTimes.length; i = i + 2) {
      int start = int.parse(Utils.getLongTime(mFsTimes[i]));
      int end = int.parse(Utils.getLongTime(mFsTimes[i + 1]));
      mFsCount += (end - start) ~/ 60;
    }
  }

  static int getMaxPeriod(
    bool isDrawAlligator,
    bool isDrawCost,
    bool isDrawDKX,
    bool isDrawBollinger,
    bool isDrawFall,
    bool isDrawMacd,
    bool isDrawDmi,
    bool isDrawRsi,
    bool isDrawTRIX,
    bool isDrawPSY,
    bool isDrawATR,
    bool isDrawBIAS,
    bool isDrawCCI,
    bool isDrawKDJ,
    bool isDrawWR,
    bool isDrawMIKE,
    bool isDrawGUBI,
  ) {
    int max = 0;
    if (isDrawAlligator) {
      //  鳄鱼线周期
      max = max > (JawPeriod + JawSpeed) ? max : (JawPeriod + JawSpeed);
      max = max > (TeethPeriod + TeethSpeed) ? max : (TeethPeriod + TeethSpeed);
      max = max > (LipsPeriod + LipsSpeed) ? max : (LipsPeriod + LipsSpeed);
    }
    if (isDrawCost) {
      // 均线线周期
      max = max > CostOnePeriod ? max : CostOnePeriod;
      max = max > CostTwoPeriod ? max : CostTwoPeriod;
      max = max > CostThreePeriod ? max : CostThreePeriod;
      max = max > CostFourPeriod ? max : CostFourPeriod;
      max = max > CostFivePeriod ? max : CostFivePeriod;
    }
    if (isDrawDKX) {
      //  多空线周期
      max = max > DKXPeriod ? max : DKXPeriod;
      max = max > MADKXPeriod ? max : MADKXPeriod;
    }
    if (isDrawBollinger) {
      max = max > BollingerPeriod ? max : BollingerPeriod;
    }
    if (isDrawFall) {
      //  瀑布线周期
      max = max > FallPeriod1 * 4 ? max : FallPeriod1 * 4;
      max = max > FallPeriod2 * 4 ? max : FallPeriod2 * 4;
      max = max > FallPeriod3 * 4 ? max : FallPeriod3 * 4;
      max = max > FallPeriod4 * 4 ? max : FallPeriod4 * 4;
      max = max > FallPeriod5 * 4 ? max : FallPeriod5 * 4;
      max = max > FallPeriod6 * 4 ? max : FallPeriod6 * 4;
    }
    if (isDrawMacd) {
      //  MACD线周期
      max = max > (macdPeriod + macdLPeriod) ? max : (macdPeriod + macdLPeriod);
      max = max > macdLPeriod ? max : macdLPeriod;
    }
    if (isDrawDmi) {
      //  DMI线周期
      max = max > dmiPeriod ? max : dmiPeriod;
    }
    if (isDrawRsi) {
      //  rsi线周期
      max = max > rsiPeriod ? max : rsiPeriod;
    }
    if (isDrawTRIX) {
      //  TRIX线周期
      max = max > (TRIXPeriod + TRIXMAPeriod) ? max : (TRIXPeriod + TRIXMAPeriod);
      max = max > TRIXPeriod ? max : TRIXPeriod;
    }
    if (isDrawPSY) {
      //  PSY线周期
      max = max > (PSYPeriod + PSYMAPeriod) ? max : (PSYPeriod + PSYMAPeriod);
      max = max > PSYPeriod ? max : PSYPeriod;
    }
    if (isDrawATR) {
      //  ATR线周期
      max = max > ATRPeriod ? max : ATRPeriod;
    }
    if (isDrawBIAS) {
      //  BIAS线周期
      max = max > BIAS1Period ? max : BIAS1Period;
      max = max > BIAS2Period ? max : BIAS2Period;
      max = max > BIAS3Period ? max : BIAS3Period;
    }
    if (isDrawCCI) {
      //  CCI线周期
      max = max > CCIPeriod ? max : CCIPeriod;
    }
    if (isDrawKDJ) {
      //  KDJ线周期
      max = max > KDJPeriod ? max : KDJPeriod;
    }
    if (isDrawWR) {
      //  WR线周期
      max = max > Wr1Period ? max : Wr1Period;
      max = max > Wr2Period ? max : Wr2Period;
    }
    if (isDrawMIKE) {
      //  MIKE线周期
      max = max > MikePeriod ? max : MikePeriod;
    }
    if (isDrawGUBI) {
      //  GUBI线周期
      max = max > GUBIPeriod1 ? max : GUBIPeriod1;
      max = max > GUBIPeriod2 ? max : GUBIPeriod2;
      max = max > GUBIPeriod3 ? max : GUBIPeriod3;
      max = max > GUBIPeriod4 ? max : GUBIPeriod4;
      max = max > GUBIPeriod5 ? max : GUBIPeriod5;
      max = max > GUBIPeriod6 ? max : GUBIPeriod6;
      max = max > GUBIPeriod7 ? max : GUBIPeriod7;
      max = max > GUBIPeriod8 ? max : GUBIPeriod8;
      max = max > GUBIPeriod9 ? max : GUBIPeriod9;
      max = max > GUBIPeriod10 ? max : GUBIPeriod10;
      max = max > GUBIPeriod11 ? max : GUBIPeriod11;
      max = max > GUBIPeriod12 ? max : GUBIPeriod12;
    }
    return max;
  }

  static double getStringWidth(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? 8))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.width;
  }

  static double getStringHeight(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? 8))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.height;
  }
}
