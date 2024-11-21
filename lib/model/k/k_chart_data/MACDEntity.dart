import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:trade/util/painter/k_chart/sub_chart_painter.dart';

import '../../../util/log/log.dart';
import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

class MACDEntity {
  /**
   * DEA数据集合
   */
  List<double> DEAs = [];
  /**
   * DIFs数据集合
   */
  List<double> DIFs = [];
  /**
   * MACDs数据集合
   */
  List<double> MACDs = [];
  /**
   * MACD最高价
   */
  double maxPrice = 0.0;
  /**
   * MACD最低价
   */
  double minPrice = 0.0;
  /**
   * 默认虚线效果
   */
  List<double> DEFAULT_DASH_EFFECT = [2, 1];
  /**
   * 默认XY轴字体大小
   **/
  double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  /**
   * 增加数据类
   */
  CalcIndexData mCalcData = CalcIndexData();

  /**
   * 初始化数据
   *
   * @param OHLCData
   * @param Speriod
   * @param Lperiod
   * @param period
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int Speriod, int Lperiod, int period, int pri_type) {
    if (OHLCData.isEmpty || Lperiod - 1 >= OHLCData.length) {
      return;
    }

    DEAs.clear();
    DIFs.clear();
    MACDs.clear();
    List<OHLCEntity> OHLCList = <OHLCEntity>[];
    OHLCList.clear();
    OHLCList.addAll(OHLCData);

    List<double> EMAshort = [];
    List<double> EMAlong = [];

    double eMA12 = 0.0;
    double eMA26 = 0.0;
    //计算第一日的EMA(short),EMA(long)
    switch (pri_type) {
      case 0: //开
        eMA12 = (OHLCList[Speriod - 1].open ?? 0).toDouble();
        eMA26 = (OHLCList[Lperiod - 1].open ?? 0).toDouble();
        break;

      case 1: //高
        eMA12 = (OHLCList[Speriod - 1].high ?? 0).toDouble();
        eMA26 = (OHLCList[Lperiod - 1].high ?? 0).toDouble();
        break;

      case 2: //收
        eMA12 = (OHLCList[Speriod - 1].close ?? 0).toDouble();
        eMA26 = (OHLCList[Lperiod - 1].close ?? 0).toDouble();
        break;

      case 3: //低
        eMA12 = (OHLCList[Speriod - 1].low ?? 0 ?? 0).toDouble();
        eMA26 = (OHLCList[Lperiod - 1].low ?? 0 ?? 0).toDouble();
        break;

      case 4: //高低价一半
        eMA12 = ((OHLCList[Speriod - 1].low ?? 0 ?? 0) + (OHLCList[Speriod - 1].high ?? 0)) / 2;
        eMA26 = ((OHLCList[Lperiod - 1].low ?? 0 ?? 0) + (OHLCList[Lperiod - 1].high ?? 0)) / 2;
        break;

      default:
        break;
    }

    //计算Diff
    for (int i = Speriod - 1; i < OHLCList.length; i++) {
      double curPrice = 0.0; //当日的开，高，收，低价格
      switch (pri_type) {
        case 0: //开
          curPrice = (OHLCList[i].open ?? 0).toDouble();
          break;
        case 1: //高
          curPrice = (OHLCList[i].high ?? 0).toDouble();
          break;
        case 2: //收
          curPrice = (OHLCList[i].close ?? 0).toDouble();
          break;
        case 3: //低
          curPrice = (OHLCList[i].low ?? 0).toDouble();
          break;
        case 4: //高低价一半
          curPrice = ((OHLCList[i].low ?? 0) + (OHLCList[i].high ?? 0)) / 2;
          break;

        default:
          break;
      }

      //EMA(short)
      if (i == Speriod - 1) {
        eMA12 = eMA12;
      } else {
        eMA12 = eMA12 * (Speriod - 1) / (Speriod + 1) + curPrice * 2 / (Speriod + 1);
      }
      EMAshort.add(eMA12);
    }

    for (int i = Lperiod - 1; i < OHLCList.length; i++) {
      double curPrice = 0.0; //当日的开，高，收，低价格
      switch (pri_type) {
        case 0: //开
          curPrice = (OHLCList[i].open ?? 0).toDouble();
          break;
        case 1: //高
          curPrice = (OHLCList[i].high ?? 0).toDouble();
          break;
        case 2: //收
          curPrice = (OHLCList[i].close ?? 0).toDouble();
          break;
        case 3: //低
          curPrice = (OHLCList[i].low ?? 0).toDouble();
          break;
        case 4: //高低价一半
          curPrice = ((OHLCList[i].low ?? 0) + (OHLCList[i].high ?? 0)) / 2;
          break;

        default:
          break;
      }

      //EMA(long)
      if (i == Speriod - 1) {
        eMA26 = eMA26;
      } else {
        eMA26 = eMA26 * (Lperiod - 1) / (Lperiod + 1) + curPrice * 2 / (Lperiod + 1);
      }
      EMAlong.add(eMA26);
    }

    for (int i = 0; i < EMAlong.length; i++) {
      DIFs.add(EMAshort[i + (Lperiod - Speriod)] - EMAlong[i]);
    }

    //计算DEAs
    for (int i = period - 1; i < DIFs.length; i++) {
      double sum = 0;
      for (int j = i - (period - 1); j <= i; j++) {
        sum += DIFs[j];
      }
      DEAs.add(sum / period);
    }

    //计算MACDs
    for (int i = 0; i < DEAs.length; i++) {
      MACDs.add(DIFs[i + period - 1] - DEAs[i]);
    }
    // Log.i("", "本次计算出DIFF：" + DIFs.length);
    // Log.e("切换测试", "macd初始化计算：" + DIFs.length);
  }

  /**
   * 增加MACD数据
   *
   * @param OHLCData
   * @param Speriod
   * @param Lperiod
   * @param period
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int Speriod, int Lperiod, int period, int pri_type, int count) {
    if (DIFs.isEmpty || DEAs.isEmpty || MACDs.isEmpty) {
      return;
    }

    if (mCalcData.calcMACD(OHLCData, Speriod, Lperiod, period, pri_type, OHLCData.length - 1) == null) return;

    DIFs.remove(DIFs.length - 1);
    DEAs.remove(DEAs.length - 1);
    MACDs.remove(MACDs.length - 1);

    for (int i = count; i > 0; i--) {
      Map<String, double> value = mCalcData.calcMACD(OHLCData, Speriod, Lperiod, period, pri_type, OHLCData.length - i);
      double diff = value["diff"] ?? 0;
      double dea = value["dea"] ?? 0;
      double macd = value["macd"] ?? 0;
      DIFs.add(diff);
      DEAs.add(dea);
      MACDs.add(macd);
    }
  }

  /**
   * 计算MACD的最高最低价
   */
  void calclatePrice(int mDataStartIndext, int showNumber, int Speriod, int Lperiod, int period) {
    if (DIFs.isEmpty || DEAs.isEmpty || MACDs.isEmpty) {
      return;
    }
    //当前绘制到的K线根数大于MACD长周期时，从第Lperiod根K线的时候才有diff数据
    int lotion = mDataStartIndext - (Lperiod - 1) < 0 ? 0 : mDataStartIndext - (Lperiod - 1);
    minPrice = DIFs[lotion];
    maxPrice = DIFs[lotion];

    for (int i = lotion; i < mDataStartIndext + showNumber - (Lperiod - 1); i++) {
      if (i < DIFs.length) {
        minPrice = minPrice < DIFs[i] ? minPrice : DIFs[i];
        maxPrice = maxPrice > DIFs[i] ? maxPrice : DIFs[i];
      }
    }

    lotion = mDataStartIndext - (Lperiod + period - 1) < 0 ? 0 : mDataStartIndext - (Lperiod + period - 1);
    for (int i = lotion; i < mDataStartIndext + showNumber - (Lperiod + period - 1); i++) {
      if (i < DEAs.length && i < MACDs.length) {
        minPrice = minPrice < DEAs[i] ? minPrice : DEAs[i];
        minPrice = minPrice < MACDs[i] ? minPrice : MACDs[i];
        maxPrice = maxPrice > DEAs[i] ? maxPrice : DEAs[i];
        maxPrice = maxPrice > MACDs[i] ? maxPrice : MACDs[i];
      }
    }
  }

