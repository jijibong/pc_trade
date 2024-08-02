import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:trade/util/utils/utils.dart';
import '../../model/k/OHLCEntity.dart';
import '../../model/k/golden_line.dart';
import '../../model/k/k_flag.dart';
import '../../model/k/k_preiod.dart';
import '../../model/k/k_time.dart';
import '../../model/k/oblique_line.dart';
import '../../model/k/port.dart';
import '../../model/k/transverse_line.dart';
import '../../model/k/vertical_line.dart';
import '../log/log.dart';
import '../painter/k_chart/grid_view.dart';
import '../painter/k_chart/k_chart_painter.dart';
import '../shared_preferences/shared_preferences_key.dart';
import '../shared_preferences/shared_preferences_utils.dart';

class KUtils {
  ///查询K线周期
  static Future<List<KPeriod>> getKPeriodList(bool isNeedFs, bool isAll) async {
    List<KPeriod> kPeriodList = [];
    String? string = await SpUtils.getString(SpKey.kPeriod);
    if (string != null) {
      List tmp = jsonDecode(string);
      kPeriodList = tmp.map((e) => KPeriod.fromJson(e)).toList();
    }
    if (!isAll) {
      kPeriodList.removeWhere((element) => element.isDel != false);
    }

    if (isNeedFs) {
      KPeriod fs = KPeriod(name: "分时", period: KTime.FS, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
      kPeriodList.insert(0, fs);
    }
    for (var element in kPeriodList) {
      element.isSelected = false;
    }
    return kPeriodList;
  }

  ///处理分时数据
  static List<OHLCEntity> dealFsData(List<OHLCEntity>? response, List<String> tradeTimes, double preClose, String excd) {
    List<OHLCEntity> allList = [];

    if (tradeTimes.isNotEmpty && response != null && response.isNotEmpty) {
      String? endDate = response.last.date;
      String? endTime = response.last.time;
      String? startDate = tradeTimes.first.split(" ")[0];
      String? startTime = tradeTimes.first.split(" ")[1];

      if (endDate == startDate) {
        String lastTime = "$endDate $endTime";
        String dataTime = Utils.getNextMin("$startDate $startTime");
        while (dataTime != lastTime) {
          OHLCEntity ohlc = OHLCEntity();
          ohlc.date = dataTime.split(" ")[0];
          ohlc.time = dataTime.split(" ")[1];
          allList.add(ohlc);
          bool isTradeTime = false;
          int loc = -1;
          for (var element in tradeTimes) {
            if (dataTime == element) {
              isTradeTime = true;
              loc = tradeTimes.indexOf(element);
              break;
            }
          }
          if (isTradeTime) {
            if (loc + 1 < tradeTimes.length) {
              dataTime = Utils.getNextMin(tradeTimes[loc + 1]);
            } else {
              dataTime = Utils.getNextMin(tradeTimes.last);
            }
          } else {
            dataTime = Utils.getNextMin(dataTime);
          }
        }
      } else {
        if (Utils.getWeek(endDate) == 1) {
          startDate = Utils.getDayBefore(endDate!, 3);
          if (excd == "HKEX") {
            List<String> relist = [];
            for (int i = 0; i < tradeTimes.length; i++) {
              if (i <= 1) {
                relist.add(tradeTimes[i]);
              } else {
                String time = tradeTimes[i].split(" ")[1];
                relist.add("$endDate $time");
              }
            }

            tradeTimes.clear();
            tradeTimes.addAll(relist);
          }
        }
        String lastTime = "$endDate $endTime";
        String dataTime = Utils.getNextMin("$startDate $startTime");
        while (dataTime != lastTime) {
          OHLCEntity ohlc = OHLCEntity();
          ohlc.date = dataTime.split(" ")[0];
          ohlc.time = dataTime.split(" ")[1];
          ohlc.timeStamp = Utils.getTimeStamp10(dataTime);
          allList.add(ohlc);

          bool isTradeTime = false;
          int loc = -1;
          for (int i = 0; i < tradeTimes.length; i++) {
            if (dataTime == tradeTimes[i]) {
              isTradeTime = true;
              loc = i;
              break;
            }
          }
          if (isTradeTime) {
            dataTime = Utils.getNextMin(tradeTimes[loc + 1]);
          } else {
            dataTime = Utils.getNextMin(dataTime);
          }
        }
      }

      Map<String, OHLCEntity> map = {};
      for (var element in response) {
        map["${element.date} ${element.time}"] = element;
      }

      for (var element in allList) {
        String strTime = "${element.date} ${element.time}";
        if (map.containsKey(strTime)) {
          element.close = map[strTime]?.close;
          element.preClose = map[strTime]?.preClose;
          element.amount = map[strTime]?.amount;
          element.volume = map[strTime]?.volume;
        } else {
          num? price = 0;
          if (preClose == 0) {
            for (var element in response) {
              if (element.close != null) {
                preClose = element.close!.toDouble();
                break;
              }
            }
          }
          if (allList.indexOf(element) == 0) {
            price = preClose;
          } else {
            price = allList[allList.indexOf(element) - 1].close;
          }
          element.close = price;
        }
      }
      //计算均价
      for (int i = 0; i < allList.length; i++) {
        num? average = 0;
        if (i == 0) {
          average = allList[i].close;
        } else {
          double price = 0;
          for (int j = 0; j <= i; j++) {
            price = price + allList[j].close!;
          }
          average = num.parse((price / (i + 1)).toStringAsFixed(4));
        }
        allList[i].average = average;
      }
    }

    return allList;
  }

  /// 判断此横线是否在当前屏幕内
  static bool isShowTrans(TransverseLine transverseLine, ChartPainter mChartPainter, double maxPrice, double minPrice) {
    bool isShowing = false;
    if (transverseLine.flag == 0) {
      //k线区域
      double price = transverseLine.price;
      if (price >= minPrice && price <= maxPrice) {
        isShowing = true;
      }
      // } else if (transverseLine.flag == 1) {
      //   //RSI,DMI
      //   double maxPrice = mChartPainter.getLowMaxPrice();
      //   double minPrice = mChartPainter.getLowMinPrice();
      //   double price = transverseLine.price;
      //   if (price >= minPrice && price <= maxPrice) {
      //     isShowing = true;
      //   }
      // } else if (transverseLine.flag == 2) {
      //   //MACD
      //   double maxPrice = mChartPainter.getLowMaxPrice();
      //   double minPrice = mChartPainter.getLowMinPrice();
      //   double price = transverseLine.price;
      //   if (price >= minPrice && price <= maxPrice) {
      //     isShowing = true;
      //   }
    }

    return isShowing;
  }

  /// 判断此竖线是否在当前屏幕内
  static bool isShowX(VerticalLine verticalLine, ChartPainter mChartPainter, int start, int count) {
    bool isShowing = false;
    String date = verticalLine.date;

    for (int i = start; i < start + count; i++) {
      String sDate = "";
      if (i < mChartPainter.getOHLCData().length) {
        sDate = "${mChartPainter.getOHLCData()[i].date} ${mChartPainter.getOHLCData()[i].time}";
      }

      if (date == sDate) {
        isShowing = true;
      }
    }

    return isShowing;
  }

  /// 获取此条竖线的横坐标
  static double getVerticalX(VerticalLine verticalLine, ChartPainter mChartPainter, int start, int count, double mCandleWidth) {
    double X = 0;
    String date = verticalLine.date;

    for (int i = start; i < start + count; i++) {
      String sDate = "";
      if (i < mChartPainter.getOHLCData().length) {
        sDate = "${mChartPainter.getOHLCData()[i].date} ${mChartPainter.getOHLCData()[i].time}";
      }

      if (date == sDate) {
        int number = i - start + 1;
        X = (mCandleWidth * number) + GridChart.MARGINLEFT;
      }
    }

    return X;
  }

  /// 获取此条横线的纵坐标
  static double getTransY(TransverseLine transverseLine, ChartPainter mChartPainter, double maxPrice, double minPrice) {
    double Y = 0;
    if (transverseLine.flag == 0) {
      //k线区域
      double rate = (maxPrice - minPrice) / mChartPainter.mUperChartHeight;
      double price = transverseLine.price;
      Y = (mChartPainter.MARGINTOP + mChartPainter.mUperChartHeight - (price - minPrice) / rate);
      // } else if (transverseLine.flag == 1) {
      //   //RSI,DMI
      //   double maxPrice = mChartPainter.getLowMaxPrice();
      //   double minPrice = mChartPainter.getLowMinPrice();
      //   double rate = (maxPrice - minPrice) / mChartPainter.getDownChartHeight();
      //   double price = transverseLine.price;
      //   Y = (mChartPainter.kChartViewHeight - mChartPainter.getMarginBottom() - (price - minPrice) / rate);
      // } else if (transverseLine.flag == 2) {
      //   //MACD
      //   double maxPrice = mChartPainter.getLowMaxPrice();
      //   double minPrice = mChartPainter.getLowMinPrice();
      //   double rate = (maxPrice - minPrice) / mChartPainter.getDownChartHeight();
      //   double price = transverseLine.price;
      //   Y = (mChartPainter.kChartViewHeight - mChartPainter.getMarginBottom() - (price - minPrice) / rate);
    }

    return Y;
  }

  ///判断该斜线是否在屏幕内
  static bool isShowOblique(ObliqueLine obliqueLine, ChartPainter mChartPainter, int start, int mShowDataNum, double mMaxPrice, double mMinPrice) {
    bool isShow = false;
    String startDate = obliqueLine.startDate;
    String endDate = obliqueLine.endDate;
    int end = start + mShowDataNum - 1;
    double startPrice = obliqueLine.startPrice;
    double endPrice = obliqueLine.endPrice;
    int startNum = 0;
    int endNum = 0;
    double maxPrice = 0;
    double minPrice = 0;

    if (obliqueLine.flag == 0) {
      //k线区域
      maxPrice = mMaxPrice;
      minPrice = mMinPrice;
      // } else {
      //   //副图指标线区域
      //   maxPrice = mChartPainter.getLowMaxPrice();
      //   minPrice = mChartPainter.getLowMinPrice();
    }

    for (int i = 0; i < mChartPainter.getOHLCData().length; i++) {
      String date = "${mChartPainter.getOHLCData()[i].date} ${mChartPainter.getOHLCData()[i].time}";
      if (date == startDate) {
        startNum = i;
      }
      if (date == endDate) {
        endNum = i;
      }
    }

    if (startPrice >= minPrice &&
        startPrice <= maxPrice &&
        endPrice >= minPrice &&
        endPrice <= maxPrice &&
        startNum >= start &&
        startNum <= end &&
        endNum >= start &&
        endNum <= end) {
      isShow = true;
    }

    return isShow;
  }

  ///获取此条斜线各点的纵坐标
  static double getChartObliqueY(ObliqueLine obliLine, double price, ChartPainter mChartPainter, double maxPrice, double minPrice) {
    double Y = 0;
    if (obliLine.flag == 0) {
      //k线区域
      double rate = (maxPrice - minPrice) / mChartPainter.mUperChartHeight;
      Y = (mChartPainter.MARGINTOP + mChartPainter.mUperChartHeight - (price - minPrice) / rate);
      // } else if (obliLine.flag == 1) {
      //   //RSI,DMI
      //   double maxPrice = mChartPainter.getLowMaxPrice();
      //   double minPrice = mChartPainter.getLowMinPrice();
      //   double rate = (maxPrice - minPrice) / mChartPainter.getDownChartHeight();
      //   Y = (mChartPainter.kChartViewHeight - mChartPainter.getMarginBottom() - (price - minPrice) / rate);
      // } else if (obliLine.flag == 2) {
      //   //MACD
      //   double maxPrice = mChartPainter.getLowMaxPrice();
      //   double minPrice = mChartPainter.getLowMinPrice();
      //   double rate = (maxPrice - minPrice) / mChartPainter.getDownChartHeight();
      //   Y = (mChartPainter.kChartViewHeight - mChartPainter.getMarginBottom() - (price - minPrice) / rate);
    }
    return Y;
  }

  /// 获得此日期对应的K线根数
  static int getKNumber(String sDate, ChartPainter mChartPainter, int start, int mShowDataNum) {
    int number = 0; //K线根数
    int count = start + mShowDataNum;
    for (int i = start; i < count; i++) {
      String date = "";
      if (i < mChartPainter.getOHLCData().length) {
        date = "${mChartPainter.getOHLCData()[i].date} ${mChartPainter.getOHLCData()[i].time}";
      }
      if (sDate == date) {
        number = i - start + 1;
      }
    }
    number = number >= mShowDataNum ? mShowDataNum : number;
//			number = number < 1 ? 1 : number;
    if (number == 0) {
      String dateStart = "${mChartPainter.getOHLCData()[start].date} ${mChartPainter.getOHLCData()[start].time}";
      String dateEnd = "${mChartPainter.getOHLCData()[count - 1].date} ${mChartPainter.getOHLCData()[count - 1].time}";
      if (Utils.compareDate(dateEnd, sDate) == 1) {
        number = mShowDataNum;
      }
      if (Utils.compareDate(sDate, dateStart) == 1) {
        number = 1;
      }
    }
    return number;
  }

  ///判断该黄金分割线是否在屏幕内
  static bool isShowGolden(GoldenLine obliqueLine, ChartPainter mChartPainter, int start, int mShowDataNum, double mMaxPrice, double mMinPrice) {
    bool isShow = false;
    String startDate = obliqueLine.startDate;
    String endDate = obliqueLine.endDate;
    int end = start + mShowDataNum - 1;
    double startPrice = obliqueLine.startPrice;
    double endPrice = obliqueLine.endPrice;
    int startNum = 0;
    int endNum = 0;
    double maxPrice = 0;
    double minPrice = 0;

    if (obliqueLine.flag == 0) {
      //k线区域
      maxPrice = mMaxPrice;
      minPrice = mMinPrice;
      // } else {
      //   //副图指标线区域
      //   maxPrice = mChartPainter.getLowMaxPrice();
      //   minPrice = mChartPainter.getLowMinPrice();
    }

    for (int i = 0; i < mChartPainter.getOHLCData().length; i++) {
      String date = "${mChartPainter.getOHLCData()[i].date} ${mChartPainter.getOHLCData()[i].time}";
      if (date == startDate) {
        startNum = i;
      }
      if (date == endDate) {
        endNum = i;
      }
    }
    if (startPrice >= minPrice &&
        startPrice <= maxPrice &&
        endPrice >= minPrice &&
        endPrice <= maxPrice &&
        startNum >= start &&
        startNum <= end &&
        endNum >= start &&
        endNum <= end) {
      isShow = true;
    }
    return isShow;
  }

  ///获取此条黄金分割线各点的纵坐标
  static double getChartGoldenY(GoldenLine obliLine, double price, ChartPainter mChartPainter, double maxPrice, double minPrice) {
    double Y = 0;
    if (obliLine.flag == 0) {
      //k线区域
      double rate = (maxPrice - minPrice) / mChartPainter.mUperChartHeight;
      Y = (mChartPainter.MARGINTOP + mChartPainter.mUperChartHeight - (price - minPrice) / rate);
      logger.i("传入的价格：$price");
      logger.i("计算出的Y：$Y");
      // } else if (obliLine.flag == 1) {
      //   //RSI,DMI
      //   double maxPrice = mChartPainter.getLowMaxPrice();
      //   double minPrice = mChartPainter.getLowMinPrice();
      //   double rate = (maxPrice - minPrice) / mChartPainter.getDownChartHeight();
      //   Y = (mChartPainter.kChartViewHeight - mChartPainter.getMarginBottom() - (price - minPrice) / rate);
      // } else if (obliLine.flag == 2) {
      //   //MACD
      //   double maxPrice = mChartPainter.getLowMaxPrice();
      //   double minPrice = mChartPainter.getLowMinPrice();
      //   double rate = (maxPrice - minPrice) / mChartPainter.getDownChartHeight();
      //   Y = (mChartPainter.kChartViewHeight - mChartPainter.getMarginBottom() - (price - minPrice) / rate);
    }

    return Y;
  }

  ///获得此日期对应的K线根数
  static int getNumber(String sDate, ChartPainter mChartPainter, int start, int mShowDataNum) {
    int number = 0; //K线根数
    int count = start + mShowDataNum;
    for (int i = start; i < count; i++) {
      String date = "";
      if (i < mChartPainter.getOHLCData().length) {
        date = "${mChartPainter.getOHLCData()[i].date} ${mChartPainter.getOHLCData()[i].time}";
      }
      if (sDate == date) {
        number = i - start + 1;
      }
    }
    number = number >= mShowDataNum ? mShowDataNum : number;
    number = number < 1 ? 1 : number;

    return number;
  }

  /// 检测上下黄金分割线是否超出K线边界
  static bool checkBoundary(double price, ChartPainter mChartPainter, double mMaxPrice, double mMinPrice) {
    if (price <= mMaxPrice && price >= mMinPrice) {
      return true;
    }
    return false;
  }

  /// 绘制黄金分割线
  static void drawGolden(Canvas canvas, GoldenLine goldenLine, ChartPainter mChartPainter, TextPainter redPaint, Paint paint, double mCandleWidth,
      double mMaxPrice, double mMinPrice, int start, int mShowDataNum) {
    double startY = getChartGoldenY(goldenLine, goldenLine.startPrice, mChartPainter, mMaxPrice, mMinPrice); //开始点Y坐标
    double endY = getChartGoldenY(goldenLine, goldenLine.endPrice, mChartPainter, mMaxPrice, mMinPrice); //结束点Y坐标
    double startX = (getNumber(goldenLine.startDate, mChartPainter, start, mShowDataNum) * mCandleWidth + GridChart.MARGINLEFT); //开始点X坐标
    double endX = (getNumber(goldenLine.endDate, mChartPainter, start, mShowDataNum) * mCandleWidth + GridChart.MARGINLEFT); //结束点X坐标
    double begPrice = goldenLine.startPrice; //开始价格
    double endPrice = goldenLine.endPrice; //结束价格
    double left = startX - GridChart.MARGINLEFT;
    double right = GridChart.MARGINLEFT + GridChart.mChartWidth - startX;
    double fLineBegX = 0; //每根线的长度

    switch (goldenLine.selectPoint) {
      case 0: //起点  , 正左负右
        fLineBegX = (startX - endX) * 3;
        fLineBegX = fLineBegX <= 0 ? fLineBegX.abs() : -fLineBegX;
        if (fLineBegX <= 0) {
          fLineBegX = fLineBegX.abs() > left ? -left : fLineBegX;
        } else {
          fLineBegX = fLineBegX > right ? right : fLineBegX;
        }
        break;

      case 1: //中点
        fLineBegX = (endX - startX) * 3;
        if (fLineBegX <= 0) {
          fLineBegX = fLineBegX.abs() > left ? -left : fLineBegX;
        } else {
          fLineBegX = fLineBegX > right ? right : fLineBegX;
        }
        break;

      case 2: //终点 ，正右负左
        fLineBegX = (endX - startX) * 3;
        if (fLineBegX <= 0) {
          fLineBegX = fLineBegX.abs() > left ? -left : fLineBegX;
        } else {
          fLineBegX = fLineBegX > right ? right : fLineBegX;
        }
        break;

      default:
        break;
    }

    double pri236 = 0;
    double pri05 = 0;
    double pri618 = 0;
    double pri382 = 0;
    double pri1618 = 0;
    double pri2618 = 0;
    double pri4236 = 0;

    if (endPrice < begPrice) {
      pri236 = endPrice + (begPrice - endPrice) * 0.236;
      pri382 = endPrice + (begPrice - endPrice) * 0.382;
      pri05 = endPrice + (begPrice - endPrice) * 0.5 - 0;
      pri618 = endPrice + (begPrice - endPrice) * 0.618;
      pri1618 = begPrice + (begPrice - endPrice) * 0.618;
      pri2618 = begPrice + (begPrice - endPrice) * 1.618;
      pri4236 = begPrice + (begPrice - endPrice) * 3.236;
    } else {
      pri236 = endPrice - (endPrice - begPrice) * 0.236;
      pri382 = endPrice - (endPrice - begPrice) * 0.382;
      pri05 = endPrice - (endPrice - begPrice) * 0.5;
      pri618 = endPrice - (endPrice - begPrice) * 0.618;
      pri1618 = begPrice - (endPrice - begPrice) * 0.618;
      pri2618 = begPrice - (endPrice - begPrice) * 1.618;
      pri4236 = begPrice - (endPrice - begPrice) * 3.236;
    }

    if (checkBoundary(begPrice, mChartPainter, mMaxPrice, mMinPrice)) {
      //绘制100线
      canvas.drawLine(Offset(startX, startY), Offset(startX + fLineBegX, startY), paint); //100线
      String text = "100(${Utils.getPointNum(begPrice)})";
      double h = ChartPainter.getStringHeight(text, redPaint);
      double w = ChartPainter.getStringWidth(text, redPaint);
      if (fLineBegX >= 0) {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX, startY + h));
      } else {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX - w, startY + h));
      }
    }

    if (checkBoundary(endPrice, mChartPainter, mMaxPrice, mMinPrice)) {
      //绘制0.0线
      canvas.drawLine(Offset(startX, endY), Offset(startX + fLineBegX, endY), paint); //0.0
      String text = "0.0(${Utils.getPointNum(endPrice)})";
      double h = ChartPainter.getStringHeight(text, redPaint);
      double w = ChartPainter.getStringWidth(text, redPaint);
      if (fLineBegX >= 0) {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX, endY + h));
      } else {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX - w, endY + h));
      }
    }

    if (checkBoundary(pri236, mChartPainter, mMaxPrice, mMinPrice)) {
      //绘制23.6线
      double localY236 = getChartGoldenY(goldenLine, pri236, mChartPainter, mMaxPrice, mMinPrice);
      canvas.drawLine(Offset(startX, localY236), Offset(startX + fLineBegX, localY236), paint); //23.6
      String text = "23.6(${Utils.getPointNum(pri236)})";
      double h = ChartPainter.getStringHeight(text, redPaint);
      double w = ChartPainter.getStringWidth(text, redPaint);
      if (fLineBegX >= 0) {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX, localY236 + h));
      } else {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX - w, localY236 + h));
      }
    }

    if (checkBoundary(pri382, mChartPainter, mMaxPrice, mMinPrice)) {
      //绘制38.2线
      double localY382 = getChartGoldenY(goldenLine, pri382, mChartPainter, mMaxPrice, mMinPrice);
      canvas.drawLine(Offset(startX, localY382), Offset(startX + fLineBegX, localY382), paint); //38.2
      String text = "38.2(${Utils.getPointNum(pri382)})";
      double h = ChartPainter.getStringHeight(text, redPaint);
      double w = ChartPainter.getStringWidth(text, redPaint);
      if (fLineBegX >= 0) {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX, localY382 + h));
      } else {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX - w, localY382 + h));
      }
    }

    if (checkBoundary(pri05, mChartPainter, mMaxPrice, mMinPrice)) {
      //绘制50.0线
      double localY05 = getChartGoldenY(goldenLine, pri05, mChartPainter, mMaxPrice, mMinPrice);
      canvas.drawLine(Offset(startX, localY05), Offset(startX + fLineBegX, localY05), paint); //50.0
      String text = "50.0(${Utils.getPointNum(pri05)})";
      double h = ChartPainter.getStringHeight(text, redPaint);
      double w = ChartPainter.getStringWidth(text, redPaint);
      if (fLineBegX >= 0) {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX, localY05 + h));
      } else {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX - w, localY05 + h));
      }
    }

    if (checkBoundary(pri618, mChartPainter, mMaxPrice, mMinPrice)) {
      //绘制618线
      double localY618 = getChartGoldenY(goldenLine, pri618, mChartPainter, mMaxPrice, mMinPrice);
      canvas.drawLine(Offset(startX, localY618), Offset(startX + fLineBegX, localY618), paint); //61.8
      String text = "61.8(${Utils.getPointNum(pri618)})";
      double h = ChartPainter.getStringHeight(text, redPaint);
      double w = ChartPainter.getStringWidth(text, redPaint);
      if (fLineBegX >= 0) {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX, localY618 + h));
      } else {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX - w, localY618 + h));
      }
    }

    if (checkBoundary(pri1618, mChartPainter, mMaxPrice, mMinPrice)) {
      //绘制1618线
      double localY1618 = getChartGoldenY(goldenLine, pri1618, mChartPainter, mMaxPrice, mMinPrice);
      canvas.drawLine(Offset(startX, localY1618), Offset(startX + fLineBegX, localY1618), paint); //161.8
      String text = "161.8(${Utils.getPointNum(pri1618)})";
      double h = ChartPainter.getStringHeight(text, redPaint);
      double w = ChartPainter.getStringWidth(text, redPaint);
      if (fLineBegX >= 0) {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX, localY1618 + h));
      } else {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX - w, localY1618 + h));
      }
    }

    if (checkBoundary(pri2618, mChartPainter, mMaxPrice, mMinPrice)) {
      //绘制2618线
      double localY2618 = getChartGoldenY(goldenLine, pri2618, mChartPainter, mMaxPrice, mMinPrice);
      canvas.drawLine(Offset(startX, localY2618), Offset(startX + fLineBegX, localY2618), paint); //261.8
      String text = "261.8(${Utils.getPointNum(pri2618)})";
      double h = ChartPainter.getStringHeight(text, redPaint);
      double w = ChartPainter.getStringWidth(text, redPaint);
      if (fLineBegX >= 0) {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX, localY2618 + h));
      } else {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX - w, localY2618 + h));
      }
    }

    if (checkBoundary(pri4236, mChartPainter, mMaxPrice, mMinPrice)) {
      //绘制2618线
      double localY4236 = getChartGoldenY(goldenLine, pri4236, mChartPainter, mMaxPrice, mMinPrice);
      canvas.drawLine(Offset(startX, localY4236), Offset(startX + fLineBegX, localY4236), paint); //423.6
      String text = "423.6(${Utils.getPointNum(pri4236)})";
      double h = ChartPainter.getStringHeight(text, redPaint);
      double w = ChartPainter.getStringWidth(text, redPaint);
      if (fLineBegX >= 0) {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX, localY4236 + h));
      } else {
        redPaint
          ..text = TextSpan(text: text, style: TextStyle(color: Port.goldenLineColor, fontSize: mChartPainter.DEFAULT_AXIS_TITLE_SIZE))
          ..layout()
          ..paint(canvas, Offset(startX - w, localY4236 + h));
      }
    }
  }

  /// 绘制智能识别区域
  // static void drawIdentifyArea(Canvas canvas, int mDataStartIndext, int mShowDataNum, double mCandleWidth, double mMaxPrice, double mMinPrice,
  //     int CANDLE_INTERVAL, int MARGINLEFT, int MARGINTOP , double uperChartHeight  , FallLineEntity mFallData , List<HNLineData>? HNLineDatas , List<IdentifyFall>? IFallDatas,
  //     int FallPeriod1 , int FallPeriod2 , int FallPeriod3 , int FallPeriod4 , int FallPeriod5 , int FallPeriod6){
  //   if (HNLineDatas.isEmpty || mDataStartIndext < (FallPeriod6*4 + 25 -1) ||  IFallDatas.isEmpty) {
  //     return;
  //   }
  //
  //   double rate = 0.0;//每单位像素价格
  //   Paint firstPaint=Paint();
  //   Paint mPaint =Paint() ;
  //   List<int> list =[];//位置集合
  //   rate = uperChartHeight / (mMaxPrice - mMinPrice);//计算最小单位
  //   // 创建画笔
  //   Paint redPaint = getDrawPaint(Color.rgb(255,0,0));
  //   Paint greenPaint = getDrawPaint(Color.rgb(0,255,0));
  //   Paint bluePaint = getDrawPaint(Color.rgb(0,0,255));
  //   redPaint.setAlpha(90);
  //   greenPaint.setAlpha(90);
  //   bluePaint.setAlpha(90);
  //
  //   for (int j = mDataStartIndext; j >= 0; j--) {     //确定起始画笔
  //     IdentifyFall IFall = IFallDatas.get(j);
  //     int type = IFall.getType();
  //     boolean isFinal = IFall.isFinal();
  //     if (type == Type.through_multi || type == Type.process_multi) {//多单
  //       firstPaint =  redPaint;
  //       break ;
  //     }else if (type == Type.through_empty || type == Type.process_empty) {//空单
  //       firstPaint =  greenPaint;
  //       break ;
  //     }else if (isFinal) {//转折点
  //       firstPaint =  bluePaint;
  //       break ;
  //     }else{//无
  //       firstPaint =  bluePaint;
  //     }
  //   }
  //
  //   //获得当前屏幕开始结束位置数组
  //   for (int i = mDataStartIndext; i < mDataStartIndext + mShowDataNum-1 ; i++) {
  //     IdentifyFall IFall = IFallDatas.get(i);
  //     int type = IFall.getType();
  //     boolean isFinal = IFall.isFinal();
  //     if (type == Type.through_multi || type == Type.process_multi ||
  //         type == Type.through_empty || type == Type.process_empty ||
  //         isFinal == true) {
  //       list.add(i);
  //     }
  //   }
  //
  //
  //
  //   for (int i = 0; i <= list.size() ; i++) {
  //     int start = 0;
  //     int end = 0;
  //     if (i==0) {//确定开始结束位置
  //       start = mDataStartIndext ;
  //       end = list.size()==0 ? mDataStartIndext + mShowDataNum -2 : list.get(i);
  //     }else if(i == list.size()){
  //       start = list.get(i-1) ;
  //       end = mDataStartIndext + mShowDataNum -2;
  //     }else{
  //       start = list.get(i-1) ;
  //       end = list.get(i);
  //     }
  //
  //     if (start == mDataStartIndext) {//确定区域颜色
  //       mPaint = firstPaint;
  //     }else{
  //       int type = IFallDatas.get(start).getType();
  //       boolean isFinal = IFallDatas.get(start).isFinal();
  //       if (isFinal) {
  //         mPaint = bluePaint;
  //       }else if (type == Type.through_multi || type == Type.process_multi) {
  //         mPaint = redPaint;
  //       }else if (type == Type.through_empty || type == Type.process_empty) {
  //         mPaint = greenPaint;
  //       }else{
  //         mPaint = bluePaint;
  //       }
  //     }
  //
  //     Path areaPath = Path();
  //     float lastY = 0;
  //     float lastX = 0;
  //     for (int j = start; j <= end; j++) {
  //       float startX = (float) (MARGINLEFT + mCandleWidth * (j - mDataStartIndext) + mCandleWidth);//K线横向位置，X坐标
  //       double pb1 = mFallData.getPBX1().get(j - (FallPeriod1*4-1));
  //       double pb2 = mFallData.getPBX2().get(j - (FallPeriod2*4-1));
  //       double pb3 = mFallData.getPBX3().get(j - (FallPeriod3*4-1));
  //       double pb4 = mFallData.getPBX4().get(j - (FallPeriod4*4-1));
  //       double pb5 = mFallData.getPBX5().get(j - (FallPeriod5*4-1));
  //       double pb6 = mFallData.getPBX6().get(j - (FallPeriod6*4-1));
  //       double pbMin = pb1;
  //       double pbMax = pb1;
  //       pbMin = pbMin < pb2 ? pbMin : pb2;
  //       pbMin = pbMin < pb3 ? pbMin : pb3;
  //       pbMin = pbMin < pb4 ? pbMin : pb4;
  //       pbMin = pbMin < pb5 ? pbMin : pb5;
  //       pbMin = pbMin < pb6 ? pbMin : pb6;
  //       pbMax = pbMax > pb2 ? pbMax : pb2;
  //       pbMax = pbMax > pb3 ? pbMax : pb3;
  //       pbMax = pbMax > pb4 ? pbMax : pb4;
  //       pbMax = pbMax > pb5 ? pbMax : pb5;
  //       pbMax = pbMax > pb6 ? pbMax : pb6;
  //
  //       float Ymax = (float) ((mMaxPrice - pbMax) * rate + MARGINTOP);//最高位置
  //       float Ymin = (float) ((mMaxPrice - pbMin) * rate + MARGINTOP);//最高位置
  //
  //       if (j == start) {
  //         areaPath.moveTo(startX, Ymax);
  //         areaPath.lineTo(startX, Ymin);
  //         areaPath.moveTo(startX, Ymax);
  //
  //       } else {
  //         areaPath.lineTo(startX, Ymax);
  //         areaPath.lineTo(startX, Ymin);
  //         areaPath.lineTo(lastX, lastY);
  //         areaPath.close();
  //         areaPath.moveTo(startX, Ymax);
  //       }
  //
  //       lastX = startX;
  //       lastY = Ymin;
  //
  //     }
  //     areaPath.close();
  //     canvas.drawPath(areaPath, mPaint);
  //   }
  //
  // }

  ///  是否在同一周期
  static bool isInPeriod(DateTime oldDate, DateTime newDate, KPeriod period) {
    bool result = false;
    if (period.cusType == 1) {
      if (period.kpFlag == KPFlag.Day) {
        if (oldDate.year == newDate.year && oldDate.month == newDate.month && oldDate.day == newDate.day) {
          result = true;
        } else {
          result = false;
        }
      } else {
        if (newDate.isAfter(oldDate)) {
          result = false;
        } else {
          result = true;
        }
      }
    } else {
      if (period.kpFlag == KPFlag.Day || period.kpFlag == KPFlag.Week || period.kpFlag == KPFlag.Month || period.kpFlag == KPFlag.Year) {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd 00:00:00:000");
        oldDate = dateFormat.parse(oldDate.toString());
        newDate = dateFormat.parse(newDate.toString());

        if (newDate.isAfter(oldDate)) {
          result = false;
        } else {
          result = true;
        }
      } else {
        result = newDate.isAfter(oldDate) ? false : true;
      }
    }

    return result;
  }

  ///计算两个时间之间相差的周期
  static int getCount(String oldTime, String newTime, KPeriod period) {
    int count = 0;
    DateFormat simpleDateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

    //两个时间的毫秒数差异
    Duration diff = simpleDateFormat.parse(newTime).difference(simpleDateFormat.parse(oldTime));
    int diffDay = diff.inDays; //天
    // int diffHour = diff.inHours; //小时
    int diffmMinute = diff.inMinutes; //分钟

    if (period.cusType == 1) {
      switch (period.period) {
        case KTime.M_1: //1分钟
          count = diffmMinute;
          break;

        case KTime.M_3: //1分钟
          count = diffmMinute ~/ 3;
          break;

        case KTime.M_5: //5分钟
          count = diffmMinute ~/ 5;
          break;

        case KTime.M_10: //5分钟
          count = diffmMinute ~/ 10;
          break;

        case KTime.M_15: //15分钟
          count = diffmMinute ~/ 15;
          break;

        case KTime.M_30: //30分钟
          count = diffmMinute ~/ 30;
          break;

        case KTime.H_1: //1小时
//                count = (int) (diffHour / 1);
          count = diffmMinute ~/ 60;
          break;

        case KTime.H_4: //4小时
//                count = (int) (diffHour / 4);
          count = diffmMinute ~/ 240;
          break;

        case KTime.DAY: //天
          count = diffDay ~/ 1 - 1;
          break;

        case KTime.WEEK: //周
          count = diffDay ~/ 7;
          break;

        case KTime.MON: //月
          count = diffDay ~/ 30;
          break;

        default:
          break;
      }
    } else {
      switch (period.kpFlag) {
        case KPFlag.Minute:
          count = diffmMinute ~/ period.period!;
          break;

        case KPFlag.Hour:
          count = diffmMinute ~/ (period.period! * 60);
          break;

        case KPFlag.Day:
          count = diffDay ~/ period.period! - 1;
          break;

        case KPFlag.Week:
          count = diffDay ~/ (period.period! * 7);
          break;

        case KPFlag.Month:
          count = diffDay ~/ (period.period! * 30);
          break;

        case KPFlag.Year:
          count = diffDay ~/ (period.period! * 365);
          break;

        default:
          break;
      }
    }
    return count;
  }
}
