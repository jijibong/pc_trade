import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';

import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * Bollinger指标线绘制，数据计算
 * @author hexuejian
 *
 */
class BollingerEntity {
  /**Bollinger周期内均线数据集合*/
  List<double> BollingerAVE = [];
  /**Bollinger周期内标准差数据集合*/
  List<double> BollingerSQRT = [];
  /** 默认字体大小 **/
  static double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  /**增加数据类*/
  CalcIndexData mCalcData = CalcIndexData();

  BollingerEntity() {
    BollingerAVE = [];
    BollingerSQRT = [];
  }

  /**
   * 初始化Bollinger数据
   * @param OHLCData
   * @param period
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int period, int type, int pri_type) {
    BollingerAVE.clear();
    BollingerSQRT.clear();

    if (OHLCData == null || OHLCData.isEmpty) {
      return;
    }

    switch (type) {
      case 0: //简单移动平均线

        calcSimple(OHLCData, period, pri_type);
        break;

      case 1: //指数移动平均线

        calcExponential(OHLCData, period, pri_type);
        break;

      case 2: //平滑移动平均线

        calcSmoothed(OHLCData, period, pri_type);
        break;

      default:
        break;
    }

    //计算周期内标准差
    for (int i = 0; i < BollingerAVE.length; i++) {
      double a1 = 0.0;
      for (int j = 0; j < period; j++) {
        // 计算十根的平方的和
        a1 += (getPrice(OHLCData, j + i, pri_type) - BollingerAVE[i]) * (getPrice(OHLCData, j + i, pri_type) - BollingerAVE[i]);
      }
      BollingerSQRT.add(sqrt(a1 / period)); // 计算第10的平方根
    }
  }

  /**
   * 计算简单移动平均线
   */
  void calcSimple(List<OHLCEntity> OHLCData, int period, int pri_type) {
    //计算周期内均线
    for (int i = period - 1; i < OHLCData.length; i++) {
      double a = 0.0;
      for (int j = 0; j < period; j++) {
        a += getPrice(OHLCData, j + i - (period - 1), pri_type);
      }
      BollingerAVE.add(a / period);
    }
  }

  /**
   * 计算指数移动平均线
   */
  void calcExponential(List<OHLCEntity> OHLCData, int period, int pri_type) {
    //计算周期内均线
    for (int i = period - 1; i < OHLCData.length; i++) {
      double a = 0.0;
      for (int j = 0; j < period; j++) {
        a += getPrice(OHLCData, j + i - (period - 1), pri_type);
      }
      BollingerAVE.add(a / period);
    }
  }

  /**
   * 计算顺畅移动平均线
   */
  void calcSmoothed(List<OHLCEntity> OHLCData, int period, int pri_type) {
    //计算周期内均线
    for (int i = period - 1; i < OHLCData.length; i++) {
      double a = 0.0;
      for (int j = 0; j < period; j++) {
        a += getPrice(OHLCData, j + i - (period - 1), pri_type);
      }
      double ave = a / period;
      double value = (a - ave + (OHLCData[i].close ?? 0)) / period;
      BollingerAVE.add(value);
    }
  }

  /**
   * 获得Bollinger价格
   */
  double getPrice(List<OHLCEntity> OHLCData, int i, int pri_type) {
    double price = 0.0;
    switch (pri_type) {
      case 0: //开
        price = OHLCData[i].open?.toDouble() ?? 0;
        break;

      case 1: //高
        price = OHLCData[i].high?.toDouble() ?? 0;
        break;

      case 2: //收
        price = OHLCData[i].close?.toDouble() ?? 0;
        break;

      case 3: //低
        price = OHLCData[i].low?.toDouble() ?? 0;
        break;

      case 4: //高低一半
        price = ((OHLCData[i].high ?? 0) + (OHLCData[i].low ?? 0)) / 2;
        break;

      default:
        break;
    }
    return price;
  }

