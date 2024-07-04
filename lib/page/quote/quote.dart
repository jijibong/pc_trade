import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../util/style/paint.dart';

class Quote extends StatefulWidget {
  const Quote({super.key});

  @override
  State<Quote> createState() => _QuoteState();
}

class _QuoteState extends State<Quote> {
  int selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Row(
        children: [
          Column(
            children: [
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.sp, vertical: 10.sp),
                  alignment: Alignment.center,
                  child: CustomPaint(
                    painter: TrapeziumPainter(),
                    child: Text(
                      '自\n选\n界\n面',
                      style: TextStyle(
                        fontSize: 6.sp,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.sp, vertical: 10.sp),
                  alignment: Alignment.center,
                  child: CustomPaint(
                    painter: TrapeziumPainter(selected:false),
                    child: Text(
                      '国\n际\n期\n货',
                      style: TextStyle(
                        fontSize: 6.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(child: Container())
        ],
      ),
    );
  }
}
