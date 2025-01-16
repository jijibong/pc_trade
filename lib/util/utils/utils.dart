import 'dart:convert';
import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade/util/shared_preferences/shared_preferences_key.dart';
import 'package:trade/util/shared_preferences/shared_preferences_utils.dart';

import '../../config/common.dart';
import '../../model/broker/broker.dart';
import '../../model/date/date.dart';
import '../../model/k/OHLCEntity.dart';
import '../../model/k/k_flag.dart';
import '../../model/k/k_preiod.dart';
import '../../model/k/k_time.dart';
import '../../model/k/trade_time.dart';
import '../../model/option/option.dart';
import '../../model/quote/close_today.dart';
import '../../model/quote/commodity.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../log/log.dart';
import '../painter/k_chart/base_k_chart_painter.dart';
import 'market_util.dart';

class Utils {
  static DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");

  ///生成指定长度的随机字符串
  static String generateLenString(int length) {
    final random = Random();
    const availableChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(length, (index) => availableChars[random.nextInt(availableChars.length)]).join();

    return randomString;
  }

  /// Double 转string 去除科学记数法显示
  static String double2Str(double? d) {
    if (d == null) {
      return "";
    }
    String result = Decimal.parse(d.toString()).toString();
    while (result.endsWith("0") && result.contains(".")) {
      result = result.substring(0, result.length - 1);
    }

    if (result.endsWith(".")) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  /// 查询全部交易所
  static Future<List<Exchange>> getAllExchange() async {
    List<Exchange> saveList = [];
    String? string = await SpUtils.getString(SpKey.exchange);
    if (string != null) {
      List<dynamic> list = jsonDecode(string);
      for (var element in list) {
        saveList.add(Exchange.fromJson(element));
      }
    }
    return saveList;
  }

  /// 查询我的交易所
  static Future<List<Exchange>> getMyExchange(bool isMy) async {
    List<Exchange> conList = [];
    String? string = await SpUtils.getString(SpKey.exchange);
    if (string != null) {
      List<dynamic> list = jsonDecode(string);
      for (var element in list) {
        Exchange tmp = Exchange.fromJson(element);
        conList.add(tmp);
      }
    }
    if (conList.isNotEmpty) {
      conList.sort((a, b) {
        if (a.orderUser == b.orderUser) {
          return b.orderNum?.compareTo(a.orderNum ?? 0) ?? 0;
        }
        return b.orderUser?.compareTo(a.orderUser ?? 0) ?? 0;
      });
    }
    return conList;
  }

  ///存储交易所
  static void saveExchange(List<Exchange> list) async {
    if (list.isEmpty) {
      return;
    }
    List tmp = [];
    for (var element in list) {
      tmp.add(element.toJson());
    }
    String temp = jsonEncode(tmp);
    await SpUtils.set(SpKey.exchange, temp);
  }

  /// 更新本地自选
  static void updateOption(Contract mContract, bool isMain) async {
    String? string = await SpUtils.getString(SpKey.option);
    if (string != null && string != "") {
      List optionList = jsonDecode(string);
      List<Option> tmp = [];
      for (var element in optionList) {
        var value = Option.fromJson(element);
        if (value.excd == mContract.exCode && value.comCode == mContract.subComCode && value.comType == mContract.comType && value.isMain == isMain) {
          value.scode = mContract.code;
        }
        tmp.add(value);
      }
      SpUtils.set(SpKey.option, jsonEncode(tmp));
    }
  }

  /// 获取交易所下所有主力合约
  static Future<List<Contract>> getContractWithMain(String excd) async {
    List<Contract> conList = [];
    List<Commodity> products = [];

    List<Commodity> list = MarketUtils.commodityList;
    for (var element in list) {
      if (element.exchangeNo == excd) {
        products.add(element);
      }
    }
    products.sort((a, b) => b.orderNum!.compareTo(a.orderNum!));

    if (products.isNotEmpty) {
      for (var element in products) {
        List<Contract> contractList = [];
        List<Contract> list = MarketUtils.contractList;
        for (var e in list) {
          if (e.subComCode == element.commodityNo && e.exCode == element.exchangeNo && e.comType == element.commodityType) {
            contractList.add(e);
          }
        }
        contractList.sort((a, b) => a.name!.compareTo(b.name!));
        List<Contract> tmp = [];
        for (var bean in contractList) {
          Contract con = Contract();
          if (bean.contractID == element.mfContract) {
            con = Contract(
                name: "${bean.comName}主",
                code: bean.code,
                exCode: bean.exCode,
                comName: element.shortName,
                comType: bean.comType,
                subComCode: bean.subComCode,
                subConCode: bean.subConCode,
                comId: bean.comId,
                conId: bean.conId,
                contractID: bean.contractID,
                preSettlePrice: bean.preSettlePrice,
                futureTickSize: element.commodityTickSize,
                contractSize: element.contractSize,
                currency: element.tradeCurrency,
                trTime: element.tradeTime,
                level2List: getLevel2List(),
                isMain: true);
            tmp.add(con);
          }
          con = Contract(
              name: bean.name,
              code: bean.code,
              exCode: bean.exCode,
              comName: element.shortName,
              comType: bean.comType,
              subComCode: bean.subComCode,
              subConCode: bean.subConCode,
              comId: bean.comId,
              conId: bean.conId,
              contractID: bean.contractID,
              preSettlePrice: bean.preSettlePrice,
              futureTickSize: element.commodityTickSize,
              contractSize: element.contractSize,
              currency: element.tradeCurrency,
              trTime: element.tradeTime,
              level2List: getLevel2List(),
              isMain: false);
          tmp.add(con);
        }
        tmp.sort((a, b) {
          if (a.name!.contains("主")) {
            return -1;
          } else if (b.name!.contains("主")) {
            return 1;
          }
          return a.code!.compareTo(b.code!);
        });
        conList.addAll(tmp);
      }
      if (conList.isNotEmpty) {
        MarketUtils.setDataList(excd, conList);
      }
    }
    return conList;
  }

  /// 构造leve2
  static List<Level2> getLevel2List() {
    List<Level2> level2List = [];
    if (level2List.isEmpty) {
      level2List = [];
      for (int i = 0; i < 40; i++) {
        level2List.add(Level2());
      }
    }
    return level2List;
  }

  /// 获取服务商信息
  static Future<Broker?> getBroker() async {
    String? str = await SpUtils.getString(SpKey.broker);
    if (str != null && str.isNotEmpty) {
      Broker broker = Broker.fromJson(jsonDecode(str));
      return broker;
    }
    return null;
  }

  ///保存服务商信息
  static void saveBroker(Broker? broker) {
    if (broker != null) {
      String str = jsonEncode(broker.toJson());
      SpUtils.set(SpKey.broker, str);
    } else {
      SpUtils.remove(SpKey.broker);
    }
  }

  /// 获取商品下的合约
  static List<Contract> getComContract(Contract contract) {
    List<Contract> conList = [];
    List? tmp =
        MarketUtils.commodityList.where((element) => element.commodityNo == contract.subComCode && element.exchangeNo == contract.exCode).toList();
    if (tmp.isNotEmpty) {
      Commodity product = tmp.first;
      List<Contract> contractList = MarketUtils.contractList
          .where((element) =>
              element.exCode == product.exchangeNo && element.subComCode == product.commodityNo && element.comType == product.commodityType)
          .toList();
      contractList.sort((a, b) => a.name!.compareTo(b.name!));

      Contract con = Contract();
      for (var bean in contractList) {
        if (bean.contractID == product.mfContract) {
          con = Contract(
              name: bean.name,
              code: bean.code,
              exCode: bean.exCode,
              comName: product.shortName,
              comType: bean.comType,
              subComCode: bean.subComCode,
              subConCode: bean.subConCode,
              comId: bean.comId,
              conId: bean.conId,
              contractID: bean.contractID,
              preSettlePrice: bean.preSettlePrice,
              futureTickSize: product.commodityTickSize,
              contractSize: product.contractSize,
              currency: product.tradeCurrency,
              trTime: product.tradeTime,
              level2List: Utils.getLevel2List(),
              isMain: true);
          conList.add(con);
          //合约
          Contract child = Contract(
            name: bean.name,
            code: bean.code,
            exCode: bean.exCode,
            comName: product.shortName,
            comType: bean.comType,
            subComCode: bean.subComCode,
            subConCode: bean.subConCode,
            comId: bean.comId,
            conId: bean.conId,
            contractID: bean.contractID,
            preSettlePrice: bean.preSettlePrice,
            futureTickSize: product.commodityTickSize,
            contractSize: product.contractSize,
            currency: product.tradeCurrency,
            trTime: product.tradeTime,
            itemType: 1,
            level2List: Utils.getLevel2List(),
          );
          conList.add(child);
        } else {
          Contract child = Contract(
            name: bean.name,
            code: bean.code,
            exCode: bean.exCode,
            comName: product.shortName,
            comType: bean.comType,
            subComCode: bean.subComCode,
            subConCode: bean.subConCode,
            comId: bean.comId,
            conId: bean.conId,
            contractID: bean.contractID,
            preSettlePrice: bean.preSettlePrice,
            futureTickSize: product.commodityTickSize,
            contractSize: product.contractSize,
            currency: product.tradeCurrency,
            trTime: product.tradeTime,
            itemType: 1,
            level2List: Utils.getLevel2List(),
          );
          conList.add(child);
        }
      }
    }
    return conList;
  }

  /// 获取交易所下所有品种
  static List<Commodity> getVariety(String? exchangeNo) {
    List<Commodity> tmp = MarketUtils.commodityList.where((element) => element.exchangeNo == exchangeNo).toList();
    return tmp;
  }

  /// 是否设置优先平今
  static Future<bool> isCloseToday(String exchangeNo, String commodityNo, int commodityType) async {
    String? string = await SpUtils.getString(SpKey.comCloseToday);
    bool select = false;
    if (string != null) {
      List tmp = jsonDecode(string);
      List<ComCloseToday> closeTodayList = tmp.map((e) => ComCloseToday.fromJson(e)).toList();
      for (var e in closeTodayList) {
        if (e.exchangeNo == exchangeNo && e.commodityNo == commodityNo && e.commodityType == commodityType) {
          select = e.select ?? true;
          break;
        }
      }
    }
    return select;
  }

  ///根据给出的标准保留小数位
  static double dealPointByOld(num? d, num? old) {
    if (d == null || old == null) return 0;
    int num = old.toString().length - old.toString().indexOf(".") - 1;
    double result = Decimal.parse(d.toStringAsFixed(num)).toDouble();
    return result;
  }

  /// 根据给定数据处理double为字符串
  static String d2SBySrc(double? d, double? src) {
    if (d == null) return "";
    String str = double2Str(src);
    int point = str.indexOf(".");
    int num = 0;
    if (point > 0) {
      num = str.length - point - 1;
      if (num == 1) {
        String str1 = str.substring(str.indexOf(".") + 1, str.length);
        num = str1 == "0" ? 0 : 1;
      }
    }
    String fv = d.toStringAsFixed(num);
    return fv;
  }

  /// 若小数点后均为零，则保留一位小数，并且有四舍五入的规则。
  static double dealPointBigDecimal(double? d, int? num) {
    if (d == null || num == null) return 0;
    double result = Decimal.parse(d.toStringAsFixed(num)).toDouble();
    return result;
  }

  ///返回字符串时间的时间戳字符串。（注意：10位数字，）
  static String getLongTime(String time) {
    String reTime = "";
    try {
      DateTime d = format.parse(time);
      num l = d.millisecondsSinceEpoch;
      int stamp = (l / 1000).round();
      reTime = stamp.toString();
    } catch (e) {
      logger.e(e);
    }
    return reTime;
  }

  ///返回字符串时间的时间戳整型。（注意：10位数字，）
  static int getTimeStamp10(String time) {
    int reTime = 0;
    try {
      DateTime d = format.parse(time);
      num l = d.millisecondsSinceEpoch;
      int stamp = (l / 1000).round();
      reTime = stamp;
    } catch (e) {
      logger.e(e);
    }
    return reTime;
  }

  ///获取下一分钟时间
  static String getNextMin(String timeStr) {
    DateTime dateTime = format.parse(timeStr);
    String date = format.format(dateTime.add(const Duration(minutes: 1)));
    return date;
  }

  ///获得一个日期是星期几的索引 ，1星期一
  static int getWeek(String? strDate) {
    DateTime date;
    int weekIndex = 0;
    DateFormat weekFormat = DateFormat("yyyy-MM-dd");
    try {
      date = weekFormat.parse(strDate!);
      weekIndex = date.weekday - 1;
      if (weekIndex < 0) {
        weekIndex = 0;
      }
    } catch (e) {
      logger.e("$strDate 日期格式错误，请给出正确格式:$e");
    }
    return weekIndex;
  }

  static double dp2px(int dp) {
    double scale = Get.pixelRatio;
    double i = dp * scale + 0.5;
    return i;
  }

  /// 根据小数点位置保存小数位数
  static String getPointNum(double num, {int? length}) {
    String text = "";
    int digit = length ?? 3;
    String strNum = Decimal.fromJson(num.toString()).toString();

    int loc = strNum.indexOf(".");
    bool isStart = strNum.startsWith("-");
    if (isStart) {
      if (loc == 2) {
        //保留五位
        int first = int.parse(strNum.substring(1, loc));
        if (first > 0 && first < 10) {
          digit = 4;
          text = getLimitNum(num, digit);
        } else {
          digit = 5;
          text = getLimitNum(num, digit);
        }
        return text;
      }
    } else {
      if (loc == 1) {
        //保留五位
        int first = int.parse(strNum.substring(0, loc));
        if (first > 0 && first < 10) {
          digit = 4;
          text = getLimitNum(num, digit);
        } else {
          digit = 5;
          text = getLimitNum(num, digit);
        }
        return text;
      }
    }
    return getLimitNum(num, digit);
  }

  ///获取指定位数小数
  static String getLimitNum(double num, int digit) {
    String text = "";
    text = num.toStringAsFixed(digit);
    return text;
  }

  ///获取时
  static String getHourTime(String timeStr) {
    String hour = "00:00";
    try {
      hour = timeStr.split(" ")[1].substring(0, 5);
    } catch (e) {
      logger.e(e);
    }
    return hour;
  }

  ///将毫秒转换成指定格式字符串时间
  static String timeMillisToString(int time) {
    time = time * 1000;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    String date = format.format(dateTime);
    return date;
  }

  ///指定格式时间转换成秒数
  static int StringToTime10(String dateString) {
    try {
      DateFormat compareDateFormat = DateFormat("yyyy-MM-dd HH:mm");
      int time = compareDateFormat.parse(dateString).millisecondsSinceEpoch;
      return time ~/ 1000;
    } catch (e) {
      logger.w(e);
    }
    return 0;
  }

  /// 将毫秒转换成指定格式日期
  static String timeMillisToDate(int time) {
    time = time * 1000;
    var simpleDateFormat = DateFormat("yyyy-MM-dd");
    String date = simpleDateFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
    return date;
  }

  ///将毫秒转换成指定格式时间
  static String timeMillisToTime(int time) {
    time = time * 1000;
    DateFormat dateFormat = DateFormat("HH:mm:ss");
    String date = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
    return date;
  }

  ///毫秒字符串时间转换成毫秒数
  static int MilsStringToTimestamp(String dateString) {
    try {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
      int time = dateFormat.parse(dateString).microsecondsSinceEpoch;
      return time;
    } catch (e) {
      logger.e(e);
    }
    return 0;
  }

  ///比较两个时间大小
  static int compareDate(String oldDate, String newDate) {
    try {
      DateTime dateOld = format.parse(oldDate);
      DateTime dateNew = format.parse(newDate);

      if (dateNew.isBefore(dateOld)) {
        return -1;
      } else if (dateNew.isAfter(dateOld)) {
        return 1;
      }
    } catch (e) {
      logger.e(e);
    }
    return -1;
  }

  ///获得指定日期的前一天
  static String getDayBefore(String specifiedDay, int num) {
    DateFormat dayFormat = DateFormat("yyyy-MM-dd");
    DateTime date = dayFormat.parse(specifiedDay);

    String dayAfter = dayFormat.format(date.subtract(Duration(days: num)));
    return dayAfter;
  }

  ///获得指定日期的后一天
  static String getDayAfter(String specifiedDay, int num) {
    DateFormat dayFormat = DateFormat("yyyy-MM-dd");
    DateTime date = dayFormat.parse(specifiedDay);

    String dayAfter = dayFormat.format(date.add(Duration(days: num)));
    return dayAfter;
  }

  static int getStartIndex(String date, List<OHLCEntity> OHLCData) {
    int index = 0;
    for (int i = 0; i < OHLCData.length; i++) {
      String date1 = "${OHLCData[i].date} ${OHLCData[i].time}";
      if (date1 == date) {
        index = i;
        return index;
      }
    }
    return index;
  }

  /// 获取最小变动价的整数倍
  static double getIntegerPrice(num? price, num? base) {
    if (price != null && base != null) {
      double result = 0;
      int mutli = Decimal.parse((price / base).toString()).toBigInt().toInt();
      result = mutli * base.toDouble();
      result = dealPointByOld(result, base);
      return result;
    }
    return 0;
  }

  ///获取和历史数据统一的标准时间格式
  static String getUnifiedTime(String newTime, KPeriod period, String standardTime) {
    String returnTime = "";
    String second = standardTime.substring(17, 19);
    String hour = standardTime.substring(11, 19);
    if (period.cusType == 1) {
      switch (period.period) {
        case KTime.FS: //1分钟
        case KTime.M_1: //1分钟
          returnTime = newTime.substring(0, 17) + second;
          break;

        case KTime.M_3: //5分钟
          returnTime = newTime.substring(0, 17) + second;
          break;

        case KTime.M_5: //5分钟
          returnTime = newTime.substring(0, 17) + second;
          break;

        case KTime.M_10: //10分钟
          returnTime = newTime.substring(0, 17) + second;
          break;

        case KTime.M_15: //15分钟
          returnTime = newTime.substring(0, 17) + second;
          break;

        case KTime.M_30: //30分钟
          returnTime = newTime.substring(0, 17) + second;
          break;

        case KTime.H_1: //1小时
//                returnTime = newTime.substring(0, 14) + minute;
          returnTime = newTime.substring(0, 17) + second;
          break;

        case KTime.H_4: //4小时
//                returnTime = newTime.substring(0, 14) + minute;
          returnTime = newTime.substring(0, 17) + second;
          break;

        case KTime.DAY: //天
          returnTime = newTime.substring(0, 11) + hour;
          break;

        case KTime.WEEK: //周
          returnTime = newTime.substring(0, 11) + hour;
          break;

        case KTime.MON: //月
          returnTime = newTime.substring(0, 11) + hour;
          break;

        default:
          break;
      }
    } else {
      switch (period.kpFlag) {
        case KPFlag.Minute:
        case KPFlag.Hour:
          returnTime = newTime.substring(0, 17) + second;
          break;

        case KPFlag.Day:
        case KPFlag.Week:
        case KPFlag.Month:
        case KPFlag.Year:
          returnTime = newTime.substring(0, 11) + hour;
          break;
      }
    }

    return returnTime;
  }

  ///小数处理
  static String? decimalFormat(num? value) {
    if (value == null) return null;
    if (value is int) {
      return value.toString();
    }
    final mul = pow(10, 2);
    return NumberFormat().format((value * mul).roundToDouble() / mul);
  }

  /// 计算交易时间
  static List<TradeDate> calcTradeDate(String timePoint, List<TradeTime> mTradeTimes) {
    List<TradeDate> list = [];
    String staDate = timePoint.split(" ")[0];
    String staTime = timePoint.split(" ")[1];
    try {
      if (mTradeTimes.isNotEmpty) {
        String openTime = "$staDate ${mTradeTimes[0].Start}";
        String closeTime = "$staDate ${mTradeTimes[mTradeTimes.length - 1].End}";
        String nDate = staDate;
        String nTime = staTime;

        String preTime = openTime;
        if (compareDate(openTime, closeTime) == -1) {
          //收盘早于开盘

          if (compareDate(openTime, "$staDate $nTime") == -1) {
            if (getWeek(nDate) == 1) {
              //星期一
              nDate = getDayBefore(nDate, 3);
            } else {
              nDate = getDayBefore(nDate, 1);
            }
          }

          for (int i = 0; i < mTradeTimes.length; i++) {
            String indexStart = "$staDate ${mTradeTimes[i].Start}";
            String indexEnd = "$staDate ${mTradeTimes[i].End}";
            if (compareDate(indexStart, indexEnd) == -1) {
              String start = "$nDate ${mTradeTimes[i].Start}";
              nDate = getDayAfter(nDate, 1);
              String end = "$nDate ${mTradeTimes[i].End}";
              list.add(TradeDate(Common.ymdhmsFormat.parse(start), Common.ymdhmsFormat.parse(end)));

              if (getWeek(nDate) == 6) {
                nDate = getDayAfter(nDate, 2);
              }
            } else {
              if (compareDate(indexStart, preTime) == 1) {
                if (getWeek(nDate) == 5) {
                  //周五
                  nDate = getDayAfter(nDate, 3);
                  String start = "$nDate ${mTradeTimes[i].Start}";
                  String end = "$nDate ${mTradeTimes[i].End}";
                  list.add(TradeDate(Common.ymdhmsFormat.parse(start), Common.ymdhmsFormat.parse(end)));
                } else {
                  nDate = getDayAfter(nDate, 1);
                  String start = "$nDate ${mTradeTimes[i].Start}";
                  String end = "$nDate ${mTradeTimes[i].End}";
                  list.add(TradeDate(Common.ymdhmsFormat.parse(start), Common.ymdhmsFormat.parse(end)));
                }
              } else {
                String start = "$nDate ${mTradeTimes[i].Start}";
                String end = "$nDate ${mTradeTimes[i].End}";
                list.add(TradeDate(Common.ymdhmsFormat.parse(start), Common.ymdhmsFormat.parse(end)));
              }
            }
            preTime = indexEnd;
          }
        } else {
          //开盘早于收盘
          for (int i = 0; i < mTradeTimes.length; i++) {
            String start = "$nDate ${mTradeTimes[i].Start}";
            String end = "$nDate ${mTradeTimes[i].End}";
            list.add(TradeDate(Common.ymdhmsFormat.parse(start), Common.ymdhmsFormat.parse(end)));
          }
        }
      }
    } catch (e) {
      Log.e("计算交易时间异常：$e");
    }
    return list;
  }

  ///计算自定义K线自合成时间
  static String calcCustomNextDate(String oldPoint, String newPoint, KPeriod period, List<TradeTime> tradeTimes) {
    String nextStrTime = "";
    try {
      DateTime timeDate;
      List<TradeDate> dayTimes = [];
      int timeInterval = 0;
      int dayAvailable = 0;
      switch (period.kpFlag) {
        case KPFlag.Minute:
        case KPFlag.Hour:
          timeDate = Common.ymdhmsFormat.parse(oldPoint);
          timeInterval = period.kpFlag == KPFlag.Minute ? (period.period ?? 1) * 60 * 1000 : (period.period ?? 1) * 60 * 60 * 1000;
          dayTimes = calcTradeDate(oldPoint, tradeTimes);
          DateTime? close = dayTimes[dayTimes.length - 1].End;

          // 等于收盘时间的，从下一个交易日开盘时间开始重新计算
          if (timeDate.isAtSameMomentAs(close!)) {
            dayTimes = calcTradeDate(newPoint, tradeTimes);
            if (dayTimes.isNotEmpty && dayTimes[0].Start != null) {
              DateTime open = dayTimes[0].Start!;
              DateTime nextDate = open.add(Duration(milliseconds: timeInterval));
              nextStrTime = Common.ymdhmsFormat.format(nextDate);
            } else {
              nextStrTime = newPoint;
            }
          } else {
            for (int i = 0; i < dayTimes.length; i++) {
              dayAvailable += dayTimes[i].End!.millisecondsSinceEpoch - dayTimes[i].Start!.millisecondsSinceEpoch;
            }

            if (timeInterval <= dayAvailable) {
              DateTime nextDate = timeDate.add(Duration(milliseconds: timeInterval));
              if (!nextDate.isBefore(close)) {
                nextStrTime = Common.ymdhmsFormat.format(close);
                return nextStrTime;
              }

              int index = 0;
              for (int i = 0; i < dayTimes.length; i++) {
                if (dayTimes[i].End != null && !timeDate.isAfter(dayTimes[i].End!)) {
                  index = i;
                  break;
                }
              }
              int timeConsume = 0;
              DateTime preDate = timeDate;
              for (int i = index; i < dayTimes.length; i++) {
                if (nextDate.isAfter(dayTimes[i].End!)) {
                  if (i == dayTimes.length - 1) {
                    nextStrTime = Common.ymdhmsFormat.format(close);
                    break;
                  } else {
                    timeConsume += dayTimes[i].End!.millisecondsSinceEpoch - preDate.millisecondsSinceEpoch;
                    timeConsume += dayTimes[i].End!.millisecondsSinceEpoch - preDate.millisecondsSinceEpoch;
                    preDate = dayTimes[i + 1].Start!;
                    nextDate = dayTimes[i + 1].Start!.add(Duration(milliseconds: timeInterval - timeConsume));
                  }
                } else {
                  nextStrTime = Common.ymdhmsFormat.format(nextDate);
                  break;
                }
              }
            } else {
              nextStrTime = Common.ymdhmsFormat.format(close);
            }
          }
          break;
        case KPFlag.Day:
        case KPFlag.Week:
        case KPFlag.Month:
        case KPFlag.Year:
          if (tradeTimes.isNotEmpty) {
            nextStrTime = "${newPoint.split(" ")[0]} ${tradeTimes[tradeTimes.length - 1].End}";
          } else {
            nextStrTime = newPoint;
          }
          break;
      }
    } catch (e) {
      logger.e("计算自定义K线自合成时间异常：$e");
    }

    return nextStrTime;
  }

  ///获取行情订阅json
  static List<String> getSubJson(int start, int end, List<Contract> list) {
    if (list.isNotEmpty) {
      List<String> maps = [];
      for (var con in list.sublist(start, end)) {
        String? excd = con.exCode;
        String type = String.fromCharCode(con.comType ?? 0);
        String? comCode = con.subComCode;
        String? conCode = con.subConCode;
        String key = "$excd.$type.$comCode.$conCode";
        maps.add(key);
      }
      // logger.i(json);
      return maps;
    }
    return [];
  }

  ///操作自选
  static Future<void> operateOption(Contract mContract, bool isAdd, int userId) async {
    String? option = await SpUtils.getString(SpKey.option);
    List<Option> tmp = [];
    if (option != null && option != "") {
      List temp = jsonDecode(option);
      for (var element in temp) {
        tmp.add(Option.fromJson(element));
      }
    }
    if (isAdd) {
      Option option = Option(
          excd: mContract.exCode,
          scode: mContract.code,
          comCode: mContract.subComCode,
          comType: mContract.comType,
          userId: userId,
          isMain: mContract.isMain);
      tmp.add(option);
    } else {
      tmp.removeWhere((element) =>
          element.excd == mContract.exCode &&
          element.scode == mContract.code &&
          element.comType == mContract.comType &&
          element.isMain == mContract.isMain);
    }
    SpUtils.set(SpKey.option, jsonEncode(tmp));
  }
}
