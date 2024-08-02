import 'package:path_drawing/path_drawing.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * RSI指标线绘制，数据计算
 *
 * @author hexuejian
 */
class KDJEntity {
  /**
   * RSI数据集合
   */
  List<double> Ks = [];
  List<double> Ds = [];
  List<double> Js = [];
  /**
   * RSI最高价
   */
  double maxPrice = 0.0;
  /**
   * RSI最低价
   */
  double minPrice = 0.0;
  /**
   * 默认字体大小
   **/
  static double DEFAULT_AXIS_TITLE_SIZE = 22;
  /**
   * 默认虚线效果
   */
  List<double> DEFAULT_DASH_EFFECT = [2, 1];
  // static final PathEffect DEFAULT_DASH_EFFECT = new DashPathEffect(new double[]{2, 3, 2,
  // 3}, 1);
  /**
   * 虚线颜色
   */
  static const Color DEFAULT_DOTTED_COLOR = Colors.grey;
  /**
   * 增加数据类
   */
  CalcIndexData mCalcData = CalcIndexData();

  KDJEntity() {
    Ks = [];
    Ds = [];
    Js = [];
  }

  /**
   * 初始化RSI数据
   *
   * @param OHLCData
   * @param period
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int period, int pri_type, int m1, int m2) {
    Ks.clear();
    Ds.clear();
    Js.clear();

    if (OHLCData == null || OHLCData.isEmpty) {
      return;
    }

    double k = 50.0, d = 50.0, j = 0.0;
    m1 = m1 > 1 ? m1 : 2;
    for (int i = period - 1; i < OHLCData.length; i++) {
      //K:=SMA(RSV,M1,1)=(1*RSV+(M1-1)*K')/M1=RSV/M1+(M1-1)/M1*K';K1是上个周期的K值,若前一周期无K值,以50代替;M1>1是必要条件
      double hh = 0, ll = 0, Rsv = 0;
      hh = mCalcData.calcHighest(OHLCData, period, i);
      ll = mCalcData.calcLowest(OHLCData, period, i);
      if ((hh - ll) == 0) {
        Rsv = 0;
      } else {
        Rsv = ((OHLCData[i].close ?? 0) - ll) / (hh - ll) * 100;
      }
      k = Rsv / m1 + (m1 - 1) / m1 * k;

      //D:=SMA(K,M2,1)=K/M2+(M2-1)/M2*D';M2>1
      d = k / m2 + (m2 - 1) / m2 * d;

      //J:=3*K-2*D
      j = 3 * k - 2 * d;
      Ks.add(k);
      Ds.add(d);
      Js.add(j);
    }
  }

  /**
   * 获得Rsi价格
   */
  double getPrice(List<OHLCEntity> OHLCData, int j, int i, int period, int pri_type) {
    num price = 0.0;
    switch (pri_type) {
      case 0: //开
        price = (OHLCData[j + i - (period - 1)].open ?? 0) - (OHLCData[j + i - period].open ?? 0);
        break;

      case 1: //高
        price = (OHLCData[j + i - (period - 1)].high ?? 0) - (OHLCData[j + i - period].high ?? 0);
        break;

      case 2: //收
        price = (OHLCData[j + i - (period - 1)].close ?? 0) - (OHLCData[j + i - period].close ?? 0);
        break;

      case 3: //低
        price = (OHLCData[j + i - (period - 1)].low ?? 0) - (OHLCData[j + i - period].low ?? 0);
        break;

      case 4: //高低一半
        price = ((OHLCData[j + i - (period - 1)].high ?? 0) + (OHLCData[j + i - (period - 1)].low ?? 0)) / 2 -
            ((OHLCData[j + i - (period - 1) - 1].high ?? 0) + (OHLCData[j + i - (period - 1) - 1].low ?? 0)) / 2;
        break;

      default:
        break;
    }
    return price.toDouble();
  }

  /**
   * 增加KDJ数据
   *
   * @param OHLCData
   * @param period
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int period, int pri_type, int count, int m1, int m2) {
    if (Ks.isEmpty || Ds.isEmpty || Js.isEmpty) {
      return;
    }

    Map<String, double> map = mCalcData.calcKDJ(OHLCData, period, OHLCData.length - 1, m1, m2);
    if (map == null) return;

    Ks.remove(Ks.length - 1);
    Ds.remove(Ds.length - 1);
    Js.remove(Js.length - 1);

    for (int i = count; i > 0; i--) {
      Map<String, double> value = mCalcData.calcKDJ(OHLCData, period, OHLCData.length - i, m1, m2);
      double k = value["K"] ?? 0;
      double d = value["D"] ?? 0;
      double j = value["J"] ?? 0;
      Ks.add(k);
      Ds.add(d);
      Js.add(j);
    }
  }

  /**
   * 计算KDJ的最高最低价
   */
  void calclatePrice(int mDataStartIndext, int showNumber, int period) {
    if (Ks.isEmpty || Ds.isEmpty || Js.isEmpty) {
      return;
    }
    //当前绘制到的K线根数大于kdj周期时，从第period根K线的时候才有kdj数据
    int lotion = mDataStartIndext - (period - 1) < 0 ? 0 : mDataStartIndext - (period - 1);
    minPrice = Ks[lotion];
    maxPrice = Ks[lotion];

    for (int i = lotion; i < mDataStartIndext + showNumber - (period - 1); i++) {
      if (i < Ks.length && i < Ds.length && i < Js.length) {
        minPrice = minPrice < Ks[i] ? minPrice : Ks[i];
        maxPrice = maxPrice > Ks[i] ? maxPrice : Ks[i];
        minPrice = minPrice < Ds[i] ? minPrice : Ds[i];
        maxPrice = maxPrice > Ds[i] ? maxPrice : Ds[i];
        minPrice = minPrice < Js[i] ? minPrice : Js[i];
        maxPrice = maxPrice > Js[i] ? maxPrice : Js[i];
      }
    }
  }

