import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:trade/util/painter/k_chart/k_chart_painter.dart';

import '../../../model/k/port.dart';
import '../../log/log.dart';
import 'method_util.dart';

abstract class BaseKChartPainter extends CustomPainter {
  double latitudeSpacing = 0;
  static double TimeMarginRight = 0;
  static double TimeMarginLeft = 0;
  double timeDownChartHeight = 0;
  bool isDrawTimeDown = true;
  double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  static double MARGINLEFT = 2;
  double MARGINTOP = Port.defult_margin_top;
  int UPER_LOWER_INTERVAL = 5;
  Color DEFAULT_AXIS_COLOR = Colors.black;
  static double mCursorWidth = 0;
  Color DEFAULT_BORDER_COLOR = Colors.black;
  Color DEFAULT_LONGI_LAITUDE_COLOR = Colors.black;
  List<double> DEFAULT_DASH_EFFECT = [0.8, 5];
  int DEFAULT_UPER_LATITUDE_NUM = 3;
  int DEFAULT_MID_LATITUDE_NUM = 0;
  int DEFAULT_LOWER_LATITUDE_NUM = 0;
  int DEFAULT_LOGITUDE_NUM = 3;
  int DEFAULT_TIME_LOGITUDE_NUM = 3;
  int DEFAULT_TIME_LATITUDE_NUM = 7;
  double TIME_LOWER_CHART_TOP = 0;
  double UPER_CHART_BOTTOM = 0;
  double TIME_UPER_CHART_BOTTOM = 0;
  double mUperChartHeight = 0;
  double mRightArea = 0;
  double? longitudeSpacing;
  Paint forePaint = MethodUntil().getDrawPaint(Port.foreGroundColor);
  Paint girdPaint = MethodUntil().getDrawPaint(Port.girdColor);
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
      drawTimeBorders(canvas, viewHeight, viewWidth);
      drawTimeRegions(canvas, viewHeight, viewWidth);
    } else {
      mRightArea = mCursorWidth;
      longitudeSpacing = (viewWidth - 2 * MARGINLEFT - mRightArea) / (DEFAULT_LOGITUDE_NUM + 1);
      latitudeSpacing = ((viewHeight - MARGINTOP) ~/ (DEFAULT_UPER_LATITUDE_NUM + 1)).toDouble();
      mUperChartHeight = latitudeSpacing * (DEFAULT_UPER_LATITUDE_NUM + 1);
      UPER_CHART_BOTTOM = MARGINTOP + latitudeSpacing * (DEFAULT_UPER_LATITUDE_NUM + 1);
      drawBorders(canvas, viewHeight, viewWidth);
      drawLatitudes(canvas, viewWidth, latitudeSpacing);
    }
  }

  void drawTimeBorders(Canvas canvas, double viewHeight, double viewWidth) {
    canvas.drawLine(Offset(TimeMarginLeft, MARGINTOP), Offset(viewWidth - TimeMarginRight, MARGINTOP), forePaint);
    canvas.drawLine(Offset(TimeMarginLeft, MARGINTOP), Offset(TimeMarginLeft, viewHeight), forePaint);
    canvas.drawLine(Offset((viewWidth - TimeMarginLeft), viewHeight), Offset((viewWidth - TimeMarginRight), MARGINTOP.toDouble()), forePaint);
    canvas.drawLine(Offset((viewWidth - TimeMarginRight), viewHeight), Offset(TimeMarginLeft, viewHeight), forePaint);
  }

  void drawTimeRegions(Canvas canvas, double viewHeight, double viewWidth) {
    if (isDrawTimeDown) {
      forePaint
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, TIME_UPER_CHART_BOTTOM), Offset((viewWidth - TimeMarginRight), TIME_UPER_CHART_BOTTOM), forePaint);
    }
  }

  void drawBorders(Canvas canvas, double viewHeight, double viewWidth) {
    canvas.drawLine(Offset(viewWidth - MARGINLEFT - mRightArea, viewHeight), Offset(MARGINLEFT, viewHeight), girdPaint);
  }

  void drawLatitudes(Canvas canvas, double viewWidth, double latitudeSpacing) {
    girdPaint
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= DEFAULT_UPER_LATITUDE_NUM; i++) {
      Path path = Path(); // 绘制虚线
      // path.moveTo(MARGINLEFT + ChartPainter.leftMarginSpace,
      //     latitudeSpacing * i + MARGINTOP - Port.text_check + getStringHeight("0", TextPainter(), size: Port.ChartTextSize));
      // path.lineTo(viewWidth - MARGINLEFT - mRightArea,
      //     latitudeSpacing * i + MARGINTOP - Port.text_check + getStringHeight("0", TextPainter(), size: Port.ChartTextSize));
      path.moveTo(MARGINLEFT + ChartPainter.leftMarginSpace, latitudeSpacing * i + MARGINTOP);
      path.lineTo(viewWidth - MARGINLEFT - mRightArea, latitudeSpacing * i + MARGINTOP);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        girdPaint,
      );
    }
  }

  static double getStringHeight(String text, TextPainter paint, {double? size}) {
    paint
      ..text = TextSpan(text: text, style: TextStyle(fontSize: size ?? Port.ChartTextSize))
      ..textDirection = TextDirection.ltr
      ..layout();
    return paint.height;
  }

  @override
  bool shouldRepaint(BaseKChartPainter oldDelegate) {
    return false;
  }
}
