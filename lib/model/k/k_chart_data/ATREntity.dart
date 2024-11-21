import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * ATR真实波幅指标线绘制，数据计算
 * @author hexuejian
 *
 */
 class ATREntity {
  /**ATR数据集合*/
   List<double> ATRs=[];
  /**TR数据集合*/
   List<double> TRs=[];
  /**CCI最高价*/
   double maxPrice = 0.0;
  /**CCI最低价*/
   double minPrice = 0.0;
  /** 默认字体大小 **/
   static double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  /** 默认虚线效果 */
   List<double> DEFAULT_DASH_EFFECT = [2, 1];
   // static final PathEffect DEFAULT_DASH_EFFECT = new DashPathEffect(new double[] { 2, 3, 2,
  // 3 }, 1);
  /** 虚线颜色 */
   static final Color DEFAULT_DOTTED_COLOR = Colors.grey;
  /**增加数据类*/
   CalcIndexData mCalcData =  CalcIndexData();

   ATREntity() {
    ATRs =[];
    TRs = [];
  }

  /**
   * 初始化CCI数据
   * @param OHLCData
   * @param period
   * @param pri_type
   */
   void initData(List<OHLCEntity> OHLCData , int period , int pri_type){
    ATRs.clear();
    TRs.clear();

    if (OHLCData.isEmpty) {
      return;
    }

    for (int i = period-1; i < OHLCData.length; i++) {
      Map<String, double> value = mCalcData.calcATR(OHLCData, period, i);
      double atr = value["ATR"]??0;
      double tr = value["TR"]??0;
      ATRs.add(atr);
      TRs.add(tr);
    }
  }

  /**
   * 获得Rsi价格
   */
   double getPrice(List<OHLCEntity> OHLCData , int j , int i , int period , int pri_type){
    double price= 0.0;
    switch (pri_type) {
      case 0: //开
        price = ((OHLCData[j + i - (period - 1)].open ?? 0) - (OHLCData[j + i - (period - 1) - 1].open ?? 0)).toDouble();
        break;

      case 1: //高
        price = ((OHLCData[j + i - (period - 1)].high ?? 0) - (OHLCData[j + i - (period - 1) - 1].high ?? 0)).toDouble();
        break;

      case 2: //收
        price = ((OHLCData[j + i - (period - 1)].close ?? 0) - (OHLCData[j + i - (period - 1) - 1].close ?? 0)).toDouble();
        break;

      case 3: //低
        price = ((OHLCData[j + i - (period - 1)].low ?? 0) - (OHLCData[j + i - (period - 1) - 1].low ?? 0)).toDouble();
        break;

      case 4: //高低一半
        price = ((OHLCData[j + i - (period - 1)].high ?? 0) + (OHLCData[j + i - (period - 1)].low ?? 0)) / 2 -
            ((OHLCData[j + i - (period - 1) - 1].high ?? 0) + (OHLCData[j + i - (period - 1) - 1].low ?? 0)) / 2;
        break;

      default:
        break;
    }
    return price;
  }

  /**
   * 增加ATR数据
   * @param OHLCData
   * @param period
   * @param pri_type
   * @param count
   */
   void addData(List<OHLCEntity> OHLCData , int period , int pri_type , int count){
    if (ATRs.isEmpty || TRs.isEmpty) {
      return;
    }

    Map<String, double> map = mCalcData.calcATR(OHLCData, period, OHLCData.length - 1);
    if (map == null) return;

    ATRs.remove(ATRs.length-1);
    TRs.remove(TRs.length-1);

    for (int i = count; i > 0; i--) {
      Map<String, double> value = mCalcData.calcATR(OHLCData, period, OHLCData.length - i);
      double atr = value["ATR"]??0;
      double tr = value["TR"]??0;

      ATRs.add(atr);
      TRs.add(tr);
    }
  }

  /**
   * 计算ATR的最高最低价
   */
   void calclatePrice(int mDataStartIndext , int showNumber, int period){
    if (ATRs.isEmpty || TRs.isEmpty) {
      return;
    }
    //当前绘制到的K线根数大于ATR周期时，从第period根K线的时候才有ATR数据
    int lotion = mDataStartIndext - (period-1) < 0 ? 0 : mDataStartIndext - (period-1);
    minPrice = ATRs[lotion] ;
    maxPrice = ATRs[lotion] ;

    for (int i = lotion; i < mDataStartIndext + showNumber - (period-1); i++) {
      if(i < ATRs.length && i < TRs.length){
        minPrice = minPrice < ATRs[i] ? minPrice : ATRs[i];
        maxPrice = maxPrice > ATRs[i] ? maxPrice : ATRs[i];
        minPrice = minPrice < TRs[i] ? minPrice : TRs[i];
        maxPrice = maxPrice > TRs[i] ? maxPrice : TRs[i];
      }
    }
  }


  /**
   * 绘制ATR,价格线
   */
   void drawATR(Canvas canvas,double viewHeight, double viewWidth , int mDataStartIndext,int mShowDataNum,double mCandleWidth,int CANDLE_INTERVAL,
       double MARGINLEFT,double MARGINBOTTOM , double LOWER_CHART_TOP	, double mRightArea , int ATRPeriod){
    double lowerHight = viewHeight - LOWER_CHART_TOP - MARGINBOTTOM - DEFAULT_AXIS_TITLE_SIZE -10;//下表高度
    double rate = 0.0;//每单位像素价格
    Paint bluePaint = MethodUntil().getDrawPaint(Port.ATRColor);
    Paint blackPaint = MethodUntil().getDrawPaint(Port.TRColor);
    TextPainter textPaint =TextPainter(); // MethodUntil().getDrawPaint(Port.chartTxtColor);
    Paint dottedPaint = MethodUntil().getDrawPaint(Port.girdColor);//虚线画笔
    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    bluePaint.strokeWidth=Port.ATRWidth[0];
    blackPaint.strokeWidth=Port.ATRWidth[1];

    rate = lowerHight / (maxPrice - minPrice);
    double textBottom = DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = MARGINLEFT;

    int num = 4; //虚线数量
    double perPrice =  (maxPrice-minPrice)/(num+1);//计算每一格纬线框所占有的价格
    perPrice = perPrice==0 ? 1 : perPrice;
//		num =  ((maxPrice-minPrice) / perPrice) ;
//		double latitudeSpacing = lowerHight / (num+1);;//每格高度
     double price =  minPrice + perPrice;


    while (price <= maxPrice) {
      Path path =  Path(); // 绘制虚线
      path.moveTo(MARGINLEFT, viewHeight - MARGINBOTTOM - (price-minPrice)*rate);
      path.lineTo( viewWidth - MARGINLEFT-mRightArea,  viewHeight - MARGINBOTTOM - (price-minPrice)*rate);
      // canvas.drawPath(path, dottedPaint);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        dottedPaint,
      );
      // if (Port.drawFlag==1) {
      //   canvas.drawText(mUntil.getLimitNum(price, 0), viewWidth - MARGINLEFT-mRightArea,  (viewHeight - MARGINBOTTOM - (price-minPrice)*rate + DEFAULT_AXIS_TITLE_SIZE/2),
      //       textPaint);
      // }else{
        if (price < maxPrice) {
          // canvas.drawText(Utils.getLimitNum(price, 0), MARGINLEFT,  viewHeight - MARGINBOTTOM - (price-minPrice)*rate,
          //     textPaint);
          textPaint
            ..text = TextSpan(text: Utils.getLimitNum(price, 0), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
            ..textDirection = TextDirection.ltr
            ..layout()
            ..paint(canvas, Offset(MARGINLEFT, viewHeight - MARGINBOTTOM - (price-minPrice)*rate));
        }
      // }
      price += perPrice ;
    }



    //绘制cci
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum ; i++) {
      int number = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX =  (MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth);
      double nextX =  (MARGINLEFT + mCandleWidth * (number) + mCandleWidth);

      //从周期开始才绘制ATR
      if (i >= ATRPeriod-1) {
        //ATR线
        int nextNumber = (i - mDataStartIndext + 1) >=  mShowDataNum ? i - (ATRPeriod-1) : i - (ATRPeriod-1) + 1;
        if(nextNumber < ATRs.length && nextNumber < TRs.length){
          double AstartY =  (LOWER_CHART_TOP + (maxPrice - ATRs[i - (ATRPeriod-1)]) * rate + textBottom);
          double AstopY =  (LOWER_CHART_TOP + (maxPrice - ATRs[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, AstartY), Offset(nextX, AstopY), bluePaint);
          //TR
          double TstartY =  (LOWER_CHART_TOP + (maxPrice - TRs[i - (ATRPeriod-1)]) * rate + textBottom);
          double TstopY =  (LOWER_CHART_TOP + (maxPrice - TRs[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, TstartY), Offset(nextX, TstopY), blackPaint);
        }
      }

      //绘制当前周期，最新一根数据的ATR
      if (i == (mDataStartIndext + mShowDataNum - 1)) {
        String atr , tr;
        if ((mDataStartIndext + mShowDataNum) > ATRPeriod &&
            (i - (ATRPeriod-1)) < ATRs.length &&
            (i - (ATRPeriod-1)) < TRs.length ) {
          atr = Utils.getPointNum(ATRs[i - (ATRPeriod-1)]);
          tr = Utils.getPointNum(TRs[i - (ATRPeriod-1)]);
        }else{
          atr = "0.000";
          tr = "0.000";
        }

        String text = "ATR($ATRPeriod) ($tr , $atr)";
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text:text, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(MARGINLEFT, viewHeight - MARGINBOTTOM - (price-minPrice)*rate));
        textXStart = textXStart + ChartPainter.getStringWidth(text , textPaint) + 15;

        text = "TR: $tr";
        // textPaint.setColor(Port.TRColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(MARGINLEFT, viewHeight - MARGINBOTTOM - (price-minPrice)*rate));
        textXStart = textXStart + ChartPainter.getStringWidth(text , textPaint) + 15;

        text = "ATR: $atr";
        // textPaint.setColor(Port.ATRColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(MARGINLEFT, viewHeight - MARGINBOTTOM - (price-minPrice)*rate));
        textXStart = textXStart + ChartPainter.getStringWidth(text , textPaint) + 15;
      }
    }
  }
}
