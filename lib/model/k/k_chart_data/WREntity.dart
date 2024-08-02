import 'package:path_drawing/path_drawing.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * WR指标线绘制，数据计算
 * @author hexuejian
 *
 */
class WREntity {
  /**WR数据集合*/
  List<double> WR1 = [];
  List<double> WR2 = [];
  /**WR最高价*/
  double maxPrice = 0.0;
  /**WR最低价*/
  double minPrice = 0.0;
  /** 默认字体大小 **/
  static double DEFAULT_AXIS_TITLE_SIZE = 22;
  /** 默认虚线效果 */
  List<double> DEFAULT_DASH_EFFECT = [2, 1];

  // static final PathEffect DEFAULT_DASH_EFFECT = new DashPathEffect(new double[] { 2, 3, 2,
  // 3 }, 1);
  /** 虚线颜色 */
  static const Color DEFAULT_DOTTED_COLOR = Colors.grey;
  /**增加数据类*/
  CalcIndexData mCalcData = CalcIndexData();

  WREntity() {
    WR1 = [];
    WR2 = [];
  }

  /**
   * 初始化RSI数据
   * @param OHLCData
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int period1, int period2, int pri_type) {
    WR1.clear();
    WR2.clear();

    if (OHLCData == null || OHLCData.isEmpty) {
      return;
    }

    //WR1:=100*(HHV(HIGH,N1)-close)/(HHV(HIGH,N1)-LLV(HIGH,N1));
    //计算WR1
    for (int i = period1 - 1; i < OHLCData.length; i++) {
      double ll = 0.0, hh = 0.0;
      double wr1 = 0;
      hh = mCalcData.calcHighest(OHLCData, period1, i);
      ll = mCalcData.calcLowest(OHLCData, period1, i);
      if ((hh - ll) == 0) {
        wr1 = 0;
      } else {
        wr1 = 100 * (hh - (OHLCData[i].close ?? 0)) / (hh - ll);
      }
      WR1.add(wr1);
    }

    //计算WR2
    for (int i = period2 - 1; i < OHLCData.length; i++) {
      double ll = 0.0, hh = 0.0;
      double wr2 = 0;
      hh = mCalcData.calcHighest(OHLCData, period2, i);
      ll = mCalcData.calcLowest(OHLCData, period2, i);
      if ((hh - ll) == 0) {
        wr2 = 0;
      } else {
        wr2 = 100 * (hh - (OHLCData[i].close ?? 0)) / (hh - ll);
      }
      WR2.add(wr2);
    }
  }

  /**
   * 获得Rsi价格
   */
  double getPrice(List<OHLCEntity> OHLCData, int j, int i, int period, int pri_type) {
    num price = 0.0;
    switch (pri_type) {
      case 0: //开
        price = (OHLCData[j + i - (period - 1)].open ?? 0) - (OHLCData[j + i - (period - 1) - 1].open ?? 0);
        break;

      case 1: //高
        price = (OHLCData[j + i - (period - 1)].high ?? 0) - (OHLCData[j + i - (period - 1) - 1].high ?? 0);
        break;

      case 2: //收
        price = (OHLCData[j + i - (period - 1)].close ?? 0) - (OHLCData[j + i - (period - 1) - 1].close ?? 0);
        break;

      case 3: //低
        price = (OHLCData[j + i - (period - 1)].low ?? 0) - (OHLCData[j + i - (period - 1) - 1].low ?? 0);
        break;

      case 4: //高低一半
        price = ((OHLCData[j + i - (period - 1)].high ?? 0) + (OHLCData[j + i - (period - 1)].low ?? 0)) / 2 -
            ((OHLCData[j + i - (period - 1) - 1].high ?? 0) + (OHLCData[j + i - (period - 1) - 1].low ?? 0)) / 2;
        break;

      default:
        break;
    }
    return price.toDouble();
  }

