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
 * PSY心理线指标线绘制，数据计算
 * @author hexuejian
 *
 */
class PSYEntity {
  /**PSY数据集合*/
  List<double> PSYs = [];
  /**PSYMA数据集合*/
  List<double> PSYMAs = [];
  /**PSY最高价*/
  double maxPrice = 0.0;
  /**PSY最低价*/
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

  PSYEntity() {
    PSYs = [];
    PSYMAs = [];
  }

  /**
   * 初始化RSI数据
   * @param OHLCData
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int psyPeriod, int psyMaPeriod, int pri_type) {
    PSYs.clear();
    PSYMAs.clear();

    if (OHLCData == null || OHLCData.length == 0) {
      return;
    }

    //计算PSY
    for (int i = psyPeriod - 1; i < OHLCData.length; i++) {
      double psy = 0.0;
      psy = mCalcData.calcINPSY(OHLCData, psyPeriod, i);
      PSYs.add(psy);
    }

    //计算psyma
    for (int i = psyPeriod + psyMaPeriod - 1; i < OHLCData.length; i++) {
      double psyma = 0.0;
      double sumPsy = 0.0;
      for (int j = i - psyMaPeriod + 1; j <= i; j++) {
        sumPsy += mCalcData.calcINPSY(OHLCData, psyPeriod, j);
      }
      psyma = sumPsy / psyMaPeriod;
      PSYMAs.add(psyma);
    }
  }

  /**
   * 获得Rsi价格
   */
  //  double getPrice(List<OHLCEntity> OHLCData , int j , int i , int period , int pri_type){
  //   double price= 0.0;
  //   switch (pri_type) {
  //
  //     case 0://开
  //       price = OHLCData[j + i - (period - 1)).getOpen()- OHLCData[j + i - (period - 1) - 1).getOpen();
  //       break;
  //
  //     case 1://高
  //       price = OHLCData[j + i - (period - 1)).getHigh()- OHLCData[j + i - (period - 1) - 1).getHigh();
  //       break;
  //
  //     case 2://收
  //       price = OHLCData[j + i - (period - 1)).getClose()- OHLCData[j + i - (period - 1) - 1).getClose();
  //       break;
  //
  //     case 3://低
  //       price = OHLCData[j + i - (period - 1)).getLow()- OHLCData[j + i - (period - 1) - 1).getLow();
  //       break;
  //
  //     case 4://高低一半
  //       price = (OHLCData[j + i - (period - 1)).getHigh()+OHLCData[j + i - (period - 1)).getLow()) / 2
  //           - (OHLCData[j + i - (period - 1) -1).getHigh()+OHLCData[j + i - (period - 1) -1).getLow()) / 2;
  //       break;
  //
  //     default:
  //       break;
  //   }
  //   return price;
  // }

  /**
   * 增加RSI数据
   * @param OHLCData
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int psyPeriod, int psyMaPeriod, int pri_type, int count) {
    if (PSYs.isEmpty || PSYMAs.isEmpty) {
      return;
    }
    if (mCalcData.calcPSY(OHLCData, psyPeriod, psyMaPeriod, OHLCData.length - 1) == null) return;

    PSYs.remove(PSYs.length - 1);
    PSYMAs.remove(PSYMAs.length - 1);

    for (int i = count; i > 0; i--) {
      double psy = 0.0, psyMa = 0.0;

      Map<String, double> value = mCalcData.calcPSY(OHLCData, psyPeriod, psyMaPeriod, OHLCData.length - i);
      psy = value["PSY"] ?? 0;
      psyMa = value["PSYMA"] ?? 0;

      PSYs.add(psy);
      PSYMAs.add(psyMa);
    }
  }

  /**
   * 绘制PSY,价格线
   */
  void drawPSY(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL,
      double leftMarginSpace, double halfTextHeight, int PSYPeriod, int PSYMAPeriod) {
    double textBottom = Port.defult_margin_top;
    double lowerHeight = viewHeight - textBottom - halfTextHeight * 2;
    double rate = 0.0; //每单位像素价格
    Paint redPaint = MethodUntil().getDrawPaint(Port.PSYColor);
    Paint yellowPaint = MethodUntil().getDrawPaint(Port.PSYMAColor);
    TextPainter textPaint = TextPainter();
    Paint dottedPaint = MethodUntil().getDrawPaint(DEFAULT_DOTTED_COLOR); //虚线画笔
    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    redPaint.strokeWidth = Port.PSYWidth[0];
    yellowPaint.strokeWidth = Port.PSYWidth[1];

    rate = lowerHeight / 100;
    double textXStart = Port.defult_icon_width + leftMarginSpace;

    //绘制价格25线
    Path path = Path();
    double Y25 = viewHeight - textBottom - lowerHeight * 0.25;
    String price25 = "25.00";
    path.moveTo(leftMarginSpace, Y25);
    path.lineTo(viewWidth - leftMarginSpace, Y25);
    // canvas.drawPath(path, dottedPaint);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      dottedPaint,
    );

