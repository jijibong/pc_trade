import 'package:flutter/material.dart';
import 'package:trade/util/painter/k_chart/base_k_chart_painter.dart';

import '../../../model/k/OHLCEntity.dart';
import '../../../model/k/k_flag.dart';
import '../../../model/k/k_preiod.dart';
import '../../../model/k/port.dart';
import '../../utils/utils.dart';
import 'k_chart_painter.dart';
import 'method_util.dart';

class CrossLineView extends CustomPainter {
  Paint customPaint = Paint();
  Paint redPaint = Paint();
  TextPainter textPaint = TextPainter();
  /** 默认XY轴字体大小 **/
  double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  static const Color whiteColor = Color.fromRGBO(255, 255, 255, 1);
  static const Color orangeColor = Color.fromRGBO(255, 126, 0, 1);
  static const Color redColor = Color.fromRGBO(255, 32, 74, 1);
  static const Color greenColor = Color.fromRGBO(58, 255, 32, 1);
  /**当前横坐标*/
  double currentX = 0;
  /**当前纵坐标*/
  double currentY = 0;
  /**view高度*/
  int? VIEW_HEIGHT;
  /**view宽度*/
  int? VIEW_WIDTH;
  /**绘图view*/
  late ChartPainter mKChartsView;
  /**当前竖线的日期*/
  String? dateV = "";
  /**当前横线的价格*/
  double? priceH = 0;
  double crossLineViewHeight = 0;
  bool isDrawTime = true;

  CrossLineView(ChartPainter mView, {required bool isDrawTime}) {
    mKChartsView = mView;
    // setBackgroundColor(Colors.transparent);//设置背景透明
    //设置画笔的颜色
    customPaint = Paint();
    customPaint.color = Colors.red;
    redPaint = MethodUntil().getDrawPaint(const Color.fromRGBO(255, 255, 255, 1));
    textPaint = MethodUntil().getTextPainter(DEFAULT_AXIS_TITLE_SIZE);
    // redPaint.setTextSize(DEFAULT_AXIS_TITLE_SIZE);
    //设置画笔的风格
    customPaint.style = PaintingStyle.stroke;
    customPaint.strokeWidth = 1;
    customPaint.isAntiAlias = true;
    // paint.setDither(true);
    //初始化十字线初始坐标
    currentX = 0.0;
    currentY = 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    crossLineViewHeight = size.height;
    int number = getNumber(currentX.toInt(), BaseKChartPainter.MARGINLEFT, mKChartsView.mCandleWidth, mKChartsView.mShowDataNum, isDrawTime);
//		Log.i("", "第"+number+" 根K线");
    currentX = BaseKChartPainter.MARGINLEFT + number * mKChartsView.mCandleWidth;
    currentY = dealY(currentY, ChartPainter.kChartViewHeight, mKChartsView.MARGINBOTTOM, mKChartsView.MARGINTOP);

    priceH = getPrice(currentY);
    priceH = priceH ?? 0;
    String price = Utils.getPointNum(priceH!);
    int index = mKChartsView.mDataStartIndext + number - 1;
    String date = "";
    if (mKChartsView.getOHLCData().isNotEmpty && index < mKChartsView.getOHLCData().length) {
      date = "${mKChartsView.getOHLCData()[index].date} ${mKChartsView.getOHLCData()[index].time}";
    } else {
      date = "00:00:00";
    }
    dateV = date;

    //画竖线
    canvas.drawLine(Offset(currentX, mKChartsView.MARGINTOP), Offset(currentX, size.height - mKChartsView.MARGINBOTTOM), customPaint);
    //绘制日期
    double dateX = currentX - getStringWidth(date, textPaint) / 2;
    double dateY = size.height - mKChartsView.MARGINBOTTOM + getStringHeight(date, textPaint) + 5;
    double dateLeft = currentX - getStringWidth(date, textPaint) / 2 - 10;
    double dateTop = size.height - mKChartsView.MARGINBOTTOM;
    double dateRight = currentX + getStringWidth(date, textPaint) / 2 + 10;
    double dateBottom = dateTop + getStringHeight(date, textPaint) + 10;
    canvas.drawRect(Rect.fromLTRB(dateLeft, dateTop, dateRight, dateBottom), redPaint);

    TextSpan span = TextSpan(children: [TextSpan(text: date, style: const TextStyle(color: Colors.white))]);
    textPaint
      ..text = span
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(dateX, dateY));

