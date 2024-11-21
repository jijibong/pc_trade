import 'package:path_drawing/path_drawing.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/painter/k_chart/sub_chart_painter.dart';
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
  static double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
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
  void drawWR(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL,
      double leftMarginSpace, double halfTextHeight, int Wr1Period, int Wr2Period) {
    double lowerHight = viewHeight - Port.defult_margin_top - halfTextHeight * 2;
    double latitudeSpacing = lowerHight / 2; //每格高度
    double rate = 0.0; //每单位像素价格
    Paint greenPaint = MethodUntil().getDrawPaint(Port.WR1Color);
    Paint yellowPaint = MethodUntil().getDrawPaint(Port.WR2Color);
    TextPainter textPaint = TextPainter(); //MethodUntil().getDrawPaint(Port.chartTxtColor);
    Paint dottedPaint = MethodUntil().getDrawPaint(Port.girdColor); //虚线画笔
    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    yellowPaint.strokeWidth = Port.WRWidth[0];
    greenPaint.strokeWidth = Port.WRWidth[1];

    maxPrice = 100.0;
    minPrice = 0.0;
    rate = lowerHight / (maxPrice - minPrice);
    double textBottom = DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = Port.defult_icon_width + leftMarginSpace;

    //绘制虚线
    Path path = Path(); // 绘制虚线
    path.moveTo(leftMarginSpace, latitudeSpacing + textBottom);
    path.lineTo(viewWidth - leftMarginSpace, latitudeSpacing + textBottom);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      dottedPaint,
    );
    //绘制价格
    double perPrice = (maxPrice - minPrice) / 2; //计算每一格纬线框所占有的价格
    double textWidth1 = SubChartPainter.getStringWidth("${Utils.getPointNum(minPrice + perPrice)} ", textPaint);
    textPaint
      ..text = TextSpan(text: Utils.getPointNum(minPrice + perPrice), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftMarginSpace - textWidth1, latitudeSpacing + textBottom - halfTextHeight));

    //绘制WR
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = mCandleWidth * (i - mDataStartIndext) + mCandleWidth + leftMarginSpace;
      double nextX = mCandleWidth * number + mCandleWidth + leftMarginSpace;

      //从周期开始才绘制WR
      if (i >= Wr1Period - 1) {
        //wr1线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (Wr1Period - 1) : i - (Wr1Period - 1) + 1;
        if (nextNumber < WR1.length) {
          double startY = (maxPrice - WR1[i - (Wr1Period - 1)]) * rate + textBottom;
          double stopY = (maxPrice - WR1[nextNumber]) * rate + textBottom;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), greenPaint);
        }
      }

      if (i >= Wr2Period - 1) {
        //wr2线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (Wr2Period - 1) : i - (Wr2Period - 1) + 1;
        if (nextNumber < WR2.length) {
          double startY = (maxPrice - WR2[i - (Wr2Period - 1)]) * rate + textBottom;
          double stopY = (maxPrice - WR2[nextNumber]) * rate + textBottom;
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
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "WR1: $wr1";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.WR1Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "WR2: $wr2";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.WR2Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;
      }
    }
  }
}
