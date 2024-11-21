import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:trade/util/painter/k_chart/k_chart_painter.dart';

import '../../../model/k/port.dart';
import 'method_util.dart';

abstract class BaseKChartPainter extends CustomPainter {
  Color mForGround = Port.foreGroundColor;
  Color mGridColor = Port.girdColor;
  double latitudeSpacing = 0;
  static double TimeMarginRight = 0;
  static double TimeMarginLeft = 0;
  double timeDownChartHeight = 0;
  bool isDrawTimeDown = true;
  double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  static double MARGINLEFT = 2;
  static double KMARGINLEFT = 0;
  double MARGINTOP = Port.defult_margin_top;
  double MARGINBOTTOM = 0;
  int UPER_LOWER_INTERVAL = 5;
  int TIME_UPER_LOWER_INTERVAL = 20;
  Color DEFAULT_AXIS_COLOR = Colors.black;
  static double mCursorWidth = 0;
  Color DEFAULT_BORDER_COLOR = Colors.black;
  Color DEFAULT_LONGI_LAITUDE_COLOR = Colors.black;
  List<double> DEFAULT_DASH_EFFECT = [2, 1];
  int DEFAULT_UPER_LATITUDE_NUM = 4;
  int DEFAULT_MID_LATITUDE_NUM = 1;
  int DEFAULT_LOWER_LATITUDE_NUM = 1;
  int DEFAULT_LOGITUDE_NUM = 3;
  int DEFAULT_TIME_LOGITUDE_NUM = 3;
  int DEFAULT_TIME_LATITUDE_NUM = 7;
  static double LOWER_CHART_TOP = 0;
  static double MID_CHART_TOP = 0;
  double TIME_LOWER_CHART_TOP = 0;
  double UPER_CHART_BOTTOM = 0;
  double TIME_UPER_CHART_BOTTOM = 0;
  double mUperChartHeight = 0;
  double mMidChartHeight = 0;
  double mLowerChartHeight = 0;
  double mRightArea = 0;
  double? longitudeSpacing;
  Paint forePaint = MethodUntil().getDrawPaint(Port.foreGroundColor);
  Paint girdPaint = MethodUntil().getDrawPaint(Port.girdColor);
  bool isDrawTime = true;
  bool isDrawMid = false;
  bool isDrawLower = false;
  bool isDrawFrame = false;
  double bChartWidth = 0;

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
      timeDownChartHeight = isDrawTimeDown == true ? (viewHeight - MARGINBOTTOM - MARGINTOP) ~/ (DEFAULT_TIME_LATITUDE_NUM + 1) * 3 : 0;
      TIME_UPER_CHART_BOTTOM = viewHeight - timeDownChartHeight - MARGINBOTTOM;
      TIME_LOWER_CHART_TOP = viewHeight - timeDownChartHeight - MARGINBOTTOM + TIME_UPER_LOWER_INTERVAL;
      drawTimeBorders(canvas, viewHeight.toInt(), viewWidth.toInt());
      drawTimeRegions(canvas, viewHeight.toInt(), viewWidth.toInt());
    } else {
      if (isDrawLower && isDrawMid) {
        DEFAULT_UPER_LATITUDE_NUM = 4;
        DEFAULT_MID_LATITUDE_NUM = 1;
        DEFAULT_LOWER_LATITUDE_NUM = 2;
      } else if (isDrawLower && isDrawMid == false) {
        DEFAULT_UPER_LATITUDE_NUM = 5;
        DEFAULT_MID_LATITUDE_NUM = 0;
        DEFAULT_LOWER_LATITUDE_NUM = 2;
      } else if (isDrawLower == false && isDrawMid == false) {
        DEFAULT_UPER_LATITUDE_NUM = 7;
        DEFAULT_MID_LATITUDE_NUM = 0;
        DEFAULT_LOWER_LATITUDE_NUM = 0;
      }
      mRightArea = mCursorWidth;
      longitudeSpacing = (viewWidth - 2 * MARGINLEFT - mRightArea) / (DEFAULT_LOGITUDE_NUM + 1);
      if (isDrawLower && isDrawMid) {
        latitudeSpacing = ((viewHeight - MARGINTOP - MARGINBOTTOM - UPER_LOWER_INTERVAL) ~/
                (DEFAULT_UPER_LATITUDE_NUM + DEFAULT_LOWER_LATITUDE_NUM + DEFAULT_MID_LATITUDE_NUM + 3))
            .toDouble();
      } else if (isDrawLower && isDrawMid == false) {
        latitudeSpacing =
            ((viewHeight - MARGINTOP - MARGINBOTTOM - UPER_LOWER_INTERVAL) ~/ (DEFAULT_UPER_LATITUDE_NUM + DEFAULT_LOWER_LATITUDE_NUM + 2)).toDouble();
      } else if (isDrawLower == false && isDrawMid == false) {
        latitudeSpacing = ((viewHeight - MARGINTOP - MARGINBOTTOM) ~/ (DEFAULT_UPER_LATITUDE_NUM + 1)).toDouble();
      }
      mUperChartHeight = latitudeSpacing * (DEFAULT_UPER_LATITUDE_NUM + 1);
      mMidChartHeight = latitudeSpacing * (DEFAULT_MID_LATITUDE_NUM + 1);
      mLowerChartHeight = latitudeSpacing * (DEFAULT_LOWER_LATITUDE_NUM + 1);
      bChartWidth = longitudeSpacing ?? 1 * (DEFAULT_LOGITUDE_NUM + 1);
      UPER_CHART_BOTTOM = MARGINTOP + latitudeSpacing * (DEFAULT_UPER_LATITUDE_NUM + 1);
      MID_CHART_TOP = UPER_CHART_BOTTOM + UPER_LOWER_INTERVAL;
      LOWER_CHART_TOP = viewHeight - MARGINBOTTOM - latitudeSpacing * (DEFAULT_LOWER_LATITUDE_NUM + 1);
      drawBorders(canvas, viewHeight, viewWidth);
      drawLatitudes(canvas, viewWidth, latitudeSpacing);
      drawRegions(canvas, viewWidth);
    }
  }

  void drawTimeBorders(Canvas canvas, int viewHeight, int viewWidth) {
    if (isDrawFrame) {
      girdPaint.color = mForGround;
      girdPaint.strokeWidth = 2;

      canvas.drawLine(Offset(TimeMarginLeft, MARGINTOP), Offset(viewWidth - TimeMarginRight, MARGINTOP), forePaint);
      canvas.drawLine(Offset(TimeMarginLeft, MARGINTOP), Offset(TimeMarginLeft, viewHeight - MARGINBOTTOM), forePaint);
      canvas.drawLine(
          Offset((viewWidth - TimeMarginLeft), (viewHeight - MARGINBOTTOM).toDouble()), Offset((viewWidth - TimeMarginRight), MARGINTOP.toDouble()), forePaint);
      canvas.drawLine(Offset((viewWidth - TimeMarginRight), (viewHeight - MARGINBOTTOM).toDouble()),
          Offset(TimeMarginLeft, (viewHeight - MARGINBOTTOM).toDouble()), forePaint);
    }
  }

  void drawTimeRegions(Canvas canvas, int viewHeight, int viewWidth) {
    if (isDrawTimeDown) {
      forePaint.color = mForGround;
      forePaint.strokeWidth = 2;
      canvas.drawLine(Offset(0, TIME_UPER_CHART_BOTTOM), Offset((viewWidth - TimeMarginRight), TIME_UPER_CHART_BOTTOM), forePaint);
    }
  }

  void drawBorders(Canvas canvas, double viewHeight, double viewWidth) {
    girdPaint.color = mGridColor;
    girdPaint.strokeWidth = 2;
    canvas.drawLine(Offset(viewWidth - MARGINLEFT - mRightArea, viewHeight - MARGINBOTTOM), Offset(MARGINLEFT, viewHeight - MARGINBOTTOM), girdPaint);
  }

  void drawLatitudes(Canvas canvas, double viewWidth, double latitudeSpacing) {
    girdPaint.color = mGridColor;
    girdPaint.style = PaintingStyle.stroke;
    girdPaint.isAntiAlias = true;
    girdPaint.strokeWidth = 1;
    for (int i = 1; i <= DEFAULT_UPER_LATITUDE_NUM; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(MARGINLEFT + ChartPainter.leftMarginSpace, MARGINTOP + latitudeSpacing * i);
      path.lineTo(viewWidth - MARGINLEFT - mRightArea, MARGINTOP + latitudeSpacing * i);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        girdPaint,
      );
    }
  }

  void drawRegions(Canvas canvas, double viewWidth) {
    if (isDrawMid) {
      forePaint.color = mForGround;
      forePaint.strokeWidth = 2;
      canvas.drawLine(
          Offset(MARGINLEFT + ChartPainter.leftMarginSpace, UPER_CHART_BOTTOM), Offset(viewWidth - MARGINLEFT - mRightArea, UPER_CHART_BOTTOM), forePaint);
    }

    if (isDrawLower) {
      forePaint.color = mForGround;
      forePaint.strokeWidth = 2;
      canvas.drawLine(
          Offset(MARGINLEFT + ChartPainter.leftMarginSpace, LOWER_CHART_TOP), Offset(viewWidth - MARGINLEFT - mRightArea, LOWER_CHART_TOP), forePaint);
    }
  }

  @override
  bool shouldRepaint(BaseKChartPainter oldDelegate) {
    return true;
  }
}
