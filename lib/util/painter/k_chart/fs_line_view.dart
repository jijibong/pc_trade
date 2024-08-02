import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../../model/k/OHLCEntity.dart';
import '../../../model/k/port.dart';
import '../../utils/utils.dart';
import 'base_k_chart_painter.dart';
import 'method_util.dart';

class FsLineChart extends BaseKChartPainter {
  Color whiteColor = const Color.fromRGBO(255, 255, 255, 1);
  double timeDownChartHeight = 1;
  double mPointWidth = 1;
  List<OHLCEntity> mOHLCData = [];
  double TimeMarginRight = 2;
  double TimeMarginLeft = 2;
  double mMaxPrice = 0;
  double mMinPrice = 0;
  double lastClose = 0;
  TextPainter redPaint = TextPainter();
  TextPainter greenPaint = TextPainter();
  Paint cursorPaint = MethodUntil().getDrawPaint(Port.cursorYellowColor); //游标画笔
  Paint whitePaint = MethodUntil().getDrawPaint(const Color.fromRGBO(255, 255, 255, 1)); //白色画笔
  Paint bluePaint = MethodUntil().getDrawPaint(const Color.fromRGBO(28, 220, 255, 1)); //蓝色画笔
  Paint yellowPaint = MethodUntil().getDrawPaint(const Color.fromRGBO(255, 240, 0, 1)); //黄色画笔
  TextPainter textPaint = TextPainter();

  FsLineChart({
    required this.mMaxPrice,
    required this.mMinPrice,
    required this.lastClose,
    required this.mOHLCData,
  }) : super(
          isDrawTime: true,
        ) {
    isDrawTimeDown = false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    if (mOHLCData.isEmpty) {
      canvas.drawColor(Port.backGroundColor, BlendMode.color);
      return;
    }
    TimeMarginLeft = 2;
    TimeMarginRight = 2;
    int number = mOHLCData.length;

    if (number < 2) return;

    mPointWidth = (size.width - TimeMarginLeft - TimeMarginRight) / number;
    if (mPointWidth == 0) return;

    timeDownChartHeight = isDrawTimeDown == true ? (size.height - MARGINBOTTOM - MARGINTOP) / (DEFAULT_TIME_LATITUDE_NUM + 1) * 3 : 0;
    double latitudeSpacing = (size.height - MARGINBOTTOM - MARGINTOP - timeDownChartHeight) / (DEFAULT_TIME_LATITUDE_NUM + 1);
    double longitudeSpacing = (size.width - TimeMarginLeft - TimeMarginRight) / (DEFAULT_TIME_LOGITUDE_NUM + 1);
    _drawLatitudes(canvas, size.width, latitudeSpacing);
    _drawLongitudes(canvas, longitudeSpacing, size);
    _drawTimeUpper(canvas, longitudeSpacing, size);
  }

  void _drawLatitudes(Canvas canvas, double width, double latitudeSpacing) {
    girdPaint
      ..color = Port.girdColor
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 0.5;

    for (int i = 1; i <= DEFAULT_TIME_LATITUDE_NUM; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(TimeMarginLeft, MARGINTOP + latitudeSpacing * i);
      path.lineTo(width - TimeMarginRight, MARGINTOP + latitudeSpacing * i);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        girdPaint,
      );
    }

