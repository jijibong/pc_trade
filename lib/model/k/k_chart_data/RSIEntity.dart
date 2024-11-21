import 'package:path_drawing/path_drawing.dart';

import 'package:fluent_ui/fluent_ui.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/painter/k_chart/sub_chart_painter.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * RSI指标线绘制，数据计算
 * @author hexuejian
 *
 */
class RSIEntity {
  /**RSI数据集合*/
  List<double> RSIs = [];
  /**RSI最高价*/
  double maxPrice = 0.0;
  /**RSI最低价*/
  double minPrice = 0.0;
  /** 默认字体大小 **/
  static double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  /** 默认虚线效果 */
  // static final PathEffect DEFAULT_DASH_EFFECT = new DashPathEffect(new double[] { 2, 3, 2,
  // 3 }, 1);
  List<double> DEFAULT_DASH_EFFECT = [2, 1];

  /** 虚线颜色 */
  static Color DEFAULT_DOTTED_COLOR = Colors.red;
  /**增加数据类*/
  CalcIndexData mCalcData = CalcIndexData();

  RSIEntity() {
    RSIs = [];
  }

  /**
   * 初始化RSI数据
   * @param OHLCData
   * @param period
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int period, int priType) {
    RSIs.clear();

    if (OHLCData == null || OHLCData.isEmpty) {
      return;
    }

    for (int i = period - 1; i < OHLCData.length; i++) {
      double rise = 0.0;
      double down = 0.0;

      for (int j = 0; j < period; j++) {
        //计算周期内的上升和下跌平均数
        double price = 0.0;
        if (j >= 1) {
          price = getPrice(OHLCData, j, i, period, priType);
          if (price >= 0) {
            //升幅
            rise += price;
          } else {
            //跌幅
            down += price.abs();
          }
        }
      }

      rise = rise / period;
      down = down / period;
      // ＲＳＩ＝[上升平均数÷(上升平均数＋下跌平均数)]×100
      double rsi = 0.0;
      if (rise.isNaN || down.isNaN) {
        rsi = 0.0;
      } else if (rise == 0 && down == 0) {
        rsi = 0.0;
      } else {
        rsi = rise / (rise + down) * 100;
      }

      RSIs.add(rsi);
    }
  }

  /**
   * 获得Rsi价格
   */
  double getPrice(List<OHLCEntity> OHLCData, int j, int i, int period, int priType) {
    double price = 0.0;
    switch (priType) {
      case 0: //开
        price = ((OHLCData[j + i - (period - 1)].open ?? 0) - (OHLCData[j + i - (period - 1) - 1].open ?? 0)).toDouble();
        break;

      case 1: //高
        price = ((OHLCData[j + i - (period - 1)].high ?? 0) - (OHLCData[j + i - (period - 1) - 1].high ?? 0)).toDouble();
        break;

      case 2: //收
        price = ((OHLCData[j + i - (period - 1)].close ?? 0) - (OHLCData[j + i - (period - 1) - 1].close ?? 0)).toDouble();
        break;

      case 3: //低
        price = ((OHLCData[j + i - (period - 1)].low ?? 0) - (OHLCData[j + i - (period - 1) - 1].low ?? 0)).toDouble();
        break;

      case 4: //高低一半
        price = ((OHLCData[j + i - (period - 1)].high ?? 0) + (OHLCData[j + i - (period - 1)].low ?? 0)) / 2 -
            ((OHLCData[j + i - (period - 1) - 1].high ?? 0) + (OHLCData[j + i - (period - 1) - 1].low ?? 0)) / 2;
        break;

      default:
        break;
    }
    return price;
  }

  /**
   * 增加RSI数据
   * @param OHLCData
   * @param period
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int period, int priType, int count) {
    if (RSIs.isEmpty) {
      return;
    }
    if (mCalcData.calcRsi(OHLCData, period, priType, OHLCData.length - 1) == double.maxFinite) return;

    RSIs.remove(RSIs.length - 1);

    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcRsi(OHLCData, period, priType, OHLCData.length - i);
      RSIs.add(value);
    }
  }

  /**
   * 绘制RSI,价格线
   */
  void drawRSI(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL,
      double leftMarginSpace, double halfTextHeight, int rsiPeriod) {
    double textBottom = Port.defult_margin_top;
    double lowerHeight = viewHeight - textBottom - halfTextHeight * 2;
    double rate = 0.0; //每单位像素价格
    Paint yellowPaint = MethodUntil().getDrawPaint(Port.rsiColor);
    TextPainter textPaint = TextPainter();
    Paint dottedPaint = MethodUntil().getDrawPaint(DEFAULT_DOTTED_COLOR); //虚线画笔
    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    yellowPaint.strokeWidth = Port.rsiWidth;

    rate = lowerHeight / 100;

    //绘制价格30线
    Path path = Path();
    double Y = viewHeight - lowerHeight * 0.5 + textBottom;
    String price = "50";
    path.moveTo(leftMarginSpace, Y);
    path.lineTo(viewWidth - leftMarginSpace, Y);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      dottedPaint,
    );

    double textWidth = SubChartPainter.getStringWidth("$price ", textPaint);
    textPaint
      ..text = TextSpan(text: price, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftMarginSpace - textWidth, Y - halfTextHeight));

    //绘制RSI
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = mCandleWidth * (i - mDataStartIndext) + mCandleWidth + leftMarginSpace;
      double nextX = mCandleWidth * (number) + mCandleWidth + leftMarginSpace;

      //从周期开始才绘制RSI
      if (i >= rsiPeriod - 1) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (rsiPeriod - 1) : i - (rsiPeriod - 1) + 1;
        if (nextNumber < RSIs.length) {
          double startY = viewHeight - RSIs[i - (rsiPeriod - 1)] * rate + textBottom;
          double stopY = viewHeight - RSIs[nextNumber] * rate + textBottom;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), yellowPaint);
        }
      }

      //绘制当前周期，最新一根数据的rsi
      if (i == mDataStartIndext + mShowDataNum - 1) {
        String rsi;
        if ((mDataStartIndext + mShowDataNum) > rsiPeriod && i - (rsiPeriod - 1) < RSIs.length) {
          rsi = Utils.getPointNum(RSIs[i - (rsiPeriod - 1)]);
        } else {
          rsi = "0.000";
        }

        String text = "RSI($rsiPeriod):$rsi";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.rsiColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(Port.defult_icon_width + leftMarginSpace, Port.text_check));
      }
    }
  }
}
