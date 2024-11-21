import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/painter/k_chart/sub_chart_painter.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * BIAS指标线绘制，数据计算
 * @author hexuejian
 *
 */
class BIASEntity {
  /**BIAS数据集合*/
  List<double> BIASs1 = [];
  List<double> BIASs2 = [];
  List<double> BIASs3 = [];
  /**BIAS最高价*/
  double maxPrice = 0.0;
  /**BIAS最低价*/
  double minPrice = 0.0;
  /** 默认字体大小 **/
  static double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  /** 默认虚线效果 */
  List<double> DEFAULT_DASH_EFFECT = [2, 1];
  // static final PathEffect DEFAULT_DASH_EFFECT = new DashPathEffect(new double[] { 2, 3, 2,
  // 3 }, 1);
  /**增加数据类*/
  CalcIndexData mCalcData = CalcIndexData();

  BIASEntity() {
    BIASs1 = [];
    BIASs2 = [];
    BIASs3 = [];
  }

  /**
   * 初始化BIAS数据
   * @param OHLCData
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int period1, int period2, int period3, int pri_type) {
    BIASs1.clear();
    BIASs2.clear();
    BIASs3.clear();

    if (OHLCData == null || OHLCData.isEmpty) {
      return;
    }

    for (int i = period1 - 1; i < OHLCData.length; i++) {
      double bias = 0.0;
      bias = mCalcData.calcBIAS(OHLCData, period1, pri_type, i);
      BIASs1.add(bias);
    }

    for (int i = period2 - 1; i < OHLCData.length; i++) {
      double bias = 0.0;
      bias = mCalcData.calcBIAS(OHLCData, period2, pri_type, i);
      BIASs2.add(bias);
    }

    for (int i = period3 - 1; i < OHLCData.length; i++) {
      double bias = 0.0;
      bias = mCalcData.calcBIAS(OHLCData, period3, pri_type, i);
      BIASs3.add(bias);
    }
  }

  /**
   * 获得BIAS价格
   */
  //  double getPrice(List<OHLCEntity> OHLCData , int j , int i , int period , int pri_type){
  // double price= 0.0;
  // switch (pri_type) {
  //
  // case 0://开
  // price = OHLCData.get(j + i - (period - 1)).getOpen()- OHLCData.get(j + i - (period - 1) - 1).getOpen();
  // break;
  //
  // case 1://高
  // price = OHLCData.get(j + i - (period - 1)).getHigh()- OHLCData.get(j + i - (period - 1) - 1).getHigh();
  // break;
  //
  // case 2://收
  // price = OHLCData.get(j + i - (period - 1)).getClose()- OHLCData.get(j + i - (period - 1) - 1).getClose();
  // break;
  //
  // case 3://低
  // price = OHLCData.get(j + i - (period - 1)).getLow()- OHLCData.get(j + i - (period - 1) - 1).getLow();
  // break;
  //
  // case 4://高低一半
  // price = (OHLCData.get(j + i - (period - 1)).getHigh()+OHLCData.get(j + i - (period - 1)).getLow()) / 2
  // - (OHLCData.get(j + i - (period - 1) -1).getHigh()+OHLCData.get(j + i - (period - 1) -1).getLow()) / 2;
  // break;
  //
  // default:
  // break;
  // }
  // return price;
  // }

  /**
   * 增加KDJ数据
   * @param OHLCData
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int period1, int period2, int period3, int pri_type, int count) {
    if (BIASs1.isEmpty || BIASs2.isEmpty || BIASs3.isEmpty) {
      return;
    }

    if (mCalcData.calcBIAS(OHLCData, period1, pri_type, OHLCData.length - 1) == double.maxFinite) return;
    if (mCalcData.calcBIAS(OHLCData, period2, pri_type, OHLCData.length - 1) == double.maxFinite) return;
    if (mCalcData.calcBIAS(OHLCData, period3, pri_type, OHLCData.length - 1) == double.maxFinite) return;

    BIASs1.remove(BIASs1.length - 1);
    BIASs2.remove(BIASs2.length - 1);
    BIASs3.remove(BIASs3.length - 1);

    for (int i = count; i > 0; i--) {
      double bias1 = 0.0;
      double bias2 = 0.0;
      double bias3 = 0.0;
      bias1 = mCalcData.calcBIAS(OHLCData, period1, pri_type, OHLCData.length - i);
      bias2 = mCalcData.calcBIAS(OHLCData, period2, pri_type, OHLCData.length - i);
      bias3 = mCalcData.calcBIAS(OHLCData, period3, pri_type, OHLCData.length - i);
      BIASs1.add(bias1);
      BIASs2.add(bias2);
      BIASs3.add(bias3);
    }
  }

  /**
   * 计算BIAS的最高最低价
   */
  void calclatePrice(int mDataStartIndext, int showNumber, int period1, int period2, int period3) {
    if (BIASs1.length == 0 || BIASs2.length == 0 || BIASs3.length == 0) {
      return;
    }
    //当前绘制到的K线根数大于kdj周期时，从第period根K线的时候才有kdj数据
    int lotion = mDataStartIndext - (period1 - 1) < 0 ? 0 : mDataStartIndext - (period1 - 1);
    minPrice = BIASs1[lotion];
    maxPrice = BIASs1[lotion];

    for (int i = lotion; i < mDataStartIndext + showNumber - (period1 - 1); i++) {
      if (i < BIASs1.length) {
        minPrice = minPrice < BIASs1[i] ? minPrice : BIASs1[i];
        maxPrice = maxPrice > BIASs1[i] ? maxPrice : BIASs1[i];
      }
    }

    lotion = mDataStartIndext - (period2 - 1) < 0 ? 0 : mDataStartIndext - (period2 - 1);
    for (int i = lotion; i < mDataStartIndext + showNumber - (period2 - 1); i++) {
      if (i < BIASs2.length) {
        minPrice = minPrice < BIASs2[i] ? minPrice : BIASs2[i];
        maxPrice = maxPrice > BIASs2[i] ? maxPrice : BIASs2[i];
      }
    }

    lotion = mDataStartIndext - (period3 - 1) < 0 ? 0 : mDataStartIndext - (period3 - 1);
    for (int i = lotion; i < mDataStartIndext + showNumber - (period3 - 1); i++) {
      if (i < BIASs3.length) {
        minPrice = minPrice < BIASs3[i] ? minPrice : BIASs3[i];
        maxPrice = maxPrice > BIASs3[i] ? maxPrice : BIASs3[i];
      }
    }
  }

