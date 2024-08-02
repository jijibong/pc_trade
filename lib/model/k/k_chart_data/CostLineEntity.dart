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
 class CostLineEntity {
  /**CostLine数据集合一*/
   List<double> CostOne=[];
  /**CostLine数据集合二*/
   List<double> CostTwo=[];
  /**CostLine数据集合三*/
   List<double> CostThree=[];
  /**CostLine数据集合四*/
   List<double> CostFour=[];
  /**CostLine数据集合五*/
   List<double> CostFive=[];
  /** 默认字体大小 **/
   static  double DEFAULT_AXIS_TITLE_SIZE = 22;
  /**增加数据类*/
   CalcIndexData mCalcData =  CalcIndexData();


   CostLineEntity() {
    CostOne =  [];
    CostTwo =  [];
    CostThree =[];
    CostFour = [];
    CostFive = [];

  }

  /**
   * 初始化CostLine数据
   * @param OHLCData
   * @param pri_type
   */
   void initData(List<OHLCEntity> OHLCData , int onePeriod, int twoPeriod , int threePeriod ,
      int fourPeriod , int fivePeriod , int type , int pri_type){
    CostOne.clear();
    CostTwo.clear();
    CostThree.clear();
    CostFour.clear();
    CostFive.clear();

    if (OHLCData == null || OHLCData.length == 0) {
      return;
    }

    switch (type) {//按类型计算

      case 0://simple
        calcSimple(OHLCData, onePeriod, twoPeriod, threePeriod, fourPeriod, fivePeriod, pri_type);
        break;

      case 1://Exponential
        calcExponential(OHLCData, onePeriod, twoPeriod, threePeriod, fourPeriod, fivePeriod, pri_type);
        break;

      case 2://smoothed
        calcSmoothed(OHLCData, onePeriod, twoPeriod, threePeriod, fourPeriod, fivePeriod, pri_type);
        break;

      default:
        break;
    }


  }

  /**
   * 简单移动平均计算
   */
   void calcSimple(List<OHLCEntity> OHLCData , int onePeriod, int twoPeriod , int threePeriod ,
      int fourPeriod , int fivePeriod ,int pri_type){
    //周期一
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= onePeriod - 1) {
        double a = 0.0;
        for (int j = 0; j < onePeriod; j++) {
          a += getPrice(OHLCData, j + i - (onePeriod - 1), pri_type);
        }
        CostOne.add(a/onePeriod);
      }
    }


    //周期二
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= twoPeriod - 1) {
        double a = 0.0;
        for (int j = 0; j < twoPeriod; j++) {
          a += getPrice(OHLCData, j + i - (twoPeriod - 1), pri_type);
        }
        CostTwo.add(a/twoPeriod);
      }
    }

    //周期三
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= threePeriod - 1) {
        double a = 0.0;
        for (int j = 0; j < threePeriod; j++) {
          a += getPrice(OHLCData, j + i - (threePeriod - 1), pri_type);
        }
        CostThree.add(a/threePeriod);
      }
    }

    //周期四
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= fourPeriod - 1) {
        double a = 0.0;
        for (int j = 0; j < fourPeriod; j++) {
          a += getPrice(OHLCData, j + i - (fourPeriod - 1), pri_type);
        }
        CostFour.add(a/fourPeriod);
      }
    }

    //周期五
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= fivePeriod - 1) {
        double a = 0.0;
        for (int j = 0; j < fivePeriod; j++) {
          a += getPrice(OHLCData, j + i - (fivePeriod - 1), pri_type);
        }
        CostFive.add(a/fivePeriod);
      }
    }
  }

  /**
   * 指数移动平均计算 EMA(X,N) = 2*X/(N+1)+(N-1)/(N+1)*昨日指数收盘平均值  ,X为当日价格,N为周期
   */
   void calcExponential(List<OHLCEntity> OHLCData , int onePeriod, int twoPeriod , int threePeriod ,
      int fourPeriod , int fivePeriod ,int pri_type){
    double tmpValue = 0.0;
    //周期一
    for (int i = onePeriod - 1; i < OHLCData.length; i++) {
      if (i == onePeriod - 1) {
        tmpValue = getPrice(OHLCData, i, pri_type);
      }else{
        tmpValue = (2.0*getPrice(OHLCData, i, pri_type) + (onePeriod - 1)*tmpValue) / (onePeriod + 1);
    }
    CostOne.add(tmpValue);
    }

    //周期二
    for (int i = twoPeriod - 1; i < OHLCData.length; i++) {
    if (i == twoPeriod - 1) {
    tmpValue = getPrice(OHLCData, i, pri_type);
    }else{
    tmpValue = (2.0*getPrice(OHLCData, i, pri_type)+(twoPeriod - 1)*tmpValue) / (twoPeriod + 1);
    }
    CostTwo.add(tmpValue);
    }

    //周期三
    for (int i = threePeriod - 1; i < OHLCData.length; i++) {
    if (i == threePeriod - 1) {
    tmpValue = getPrice(OHLCData, i, pri_type);
    }else{
    tmpValue = (2.0*getPrice(OHLCData, i, pri_type)+(threePeriod - 1)*tmpValue) / (threePeriod + 1);
    }
    CostThree.add(tmpValue);
    }

    //周期四
    for (int i = fourPeriod - 1; i < OHLCData.length; i++) {
    if (i == fourPeriod - 1) {
    tmpValue = getPrice(OHLCData, i, pri_type);
    }else{
    tmpValue = (2.0*getPrice(OHLCData, i, pri_type)+(fourPeriod - 1)*tmpValue) / (fourPeriod + 1);
    }
    CostFour.add(tmpValue);
    }

    //周期五
    for (int i = fivePeriod - 1; i < OHLCData.length; i++) {
    if (i == fivePeriod - 1) {
    tmpValue = getPrice(OHLCData, i, pri_type);
    }else{
    tmpValue = (2.0*getPrice(OHLCData, i, pri_type)+(fivePeriod - 1)*tmpValue) / (fivePeriod + 1);
    }
    CostFive.add(tmpValue);
    }
  }

  /**
   * 平滑移动平均计算
   */
   void calcSmoothed(List<OHLCEntity> OHLCData , int onePeriod, int twoPeriod , int threePeriod ,
      int fourPeriod , int fivePeriod ,int pri_type){
    //周期一
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= onePeriod - 1) {
        double a = 0.0;
        for (int j = 0; j < onePeriod; j++) {
          a += getPrice(OHLCData, j + i - (onePeriod - 1), pri_type);
        }
        double ave = a / onePeriod;
        double value = (a - ave + (OHLCData[i].close??0)) / onePeriod;
        CostOne.add(value);
      }
    }


    //周期二
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= twoPeriod - 1) {
        double a = 0.0;
        for (int j = 0; j < twoPeriod; j++) {
          a += getPrice(OHLCData, j + i - (twoPeriod - 1), pri_type);
        }
        double ave = a / twoPeriod;
        double value = (a - ave + (OHLCData[i].close??0)) / twoPeriod;
        CostTwo.add(value);
      }
    }

    //周期三
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= threePeriod - 1) {
        double a = 0.0;
        for (int j = 0; j < threePeriod; j++) {
          a += getPrice(OHLCData, j + i - (threePeriod - 1), pri_type);
        }
        double ave = a / threePeriod;
        double value = (a - ave + (OHLCData[i].close??0)) / threePeriod;
        CostThree.add(value);
      }
    }

    //周期四
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= fourPeriod - 1) {
        double a = 0.0;
        for (int j = 0; j < fourPeriod; j++) {
          a += getPrice(OHLCData, j + i - (fourPeriod - 1), pri_type);
        }
        double ave = a / fourPeriod;
        double value = (a - ave + (OHLCData[i].close??0)) / fourPeriod;
        CostFour.add(value);
      }
    }

    //周期五
    for (int i = 0; i < OHLCData.length; i++) {
      if (i >= fivePeriod - 1) {
        double a = 0.0;
        for (int j = 0; j < fivePeriod; j++) {
          a += getPrice(OHLCData, j + i - (fivePeriod - 1), pri_type);
        }
        double ave = a / fivePeriod;
        double value = (a - ave + (OHLCData[i].close??0)) / fivePeriod;
        CostFive.add(value);
      }
    }
  }

  /**
   * 取值
   */
   double getPrice(List<OHLCEntity> OHLCData , int i , int pri_type){
    double price= 0.0;
    switch (pri_type) {

      case 0://开
        price = (OHLCData[i].open??0).toDouble();
        break;

      case 1://高
        price = (OHLCData[i].high??0).toDouble();
        break;

      case 2://收
        price = (OHLCData[i].close??0).toDouble();
        break;

      case 3://低
        price = (OHLCData[i].low??0).toDouble();
        break;

      case 4://高低一半
        price = ((OHLCData[i].high??0)+(OHLCData[i].low??0)) / 2;
        break;

      default:
        break;
    }
    return price;
  }


  /**
   * 增加均线数据
   * @param OHLCData
   * @param onePeriod
   * @param twoPeriod
   * @param threePeriod
   * @param fourPeriod
   * @param fivePeriod
   * @param type
   * @param pri_type
   * @param count
   */
   void addData(List<OHLCEntity> OHLCData , int onePeriod, int twoPeriod , int threePeriod ,
      int fourPeriod , int fivePeriod , int type , int pri_type ,int count){

    if (CostOne.isEmpty||
        CostTwo.isEmpty||
        CostThree.isEmpty||
        CostFour.isEmpty||
        CostFive.isEmpty) {
      return;
    }

    if (mCalcData.calcCost(OHLCData, fivePeriod, type, pri_type, OHLCData.length-1) == double.maxFinite) return;


    CostOne.remove(CostOne.length-1);
    CostTwo.remove(CostTwo.length-1);
    CostThree.remove(CostThree.length-1);
    CostFour.remove(CostFour.length-1);
    CostFive.remove(CostFive.length-1);

    //均线一
    for (int i = count; i > 0; i--) {
      CostOne.add(mCalcData.calcCost(OHLCData, onePeriod, type, pri_type, OHLCData.length-i));
    }
    //均线二
    for (int i = count; i > 0; i--) {
      CostTwo.add(mCalcData.calcCost(OHLCData, twoPeriod, type, pri_type, OHLCData.length-i));
    }
    //均线三
    for (int i = count; i > 0; i--) {
      CostThree.add(mCalcData.calcCost(OHLCData, threePeriod, type, pri_type, OHLCData.length-i));
    }
    //均线四
    for (int i = count; i > 0; i--) {
      CostFour.add(mCalcData.calcCost(OHLCData, fourPeriod, type, pri_type, OHLCData.length-i));
    }
    //均线五
    for (int i = count; i > 0; i--) {
      CostFive.add(mCalcData.calcCost(OHLCData, fivePeriod, type, pri_type, OHLCData.length-i));
    }
  }


  /**
   * 绘制均线
   */
   void drawCOST(Canvas canvas, int mDataStartIndext,int mShowDataNum,double mCandleWidth,double mMaxPrice,double mMinPrice,
      int CANDLE_INTERVAL,double MARGINLEFT,double MARGINTOP ,double uperChartHeight,
      int CostOnePeriod , int CostTwoPeriod ,int CostThreePeriod ,int CostFourPeriod ,int CostFivePeriod ,
      bool isDrawCost1 ,bool isDrawCost2 ,bool isDrawCost3 ,bool isDrawCost4 ,bool isDrawCost5){
    double rate = 0.0;//每单位像素价格
    Paint onePaint = MethodUntil().getDrawPaint(Port.costOneColor);
    Paint twoPaint = MethodUntil().getDrawPaint(Port.costTwoColor);
    Paint threePaint = MethodUntil().getDrawPaint(Port.costThreeColor);
    Paint fourPaint =MethodUntil().getDrawPaint(Port.costFourColor);
    Paint fivePaint =MethodUntil().getDrawPaint(Port.costFiveColor);
    TextPainter textPaint = TextPainter(); //MethodUntil().getDrawPaint(Port.foreGroundColor);
    onePaint.strokeWidth=Port.costWidth[0];
    twoPaint.strokeWidth=Port.costWidth[1];
    threePaint.strokeWidth=Port.costWidth[2];
    fourPaint.strokeWidth=Port.costWidth[3];
    fivePaint.strokeWidth=Port.costWidth[4];
    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
    // textPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);

    rate = (uperChartHeight - DEFAULT_AXIS_TITLE_SIZE-10) / (mMaxPrice - mMinPrice);//计算最小单位
    double textBottom = MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = MARGINLEFT;


    //开始绘制
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum ; i++) {
      int number = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX =  MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double nextX =  MARGINLEFT + mCandleWidth * (number) + mCandleWidth;

      //从周期1开始才绘制均线1
      if (i >= CostOnePeriod-1 && isDrawCost1) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (CostOnePeriod-1) : i - (CostOnePeriod-1) + 1;
        if(nextNumber < CostOne.length){
          //绘制均线1
          double startY =  (mMaxPrice - CostOne[i - (CostOnePeriod-1)]) * rate  + textBottom;
          double stopY =  (mMaxPrice - CostOne[nextNumber]) * rate  + textBottom;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), onePaint);
        }
      }

      //从周期2开始才绘制均线2
      if (i >= CostTwoPeriod-1 && isDrawCost2) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (CostTwoPeriod-1) : i - (CostTwoPeriod-1) + 1;
        if(nextNumber < CostTwo.length){
          //绘制均线2
          double startY =  ((mMaxPrice - CostTwo[i - (CostTwoPeriod-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - CostTwo[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), twoPaint);
        }
      }

      //从周期3开始才绘制均线3
      if (i >= CostThreePeriod-1 && isDrawCost3) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (CostThreePeriod-1) : i - (CostThreePeriod-1) + 1;
        if(nextNumber < CostThree.length){
          //绘制均线3
          double startY =  ((mMaxPrice - CostThree[i - (CostThreePeriod-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - CostThree[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), threePaint);
        }
      }

      //从周期4开始才绘制均线4
      if (i >= CostFourPeriod-1 && isDrawCost4) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (CostFourPeriod-1) : i - (CostFourPeriod-1) + 1;
        if(nextNumber < CostFour.length){
          //绘制均线4
          double startY =  ((mMaxPrice - CostFour[i - (CostFourPeriod-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - CostFour[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), fourPaint);
        }
      }

      //从周期5开始才绘制均线5
      if (i >= CostFivePeriod-1 && isDrawCost5) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (CostFivePeriod-1) : i - (CostFivePeriod-1) + 1;
        if(nextNumber < CostFive.length){
          //绘制均线5
          double startY =  ((mMaxPrice - CostFive[i - (CostFivePeriod-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - CostFive[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), fivePaint);
        }
      }

      //绘制当前周期，最新一根数据
      if (i == mDataStartIndext + mShowDataNum - 1) {
        String cost1 , cost2 , cost3 , cost4 , cost5;
        //周期1的当前数据
        if ((mDataStartIndext + mShowDataNum) > CostOnePeriod && isDrawCost1 && (i - (CostOnePeriod-1)) < CostOne.length) {
          cost1 = Utils.getPointNum(CostOne[i - (CostOnePeriod-1)]);
        }else{
          cost1 = "0.000";
        }
        //周期2的当前数据
        if ((mDataStartIndext + mShowDataNum) > CostTwoPeriod && isDrawCost2 && (i - (CostTwoPeriod-1)) < CostTwo.length) {
          cost2 = Utils.getPointNum(CostTwo[i - (CostTwoPeriod-1)]);
        }else{
          cost2 = "0.000";
        }
        //周期3的当前数据
        if ((mDataStartIndext + mShowDataNum) > CostThreePeriod && isDrawCost3 && (i - (CostThreePeriod-1)) < CostThree.length) {
          cost3 = Utils.getPointNum(CostThree[i - (CostThreePeriod-1)]);
        }else{
          cost3 = "0.000";
        }
        //周期4的当前数据
        if ((mDataStartIndext + mShowDataNum) > CostFourPeriod && isDrawCost4 && (i - (CostFourPeriod-1)) < CostFour.length) {
          cost4 = Utils.getPointNum(CostFour[i - (CostFourPeriod-1)]);
        }else{
          cost4 = "0.000";
        }
        //周期5的当前数据
        if ((mDataStartIndext + mShowDataNum) > CostFivePeriod && isDrawCost5 && (i - (CostFivePeriod-1)) < CostFive.length) {
          cost5 = Utils.getPointNum(CostFive[i - (CostFivePeriod-1)]);
        }else{
          cost5 = "0.000";
        }

        String text = "MA$CostOnePeriod:$cost1";
        // textPaint.setColor(Port.costOneColor);
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.costOneColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5));
        textXStart = textXStart +ChartPainter.getStringWidth(text , textPaint) + 15;

        text = "MA$CostTwoPeriod:$cost2";
        // textPaint.setColor(Port.costTwoColor);
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.costTwoColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5));
        textXStart = textXStart + ChartPainter.getStringWidth(text , textPaint) + 15;

        text = "MA$CostThreePeriod:$cost3";
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.costOneColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5));
        textXStart = textXStart + ChartPainter.getStringWidth(text , textPaint) + 15;

        text = "MA$CostFourPeriod:$cost4";
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.costOneColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5));
        textXStart = textXStart + ChartPainter.getStringWidth(text , textPaint) + 15;

        text = "MA$CostFivePeriod:$cost5";
        // textPaint.setColor(Port.costFiveColor);
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.costFiveColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5));
        textXStart = textXStart + ChartPainter.getStringWidth(text , textPaint) + 15;

      }
    }
  }
}
