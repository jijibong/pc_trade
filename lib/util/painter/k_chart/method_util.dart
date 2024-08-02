import 'package:flutter/cupertino.dart';

///绘图画笔
class MethodUntil {
  Paint getDrawPaint(Color color) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    return paint;
  }

  TextPainter getTextPainter(double size) {
    TextPainter paint = TextPainter();
    paint.strutStyle = StrutStyle(fontSize: size);
    paint.textDirection = TextDirection.ltr;
    // paint.color=color;
    // paint.style=PaintingStyle.fill; // 设置实心的
    // paint.isAntiAlias=true;
    return paint;
  }
}
