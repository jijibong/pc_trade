import 'package:flutter/material.dart';

import '../../../model/k/port.dart';
import '../../utils/utils.dart';
import 'method_util.dart';

class DrawView extends CustomPainter {
  Paint customPaint = Paint();
  TextPainter textPaint = TextPainter();
  double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  static const Color color = Color.fromRGBO(255, 255, 255, 1);

  double currentX = 0;
  double currentY = 0;

  @override
  void paint(Canvas canvas, Size size) {}

  static int getNumber(int position, double marginLeft, double pWidth, int showNum) {
    int number = 0;
    int num = ((position - marginLeft) % pWidth).toInt();
    if (num == 0) {
      number = (position - marginLeft) ~/ pWidth;
    } else {
      number = ((position - marginLeft) / pWidth + 1).toInt();
    }

    number = number < 1 ? 1 : number;
    number = number > showNum ? showNum : number;
    return number;
  }

  static double dealY(double Y, double viewHeight, double marginBottom, double marginTop) {
    double positionY = Y;
    positionY = positionY > viewHeight - marginBottom ? viewHeight - marginBottom : positionY;
    positionY = positionY < marginTop ? marginTop : positionY;
    return positionY;
  }

  static void drawLines(Canvas canvas, double viewHeight, double viewWidth, double X, double Y, double mPointWidth, double MARGINTOP,
      double MARGINBOTTOM, double MARGINLEFT, double leftMarginSpace, double MARGINRIGHT, int showNum) {
    int number = getNumber(X.toInt(), MARGINLEFT + leftMarginSpace, mPointWidth, showNum);
    X = MARGINLEFT + number * mPointWidth + leftMarginSpace;
    Y = dealY(Y, viewHeight, MARGINBOTTOM, MARGINTOP);

    double startX = X;
    double startY = viewHeight - MARGINBOTTOM;
    double stopX = X;
    double stopY = MARGINTOP;
    Paint framePaint = MethodUntil().getDrawPaint(const Color.fromRGBO(38, 41, 55, 1));
    framePaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = Utils.dp2px(1);
    //竖线
    canvas.drawLine(Offset(startX, startY), Offset(stopX, stopY), framePaint);

    startX = MARGINLEFT;
    startY = Y;
    stopX = viewWidth - MARGINRIGHT;
    stopY = Y;

    //横线
    canvas.drawLine(Offset(startX, startY), Offset(stopX, stopY), framePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
