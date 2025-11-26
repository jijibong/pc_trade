import 'package:flutter/cupertino.dart';

///绘图画笔
class MethodUntil {
  Paint getDrawPaint(Color color) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    return paint;
  }

  Paint getFillPaint(Color color) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    return paint;
  }

  Paint getDashPaint(Color color) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
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

  TextPainter getDialogTextPainter(double size) {
    TextPainter paint = TextPainter(
      strutStyle: StrutStyle(fontSize: size),
      textDirection: TextDirection.ltr, // 文本方向（这里用ltr，通过对齐方式控制）
      textAlign: TextAlign.right, // 关键：右对齐
    );
    return paint;
  }
}
