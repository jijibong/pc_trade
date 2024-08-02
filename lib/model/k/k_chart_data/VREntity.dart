import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_drawing/path_drawing.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

class VREntity {
  /**
   * 数据集合
   */
  List<double> mVrlList = [];
  /**
   * 最高价
   */
  double maxPrice = 0;
  /**
   * 最低价
   */
  double minPrice = 0;
  /**
   * 默认虚线效果
   */
  List<double> DEFAULT_DASH_EFFECT = [2, 1];
  // static final PathEffect DEFAULT_DASH_EFFECT = new DashPathEffect(new double[]{2, 3, 2,
  // 3}, 1);
  /**
   * 默认XY轴字体大小
   **/
  static double DEFAULT_AXIS_TITLE_SIZE = 22;
  /**
   * 增加数据类
   */
  CalcIndexData mCalcData = CalcIndexData();

  VREntity() {
    //数据，短周期，长周期，周期，取值类型
    mVrlList = [];
  }

  /**
   * 初始化数据
   *
   * @param OHLCData
   */
  void initData(List<OHLCEntity> OHLCData, int period) {
    if (OHLCData == null || OHLCData.isEmpty) {
      return;
    }

//        2.计算过程
//        (1) N日以来股价上涨的那一日的成交量都称为UV，将N日内的UV总和相加称为UVS。
//        (2) N日以来股价下跌的那一日的成交量都称为DV，将N日内的DV总和相加称为DVS。
//        (3) N日以来股价平盘的那一日的成交量都称为PV，将N日内的PV总和相加称为PVS。
//        (4)最后N日的VR就可以计算出来:
//        VR (N)=((UVS+ 1/2PVS)/(DVS + 1/2PVS))*100
    mVrlList.clear();
    for (int i = period - 1; i < OHLCData.length; i++) {
      double uvs = 0.0;
      double dvs = 0.0;
      double pvs = 0.0;
      double vr = 0.0;

      for (int j = i - (period - 1); j <= i; j++) {
        //计算周期内的上升和下跌平均数
        if ((OHLCData[j].close ?? 0) > (OHLCData[j].open ?? 0)) {
          uvs += OHLCData[j].volume ?? 0;
        } else if ((OHLCData[j].close ?? 0) < (OHLCData[j].open ?? 0)) {
          dvs += OHLCData[j].volume ?? 0;
        } else if (OHLCData[j].close == OHLCData[j].open) {
          pvs += OHLCData[j].volume ?? 0;
        }
      }

      if (dvs + pvs / 2 == 0) {
        vr = 0;
      } else {
        vr = ((uvs + pvs / 2) / (dvs + pvs / 2)) * 100;
      }
      mVrlList.add(vr);
    }
  }

  /**
   * 增加VR数据
   * @param OHLCData
   * @param period
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int period, int count) {
    if (mVrlList.isEmpty) {
      return;
    }

    mVrlList.remove(mVrlList.length - 1);

    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcVR(OHLCData, period, OHLCData.length - i);
      mVrlList.add(value);
    }
  }

  /**
   * 计算成交量线图的最高最低价
   */
  void calclatePrice(int mDataStartIndext, int showNumber, int period) {
    if (mVrlList.isEmpty) {
      return;
    }

    int lotion = mDataStartIndext - (period - 1) < 0 ? 0 : mDataStartIndext - (period - 1);
    minPrice = mVrlList[lotion];
    maxPrice = mVrlList[lotion];

    for (int i = lotion; i < mDataStartIndext + showNumber - (period - 1); i++) {
      if (i < mVrlList.length) {
        minPrice = minPrice < mVrlList[i] ? minPrice : mVrlList[i];
        maxPrice = maxPrice > mVrlList[i] ? maxPrice : mVrlList[i];
      }
    }
  }

  /**
   * 绘制VR
   *
   * @param canvas
   */
  void drawVR(Canvas canvas, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL, double MARGINLEFT,
      double MARGINBOTTOM, double LOWER_CHART_TOP, double MID_CHART_TOP, double mRightArea, int period) {
    if (mVrlList.isEmpty) {
      return;
    }

    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
    double lowerHight = LOWER_CHART_TOP - MID_CHART_TOP - DEFAULT_AXIS_TITLE_SIZE - 10; //下表高度
    Paint linePaint = MethodUntil().getDrawPaint(Port.VR_Color);
    TextPainter textPaint = TextPainter();
    Paint girdPaint = MethodUntil().getDrawPaint(Port.girdColor);
    girdPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    girdPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double rate = 0.0;
    //计算最高价，最低价
    rate = lowerHight / (maxPrice - minPrice);

    //绘制网格线
    Path path = Path(); // 绘制虚线
    double perPrice = (maxPrice - minPrice) / 4;

    for (int i = 1; i <= 3; i++) {
      double perheight = perPrice * i * rate;
      path.moveTo(MARGINLEFT, LOWER_CHART_TOP - perheight);
      path.lineTo(viewWidth - MARGINLEFT - mRightArea, LOWER_CHART_TOP - perheight);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        girdPaint,
      );

      String price = Utils.getPointNum(perPrice * i + minPrice);
      // if (Port.drawFlag == 1) {
      //   canvas.drawText(price, viewWidth - MARGINLEFT - mRightArea, LOWER_CHART_TOP - perheight + DEFAULT_AXIS_TITLE_SIZE / 2, textPaint);
      // } else {
      //   canvas.drawText(price, MARGINLEFT, LOWER_CHART_TOP - perheight, textPaint);
      textPaint
        ..text = TextSpan(text: price, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(MARGINLEFT, LOWER_CHART_TOP - perheight));
      // }
    }

    //绘制VR图
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double nextX = MARGINLEFT + mCandleWidth * (number) + mCandleWidth;

      //从周期开始才绘制VR
      if (i >= period - 1) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (period - 1) : i - (period - 1) + 1;
        if (nextNumber < mVrlList.length) {
          double startY = LOWER_CHART_TOP - (mVrlList[i - (period - 1)] - minPrice) * rate;
          double stopY = LOWER_CHART_TOP - (mVrlList[nextNumber] - minPrice) * rate;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), linePaint);
        }
      }

      //绘制当前周期，最新一根数据的vr
      if (i == mDataStartIndext + mShowDataNum - 1) {
        String rsi;
        if ((mDataStartIndext + mShowDataNum) > period && (i - (period - 1)) < mVrlList.length) {
          rsi = Utils.getPointNum(mVrlList[i - (period - 1)]);
        } else {
          rsi = "0.000";
        }

        String text = "VR:($period): $rsi";
        // textPaint.setColor(Port.VR_Color);
        // canvas.drawText(text, MARGINLEFT, MID_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.VR_Color, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(MARGINLEFT, MID_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
      }
    }
  }
}
