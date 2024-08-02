import 'package:fluent_ui/fluent_ui.dart';
import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * MIKE指标线绘制，数据计算
 * @author hexuejian
 *
 */
class MIKEEntity {
  /**MIKE数据集合*/
  List<double> WR = [];
  /**MIKE数据集合*/
  List<double> MR = [];
  /**MIKE数据集合*/
  List<double> SR = [];
  /**MIKE数据集合*/
  List<double> WS = [];
  /**MIKE数据集合*/
  List<double> MS = [];
  /**MIKE数据集合*/
  List<double> SS = [];
  /** 默认字体大小 **/
  static double DEFAULT_AXIS_TITLE_SIZE = 22;
  /**增加数据类*/
  CalcIndexData mCalcData = CalcIndexData();

  MIKEEntity() {
    WR = [];
    MR = [];
    SR = [];
    WS = [];
    MS = [];
    SS = [];
  }

  /**
   * 初始化Bollinger数据
   * @param OHLCData
   * @param period
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int period, int pri_type) {
    WR.clear();
    MR.clear();
    SR.clear();
    WS.clear();
    MS.clear();
    SS.clear();

    if (OHLCData == null || OHLCData.isEmpty) {
      return;
    }

    for (int i = period - 1; i < OHLCData.length; i++) {
      double wr = 0.0, mr = 0.0, sr = 0.0, ws = 0.0, ms = 0.0, ss = 0.0;
      Map<String, double> value = mCalcData.calcMIKE(OHLCData, period, i);
      wr = value["WR"] ?? 0;
      mr = value["MR"] ?? 0;
      sr = value["SR"] ?? 0;
      ws = value["WS"] ?? 0;
      ms = value["MS"] ?? 0;
      ss = value["SS"] ?? 0;

      WR.add(wr);
      MR.add(mr);
      SR.add(sr);
      WS.add(ws);
      MS.add(ms);
      SS.add(ss);
    }
  }

  /**
   * 获得Bollinger价格
   */
  //  double getPrice(List<OHLCEntity> OHLCData , int i , int pri_type){
  //   double price= 0.0;
  //   switch (pri_type) {
  //
  //     case 0://开
  //       price = OHLCData.get(i).getOpen();
  //       break;
  //
  //     case 1://高
  //       price = OHLCData.get(i).getHigh();
  //       break;
  //
  //     case 2://收
  //       price = OHLCData.get(i).getClose();
  //       break;
  //
  //     case 3://低
  //       price = OHLCData.get(i).getLow();
  //       break;
  //
  //     case 4://高低一半
  //       price = (OHLCData.get(i).getHigh()+OHLCData.get(i).getLow()) / 2;
  //       break;
  //
  //     default:
  //       break;
  //   }
  //   return price;
  // }

  /**
   * 增加布林带数据
   * @param OHLCData
   * @param period
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int period, int pri_type, int count) {
    if (WR.isEmpty || MR.isEmpty || SR.isEmpty || WS.isEmpty || MS.isEmpty || SS.isEmpty) {
      return;
    }
    Map<String, double> map = mCalcData.calcMIKE(OHLCData, period, OHLCData.length - 1);
    if (map == null) return;

    WR.remove(WR.length - 1);
    MR.remove(MR.length - 1);
    SR.remove(SR.length - 1);
    WS.remove(WS.length - 1);
    MS.remove(MS.length - 1);
    SS.remove(SS.length - 1);

    for (int i = count; i > 0; i--) {
      double wr = 0.0, mr = 0.0, sr = 0.0, ws = 0.0, ms = 0.0, ss = 0.0;
      Map<String, double> value = mCalcData.calcMIKE(OHLCData, period, OHLCData.length - i);
      wr = value["WR"] ?? 0;
      mr = value["MR"] ?? 0;
      sr = value["SR"] ?? 0;
      ws = value["WS"] ?? 0;
      ms = value["MS"] ?? 0;
      ss = value["SS"] ?? 0;

      WR.add(wr);
      MR.add(mr);
      SR.add(sr);
      WS.add(ws);
      MS.add(ms);
      SS.add(ss);
    }
  }

  /**
   * 绘制布林线
   */
  void drawMIKE(Canvas canvas, int mDataStartIndext, int mShowDataNum, double mCandleWidth, double mMaxPrice, double mMinPrice, int CANDLE_INTERVAL,
      double MARGINLEFT, double MARGINTOP, double uperChartHeight, int MikePeriod) {
    double rate = 0.0; //每单位像素价格
    Paint WRPaint = MethodUntil().getDrawPaint(Port.MIKE_WRColor);
    Paint MRPaint = MethodUntil().getDrawPaint(Port.MIKE_MRColor);
    Paint SRPaint = MethodUntil().getDrawPaint(Port.MIKE_SRColor);
    Paint WSPaint = MethodUntil().getDrawPaint(Port.MIKE_WSColor);
    Paint MSPaint = MethodUntil().getDrawPaint(Port.MIKE_MSColor);
    Paint SSPaint = MethodUntil().getDrawPaint(Port.MIKE_SSColor);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.foreGroundColor);
    // Paint textPaint = MethodUntil().getDrawPaint(Port.foreGroundColor);
    WRPaint.strokeWidth = Port.MIKEWidth[0];
    MRPaint.strokeWidth = Port.MIKEWidth[1];
    SRPaint.strokeWidth = Port.MIKEWidth[2];
    WSPaint.strokeWidth = Port.MIKEWidth[3];
    MSPaint.strokeWidth = Port.MIKEWidth[4];
    SSPaint.strokeWidth = Port.MIKEWidth[5];
    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
    // textPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);

