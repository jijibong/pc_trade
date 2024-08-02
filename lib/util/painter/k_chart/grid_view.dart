import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import '../../../model/k/port.dart';
import 'method_util.dart';

///坐标轴使用的View
class GridChart extends CustomPainter {
  /// 默认背景色
  Color DEFAULT_CHART_BACKGROUD = Colors.white;

  /// 默认XY轴字体大小
  double DEFAULT_AXIS_TITLE_SIZE = 8;

  /// 默认左右边距
  static double MARGINLEFT = 2;

  /// 默认上边距
  double MARGINTOP = 4;

  /// 默认下边距
  double MARGINBOTTOM = 44;

  /// DEFAULT_AXIS_TITLE_SIZE;
  /// 默认上下表间隔
  int UPER_LOWER_INTERVAL = 5;

  /// 默认分时图上下表间隔
  int TIME_UPER_LOWER_INTERVAL = 40;

  /// 默认字体颜色
  Color DEFAULT_AXIS_COLOR = Colors.black;

  /// 竖屏右侧实时价格游标宽度
  double mCursorWidth = 18;

  /// 默认边框的颜色
  static const Color DEFAULT_BORDER_COLOR = Colors.black;

  /// 默认经纬线颜色
  static const Color DEFAULT_LONGI_LAITUDE_COLOR = Colors.black;

  /// 默认虚线效果
  List<double> DEFAULT_DASH_EFFECT = [2, 1];

  /// 默认上表纬线数
  int DEFAULT_UPER_LATITUDE_NUM = 4;

  /// 默认中表纬线数
  int DEFAULT_MID_LATITUDE_NUM = 1;

  /// 默认下表纬线数
  int DEFAULT_LOWER_LATITUDE_NUM = 1;

  /// 默认经线数
  int DEFAULT_LOGITUDE_NUM = 3;

  /// 默认分时图经线数
  int DEFAULT_TIME_LOGITUDE_NUM = 3;

  /// 默认分时图纬线数
  int DEFAULT_TIME_LATITUDE_NUM = 7;

  /// 是否绘制分时图下表
  bool isDrawTimeDown = true;

  /// 分时图下表高度
  double timeDownChartHeight = 0;

  /// 下表的顶部
  double LOWER_CHART_TOP = 0;

  /// 中间表的顶部
  double MID_CHART_TOP = 0;

  /// 下表的顶部
  double TIME_LOWER_CHART_TOP = 0;

  /// 上表的底部
  double UPER_CHART_BOTTOM = 0;

  /// 中间表的底部
  double MID_CHART_BOTTOM = 0;

  /// 上表的底部
  double TIME_UPER_CHART_BOTTOM = 0;
  // /////////////属性////////////////
  /// 背景色
  // Color mBackGround= Port.backGroundColor;
  /// 前景色
  Color mForGround = Port.foreGroundColor;

  /// 网格线颜色
  Color mGridColor = Port.girdColor;

  /// 经纬线颜色
  Color mLongiLatitudeColor = DEFAULT_LONGI_LAITUDE_COLOR;

  /// 虚线效果
  List<double>? mDashEffect = [];

  /// 边线色
  Color mBorderColor = DEFAULT_BORDER_COLOR;

  /// 上表高度
  double mUperChartHeight = 0;

  /// 中表高度
  double mMidChartHeight = 0;

  /// 下表高度
  double mLowerChartHeight = 0;

  /// 表宽度
  static double mChartWidth = 0;

  /// 右侧显示价格区域宽度
  double _mRightArea = -1;

  /// 经线间隔，Y
  int longitudeSpacing = 0;

  /// 纬线间隔，X
  int latitudeSpacing = 0;

  /// 分时图右侧显示价格区域宽度
  static double TimeMarginRight = 0;

  /// 分时图左侧显示价格区域宽度
  static double TimeMarginLeft = 0;

  /// 绘字画笔
  TextPainter textPaint = TextPainter();

  /// 前景画笔
  Paint forePaint = Paint();

  /// 网格画笔
  Paint girdPaint = Paint();

  /// 是否绘制分时图
  bool isDrawTime = true;

  /// 是否绘制中表格
  bool isDrawMid = true;

  /// 是否绘制下表格
  bool isDrawLower = true;

  /// 是否绘制边框
  bool isDrawFrame = false;

  GridChart(this.isDrawTime) {
    mDashEffect = DEFAULT_DASH_EFFECT;
    forePaint = MethodUntil().getDrawPaint(mForGround);
    girdPaint = MethodUntil().getDrawPaint(mGridColor);
  }