  /**
   * 绘制KDJ,价格线
   */
  void drawKDJ(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL,
      double MARGINLEFT, double MARGINBOTTOM, double LOWER_CHART_TOP, double mRightArea, int KDJPeriod, int KDJ_M1, int KDJ_M2) {
    double lowerHight = viewHeight - LOWER_CHART_TOP - MARGINBOTTOM - DEFAULT_AXIS_TITLE_SIZE - 10; //下表高度
    double latitudeSpacing = lowerHight / 6; //每格高度
    double rate = 0.0; //每单位像素价格
    Paint yellowPaint = MethodUntil().getDrawPaint(Port.KDJ_KColor);
    Paint purplePaint = MethodUntil().getDrawPaint(Port.KDJ_DColor);
    Paint greenPaint = MethodUntil().getDrawPaint(Port.KDJ_JColor);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.chartTxtColor);
    Paint dottedPaint = MethodUntil().getDrawPaint(Port.girdColor); //虚线画笔
    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    yellowPaint.strokeWidth = Port.KDJWidth[0];
    purplePaint.strokeWidth = Port.KDJWidth[1];
    greenPaint.strokeWidth = Port.KDJWidth[2];
    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
    // textPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);

    rate = lowerHight / (maxPrice - minPrice);
    double textBottom = DEFAULT_AXIS_TITLE_SIZE + 10;

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
      // if (Port.drawFlag == 1) {
      // canvas.drawText(Utils.getPointNum(minPrice + perPrice * i), viewWidth - MARGINLEFT - mRightArea,
      //     viewHeight - MARGINBOTTOM - latitudeSpacing * i + DEFAULT_AXIS_TITLE_SIZE / 2 + textBottom,
      //     textPaint);
      //
      //   textPaint
      //     ..text = TextSpan(text: Utils.getPointNum(minPrice + perPrice * i), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      //     ..textDirection = TextDirection.ltr
      //     ..layout()
      //     ..paint(
      //         canvas, Offset(viewWidth - MARGINLEFT - mRightArea, viewHeight - MARGINBOTTOM - latitudeSpacing * i + DEFAULT_AXIS_TITLE_SIZE / 2 + textBottom));
      // } else {
      //   canvas.drawText(Utils.getPointNum(minPrice + perPrice * i), MARGINLEFT, viewHeight - MARGINBOTTOM - latitudeSpacing * i + textBottom, textPaint);
      textPaint
        ..text = TextSpan(text: Utils.getPointNum(minPrice + perPrice * i), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(MARGINLEFT, viewHeight - MARGINBOTTOM - latitudeSpacing * i + textBottom));
      // }
    }

    //绘制KDJ
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = (MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth);
      double nextX = (MARGINLEFT + mCandleWidth * (number) + mCandleWidth);

      //从周期开始才绘制KDJ
      if (i >= KDJPeriod - 1) {
        //K线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (KDJPeriod - 1) : i - (KDJPeriod - 1) + 1;
        if (nextNumber < Ks.length && nextNumber < Ds.length && nextNumber < Js.length) {
          double KstartY = (LOWER_CHART_TOP + (maxPrice - Ks[i - (KDJPeriod - 1)]) * rate + textBottom);
          double KstopY = (LOWER_CHART_TOP + (maxPrice - Ks[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, KstartY), Offset(nextX, KstopY), yellowPaint);
          //D线
          double DstartY = (LOWER_CHART_TOP + (maxPrice - Ds[i - (KDJPeriod - 1)]) * rate + textBottom);
          double DstopY = (LOWER_CHART_TOP + (maxPrice - Ds[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, DstartY), Offset(nextX, DstopY), purplePaint);
          //J线
          double JstartY = (LOWER_CHART_TOP + (maxPrice - Js[i - (KDJPeriod - 1)]) * rate + textBottom);
          double JstopY = (LOWER_CHART_TOP + (maxPrice - Js[nextNumber]) * rate + textBottom);
          canvas.drawLine(Offset(startX, JstartY), Offset(nextX, JstopY), greenPaint);
        }
      }

      //绘制当前周期，最新一根数据的KDJ
      if (i == (mDataStartIndext + mShowDataNum - 1)) {
        String K, D, J;
        if ((mDataStartIndext + mShowDataNum) > KDJPeriod &&
            (i - (KDJPeriod - 1)) < Ks.length &&
            (i - (KDJPeriod - 1)) < Ds.length &&
            (i - (KDJPeriod - 1)) < Js.length) {
          K = Utils.getPointNum(Ks[i - (KDJPeriod - 1)]);
          D = Utils.getPointNum(Ds[i - (KDJPeriod - 1)]);
          J = Utils.getPointNum(Js[i - (KDJPeriod - 1)]);
        } else {
          K = "0.000";
          D = "0.000";
          J = "0.000";
        }

        double textXStart = MARGINLEFT;
        String text = "KDJ($KDJPeriod , $KDJ_M1 , $KDJ_M2)";
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "K:$K";
        // textPaint.setColor(Port.KDJ_KColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.KDJ_KColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "D:$D";
        // textPaint.setColor(Port.KDJ_DColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.KDJ_DColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;

        text = "J:$J";
        // textPaint.setColor(Port.KDJ_JColor);
        // canvas.drawText(text, textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.KDJ_JColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(textXStart, LOWER_CHART_TOP + DEFAULT_AXIS_TITLE_SIZE + 5));
        textXStart = textXStart + ChartPainter.getStringWidth(text, textPaint) + 15;
      }
    }
  }
}
