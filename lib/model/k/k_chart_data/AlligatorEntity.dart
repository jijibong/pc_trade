import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * 鳄鱼线指标线绘制，数据计算
 * @author hexuejian
 *
 */
class AlligatorEntity {
  /**鳄鱼线鳄线数据集合*/
  List<double> JawList = [];
  /**鳄鱼线齿线数据集合*/
  List<double> TeethList = [];
  /**鳄鱼线唇线数据集合*/
  List<double> LipsList = [];
  /** 默认字体大小 **/
  static double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  /**增加数据类*/
  CalcIndexData mCalcData = CalcIndexData();

  AlligatorEntity() {
    JawList = [];
    TeethList = [];
    LipsList = [];
  }

  /**
   * 初始化鳄鱼线数据
   * @param OHLCData
   */
  void initData(List<OHLCEntity> OHLCData, int JawPeriod, int TeethPeriod, int LipsPeriod) {
    JawList.clear();
    TeethList.clear();
    LipsList.clear();

    if (OHLCData.isEmpty) {
      return;
    }

    JawList = calcSmooth(OHLCData, JawPeriod);
    TeethList = calcSmooth(OHLCData, TeethPeriod);
    LipsList = calcSmooth(OHLCData, LipsPeriod);
  }

  /**
   * 计算顺畅移动平均
   * @param OHLCData
   * @param period
   * @return
   */
  List<double> calcSmooth(List<OHLCEntity> OHLCData, int period) {
    List<double> doubles = [];
    for (int i = period - 1; i < OHLCData.length; i++) {
      double a = 0.0;

      for (int j = i; j > i - period; j--) {
        a += ((OHLCData[j].high ?? 0) + (OHLCData[j].low ?? 0)) / 2;
      }

      doubles.add(a / period);
    }
    return doubles;
  }

  /**
   * 增加鳄鱼线数据
   * @param OHLCData
   * @param JawPeriod
   * @param TeethPeriod
   * @param LipsPeriod
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int JawPeriod, int TeethPeriod, int LipsPeriod, int count) {
    if (JawList.isEmpty || TeethList.isEmpty || LipsList.isEmpty) {
      return;
    }
    if (mCalcData.calcAlligator(OHLCData, LipsPeriod, OHLCData.length - 1) == double.maxFinite) return;

    JawList.remove(JawList.length - 1);
    TeethList.remove(TeethList.length - 1);
    LipsList.remove(LipsList.length - 1);

    //计算鳄
    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcAlligator(OHLCData, JawPeriod, OHLCData.length - i);
      JawList.add(value);
    }

    //计算齿
    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcAlligator(OHLCData, TeethPeriod, OHLCData.length - i);
      TeethList.add(value);
    }

    //计算唇
    for (int i = count; i > 0; i--) {
      double value = mCalcData.calcAlligator(OHLCData, LipsPeriod, OHLCData.length - i);
      LipsList.add(value);
    }
  }

  /**
   * 绘制鳄鱼线
   */
  void drawAlligator(
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
      int JawPeriod,
      int JawSpeed,
      int TeethPeriod,
      int TeethSpeed,
      int LipsPeriod,
      int LipsSpeed) {
    double rate = 0.0; //每单位像素价格
    Paint jawPaint = MethodUntil().getDrawPaint(Port.jawColor);
    Paint teethPaint = MethodUntil().getDrawPaint(Port.teethColor);
    Paint lipsPaint = MethodUntil().getDrawPaint(Port.lipsColor);
    TextPainter textPaint = TextPainter();

    rate = (uperChartHeight - DEFAULT_AXIS_TITLE_SIZE - 10) / (mMaxPrice - mMinPrice); //计算最小单位
    double textBottom = MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = MARGINLEFT;

    //绘制jaw下巴
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum + JawSpeed; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum + JawSpeed ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double nextX = MARGINLEFT + mCandleWidth * (number) + mCandleWidth;

      //从周期开始才绘制jaw下巴
      if (i >= JawPeriod - 1 + JawSpeed) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum + JawSpeed ? i - (JawPeriod - 1 + JawSpeed) : i - (JawPeriod - 1 + JawSpeed) + 1;
        //绘制UP线
        if (nextNumber < JawList.length) {
          double startY = (mMaxPrice - JawList[i - (JawPeriod - 1 + JawSpeed)]) * rate + textBottom;
          double stopY = (mMaxPrice - JawList[nextNumber]) * rate + textBottom;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), jawPaint);
        }
      }

//		//绘制当前周期，最新一根数据的
      if (i == (mDataStartIndext + mShowDataNum + JawSpeed - 1) && (i - (JawPeriod - 1 + JawSpeed) + 1) < JawList.length) {
        String jaw = Utils.getPointNum(JawList[i - (JawPeriod - 1 + JawSpeed)] + 1);
        String text = "JAW${Port.JawPeriod}:$jaw";
        // textPaint.setColor(Port.jawColor);
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.jawColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;
      }
    }

    //绘制牙齿
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum + TeethSpeed; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum + TeethSpeed ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = (MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth);
      double nextX = (MARGINLEFT + mCandleWidth * (number) + mCandleWidth);

      //从周期开始才绘制牙齿
      if (i >= TeethPeriod - 1 + TeethSpeed) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum + TeethSpeed ? i - (TeethPeriod - 1 + TeethSpeed) : i - (TeethPeriod - 1 + TeethSpeed) + 1;
        if (nextNumber < TeethList.length) {
          //绘制UP线
          double startY = ((mMaxPrice - TeethList[i - (TeethPeriod - 1 + TeethSpeed)]) * rate + textBottom);
          double stopY = ((mMaxPrice - TeethList[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), teethPaint);
        }
      }

      //绘制当前周期，最新一根数据的
      if (i == (mDataStartIndext + mShowDataNum + TeethSpeed - 1) && (i - (TeethPeriod - 1 + TeethSpeed) + 1) < TeethList.length) {
        String jaw = Utils.getPointNum(TeethList[i - (TeethPeriod - 1 + TeethSpeed) + 1]);
        String text = "Teeth${Port.TeethPeriod}:$jaw";
        // textPaint.setColor(Port.teethColor);
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.teethColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;
      }
    }

    //绘制嘴唇
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum + LipsSpeed; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum + LipsSpeed ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = (MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth);
      double nextX = (MARGINLEFT + mCandleWidth * (number) + mCandleWidth);
      //从周期开始才绘制嘴唇
      if (i >= LipsPeriod - 1 + LipsSpeed) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum + LipsSpeed ? i - (LipsPeriod - 1 + LipsSpeed) : i - (LipsPeriod - 1 + LipsSpeed) + 1;
        if (nextNumber < LipsList.length) {
          //绘制嘴唇s
          double startY = ((mMaxPrice - LipsList[i - (LipsPeriod - 1 + LipsSpeed)]) * rate + textBottom);
          double stopY = ((mMaxPrice - LipsList[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), lipsPaint);
        }
      }

      //绘制当前周期，最新一根数据的
      if (i == (mDataStartIndext + mShowDataNum + LipsSpeed - 1) && (i - (LipsPeriod - 1 + LipsSpeed) + 1) < LipsList.length) {
        String jaw = Utils.getPointNum(LipsList[i - (LipsPeriod - 1 + LipsSpeed)] + 1);
        String text = "Lip${Port.LipsPeriod}:$jaw";
        // textPaint.setColor(Port.lipsColor);
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.lipsColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
      }
    }
  }
}
