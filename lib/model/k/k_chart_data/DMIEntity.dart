import 'package:path_drawing/path_drawing.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * RSI指标线绘制，数据计算
 * @author hexuejian
 *
 */
class DMIEntity {
  /**+DI数据集合*/
  List<double> upDIs = [];
  /**-DI数据集合*/
  List<double> downDIs = [];
  /**ADX数据集合*/
  List<double> ADXs = [];
  /** 默认字体大小 **/
  static double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  // /** 默认虚线效果 */
  //  static final PathEffect DEFAULT_DASH_EFFECT = new DashPathEffect(new double[] { 2, 3, 2, 3 }, 1);
  List<double> DEFAULT_DASH_EFFECT = [2, 1];
  /** 虚线颜色 */
  static const Color DEFAULT_DOTTED_COLOR = Colors.grey;
  /**增加数据类*/
  CalcIndexData mCalcData = new CalcIndexData();

  DMIEntity() {
    upDIs = [];
    downDIs = [];
    ADXs = [];
  }

  /**
   * 计算DMI数据
   */
  void initData(List<OHLCEntity>? OHLCData, int period) {
    upDIs.clear();
    downDIs.clear();
    ADXs.clear();
    if (OHLCData == null || OHLCData.length == 0) {
      return;
    }

    for (int i = period - 1; i < OHLCData.length; i++) {
      double? upDM = 0.0; //+DM
      double downDM = 0.0; //-DM
      double TR = 0.0; //表示c1,c2,c3的最大值(也就是tr)
      double d = 0.0; //表示c1,c2,c3的中间变量
      double sumTR = 0.0; //周期类tr的总和
      double sumUpDI = 0.0; //周期类+DI的和
      double sumDownDI = 0.0; //周期类-DI的和

      for (int j = 0; j < period; j++) {
        // 计算周期类的上升和下跌数

        if (j + i - (period - 1) == 0) {
          upDM = (OHLCData[j + i - (period - 1)].high ?? 0).toDouble();
        } else {
          //+dm
          if ((OHLCData[j + i - (period - 1)].high ?? 0) - (OHLCData[j + i - (period - 1) - 1].high ?? 0) > 0) {
            upDM = ((OHLCData[j + i - (period - 1)].high ?? 0) - (OHLCData[j + i - (period - 1) - 1].high ?? 0)).toDouble();
          } else {
            upDM = 0.0;
          }
          //-dm
          if ((OHLCData[j + i - (period - 1) - 1].low ?? 0) - (OHLCData[j + i - (period - 1)].low ?? 0) > 0) {
            downDM = ((OHLCData[j + i - (period - 1) - 1].low ?? 0) - (OHLCData[j + i - (period - 1)].low ?? 0)).toDouble();
          } else {
            downDM = 0.0;
          }

          //tr
          double c1 = ((OHLCData[j + i - (period - 1)].high ?? 0) - (OHLCData[j + i - (period - 1)].low ?? 0)).abs().toDouble();
          double c2 = ((OHLCData[j + i - (period - 1)].high ?? 0) - (OHLCData[j + i - (period - 1) - 1].close ?? 0)).abs().toDouble();
          double c3 = ((OHLCData[j + i - (period - 1)].low ?? 0) - (OHLCData[j + i - (period - 1) - 1].close ?? 0)).abs().toDouble();
          d = c1 > c2 ? c1 : c2;
          TR = d > c3 ? d : c3;

          sumTR += TR;
          sumUpDI += upDM;
          sumDownDI += downDM;
        }
      }

      //计算+DI和-DI
      double upDI = 0.0;
      double downDI = 0.0;
      double adx = 0.0;
      if (sumTR == 0) {
        //处理分母为零的情况
        upDI = 0.0;
        downDI = 0.0;
        adx = 0.0;
      } else {
        upDI = (sumUpDI / sumTR) * 100;
        downDI = (sumDownDI / sumTR) * 100;
        adx = ((upDI - downDI)).abs() / (upDI + downDI) * 100;
      }

      upDIs.add(upDI);
      downDIs.add(downDI);
      ADXs.add(adx);
    }
  }

  /**
   * 增加DMI数据
   * @param OHLCData
   * @param period
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int period, int count) {
    if (upDIs.isEmpty || downDIs.isEmpty || ADXs.isEmpty) {
      return;
    }

    if (mCalcData.calcDMI(OHLCData, period, OHLCData.length - 1) == null) return;

    upDIs.remove(upDIs.length - 1);
    downDIs.remove(downDIs.length - 1);
    ADXs.remove(ADXs.length - 1);

    for (int i = count; i > 0; i--) {
      Map<String, double> value = mCalcData.calcDMI(OHLCData, period, OHLCData.length - i);
      double upDi = value["up"] ?? 0;
      double downDi = value["down"] ?? 0;
      double adx = value["adx"] ?? 0;
      upDIs.add(upDi);
      downDIs.add(downDi);
      ADXs.add(adx);
    }
  }

  /**
   * 绘制DMI,价格线
   */
  void drawDmi(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL,
      double MARGINLEFT, double MARGINBOTTOM, double LOWER_CHART_TOP, double mRightArea, int dmiPeriod) {
    double lowerHight = viewHeight - LOWER_CHART_TOP - MARGINBOTTOM - DEFAULT_AXIS_TITLE_SIZE - 10; //下表高度
    double rate = 0.0; //每单位像素价格
    Paint redPaint = getDrawPaint(Port.dmiUPColor);
    Paint bluePaint = getDrawPaint(Port.dmiADXColor);
    Paint greenPaint = getDrawPaint(Port.dmiDownColor);
    TextPainter textPaint = TextPainter(); // getDrawPaint(Port.chartTxtColor);
    Paint dottedPaint = getDrawPaint(DEFAULT_DOTTED_COLOR); //虚线画笔
    // dottedPaint.setPathEffect(DEFAULT_DASH_EFFECT);
    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    redPaint.strokeWidth = Port.dmiWidth[1].toDouble();
    bluePaint.strokeWidth = Port.dmiWidth[0].toDouble();
    greenPaint.strokeWidth = Port.dmiWidth[2].toDouble();
    // textPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);

    rate = lowerHight / 100;

    //绘制价格25线
    Path path = Path();
    double Y25 = viewHeight - MARGINBOTTOM - lowerHight * 0.25;
    String price25 = "25.00";
    path.moveTo(MARGINLEFT, Y25);
    path.lineTo(viewWidth - MARGINLEFT - mRightArea, Y25);
    // canvas.drawPath(path, dottedPaint);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      dottedPaint,
    );

