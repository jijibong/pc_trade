import 'package:flutter/cupertino.dart';

import '../../../util/painter/k_chart/base_k_chart_painter.dart';
import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * 瀑布线指标线绘制，数据计算
 *
 * @author hexuejian
 */
class FallLineEntity {
  /**
   * 瀑布线周期1数据集合
   */
  List<double> PBX1 = [];
  /**
   * 瀑布线周期2数据集合
   */
  List<double> PBX2 = [];
  /**
   * 瀑布线周期3数据集合
   */
  List<double> PBX3 = [];
  /**
   * 瀑布线周期4数据集合
   */
  List<double> PBX4 = [];
  /**
   * 瀑布线周期5数据集合
   */
  List<double> PBX5 = [];
  /**
   * 瀑布线周期6数据集合
   */
  List<double> PBX6 = [];
  /**
   * 默认字体大小
   **/
  static double DEFAULT_AXIS_TITLE_SIZE = 22;
  /**
   * 增加数据类
   */
  CalcIndexData mCalcData = CalcIndexData();

  FallLineEntity() {
    PBX1 = [];
    PBX2 = [];
    PBX3 = [];
    PBX4 = [];
    PBX5 = [];
    PBX6 = [];
  }

  /**
   * 初始化瀑布线数据
   *
   * @param OHLCData
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int period1, int period2, int period3, int period4, int period5, int period6, int pri_type) {
    PBX1.clear();
    PBX2.clear();
    PBX3.clear();
    PBX4.clear();
    PBX5.clear();
    PBX6.clear();

    if (OHLCData == null || OHLCData.length == 0) {
      return;
    }

    //计算周期1瀑布线
    List<double> exponentList1 = []; //M1日指数移动平均数集合
    List<double> simpleList1 = []; //M1*2日简单移动平均数集合
    List<double> fourList1 = []; //M1*4日简单移动平均数集合
    exponentList1 = calcExponent(OHLCData, period1, pri_type);
    simpleList1 = calcSimple2(OHLCData, period1, pri_type);
    fourList1 = calcSimple4(OHLCData, period1, pri_type);

    // PBX1=(收盘价的M1日指数移动平均+收盘价的M1*2日简单移动平均+收盘价的M1*4日简单移动平均)/3
    for (int i = 0; i < fourList1.length; i++) {
      PBX1.add((exponentList1[i + period1 * 3] + simpleList1[i + period1 * 2] + fourList1[i]) / 3);
    }

    //计算周期2瀑布线
    List<double> exponentList2 = []; //M1日指数移动平均数集合
    List<double> simpleList2 = []; //M1*2日简单移动平均数集合
    List<double> fourList2 = []; //M1*4日简单移动平均数集合
    exponentList2 = calcExponent(OHLCData, period2, pri_type);
    simpleList2 = calcSimple2(OHLCData, period2, pri_type);
    fourList2 = calcSimple4(OHLCData, period2, pri_type);

    // PBX1=(收盘价的M1日指数移动平均+收盘价的M1*2日简单移动平均+收盘价的M1*4日简单移动平均)/3
    for (int i = 0; i < fourList2.length; i++) {
      PBX2.add((exponentList2[i + period2 * 3] + simpleList2[i + period2 * 2] + fourList2[i]) / 3);
    }

    //计算周期3瀑布线
    List<double> exponentList3 = []; //M1日指数移动平均数集合
    List<double> simpleList3 = []; //M1*2日简单移动平均数集合
    List<double> fourList3 = []; //M1*4日简单移动平均数集合
    exponentList3 = calcExponent(OHLCData, period3, pri_type);
    simpleList3 = calcSimple2(OHLCData, period3, pri_type);
    fourList3 = calcSimple4(OHLCData, period3, pri_type);

    // PBX1=(收盘价的M1日指数移动平均+收盘价的M1*2日简单移动平均+收盘价的M1*4日简单移动平均)/3
    for (int i = 0; i < fourList3.length; i++) {
      PBX3.add((exponentList3[i + period3 * 3] + simpleList3[i + period3 * 2] + fourList3[i]) / 3);
    }

    //计算周期4瀑布线
    List<double> exponentList4 = []; //M1日指数移动平均数集合
    List<double> simpleList4 = []; //M1*2日简单移动平均数集合
    List<double> fourList4 = []; //M1*4日简单移动平均数集合
    exponentList4 = calcExponent(OHLCData, period4, pri_type);
    simpleList4 = calcSimple2(OHLCData, period4, pri_type);
    fourList4 = calcSimple4(OHLCData, period4, pri_type);

    // PBX1=(收盘价的M1日指数移动平均+收盘价的M1*2日简单移动平均+收盘价的M1*4日简单移动平均)/3
    for (int i = 0; i < fourList4.length; i++) {
      PBX4.add((exponentList4[i + period4 * 3] + simpleList4[i + period4 * 2] + fourList4[i]) / 3);
    }

    //计算周期5瀑布线
    List<double> exponentList5 = []; //M1日指数移动平均数集合
    List<double> simpleList5 = []; //M1*2日简单移动平均数集合
    List<double> fourList5 = []; //M1*4日简单移动平均数集合
    exponentList5 = calcExponent(OHLCData, period5, pri_type);
    simpleList5 = calcSimple2(OHLCData, period5, pri_type);
    fourList5 = calcSimple4(OHLCData, period5, pri_type);

    // PBX1=(收盘价的M1日指数移动平均+收盘价的M1*2日简单移动平均+收盘价的M1*4日简单移动平均)/3
    for (int i = 0; i < fourList5.length; i++) {
      PBX5.add((exponentList5[i + period5 * 3] + simpleList5[i + period5 * 2] + fourList5[i]) / 3);
    }

    //计算周期5瀑布线
    List<double> exponentList6 = []; //M1日指数移动平均数集合
    List<double> simpleList6 = []; //M1*2日简单移动平均数集合
    List<double> fourList6 = []; //M1*4日简单移动平均数集合
    exponentList6 = calcExponent(OHLCData, period6, pri_type);
    simpleList6 = calcSimple2(OHLCData, period6, pri_type);
    fourList6 = calcSimple4(OHLCData, period6, pri_type);

    // PBX1=(收盘价的M1日指数移动平均+收盘价的M1*2日简单移动平均+收盘价的M1*4日简单移动平均)/3
    for (int i = 0; i < fourList6.length; i++) {
      PBX6.add((exponentList6[i + period6 * 3] + simpleList6[i + period6 * 2] + fourList6[i]) / 3);
    }
  }

  /**
   * 计算周期内的指数移动平均数
   * @param OHLCData
   * @param period
   * @param pri_type
   * @return
   */
  List<double> calcExponent(List<OHLCEntity> OHLCData, int period, int pri_type) {
    List<double> datalist = [];
    for (int i = period - 1; i < OHLCData.length; i++) {
      // 计算指数移动平均数
      if (i == period - 1) {
        datalist.add(getPrice(OHLCData, i, pri_type));
      } else {
        datalist.add((getPrice(OHLCData, i, pri_type) - datalist[i - period]) / period + datalist[i - period]);
      }
    }
    return datalist;
  }