    lastClose = lastClose == 0 ? mMinPrice + ((mMaxPrice - mMinPrice) / 2) : lastClose;
    double max = mMaxPrice;
    double min = mMinPrice;
    double maxHeight = (max - lastClose) > (lastClose - min) ? (max - lastClose) : (lastClose - min);
    double perPrice = maxHeight / 4;
    for (int i = 3; i > 0; i--) {
      String text = Utils.getPointNum(lastClose + perPrice * (4 - i));
      double percent = (perPrice * (4 - i)) / lastClose * 100;
      String textPercent = "${Utils.getLimitNum(percent, 2)}%";
      double leftY = 0, rightX = 0;
      leftY = MARGINTOP + latitudeSpacing * i;
      rightX = width - getStringWidth(textPercent, redPaint, size: DEFAULT_AXIS_TITLE_SIZE);
      redPaint
        ..text = TextSpan(text: text, style: TextStyle(color: const Color.fromRGBO(230, 56, 89, 1), fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(TimeMarginLeft, leftY));
      redPaint
        ..text = TextSpan(text: textPercent, style: TextStyle(color: const Color.fromRGBO(230, 56, 89, 1), fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(rightX, leftY));
    }

    for (int i = 7; i > 4; i--) {
      String text = Utils.getPointNum(lastClose - perPrice * (i - 4));
      double percent = (perPrice * (i - 4)) / lastClose * 100;
      String textPercent = "-${Utils.getLimitNum(percent, 2)}%";
      double leftX = 0, leftY = 0, rightX = 0;
      leftX = TimeMarginLeft;
      leftY = MARGINTOP + latitudeSpacing * i;
      rightX = width - getStringWidth(textPercent, greenPaint, size: DEFAULT_AXIS_TITLE_SIZE);
      redPaint
        ..text = TextSpan(text: text, style: TextStyle(color: const Color.fromRGBO(58, 255, 32, 1), fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(leftX, leftY));
      redPaint
        ..text = TextSpan(text: textPercent, style: TextStyle(color: const Color.fromRGBO(58, 255, 32, 1), fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(rightX, leftY));
    }
    double leftY = 0, rightX = 0;
    leftY = MARGINTOP + latitudeSpacing * 4;
    rightX = width - getStringWidth("0.00%", textPaint, size: DEFAULT_AXIS_TITLE_SIZE);
    redPaint
      ..text = TextSpan(text: Utils.getPointNum(lastClose), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(TimeMarginLeft, leftY));
    redPaint
      ..text = TextSpan(text: "0.00%", style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
      ..textDirection = TextDirection.ltr
      ..layout()
      ..paint(canvas, Offset(rightX, leftY));
  }

  void _drawLongitudes(Canvas canvas, double longitudeSpacing, Size size) {
    Paint paint = Paint()
      ..color = Port.girdColor
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = 1;
    for (int i = 1; i <= DEFAULT_TIME_LOGITUDE_NUM; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(TimeMarginLeft + longitudeSpacing * i, MARGINTOP);
      path.lineTo(TimeMarginLeft + longitudeSpacing * i, TIME_UPER_CHART_BOTTOM);
      canvas.drawPath(path, paint);
    }

    List timeArry = calcFSTime();
    for (int i = 0; i < timeArry.length; i++) {
      double x, y;
      if (i == 0) {
        x = longitudeSpacing * i + TimeMarginLeft;
        y = size.height - MARGINBOTTOM - timeDownChartHeight + getStringHeight(timeArry[i], textPaint);
      } else if (i == timeArry.length - 1) {
        x = longitudeSpacing * i + TimeMarginLeft - getStringWidth(timeArry[i], textPaint);
        y = size.height - MARGINBOTTOM - timeDownChartHeight + getStringHeight(timeArry[i], textPaint);
      } else {
        x = longitudeSpacing * i + TimeMarginLeft - getStringWidth(timeArry[i], textPaint) / 2;
        y = size.height - MARGINBOTTOM - timeDownChartHeight + getStringHeight(timeArry[i], textPaint);
      }
      textPaint
        ..text = TextSpan(text: timeArry[i], style: TextStyle(color: Port.costFiveColor, fontSize: DEFAULT_AXIS_TITLE_SIZE + 2))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(x, y));
    }
  }

  void _drawTimeUpper(Canvas canvas, double longitudeSpacing, Size size) {
    bluePaint.strokeWidth = 1;
    yellowPaint.strokeWidth = 1;
    double closeY = 0.0;
    double averageY = 0.0;
    double nextCloseY = 0.0;
    double nextAverageY = 0.0;
    double startX = 0.0;
    double nextX = 0.0;
    lastClose = lastClose == 0 ? mMinPrice + ((mMaxPrice - mMinPrice) / 2) : lastClose;
    double max = mMaxPrice;
    double min = mMinPrice;
    double maxHeight = (max - lastClose) > (lastClose - min) ? (max - lastClose) : (lastClose - min); //最大价差
    max = lastClose + maxHeight;
    min = lastClose - maxHeight;
    double rate = (size.height - MARGINBOTTOM - MARGINTOP - timeDownChartHeight) / (max - min); //计算最小单位
    if (rate.isInfinite) {
      // logger.d("rate.isInfinite  max:$max   min:$max   lastClose:$lastClose");
      return;
    }
    int showNum = 0;
    showNum = (size.width - TimeMarginLeft - TimeMarginRight) ~/ mPointWidth;
    for (int i = 0; i < showNum; i++) {
      int num = i + 1;
      startX = mPointWidth * i + TimeMarginLeft;
      nextX = mPointWidth * num + TimeMarginLeft;
      if (i >= mOHLCData.length) break;
      if (i < mOHLCData.length) {
        int next = (i + 1) >= mOHLCData.length ? mOHLCData.length - 1 : i + 1;
        closeY = (max - (mOHLCData[i].close ?? 0)) * rate + MARGINTOP;
        averageY = (max - (mOHLCData[i].average ?? 0)) * rate + MARGINTOP;
        nextCloseY = (max - (mOHLCData[next].close ?? 0)) * rate + MARGINTOP;
        nextAverageY = (max - (mOHLCData[next].average ?? 0)) * rate + MARGINTOP;
        canvas.drawLine(Offset(startX, closeY), Offset(nextX, nextCloseY), bluePaint); //绘制收盘价
        canvas.drawLine(Offset(startX, averageY), Offset(nextX, nextAverageY), yellowPaint); //绘制均价
      }
    }
  }

  List<String> calcFSTime() {
    List<String> timeArr = ["00:00:00", "00:00:00", "00:00:00", "00:00:00", "00:00:00"];
    int start = int.tryParse(Utils.getLongTime("${mOHLCData[0].date} ${mOHLCData[0].time}")) ?? 0;
    int end = int.tryParse(Utils.getLongTime("${mOHLCData.last.date} ${mOHLCData.last.time}")) ?? 0;
    int period = (end - start) ~/ 5;
    int start1 = start + period;
    int start2 = start1 + period;
    int start3 = start2 + period;

    timeArr[0] = Utils.timeMillisToTime(start);
    timeArr[1] = Utils.timeMillisToTime(start1);
    timeArr[2] = Utils.timeMillisToTime(start2);
    timeArr[3] = Utils.timeMillisToTime(start3);
    timeArr[4] = Utils.timeMillisToTime(end);
    return timeArr;
  }

  List<OHLCEntity> getOHLCData() {
    List<OHLCEntity> list = [];
    if (mOHLCData.isNotEmpty) {
      list.addAll(mOHLCData);
    }
    return list;
  }

  static double getStringWidth(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? Port.ChartTextSize + 2))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.width;
  }

  static double getStringHeight(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? Port.ChartTextSize + 2))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.height;
  }
}