    //50线
    double Y50 = viewHeight - MARGINBOTTOM - lowerHight * 0.5;
    String price50 = "50.00";
    path.moveTo(MARGINLEFT, Y50);
    path.lineTo(viewWidth - MARGINLEFT - mRightArea, Y50);
    // canvas.drawPath(path, dottedPaint);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      dottedPaint,
    );
    //75线
    double Y75 = viewHeight - MARGINBOTTOM - lowerHight * 0.75;
    String price75 = "75.00";
    path.moveTo(MARGINLEFT, Y75);
    path.lineTo(viewWidth - MARGINLEFT - mRightArea, Y75);
    // canvas.drawPath(path, dottedPaint);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      dottedPaint,
    );
    // if (Port.drawFlag == 1) {
    //   canvas.drawText(price25, viewWidth - MARGINLEFT - mRightArea, Y25 + DEFAULT_AXIS_TITLE_SIZE / 2, textPaint);
    //   canvas.drawText(price50, viewWidth - MARGINLEFT - mRightArea, Y50 + DEFAULT_AXIS_TITLE_SIZE / 2, textPaint);
    //   canvas.drawText(price75, viewWidth - MARGINLEFT - mRightArea, Y75 + DEFAULT_AXIS_TITLE_SIZE / 2, textPaint);
    //   //0线价格
    //   canvas.drawText("0.00", viewWidth - MARGINLEFT - mRightArea, viewHeight - MARGINBOTTOM, textPaint);
    //   //100线价格
    //   canvas.drawText("100.00", viewWidth - MARGINLEFT - mRightArea, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE, textPaint);
    // } else {
    textPaint
      ..text = TextSpan(text: price25, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(MARGINLEFT, Y25));
    textPaint
      ..text = TextSpan(text: price50, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(MARGINLEFT, Y50));
    textPaint
      ..text = TextSpan(text: price75, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(MARGINLEFT, Y75));
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

      //从周期开始才绘制DMI
      if (i >= dmiPeriod - 1) {
        // Log.i("", "upDIs集合大小："+upDIs.length);
        // Log.i("", "K线数据位置："+i);
        // Log.i("", "upDIs数据位置："+(i - (dmiPeriod-1)));
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (dmiPeriod - 1) : i - (dmiPeriod - 1) + 1;
        if (nextNumber < upDIs.length && nextNumber < downDIs.length && nextNumber < ADXs.length) {
          //绘制+DI
          double upDI_startY = viewHeight - MARGINBOTTOM - upDIs[i - (dmiPeriod - 1)] * rate;
          double upDI_stopY = viewHeight - MARGINBOTTOM - upDIs[nextNumber] * rate;
          canvas.drawLine(Offset(startX, upDI_startY), Offset(nextX, upDI_stopY), redPaint);
          //绘制-DI
          double downDI_startY = viewHeight - MARGINBOTTOM - downDIs[i - (dmiPeriod - 1)] * rate;
          double downDI_stopY = viewHeight - MARGINBOTTOM - downDIs[nextNumber] * rate;
          canvas.drawLine(Offset(startX, downDI_startY), Offset(nextX, downDI_stopY), greenPaint);
          //绘制ADX
          double ADX_startY = viewHeight - MARGINBOTTOM - ADXs[i - (dmiPeriod - 1)] * rate;
          double ADX_stopY = viewHeight - MARGINBOTTOM - ADXs[nextNumber] * rate;
          canvas.drawLine(Offset(startX, ADX_startY), Offset(nextX, ADX_stopY), bluePaint);
        }
      }

      //绘制当前周期，最新一根数据的dmi
      if (i == (mDataStartIndext + mShowDataNum - 1)) {
        String upDI, downDI, adx;
        if ((mDataStartIndext + mShowDataNum) > dmiPeriod &&
            (i - (dmiPeriod - 1)) < upDIs.length &&
            (i - (dmiPeriod - 1)) < downDIs.length &&
            (i - (dmiPeriod - 1)) < ADXs.length) {
          upDI = Utils.getPointNum(upDIs[i - (dmiPeriod - 1)]);
          downDI = Utils.getPointNum(downDIs[i - (dmiPeriod - 1)]);
          adx = Utils.getPointNum(ADXs[i - (dmiPeriod - 1)]);
        } else {
          upDI = "0.000";
          downDI = "0.000";
          adx = "0.000";
        }

        double textXStart = MARGINLEFT;
        String text = "DMI($dmiPeriod)";
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "+DI:$upDI";
        // textPaint.setColor(Port.dmiUPColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.dmiUPColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "-DI:$downDI";
        // textPaint.setColor(Port.dmiDownColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.dmiDownColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "ADX:$adx";
        // textPaint.setColor(Port.dmiADXColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.dmiADXColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
      }
    }
  }

  /**
   * 绘图画笔
   */
  Paint getDrawPaint(Color color) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = Port.StrokeWidth
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    return paint;
  }
}