  /**
   * 计算周期x2日内的简单移动平均数
   * @param OHLCData
   * @param period
   * @param pri_type
   * @return
   */
  List<double> calcSimple2(List<OHLCEntity> OHLCData, int period, int pri_type) {
    List<double> datalist = [];
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= period * 2 - 1) {
        double a = 0.0;
        for (int j = 0; j < period * 2; j++) {
          a += getPrice(OHLCData, (j + i - (period * 2 - 1)), pri_type);
        }
        datalist.add(a / (period * 2));
      }
    }
    return datalist;
  }

  /**
   * 计算周期x4日内的简单移动平均数
   * @param OHLCData
   * @param period
   * @param pri_type
   * @return
   */
  List<double> calcSimple4(List<OHLCEntity> OHLCData, int period, int pri_type) {
    List<double> datalist = [];
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= period * 4 - 1) {
        double a = 0.0;
        for (int j = 0; j < period * 4; j++) {
          a += getPrice(OHLCData, (j + i - (period * 4 - 1)), pri_type);
        }
        datalist.add(a / (period * 4));
      }
    }
    return datalist;
  }

  /**
   * 获得瀑布线价格
   */
  double getPrice(List<OHLCEntity> OHLCData, int i, int pri_type) {
    double price = 0.0;
    switch (pri_type) {
      case 0: //开
        price = (OHLCData[i].open ?? 0).toDouble();
        break;

      case 1: //高
        price = (OHLCData[i].high ?? 0).toDouble();
        break;

      case 2: //收
        price = (OHLCData[i].close ?? 0).toDouble();
        break;

      case 3: //低
        price = (OHLCData[i].low ?? 0).toDouble();
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
   * 增加瀑布线数据
   *
   * @param OHLCData
   * @param period1
   * @param period2
   * @param period3
   * @param period4
   * @param period5
   * @param period6
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int period1, int period2, int period3, int period4, int period5, int period6, int pri_type, int count) {
    if (PBX1.isEmpty || PBX2.isEmpty || PBX3.isEmpty || PBX4.isEmpty || PBX5.isEmpty || PBX6.isEmpty) {
      return;
    }
    PBX1.remove(PBX1.length - 1);
    PBX2.remove(PBX2.length - 1);
    PBX3.remove(PBX3.length - 1);
    PBX4.remove(PBX4.length - 1);
    PBX5.remove(PBX5.length - 1);
    PBX6.remove(PBX6.length - 1);

    //计算PBX1
    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcFall(OHLCData, period1, pri_type, OHLCData.length - i);
      PBX1.add(value);
    }
    //计算PBX2
    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcFall(OHLCData, period2, pri_type, OHLCData.length - i);
      PBX2.add(value);
    }
    //计算PBX3
    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcFall(OHLCData, period3, pri_type, OHLCData.length - i);
      PBX3.add(value);
    }
    //计算PBX4
    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcFall(OHLCData, period4, pri_type, OHLCData.length - i);
      PBX4.add(value);
    }
    //计算PBX5
    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcFall(OHLCData, period5, pri_type, OHLCData.length - i);
      PBX5.add(value);
    }
    //计算PBX6
    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcFall(OHLCData, period6, pri_type, OHLCData.length - i);
      PBX6.add(value);
    }
  }

  /**
   * 绘制瀑布线
   */
  void drawFall(
      Canvas canvas,
      int mDataStartIndext,
      int mShowDataNum,
      double mCandleWidth,
      double mMaxPrice,
      double mMinPrice,
      int CANDLE_INTERVAL,
      double MARGINLEFT,
      double MARGINTOP,
      double uperChartHeight,
      int FallPeriod1,
      int FallPeriod2,
      int FallPeriod3,
      int FallPeriod4,
      int FallPeriod5,
      int FallPeriod6) {
    double rate = 0.0; //每单位像素价格
    Paint onePaint = MethodUntil().getDrawPaint(Port.fall1Color);
    Paint twoPaint = MethodUntil().getDrawPaint(Port.fall2Color);
    Paint threePaint = MethodUntil().getDrawPaint(Port.fall3Color);
    Paint fourPaint = MethodUntil().getDrawPaint(Port.fall4Color);
    Paint fivePaint = MethodUntil().getDrawPaint(Port.fall5Color);
    Paint sixPaint = MethodUntil().getDrawPaint(Port.fall6Color);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.foreGroundColor);
    onePaint.strokeWidth = Port.fallWidth[0];
    twoPaint.strokeWidth = Port.fallWidth[1];
    threePaint.strokeWidth = Port.fallWidth[2];
    fourPaint.strokeWidth = Port.fallWidth[3];
    fivePaint.strokeWidth = Port.fallWidth[4];
    sixPaint.strokeWidth = Port.fallWidth[5];
    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
    // textPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);

    rate = (uperChartHeight - DEFAULT_AXIS_TITLE_SIZE - 10) / (mMaxPrice - mMinPrice); //计算最小单位
    double textBottom = MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = MARGINLEFT;

    //绘制瀑布线
