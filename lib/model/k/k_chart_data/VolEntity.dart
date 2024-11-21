import 'dart:math';

import 'package:path_drawing/path_drawing.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:trade/util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/painter/k_chart/sub_chart_painter.dart';
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
  static double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
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

  /// 绘制Vol
  void drawVol(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL,
      double leftMarginSpace, double halfTextHeight) {
    if (mVolList.isEmpty) {
      return;
    }
    double lowerHight = viewHeight - Port.defult_margin_top - halfTextHeight * 2;
    Paint upPaint = MethodUntil().getDrawPaint(Port.VolUp_Color);
    Paint downPaint = MethodUntil().getDrawPaint(Port.VolDown_Color);
    Paint equalPaint = MethodUntil().getDrawPaint(Port.VolEqu_Color);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.chartTxtColor);
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

    double perHeight = perPrice * 2 * rate;
    path.moveTo(leftMarginSpace, viewHeight - perHeight);
    path.lineTo(viewWidth - leftMarginSpace, viewHeight - perHeight);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
      ),
      girdPaint,
    );

    String price = Utils.getLimitNum(perPrice * 2, 0);
    double priceWidth = SubChartPainter.getStringWidth("$price ", textPaint);
    textPaint
      ..text = TextSpan(text: price, style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(leftMarginSpace - priceWidth, viewHeight - perHeight - halfTextHeight));

    //绘制成交量图
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      if (i >= mVolList.length) {
        return;
      }

      double startX = mCandleWidth * (i - mDataStartIndext) + mCandleWidth + leftMarginSpace;
      double left = startX - max((mCandleWidth - CANDLE_INTERVAL) / 2, 0.5);
      double right = startX + max((mCandleWidth - CANDLE_INTERVAL) / 2, 0.5);
      double top = viewHeight - (mVolList[i].volume ?? 0) * rate;
      double bottom = viewHeight;

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
        } else if (open == close) {
          //平
          tmp = Port.VolEqu_Color;
        } else {
          //下跌
          tmp = Port.VolDown_Color;
        }
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: tmp, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(Port.defult_icon_width + leftMarginSpace, Port.text_check));
      }
    }
  }

  ///绘制分时图vol
  void drawFenshiVol(Canvas canvas, double viewHeight, double viewWidth, double mCandleWidth, double MARGINLEFT, double leftMarginSpace,
      double rightMarginSpace, double MARGINBOTTOM, double LOWER_CHART_TOP, double MARGINRIGHT, double halfTextHeight) {
    if (mVolList.isEmpty) {
      return;
    }
    double lowerHight = viewHeight - LOWER_CHART_TOP - MARGINBOTTOM;
    Paint upPaint = MethodUntil().getDrawPaint(Port.VolUp_Color);
    Paint downPaint = MethodUntil().getDrawPaint(Port.VolDown_Color);
    Paint equalPaint = MethodUntil().getDrawPaint(Port.VolEqu_Color);
    TextPainter textPaint = TextPainter();
    Paint girdPaint = MethodUntil().getDrawPaint(Port.girdColor);
    girdPaint
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double rate = 0.0;
    //计算最高价，最低价
    rate = lowerHight / (maxPrice - 0);

    //绘制网格线
    Path path = Path(); // 绘制虚线
    double perPrice = (maxPrice - 0) / 3;

    for (int i = 1; i <= 2; i++) {
      double perheight = (perPrice * i) * rate;
      path.moveTo(MARGINLEFT + leftMarginSpace, viewHeight - perheight - MARGINBOTTOM);
      path.lineTo(viewWidth - MARGINRIGHT - rightMarginSpace, viewHeight - perheight - MARGINBOTTOM);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        girdPaint,
      );
    }

    //绘制成交量图
    int showNum = (viewWidth - MARGINLEFT - MARGINRIGHT) ~/ mCandleWidth;
    for (int i = 0; i < showNum && i < mVolList.length; i++) {
      double startX = (mCandleWidth * i + MARGINLEFT + leftMarginSpace);
      double top = viewHeight - (mVolList[i].volume ?? 0) * rate - MARGINBOTTOM;
      double bottom = viewHeight - MARGINBOTTOM;

      int loc = i == 0 ? 0 : i - 1;
      double pre = (mVolList[loc].close ?? 0).toDouble();
      double close = (mVolList[i].close ?? 0).toDouble();

      if (pre < close) {
        canvas.drawLine(Offset(startX, bottom), Offset(startX, top), upPaint);
      } else if (pre == close) {
        canvas.drawLine(Offset(startX, bottom), Offset(startX, top), equalPaint);
      } else {
        canvas.drawLine(Offset(startX, bottom), Offset(startX, top), downPaint);
      }
      //绘制当前周期，最新一根数据的成交量
      if (i == mVolList.length - 1) {
        String text = "成交量";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.cursorYellowColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(MARGINLEFT, LOWER_CHART_TOP));
      }
    }

    for (int i = 1; i <= 2; i++) {
      double perheight = (perPrice * i) * rate;
      String price = (perPrice * i).toInt().toString();
      double length = ChartPainter.getStringWidth(price, textPaint, size: DEFAULT_AXIS_TITLE_SIZE);
      textPaint
        ..text = TextSpan(text: price, style: TextStyle(color: Port.cursorYellowColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(leftMarginSpace - length, viewHeight - perheight - MARGINBOTTOM - halfTextHeight));
    }
  }
}
