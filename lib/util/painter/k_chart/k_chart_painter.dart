import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../../model/k/OHLCEntity.dart';
import '../../../model/k/custom_line.dart';
import '../../../model/k/draw_tool_line.dart';
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
import '../../../model/pl/pl.dart';
import '../../../model/quote/side_type.dart';
import '../../../model/trade/hold_order.dart';
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
  List<CustomLine> drawOrderLines = [];
  List<DrawToolLine> drawToolLines = [];
  int mTimeStartIndext = 0;
  int mTimeShowNum = 1380;
  int mShowNum = 35, mStartIndex = 0;
  double timeMarginRight = 0;
  double timeMarginLeft = 0;
  static double leftMarginSpace = 80;
  static double timeLeftMarginSpace = getStringWidth("000.000", TextPainter(), size: Port.ChartTextSize);
  static double rightMarginSpace = getStringWidth("+0.00%", TextPainter(), size: Port.ChartTextSize);
  static double halfTextHeight = getStringHeight("0", TextPainter(), size: Port.ChartTextSize) / 2;
  int mPreSize = 0;
  int mOrder = 0;
  double lastClose = 0;
  String chartExCode = "";
  String chartCode = "";
  List<double> CUSTOM_DASH_EFFECT = [5, 5];

  /// 十字线辅助绘制
  late CrossLineView mCrossLineView;
  // 下部表的数据
  /// MACD数据
  MACDEntity? mMACDData;

  /// RSI数据
  RSIEntity? mRSIData;

  /// 布林带数据
  BollingerEntity? mBollingerData;

  /// 均线数据
  CostLineEntity? mCostData;

  /// 瀑布线数据
  FallLineEntity? mFallData;

  /// 鳄鱼线数据
  AlligatorEntity? mAlligatorData;

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

  /// 布林线	周期
  static int BollingerPeriod = 26;

  /// 布林线	标准差
  static double BollingerSD = 2.000;

  /// 均线	周期1
  static int CostOnePeriod = 5;

  /// 均线	周期2
  static int CostTwoPeriod = 10;

  /// 均线	周期3
  static int CostThreePeriod = 20;

  /// 均线	周期4
  static int CostFourPeriod = 40;

  /// 均线	周期5
  static int CostFivePeriod = 60;

  /// 瀑布线	周期1
  static int FallPeriod1 = 4;

  /// 瀑布线	周期2
  static int FallPeriod2 = 6;

  /// 瀑布线	周期3
  static int FallPeriod3 = 9;

  /// 瀑布线	周期4
  static int FallPeriod4 = 13;

  /// 瀑布线	周期5
  static int FallPeriod5 = 18;

  /// 瀑布线	周期6
  static int FallPeriod6 = 24;

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

  bool isDrawBollinger = false;
  bool isDrawCost = true;
  bool isDrawCost1 = true;
  bool isDrawCost2 = true;
  bool isDrawCost3 = true;
  bool isDrawCost4 = true;
  bool isDrawCost5 = true;
  bool isDrawFall = false;

  bool isDrawCrossLine = false;
  bool isDrawCandle = true;
  bool isSmartFall = false;
  bool isSwithSmart = false;
  List<TradeTime> mTradeTimes = [];
  List<String> mFsTimes = [];
  int mFsCount = 0;
  static double kChartViewHeight = 0;
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
  bool isDrawing = false;
  bool orderDrawing = false;
  List<HoldOrder> holdOrder = [];
  List<PLRecord> pLRecordList = [];
  int hoverIndex = 0;

  ChartPainter({
    required this.isDrawTime,
    required this.lastClose,
    required this.mTradeTimes,
    required this.mFsTimes,
    required this.mFsCount,
    required this.orderDrawing,
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
    required this.drawOrderLines,
    required this.drawToolLines,
    required this.mDataStartIndext,
    required this.mShowDataNum,
    required this.MIN_CANDLE_NUM,
    required this.isDrawBollinger,
    required this.isDrawCost,
    required this.isDrawCost1,
    required this.isDrawCost2,
    required this.isDrawCost3,
    required this.isDrawCost4,
    required this.isDrawCost5,
    required this.isDrawFall,
    required this.isDrawCrossLine,
    required this.mPreSize,
    required this.mMACDData,
    required this.mRSIData,
    required this.mBollingerData,
    required this.mCostData,
    required this.mFallData,
    required this.mAlligatorData,
    required this.mKDJData,
    required this.mWRData,
    required this.mCCIData,
    required this.mBIASData,
    required this.mPSYData,
    required this.mVolData,
    required this.mVRData,
    required this.isDrawTimeDown,
    required this.holdOrder,
    required this.pLRecordList,
    required this.hoverIndex,
  }) : super(isDrawTime: isDrawTime);

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    kChartViewHeight = size.height;
    kChartViewWidth = size.width;
    if (mOHLCData.isEmpty) {
      return;
    }
    if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
      return;
    }
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
      timeDownChartHeight = isDrawTimeDown == true ? (size.height - MARGINTOP) / (DEFAULT_TIME_LATITUDE_NUM + 1) * 3 : 0;
      double latitudeSpacing = (size.height - MARGINTOP - timeDownChartHeight) / (DEFAULT_TIME_LATITUDE_NUM + 1);
      double longitudeSpacing = (size.width - timeMarginLeft - timeMarginRight) / (DEFAULT_TIME_LOGITUDE_NUM + 1);
      _drawLatitudes(canvas, latitudeSpacing);
      _drawLongitudes(canvas, longitudeSpacing);
      _drawTimeUpper(canvas, longitudeSpacing);
    } else {
      _drawUpperRegion(canvas);
      _drawAssistLine(canvas);
      _drawTitles(canvas);
    }
  }

  void _drawLatitudes(Canvas canvas, double latitudeSpacing) {
    girdPaint
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= DEFAULT_TIME_LATITUDE_NUM; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(timeMarginLeft + timeLeftMarginSpace, MARGINTOP + latitudeSpacing * i);
      path.lineTo(kChartViewWidth - timeMarginRight - rightMarginSpace, MARGINTOP + latitudeSpacing * i);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        girdPaint,
      );
    }

    lastClose = lastClose == 0 ? (mMaxPrice + mMinPrice) / 2 : lastClose;
    double maxHeight = max(mMaxPrice - lastClose, lastClose - mMinPrice);
    double perPrice = maxHeight / 4;
    for (int i = 3; i > 0; i--) {
      String text = Utils.getPointNum(lastClose + perPrice * (4 - i), length: 2);
      double percent = (perPrice * (4 - i)) / lastClose * 100;
      String textPercent = "${Utils.getLimitNum(percent, 2)}%";
      double leftX = 0, leftY = 0, rightX = 0;
      leftX = timeMarginLeft + timeLeftMarginSpace - getStringWidth(text, redPaint) - 1;
      leftY = MARGINTOP + latitudeSpacing * i - halfTextHeight;
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
      String text = Utils.getPointNum(lastClose - perPrice * (i - 4), length: 2);
      double percent = (perPrice * (i - 4)) / lastClose * 100;
      String textPercent = "-${Utils.getLimitNum(percent, 2)}%";
      double leftX = 0, leftY = 0, rightX = 0;

      leftX = timeMarginLeft + timeLeftMarginSpace - getStringWidth(text, redPaint) - 1;
      leftY = MARGINTOP + latitudeSpacing * i - halfTextHeight;
      rightX = kChartViewWidth - getStringWidth(textPercent, greenPaint, size: DEFAULT_AXIS_TITLE_SIZE);
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
    leftX = timeMarginLeft + timeLeftMarginSpace - getStringWidth(Utils.getPointNum(lastClose, length: 2), redPaint) - 1;
    leftY = MARGINTOP + latitudeSpacing * 4 - halfTextHeight;
    rightX = kChartViewWidth - getStringWidth("0.00%", textPaint, size: DEFAULT_AXIS_TITLE_SIZE);
    redPaint
      ..text = TextSpan(text: Utils.getPointNum(lastClose, length: 2), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftX, leftY));
    redPaint
      ..text = TextSpan(text: "0.00%", style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(rightX, leftY));
  }

  void _drawLongitudes(Canvas canvas, double longitudeSpacing) {
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
        path.moveTo(timeMarginLeft + longitudeSpacing * i, MARGINTOP);
        path.lineTo(timeMarginLeft + longitudeSpacing * i, TIME_UPER_CHART_BOTTOM);
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawTimeUpper(Canvas canvas, double longitudeSpacing) {
    bluePaint.strokeWidth = 1;
    yellowPaint.strokeWidth = 1;
    double closeY = 0.0;
    double averageY = 0.0;
    double nextCloseY = 0.0;
    double nextAverageY = 0.0;
    double startX = 0.0;
    double nextX = 0.0;
    lastClose = lastClose == 0 ? (mMaxPrice + mMinPrice) / 2 : lastClose;
    double max = mMaxPrice;
    double min = mMinPrice;
    double maxHeight = (max - lastClose) > (lastClose - min) ? (max - lastClose) : (lastClose - min); //最大价差
    max = lastClose + maxHeight;
    min = lastClose - maxHeight;
    double rate = (kChartViewHeight - MARGINTOP - timeDownChartHeight) / (max - min); //计算最小单位
    if (rate.isInfinite) {
      logger.d("rate.isInfinite  max:$max   min:$max   lastClose:$lastClose");
      return;
    }
    int showNum = 0;
    showNum = (kChartViewWidth - timeMarginLeft - timeMarginRight - timeLeftMarginSpace - rightMarginSpace) ~/ mPointWidth;
    for (int i = 0; i < showNum; i++) {
      int num = (i + 1) >= showNum ? showNum - 1 : i + 1;
      startX = mPointWidth * i + timeMarginLeft + timeLeftMarginSpace;
      nextX = mPointWidth * num + timeMarginLeft + rightMarginSpace;
      if (i >= mOHLCData.length) break;
      if (i < mOHLCData.length) {
        int next = (i + 1) >= mOHLCData.length ? mOHLCData.length - 1 : i + 1;
        closeY = (max - (mOHLCData[i].close ?? 0)) * rate;
        averageY = (max - (mOHLCData[i].average ?? 0)) * rate;
        nextCloseY = (max - (mOHLCData[next].close ?? 0)) * rate;
        nextAverageY = (max - (mOHLCData[next].average ?? 0)) * rate;
        canvas.drawLine(Offset(startX, closeY), Offset(nextX, nextCloseY), bluePaint); //绘制收盘价
        canvas.drawLine(Offset(startX, averageY), Offset(nextX, nextAverageY), yellowPaint); //绘制收盘价
      }
    }
    //绘制成交量
    if (mVolData != null && isDrawTimeDown) {
      mVolData?.drawFenshiVol(canvas, kChartViewHeight, kChartViewWidth, mPointWidth, BaseKChartPainter.TimeMarginLeft, timeLeftMarginSpace,
          rightMarginSpace, TIME_LOWER_CHART_TOP, BaseKChartPainter.TimeMarginRight, halfTextHeight);
    }

    drawPosLines(canvas);
    //绘制十字线
    if (currentX != -1 && currentY != -1 && isDrawCrossLine) {
      double lowerHeight = kChartViewHeight - TIME_LOWER_CHART_TOP;
      CrossLineView.drawCrossLine(canvas, kChartViewHeight, kChartViewWidth, lowerHeight, currentX, currentY, mPointWidth, MARGINTOP, timeMarginLeft,
          timeLeftMarginSpace, rightMarginSpace, showNum, 0, mOHLCData, isDrawTime, lastClose, hoverIndex, mKPeriod);
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

    // logger.f((mUperChartHeight - MARGINTOP + Port.text_check - getStringHeight("0", TextPainter(), size: Port.ChartTextSize));
    double rate = mUperChartHeight / (mMaxPrice - mMinPrice); //计算最小单位
    // double rate = (mUperChartHeight - MARGINTOP + Port.text_check - getStringHeight("0", TextPainter(), size: Port.ChartTextSize)) /
    //     (mMaxPrice - mMinPrice); //计算最小单位
    // double textBottom = MARGINTOP - Port.text_check + getStringHeight("0", TextPainter(), size: Port.ChartTextSize);
    double textBottom = MARGINTOP;
    canvas.drawLine(Offset(leftMarginSpace, 0), Offset(leftMarginSpace, kChartViewHeight), girdPaint);
    for (int i = 0; i < mShowDataNum && mDataStartIndext + i < mOHLCData.length; i++) {
      OHLCEntity entity = mOHLCData[mDataStartIndext + i];
      double startX = BaseKChartPainter.MARGINLEFT + mCandleWidth * i + mCandleWidth + leftMarginSpace;
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
      path.moveTo(BaseKChartPainter.MARGINLEFT + mChartWidth + leftMarginSpace, closeHigh);
      path.lineTo(BaseKChartPainter.MARGINLEFT + mChartWidth + leftMarginSpace, closeHigh - 10);
      path.lineTo(BaseKChartPainter.MARGINLEFT + mChartWidth + leftMarginSpace, closeHigh + 10);
      path.close();
      canvas.drawPath(path, cursorPaint);
    }
    drawHighLowPoint(canvas, rate, textBottom);

    //绘制瀑布线
    if (isDrawFall && isSmartFall == false && mFallData != null) {
      mFallData?.drawFall(
          canvas,
          mDataStartIndext,
          mShowDataNum,
          mCandleWidth,
          mMaxPrice,
          mMinPrice,
          CANDLE_INTERVAL,
          BaseKChartPainter.MARGINLEFT,
          leftMarginSpace,
          MARGINTOP,
          mUperChartHeight,
          FallPeriod1,
          FallPeriod2,
          FallPeriod3,
          FallPeriod4,
          FallPeriod5,
          FallPeriod6,
          currentIndex(),
          isDrawCrossLine);
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
          leftMarginSpace,
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
          isDrawCost5,
          isDrawCrossLine,
          currentIndex());
    }

    //绘制布林线
    if (isDrawBollinger && mBollingerData != null) {
      mBollingerData?.drawBollinger(canvas, mDataStartIndext, mShowDataNum, mCandleWidth, mMaxPrice, mMinPrice, CANDLE_INTERVAL,
          BaseKChartPainter.MARGINLEFT, leftMarginSpace, MARGINTOP, mUperChartHeight, BollingerPeriod, BollingerSD, isDrawCrossLine, currentIndex());
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
    TextPainter redGPaint = TextPainter();

    // 绘制横线
    for (int i = 0; i < Port.transverseList.length; i++) {
      bool isShow = KUtils.isShowTrans(Port.transverseList[i], this, mMaxPrice, mMinPrice); //是否在当前屏幕内
      String code = Port.transverseList[i].code;
      if (Port.transverseList[i].isSelect == false && isShow && code == chartCode) {
        double Y = KUtils.getTransY(Port.transverseList[i], this, mMaxPrice, mMinPrice);
        String price = Utils.getPointNum(Port.transverseList[i].price, length: 2);
        //画横线
        canvas.drawLine(Offset(BaseKChartPainter.MARGINLEFT, Y), Offset(BaseKChartPainter.MARGINLEFT + mChartWidth, Y), paintT);
        //绘制价格
        // double left, top, right, bottom, priceX, priceY;
        // priceX = BaseKChartPainter.MARGINLEFT + mChartWidth + 5;
        // priceY = Y + getStringHeight(price, textPaint) / 2;
        // left = BaseKChartPainter.MARGINLEFT + mChartWidth;
        // top = Y - getStringHeight(price, textPaint) / 2 - 5;
        // right = left + getStringWidth(price, textPaint) + 15;
        // bottom = Y + getStringHeight(price, textPaint) / 2 + 5;

        double priceX = BaseKChartPainter.MARGINLEFT + -getStringWidth(price, textPaint) - 15;
        double priceY = Y + getStringHeight(price, textPaint) / 2;
        double left = BaseKChartPainter.MARGINLEFT + mChartWidth - getStringWidth(price, textPaint) - 15;
        double top = Y - getStringHeight(price, textPaint) / 2 - 5;
        double right = left + getStringWidth(price, textPaint) + 15;
        double bottom = Y + getStringHeight(price, textPaint) / 2 + 5;

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
        canvas.drawLine(Offset(X, MARGINTOP), Offset(X, kChartViewHeight), paintV);
        //绘制时间
        double dateX = X - getStringWidth(date, textPaint) / 2;
        double dateY = kChartViewHeight + getStringHeight(date, textPaint) + 5;
        double left = X - getStringWidth(date, textPaint) / 2 - 10;
        double top = kChartViewHeight;
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
        double startX =
            (KUtils.getKNumber(Port.GoldenList[i].startDate, this, mStartIndex, mShowDataNum) * mCandleWidth + BaseKChartPainter.MARGINLEFT);
        double endX = (KUtils.getKNumber(Port.GoldenList[i].endDate, this, mStartIndex, mShowDataNum) * mCandleWidth + BaseKChartPainter.MARGINLEFT);

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paintG);
        KUtils.drawGolden(canvas, Port.GoldenList[i], this, redGPaint, paintG, mCandleWidth, mMaxPrice, mMinPrice, mStartIndex, mShowDataNum);
      }
    }
  }

  void _drawTitles(Canvas canvas) {
    double perPrice = (mMaxPrice - mMinPrice) / (DEFAULT_UPER_LATITUDE_NUM + 1); //计算每一格纬线框所占有的价格
    for (int i = 1; i <= DEFAULT_UPER_LATITUDE_NUM; i++) {
      String text = Utils.getPointNum(mMinPrice + perPrice * i, length: 2);
      textPaint
        ..text = TextSpan(text: text, style: TextStyle(color: Colors.white, fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(
            canvas,
            Offset(BaseKChartPainter.MARGINLEFT + leftMarginSpace - getStringWidth(text, textPaint) - 5,
                UPER_CHART_BOTTOM - latitudeSpacing * i - MARGINTOP + getStringHeight(text, textPaint) / 2));
    }

    // 绘制十字线
    if (currentX != -1 && currentY != -1 && isDrawCrossLine) {
      CrossLineView.drawCrossLine(
          canvas,
          kChartViewHeight,
          kChartViewWidth,
          0,
          currentX,
          currentY,
          mCandleWidth,
          MARGINTOP,
          BaseKChartPainter.MARGINLEFT,
          leftMarginSpace,
          rightMarginSpace,
          mShowDataNum,
          mDataStartIndext,
          mOHLCData,
          isDrawTime,
          lastClose,
          hoverIndex,
          mKPeriod);
    }

    //画线下单
    drawLines(canvas);

    drawPosLines(canvas);
  }

  void drawHighLowPoint(Canvas canvas, double rate, double textBottom) {
    yangPaint.style = PaintingStyle.fill;
    double minPrice = mOHLCData[mDataStartIndext].low ?? 0;
    double maxPrice = mOHLCData[mDataStartIndext].high ?? 0;
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

    double minX = BaseKChartPainter.MARGINLEFT + leftMarginSpace + mCandleWidth * minLoc + mCandleWidth;
    double maxX = BaseKChartPainter.MARGINLEFT + leftMarginSpace + mCandleWidth * maxLoc + mCandleWidth;
    double high = (mMaxPrice - maxPrice) * rate + textBottom;
    double low = (mMaxPrice - minPrice) * rate + textBottom;

    String maxText = maxPrice.toString();
    String minText = minPrice.toString();
    if (high < textBottom + getStringHeight(maxText, textPaint) - 10) {
      maxText = "$maxText<---";
      high = textBottom + getStringHeight(maxText, textPaint) - 10;
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
    double x, y;
    String startStr = mFsTimes[0].substring(0, 16);
    String timeStr = Utils.getHourTime(mFsTimes[mFsTimes.length - 1]);
    //第一个时间
    timeStr = Utils.getHourTime(Utils.timeMillisToString(Utils.StringToTime10(startStr)));
    x = timeMarginLeft + timeLeftMarginSpace - getStringWidth(timeStr, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) / 2;
    y = kChartViewHeight;
    canvas.drawLine(Offset(timeMarginLeft + timeLeftMarginSpace, 0), Offset(timeMarginLeft + timeLeftMarginSpace, kChartViewHeight),
        girdPaint..strokeWidth = 1.5);
    textPaint
      ..text = TextSpan(text: timeStr, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(x, y));

    //最后一个时间
    timeStr = Utils.getHourTime(mFsTimes[mFsTimes.length - 1]);
    x = kChartViewWidth - rightMarginSpace - getStringWidth(timeStr, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) / 2;
    canvas.drawLine(Offset(kChartViewWidth - rightMarginSpace, 0), Offset(kChartViewWidth - rightMarginSpace, kChartViewHeight), girdPaint);
    textPaint
      ..text = TextSpan(text: timeStr, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(x, y));
    canvas.drawLine(Offset(timeMarginLeft, kChartViewHeight), Offset(kChartViewWidth - timeMarginRight, kChartViewHeight), girdPaint);
  }

  void drawLines(Canvas canvas) {
    Paint framePaint = MethodUntil().getDashPaint(Port.costOneColor);
    double rate = mUperChartHeight / (mMaxPrice - mMinPrice); //计算最小单位
    // double rate =
    //     (mUperChartHeight - MARGINTOP + Port.text_check - getStringHeight("0", TextPainter(), size: Port.ChartTextSize)) / (mMaxPrice - mMinPrice);
    double textBottom = MARGINTOP;
    double startX = BaseKChartPainter.MARGINLEFT + leftMarginSpace;
    double stopX = kChartViewWidth;
    double Y = 0;
    framePaint.strokeWidth = Utils.dp2px(1);

    ///画线下单
    for (CustomLine e in drawOrderLines) {
      if (e.kPrice != null) {
        Y = (mMaxPrice - (e.kPrice ?? 0)) * rate + textBottom;
        e.lineY = Y;
      } else if (e.lineY != null) {
        e.kPrice = double.tryParse((mMaxPrice - ((e.lineY! - textBottom) / rate)).toStringAsFixed(4));
        Y = e.lineY!;
      }

      if (dealY(Y)) {
        framePaint.color = e.color;
        Path path = Path(); // 绘制虚线
        path.moveTo(startX, Y);
        path.lineTo(stopX, Y);
        e.path = path;
        //横线
        canvas.drawPath(
          dashPath(
            path,
            dashArray: CircularIntervalList<double>(CUSTOM_DASH_EFFECT),
          ),
          framePaint,
        );

        textPaint
          ..text = TextSpan(
              text: "${e.type == 1 ? "买开" : e.type == 2 ? "卖开" : "平仓"}${e.num}手 ${e.kPrice?.toStringAsFixed(4)}")
          ..layout()
          ..paint(
              canvas,
              Offset(
                  startX,
                  Y -
                      getStringHeight(
                          "${e.type == 1 ? "买开" : e.type == 2 ? "卖开" : "平仓"}${e.num}手 ${e.kPrice?.toStringAsFixed(4)}",
                          textPaint)));
      }
    }

    ///画线工具
    for (DrawToolLine e in drawToolLines) {
      Path path = Path(); // 绘制虚线
      Path tmp = Path()
        ..addRect(Rect.fromLTWH(BaseKChartPainter.MARGINLEFT + leftMarginSpace, 0, kChartViewWidth - BaseKChartPainter.MARGINLEFT - leftMarginSpace,
            kChartViewHeight)); // 绘制虚线
      double width = (e.widthType ?? 1).toDouble();
      framePaint
        ..color = e.selected ? Colors.red : Color(e.colorValue ?? 4294967295)
        ..strokeWidth = width * width - ((width - 1) * (width - 1));
      if (e.pathType == 3 && e.firstPointY != null) {
        ///水平线
        double Y = (mMaxPrice - e.firstPointY!) * rate + textBottom;
        if (dealY(Y)) {
          path.moveTo(startX, Y);
          path.lineTo(stopX, Y);
          e.path = path;
          _paintLines(canvas, e.lineType, path, framePaint);
          textPaint
            ..text = TextSpan(text: e.firstPointY!.toStringAsFixed(4))
            ..layout()
            ..paint(canvas, Offset(startX, Y - getStringHeight(e.firstPointY!.toStringAsFixed(4), textPaint)));
        }
      } //
      else if (e.pathType == 4 && e.firstPointX != null) {
        ///竖线
        if (dateTOIndex(e.firstPointX!) >= mDataStartIndext) {
          double X = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
          path.moveTo(X, MARGINTOP);
          path.lineTo(X, kChartViewHeight);
          e.path = path;
          _paintLines(canvas, e.lineType, path, framePaint);
        }
      } //
      else if (e.pathType == 16 && e.firstPointX != null && e.firstPointY != null) {
        ///上45度
        double X = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double Y = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        path.moveTo(X, Y);
        if (kChartViewWidth - X > Y - MARGINTOP) {
          path.lineTo(X + Y - MARGINTOP, MARGINTOP);
        } else {
          path.lineTo(kChartViewWidth, Y - kChartViewWidth + X);
        }
        e.path = path;
        _paintLines(canvas, e.lineType, path, framePaint);
        _paintPoints(canvas, Offset(X, Y), framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 17 && e.firstPointX != null && e.firstPointY != null) {
        ///下45度
        double X = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double Y = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        path.moveTo(X, Y);
        if (kChartViewWidth - X > kChartViewHeight - Y) {
          path.lineTo(X + kChartViewHeight - Y, kChartViewHeight);
        } else {
          path.lineTo(kChartViewWidth, Y + kChartViewWidth - X);
        }
        e.path = path;
        _paintLines(canvas, e.lineType, path, framePaint);
        _paintPoints(canvas, Offset(X, Y), framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 1 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///趋势线
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        if (firstX == secondX) {
          path.moveTo(firstX, 0);
          path.lineTo(firstX, kChartViewHeight);
        } else if (firstY == secondY) {
          path.moveTo(0, firstY);
          path.lineTo(kChartViewWidth, firstY);
        } else {
          final k = (secondY - firstY) / (secondX - firstX);
          final b = firstY - k * firstX;
          final intersections = [
            Offset(0, b),
            Offset(kChartViewWidth, k * kChartViewWidth + b),
            Offset(-b / k, 0),
            Offset((kChartViewHeight - b) / k, kChartViewHeight),
          ];
          final validPoints = intersections.where((p) => p.dx >= 0 && p.dx <= kChartViewWidth && p.dy >= 0 && p.dy <= kChartViewHeight).toList();
          if (validPoints.length >= 2) {
            validPoints.sort((a, b) => a.dx.compareTo(b.dx));
            path.moveTo(validPoints[0].dx, validPoints[0].dy);
            path.lineTo(validPoints[1].dx, validPoints[1].dy);
          }
        }
        e.path = path;
        _paintLines(canvas, e.lineType, path, framePaint);
        _paintPoints(canvas, Offset(firstX, firstY), framePaint);
        _paintPoints(canvas, Offset(secondX, secondY), framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 2 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///射线
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        if (firstX == secondX) {
          path.moveTo(firstX, firstY);
          path.lineTo(secondX, secondY > firstY ? kChartViewHeight : 0);
        } else if (firstY == secondY) {
          path.moveTo(firstX, firstY);
          path.lineTo(firstX > secondX ? 0 : kChartViewWidth, firstY);
        } else {
          // final k = (secondY - firstY) / (secondX - firstX);
          // final b = firstY - k * firstX;
          // final intersections = [
          //   Offset(0, b),
          //   Offset(kChartViewWidth, k * kChartViewWidth + b),
          //   Offset(-b / k, 0),
          //   Offset((kChartViewHeight - b) / k, kChartViewHeight),
          // ];
          // final validPoints = intersections.where((p) => p.dx >= 0 && p.dx <= kChartViewWidth && p.dy >= 0 && p.dy <= kChartViewHeight).toList();
          // if (validPoints.isNotEmpty) {
          //   validPoints.sort((a, b) => a.dx.compareTo(b.dx));
          //   path.moveTo(firstX, firstY);
          //   if (k > 0) {
          //     path.lineTo(validPoints[0].dx, validPoints[0].dy);
          //   } else {
          //     path.lineTo(validPoints[1].dx, validPoints[1].dy);
          //   }
          // }
          var direction = Offset(secondX, secondY) - Offset(firstX, firstY);
          double value = 0;
          final tValues = [
            (0 - secondX) / direction.dx, // 左边界
            (kChartViewWidth - secondX) / direction.dx, // 右边界
            (0 - secondY) / direction.dy, // 上边界
            (kChartViewHeight - secondY) / direction.dy, // 下边界
          ];
          value = tValues.where((t) => t.isFinite && t > 0).reduce((a, b) => a < b ? a : b);
          path.moveTo(firstX, firstY);
          path.lineTo(secondX + (direction.dx * value), secondY + (direction.dy * value));
        }
        e.path = path;
        _paintLines(canvas, e.lineType, path, framePaint);
        _paintPoints(canvas, Offset(firstX, firstY), framePaint);
        _paintPoints(canvas, Offset(secondX, secondY), framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 5 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///线段
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        path.moveTo(firstX, firstY);
        path.lineTo(secondX, secondY);
        e.path = path;
        _paintLines(canvas, e.lineType, path, framePaint);
        _paintPoints(canvas, Offset(firstX, firstY), framePaint);
        _paintPoints(canvas, Offset(secondX, secondY), framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 8 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///矩形
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        path.moveTo(firstX, firstY);
        path.lineTo(secondX, firstY);
        path.lineTo(secondX, secondY);
        path.lineTo(firstX, secondY);
        path.close();
        e.path = path;
        _paintLines(canvas, e.lineType, path, framePaint);
        _paintPoints(canvas, Offset(firstX, firstY), framePaint);
        _paintPoints(canvas, Offset(secondX, secondY), framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 10 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///圆弧
        if (e.firstPointX != e.secondPointX) {
          double x1 = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
          double x2 = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
          double y1 = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
          double y2 = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
          canvas.save();
          canvas.clipPath(tmp);
          final a = (y1 - y2) / ((x1 - x2) * (x1 - x2) / 4);
          // 生成抛物线路径
          path.moveTo(x1, y1);
          if (x1 < x2) {
            for (double x = x1; x <= x2; x += 0.5) {
              final y = a * (x - (x2 - x1) / 2 - x1) * (x - (x2 - x1) / 2 - x1) + y2;
              if (x != x1) {
                path.lineTo(x, y);
              }
            }
          } else {
            for (double x = x1; x >= x2; x -= 0.5) {
              final y = a * (x - (x2 - x1) / 2 - x1) * (x - (x2 - x1) / 2 - x1) + y2;
              if (x != x1) {
                path.lineTo(x, y);
              }
            }
          }
          // path.moveTo(firstX, firstY);
          // path.cubicTo(
          //   firstX, secondY, // 第一个控制点（上方）
          //   secondX + secondX - firstX, secondY, // 第二个控制点（上方）
          //   secondX + secondX - firstX, firstY, // 终点
          // );
          e.path = path;
          _paintLines(canvas, e.lineType, path, framePaint);
          _paintPoints(canvas, Offset(x1, y1), framePaint);
          _paintPoints(canvas, Offset(x2, y2), framePaint);
          canvas.restore();
        }
      } //
      else if (e.pathType == 13 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///对称角度线
        if (e.firstPointX != e.secondPointX) {
          double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
          double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
          double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
          double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
          canvas.save();
          canvas.clipPath(tmp);
          var direction = Offset(secondX + secondX - firstX, firstY) - Offset(secondX, secondY);
          double value = 0;
          final tValues = [
            (0 - (secondX + secondX - firstX)) / direction.dx, // 左边界
            (kChartViewWidth - (secondX + secondX - firstX)) / direction.dx, // 右边界
            (0 - firstY) / direction.dy, // 上边界
            (kChartViewHeight - firstY) / direction.dy, // 下边界
          ];
          value = tValues.where((t) => t.isFinite && t > 0).reduce((a, b) => a < b ? a : b);
          double x = secondX + secondX - firstX + (direction.dx * value);
          double y = firstY + (direction.dy * value);
          path.moveTo(firstX, firstY);
          path.lineTo(secondX, secondY);
          path.lineTo(secondX, firstY);
          path.moveTo(secondX, secondY);
          path.lineTo(x, y);
          e.path = path;
          _paintLines(canvas, e.lineType, path, framePaint);
          _paintPoints(canvas, Offset(firstX, firstY), framePaint);
          _paintPoints(canvas, Offset(secondX, secondY), framePaint);
          canvas.restore();
        }
      } //
      else if (e.pathType == 14 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///圆
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        double radius = sqrt((secondY - firstY) * (secondY - firstY) + (secondX - firstX) * (secondX - firstX));
        path.addOval(Rect.fromCircle(center: Offset(firstX, firstY), radius: radius));
        e.path = path;
        _paintLines(canvas, e.lineType, path, framePaint);
        _paintPoints(canvas, Offset(firstX, firstY), framePaint);
        _paintPoints(canvas, Offset(secondX, secondY), framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 15 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///椭圆
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        path.addOval(Rect.fromCenter(
            center: Offset((firstX + secondX) / 2, (firstY + secondY) / 2), width: (secondX - firstX).abs(), height: (secondY - firstY).abs()));
        e.path = path;
        _paintLines(canvas, e.lineType, path, framePaint);
        _paintPoints(canvas, Offset(firstX, firstY), framePaint);
        _paintPoints(canvas, Offset(secondX, secondY), framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 11 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///甘氏线
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        // _paintLines(canvas, e.lineType, path, framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 12 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///阻速线
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        // _paintLines(canvas, e.lineType, path, framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 18 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///多圆弧
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        // _paintLines(canvas, e.lineType, path, framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 6 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///通道线
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        if (firstX == secondX) {
          path.moveTo(firstX, 0);
          path.lineTo(firstX, kChartViewHeight);
        } else if (firstY == secondY) {
          path.moveTo(0, firstY);
          path.lineTo(kChartViewWidth, firstY);
        } else {
          final k = (secondY - firstY) / (secondX - firstX);
          final b = firstY - k * firstX;
          final intersections = [
            Offset(0, b),
            Offset(kChartViewWidth, k * kChartViewWidth + b),
            Offset(-b / k, 0),
            Offset((kChartViewHeight - b) / k, kChartViewHeight),
          ];
          final validPoints = intersections.where((p) => p.dx >= 0 && p.dx <= kChartViewWidth && p.dy >= 0 && p.dy <= kChartViewHeight).toList();
          if (validPoints.length >= 2) {
            validPoints.sort((a, b) => a.dx.compareTo(b.dx));
            path.moveTo(validPoints[0].dx, validPoints[0].dy);
            path.lineTo(validPoints[1].dx, validPoints[1].dy);
          }
        }
        _paintLines(canvas, e.lineType, path, framePaint);
        _paintPoints(canvas, Offset(firstX, firstY), framePaint);
        _paintPoints(canvas, Offset(secondX, secondY), framePaint);

        if (e.thirdPointX != null && e.thirdPointY != null) {
          double thirdPointX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.thirdPointX!) - mDataStartIndext) + leftMarginSpace;
          double thirdPointY = (mMaxPrice - (e.thirdPointY ?? 0)) * rate + textBottom;
          double forPointX = firstX - thirdPointX + firstX;
          double forPointY = firstY - thirdPointY + firstY;
          double slope = (secondY - firstY) / (secondX - firstX);
          double intercept = thirdPointY - slope * thirdPointX;
          double intercept1 = forPointY - slope * forPointX;
          // 计算平行线的两个端点（为了显示，我们选择x=0和x=size.width的点）
          final intersections = [
            Offset(0, intercept),
            Offset(kChartViewWidth, slope * kChartViewWidth + intercept),
            Offset(-intercept / slope, 0),
            Offset((kChartViewHeight - intercept) / slope, kChartViewHeight),
          ];
          final intersections0 = [
            Offset(0, intercept1),
            Offset(kChartViewWidth, slope * kChartViewWidth + intercept1),
            Offset(-intercept1 / slope, 0),
            Offset((kChartViewHeight - intercept1) / slope, kChartViewHeight),
          ];
          final validPoints = intersections.where((p) => p.dx >= 0 && p.dx <= kChartViewWidth && p.dy >= 0 && p.dy <= kChartViewHeight).toList();
          if (validPoints.length >= 2) {
            validPoints.sort((a, b) => a.dx.compareTo(b.dx));
            path.moveTo(validPoints[0].dx, validPoints[0].dy);
            path.lineTo(validPoints[1].dx, validPoints[1].dy);
          }
          final points = intersections0.where((p) => p.dx >= 0 && p.dx <= kChartViewWidth && p.dy >= 0 && p.dy <= kChartViewHeight).toList();
          if (points.length >= 2) {
            points.sort((a, b) => a.dx.compareTo(b.dx));
            path.moveTo(points[0].dx, points[0].dy);
            path.lineTo(points[1].dx, points[1].dy);
          }
          e.path = path;
          _paintLines(canvas, e.lineType, path, framePaint);
          _paintPoints(canvas, Offset(thirdPointX, thirdPointY), framePaint);
        }
        canvas.restore();
      } //
      else if (e.pathType == 7 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///平行线
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        if (firstX == secondX) {
          path.moveTo(firstX, 0);
          path.lineTo(firstX, kChartViewHeight);
        } else if (firstY == secondY) {
          path.moveTo(0, firstY);
          path.lineTo(kChartViewWidth, firstY);
        } else {
          final k = (secondY - firstY) / (secondX - firstX);
          final b = firstY - k * firstX;
          final intersections = [
            Offset(0, b),
            Offset(kChartViewWidth, k * kChartViewWidth + b),
            Offset(-b / k, 0),
            Offset((kChartViewHeight - b) / k, kChartViewHeight),
          ];
          final validPoints = intersections.where((p) => p.dx >= 0 && p.dx <= kChartViewWidth && p.dy >= 0 && p.dy <= kChartViewHeight).toList();
          if (validPoints.length >= 2) {
            validPoints.sort((a, b) => a.dx.compareTo(b.dx));
            path.moveTo(validPoints[0].dx, validPoints[0].dy);
            path.lineTo(validPoints[1].dx, validPoints[1].dy);
          }
        }
        _paintPoints(canvas, Offset(firstX, firstY), framePaint);
        _paintPoints(canvas, Offset(secondX, secondY), framePaint);
        if (e.thirdPointX != null && e.thirdPointY != null) {
          double thirdPointX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.thirdPointX!) - mDataStartIndext) + leftMarginSpace;
          double thirdPointY = (mMaxPrice - (e.thirdPointY ?? 0)) * rate + textBottom;
          double slope = (secondY - firstY) / (secondX - firstX);
          double intercept = thirdPointY - slope * thirdPointX;
          // 计算平行线的两个端点（为了显示，我们选择x=0和x=size.width的点）
          final intersections = [
            Offset(0, intercept),
            Offset(kChartViewWidth, slope * kChartViewWidth + intercept),
            Offset(-intercept / slope, 0),
            Offset((kChartViewHeight - intercept) / slope, kChartViewHeight),
          ];
          final validPoints = intersections.where((p) => p.dx >= 0 && p.dx <= kChartViewWidth && p.dy >= 0 && p.dy <= kChartViewHeight).toList();
          if (validPoints.length >= 2) {
            validPoints.sort((a, b) => a.dx.compareTo(b.dx));
            path.moveTo(validPoints[0].dx, validPoints[0].dy);
            path.lineTo(validPoints[1].dx, validPoints[1].dy);
          }
          _paintPoints(canvas, Offset(thirdPointX, thirdPointY), framePaint);
          e.path = path;
        }
        _paintLines(canvas, e.lineType, path, framePaint);
        canvas.restore();
      } //
      else if (e.pathType == 9 && e.firstPointX != null && e.firstPointY != null && e.secondPointX != null && e.secondPointY != null) {
        ///三角线
        double firstX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.firstPointX!) - mDataStartIndext) + leftMarginSpace;
        double secondX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.secondPointX!) - mDataStartIndext) + leftMarginSpace;
        double firstY = (mMaxPrice - (e.firstPointY ?? 0)) * rate + textBottom;
        double secondY = (mMaxPrice - (e.secondPointY ?? 0)) * rate + textBottom;
        canvas.save();
        canvas.clipPath(tmp);
        path.moveTo(firstX, firstY);
        path.lineTo(secondX, secondY);
        _paintPoints(canvas, Offset(firstX, firstY), framePaint);
        _paintPoints(canvas, Offset(secondX, secondY), framePaint);
        if (e.thirdPointX != null && e.thirdPointY != null) {
          double thirdPointX = BaseKChartPainter.MARGINLEFT + mCandleWidth * (dateTOIndex(e.thirdPointX!) - mDataStartIndext) + leftMarginSpace;
          double thirdPointY = (mMaxPrice - (e.thirdPointY ?? 0)) * rate + textBottom;
          path.lineTo(thirdPointX, thirdPointY);
          path.lineTo(firstX, firstY);
          _paintPoints(canvas, Offset(thirdPointX, thirdPointY), framePaint);
        }
        e.path = path;
        _paintLines(canvas, e.lineType, path, framePaint);
        canvas.restore();
      } //
    }

    ///盈损线
    for (PLRecord e in pLRecordList) {
      Path path = Path();
      Path borderPath = Path(); // 绘制虚线
      framePaint
        ..color = e.selected ? Colors.red : Colors.blue
        ..strokeWidth = 1;
      double Y = 0;

      if (e.price != null) {
        Y = (mMaxPrice - (e.price ?? 0)) * rate + textBottom;
        e.lineY = Y;
      } else if (e.lineY != null) {
        e.price = double.tryParse((mMaxPrice - ((e.lineY! - textBottom) / rate)).toStringAsFixed(4));
        Y = e.lineY!;
      }

      if (dealY(Y)) {
        path.moveTo(startX, Y);
        path.lineTo(stopX, Y);
        e.path = path;
        canvas.drawPath(
            dashPath(
              path,
              dashArray: CircularIntervalList<double>([4, 4]),
            ),
            framePaint);

        double newY = Y - getStringHeight("${e.price}", textPaint);
        textPaint
          ..text = TextSpan(
            text: "${e.price}多头止${e.win ? "盈" : "损"}${e.RealQty}手",
          )
          ..textDirection = TextDirection.ltr
          ..layout();

        borderPath.moveTo(startX, Y);
        borderPath.lineTo(startX, newY);
        borderPath.lineTo(startX + textPaint.width, newY);
        borderPath.lineTo(startX + textPaint.width, Y);
        borderPath.close();
        canvas.drawPath(borderPath, framePaint..color = Colors.blue);
        textPaint.paint(canvas, Offset(startX, newY));
      }
    }
  }

  ///持仓线
  void drawPosLines(Canvas canvas) {
    Paint framePaint = MethodUntil().getDashPaint(Port.macdUpColor);
    TextPainter subTextPaint = MethodUntil().getTextPainter(Utils.dp2px(5));
    double rate = 1; //计算最小单位
    double textBottom = MARGINTOP;
    double startX = BaseKChartPainter.MARGINLEFT + leftMarginSpace;
    double stopX = kChartViewWidth;
    double Y = 0;
    framePaint.strokeWidth = Utils.dp2px(1);

    if (isDrawTime) {
      startX = BaseKChartPainter.MARGINLEFT + timeLeftMarginSpace;
      stopX = kChartViewWidth - rightMarginSpace;
    }
    for (HoldOrder e in holdOrder) {
      if (e.open != null) {
        if (isDrawTime) {
          double maxHeight = (mMaxPrice - lastClose) > (lastClose - mMinPrice) ? (mMaxPrice - lastClose) : (lastClose - mMinPrice); //最大价差
          rate = (kChartViewHeight - MARGINTOP - timeDownChartHeight) / (maxHeight * 2); //计算最小单位
          Y = (lastClose + maxHeight - e.open!) * rate;
        } else {
          rate = mUperChartHeight / (mMaxPrice - mMinPrice);
          Y = (mMaxPrice - (e.open ?? 0)) * rate + textBottom;
        }
      }
      if (dealY(Y)) {
        Path path = Path(); // 绘制虚线
        Path borderPath = Path(); // 绘制虚线
        path.moveTo(startX, Y);
        path.lineTo(stopX, Y);
        //横线
        canvas.drawPath(
          dashPath(
            path,
            dashArray: CircularIntervalList<double>(CUSTOM_DASH_EFFECT),
          ),
          framePaint,
        );

        double newY = Y -
            getStringHeight(
                "${Utils.d2SBySrc(e.open, e.FutureTickSize)}${e.orderSide == SideType.SIDE_BUY ? "买" : "卖"}${e.AvailableQty}手}", subTextPaint);

        textPaint
          ..text = TextSpan(
            children: [
              TextSpan(
                  text: "${Utils.d2SBySrc(e.open, e.FutureTickSize)}${e.orderSide == SideType.SIDE_BUY ? "买" : "卖"}${e.AvailableQty}手",
                  style: TextStyle(color: Port.costTwoColor)),
              if (e.floatProfit != null)
                TextSpan(
                    text: "${e.floatProfit! < 0 ? "亏" : "盈"}${e.floatProfit.obs.toStringAsFixed(4)}",
                    style: TextStyle(color: e.floatProfit! < 0 ? Port.costFourColor : Port.VR_Color))
            ],
          )
          ..textDirection = TextDirection.ltr
          ..layout();
        borderPath.moveTo(startX, Y);
        borderPath.lineTo(startX, newY);
        borderPath.lineTo(startX + textPaint.width, newY);
        borderPath.lineTo(startX + textPaint.width, Y);
        borderPath.close();
        canvas.drawPath(borderPath, framePaint);
        textPaint.paint(canvas, Offset(startX, newY));
      }
    }
  }

  List<OHLCEntity> getOHLCData() {
    List<OHLCEntity> list = [];
    if (mOHLCData.isNotEmpty) {
      list.addAll(mOHLCData);
    }
    return list;
  }

  static int getMaxPeriod(bool isDrawCost, bool isDrawBollinger, bool isDrawFall) {
    int max = 0;
    if (isDrawCost) {
      // 均线线周期
      max = max > CostOnePeriod ? max : CostOnePeriod;
      max = max > CostTwoPeriod ? max : CostTwoPeriod;
      max = max > CostThreePeriod ? max : CostThreePeriod;
      max = max > CostFourPeriod ? max : CostFourPeriod;
      max = max > CostFivePeriod ? max : CostFivePeriod;
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
    // if (isMidDrawMacd) {
    //   //  MACD线周期
    //   max = max > (macdPeriod + macdLPeriod) ? max : (macdPeriod + macdLPeriod);
    //   max = max > macdLPeriod ? max : macdLPeriod;
    // }
    // if (isDrawRsi) {
    //   //  rsi线周期
    //   max = max > rsiPeriod ? max : rsiPeriod;
    // }
    // if (isDrawPSY) {
    //   //  PSY线周期
    //   max = max > (PSYPeriod + PSYMAPeriod) ? max : (PSYPeriod + PSYMAPeriod);
    //   max = max > PSYPeriod ? max : PSYPeriod;
    // }
    // if (isDrawBIAS) {
    //   //  BIAS线周期
    //   max = max > BIAS1Period ? max : BIAS1Period;
    //   max = max > BIAS2Period ? max : BIAS2Period;
    //   max = max > BIAS3Period ? max : BIAS3Period;
    // }
    // if (isDrawCCI) {
    //   //  CCI线周期
    //   max = max > CCIPeriod ? max : CCIPeriod;
    // }
    // if (isDrawKDJ) {
    //   //  KDJ线周期
    //   max = max > KDJPeriod ? max : KDJPeriod;
    // }
    // if (isDrawWR) {
    //   //  WR线周期
    //   max = max > Wr1Period ? max : Wr1Period;
    //   max = max > Wr2Period ? max : Wr2Period;
    // }
    return max;
  }

  int currentIndex() {
    int number = 0;
    double marginLeft = BaseKChartPainter.MARGINLEFT + leftMarginSpace;
    int num = ((currentX - marginLeft) % mCandleWidth).toInt();
    if (num == 0) {
      number = (currentX - marginLeft) ~/ mCandleWidth;
    } else {
      number = ((currentX - marginLeft) / mCandleWidth + 1).toInt();
    }
    number = max(number, 0);
    number = number + mDataStartIndext;
    return number;
  }

  bool dealY(double Y) {
    // double positionY = Y;
    // positionY = positionY > kChartViewHeight - MARGINBOTTOM ? kChartViewHeight - MARGINBOTTOM : positionY;
    // positionY = positionY < MARGINTOP ? MARGINTOP : positionY;
    return Y < kChartViewHeight && Y > MARGINTOP;
  }

  int dateTOIndex(String date) {
    int x = mOHLCData.indexWhere((e) => "${e.date} ${e.time}" == date);
    double dx = BaseKChartPainter.MARGINLEFT + mCandleWidth * (x - mDataStartIndext) + leftMarginSpace;
    double i = (dx - leftMarginSpace - BaseKChartPainter.MARGINLEFT) / mCandleWidth;
    return min(i.round() + mDataStartIndext, mOHLCData.length);
  }

  _paintLines(Canvas canvas, int? type, Path path, Paint paint) {
    canvas.drawPath(
        type == 1
            ? path
            : dashPath(
                path,
                dashArray: CircularIntervalList<double>(type == 3
                    ? [1, 4]
                    : type == 4
                        ? [4, 1, 1]
                        : [4, 4]),
              ),
        paint);
  }

  _paintPoints(Canvas canvas, Offset offset, Paint paint) {
    canvas.drawRect(Rect.fromCenter(center: offset, width: 5, height: 5), paint);
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
}