  /**
   * 绘制macd
   *
   * @param canvas
   */
  void drawMACD(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL,
      double leftMarginSpace, double halfTextHeight, int macdLPeriod, int macdSPeriod, int macdPeriod) {
    if (DIFs.isEmpty || DEAs.isEmpty || MACDs.isEmpty) {
      return;
    }
    double lowerHight = viewHeight - Port.defult_margin_top - halfTextHeight * 2;
    double textsize = DEFAULT_AXIS_TITLE_SIZE;
    Paint blackPaint = getDrawPaint(const Color.fromRGBO(0, 0, 0, 1));
    Paint redPaint = getDrawPaint(Port.macdUpColor);
    Paint greenPaint = getDrawPaint(Port.macdDownColor);
    Paint deaPaint = getDrawPaint(Port.macdSlowColor);
    Paint diffPaint = getDrawPaint(Port.macdFastColor);
    TextPainter textPaint = TextPainter(); // getDrawPaint(Port.chartTxtColor);
    Paint girdPaint = getDrawPaint(Port.girdColor);
    girdPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    redPaint.strokeWidth = Port.macdWidth[2].toDouble();
    blackPaint.strokeWidth = 1;
    greenPaint.strokeWidth = Port.macdWidth[3].toDouble();
    deaPaint.strokeWidth = Port.macdWidth[1].toDouble();
    diffPaint.strokeWidth = Port.macdWidth[0].toDouble();

    double rate = 0.0;
    //计算最高价，最低价
    rate = maxPrice < 0 ? lowerHight / (0 - minPrice) : lowerHight / (maxPrice - minPrice);

    //绘制网格线
    Path path = Path(); // 绘制虚线
    double maxheight = (maxPrice / 2 - minPrice) * rate;
    //当最高价为零时不绘制此线
    path.moveTo(leftMarginSpace, viewHeight - maxheight);
    path.lineTo(viewWidth, viewHeight - maxheight);
    String price = Utils.getLimitNum(maxPrice / 2, 2);

    double textWidth = SubChartPainter.getStringWidth("$price ", textPaint);
    textPaint
      ..text = TextSpan(text: price, style: TextStyle(color: Port.chartTxtColor, fontSize: textsize))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftMarginSpace - textWidth, viewHeight - maxheight - halfTextHeight));

    //零轴
    double zeroheight = (0 - minPrice) * rate;
    double Y = viewHeight - zeroheight;
    path.moveTo(leftMarginSpace, Y);
    path.lineTo(viewWidth, Y);
    String price0 = "0.00";
    double textWidth0 = SubChartPainter.getStringWidth("$price0 ", textPaint);
    textPaint
      ..text = TextSpan(text: price0, style: TextStyle(color: Port.chartTxtColor, fontSize: textsize))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftMarginSpace - textWidth0, Y - halfTextHeight));

    //min/2
    double minheight = (minPrice / 2 - minPrice) * rate;
    path.moveTo(leftMarginSpace, viewHeight - minheight);
    path.lineTo(viewWidth, viewHeight - minheight);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      girdPaint,
    );
    String lowPrice = Utils.getLimitNum(minPrice / 2, 2);
    double textWidth1 = SubChartPainter.getStringWidth("$lowPrice ", textPaint);
    textPaint
      ..text = TextSpan(text: lowPrice, style: TextStyle(color: Port.chartTxtColor, fontSize: textsize))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftMarginSpace - textWidth1, viewHeight - minheight - halfTextHeight));

    //零轴
    zeroheight = (0 - minPrice) * rate;
    double zero = viewHeight - zeroheight;

    //绘制MACD
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = mCandleWidth * (i - mDataStartIndext) + mCandleWidth + leftMarginSpace;
      double nextX = mCandleWidth * (number) + mCandleWidth + leftMarginSpace;
      // double left = startX - (mCandleWidth - CANDLE_INTERVAL) / 2;
      // double right = startX + (mCandleWidth - CANDLE_INTERVAL) / 2;

      // 绘制矩形
      if (i >= (macdLPeriod + macdPeriod - 1)) {
        //当前所绘K线根数大于MACD长周期与周期之和才开始绘制柱状图
        int loction = i - (macdLPeriod + macdPeriod - 1);

        if (loction < MACDs.length) {
          if (MACDs[loction] >= 0.0) {
            //绘制横线
            // canvas.drawLine(Offset(left, zero), Offset(right, zero), blackPaint);
            //绘制竖线
            double top = zero - MACDs[loction] * rate;
            canvas.drawLine(Offset(startX, zero), Offset(startX, top), redPaint);
          } else {
            //绘制横线
            // canvas.drawLine(Offset(left, zero), Offset(right, zero), blackPaint);
            //绘制竖线
            double top = zero - MACDs[loction] * rate;
            canvas.drawLine(Offset(startX, zero), Offset(startX, top), greenPaint);
          }
        }
      }

      //绘制DIFF
      if (i >= macdLPeriod - 1) {
        int diffNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (macdLPeriod - 1) : i - (macdLPeriod - 1) + 1;
        if (diffNumber < DIFs.length) {
          double startY = zero - DIFs[i - (macdLPeriod - 1)] * rate;
          double stopY = zero - DIFs[diffNumber] * rate;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), diffPaint);
        }
      }

      //绘制DEA
      if (i >= macdLPeriod + macdPeriod - 1) {
        int deaNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (macdLPeriod + macdPeriod - 1) : i - (macdLPeriod + macdPeriod - 1) + 1;
        if (deaNumber < DEAs.length) {
          double startY = zero - DEAs[i - (macdLPeriod + macdPeriod - 1)] * rate;
          double stopY = zero - DEAs[deaNumber] * rate;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), deaPaint);
        }
      }

      //绘制当前周期，最新一根数据的diff,dea,macd
      if (i == mDataStartIndext + mShowDataNum - 1) {
        String diff, dea, macd = "";
        // logger.i("mDataStartIndext:$mDataStartIndext  mShowDataNum:$mShowDataNum  macdLPeriod:$macdLPeriod  i:$i  DIFs:${DIFs.length}");

        if ((mDataStartIndext + mShowDataNum) > macdLPeriod && (i - (macdLPeriod - 1)) < DIFs.length) {
          diff = Utils.getPointNum(DIFs[i - (macdLPeriod - 1)]);
        } else {
          diff = "0.000";
        }

        if ((mDataStartIndext + mShowDataNum) > (macdLPeriod + macdPeriod) &&
            (i - (macdLPeriod + macdPeriod - 1)) < DEAs.length &&
            (i - (macdLPeriod + macdPeriod - 1)) < MACDs.length) {
          dea = Utils.getPointNum(DEAs[i - (macdLPeriod + macdPeriod - 1)]);
          macd = Utils.getPointNum(MACDs[i - (macdLPeriod + macdPeriod - 1)]);
        } else {
          dea = "0.000";
          macd = "0.000";
        }

        double textXStart = Port.defult_icon_width + leftMarginSpace;
        String text = "MACD($macdSPeriod , $macdLPeriod , $macdPeriod)";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: const Color.fromRGBO(230, 56, 89, 1), fontSize: textsize))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) + 15;

        text = "DEA:$dea , $diff , $macd";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.macdSlowColor, fontSize: textsize))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) + 15;

        text = "DIFF:$diff";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.macdFastColor, fontSize: textsize))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, Port.text_check));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint, size: DEFAULT_AXIS_TITLE_SIZE) + 15;

        // 绘制矩形
        if (i >= (macdLPeriod + macdPeriod - 1) && (i - (macdLPeriod + macdPeriod - 1)) < MACDs.length) {
          text = "STICK:$macd";
          if (MACDs[i - (macdLPeriod + macdPeriod - 1)] >= 0) {
            textPaint
              ..text = TextSpan(text: text, style: TextStyle(color: Port.macdUpColor, fontSize: textsize))
              ..textDirection = TextDirection.ltr
              ..layout()
              ..paint(canvas, Offset(textXStart, Port.text_check));
          } else {
            textPaint
              ..text = TextSpan(text: text, style: TextStyle(color: Port.macdDownColor, fontSize: textsize))
              ..textDirection = TextDirection.ltr
              ..layout()
              ..paint(canvas, Offset(textXStart, Port.text_check));
          }
        }
      }
    }
  }

  /**
   * 绘图画笔
   */
  Paint getDrawPaint(Color color) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..strokeWidth = Port.StrokeWidth;
    return paint;
  }
}
