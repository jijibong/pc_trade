import 'package:flutter/cupertino.dart';
import '../../../util/painter/k_chart/base_k_chart_painter.dart';
import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * DKX指标线绘制，数据计算
 * @author hexuejian
 *
 */
 class DKXEntity {
  /**DKX数据集合*/
   List<double> DKX=[];
  /**MADKX数据集合*/
   List<double> MADKX=[];
  /** 默认字体大小 **/
   static double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  /**增加数据类*/
   CalcIndexData mCalcData =  CalcIndexData();


   DKXEntity() {
    DKX = [];
    MADKX = [];

  }

  /**
   * 初始化DKX数据
   * @param OHLCData
   */
   void initData(List<OHLCEntity> OHLCData , int dkxPeriod, int madkxPeriod){
    DKX.clear();
    MADKX.clear();

    if (OHLCData == null || OHLCData.length == 0) {
      return;
    }

    //计算MID
    List<double> mids = [];
    for (int i = 0; i < OHLCData.length; i++) {
      double a = 0.0;
      a = (3 * (OHLCData[i].close??0)
          + (OHLCData[i].low??0)
          + (OHLCData[i].open??0) + (OHLCData[i].high??0)) / 6;
      mids.add(a);
    }

    //计算DKX
    for (int i = dkxPeriod-1; i < mids.length; i++) {
      double a = 0.0;
      for (int j = dkxPeriod; j > 0 ; j--) {
        a +=j*mids[i+(j-dkxPeriod)];
      }
      DKX.add(a /((dkxPeriod + 1) * (dkxPeriod/2)));
    }

    //计算MADKX
    for (int i = madkxPeriod - 1;i <DKX.length; i++) {
      double a = 0.0;
      for (int j = i; j >i- madkxPeriod; j--) {
        a += DKX[j] ;
      }
      MADKX.add(a / madkxPeriod);
    }

  
  }


  /**
   * 增加DKX的值
   * @param OHLCData
   * @param dkxPeriod
   * @param madkxPeriod
   * @param count
   */
   void addData(List<OHLCEntity> OHLCData , int dkxPeriod, int madkxPeriod , int count){
    if (DKX.isEmpty||MADKX.isEmpty) {
      return;
    }
    if (mCalcData.calcDKX(OHLCData, dkxPeriod, madkxPeriod, OHLCData.length-1) == null) return;

    DKX.remove(DKX.length-1);
    MADKX.remove(MADKX.length-1);
    //计算DKX，MADKX
    for (int i = count; i > 0; i--) {

      Map<String, double> value = mCalcData.calcDKX(OHLCData, dkxPeriod, madkxPeriod, OHLCData.length-i);
      double dkx = value["dkx"]??0;
      double madkx = value["madkx"]??0;
      DKX.add(dkx);
      MADKX.add(madkx);
    }

  }


  /**
   * 绘制DKX,MADKX
   */
   void drawDKX(Canvas canvas, int mDataStartIndext,int mShowDataNum,double mCandleWidth,double mMaxPrice,double mMinPrice,
      int CANDLE_INTERVAL,double MARGINLEFT,double MARGINTOP ,double uperChartHeight,
      int DKXPeriod , int MADKXPeriod){
    double rate = 0.0;//每单位像素价格
    Paint yellowPaint = MethodUntil().getDrawPaint(Port.DKXColor);
    Paint bluePaint = MethodUntil().getDrawPaint(Port.MADKXColor);
    TextPainter textPaint =TextPainter();// MethodUntil().getDrawPaint(Port.foreGroundColor);
    yellowPaint.strokeWidth=Port.DKXWidth[0];
    bluePaint.strokeWidth=Port.DKXWidth[1];
    // textPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);

    rate = (uperChartHeight - DEFAULT_AXIS_TITLE_SIZE-10) / (mMaxPrice - mMinPrice);//计算最小单位
    double textBottom = MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = MARGINLEFT;


    //开始绘制
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum ; i++) {
      int number = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX =  MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double nextX =  MARGINLEFT + mCandleWidth * (number) + mCandleWidth;

      //从DKX周期开始才绘制DKX
      if (i >= DKXPeriod-1) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (DKXPeriod-1) : i - (DKXPeriod-1) + 1;
        if(nextNumber < DKX.length){
          //绘制DKX线
          double startY =  ((mMaxPrice - DKX[i - (DKXPeriod-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - DKX[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), bluePaint);
        }
      }

      //从MADKX周期开始才绘制MADKX
      if (i >= DKXPeriod + MADKXPeriod-2) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (DKXPeriod + MADKXPeriod-2) : i - (DKXPeriod + MADKXPeriod-2) + 1;
        if(nextNumber < MADKX.length){
          //绘制MADKX线
          double startY =  ((mMaxPrice - MADKX[i - (DKXPeriod + MADKXPeriod-2)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - MADKX[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), yellowPaint);
        }
      }

      //绘制当前周期，最新一根数据的DKX,MADKX
      int maxPeriod = DKXPeriod;
      maxPeriod = maxPeriod > DKXPeriod + MADKXPeriod ? maxPeriod : DKXPeriod + MADKXPeriod;
      if (i == (mDataStartIndext + mShowDataNum - 1) && (mDataStartIndext + mShowDataNum) > maxPeriod) {
        String dkx, madkx;
        //dkx数据
        if ((mDataStartIndext + mShowDataNum) > DKXPeriod && (i - (DKXPeriod-1)) < DKX.length) {
          dkx = Utils.getPointNum(DKX[i - (DKXPeriod-1)]);
        }else{
          dkx = "0.000";
        }
        //madkx数据
        if ((mDataStartIndext + mShowDataNum) > (DKXPeriod + MADKXPeriod) && (i - (DKXPeriod + MADKXPeriod-2))< MADKX.length) {
          madkx = Utils.getPointNum(MADKX[i - (DKXPeriod + MADKXPeriod-2)]);
        }else{
          madkx = "0.000";
        }

        String text = "DKX$DKXPeriod:$dkx";
        // textPaint.setColor(Port.DKXColor);
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.DKXColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5));
        textXStart = textXStart + ChartPainter.getStringWidth(text , textPaint) + 15;

        text = "MADKX$MADKXPeriod:$madkx";
        // textPaint.setColor(Port.MADKXColor);
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.MADKXColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5));
      }
    }
  }

}