  /**
   * 增加布林带数据
   * @param OHLCData
   * @param period
   * @param type
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int period, int type, int pri_type, int count) {
    if (BollingerAVE.isEmpty || BollingerSQRT.isEmpty) {
      return;
    }

    Map<String, double> map = mCalcData.calcBollinger(OHLCData, period, type, pri_type, OHLCData.length - 1);
    if (map == null) return;

    BollingerAVE.remove(BollingerAVE.length - 1);
    BollingerSQRT.remove(BollingerSQRT.length - 1);

    for (int i = count; i > 0; i--) {
      Map<String, double> value = mCalcData.calcBollinger(OHLCData, period, type, pri_type, OHLCData.length - i);
      double ave = value["ave"] ?? 0;
      double sqrt = value["sqrt"] ?? 0;
      BollingerAVE.add(ave);
      BollingerSQRT.add(sqrt);
    }
  }

  /**
   * 绘制布林线
   */
  void drawBollinger(Canvas canvas, int mDataStartIndext, int mShowDataNum, double mCandleWidth, double mMaxPrice, double mMinPrice, int CANDLE_INTERVAL,
      double MARGINLEFT, double leftMarginSpace, double MARGINTOP, double uperChartHeight, int BollingerPeriod, double BollingerSD) {
    double rate = 0.0; //每单位像素价格
    Paint midPaint = MethodUntil().getDrawPaint(Port.BollingerMidColor);
    Paint upPaint = MethodUntil().getDrawPaint(Port.BollingerUpColor);
    Paint downPaint = MethodUntil().getDrawPaint(Port.BollingerDownColor);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.chartTxtColor);
    midPaint.strokeWidth = Port.BollingerWidth[1];
    upPaint.strokeWidth = Port.BollingerWidth[0];
    downPaint.strokeWidth = Port.BollingerWidth[2];

    rate = (uperChartHeight - DEFAULT_AXIS_TITLE_SIZE - 10) / (mMaxPrice - mMinPrice); //计算最小单位
    double textBottom = MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = MARGINLEFT + Port.defult_icon_width + leftMarginSpace;

    //绘制Bollinger
//		double lastY = 0;
//		double lastX = 0;
//		Path areaPath = new Path();
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth + leftMarginSpace;
      double nextX = MARGINLEFT + mCandleWidth * (number) + mCandleWidth + leftMarginSpace;

      //从周期开始才绘制Bollinger
      if (i >= BollingerPeriod - 1) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (BollingerPeriod - 1) : i - (BollingerPeriod - 1) + 1;
        if (nextNumber >= BollingerAVE.length) return;
        //绘制UP线
        double startY = (mMaxPrice - (BollingerAVE[i - (BollingerPeriod - 1)] + BollingerSD * BollingerSQRT[i - (BollingerPeriod - 1)])) * rate + textBottom;
        double stopY = (mMaxPrice - (BollingerAVE[nextNumber] + BollingerSD * BollingerSQRT[nextNumber])) * rate + textBottom;
        canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), upPaint);
        //绘制中间线
        double mStartY = (mMaxPrice - BollingerAVE[i - (BollingerPeriod - 1)]) * rate + textBottom;
        double mStopY = (mMaxPrice - BollingerAVE[nextNumber]) * rate + textBottom;
        canvas.drawLine(Offset(startX, mStartY), Offset(nextX, mStopY), midPaint);
        //绘制DOWN线
        double dStartY = (mMaxPrice - (BollingerAVE[i - (BollingerPeriod - 1)] - BollingerSD * BollingerSQRT[i - (BollingerPeriod - 1)])) * rate + textBottom;
        double dStopY = (mMaxPrice - (BollingerAVE[nextNumber] - BollingerSD * BollingerSQRT[nextNumber])) * rate + textBottom;
        canvas.drawLine(Offset(startX, dStartY), Offset(nextX, dStopY), downPaint);
      }

      //绘制当前周期，最新一根数据的up,down,middle
      // logger.i("i:$i ,mDataStartIndext:$mDataStartIndext ,mShowDataNum:$mShowDataNum");

      if (i == mDataStartIndext + mShowDataNum - 1) {
        String up, mid, down;
        if ((mDataStartIndext + mShowDataNum) > BollingerPeriod &&
            (i - (BollingerPeriod - 1)) < BollingerAVE.length &&
            (i - (BollingerPeriod - 1)) < BollingerSQRT.length) {
          up = Utils.getPointNum((BollingerAVE[i - (BollingerPeriod - 1)] + 2 * BollingerSQRT[i - (BollingerPeriod - 1)]));
          mid = Utils.getPointNum((BollingerAVE[i - (BollingerPeriod - 1)]));
          down = Utils.getPointNum((BollingerAVE[i - (BollingerPeriod - 1)] - 2 * BollingerSQRT[i - (BollingerPeriod - 1)]));
        } else {
          up = "0.000";
          mid = "0.000";
          down = "0.000";
        }
        String text = "BLD($BollingerPeriod, $BollingerSD)";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP - (Port.text_check / 3)));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) + 15;

        text = "TOP:$up";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.BollingerUpColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP - (Port.text_check / 3)));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) + 15;

        text = "MID:$mid";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.BollingerMidColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP - (Port.text_check / 3)));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) + 15;

        text = "BOTTOM:$down";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.BollingerDownColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP - (Port.text_check / 3)));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) + 15;
      }
    }
  }
}
