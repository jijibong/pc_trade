import 'package:path_drawing/path_drawing.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * TRIX三重指数指标线绘制，数据计算
 * @author hexuejian
 *
 */
class TRIXEntity {
  /**TRIX数据集合*/
  List<double> TRIXs = [];
  List<double> MATRIXs = [];
  /**TRIX最高价*/
  double maxPrice = 0.0;
  /**TRIX最低价*/
  double minPrice = 0.0;
  /** 默认字体大小 **/
  static double DEFAULT_AXIS_TITLE_SIZE = 22;
  /** 默认虚线效果 */
  List<double> DEFAULT_DASH_EFFECT = [2, 1];
  // static final PathEffect DEFAULT_DASH_EFFECT = new DashPathEffect(new double[] { 2, 3, 2,
  // 3 }, 1);
  /** 虚线颜色 */
  static const Color DEFAULT_DOTTED_COLOR = Colors.grey;
  /**增加数据类*/
  CalcIndexData mCalcData = CalcIndexData();

  TRIXEntity() {
    TRIXs = [];
    MATRIXs = [];
  }

  /**
   * 初始化TRIX数据
   * @param OHLCData
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int trPeriod, int matrixPeriod, int pri_type) {
    TRIXs.clear();
    MATRIXs.clear();

    if (OHLCData == null || OHLCData.isEmpty) {
      return;
    }

    mCalcData.calcTRIX_TR(OHLCData, trPeriod);

    /*double Tr1 = 0.0 , Tr2 = 0.0  , Tr3 = 0.0  ;
		double lastTr1 = 0.0 , lastTr2 = 0.0  , lastTr3 = 0.0  ;
		double trValue = 0.0 , lastValue=0.0;
		double trPara1=2.0f/(trPeriod+1);
		double trPara2=(trPeriod-1) / (trPeriod+1);
		//trix
		for (int i = trPeriod-1; i < OHLCData.length; i++) {
			double trix = 0.0;
			lastTr1 = Tr1;
			lastTr2 = Tr2;
			lastTr3 = Tr3;
			lastValue = trValue==0.0 ? OHLCData[i).getClose() : trValue;
			//一重指数
			if(i==trPeriod-1){
				Tr1 = OHLCData[i).getClose();
			}else{
				//EMA(X,N)=2*X/(N+1)+(N-1)/(N+1)*昨天的指数收盘平均值
				Tr1 = trPara1*OHLCData[i).getClose() + trPara2 * lastTr1 ;
			}

			//二重指数
			if(i<trPeriod){
				Tr2 = Tr1;
			}else{
				Tr2 = trPara1*Tr1 + trPara2*lastTr2;
			}

			//三重指数
			if(i<trPeriod){
				Tr3 = Tr2;
			}else{
				Tr3 = trPara1*Tr2 + trPara2*lastTr3;
			}

			trValue = trPara1*(trPara1*(trPara1*OHLCData[i).getClose() + trPara2*lastTr1) + trPara2*lastTr2) + trPara2*lastTr3;
			//trix:=(tr-ref(tr,1))/ref(tr,1)*100
			trix=(trValue - lastValue) / lastValue*100;
			TRIXs.add(trix);
		}


		for (int i = trPeriod+matrixPeriod-1; i < OHLCData.length; i++) {
			double trixSum = 0.0;
			double matrix = 0.0;
			for (int j = i-matrixPeriod+1; j <= i; j++) {
				trixSum+=(TRIXs[j-(trPeriod-1)) - TRIXs[(j-(trPeriod-1))-1)) / TRIXs[(j-(trPeriod-1))-1)*100;
			}
			matrix = trixSum / matrixPeriod;
			MATRIXs.add(matrix);
		}*/
    for (int i = trPeriod - 1; i < OHLCData.length; i++) {
      Map<String, double> value = mCalcData.calcTRIX(OHLCData, trPeriod, matrixPeriod, i);
      double trix = 0.0;
      double matrix = 0.0;
      if (value != null) {
        trix = value["TRIX"] ?? 0;
        matrix = value["MATRIX"] ?? 0;
      }
      TRIXs.add(trix);
      if (i >= trPeriod + matrixPeriod - 1) {
        MATRIXs.add(matrix);
      }
    }
  }

  /**
   * 获得Rsi价格
   */
  //  double getPrice(List<OHLCEntity> OHLCData , int j , int i , int period , int pri_type){
  //   double price= 0.0;
  //   switch (pri_type) {
  //
  //     case 0://开
  //       price = OHLCData[j + i - (period - 1)).getOpen()- OHLCData[j + i - (period - 1) - 1).getOpen();
  //       break;
  //
  //     case 1://高
  //       price = OHLCData[j + i - (period - 1)).getHigh()- OHLCData[j + i - (period - 1) - 1).getHigh();
  //       break;
  //
  //     case 2://收
  //       price = OHLCData[j + i - (period - 1)).getClose()- OHLCData[j + i - (period - 1) - 1).getClose();
  //       break;
  //
  //     case 3://低
  //       price = OHLCData[j + i - (period - 1)).getLow()- OHLCData[j + i - (period - 1) - 1).getLow();
  //       break;
  //
  //     case 4://高低一半
  //       price = (OHLCData[j + i - (period - 1)).getHigh()+OHLCData[j + i - (period - 1)).getLow()) / 2
  //           - (OHLCData[j + i - (period - 1) -1).getHigh()+OHLCData[j + i - (period - 1) -1).getLow()) / 2;
  //       break;
  //
  //     default:
  //       break;
  //   }
  //   return price;
  // }

  /**
   * 增加TRIX数据
   * @param OHLCData
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int trPeriod, int matrixPeriod, int pri_type, int count) {
    if (TRIXs.isEmpty || MATRIXs.isEmpty) {
      return;
    }

    Map<String, double> map = mCalcData.calcTRIX(OHLCData, trPeriod, matrixPeriod, OHLCData.length - 1);
    if (map == null) return;

    TRIXs.remove(TRIXs.length - 1);
    MATRIXs.remove(MATRIXs.length - 1);

    for (int i = count; i > 0; i--) {
      Map<String, double> value = mCalcData.calcTRIX(OHLCData, trPeriod, matrixPeriod, OHLCData.length - i);
      double trix = value["TRIX"] ?? 0;
      double matrix = value["MATRIX"] ?? 0;
      TRIXs.add(trix);
      MATRIXs.add(matrix);
    }
  }

  /**
   * 计算TRIX的最高最低价
   */
  void calclatePrice(int mDataStartIndext, int showNumber, int trPeriod, int matrixPeriod) {
    if (TRIXs.isEmpty || MATRIXs.isEmpty) {
      return;
    }
    //当前绘制到的K线根数大于kdj周期时，从第period根K线的时候才有kdj数据
    int lotion = mDataStartIndext - (trPeriod - 1) < 0 ? 0 : mDataStartIndext - (trPeriod - 1);
    minPrice = TRIXs[lotion];
    maxPrice = TRIXs[lotion];

    for (int i = lotion; i < mDataStartIndext + showNumber - (trPeriod - 1); i++) {
      if (i < TRIXs.length) {
        minPrice = minPrice < TRIXs[i] ? minPrice : TRIXs[i];
        maxPrice = maxPrice > TRIXs[i] ? maxPrice : TRIXs[i];
      }
    }

    lotion = mDataStartIndext - (trPeriod + matrixPeriod - 1) < 0 ? 0 : mDataStartIndext - (trPeriod + matrixPeriod - 1);
    for (int i = lotion; i < mDataStartIndext + showNumber - (trPeriod + matrixPeriod - 1); i++) {
      if (i < MATRIXs.length) {
        minPrice = minPrice < MATRIXs[i] ? minPrice : MATRIXs[i];
        maxPrice = maxPrice > MATRIXs[i] ? maxPrice : MATRIXs[i];
      }
    }
  }

  /**
   * 绘制TRIX,价格线
   */
  void drawTRIX(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL,
      double MARGINLEFT, double MARGINBOTTOM, double LOWER_CHART_TOP, double mRightArea, int TRIXPeriod, int TRIXMAPeriod) {
    double lowerHight = viewHeight - LOWER_CHART_TOP - MARGINBOTTOM - DEFAULT_AXIS_TITLE_SIZE - 10; //下表高度
    double latitudeSpacing = lowerHight / 6; //每格高度
    double rate = 0.0; //每单位像素价格
    Paint redPaint = MethodUntil().getDrawPaint(Port.TRIXColor);
    Paint yellowPaint = MethodUntil().getDrawPaint(Port.TRIXMAColor);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.chartTxtColor);
    Paint dottedPaint = MethodUntil().getDrawPaint(Port.girdColor); //虚线画笔
    // dottedPaint.setPathEffect(DEFAULT_DASH_EFFECT);
    // dottedPaint.setStyle(Style.STROKE);
    // dottedPaint.setStrokeWidth(1); // 设置画笔大小
    // redPaint.setStrokeWidth(Port.TRIXWidth[0]);
    // yellowPaint.setStrokeWidth(Port.TRIXWidth[1]);
    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    redPaint.strokeWidth = Port.TRIXWidth[0];
    yellowPaint.strokeWidth = Port.TRIXWidth[1];
    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;

    rate = lowerHight / (maxPrice - minPrice);
    double textBottom = DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = MARGINLEFT;

    //绘制虚线
    for (int i = 1; i <= 5; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(MARGINLEFT, LOWER_CHART_TOP + latitudeSpacing * i + textBottom);
      path.lineTo(viewWidth - MARGINLEFT - mRightArea, LOWER_CHART_TOP + latitudeSpacing * i + textBottom);
      // canvas.drawPath(path, dottedPaint);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        dottedPaint,
      );
    }

    //绘制价格
    double perPrice = (maxPrice - minPrice) / (5 + 1); //计算每一格纬线框所占有的价格
    for (int i = 1; i <= 5; i++) {
      // if (Port.drawFlag==1) {
      //   canvas.drawText(mUntil.getPointNum(minPrice+perPrice*i), viewWidth - MARGINLEFT-mRightArea,
      //       viewHeight - MARGINBOTTOM - latitudeSpacing*i + DEFAULT_AXIS_TITLE_SIZE/2,
      //       textPaint);
      // }else{
      //   canvas.drawText(Utils.getPointNum(minPrice+perPrice*i), MARGINLEFT,
      //       viewHeight - MARGINBOTTOM - latitudeSpacing*i,
      //       textPaint);
      textPaint
        ..text = TextSpan(text: Utils.getPointNum(minPrice + perPrice * i), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(MARGINLEFT, viewHeight - MARGINBOTTOM - latitudeSpacing * i));
      // }
    }

    //绘制KDJ
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double nextX = MARGINLEFT + mCandleWidth * (number) + mCandleWidth;

      //从周期开始才绘制TRIX
      if (i >= TRIXPeriod - 1) {
        //K线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (TRIXPeriod - 1) : i - (TRIXPeriod - 1) + 1;
        if (nextNumber < TRIXs.length) {
          double startY = LOWER_CHART_TOP + (maxPrice - TRIXs[i - (TRIXPeriod - 1)]) * rate + textBottom;
          double stopY = LOWER_CHART_TOP + (maxPrice - TRIXs[nextNumber]) * rate + textBottom;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), redPaint);
        }
      }

      if (i >= TRIXPeriod + TRIXMAPeriod - 1) {
        //K线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (TRIXPeriod + TRIXMAPeriod - 1) : i - (TRIXPeriod + TRIXMAPeriod - 1) + 1;
        if (nextNumber < MATRIXs.length) {
          double startY = (LOWER_CHART_TOP + (maxPrice - MATRIXs[i - (TRIXPeriod + TRIXMAPeriod - 1)]) * rate + textBottom);
          double stopY = (LOWER_CHART_TOP + (maxPrice - MATRIXs[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), yellowPaint);
        }
      }

      //绘制当前周期，最新一根数据的TRIX
      if (i == (mDataStartIndext + mShowDataNum - 1)) {
        String TRIX, MATRIX;
        if ((mDataStartIndext + mShowDataNum) > TRIXPeriod && (i - (TRIXPeriod - 1)) < TRIXs.length) {
          TRIX = Utils.getPointNum(TRIXs[i - (TRIXPeriod - 1)]);
        } else {
          TRIX = "0.000";
        }

        if ((mDataStartIndext + mShowDataNum) > TRIXPeriod + TRIXMAPeriod && (i - (TRIXPeriod + TRIXMAPeriod - 1)) < MATRIXs.length) {
          MATRIX = Utils.getPointNum(MATRIXs[i - (TRIXPeriod + TRIXMAPeriod - 1)]);
        } else {
          MATRIX = "0.000";
        }

        String text = "TRIX($TRIXPeriod , $TRIXMAPeriod)";
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart,  LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "TRIX: $TRIX";
        // textPaint.setColor(Port.TRIXColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.TRIXColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart,  LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "MATRIX: $MATRIX";
        // textPaint.setColor(Port.TRIXMAColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.TRIXMAColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart,  LOWER_CHART_TOP+DEFAULT_AXIS_TITLE_SIZE+5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;
      }
    }
  }
}
