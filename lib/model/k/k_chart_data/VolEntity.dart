import 'package:path_drawing/path_drawing.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

class VolEntity {
  /**
   * 数据集合
   */
  List<OHLCEntity> mVolList = [];
  /**
   * 最高价
   */
  num maxPrice = 0;
  /**
   * 最低价
   */
  num minPrice = 0;
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

  VolEntity() {
    //数据，短周期，长周期，周期，取值类型
    mVolList = [];
  }

  /**
   * 初始化数据
   *
   * @param OHLCData
   */
  void initData(List<OHLCEntity> OHLCData) {
    if (OHLCData == null || OHLCData.isEmpty) {
      return;
    }
    mVolList.clear();
    mVolList.addAll(OHLCData);
  }

  /**
   * 计算成交量线图的最高最低价
   */
  void calclatePrice(int mDataStartIndext, int showNumber) {
    if (mVolList.isEmpty) {
      return;
    }
    //当前绘制到的K线根数大于MACD长周期时，从第Lperiod根K线的时候才有diff数据
    int lotion = mDataStartIndext;
    minPrice = mVolList[lotion].volume ?? 0;
    maxPrice = mVolList[lotion].volume ?? 0;

    for (int i = lotion; i < mDataStartIndext + showNumber; i++) {
      if (i < mVolList.length) {
        minPrice = minPrice < (mVolList[i].volume ?? 0) ? minPrice : (mVolList[i].volume ?? 0);
        maxPrice = maxPrice > (mVolList[i].volume ?? 0) ? maxPrice : (mVolList[i].volume ?? 0);
      }
    }
  }

  /**
   * 绘制macd
   *
   * @param canvas
   */
  void drawVol(Canvas canvas, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL, double MARGINLEFT,
      double MARGINBOTTOM, double LOWER_CHART_TOP, double MID_CHART_TOP, double mRightArea) {
    if (mVolList.isEmpty) {
      return;
    }

    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
    double lowerHight = LOWER_CHART_TOP - MID_CHART_TOP - DEFAULT_AXIS_TITLE_SIZE - 10; //下表高度
    double textsize = DEFAULT_AXIS_TITLE_SIZE;
    Paint upPaint = MethodUntil().getDrawPaint(Port.VolUp_Color);
    Paint downPaint = MethodUntil().getDrawPaint(Port.VolDown_Color);
    Paint equalPaint = MethodUntil().getDrawPaint(Port.VolEqu_Color);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.chartTxtColor);
    // Paint textPaint = MethodUntil().getDrawPaint(Port.chartTxtColor);
    Paint girdPaint = MethodUntil().getDrawPaint(Port.girdColor);
    girdPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double rate = 0.0;
    //计算最高价，最低价
    rate = lowerHight / (maxPrice - 0);

    //绘制网格线
    Path path = Path(); // 绘制虚线
    double perPrice = (maxPrice - 0) / 4;

    for (int i = 1; i <= 3; i++) {
      double perheight = (perPrice * i) * rate;
      path.moveTo(MARGINLEFT, LOWER_CHART_TOP - perheight);
      path.lineTo(viewWidth - MARGINLEFT - mRightArea, LOWER_CHART_TOP - perheight);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        girdPaint,
      );
//            String price = mUntil.getPointNum(perPrice * i);
//            if (Port.drawFlag == 1) {
//                canvas.drawText(price, viewWidth - MARGINLEFT - mRightArea,
//                        LOWER_CHART_TOP - perheight + DEFAULT_AXIS_TITLE_SIZE / 2, textPaint);
//            } else {
//                canvas.drawText(price, MARGINLEFT, LOWER_CHART_TOP - perheight, textPaint);
//            }
    }

    //绘制成交量图
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      if (i >= mVolList.length) {
        return;
      }

      double startX = MARGINLEFT + mCandleWidth * (i - mDataStartIndext) + mCandleWidth;
      double left = startX - (mCandleWidth - CANDLE_INTERVAL) / 2;
      double right = startX + (mCandleWidth - CANDLE_INTERVAL) / 2;
      double top = LOWER_CHART_TOP - (mVolList[i].volume ?? 0) * rate;
      double bottom = LOWER_CHART_TOP;

      num open = mVolList[i].open ?? 0;
      num close = mVolList[i].close ?? 0;

      // 绘制矩形
      if (open < close) {
        //上涨
        upPaint.style = PaintingStyle.stroke;
        canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), upPaint);
      } else if (open == close) {
        //平
        canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), equalPaint);
      } else {
        //下跌
        canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), downPaint);
      }

      //绘制当前周期，最新一根数据的成交量
      if (i == mDataStartIndext + mShowDataNum - 1) {
        String volume = (mVolList[i].volume ?? 0).toString();
        String text = "VOL:$volume";
        Color tmp;
        if (open < close) {
          //上涨
          tmp = Port.VolUp_Color;
          // textPaint.setColor(Port.VolUp_Color);
        } else if (open == close) {
          //平
          tmp = Port.VolEqu_Color;
          // textPaint.setColor(Port.VolEqu_Color);
        } else {
          //下跌
          tmp = Port.VolDown_Color;
          // textPaint.setColor(Port.VolDown_Color);
        }

        // canvas.drawText(text, MARGINLEFT, MID_CHART_TOP + textsize/2, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: tmp, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(MARGINLEFT, MID_CHART_TOP + textsize / 2));
      }
    }

    for (int i = 1; i <= 3; i++) {
      double perheight = ((perPrice * i) * rate);
      String price = Utils.getPointNum(perPrice * i);
      // textPaint.setColor(Port.chartTxtColor);
      // if (Port.drawFlag == 1) {
      // canvas.drawText(price, viewWidth - MARGINLEFT - mRightArea,
      // LOWER_CHART_TOP - perheight + DEFAULT_AXIS_TITLE_SIZE / 2, textPaint);
      // } else {
      // canvas.drawText(price, MARGINLEFT, LOWER_CHART_TOP - perheight, textPaint);
      textPaint
        ..text = TextSpan(text: price, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(MARGINLEFT, LOWER_CHART_TOP - perheight));

      // }
    }
  }

  /**
   * 绘制分时图macd
   *
   * @param canvas
   */
  void drawFenshiVol(Canvas canvas, double viewHeight, double viewWidth, double mCandleWidth, double MARGINLEFT, double MARGINBOTTOM, double LOWER_CHART_TOP,
      double MARGINRIGHT) {
    if (mVolList.isEmpty) {
      return;
    }
    MARGINBOTTOM = 8;
    double lowerHight = viewHeight - LOWER_CHART_TOP - MARGINBOTTOM;
    double textsize = Port.ChartTextSize;
    Paint upPaint = MethodUntil().getDrawPaint(Port.VolUp_Color);
    Paint downPaint = MethodUntil().getDrawPaint(Port.VolDown_Color);
    Paint equalPaint = MethodUntil().getDrawPaint(Port.VolEqu_Color);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.foreGroundColor);
    Paint girdPaint = MethodUntil().getDrawPaint(Port.girdColor);
    // girdPaint.setPathEffect(DEFAULT_DASH_EFFECT);
    // girdPaint.setStyle(Style.STROKE);
    // girdPaint.setStrokeWidth(1); // 设置画笔大小
    girdPaint
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
    // textPaint.setTextSize(textsize);

