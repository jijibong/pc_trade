import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:trade/util/painter/k_chart/k_chart_painter.dart';

import '../../../model/k/port.dart';
import 'method_util.dart';

abstract class BaseKChartPainter extends CustomPainter {
  double latitudeSpacing = 0;
  static double TimeMarginRight = 0;
  static double TimeMarginLeft = 0;
  double timeDownChartHeight = 0;
  bool isDrawTimeDown = true;
  double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  static double MARGINLEFT = 2;
  // double MARGINTOP = getStringHeight("0", TextPainter(), size: Port.ChartTextSize);
  double timeLeftMarginSpace = getStringWidth("000.000", TextPainter(), size: Port.ChartTextSize);
  double halfTextHeight = getStringHeight("0", TextPainter(), size: Port.ChartTextSize) / 2;
  double textHeight = getStringHeight("MA", TextPainter(), size: Port.ChartTextSize);
  double MARGINTOP = 0;
  int UPER_LOWER_INTERVAL = 5;
  Color DEFAULT_AXIS_COLOR = Colors.black;
  Color DEFAULT_BORDER_COLOR = Colors.black;
  Color DEFAULT_LONGI_LAITUDE_COLOR = Colors.black;
  List<double> DEFAULT_DASH_EFFECT = [7, 5];
  int DEFAULT_UPER_LATITUDE_NUM = 7;
  int DEFAULT_MID_LATITUDE_NUM = 0;
  int DEFAULT_LOWER_LATITUDE_NUM = 0;
  int DEFAULT_LOGITUDE_NUM = 3;
  int DEFAULT_TIME_LOGITUDE_NUM = 3;
  int DEFAULT_TIME_LATITUDE_NUM = 7;
  double TIME_LOWER_CHART_TOP = 0;
  double UPER_CHART_BOTTOM = 0;
  double TIME_UPER_CHART_BOTTOM = 0;
  double mUperChartHeight = 0;
  double? longitudeSpacing;
  Paint forePaint = MethodUntil().getDrawPaint(Port.dividerColor);
  Paint girdPaint = MethodUntil().getDrawPaint(Port.borderColor);
  bool isDrawTime = true;

  BaseKChartPainter({
    required this.isDrawTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double viewHeight = size.height;
    double viewWidth = size.width;
    if (isDrawTime) {
      TimeMarginLeft = 2;
      TimeMarginRight = 2;
      timeDownChartHeight = isDrawTimeDown == true ? (viewHeight - MARGINTOP) ~/ (DEFAULT_TIME_LATITUDE_NUM + 1) * 3 : 0;
      TIME_UPER_CHART_BOTTOM = viewHeight - timeDownChartHeight;
      TIME_LOWER_CHART_TOP = viewHeight - timeDownChartHeight + Port.TIME_UPER_LOWER_INTERVAL;
      // drawTimeBorders(canvas, viewHeight, viewWidth);
      drawTimeRegions(canvas, viewHeight, viewWidth);
    } else {
      longitudeSpacing = (viewWidth - 2 * MARGINLEFT) / (DEFAULT_LOGITUDE_NUM + 1);
      latitudeSpacing = (viewHeight - MARGINTOP - textHeight) / (DEFAULT_UPER_LATITUDE_NUM + 1);
      mUperChartHeight = latitudeSpacing * (DEFAULT_UPER_LATITUDE_NUM + 1);
      UPER_CHART_BOTTOM = MARGINTOP + textHeight + latitudeSpacing * (DEFAULT_UPER_LATITUDE_NUM + 1);
      // drawBorders(canvas, viewHeight, viewWidth);
      // drawLatitudes(canvas, viewWidth, latitudeSpacing);
    }
  }

  // void drawTimeBorders(Canvas canvas, double viewHeight, double viewWidth) {
  //   canvas.drawLine(Offset(TimeMarginLeft, MARGINTOP), Offset(viewWidth - TimeMarginRight, MARGINTOP), forePaint);
  //   canvas.drawLine(Offset(TimeMarginLeft, MARGINTOP), Offset(TimeMarginLeft, viewHeight), forePaint);
  //   canvas.drawLine(Offset((viewWidth - TimeMarginLeft), viewHeight), Offset((viewWidth - TimeMarginRight), MARGINTOP.toDouble()), forePaint);
  //   canvas.drawLine(Offset((viewWidth - TimeMarginRight), viewHeight), Offset(TimeMarginLeft, viewHeight), forePaint);
  // }

  void drawTimeRegions(Canvas canvas, double viewHeight, double viewWidth) {
    if (isDrawTimeDown) {
      forePaint
        .strokeWidth = 0.5;
      canvas.drawLine(Offset(timeLeftMarginSpace, TIME_UPER_CHART_BOTTOM), Offset((viewWidth - TimeMarginRight), TIME_UPER_CHART_BOTTOM), forePaint);
    }
  }

  void drawBorders(Canvas canvas, double viewHeight, double viewWidth) {
    canvas.drawLine(Offset(viewWidth - MARGINLEFT, viewHeight), Offset(MARGINLEFT, viewHeight), girdPaint);
  }

  static double getStringHeight(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? Port.ChartTextSize))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.height;
  }

  static double getStringWidth(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? Port.ChartTextSize))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.width;
  }

  @override
  bool shouldRepaint(BaseKChartPainter oldDelegate) {
    return false;
  }
}
