import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrapeziumPainter extends CustomPainter {
  Color color;
  TrapeziumPainter({required this.color}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path();
    // path
    //   ..relativeMoveTo(-3.sp, 0) //左上
    //   ..relativeLineTo(12.sp, -9.sp) //右上
    //   ..relativeLineTo(0, size.height * 1.6) //右下
    //   ..relativeLineTo(-12.sp, -9.sp); //左下
    // path
    //   ..relativeMoveTo(-9, 0) //左上
    //   ..relativeLineTo(36, -27) //右上
    //   ..relativeLineTo(0, size.height * 1.6) //右下
    //   ..relativeLineTo(-36, -27);
    path
      ..relativeMoveTo(-9, 0) //左上
      ..relativeLineTo(36, -27) //右上
      ..relativeLineTo(0, size.height * 1.6) //右下
      ..relativeLineTo(-36, -27);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