    // Paint mPaint = Paint()
    //   ..color = Colors.red
    //   ..isAntiAlias = true;

    rate = (uperChartHeight - DEFAULT_AXIS_TITLE_SIZE - 10) / (mMaxPrice - mMinPrice); //计算最小单位
    double textBottom = MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 10;
    double textXStart = MARGINLEFT;

    //绘制MIKE
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double nextX = MARGINLEFT + mCandleWidth * number + mCandleWidth;

      //从周期开始才绘制MIKE
      if (i >= MikePeriod - 1) {
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (MikePeriod - 1) : i - (MikePeriod - 1) + 1;
        if (nextNumber >= WR.length) return;
        //绘制WR线
        double startY = (mMaxPrice - WR[i - (MikePeriod - 1)]) * rate + textBottom;
        double stopY = (mMaxPrice - WR[nextNumber]) * rate + textBottom;
        canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), WRPaint);
        //绘制MR线
        double mStartY = (mMaxPrice - MR[i - (MikePeriod - 1)]) * rate + textBottom;
        double mStopY = (mMaxPrice - MR[nextNumber]) * rate + textBottom;
        canvas.drawLine(Offset(startX, mStartY), Offset(nextX, mStopY), MRPaint);
        //绘制SR线
        double dStartY = (mMaxPrice - SR[i - (MikePeriod - 1)]) * rate + textBottom;
        double dStopY = (mMaxPrice - SR[nextNumber]) * rate + textBottom;
        canvas.drawLine(Offset(startX, dStartY), Offset(nextX, dStopY), SRPaint);

        //绘制WS线
        double wsStartY = (mMaxPrice - WS[i - (MikePeriod - 1)]) * rate + textBottom;
        double wsStopY = (mMaxPrice - WS[nextNumber]) * rate + textBottom;
        canvas.drawLine(Offset(startX, wsStartY), Offset(nextX, wsStopY), WSPaint);

        //绘制MS线
        double msStartY = (mMaxPrice - MS[i - (MikePeriod - 1)]) * rate + textBottom;
        double msStopY = (mMaxPrice - MS[nextNumber]) * rate + textBottom;
        canvas.drawLine(Offset(startX, msStartY), Offset(nextX, msStopY), MSPaint);

        //绘制SS线
        double ssStartY = (mMaxPrice - SS[i - (MikePeriod - 1)]) * rate + textBottom;
        double ssStopY = (mMaxPrice - SS[nextNumber]) * rate + textBottom;
        canvas.drawLine(Offset(startX, ssStartY), Offset(nextX, ssStopY), SSPaint);
      }

      //绘制当前周期，最新一根数据的up,down,middle
      if (i == (mDataStartIndext + mShowDataNum - 1)) {
        String wr, mr, sr, ws, ms, ss;
        if ((mDataStartIndext + mShowDataNum) > MikePeriod &&
            (i - (MikePeriod - 1)) < WR.length &&
            (i - (MikePeriod - 1)) < MR.length &&
            (i - (MikePeriod - 1)) < SR.length &&
            (i - (MikePeriod - 1)) < WS.length &&
            (i - (MikePeriod - 1)) < MS.length &&
            (i - (MikePeriod - 1)) < SS.length) {
          wr = Utils.getPointNum(WR[i - (MikePeriod - 1)]);
          mr = Utils.getPointNum(MR[i - (MikePeriod - 1)]);
          sr = Utils.getPointNum(SR[i - (MikePeriod - 1)]);
          ws = Utils.getPointNum(WS[i - (MikePeriod - 1)]);
          ms = Utils.getPointNum(MS[i - (MikePeriod - 1)]);
          ss = Utils.getPointNum(SS[i - (MikePeriod - 1)]);
        } else {
          wr = "0.000";
          mr = "0.000";
          sr = "0.000";
          ws = "0.000";
          ms = "0.000";
          ss = "0.000";
        }

        String text = "MIKE($MikePeriod)";
        // canvas.drawText(text, textXStart, MARGINTOP+DEFAULT_AXIS_TITLE_SIZE+5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.foreGroundColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "WR:$wr";
        // textPaint.setColor(Port.MIKE_WRColor);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.MIKE_WRColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "MR:$mr";
        // textPaint.setColor(Port.MIKE_MRColor);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.MIKE_MRColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "SR:$sr";
        // textPaint.setColor(Port.MIKE_SRColor);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.MIKE_SRColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "WS:$ws";
        // textPaint.setColor(Port.MIKE_WSColor);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.MIKE_WSColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "MS:$ms";
        // textPaint.setColor(Port.MIKE_MSColor);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.MIKE_MSColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "SS:$ss";
        // textPaint.setColor(Port.MIKE_SSColor);
        // canvas.drawText(text, textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.MIKE_SSColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, MARGINTOP + DEFAULT_AXIS_TITLE_SIZE + 5));
      }
    }
  }
}