  /**
   * 绘制RSI,价格线
   */
  void drawBIAS(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL,
      double leftMarginSpace, double halfTextHeight, int BIAS1Period, int BIAS2Period, int BIAS3Period) {
    double textBottom = Port.defult_margin_top;
    double lowerHeight = viewHeight - textBottom - halfTextHeight * 2;
    double latitudeSpacing = lowerHeight / 4; //每格高度
    double rate = 0.0; //每单位像素价格
    Paint redPaint = MethodUntil().getDrawPaint(Port.BIAS1Color);
    Paint yellowPaint = MethodUntil().getDrawPaint(Port.BIAS2Color);
    Paint bluePaint = MethodUntil().getDrawPaint(Port.BIAS3Color);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.chartTxtColor);
    Paint dottedPaint = MethodUntil().getDrawPaint(Port.girdColor); //虚线画笔

    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    redPaint.strokeWidth = Port.BIASWidth[0];
    yellowPaint.strokeWidth = Port.BIASWidth[1];
    bluePaint.strokeWidth = Port.BIASWidth[2];

    rate = lowerHeight / (maxPrice - minPrice);
    double textXStart = Port.defult_icon_width + leftMarginSpace;

    //绘制虚线
    for (int i = 1; i <= 3; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(leftMarginSpace, viewHeight - latitudeSpacing * i - textBottom);
      path.lineTo(viewWidth - leftMarginSpace, viewHeight - latitudeSpacing * i - textBottom);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        dottedPaint,
      );
    }

    //绘制价格
    double perPrice = (maxPrice - minPrice) / (3 + 1); //计算每一格纬线框所占有的价格
    for (int i = 1; i <= 3; i++) {
      double textWidth = SubChartPainter.getStringWidth("${Utils.getPointNum(minPrice + perPrice * i)} ", textPaint);
      textPaint
        ..text = TextSpan(text: Utils.getPointNum(minPrice + perPrice * i), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(leftMarginSpace - textWidth, viewHeight - latitudeSpacing * i - textBottom - halfTextHeight));
    }

    //绘制BIAS
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = leftMarginSpace + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double nextX = leftMarginSpace + mCandleWidth * (number) + mCandleWidth;

      //从周期开始才绘制BIAS1
      if (i >= BIAS1Period - 1) {
        //K线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (BIAS1Period - 1) : i - (BIAS1Period - 1) + 1;
        if (nextNumber < BIASs1.length) {
          double startY = (maxPrice - BIASs1[i - (BIAS1Period - 1)]) * rate + textBottom;
          double stopY = (maxPrice - BIASs1[nextNumber]) * rate + textBottom;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), redPaint);
        }
      }

      //从周期开始才绘制BIAS2
      if (i >= BIAS2Period - 1) {
        //K线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (BIAS2Period - 1) : i - (BIAS2Period - 1) + 1;
        if (nextNumber < BIASs2.length) {
          double startY = (maxPrice - BIASs2[i - (BIAS2Period - 1)]) * rate + textBottom + halfTextHeight * 2;
          double stopY = (maxPrice - BIASs2[nextNumber]) * rate + textBottom + halfTextHeight * 2;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), yellowPaint);
        }
      }

      //从周期开始才绘制BIAS3
      if (i >= BIAS3Period - 1) {
        //K线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (BIAS3Period - 1) : i - (BIAS3Period - 1) + 1;
        if (nextNumber < BIASs3.length) {
          double startY = (maxPrice - BIASs3[i - (BIAS3Period - 1)]) * rate + textBottom + halfTextHeight * 2;
          double stopY = (maxPrice - BIASs3[nextNumber]) * rate + textBottom + halfTextHeight * 2;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), bluePaint);
        }
      }

      //绘制当前周期，最新一根数据的BIAS
      if (i == (mDataStartIndext + mShowDataNum - 1)) {
        String bias1, bias2, bias3;
        if ((mDataStartIndext + mShowDataNum) > BIAS1Period && (i - (BIAS1Period - 1)) < BIASs1.length) {
          bias1 = Utils.getPointNum(BIASs1[i - (BIAS1Period - 1)]);
        } else {
          bias1 = "0.000";
        }
        if ((mDataStartIndext + mShowDataNum) > BIAS2Period && (i - (BIAS2Period - 1)) < BIASs2.length) {
          bias2 = Utils.getPointNum(BIASs2[i - (BIAS2Period - 1)]);
        } else {
          bias2 = "0.000";
        }
        if ((mDataStartIndext + mShowDataNum) > BIAS3Period && (i - (BIAS3Period - 1)) < BIASs3.length) {
          bias3 = Utils.getPointNum(BIASs3[i - (BIAS3Period - 1)]);
        } else {
          bias3 = "0.000";
        }

        String text = "BIAS($BIAS1Period , $BIAS2Period , $BIAS3Period)";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "bias1: $bias1";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.BIAS1Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "bias2: $bias2";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.BIAS2Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "bias3: $bias3";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.BIAS3Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
      }
    }
  }
}
