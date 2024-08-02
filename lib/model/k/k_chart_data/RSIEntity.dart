import 'package:path_drawing/path_drawing.dart';

import 'package:fluent_ui/fluent_ui.dart';
import '../../../util/painter/k_chart/method_util.dart';
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
  static double DEFAULT_AXIS_TITLE_SIZE = 22;
  /** 默认虚线效果 */
  // static final PathEffect DEFAULT_DASH_EFFECT = new DashPathEffect(new double[] { 2, 3, 2,
  // 3 }, 1);
  List<double> DEFAULT_DASH_EFFECT = [2, 1];

  /** 虚线颜色 */
  static const Color DEFAULT_DOTTED_COLOR = Colors.grey;
  /**增加数据类*/
  CalcIndexData mCalcData = new CalcIndexData();

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
  void drawRsi(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int candleInterval,
      double MARGINLEFT, double MARGINBOTTOM, double lowerChartTop, double mRightArea, int rsiPeriod) {
    double lowerHight = viewHeight - lowerChartTop - MARGINBOTTOM - DEFAULT_AXIS_TITLE_SIZE - 10; //下表高度
    double rate = 0.0; //每单位像素价格
    Paint yellowPaint = MethodUntil().getDrawPaint(Port.rsiColor);
    TextPainter textPaint = TextPainter(); //MethodUntil().getDrawPaint(Port.chartTxtColor);
    Paint dottedPaint = MethodUntil().getDrawPaint(DEFAULT_DOTTED_COLOR); //虚线画笔
    // dottedPaint.setPathEffect(DEFAULT_DASH_EFFECT);
    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    yellowPaint.strokeWidth = Port.rsiWidth;
    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
    // textPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);

    rate = lowerHight / 100;

    //绘制价格30线
    Path path = Path();
    double Y30 = (viewHeight - MARGINBOTTOM - lowerHight * 0.3);
    String price30 = "30.00";
    path.moveTo(MARGINLEFT, Y30);
    path.lineTo(viewWidth - MARGINLEFT - mRightArea, Y30);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      dottedPaint,
    );

    //70线
    double Y70 = (viewHeight - MARGINBOTTOM - lowerHight * 0.7);
    String price70 = "70.00";
    path.moveTo(MARGINLEFT, Y70);
    path.lineTo(viewWidth - MARGINLEFT - mRightArea, Y70);
    // canvas.drawPath(path, dottedPaint);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      dottedPaint,
    );

    // if (Port.drawFlag == 1) {
    //   canvas.drawText(price30, viewWidth - MARGINLEFT - mRightArea, Y30+DEFAULT_AXIS_TITLE_SIZE/2, textPaint);
    //   canvas.drawText(price70, viewWidth - MARGINLEFT - mRightArea, Y70+DEFAULT_AXIS_TITLE_SIZE/2, textPaint);
    //   //0线价格
    //   canvas.drawText("0.00", viewWidth - MARGINLEFT - mRightArea, viewHeight - MARGINBOTTOM, textPaint);
    //   //100线价格
    //   canvas.drawText("100.00", viewWidth - MARGINLEFT - mRightArea, lowerChartTop + DEFAULT_AXIS_TITLE_SIZE , textPaint);
    // }else{
    //   canvas.drawText(price30, MARGINLEFT, Y30, textPaint);
    //   canvas.drawText(price70, MARGINLEFT, Y70, textPaint);
    //0线价格
    // canvas.drawText("0.00", MARGINLEFT, viewHeight - MARGINBOTTOM, textPaint);

    textPaint
      ..text = TextSpan(text: price30, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(MARGINLEFT, Y30));
    textPaint
      ..text = TextSpan(text: price70, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(MARGINLEFT, Y70));
    textPaint
      ..text = TextSpan(text: "0.00", style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(MARGINLEFT, viewHeight - MARGINBOTTOM));
    //100线价格
//			canvas.drawText("100.00", MARGINLEFT, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE , textPaint);
//     }

    //绘制RSI
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = (MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth);
      double nextX = (MARGINLEFT + mCandleWidth * (number) + mCandleWidth);

      //从周期开始才绘制RSI
      if (i >= rsiPeriod - 1) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (rsiPeriod - 1) : i - (rsiPeriod - 1) + 1;
        if (nextNumber < RSIs.length) {
          double startY = viewHeight - MARGINBOTTOM - RSIs[i - (rsiPeriod - 1)] * rate;
          double stopY = viewHeight - MARGINBOTTOM - RSIs[nextNumber] * rate;
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
        // textPaint.setColor(Port.rsiColor);
        // canvas.drawText(text, MARGINLEFT, lowerChartTop+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.rsiColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(MARGINLEFT, lowerChartTop + DEFAULT_AXIS_TITLE_SIZE + 5));
      }
    }
  }
}