//		Log.i("", "PBX2集合大小："+PBX2.length);
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double nextX = MARGINLEFT + mCandleWidth * (number) + mCandleWidth;

      //从周期1开始才绘制瀑布线1
      if (i >= (FallPeriod1 * 4 - 1)) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (FallPeriod1 * 4 - 1) : i - (FallPeriod1 * 4 - 1) + 1;
        if (nextNumber < PBX1.length) {
          //绘制UP线
          double startY = (mMaxPrice - PBX1[i - (FallPeriod1 * 4 - 1)]) * rate + textBottom;
          double stopY = (mMaxPrice - PBX1[nextNumber]) * rate + textBottom;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), onePaint);
        }
      }

      //从周期2开始才绘制瀑布线2
      if (i >= (FallPeriod2 * 4 - 1)) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (FallPeriod2 * 4 - 1) : i - (FallPeriod2 * 4 - 1) + 1;
        if (nextNumber < PBX2.length) {
          //绘制UP线
          double startY = (mMaxPrice - PBX2[i - (FallPeriod2 * 4 - 1)]) * rate + textBottom;
          double stopY = (mMaxPrice - PBX2[nextNumber]) * rate + textBottom;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), twoPaint);
        }
      }

      //从周期3开始才绘制瀑布线3
      if (i >= (FallPeriod3 * 4 - 1)) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (FallPeriod3 * 4 - 1) : i - (FallPeriod3 * 4 - 1) + 1;
        if (nextNumber < PBX3.length) {
          //绘制UP线
          double startY = (mMaxPrice - PBX3[i - (FallPeriod3 * 4 - 1)]) * rate + textBottom;
          double stopY = (mMaxPrice - PBX3[nextNumber]) * rate + textBottom;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), threePaint);
        }
      }

      //从周期4开始才绘制瀑布线4
      if (i >= (FallPeriod4 * 4 - 1)) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (FallPeriod4 * 4 - 1) : i - (FallPeriod4 * 4 - 1) + 1;
        if (nextNumber < PBX4.length) {
          //绘制UP线
          double startY = ((mMaxPrice - PBX4[i - (FallPeriod4 * 4 - 1)]) * rate + textBottom);
          double stopY = ((mMaxPrice - PBX4[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), fourPaint);
        }
      }

      //从周期5开始才绘制瀑布线5
      if (i >= (FallPeriod5 * 4 - 1)) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (FallPeriod5 * 4 - 1) : i - (FallPeriod5 * 4 - 1) + 1;
        if (nextNumber < PBX5.length) {
          //绘制UP线
          double startY = ((mMaxPrice - PBX5[i - (FallPeriod5 * 4 - 1)]) * rate + textBottom);
          double stopY = ((mMaxPrice - PBX5[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), fivePaint);
        }
      }

      //从周期6开始才绘制瀑布线6
      if (i >= (FallPeriod6 * 4 - 1)) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (FallPeriod6 * 4 - 1) : i - (FallPeriod6 * 4 - 1) + 1;
        if (nextNumber < PBX6.length) {
          //绘制UP线
          double startY = ((mMaxPrice - PBX6[i - (FallPeriod6 * 4 - 1)]) * rate + textBottom);
          double stopY = ((mMaxPrice - PBX6[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), sixPaint);
        }
      }
