import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_drawing/path_drawing.dart';

abstract class BasePainter extends CustomPainter {
  final Paint _painter = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..isAntiAlias = true;

  final Paint _fillPainter = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill
    ..strokeWidth = 1
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(BasePainter oldDelegate) {
    return false;
  }
}

class StraightLine extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), _painter);
  }
}

class RayLine extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path(); // 绘制虚线
    path.moveTo(size.width / 2, size.height / 2);
    path.lineTo(size.width, 0);
    canvas.drawLine(Offset(0, size.height), Offset(size.width / 2, size.height / 2), _painter);
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>([2, 2]),
      ),
      _painter,
    );
  }
}

class HorizontalLine extends BasePainter {
  double? width;
  Color? color;
  HorizontalLine({this.width, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    _painter.strokeWidth = width ?? 1;
    if (color != null) _painter.color = color!;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), _painter);
  }
}

class VerticalLine extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), _painter);
  }
}

class LineSegment extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), _painter);
    canvas.drawCircle(Offset(0, size.height), 2, _fillPainter);
    canvas.drawCircle(Offset(size.width, 0), 2, _fillPainter);
  }
}

class ParallelLines extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height * 9 / 10), Offset(size.width, size.height * 5 / 10), _painter);
    canvas.drawLine(Offset(0, size.height * 5 / 10), Offset(size.width, size.height * 1 / 10), _painter);
  }
}

class HorizontalParallelLines extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height * 7 / 10), Offset(size.width, size.height * 7 / 10), _painter);
    canvas.drawLine(Offset(0, size.height * 3 / 10), Offset(size.width, size.height * 3 / 10), _painter);
  }
}

class SquarePainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    double padding = 0;
    canvas.drawRect(Rect.fromLTWH(padding, padding, size.width - padding * 2, size.height - padding * 2), _painter);
  }
}

class TrianglePainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(size.width / 2, 0) // 顶部中心点
      ..lineTo(0, size.height) // 左下角
      ..lineTo(size.width, size.height) // 右下角
      ..close(); // 闭合路径

    canvas.drawPath(path, _painter); // 在画布上绘制路径
  }
}

class UShapePainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0, 0); // 起点
    path.quadraticBezierTo(0, size.height, size.width / 2, size.height); // 底部曲线
    path.lineTo(size.width / 2, size.height); // 右侧直线
    path.quadraticBezierTo(size.width, size.height, size.width, 0); // 右侧曲线
    canvas.drawPath(path, _painter); // 在画布上绘制路径
  }
}

class GansLinePainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset originalPoint = Offset(0, size.height);
    canvas.drawLine(originalPoint, const Offset(0, 0), _painter);
    canvas.drawLine(originalPoint, Offset(size.width / 2, 0), _painter);
    canvas.drawLine(originalPoint, Offset(size.width, 0), _painter);
    canvas.drawLine(originalPoint, Offset(size.width, size.height / 2), _painter);
    canvas.drawLine(originalPoint, Offset(size.width, size.height), _painter);
  }
}

class ResistanceLinePainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset originalPoint = Offset(0, size.height);
    canvas.drawLine(originalPoint, Offset(size.width, 0), _painter);
    canvas.drawLine(originalPoint, Offset(size.width, size.height / 2), _painter);
    canvas.drawLine(originalPoint, Offset(size.width, size.height), _painter);
  }
}

class SymmetricalAngleLinePainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset originalPoint = Offset(size.width / 2, 0);
    canvas.drawLine(originalPoint, Offset(0, size.height), _painter);
    canvas.drawLine(originalPoint, Offset(size.width / 2, size.height), _painter);
    canvas.drawLine(originalPoint, Offset(size.width, size.height), _painter);
  }
}

class RoundPainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, _painter);
  }
}

class EllipsePainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(Rect.fromLTWH(0, size.height / 4, size.width, size.height / 2), _painter);
  }
}

class DegreesUpPainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset originalPoint = Offset(0, size.height);

    canvas.drawLine(
      originalPoint,
      Offset(size.width, size.height), // 水平线
      _painter,
    );

    canvas.drawLine(
      originalPoint,
      Offset(size.width, 0), // 45度线
      _painter,
    );

    // 绘制角度弧线
    canvas.drawArc(
      Rect.fromCircle(center: originalPoint, radius: size.width * 0.5),
      0,
      -pi / 4,
      false,
      _painter,
    );
  }
}

class DegreesDownPainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset originalPoint = const Offset(0, 0);

    canvas.drawLine(
      originalPoint,
      Offset(size.width, 0), // 水平线
      _painter,
    );

    canvas.drawLine(
      originalPoint,
      Offset(size.width, size.height), // 45度线
      _painter,
    );

    // 绘制角度弧线
    canvas.drawArc(
      Rect.fromCircle(center: originalPoint, radius: size.width * 0.5),
      0,
      pi / 4,
      false,
      _painter,
    );
  }
}

class MultipleArcsPainter extends BasePainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset originalPoint = Offset(size.width / 2, size.height / 4 * 3);
    canvas.drawArc(
      Rect.fromCircle(center: originalPoint, radius: size.width * 0.2),
      0,
      -pi,
      false,
      _painter,
    );
    canvas.drawArc(
      Rect.fromCircle(center: originalPoint, radius: size.width * 0.38),
      0,
      -pi,
      false,
      _painter,
    );
    canvas.drawArc(
      Rect.fromCircle(center: originalPoint, radius: size.width * 0.5),
      0,
      -pi,
      false,
      _painter,
    );
  }
}

class DashedLinePainter extends BasePainter {
  List<double>? list;
  Color? color;
  DashedLinePainter({this.list,this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (color != null) _painter.color = color!;
    Path path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, size.height / 2); // 右侧直线
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(list ?? [4, 4]),
      ),
      _painter,
    );
  }
}
