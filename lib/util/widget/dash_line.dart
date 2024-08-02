import 'package:fluent_ui/fluent_ui.dart';

class DashedLine extends StatelessWidget {
  final Color dashColor;
  final double strokeWidth;
  final double dashRadius;
  final int dashCount;
  final Axis axis;
  final List<Widget> children;

  const DashedLine({
    super.key,
    this.dashColor = const Color(0xff000000),
    this.strokeWidth = 1.5,
    this.dashRadius = 1.0,
    this.dashCount = 8,
    this.axis = Axis.horizontal,
    this.children = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    final Paint paint = Paint()
      ..color = dashColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    return CustomPaint(
      painter: _DashedLinePainter(paint, dashRadius, dashCount, axis),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Paint _paint;
  final double _dashRadius;
  final int _dashCount;
  final Axis _axis;

  _DashedLinePainter(this._paint, this._dashRadius, this._dashCount, this._axis);

  @override
  void paint(Canvas canvas, Size size) {
    // final double dashLength = _dashRadius * 2;
    // final double gapLength = _dashRadius * 2;
    final double dashLength = _dashRadius * 0.5;
    final double gapLength = _dashRadius * 5;
    double startPoint = 0.0;

    if (_axis == Axis.horizontal) {
      while (startPoint < size.width) {
        canvas.drawLine(
          Offset(startPoint, size.height / 2),
          Offset(startPoint + dashLength, size.height / 2),
          _paint,
        );
        startPoint += dashLength + gapLength;
      }
    } else {
      while (startPoint < size.height) {
        canvas.drawLine(
          Offset(size.width / 2, startPoint),
          Offset(size.width / 2, startPoint + dashLength),
          _paint,
        );
        startPoint += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) {
    return _paint != oldDelegate._paint || _dashRadius != oldDelegate._dashRadius || _dashCount != oldDelegate._dashCount || _axis != oldDelegate._axis;
  }
}