    //画横线
    canvas.drawLine(Offset(BaseKChartPainter.MARGINLEFT, currentY), Offset(BaseKChartPainter.MARGINLEFT + mKChartsView.mChartWidth, currentY), customPaint);
    //绘制价格
    double left, top, right, bottom, priceX, priceY;
    priceX = BaseKChartPainter.MARGINLEFT + mKChartsView.mChartWidth + 5;
    priceY = currentY + getStringHeight(price, textPaint) / 2;
    left = BaseKChartPainter.MARGINLEFT + mKChartsView.mChartWidth;
    top = currentY - getStringHeight(price, textPaint) / 2 - 5;
    right = left + getStringWidth(price, textPaint) + 15;
    bottom = currentY + getStringHeight(price, textPaint) / 2 + 5;
    // if (Port.drawFlag == 1) {
    //   priceX = mKChartsView.MARGINLEFT + mKChartsView.mChartWidth + 5;
    //   priceY = currentY + getStringHeight(price, textPaint) / 2;
    //   left = mKChartsView.MARGINLEFT + mKChartsView.mChartWidth;
    //   top = currentY - getStringHeight(price, textPaint) / 2 - 5;
    //   right = left + getStringWidth(price, textPaint) + 15;
    //   bottom = currentY + getStringHeight(price, textPaint) / 2 + 5;
    // } else {
    priceX = BaseKChartPainter.MARGINLEFT + mKChartsView.mChartWidth - getStringWidth(price, textPaint) - 15;
    priceY = currentY + getStringHeight(price, textPaint) / 2;
    left = BaseKChartPainter.MARGINLEFT + mKChartsView.mChartWidth - getStringWidth(price, textPaint) - 15;
    top = currentY - getStringHeight(price, textPaint) / 2 - 5;
    right = left + getStringWidth(price, textPaint) + 15;
    bottom = currentY + getStringHeight(price, textPaint) / 2 + 5;
    // }
    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), redPaint);

    TextSpan priceText = TextSpan(children: [TextSpan(text: price, style: const TextStyle(color: Colors.white))]);
    textPaint
      ..text = priceText
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(priceX, priceY));
  }

  /**
   * 获取手指触摸的第几根K线
   * @param position  手指触点横坐标
   * @return
   */
  static int getNumber(int position, double marginLeft, double pWidth, int showNum, bool isDrawTime) {
    int number = 0;
    int num = ((position - marginLeft) % pWidth).toInt();
    if (num == 0) {
      number = (position - marginLeft) ~/ pWidth;
    } else {
      number = ((position - marginLeft) / pWidth + 1).toInt();
    }

    if (isDrawTime) {
      number = number < 0 ? 0 : number;
    } else {
      number = number < 1 ? 1 : number;
    }
    number = number > showNum ? showNum : number;
    return number;
  }

  /**
   * 处理Y坐标
   * @param Y
   * @return
   */
  static double dealY(double Y, double viewHeight, double marginBottom, double marginTop) {
    double positionY = Y;
    positionY = positionY > viewHeight - marginBottom ? viewHeight - marginBottom : positionY;
    positionY = positionY < marginTop ? marginTop : positionY;
    return positionY;
  }

  /**
   * 根据Y坐标获取对应的价格
   * @param coordinateY y坐标
   * @return
   */
  double getPrice(num coordinateY) {
    double price = 0.0;
    num upTop = mKChartsView.MARGINTOP; //上表上边界
    num upDown = mKChartsView.MARGINTOP + mKChartsView.mUperChartHeight; //上表下边界
    num lowTop = mKChartsView.MARGINTOP + mKChartsView.mUperChartHeight + mKChartsView.MARGINTOP + mKChartsView.UPER_LOWER_INTERVAL; //下表上边界
    num lowDown = crossLineViewHeight - mKChartsView.MARGINBOTTOM; //下表下边界

    if (coordinateY <= upDown) {
      //在上表
      double maxPrice = mKChartsView.mMaxPrice;
      double minPrice = mKChartsView.mMinPrice;
      double rate = (maxPrice - minPrice) / mKChartsView.mUperChartHeight;
      num height = mKChartsView.MARGINTOP + mKChartsView.mUperChartHeight - coordinateY;
      price = coordinateY < upTop ? maxPrice - minPrice : height * rate; //获取差价
      price = (maxPrice - minPrice) == 0 ? 0.000 : price + minPrice; //计算价格
    } else if (coordinateY >= lowTop) {
      //在下表
      double maxPrice = mKChartsView.mMaxPrice;
      double minPrice = mKChartsView.mMinPrice;
      double rate = (maxPrice - minPrice) / mKChartsView.mLowerChartHeight;
      num height = crossLineViewHeight - mKChartsView.MARGINBOTTOM - coordinateY;

      price = coordinateY > lowDown ? 0 : height * rate;
      price = (maxPrice - minPrice) == 0 ? 0.000 : price + minPrice;
    } else if (coordinateY > upDown && coordinateY < lowTop) {
      //在间隙处
      price = 0.00;
    }

    return price;
  }

  static double getStringWidth(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? 10))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.width;
  }

  static double getStringHeight(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? 10))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.height;
  }

