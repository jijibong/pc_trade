import 'package:path_drawing/path_drawing.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../../util/painter/k_chart/method_util.dart';
import '../../../util/painter/k_chart/sub_chart_painter.dart';
import '../../../util/utils/utils.dart';
import '../OHLCEntity.dart';
import '../port.dart';
import 'CalcIndexData.dart';

/**
 * 商品路径CCI指标线绘制，数据计算
 * @author hexuejian
 *
 */
class CCIEntity {
  /**CCI数据集合*/
  List<double> CCIs = [];
  /**CCI最高价*/
  double maxPrice = 0.0;
  /**CCI最低价*/
  double minPrice = 0.0;
  /** 默认字体大小 **/
  static double DEFAULT_AXIS_TITLE_SIZE = Port.ChartTextSize;
  /** 默认虚线效果 */
  List<double> DEFAULT_DASH_EFFECT = [2, 1];
  // static final PathEffect DEFAULT_DASH_EFFECT = new DashPathEffect(new double[] { 2, 3, 2,
  // 3 }, 1);
  /** 虚线颜色 */
  static const Color DEFAULT_DOTTED_COLOR = Colors.grey;
  /**增加数据类*/
  CalcIndexData mCalcData = CalcIndexData();

  CCIEntity() {
    CCIs = [];
  }

  /**
   * 初始化CCI数据
   * @param OHLCData
   * @param period
   * @param pri_type
   */
  void initData(List<OHLCEntity> OHLCData, int period, int pri_type) {
    CCIs.clear();

    if (OHLCData == null || OHLCData.isEmpty) {
      return;
    }

    for (int i = period - 1; i < OHLCData.length; i++) {
      double cci = mCalcData.calcCCI(OHLCData, period, i);
      CCIs.add(cci);
    }
  }

  /**
   * 获得Rsi价格
   */
  double getPrice(List<OHLCEntity> OHLCData, int j, int i, int period, int pri_type) {
    num price = 0.0;
    switch (pri_type) {
      case 0: //开
        price = (OHLCData[j + i - (period - 1)].open ?? 0) - (OHLCData[j + i - (period - 1) - 1].open ?? 0);
        break;

      case 1: //高
        price = (OHLCData[j + i - (period - 1)].high ?? 0) - (OHLCData[j + i - (period - 1) - 1].high ?? 0);
        break;

      case 2: //收
        price = (OHLCData[j + i - (period - 1)].close ?? 0) - (OHLCData[j + i - (period - 1) - 1].close ?? 0);
        break;

      case 3: //低
        price = (OHLCData[j + i - (period - 1)].low ?? 0) - (OHLCData[j + i - (period - 1) - 1].low ?? 0);
        break;

      case 4: //高低一半
        price = ((OHLCData[j + i - (period - 1)].high ?? 0) + (OHLCData[j + i - (period - 1)].low ?? 0)) / 2 -
            ((OHLCData[j + i - (period - 1) - 1].high ?? 0) + (OHLCData[j + i - (period - 1) - 1].low ?? 0)) / 2;
        break;

      default:
        break;
    }
    return price.toDouble();
  }

  /**
   * 增加cci数据
   * @param OHLCData
   * @param period
   * @param pri_type
   * @param count
   */
  void addData(List<OHLCEntity> OHLCData, int period, int pri_type, int count) {
    if (CCIs.isEmpty) {
      return;
    }

    if (mCalcData.calcCCI(OHLCData, period, OHLCData.length - 1) == double.maxFinite) return;

    CCIs.remove(CCIs.length - 1);

    for (int i = count; i > 0; i--) {
      double cci = mCalcData.calcCCI(OHLCData, period, OHLCData.length - i);
      CCIs.add(cci);
    }
  }

  /**
   * 计算CCI的最高最低价
   */
  void calclatePrice(int mDataStartIndext, int showNumber, int period) {
    if (CCIs.isEmpty) {
      return;
    }
    //当前绘制到的K线根数大于kdj周期时，从第period根K线的时候才有kdj数据
    int lotion = mDataStartIndext - (period - 1) < 0 ? 0 : mDataStartIndext - (period - 1);
    minPrice = CCIs[lotion];
    maxPrice = CCIs[lotion];

    for (int i = lotion; i < mDataStartIndext + showNumber - (period - 1); i++) {
      if (i < CCIs.length) {
        minPrice = minPrice < CCIs[i] ? minPrice : CCIs[i];
        maxPrice = maxPrice > CCIs[i] ? maxPrice : CCIs[i];
      }
    }
  }