//			double low = 0.0;
//			double high = 0.0;
    double rate = 0.0;
    //计算最高价，最低价
    rate = lowerHight / (maxPrice - 0);

    //绘制网格线
    Path path = Path(); // 绘制虚线
    double perPrice = (maxPrice - 0) / 4;

    for (int i = 1; i <= 3; i++) {
      double perheight = ((perPrice * i) * rate);
      path.moveTo(MARGINLEFT, viewHeight - perheight - MARGINBOTTOM);
      path.lineTo(viewWidth - MARGINRIGHT, viewHeight - perheight - MARGINBOTTOM);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        girdPaint,
      );

//			String price = mUntil.getPointNum(perPrice*i);
//            String price = (perPrice * i) + "";
//            if (Port.drawFlag == 1) {
//                canvas.drawText(price, viewWidth - MARGINRIGHT, viewHeight - perheight - MARGINBOTTOM + DEFAULT_AXIS_TITLE_SIZE / 2, textPaint);
//            } else {
//                canvas.drawText(price, MARGINLEFT, viewHeight - perheight - MARGINBOTTOM, textPaint);
//            }
    }

    //绘制成交量图
    int showNum = (viewWidth - MARGINLEFT - MARGINRIGHT) ~/ mCandleWidth;
    for (int i = 0; i < showNum && i < mVolList.length; i++) {
      double startX = (mCandleWidth * i + MARGINLEFT);
      double top = (viewHeight - (mVolList[i].volume ?? 0) * rate - MARGINBOTTOM);
      double bottom = viewHeight - MARGINBOTTOM;

      int loc = i == 0 ? 0 : i - 1;
      double pre = (mVolList[loc].close ?? 0).toDouble();
      double close = (mVolList[i].close ?? 0).toDouble();

      // 绘制矩形
      if (pre < close) {
        //上涨
        canvas.drawLine(Offset(startX, bottom), Offset(startX, top), upPaint);
      } else if (pre == close) {
        //平
        canvas.drawLine(Offset(startX, bottom), Offset(startX, top), equalPaint);
      } else {
        //下跌
        canvas.drawLine(Offset(startX, bottom), Offset(startX, top), downPaint);
      }

      //绘制当前周期，最新一根数据的成交量
      if (i == (mVolList.length - 1)) {
        String volume = (mVolList[i].volume ?? 0).toString();
        String text = "VOL: $volume";
        // canvas.drawText(text, MARGINLEFT, LOWER_CHART_TOP + textsize + 5, textPaint);
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.chartTxtColor, fontSize: textsize))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(MARGINLEFT, LOWER_CHART_TOP + textsize + 5));
      }
    }

    for (int i = 1; i <= 3; i++) {
      double perheight = ((perPrice * i) * rate);
      String price = (perPrice * i).toString();
      // if (Port.drawFlag == 1) {
      // canvas.drawText(price, viewWidth - MARGINRIGHT, viewHeight - perheight - MARGINBOTTOM + DEFAULT_AXIS_TITLE_SIZE / 2, textPaint);
      // } else {
      // canvas.drawText(price, MARGINLEFT, viewHeight - perheight - MARGINBOTTOM, textPaint);
      textPaint
        ..text = TextSpan(text: price, style: TextStyle(color: Port.chartTxtColor, fontSize: textsize))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(MARGINLEFT, viewHeight - perheight - MARGINBOTTOM));
      // }
    }
  }
}