    //70线
    double Y70 = viewHeight - textBottom - lowerHeight * 0.7;
    String price70 = "70.00";
    path.moveTo(leftMarginSpace, Y70);
    path.lineTo(viewWidth - leftMarginSpace, Y70);
    // canvas.drawPath(path, dottedPaint);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      dottedPaint,
    );
    textPaint
      ..text = TextSpan(text: price25, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftMarginSpace - SubChartPainter.getStringWidth("$price25 ", textPaint), Y25));
    textPaint
      ..text = TextSpan(text: price70, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftMarginSpace - SubChartPainter.getStringWidth("$price70 ", textPaint), Y70));
    textPaint
      ..text = TextSpan(text: "0.00", style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftMarginSpace - SubChartPainter.getStringWidth("0.00 ", textPaint), viewHeight - textBottom));

    //绘制PSY
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = leftMarginSpace + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double nextX = leftMarginSpace + mCandleWidth * (number) + mCandleWidth;

      //从周期开始才绘制PSY
      if (i >= PSYPeriod - 1) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (PSYPeriod - 1) : i - (PSYPeriod - 1) + 1;
        if (nextNumber < PSYs.length) {
          double startY = viewHeight - textBottom - PSYs[i - (PSYPeriod - 1)] * rate;
          double stopY = viewHeight - textBottom - PSYs[nextNumber] * rate;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), redPaint);
        }
      }

      //PSYMA
      if (i >= PSYPeriod + PSYMAPeriod - 1) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (PSYPeriod + PSYMAPeriod - 1) : i - (PSYPeriod + PSYMAPeriod - 1) + 1;
        if (nextNumber < PSYMAs.length) {
          double startY = viewHeight - textBottom - PSYMAs[i - (PSYPeriod + PSYMAPeriod - 1)] * rate;
          double stopY = viewHeight - textBottom - PSYMAs[nextNumber] * rate;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), yellowPaint);
        }
      }

      //绘制当前周期，最新一根数据的PSY
      if (i == (mDataStartIndext + mShowDataNum - 1)) {
        String psy, psyMa;
        if ((mDataStartIndext + mShowDataNum) > PSYPeriod && (i - (PSYPeriod - 1)) < PSYs.length) {
          psy = Utils.getPointNum(PSYs[i - (PSYPeriod - 1)]);
        } else {
          psy = "0.000";
        }
        if ((mDataStartIndext + mShowDataNum) > PSYPeriod + PSYMAPeriod && (i - (PSYPeriod + PSYMAPeriod - 1)) < PSYMAs.length) {
          psyMa = Utils.getPointNum(PSYMAs[i - (PSYPeriod + PSYMAPeriod - 1)]);
        } else {
          psyMa = "0.000";
        }

        String text = "PSY($PSYPeriod , $PSYMAPeriod)";
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.BIAS2Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) + 15;

        text = "psy: $psy";
        // textPaint.setColor(Port.PSYColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.PSYColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) + 15;

        text = "payMa: $psyMa";
        // textPaint.setColor(Port.PSYMAColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.PSYMAColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
      }
    }
  }
}
