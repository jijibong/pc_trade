import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  /// 虚线的颜色
  final Color color;

  /// 虚线的宽度
  final double strokeWidth;

  /// 单个线段的长度
  final double dashLength;

  /// 线段之间的间距
  final double dashSpacing;

  /// 分割线的方向，水平或垂直
  final Axis axis;

  /// 分割线的长度，如果是水平方向则是宽度，如果是垂直方向则是高度
  final double length;

  const DashedDivider({
    super.key,
    this.color = Colors.grey,
    this.strokeWidth = 2.0,
    this.dashLength = 3.0,
    this.dashSpacing = 3.0,
    this.axis = Axis.horizontal,
    this.length = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: axis == Axis.horizontal ? length : strokeWidth,
      height: axis == Axis.vertical ? length : strokeWidth,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color,
          strokeWidth: strokeWidth,
          dashLength: dashLength,
          dashSpacing: dashSpacing,
          axis: axis,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpacing;
  final Axis axis;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashSpacing,
    required this.axis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    double start = 0.0;
    final double totalLength = axis == Axis.horizontal ? size.width : size.height;

    while (start < totalLength) {
      final double end = start + dashLength;

      if (axis == Axis.horizontal) {
        canvas.drawLine(
          Offset(start, 0),
          Offset(end > totalLength ? totalLength : end, 0),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(0, start),
          Offset(0, end > totalLength ? totalLength : end),
          paint,
        );
      }

      start = end + dashSpacing;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashLength != oldDelegate.dashLength ||
        dashSpacing != oldDelegate.dashSpacing ||
        axis != oldDelegate.axis;
  }
}

// 使用示例
class DashedDividerExample extends StatelessWidget {
  const DashedDividerExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('虚线分割线示例'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('默认虚线分割线'),
            DashedDivider(),
            SizedBox(height: 20),

            Text('红色粗虚线'),
            DashedDivider(
              color: Colors.red,
              strokeWidth: 2.0,
              dashLength: 8.0,
              dashSpacing: 4.0,
            ),
            SizedBox(height: 20),

            Text('垂直虚线示例'),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Text('左侧内容')),
                DashedDivider(
                  axis: Axis.vertical,
                  length: 50.0,
                  color: Colors.blue,
                ),
                Expanded(child: Text('右侧内容')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
