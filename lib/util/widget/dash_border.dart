import 'package:fluent_ui/fluent_ui.dart';

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashWidth;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.dashWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 绘制圆角虚线边框
    _drawDashedRRect(canvas, rrect, paint);
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    // 计算圆角矩形的路径
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double start = 0.0;
      while (start < metric.length) {
        final end = (start + dashWidth).clamp(0.0, metric.length);
        if (end > start) {
          final extractPath = metric.extractPath(start, end);
          canvas.drawPath(extractPath, paint);
        }
        start = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}