//		Log.i("", "位置："+(i - (FallPeriod1*4-1)) +" "+"pb1数据："+PBX1[i - (FallPeriod1*4-1)));
//		Log.i("", "位置："+(i - (FallPeriod2*4-1)) +" "+"pb2数据："+PBX2[i - (FallPeriod2*4-1)));
//		Log.i("", "位置："+(i - (FallPeriod3*4-1)) +" "+"pb3数据："+PBX3[i - (FallPeriod3*4-1)));
//		Log.i("", "位置："+(i - (FallPeriod4*4-1)) +" "+"pb4数据："+PBX4[i - (FallPeriod4*4-1)));
//		Log.i("", "位置："+(i - (FallPeriod5*4-1)) +" "+"pb5数据："+PBX5[i - (FallPeriod5*4-1)));
//		Log.i("", "位置："+(i - (FallPeriod6*4-1)) +" "+"pb6数据："+PBX6[i - (FallPeriod6*4-1)));

      //绘制当前周期，最新一根数据的up,down,middle
      if (i == (mDataStartIndext + mShowDataNum - 1)) {
        String pbx1, pbx2, pbx3, pbx4, pbx5, pbx6;
        //瀑布线1数据
        if ((mDataStartIndext + mShowDataNum) > FallPeriod1 * 4 && (i - (FallPeriod1 * 4 - 1)) < PBX1.length) {
          pbx1 = Utils.getPointNum(PBX1[i - (FallPeriod1 * 4 - 1)]);
        } else {
          pbx1 = "0.000";
        }

        //瀑布线2数据
        if ((mDataStartIndext + mShowDataNum) > FallPeriod2 * 4 && (i - (FallPeriod2 * 4 - 1)) < PBX2.length) {
          pbx2 = Utils.getPointNum(PBX2[i - (FallPeriod2 * 4 - 1)]);
        } else {
          pbx2 = "0.000";
        }

        //瀑布线3数据
        if ((mDataStartIndext + mShowDataNum) > FallPeriod3 * 4 && (i - (FallPeriod3 * 4 - 1)) < PBX3.length) {
          pbx3 = Utils.getPointNum(PBX3[i - (FallPeriod3 * 4 - 1)]);
        } else {
          pbx3 = "0.000";
        }

        //瀑布线4数据
        if ((mDataStartIndext + mShowDataNum) > FallPeriod4 * 4 && (i - (FallPeriod4 * 4 - 1)) < PBX4.length) {
          pbx4 = Utils.getPointNum(PBX4[i - (FallPeriod4 * 4 - 1)]);
        } else {
          pbx4 = "0.000";
        }

        //瀑布线5数据
        if ((mDataStartIndext + mShowDataNum) > FallPeriod5 * 4 && (i - (FallPeriod5 * 4 - 1)) < PBX5.length) {
          pbx5 = Utils.getPointNum(PBX5[i - (FallPeriod5 * 4 - 1)]);
        } else {
          pbx5 = "0.000";
        }

        //瀑布线6数据
        if ((mDataStartIndext + mShowDataNum) > FallPeriod6 * 4 && (i - (FallPeriod6 * 4 - 1)) < PBX6.length) {
          pbx6 = Utils.getPointNum(PBX6[i - (FallPeriod6 * 4 - 1)]);
        } else {
          pbx6 = "0.000";
        }
        String text = "PB$FallPeriod1:$pbx1";
        // textPaint.setColor(Port.fall1Color);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.fall1Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "PB$FallPeriod2:$pbx2";
        // textPaint.setColor(Port.fall2Color);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.fall2Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "PB$FallPeriod3:$pbx3";
        // text = "PB" + FallPeriod3 + ":" + pbx3;
        // textPaint.setColor(Port.fall3Color);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.fall3Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "PB$FallPeriod4:$pbx4";
        // text = "PB" + FallPeriod4 + ":" + pbx4;
        // textPaint.setColor(Port.fall4Color);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.fall4Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "PB$FallPeriod5:$pbx5";
        // text = "PB" + FallPeriod5 + ":" + pbx5;
        // textPaint.setColor(Port.fall5Color);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.fall5Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "PB$FallPeriod6:$pbx6";
        // text = "PB" + FallPeriod6 + ":" + pbx6;
        // textPaint.setColor(Port.fall6Color);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.fall6Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;
      }
    }
  }
}