  /// 绘制边框
  void drawBorders(Canvas canvas, int viewHeight, int viewWidth) {
    girdPaint.color = mForGround;
    girdPaint.strokeWidth = 2;
    canvas.drawLine(Offset(viewWidth - MARGINLEFT - _mRightArea, viewHeight - MARGINBOTTOM), Offset(MARGINLEFT, viewHeight - MARGINBOTTOM), forePaint);
  }

  /// 绘制分时图边框
  void drawTimeBorders(Canvas canvas, int viewHeight, int viewWidth) {
    if (isDrawFrame) {
      girdPaint.color = mForGround;
      girdPaint.strokeWidth = 2;

      canvas.drawLine(Offset(TimeMarginLeft, MARGINTOP), Offset(viewWidth - TimeMarginRight, MARGINTOP), forePaint);
      canvas.drawLine(Offset(TimeMarginLeft, MARGINTOP), Offset(TimeMarginLeft, viewHeight - MARGINBOTTOM), forePaint);
      canvas.drawLine(Offset(viewWidth - TimeMarginLeft, viewHeight - MARGINBOTTOM), Offset(viewWidth - TimeMarginRight, MARGINTOP), forePaint);
      canvas.drawLine(Offset(viewWidth - TimeMarginRight, viewHeight - MARGINBOTTOM), Offset(TimeMarginLeft, viewHeight - MARGINBOTTOM), forePaint);
    }
  }

  /// 绘制经线
  void drawLongitudes(Canvas canvas, int viewHeight, int longitudeSpacing) {
    Paint paint = Paint();
    girdPaint.color = mLongiLatitudeColor;
    girdPaint.style = PaintingStyle.stroke;
    girdPaint.isAntiAlias = true;
    girdPaint.strokeWidth = 1;
    for (int i = 1; i <= DEFAULT_LOGITUDE_NUM; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(MARGINLEFT + longitudeSpacing * i, MARGINTOP);
      path.lineTo(MARGINLEFT + longitudeSpacing * i, UPER_CHART_BOTTOM);
      canvas.drawPath(path, paint);

      if (isDrawLower) {
        Path path1 = Path(); // 绘制下部表格虚线
        path1.moveTo(MARGINLEFT + longitudeSpacing * i, LOWER_CHART_TOP);
        path1.lineTo(MARGINLEFT + longitudeSpacing * i, viewHeight - MARGINBOTTOM);
        canvas.drawPath(path1, paint);
      }
    }
  }