  /**
   * 增加KDJ数据
   * @param OHLCData
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int period1, int period2, int pri_type, int count) {
    if (WR1.isEmpty || WR2.isEmpty) {
      return;
    }

    Map<String, double> map = mCalcData.calcWR(OHLCData, period1, period2, OHLCData.length - 1);
    if (map == null) return;

    WR1.remove(WR1.length - 1);
    WR2.remove(WR2.length - 1);

    for (int i = count; i > 0; i--) {
      Map<String, double> value = mCalcData.calcWR(OHLCData, period1, period2, OHLCData.length - i);
      double wr1 = value["WR1"] ?? 0;
      double wr2 = value["WR2"] ?? 0;
      WR1.add(wr1);
      WR2.add(wr2);
    }
  }

  /**
   * 绘制WR,价格线
   */
  void drawWR(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL, double MARGINLEFT,
      double MARGINBOTTOM, double LOWER_CHART_TOP, double mRightArea, int Wr1Period, int Wr2Period) {
    double lowerHight = viewHeight - LOWER_CHART_TOP - MARGINBOTTOM - DEFAULT_AXIS_TITLE_SIZE - 10; //下表高度
    double latitudeSpacing = lowerHight / 6; //每格高度
    double rate = 0.0; //每单位像素价格
    Paint greenPaint = MethodUntil().getDrawPaint(Port.WR1Color);
    Paint yellowPaint = MethodUntil().getDrawPaint(Port.WR2Color);
    TextPainter textPaint = TextPainter(); //MethodUntil().getDrawPaint(Port.chartTxtColor);
    Paint dottedPaint = MethodUntil().getDrawPaint(Port.girdColor); //虚线画笔
    // dottedPaint.setPathEffect(DEFAULT_DASH_EFFECT);
    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // dottedPaint.setStrokeWidth(1); // 设置画笔大小
    yellowPaint.strokeWidth = Port.WRWidth[0];
    greenPaint.strokeWidth = Port.WRWidth[1];
    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
    // textPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);

    maxPrice = 100.0;
    minPrice = 0.0;
    rate = lowerHight / (maxPrice - minPrice);
    double textBottom = DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = MARGINLEFT;

    //绘制虚线
    for (int i = 1; i <= 5; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(MARGINLEFT, LOWER_CHART_TOP + latitudeSpacing * i + textBottom);
      path.lineTo(viewWidth - MARGINLEFT - mRightArea, LOWER_CHART_TOP + latitudeSpacing * i + textBottom);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        dottedPaint,
      );
    }
    //绘制价格
    double perPrice = (maxPrice - minPrice) / (5 + 1); //计算每一格纬线框所占有的价格
    for (int i = 1; i <= 5; i++) {
      // if (Port.drawFlag==1) {
      //   canvas.drawText(Utils.getPointNum(minPrice+perPrice*i), viewWidth - MARGINLEFT-mRightArea, viewHeight - MARGINBOTTOM - latitudeSpacing*i + DEFAULT_AXIS_TITLE_SIZE/2,
      //       textPaint);
      // }else{
      //   canvas.drawText(Utils.getPointNum(minPrice+perPrice*i), MARGINLEFT, viewHeight - MARGINBOTTOM - latitudeSpacing*i,
      //       textPaint);
      textPaint
        ..text = TextSpan(text: Utils.getPointNum(minPrice + perPrice * i), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(MARGINLEFT, viewHeight - MARGINBOTTOM - latitudeSpacing * i));
      // }
    }

    //绘制WR
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double nextX = MARGINLEFT + mCandleWidth * number + mCandleWidth;

      //从周期开始才绘制WR
      if (i >= Wr1Period - 1) {
        //wr1线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (Wr1Period - 1) : i - (Wr1Period - 1) + 1;
        if (nextNumber < WR1.length) {
          double startY = (LOWER_CHART_TOP + (maxPrice - WR1[i - (Wr1Period - 1)]) * rate + textBottom);
          double stopY = (LOWER_CHART_TOP + (maxPrice - WR1[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), greenPaint);
        }
      }

      if (i >= Wr2Period - 1) {
        //wr2线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (Wr2Period - 1) : i - (Wr2Period - 1) + 1;
        if (nextNumber < WR2.length) {
          double startY = (LOWER_CHART_TOP + (maxPrice - WR2[i - (Wr2Period - 1)]) * rate + textBottom);
          double stopY = (LOWER_CHART_TOP + (maxPrice - WR2[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), yellowPaint);
        }
      }

      //绘制当前周期，最新一根数据的KDJ
      if (i == (mDataStartIndext + mShowDataNum - 1)) {
        String wr1, wr2;
        if ((mDataStartIndext + mShowDataNum) > Wr1Period && (i - (Wr1Period - 1)) < WR1.length) {
          wr1 = Utils.getPointNum(WR1[i - (Wr1Period - 1)]);
        } else {
          wr1 = "0.000";
        }
        if ((mDataStartIndext + mShowDataNum) > Wr2Period && (i - (Wr2Period - 1)) < WR2.length) {
          wr2 = Utils.getPointNum(WR2[i - (Wr2Period - 1)]);
        } else {
          wr2 = "0.000";
        }

        String text = "WR($Wr1Period , $Wr2Period)";
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "WR1: $wr1";
        // textPaint.setColor(Port.WR1Color);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.WR1Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "WR2: $wr2";
        // textPaint.setColor(Port.WR2Color);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.WR2Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;
      }
    }
  }
}