  void drawCCI(Canvas canvas, double viewHeight, double viewWidth, int mDataStartIndext, int mShowDataNum, double mCandleWidth, int CANDLE_INTERVAL,
      double leftMarginSpace, double halfTextHeight, int CCIPeriod) {
    double textBottom = Port.defult_margin_top;
    double lowerHeight = viewHeight - textBottom - halfTextHeight * 2;
    double latitudeSpacing = lowerHeight / 4; //每格高度
    double rate = 0.0; //每单位像素价格
    Paint purplePaint = MethodUntil().getDrawPaint(Port.CCIColor);
    TextPainter textPaint = TextPainter(); // MethodUntil().getDrawPaint(Port.chartTxtColor);
    Paint dottedPaint = MethodUntil().getDrawPaint(Port.girdColor); //虚线画笔
    dottedPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    purplePaint.strokeWidth = Port.CCIWidth[0];

    rate = lowerHeight / (maxPrice - minPrice);

    //绘制虚线
    double perPrice = (maxPrice - minPrice) / 3; //计算每一格纬线框所占有的价格
    for (int i = 1; i <= 3; i++) {
      Path path = Path(); // 绘制虚线
      path.moveTo(leftMarginSpace, latitudeSpacing * i + textBottom);
      path.lineTo(viewWidth - leftMarginSpace, latitudeSpacing * i + textBottom);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(DEFAULT_DASH_EFFECT),
        ),
        dottedPaint,
      );
      //绘制价格
      double textWidth = SubChartPainter.getStringWidth("${Utils.getPointNum(minPrice + perPrice * i)} ", textPaint);
      textPaint
        ..text = TextSpan(text: Utils.getPointNum(minPrice + perPrice * i), style: TextStyle(color: Port.chartTxtColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
        ..textDirection = TextDirection.ltr
        ..layout()
        ..paint(canvas, Offset(leftMarginSpace - textWidth, lowerHeight - latitudeSpacing * i + textBottom - halfTextHeight));
    }

    //绘制cci
    for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum; i++) {
      int number = (i - mDataStartIndext + 1) >= mShowDataNum ? i - mDataStartIndext : (i - mDataStartIndext + 1);
      double startX = mCandleWidth * (i - mDataStartIndext) + mCandleWidth + leftMarginSpace;
      double nextX = mCandleWidth * (number) + mCandleWidth + leftMarginSpace;

      //从周期开始才绘制CCI
      if (i >= CCIPeriod - 1) {
        //K线
        int nextNumber = (i - mDataStartIndext + 1) >= mShowDataNum ? i - (CCIPeriod - 1) : i - (CCIPeriod - 1) + 1;
        if (nextNumber < CCIs.length) {
          double startY = (maxPrice - CCIs[i - (CCIPeriod - 1)]) * rate + textBottom+ halfTextHeight * 2;
          double stopY = (maxPrice - CCIs[nextNumber]) * rate + textBottom+ halfTextHeight * 2;
          canvas.drawLine(Offset(startX, startY), Offset(nextX, stopY), purplePaint);
        }
      }

      //绘制当前周期，最新一根数据的KDJ
      if (i == (mDataStartIndext + mShowDataNum - 1) && (i - (CCIPeriod - 1)) < CCIs.length) {
        String cci;
        if ((mDataStartIndext + mShowDataNum) > CCIPeriod) {
          cci = Utils.getPointNum(CCIs[i - (CCIPeriod - 1)]);
        } else {
          cci = "0.000";
        }

        String text = "CCI($CCIPeriod): ($cci)";
        textPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.CCIColor, fontSize: DEFAULT_AXIS_TITLE_SIZE))
          ..textDirection = TextDirection.ltr
          ..layout()
          ..paint(canvas, Offset(Port.defult_icon_width + leftMarginSpace, Port.text_check));
      }
    }
  }
}