  /// 绘制纬线
  void drawLatitudes(Canvas canvas, int viewHeight, int viewWidth, int latitudeSpacing) {
    girdPaint.color = mGridColor;
    girdPaint.style = PaintingStyle.stroke;
    girdPaint.isAntiAlias = true;
    girdPaint.strokeWidth = 1;
    for (int i = 1; i <= DEFAULT_UPER_LATITUDE_NUM; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(MARGINLEFT, MARGINTOP + latitudeSpacing * i);
      path.lineTo(viewWidth - MARGINLEFT - _mRightArea, MARGINTOP + latitudeSpacing * i);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        girdPaint,
      );
    }
  }

  /// 绘制绘制上下表边界线
  void drawRegions(Canvas canvas, int viewHeight, int viewWidth) {
    if (isDrawMid) {
      forePaint.color = mForGround;
      forePaint.strokeWidth = 2;
      canvas.drawLine(Offset(MARGINLEFT, UPER_CHART_BOTTOM), Offset(viewWidth - MARGINLEFT - _mRightArea, UPER_CHART_BOTTOM), forePaint);
    }

    if (isDrawLower) {
      forePaint.color = mForGround;
      forePaint.strokeWidth = 2;
      // forePaint.setAlpha(150);
      canvas.drawLine(Offset(MARGINLEFT, LOWER_CHART_TOP), Offset(viewWidth - MARGINLEFT - _mRightArea, LOWER_CHART_TOP), forePaint);
    }
  }

  /// 绘制分时图上下表边界线
  void drawTimeRegions(Canvas canvas, int viewHeight, int viewWidth) {
    if (isDrawTimeDown) {
      forePaint.color = mForGround;
      forePaint.strokeWidth = 2;
      // forePaint.setAlpha(150);
      canvas.drawLine(Offset(TimeMarginLeft, TIME_UPER_CHART_BOTTOM), Offset(viewWidth - TimeMarginRight, TIME_UPER_CHART_BOTTOM), forePaint);
      canvas.drawLine(Offset(TimeMarginLeft, TIME_LOWER_CHART_TOP), Offset(viewWidth - TimeMarginRight, TIME_LOWER_CHART_TOP), forePaint);
    }
  }

  /// 设置是否绘制下表格
  void setIsDrawLower(bool isDrawLower) {
    this.isDrawLower = isDrawLower;
    isDrawTimeDown = isDrawLower;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double viewHeight = size.height;
    double viewWidth = size.width;
    if (isDrawTime) {
      textPaint.strutStyle = StrutStyle(fontSize: DEFAULT_AXIS_TITLE_SIZE + 2);
      if (Port.drawFlag == 1) {
        textPaint.text = const TextSpan(text: "00000000");
        textPaint.layout();
        TimeMarginLeft = textPaint.width;
        textPaint.text = const TextSpan(text: "0.00%");
        textPaint.layout();
        TimeMarginRight = textPaint.width;
      } else {
        TimeMarginLeft = 2;
        TimeMarginRight = 2;
      }

      timeDownChartHeight = isDrawTimeDown ? (viewHeight - MARGINBOTTOM - MARGINTOP) ~/ (DEFAULT_TIME_LATITUDE_NUM + 1) * 3 : 0;
      TIME_UPER_CHART_BOTTOM = viewHeight - timeDownChartHeight - MARGINBOTTOM;
      TIME_LOWER_CHART_TOP = viewHeight - timeDownChartHeight - MARGINBOTTOM + TIME_UPER_LOWER_INTERVAL;
      // 绘制边框
      drawTimeBorders(canvas, viewHeight.toInt(), viewWidth.toInt());
      // 绘制分时图上下表边界线
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

      if (Port.drawFlag == 1) {
        // _mRightArea = textPaint.measureText("00000000");
      } else {
        _mRightArea = mCursorWidth;
      }

      longitudeSpacing = (viewWidth - 2 * MARGINLEFT - _mRightArea) ~/ (DEFAULT_LOGITUDE_NUM + 1);

      if (isDrawLower && isDrawMid) {
        latitudeSpacing = (viewHeight - MARGINTOP - MARGINBOTTOM - UPER_LOWER_INTERVAL) ~/
            (DEFAULT_UPER_LATITUDE_NUM + DEFAULT_LOWER_LATITUDE_NUM + DEFAULT_MID_LATITUDE_NUM + 3);
      } else if (isDrawLower && isDrawMid == false) {
        latitudeSpacing = (viewHeight - MARGINTOP - MARGINBOTTOM - UPER_LOWER_INTERVAL) ~/ (DEFAULT_UPER_LATITUDE_NUM + DEFAULT_LOWER_LATITUDE_NUM + 2);
      } else if (isDrawLower == false && isDrawMid == false) {
        latitudeSpacing = (viewHeight - MARGINTOP - MARGINBOTTOM) ~/ (DEFAULT_UPER_LATITUDE_NUM + 1);
      }

//			latitudeSpacing = isDrawLower == true ? (viewHeight - MARGINTOP-MARGINBOTTOM - UPER_LOWER_INTERVAL )
//					/ (DEFAULT_UPER_LATITUDE_NUM + DEFAULT_LOWER_LATITUDE_NUM + 2) :
//						(viewHeight - MARGINTOP-MARGINBOTTOM)
//						/ (DEFAULT_UPER_LATITUDE_NUM + 1);

      mUperChartHeight = latitudeSpacing * (DEFAULT_UPER_LATITUDE_NUM + 1);
      mMidChartHeight = latitudeSpacing * (DEFAULT_MID_LATITUDE_NUM + 1);
      mLowerChartHeight = latitudeSpacing * (DEFAULT_LOWER_LATITUDE_NUM + 1);

      mChartWidth = longitudeSpacing * (DEFAULT_LOGITUDE_NUM + 1);

      UPER_CHART_BOTTOM = MARGINTOP + latitudeSpacing * (DEFAULT_UPER_LATITUDE_NUM + 1);
      MID_CHART_TOP = UPER_CHART_BOTTOM + UPER_LOWER_INTERVAL;
      LOWER_CHART_TOP = viewHeight - MARGINBOTTOM - latitudeSpacing * (DEFAULT_LOWER_LATITUDE_NUM + 1);

      // 绘制边框
      drawBorders(canvas, viewHeight.toInt(), viewWidth.toInt());

      // 绘制纬线
      drawLatitudes(canvas, viewHeight.toInt(), viewWidth.toInt(), latitudeSpacing);

      // 绘制上下表边界线
      drawRegions(canvas, viewHeight.toInt(), viewWidth.toInt());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  static double getChartWidth() {
    return mChartWidth;
  }
}
