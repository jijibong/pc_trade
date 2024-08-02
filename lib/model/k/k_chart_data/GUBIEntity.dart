import 'package:fluent_ui/fluent_ui.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * 顾比均线指标线绘制，数据计算
 * @author hexuejian
 *
 */
 class GUBIEntity {
   List<double> Cost1=[];
   List<double> Cost2=[];
   List<double> Cost3=[];
   List<double> Cost4=[];
   List<double> Cost5=[];
   List<double> Cost6=[];
   List<double> Cost7=[];
   List<double> Cost8=[];
   List<double> Cost9=[];
   List<double> Cost10=[];
   List<double> Cost11=[];
   List<double> Cost12=[];
  /** 默认字体大小 **/
   static  double DEFAULT_AXIS_TITLE_SIZE = 22;
  /**增加数据类*/
   CalcIndexData mCalcData =  CalcIndexData();


   GUBIEntity() {
    Cost1 = [];
    Cost2 = [];
    Cost3 = [];
    Cost4 = [];
    Cost5 = [];
    Cost6 = [];
    Cost7 = [];
    Cost8 = [];
    Cost9 = [];
    Cost10 =[];
    Cost11 =[];
    Cost12 =[];

  }

  /**
   * 初始化CostLine数据
   * @param OHLCData
   * @param pri_type
   */
   void initData(List<OHLCEntity> OHLCData , int Period1, int Period2 , int Period3 ,
      int Period4 , int Period5 , int Period6 , int Period7 , int Period8 ,
      int Period9 , int Period10 , int Period11 , int Period12 , int type , int pri_type){
    Cost1.clear();
    Cost2.clear();
    Cost3.clear();
    Cost4.clear();
    Cost5.clear();
    Cost6.clear();
    Cost7.clear();
    Cost8.clear();
    Cost9.clear();
    Cost10.clear();
    Cost11.clear();
    Cost12.clear();

    if (OHLCData == null || OHLCData.length == 0) {
      return;
    }

    //周期1
    for (int i = Period1 - 1; i < OHLCData.length; i++) {
      Cost1.add(mCalcData.calcCost(OHLCData, Period1, type, pri_type, i));
    }

    //周期2
    for (int i = Period2 - 1; i < OHLCData.length; i++) {
      Cost2.add(mCalcData.calcCost(OHLCData, Period2, type, pri_type, i));
    }

    //周期3
    for (int i = Period3 - 1; i < OHLCData.length; i++) {
      Cost3.add(mCalcData.calcCost(OHLCData, Period3, type, pri_type, i));
    }

    //周期4
    for (int i = Period4 - 1; i < OHLCData.length; i++) {
      Cost4.add(mCalcData.calcCost(OHLCData, Period4, type, pri_type, i));
    }

    //周期4
    for (int i = Period5 - 1; i < OHLCData.length; i++) {
      Cost5.add(mCalcData.calcCost(OHLCData, Period5, type, pri_type, i));
    }

    //周期6
    for (int i = Period6 - 1; i < OHLCData.length; i++) {
      Cost6.add(mCalcData.calcCost(OHLCData, Period6, type, pri_type, i));
    }

    //周期7
    for (int i = Period7 - 1; i < OHLCData.length; i++) {
      Cost7.add(mCalcData.calcCost(OHLCData, Period7, type, pri_type, i));
    }

    //周期8
    for (int i = Period8 - 1; i < OHLCData.length; i++) {
      Cost8.add(mCalcData.calcCost(OHLCData, Period8, type, pri_type, i));
    }

    //周期9
    for (int i = Period9 - 1; i < OHLCData.length; i++) {
      Cost9.add(mCalcData.calcCost(OHLCData, Period9, type, pri_type, i));
    }

    //周期10
    for (int i = Period10 - 1; i < OHLCData.length; i++) {
      Cost10.add(mCalcData.calcCost(OHLCData, Period10, type, pri_type, i));
    }

    //周期11
    for (int i = Period11 - 1; i < OHLCData.length; i++) {
      Cost11.add(mCalcData.calcCost(OHLCData, Period11, type, pri_type, i));
    }

    //周期12
    for (int i = Period12 - 1; i < OHLCData.length; i++) {
      Cost12.add(mCalcData.calcCost(OHLCData, Period12, type, pri_type, i));
    }


  }


  /**
   * 取值
   */
  //  double getPrice(List<OHLCEntity> OHLCData , int i , int pri_type){
  //   double price= 0.0;
  //   switch (pri_type) {
  //
  //     case 0://开
  //       price = OHLCData[i).getOpen();
  //       break;
  //
  //     case 1://高
  //       price = OHLCData[i).getHigh();
  //       break;
  //
  //     case 2://收
  //       price = OHLCData[i).getClose();
  //       break;
  //
  //     case 3://低
  //       price = OHLCData[i).getLow();
  //       break;
  //
  //     case 4://高低一半
  //       price = (OHLCData[i).getHigh()+OHLCData[i).getLow()) / 2;
  //       break;
  //
  //     default:
  //       break;
  //   }
  //   return price;
  // }


  /**
   * 增加顾比均线线数据
   * @param OHLCData
   * @param type
   * @param pri_type
   * @param count
   */
   void addData(List<OHLCEntity> OHLCData , int Period1, int Period2 , int Period3 ,
      int Period4 , int Period5 , int Period6 , int Period7 ,
      int Period8 , int Period9 , int Period10 , int Period11 , int Period12 , int type , int pri_type ,int count){

    if (Cost1.length==0||
        Cost2.length==0||
        Cost3.length==0||
        Cost4.length==0||
        Cost5.length==0||
        Cost6.length==0||
        Cost7.length==0||
        Cost8.length==0||
        Cost9.length==0||
        Cost10.length==0||
        Cost11.length==0||
        Cost12.length==0) {
      return;
    }

    if (mCalcData.calcCost(OHLCData, Period12, type, pri_type, OHLCData.length-1) == double.maxFinite) return;


    Cost1.remove(Cost1.length-1);
    Cost2.remove(Cost2.length-1);
    Cost3.remove(Cost3.length-1);
    Cost4.remove(Cost4.length-1);
    Cost5.remove(Cost5.length-1);
    Cost6.remove(Cost6.length-1);
    Cost7.remove(Cost7.length-1);
    Cost8.remove(Cost8.length-1);
    Cost9.remove(Cost9.length-1);
    Cost10.remove(Cost10.length-1);
    Cost11.remove(Cost11.length-1);
    Cost12.remove(Cost12.length-1);

    //均线一
    for (int i = count; i > 0; i--) {
      Cost1.add(mCalcData.calcCost(OHLCData, Period1, type, pri_type, OHLCData.length-i));
    }
    //均线二
    for (int i = count; i > 0; i--) {
      Cost2.add(mCalcData.calcCost(OHLCData, Period2, type, pri_type, OHLCData.length-i));
    }
    //均线三
    for (int i = count; i > 0; i--) {
      Cost3.add(mCalcData.calcCost(OHLCData, Period3, type, pri_type, OHLCData.length-i));
    }
    //均线四
    for (int i = count; i > 0; i--) {
      Cost4.add(mCalcData.calcCost(OHLCData, Period4, type, pri_type, OHLCData.length-i));
    }
    //均线五
    for (int i = count; i > 0; i--) {
      Cost5.add(mCalcData.calcCost(OHLCData, Period5, type, pri_type, OHLCData.length-i));
    }
    //均线6
    for (int i = count; i > 0; i--) {
      Cost6.add(mCalcData.calcCost(OHLCData, Period6, type, pri_type, OHLCData.length-i));
    }
    //均线7
    for (int i = count; i > 0; i--) {
      Cost7.add(mCalcData.calcCost(OHLCData, Period7, type, pri_type, OHLCData.length-i));
    }
    //均线8
    for (int i = count; i > 0; i--) {
      Cost8.add(mCalcData.calcCost(OHLCData, Period8, type, pri_type, OHLCData.length-i));
    }
    //均线9
    for (int i = count; i > 0; i--) {
      Cost9.add(mCalcData.calcCost(OHLCData, Period9, type, pri_type, OHLCData.length-i));
    }
    //均线10
    for (int i = count; i > 0; i--) {
      Cost10.add(mCalcData.calcCost(OHLCData, Period10, type, pri_type, OHLCData.length-i));
    }
    //均线11
    for (int i = count; i > 0; i--) {
      Cost11.add(mCalcData.calcCost(OHLCData, Period11, type, pri_type, OHLCData.length-i));
    }
    //均线12
    for (int i = count; i > 0; i--) {
      Cost12.add(mCalcData.calcCost(OHLCData, Period12, type, pri_type, OHLCData.length-i));
    }
  }


  /**
   * 绘制均线
   */
   void drawGUBI(Canvas canvas, int mDataStartIndext,int mShowDataNum,double mCandleWidth,double mMaxPrice,double mMinPrice,
      int CANDLE_INTERVAL,double MARGINLEFT,double MARGINTOP ,double uperChartHeight ,
      int GUBIPeriod1 , int GUBIPeriod2 , int GUBIPeriod3 , int GUBIPeriod4 , int GUBIPeriod5 , int GUBIPeriod6 ,
      int GUBIPeriod7 , int GUBIPeriod8 , int GUBIPeriod9 , int GUBIPeriod10 , int GUBIPeriod11 , int GUBIPeriod12){
    double rate = 0.0;//每单位像素价格
    Paint shortPaint = MethodUntil().getDrawPaint(Port.GUBI_SColor);
    Paint longPaint = MethodUntil().getDrawPaint(Port.GUBI_LColor);
    // Paint textPaint = MethodUntil().getDrawPaint(Port.foreGroundColor);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.foreGroundColor);
    shortPaint.strokeWidth=Port.GUBIWidth[0];
    longPaint.strokeWidth=Port.GUBIWidth[1];
    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
    // textPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);

    rate = (uperChartHeight - DEFAULT_AXIS_TITLE_SIZE-10) / (mMaxPrice - mMinPrice);//计算最小单位
    double textBottom = MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = MARGINLEFT;


    //开始绘制
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum ; i++) {
      int number = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX =  (MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth);
      double nextX =  (MARGINLEFT + mCandleWidth * (number) + mCandleWidth);

      //从周期1开始才绘制均线1
      if (i >= GUBIPeriod1-1) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod1-1) : i - (GUBIPeriod1-1) + 1;
        if(nextNumber < Cost1.length){
          //绘制均线1
          double startY =  (mMaxPrice - Cost1[i - (GUBIPeriod1-1)]) * rate  + textBottom;
          double stopY =  (mMaxPrice - Cost1[nextNumber]) * rate  + textBottom;
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), shortPaint);
        }
      }

      //从周期2开始才绘制均线2
      if (i >= GUBIPeriod2-1 ) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod2-1) : i - (GUBIPeriod2-1) + 1;
        if(nextNumber < Cost2.length){
          //绘制均线2
          double startY =  ((mMaxPrice - Cost2[i - (GUBIPeriod2-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - Cost2[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), shortPaint);
        }
      }

      //从周期3开始才绘制均线3
      if (i >= GUBIPeriod3-1 ) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod3-1) : i - (GUBIPeriod3-1) + 1;
        if(nextNumber < Cost3.length){
          //绘制均线3
          double startY =  (mMaxPrice - Cost3[i - (GUBIPeriod3-1)]) * rate  + textBottom;
          double stopY =  (mMaxPrice - Cost3[nextNumber]) * rate  + textBottom;
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), shortPaint);
        }
      }

      //从周期4开始才绘制均线4
      if (i >= GUBIPeriod4-1 ) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod4-1) : i - (GUBIPeriod4-1) + 1;
        if(nextNumber < Cost4.length){
          //绘制均线4
          double startY =  ((mMaxPrice - Cost4[i - (GUBIPeriod4-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - Cost4[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), shortPaint);
        }
      }

      //从周期5开始才绘制均线5
      if (i >= GUBIPeriod5-1 ) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod5-1) : i - (GUBIPeriod5-1) + 1;
        if(nextNumber < Cost5.length){
          //绘制均线5
          double startY =  ((mMaxPrice - Cost5[i - (GUBIPeriod5-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - Cost5[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), shortPaint);
        }
      }
      //从周期6开始才绘制均线6
      if (i >= GUBIPeriod6-1 ) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod6-1) : i - (GUBIPeriod6-1) + 1;
        if(nextNumber < Cost6.length){
          //绘制均线6
          double startY =  ((mMaxPrice - Cost6[i - (GUBIPeriod6-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - Cost6[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), shortPaint);
        }
      }

      //从周期7开始才绘制均线7
      if (i >= GUBIPeriod7-1) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod7-1) : i - (GUBIPeriod7-1) + 1;
        if(nextNumber < Cost7.length){
          //绘制均线7
          double startY =  ((mMaxPrice - Cost7[i - (GUBIPeriod7-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - Cost7[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), longPaint);
        }
      }

      //从周期8开始才绘制均线8
      if (i >= GUBIPeriod8-1 ) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod8-1) : i - (GUBIPeriod8-1) + 1;
        if(nextNumber < Cost8.length){
          //绘制均线8
          double startY =  ((mMaxPrice - Cost8[i - (GUBIPeriod8-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - Cost8[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), longPaint);
        }
      }

      //从周期9开始才绘制均线9
      if (i >= GUBIPeriod9-1 ) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod9-1) : i - (GUBIPeriod9-1) + 1;
        if(nextNumber < Cost9.length){
          //绘制均线9
          double startY =  ((mMaxPrice - Cost9[i - (GUBIPeriod9-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - Cost9[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), longPaint);
        }
      }

      //从周期10开始才绘制均线10
      if (i >= GUBIPeriod10-1 ) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod10-1) : i - (GUBIPeriod10-1) + 1;
        if(nextNumber < Cost10.length){
          //绘制均线10
          double startY =  ((mMaxPrice - Cost10[i - (GUBIPeriod10-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - Cost10[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), longPaint);
        }
      }

      //从周期11开始才绘制均线11
      if (i >= GUBIPeriod11-1 ) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod11-1) : i - (GUBIPeriod11-1) + 1;
        if(nextNumber < Cost11.length){
          //绘制均线11
          double startY =  ((mMaxPrice - Cost11[i - (GUBIPeriod11-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - Cost11[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), longPaint);
        }
      }
      //从周期12开始才绘制均线12
      if (i >= GUBIPeriod12-1 ) {
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (GUBIPeriod12-1) : i - (GUBIPeriod12-1) + 1;
        if(nextNumber < Cost12.length){
          //绘制均线12
          double startY =  ((mMaxPrice - Cost12[i - (GUBIPeriod12-1)]) * rate  + textBottom);
          double stopY =  ((mMaxPrice - Cost12[nextNumber]) * rate  + textBottom);
          canvas.drawLine(Offset(startX, startY),Offset(nextX, stopY), longPaint);
        }
      }

      //绘制当前周期，最新一根数据
      if (i == (mDataStartIndext + mShowDataNum - 1)) {
        String cost1 , cost2 , cost3 , cost4 , cost5, cost6
        , cost7, cost8, cost9, cost10, cost11, cost12;
        //周期1的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod1 && (i - (GUBIPeriod1-1)) < Cost1.length) {
          cost1 = Utils.getPointNum(Cost1[i - (GUBIPeriod1-1)]);
        }else{
          cost1 = "0.000";
        }

        //周期2的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod2 && (i - (GUBIPeriod2-1)) < Cost2.length) {
          cost2 = Utils.getPointNum(Cost2[i - (GUBIPeriod2-1)]);
        }else{
          cost2 = "0.000";
        }
        //周期3的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod3  && (i - (GUBIPeriod3-1)) < Cost3.length) {
          cost3 = Utils.getPointNum(Cost3[i - (GUBIPeriod3-1)]);
        }else{
          cost3 = "0.000";
        }
        //周期4的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod4 && (i - (GUBIPeriod4-1)) < Cost4.length) {
          cost4 = Utils.getPointNum(Cost4[i - (GUBIPeriod4-1)]);
        }else{
          cost4 = "0.000";
        }
        //周期5的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod5 && (i - (GUBIPeriod5-1)) < Cost5.length) {
          cost5 = Utils.getPointNum(Cost5[i - (GUBIPeriod5-1)]);
        }else{
          cost5 = "0.000";
        }
        //周期6的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod6 && (i - (GUBIPeriod6-1)) < Cost6.length) {
          cost6 = Utils.getPointNum(Cost6[i - (GUBIPeriod6-1)]);
        }else{
          cost6 = "0.000";
        }
        //周期7的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod7 && (i - (GUBIPeriod7-1)) < Cost7.length) {
          cost7 = Utils.getPointNum(Cost7[i - (GUBIPeriod7-1)]);
        }else{
          cost7 = "0.000";
        }
        //周期8的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod8  && (i - (GUBIPeriod8-1)) < Cost8.length) {
          cost8 = Utils.getPointNum(Cost8[i - (GUBIPeriod8-1)]);
        }else{
          cost8 = "0.000";
        }
        //周期9的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod9  && (i - (GUBIPeriod9-1)) < Cost9.length) {
          cost9 = Utils.getPointNum(Cost9[i - (GUBIPeriod9-1)]);
        }else{
          cost9 = "0.000";
        }
        //周期10的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod10 && (i - (GUBIPeriod10-1)) < Cost10.length) {
          cost10 = Utils.getPointNum(Cost10[i - (GUBIPeriod10-1)]);
        }else{
          cost10 = "0.000";
        }
        //周期11的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod11 && (i - (GUBIPeriod11-1)) < Cost11.length) {
          cost11 = Utils.getPointNum(Cost11[i - (GUBIPeriod11-1)]);
        }else{
          cost11 = "0.000";
        }
        //周期12的当前数据
        if ((mDataStartIndext + mShowDataNum) > GUBIPeriod12 && (i - (GUBIPeriod12-1)) < Cost12.length) {
          cost12 = Utils.getPointNum(Cost12[i - (GUBIPeriod12-1)]);
        }else{
          cost12 = "0.000";
        }

        String text = "GUMA($GUBIPeriod1,  $GUBIPeriod2,  $GUBIPeriod3,  $GUBIPeriod4,  $GUBIPeriod5 ,  $GUBIPeriod6,  $GUBIPeriod7,  $GUBIPeriod8,  $GUBIPeriod9,  $GUBIPeriod10,  $GUBIPeriod11,  $GUBIPeriod12)";
        // textPaint.setColor(Port.GUBI_SColor);
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.GUBI_SColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
      }

    }
  }

}