/**
 *  绘制十字线
 * @param canvas
 * @param viewHeight
 * @param viewWidth
 * @param X
 * @param Y
 * @param mPointWidth
 * @param MARGINTOP
 * @param MARGINBOTTOM
 * @param MARGINLEFT
 * @param MARGINRIGHT
 */
  static void drawCrossLine(
      Canvas canvas,
      double viewHeight,
      double viewWidth,
      num LowerChartHeight,
      double X,
      double Y,
      double mPointWidth,
      double MARGINTOP,
      double MARGINBOTTOM,
      double MARGINLEFT,
      double leftMarginSpace,
      double rightMarginSpace,
      double MARGINRIGHT,
      int showNum,
      int startIndex,
      List<OHLCEntity> list,
      bool isDrawTime,
      double lastClsoe,
      KPeriod mKPeriod) {
    int number = getNumber(X.toInt(), MARGINLEFT + leftMarginSpace, mPointWidth, showNum, isDrawTime);
//		Log.i("", "第"+number+" 根K线");
    X = MARGINLEFT + number * mPointWidth + leftMarginSpace;
    Y = dealY(Y, viewHeight, MARGINBOTTOM, MARGINTOP);

    double startX = X;
    double startY = isDrawTime ? viewHeight : viewHeight - MARGINBOTTOM;
    double stopX = X;
    double stopY = MARGINTOP;
    TextPainter areaTextPaint = MethodUntil().getTextPainter(Utils.dp2px(15));
    Paint areaPaint = MethodUntil().getDrawPaint(const Color.fromRGBO(29, 32, 44, 1));
    Paint redPaint = MethodUntil().getDrawPaint(const Color.fromRGBO(255, 255, 255, 1));
    Paint framePaint = MethodUntil().getDrawPaint(const Color.fromRGBO(38, 41, 55, 1));
    framePaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = Utils.dp2px(1);
    //竖线
    canvas.drawLine(Offset(startX, startY), Offset(stopX, stopY), redPaint);

    startX = MARGINLEFT;
    startY = Y;
    stopX = viewWidth - MARGINRIGHT;
    stopY = Y;

    //横线
    canvas.drawLine(Offset(startX, startY), Offset(stopX, stopY), redPaint);

    int index = isDrawTime ? startIndex + number : startIndex + number - 1;
    OHLCEntity? ohlc = index < list.length ? list[index] : null;
    OHLCEntity preOhlc = OHLCEntity();

    if (ohlc != null) {
      preOhlc = index == 0 ? list[0] : list[index - 1];
    }

    double ts = 0;
    if (isDrawTime) {
      ts = (viewHeight - LowerChartHeight) / 28;
    } else {
      ts = viewHeight / 28;
    }

    double left = 0, right = 0, top = 0, bottom = 0, textX = 0;
    double margin = getStringHeight("价格", TextPainter(), size: ts) / 2;
    double height = getStringHeight("价格", TextPainter(), size: ts);
    double width = getStringWidth("1970-01-01 00:00", TextPainter(), size: ts);
    if (isDrawTime) {
      String date, price, average, changePer, volume, hold;
      double close = ohlc == null ? lastClsoe : ohlc.close?.toDouble() ?? 0;
      date = ohlc == null ? "---" : "${ohlc.date?.substring(5, ohlc.date?.length)} ${ohlc.time?.substring(0, 5)}";
      price = ohlc == null ? "---" : "${ohlc.close ?? 0}";
      average = ohlc == null ? "---" : "${ohlc.average ?? 0}";
      changePer = ohlc == null ? "---" : "${Utils.dealPointBigDecimal(((ohlc.close! - lastClsoe) / lastClsoe) * 100, 2)}%";
      volume = ohlc == null ? "---" : "${ohlc.volume ?? 0}";
      hold = ohlc == null ? "---" : "${ohlc.amount ?? 0}";

      if (X > viewWidth / 2) {
        //左边
        left = MARGINLEFT + leftMarginSpace;
        top = 0;
        right = MARGINLEFT + width + leftMarginSpace;
        bottom = MARGINTOP + height * 12 + margin;
        textX = left + 5;
      } else {
        //右边
        left = viewWidth - MARGINRIGHT - width - rightMarginSpace;
        top = 0;
        right = viewWidth - MARGINRIGHT - rightMarginSpace;
        bottom = MARGINTOP + height * 12 + margin;
        textX = left + 5;
      }

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), areaPaint);
      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), framePaint);

      areaTextPaint
        ..text = TextSpan(text: "时间", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top));
      areaTextPaint
        ..text = TextSpan(text: date, style: TextStyle(color: orangeColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 1));
      areaTextPaint
        ..text = TextSpan(text: "价格", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 2));
      areaTextPaint
        ..text = TextSpan(text: price, style: TextStyle(color: getColorPaint(close, lastClsoe), fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 3));
      areaTextPaint
        ..text = TextSpan(text: "均价", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 4));
      areaTextPaint
        ..text = TextSpan(text: average, style: TextStyle(color: getColorPaint(close, lastClsoe), fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 5));
      areaTextPaint
        ..text = TextSpan(text: "涨跌幅", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 6));
      areaTextPaint
        ..text = TextSpan(text: changePer, style: TextStyle(color: getColorPaint(close, lastClsoe), fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 7));
      areaTextPaint
        ..text = TextSpan(text: "成交量", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 8));
      areaTextPaint
        ..text = TextSpan(text: volume, style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 9));
      areaTextPaint
        ..text = TextSpan(text: "持仓量", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 10));
      areaTextPaint
        ..text = TextSpan(text: hold, style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 11));
    } else {
      String date, open, high, close, low, change, changePer, volume, hold;
      if (mKPeriod.kpFlag == KPFlag.Minute || mKPeriod.kpFlag == KPFlag.Hour) {
        date = ohlc == null ? "---" : "${ohlc.date?.substring(5, ohlc.date?.length)} ${ohlc.time?.substring(0, 5)}";
      } else {
        date = ohlc == null ? "---" : ohlc.date ?? "";
      }
      open = ohlc == null ? "---" : "${ohlc.open ?? 0}";
      high = ohlc == null ? "---" : "${ohlc.high ?? 0}";
      close = ohlc == null ? "---" : "${ohlc.close ?? 0}";
      low = ohlc == null ? "---" : "${ohlc.low ?? 0}";
      double ch = ohlc == null ? 0 : ((ohlc.close ?? 0) - (preOhlc.close ?? 0)).toDouble();
      double cper = preOhlc.close == null ? 0 : Utils.dealPointBigDecimal(ch / preOhlc.close! * 100, 2);
      change = Utils.dealPointBigDecimal(ch, 2).toString();
      changePer = "$cper%";
      volume = ohlc == null ? "---" : "${ohlc.volume ?? 0}";
      hold = ohlc == null ? "---" : "${ohlc.amount ?? 0}";

      if (X > viewWidth / 2) {
        //左边
        left = MARGINLEFT + Port.defult_icon_width + leftMarginSpace;
        top = 0;
        right = MARGINLEFT + width + Port.defult_icon_width + leftMarginSpace;
        bottom = MARGINTOP + height * 18;
        textX = left + 5;
      } else {
        //右边
        left = viewWidth - MARGINRIGHT - width;
        top = 0;
        right = viewWidth - MARGINRIGHT;
        bottom = MARGINTOP + height * 18;
        textX = left + 5;
      }

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), areaPaint);
      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), framePaint);

      areaTextPaint
        ..text = TextSpan(text: "时间", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top));
      areaTextPaint
        ..text = TextSpan(text: date, style: TextStyle(color: orangeColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height));
      areaTextPaint
        ..text = TextSpan(text: "开盘", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 2));
      areaTextPaint
        ..text = TextSpan(text: open, style: TextStyle(color: getKColorPaint(ch), fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 3));
      areaTextPaint
        ..text = TextSpan(text: "最高", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 4));
      areaTextPaint
        ..text = TextSpan(text: high, style: TextStyle(color: getKColorPaint(ch), fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 5));
      areaTextPaint
        ..text = TextSpan(text: "最低", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 6));
      areaTextPaint
        ..text = TextSpan(text: low, style: TextStyle(color: getKColorPaint(ch), fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 7));
      areaTextPaint
        ..text = TextSpan(text: "收盘", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 8));
      areaTextPaint
        ..text = TextSpan(text: close, style: TextStyle(color: getKColorPaint(ch), fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 9));
      areaTextPaint
        ..text = TextSpan(text: "涨跌", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 10));
      areaTextPaint
        ..text = TextSpan(text: change, style: TextStyle(color: getKColorPaint(ch), fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 11));
      areaTextPaint
        ..text = TextSpan(text: "涨跌幅", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 12));
      areaTextPaint
        ..text = TextSpan(text: changePer, style: TextStyle(color: getKColorPaint(ch), fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 13));
      areaTextPaint
        ..text = TextSpan(text: "成交量", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 14));
      areaTextPaint
        ..text = TextSpan(text: volume, style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 15));
      areaTextPaint
        ..text = TextSpan(text: "持仓量", style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 16));
      areaTextPaint
        ..text = TextSpan(text: hold, style: TextStyle(color: whiteColor, fontSize: ts))
        ..layout()
        ..paint(canvas, Offset(textX, top + height * 17));
    }
  }

/**
 * 获取颜色画笔
 * @param close
 * @param lastClose
 * @return
 */
  static Color getColorPaint(double close, double lastClose) {
    Color? color;
    if (close > lastClose) {
      color = const Color.fromRGBO(255, 32, 74, 1);
    } else if (close < lastClose) {
      color = const Color.fromRGBO(50, 255, 32, 1);
    } else {
      color = Port.chartTxtColor;
    }
    return color;
  }

  static Color getKColorPaint(double change) {
    Color? color;
    if (change > 0) {
      color = const Color.fromRGBO(255, 32, 74, 1);
    } else if (change < 0) {
      color = const Color.fromRGBO(50, 255, 32, 1);
    } else {
      color = Port.chartTxtColor;
    }
    return color;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
