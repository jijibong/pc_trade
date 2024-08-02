import 'dart:math';

import 'package:get/get.dart';

import '../OHLCEntity.dart';

/**
 * 计算指标线数据
 * @author hexuejian
 *
 */
class CalcIndexData {
  List<double> Tr1 = [];
  List<double> Tr2 = [];
  List<double> Tr3 = [];

  /**
   * 计算均线值
   * @param OHLCData
   * @param period
   * @param type
   * @param pri_type
   * @param index
   * @return
   */
  double calcCost(List<OHLCEntity> OHLCData, int period, int type, int pri_type, int index) {
    //均线
    double value = 0;
    int counts = OHLCData.length;
    if (index < (period - 1) || index >= counts) return double.maxFinite;

    switch (type) {
      case 0: //Simple(简单移动平均线)
        double sumPri = 0;
        for (int i = index - period + 1; i <= index; i++) {
          switch (pri_type) {
            case 0: //开
              sumPri += (OHLCData[i].open) ?? 0;
              break;

            case 1: //高
              sumPri += (OHLCData[i].high) ?? 0;
              break;

            case 2: //收
              sumPri += (OHLCData[i].close) ?? 0;
              break;

            case 3: //低
              sumPri += (OHLCData[i].low) ?? 0;
              break;

            case 4: //中间价
              sumPri += ((OHLCData[i].high ?? 0) + (OHLCData[i].low ?? 0)) / 2;
              break;
          }
        }
        value = sumPri / period;
        break;

      case 1: //Exponential(指数移动平均线) EMA(X,N)=2*X/(N+1)+(N-1)/(N+1)*昨天的指数收盘平均值,X为当日收盘价,N为周期
        value = 0;
        num? tmpValue = 0;
        int pMinus = period - 1;
        int pPlus = period + 1;

        for (int i = period - 1; i <= index; i++) {
          switch (pri_type) {
            case 0: //开
              if (i == period - 1) {
                tmpValue = OHLCData[i].open ?? 0;
              } else {
                tmpValue = (2.0 * (OHLCData[i].open ?? 0) + pMinus * (tmpValue ?? 0)) / pPlus;
              }
              break;

            case 1: //高
              if (i == period - 1) {
                tmpValue = OHLCData[i].high ?? 0;
              } else {
                tmpValue = (2.0 * (OHLCData[i].high ?? 0) + pMinus * (tmpValue ?? 0)) / pPlus;
              }
              break;

            case 2: //收

              if (i == period - 1) {
                tmpValue = OHLCData[i].close ?? 0;
              } else {
                tmpValue = (2.0 * (OHLCData[i].close ?? 0) + pMinus * (tmpValue ?? 0)) / pPlus;
              }
              break;

            case 3: //低

              if (i == period - 1) {
                tmpValue = OHLCData[i].low ?? 0;
              } else {
                tmpValue = (2.0 * (OHLCData[i].low ?? 0) + pMinus * (tmpValue ?? 0)) / pPlus;
              }
              break;

            case 4: //中间价
              if (i == period - 1) {
                tmpValue = ((OHLCData[i].high ?? 0) + (OHLCData[i].low ?? 0)) / 2;
              } else {
                tmpValue = (((OHLCData[i].high ?? 0) + (OHLCData[i].low ?? 0)) + pMinus * (tmpValue ?? 0)) / pPlus;
              }
              break;
          }
        }

        value = tmpValue?.toDouble() ?? 0;

        break;

      case 2: //Smoothed(通畅移动平均线)

        double sumPri1 = 0;
        for (int i = index - period + 1; i <= index; i++) {
          switch (pri_type) {
            case 0: //开
              sumPri1 += OHLCData[i].open ?? 0;
              break;

            case 1: //高
              sumPri1 += OHLCData[i].high ?? 0;
              break;

            case 2: //收
              sumPri1 += OHLCData[i].close ?? 0;
              break;

            case 3: //低
              sumPri1 += OHLCData[i].low ?? 0;
              break;

            case 4: //中间价
              sumPri1 += ((OHLCData[i].high ?? 0) + (OHLCData[i].low ?? 0)) / 2;
              break;
          }
        }

        double smma = sumPri1 / period;
        value = (sumPri1 - smma + (OHLCData[index].close ?? 0)) / period;
        break;
    }
    return value;
  }

  /**
   * 计算布林带值
   * @param OHLCData
   * @param period
   * @param type
   * @param pri_type
   * @param index
   * @return
   */
  Map<String, double> calcBollinger(List<OHLCEntity> OHLCData, int period, int type, int pri_type, int index) {
    Map<String, double> value = <String, double>{};
    int counts = OHLCData.length;
    if (index < (period - 1) || index >= counts) return {};
    //计算平均线
    double ave = calcCost(OHLCData, period, type, pri_type, index);
    //计算标准差
    double sum = 0;
    for (int i = index - period + 1; i <= index; i++) {
      switch (pri_type) {
        case 0: //开
          sum += ((OHLCData[i].open ?? 0) - ave) * ((OHLCData[i].open ?? 0) - ave);
          break;

        case 1: //高
          sum += ((OHLCData[i].high ?? 0) - ave) * ((OHLCData[i].high ?? 0) - ave);
          break;

        case 2: //收
          sum += ((OHLCData[i].close ?? 0) - ave) * ((OHLCData[i].close ?? 0) - ave);
          break;

        case 3: //低
          sum += ((OHLCData[i].low ?? 0) - ave) * ((OHLCData[i].low ?? 0) - ave);
          break;

        case 4: //中间价
          sum += (((OHLCData[i].high ?? 0) + (OHLCData[i].low ?? 0)) / 2 - ave) * (((OHLCData[i].high ?? 0) + (OHLCData[i].low ?? 0)) / 2 - ave);
          break;
      }
    }

    double sd = sqrt(sum / period);
    value["ave"] = ave;
    value["sqrt"] = sd;

    return value;
  }

  /**
   * 计算多空线值
   * @param OHLCData
   * @param dkxPeriod
   * @param madkxPeriod
   * @param index
   * @return
   */
  Map<String, double> calcDKX(List<OHLCEntity> OHLCData, int dkxPeriod, int madkxPeriod, int index) {
    Map<String, double> value = <String, double>{};

    int counts = OHLCData.length;
    if (index < (dkxPeriod - 1) || index >= counts) return {};

    double dkxTmp = 0.0;
    double dkx = 0.0;
    double mid = 0.0;

    for (int i = dkxPeriod; i > 0; i--) //dkx:dkxPeriod*当前日的MID+...+1*m_dkxCycle日前的MID
    {
      mid = (3 * (OHLCData[index + (i - dkxPeriod)].close ?? 0) +
              (OHLCData[index + (i - dkxPeriod)].high ?? 0) +
              (OHLCData[index + (i - dkxPeriod)].low ?? 0) +
              (OHLCData[index + (i - dkxPeriod)].open ?? 0)) /
          6;
      dkxTmp = i * mid;
      dkx += dkxTmp;
    }

    dkx /= ((dkxPeriod + 1) * (dkxPeriod / 2));

    value["dkx"] = dkx;

    //计算madkx

    if (index >= (dkxPeriod + madkxPeriod - 2)) {
      double sumDkx = 0.0;
      for (int i = index - madkxPeriod + 1; i <= index; i++) {
        //dkx的madkxPeriod日均值
        dkxTmp = dkx = mid = 0.0;

        for (int j = dkxPeriod; j > 0; j--) {
          mid = (3 * (OHLCData[i + (i - dkxPeriod)].close ?? 0) +
                  (OHLCData[i + (i - dkxPeriod)].high ?? 0) +
                  (OHLCData[i + (i - dkxPeriod)].low ?? 0) +
                  (OHLCData[i + (i - dkxPeriod)].open ?? 0)) /
              6;
          dkxTmp = j * mid;
          dkx += dkxTmp;
        }
        dkx /= ((dkxPeriod + 1) * (dkxPeriod / 2));
        sumDkx += dkx;
      }

      double madkx = sumDkx / madkxPeriod;
      value["madkx"] = madkx;
    }

    return value;
  }

  /**
   * 计算MIKE指标
   * @param OHLCData
   * @param period
   * @param index
   * @return
   */
  Map<String, double> calcMIKE(List<OHLCEntity> OHLCData, int period, int index) {
    Map<String, double> value = {};

    int counts = OHLCData.length;
    if (index < (period - 1) || index >= counts) return {};

    double typ = (OHLCData[index].high ?? 0 + (OHLCData[index].low ?? 0) + (OHLCData[index].close ?? 0)) / 3;

    double ll = 0.0, hh = 0.0;
    double wr = 0.0, mr = 0.0, sr = 0.0, ws = 0.0, ms = 0.0, ss = 0.0;
    hh = calcHighest(OHLCData, period, index);
    ll = calcLowest(OHLCData, period, index);

    wr = typ * 2 - ll;
    mr = typ + hh - ll;
    sr = hh * 2 - ll;
    ws = typ * 2 - hh;
    ms = typ - hh + ll;
    ss = 2 * ll - hh;

    value["WR"] = wr;
    value["MR"] = mr;
    value["SR"] = sr;
    value["WS"] = ws;
    value["MS"] = ms;
    value["SS"] = ss;
    return value;
  }

  /**
   * 计算瀑布线的值
   * @param OHLCData
   * @param period
   * @param pri_type
   * @param index
   * @return
   */
  double calcFall(List<OHLCEntity> OHLCData, int period, int pri_type, int index) {
    double aveTwice, avefourFold, expon, value;

    //M1*2日简单移动平均
    aveTwice = calcCost(OHLCData, period * 2, 0, pri_type, index);
    //M1*4日简单移动平均
    avefourFold = calcCost(OHLCData, period * 4, 0, pri_type, index);
    //M1日指数移动平均
    expon = calcCost(OHLCData, period, 1, pri_type, index);

    //当日瀑布线的值
    value = (expon + aveTwice + avefourFold) / 3;
    return value;
  }

  /**
   * 计算鳄鱼线的值
   * @param OHLCData
   * @param period
   * @param index
   * @return
   */
  double calcAlligator(List<OHLCEntity> OHLCData, int period, int index) {
    double value;

    int counts = OHLCData.length;
    if (index < period - 1 || index >= counts) return double.maxFinite;

    double sum = 0.0;

    for (int i = 0; i < period; i++) {
      sum += (OHLCData[index - period + i + 1].high ?? 0 ?? 0 + (OHLCData[index - period + i + 1].low ?? 0 ?? 0)) / 2;
    }

    value = sum / period; //顺畅移动平均

    return value;
  }

  /**
   * 计算RSI
   * @param OHLCData
   * @param period
   * @param pri_type
   * @param index
   * @return
   */
  double calcRsi(List<OHLCEntity> OHLCData, int period, int pri_type, int index) {
    int counts = OHLCData.length;
    if (index <= (period - 1) || index >= counts) return double.maxFinite;

    double rsiUpSum = 0;
    double rsiDownSum = 0;
    double value = 0;

    for (int i = index - period + 1; i <= index; i++) {
      switch (pri_type) {
        case 0: //开
          if ((OHLCData[i].open ?? 0) - (OHLCData[i - 1].open ?? 0) > 0) {
            rsiUpSum += (OHLCData[i].open ?? 0) - (OHLCData[i - 1].open ?? 0);
          } else {
            rsiDownSum += (OHLCData[i - 1].open ?? 0) - (OHLCData[i].open ?? 0);
          }
          break;

        case 1: //高
          if ((OHLCData[i].high ?? 0) - (OHLCData[i - 1].high ?? 0) > 0) {
            rsiUpSum += (OHLCData[i].high ?? 0) - (OHLCData[i - 1].high ?? 0);
          } else {
            rsiDownSum += (OHLCData[i - 1].high ?? 0) - (OHLCData[i].high ?? 0);
          }

          break;

        case 2: //收

          if ((OHLCData[i].close ?? 0) - (OHLCData[i - 1].close ?? 0) > 0) {
            rsiUpSum += (OHLCData[i].close ?? 0) - (OHLCData[i - 1].close ?? 0);
          } else {
            rsiDownSum += (OHLCData[i - 1].close ?? 0) - (OHLCData[i].close ?? 0);
          }
          break;

        case 3: //低
          if ((OHLCData[i].low ?? 0) - (OHLCData[i - 1].low ?? 0) > 0) {
            rsiUpSum += (OHLCData[i].low ?? 0) - (OHLCData[i - 1].low ?? 0);
          } else {
            rsiDownSum += (OHLCData[i - 1].low ?? 0) - (OHLCData[i].low ?? 0);
          }
          break;

        case 4: //中间价
          double curHL = ((OHLCData[i].high ?? 0) + (OHLCData[i].low ?? 0)) / 2;
          double preHL = ((OHLCData[i - 1].high ?? 0) + (OHLCData[i - 1].low ?? 0)) / 2;
          if (curHL - preHL > 0) {
            rsiUpSum += (curHL - preHL);
          } else {
            rsiDownSum += preHL - curHL;
          }

          break;
      }
    }

    double rsiUp = rsiUpSum / period;
    double rsiDown = rsiDownSum / period;

    if ((rsiUp < 0.000001 && rsiUp > -0.000001) || ((rsiUp + rsiDown) > -0.000001 && (rsiUp + rsiDown) < 0.000001)) {
      value = 0; //处理分母为0的情况
    } else {
      value = rsiUp / (rsiUp + rsiDown) * 100;
    }

    return value;
  }

  /**
   * 计算MACD的Diff
   * @param OHLCData
   * @param sPeriod
   * @param lPeriod
   * @param pri_type
   * @param index
   * @return
   */
  double calcDiff(List<OHLCEntity> OHLCData, int sPeriod, int lPeriod, int pri_type, int index) {
    int counts = OHLCData.length;
    if (counts == 0) return double.maxFinite;

    double diff = 0;
    //计算EMA12与EMA26(分别从第12日或第26日后才有)
    double L12 = 2.0 / (sPeriod + 1);
    double L26 = 2.0 / (lPeriod + 1);

    double ema12 = 0;
    double ema26 = 0;

    //EMA12,EMA26
    double tmpEma12 = 0;
    double tmpEma26 = 0;
    switch (pri_type) {
      case 0: //开
        tmpEma12 = OHLCData[sPeriod - 1].open?.toDouble() ?? 0;
        tmpEma26 = OHLCData[lPeriod - 1].open?.toDouble() ?? 0;
        break;

      case 1: //高
        tmpEma12 = OHLCData[sPeriod - 1].high?.toDouble() ?? 0;
        tmpEma26 = OHLCData[lPeriod - 1].high?.toDouble() ?? 0;
        break;

      case 2: //收
        tmpEma12 = OHLCData[sPeriod - 1].close?.toDouble() ?? 0;
        tmpEma26 = OHLCData[lPeriod - 1].close?.toDouble() ?? 0;
        break;

      case 3: //低
        tmpEma12 = OHLCData[sPeriod - 1].low?.toDouble() ?? 0;
        tmpEma26 = OHLCData[lPeriod - 1].low?.toDouble() ?? 0;
        break;

      case 4: //中间价
        tmpEma12 = ((OHLCData[sPeriod - 1].high ?? 0) + (OHLCData[sPeriod - 1].low ?? 0)) / 2;
        tmpEma26 = ((OHLCData[lPeriod - 1].high ?? 0) + (OHLCData[lPeriod - 1].low ?? 0)) / 2;
        break;
    }

    ema12 = tmpEma12;
    ema26 = tmpEma26;
    double sd = (sPeriod - 1) / (sPeriod + 1);
    for (int i = sPeriod; i <= index; i++) {
      switch (pri_type) {
        case 0: //开
          ema12 = L12 * (OHLCData[i].open ?? 0) + (sPeriod - 1) / (sPeriod + 1) * tmpEma12;
          break;
        case 1: //高
          ema12 = L12 * (OHLCData[i].high ?? 0) + (sPeriod - 1) / (sPeriod + 1) * tmpEma12;
          break;
        case 2: //收
          ema12 = L12 * (OHLCData[i].close ?? 0) + (sPeriod - 1) / (sPeriod + 1) * tmpEma12;
          break;
        case 3: //低
          ema12 = L12 * (OHLCData[i].low ?? 0) + (sPeriod - 1) / (sPeriod + 1) * tmpEma12;
          break;
        case 4: //中间价
          ema12 = L12 * ((OHLCData[i].high ?? 0) + (OHLCData[i].low ?? 0)) / 2 + (sPeriod - 1) / (sPeriod + 1) * tmpEma12;
          break;
      }
      tmpEma12 = ema12;
    }

    for (int i = lPeriod; i <= index; i++) {
      switch (pri_type) {
        case 0: //开
          ema26 = L26 * (OHLCData[i].open ?? 0) + (lPeriod - 1) / (lPeriod + 1) * tmpEma26;
          break;

        case 1: //高
          ema26 = L26 * (OHLCData[i].high ?? 0) + (lPeriod - 1) / (lPeriod + 1) * tmpEma26;
          break;

        case 2: //收
          ema26 = L26 * (OHLCData[i].close ?? 0) + (lPeriod - 1) / (lPeriod + 1) * tmpEma26;
          break;

        case 3: //低
          ema26 = L26 * (OHLCData[i].low ?? 0) + (lPeriod - 1) / (lPeriod + 1) * tmpEma26;
          break;

        case 4: //中间价
          ema26 = L26 * ((OHLCData[i].high ?? 0) + (OHLCData[i].low ?? 0)) / 2 + (lPeriod - 1) / (lPeriod + 1) * tmpEma26;
          break;
      }
      tmpEma26 = ema26;
    }

    diff = ema12 - ema26; //0--对应lPeriod根K线

    return diff;
  }

  /**
   * 计算MACD
   * @param OHLCData
   * @param sPeriod
   * @param lPeriod
   * @param period
   * @param pri_type
   * @param index
   * @return
   */
  Map<String, double> calcMACD(List<OHLCEntity> OHLCData, int sPeriod, int lPeriod, int period, int pri_type, int index) {
    int counts = OHLCData.length;
    if (index <= (lPeriod - 1) || index >= counts) return {};

    Map<String, double> value = {};
    //计算diff值
    double diff = calcDiff(OHLCData, sPeriod, lPeriod, pri_type, index);

    //计算DEA
    //计算DEA
    if (index >= (lPeriod + period - 2)) {
      double sumDiff = 0.0;
      double tmpDiff = 0.0;
      for (int i = index - period + 1; i <= index; i++) {
        tmpDiff = calcDiff(OHLCData, sPeriod, lPeriod, pri_type, i);
        sumDiff += tmpDiff;
      }
      double dea = sumDiff / period;
      double macd = diff - dea;
      value["diff"] = diff;
      value["dea"] = dea;
      value["macd"] = macd;
    }

    return value;
  }

  /**
   * 计算DMI
   * @param OHLCData
   * @param period
   * @param index
   * @return
   */
  Map<String, double> calcDMI(List<OHLCEntity> OHLCData, int period, int index) {
    Map<String, double> value = {};
    int counts = OHLCData.length;
    if (index < period || index >= counts) return {};

    double dmPlusSum = 0;
    double dmMinusSum = 0;
    double trSum = 0;

    double dmPlus = 0; //+DM:当前K线的最高价-前日K线的最高价
    double dmMinus = 0; //-DM

    double tr = 0; //真实波幅
    double trTmp = 0;

    double diPlus = 0;
    double diMinus = 0; //-DI:下降动向值

    double dx = 0;
    double dxTmp = 0;
    double adx = 0;

    //计算上升动向,下降动向和真实波幅
    for (int i = index; i > (index - period); i--) {
      //+DM
      dmPlus = (OHLCData[i].high ?? 0) - (OHLCData[i - 1].high ?? 0) < 0 ? 0 : ((OHLCData[i].high ?? 0) - (OHLCData[i - 1].high ?? 0)).toDouble();
      //-DM
      dmMinus = (OHLCData[i - 1].low ?? 0) - (OHLCData[i].low ?? 0) < 0 ? 0 : ((OHLCData[i - 1].low ?? 0) - (OHLCData[i].low ?? 0)).toDouble();

      tr = ((OHLCData[i].high ?? 0) - (OHLCData[i].low ?? 0)).toDouble();

      if (tr < 0) tr = -tr;
      trTmp = ((OHLCData[i].high ?? 0) - (OHLCData[i - 1].close ?? 0)).toDouble();

      if (trTmp < 0) trTmp = -trTmp;
      if (tr < trTmp) tr = trTmp;

      trTmp = ((OHLCData[i].low ?? 0) - (OHLCData[i - 1].close ?? 0)).toDouble();

      if (trTmp < 0) trTmp = -trTmp;
      if (tr < trTmp) tr = trTmp;

      //属性求和
      trSum += tr;
      dmPlusSum += dmPlus;
      dmMinusSum += dmMinus;
    }

    //计算+DI和-DI
    if (trSum == 0) {
      //分母为0的情况
      diPlus = 0;
      diMinus = 0;
    } else {
      diPlus = (dmPlusSum / trSum) * 100;
      diMinus = (dmMinusSum / trSum) * 100;
    }

    //计算DX
    dxTmp = diPlus - diMinus;
    if (dxTmp < 0) dxTmp = -dxTmp;
    if ((diMinus + diPlus) != 0.0) {
      dx = dxTmp / (diMinus + diPlus) * 100;
    } else {
      dx = 0;
    }

    //计算ADX
    adx = dx / 1; //这里ADX应该是dx的移动平均值

    value["down"] = diMinus;
    value["up"] = diPlus;
    value["adx"] = adx;

    return value;
  }

  /**
   * 计算周期内的最大值
   * @param OHLCData
   * @param period
   * @param index
   * @return
   */
  double calcHighest(List<OHLCEntity> OHLCData, int period, int index) {
    double high = 0;
    if (index < period - 1 || index >= OHLCData.length) return 0;
    high = (OHLCData[index - period + 1].high ?? 0).toDouble();

    for (int i = index - period + 2; i <= index; ++i) {
      high = high > (OHLCData[i].high ?? 0) ? high : (OHLCData[i].high ?? 0).toDouble();
    }
    return high;
  }

  /**
   * 计算周期内的最小值
   * @param OHLCData
   * @param period
   * @param index
   * @return
   */
  double calcLowest(List<OHLCEntity> OHLCData, int period, int index) {
    double low = 0;
    if (index < period - 1 || index >= OHLCData.length) return 0;
    low = (OHLCData[index - period + 1].low ?? 0).toDouble();

    for (int i = index - period + 2; i <= index; ++i) {
      low = low < (OHLCData[i].low ?? 0) ? low : (OHLCData[i].low ?? 0).toDouble();
    }
    return low;
  }

  /**
   * 计算KDJ的RSV值
   * @param OHLCData
   * @param period
   * @param index
   * @return
   */
  double calcRSV(List<OHLCEntity> OHLCData, int period, int index) {
    double hh = 0;
    double ll = 0;
    double Rsv = 0;
    hh = calcHighest(OHLCData, period, index);
    ll = calcLowest(OHLCData, period, index);

    if ((hh - ll) == 0) {
      Rsv = 0;
    } else {
      Rsv = (OHLCData[index].close ?? 0 - ll) / (hh - ll) * 100;
    }

    return Rsv;
  }

  /**
   * 计算KDJ的K值
   * @param OHLCData
   * @param period
   * @param index
   * @return
   */
  double calcK(List<OHLCEntity> OHLCData, int period, int index, int M1) {
    //K:=SMA(RSV,M1,1)=(1*RSV+(M1-1)*K')/M1=RSV/M1+(M1-1)/M1*K';K1是上个周期的K值,若前一周期无K值,以50代替;M1>1是必要条件
    M1 = M1 < 1 ? 2 : M1;
    double k = 50.0;
    int i = period;
    if (index > period && index - period > period * 4) i = index - period * 4;
    for (; i <= index; i++) {
      k = calcRSV(OHLCData, period, i) / M1 + (M1 - 1) / M1 * k;
    }
    return k;
  }

  /**
   * 计算当前位置KDJ
   * @param OHLCData 数据集合
   * @param period 周期
   * @param index 索引
   * @param m1
   * @param m2
   * @return
   */
  Map<String, double> calcKDJ(List<OHLCEntity> OHLCData, int period, int index, int m1, int m2) {
    Map<String, double> value = <String, double>{};
    int counts = OHLCData.length;
    if (index < period - 1 || index >= counts) return {};

    //D:=SMA(K,M2,1)=K/M2+(M2-1)/M2*D';M2>1
    double k = 0.0, d = 50.0, j = 0.0;
    int i = period - 1;
    if (index > period && index - period > period * 4) i = index - period * 4;

    for (; i <= index; i++) {
      k = calcK(OHLCData, period, i, m1);
      d = k / m2 + (m2 - 1) / m2 * d;
    }

    //J:=3*K-2*D
    j = 3 * k - 2 * d;

    value["K"] = k;
    value["D"] = d;
    value["J"] = j;

    return value;
  }

  /**
   * 计算当前位置的WR值
   * @param OHLCData
   * @param period1 WR1周期
   * @param period2 WR2周期
   * @param index
   * @return
   */
  Map<String, double> calcWR(List<OHLCEntity> OHLCData, int period1, int period2, int index) {
    Map<String, double> value = {};
    int counts = OHLCData.length;
    if (index < period1 - 1 || index < period2 - 1 || index >= counts) return {};

    double ll = 0.0, hh = 0.0;
    double wr1 = 0, wr2 = 0;
    hh = calcHighest(OHLCData, period1, index);
    ll = calcLowest(OHLCData, period1, index);

    //WR1:=100*(HHV(high??0,N1)-close)/(HHV(high??0,N1)-LLV(high??0,N1));
    if ((hh - ll) == 0) {
      wr1 = 0;
    } else {
      wr1 = 100 * (hh - (OHLCData[index].close ?? 0)) / (hh - ll);
    }

    hh = calcHighest(OHLCData, period2, index);
    ll = calcLowest(OHLCData, period2, index);
    if ((hh - ll) == 0) {
      wr2 = 0;
    } else {
      wr2 = 100 * (hh - (OHLCData[index].close ?? 0)) / (hh - ll);
    }

    value["WR1"] = wr1;
    value["WR2"] = wr2;

    return value;
  }

  /**
   * 计算TYP
   * @param OHLCData
   * @param index
   * @return
   */
  double calcTYP(List<OHLCEntity> OHLCData, int index) {
    double typ = 0.0;
    //TYP:=(high??0+low??0+close)/3
    typ = ((OHLCData[index].high ?? 0) + (OHLCData[index].low ?? 0) + (OHLCData[index].close ?? 0)) / 3;
    return typ;
  }

  /**
   * 计算CCI
   * @param OHLCData
   * @param index
   * @return
   */
  double calcCCI(List<OHLCEntity> OHLCData, int period, int index) {
    if (index < period - 1 || index >= OHLCData.length) return double.maxFinite;
    double cci = 0.0;

    //CCI:=(TYP-MA(TYP,N)) / (0.015*AVEDEV(TYP,N))
    //计算MA(TYP,N)
    double sumTyp = 0.0;
    for (int i = index - period + 1; i <= index; ++i) {
      sumTyp += calcTYP(OHLCData, i);
    }

    double maTyp = sumTyp / period;

    //计算AVEDEV(typ,N):=(|typ(n)-ma| + ... + |typ(1)-ma|) / period
    double sumDev = 0.0;
    for (int i = index - period + 1; i <= index; ++i) {
      sumDev += (calcTYP(OHLCData, i) - maTyp).abs();
    }

    if (sumDev > 0.000001) {
      cci = (calcTYP(OHLCData, index) - maTyp) / (0.015 * sumDev / period);
    } else {
      cci = 0.0;
    }

    return cci;
  }

  /**
   * 计算TR
   * @param OHLCData
   * @param index
   * @return
   */
  double calcTR(List<OHLCEntity> OHLCData, int index) {
    double tr = 0.0;
    if (index > 0) {
      tr = (OHLCData[index].high ?? 0 - (OHLCData[index].low ?? 0)).toDouble();
      double tmpTr = ((OHLCData[index - 1].close ?? 0) - (OHLCData[index].high ?? 0)).abs().toDouble();
      if (tr < tmpTr) tr = tmpTr;
      tmpTr = ((OHLCData[index - 1].close ?? 0) - (OHLCData[index - 1].low ?? 0)).abs().toDouble();
      if (tr < tmpTr) tr = tmpTr;
    }

    return tr;
  }

  /**
   * 计算ATR
   * @param OHLCData
   * @param period
   * @param index
   * @return
   */
  Map<String, double> calcATR(List<OHLCEntity> OHLCData, int period, int index) {
    Map<String, double> value = {};
    int counts = OHLCData.length;
    if (index < period - 1 || index >= counts) return {};

    double tr = calcTR(OHLCData, index);

    double sumTr = 0.0;
    for (int i = index - period + 1; i <= index; ++i) {
      sumTr += calcTR(OHLCData, i);
    }
    double atr = sumTr / period;

    value["TR"] = tr;
    value["ATR"] = atr;

    return value;
  }

  /**
   * 计算BIAS
   * @param OHLCData
   * @param period
   * @param pri_type
   * @param index
   * @return
   */
  double calcBIAS(List<OHLCEntity> OHLCData, int period, int pri_type, int index) {
    if (index < period - 1 || index >= OHLCData.length) return double.maxFinite;

    double bias = 0.0;
    double ma = 0.0;
    //BIAS:=(CLOSE-MA(CLOSE,N1)) / MA(CLOSE,N1) *100
    ma = calcCost(OHLCData, period, 0, pri_type, index);

    switch (pri_type) {
      //BIAS 价格类型(Open,Close,HL/2,high??0,low??0)

      case 0:
        bias = ((OHLCData[index].open ?? 0) - ma) / ma * 100;
        break;

      case 1:
        bias = ((OHLCData[index].high ?? 0) - ma) / ma * 100;
        break;

      case 2:
        bias = ((OHLCData[index].close ?? 0) - ma) / ma * 100;
        break;

      case 3:
        bias = ((OHLCData[index].low ?? 0) - ma) / ma * 100;
        break;

      case 4:
        bias = (((OHLCData[index].high ?? 0) + (OHLCData[index].low ?? 0)) / 2 - ma) / ma * 100;
        break;
    }

    return bias;
  }

  /**
   * 计算PSY
   * @param OHLCData
   * @param period
   * @param index
   * @return
   */
  double calcINPSY(List<OHLCEntity> OHLCData, int period, int index) {
    int count = OHLCData.length;
    if (index < period || index >= count) return 0.0;
    //PSY:=COUNT(CLOSE>REF(CLOSE,1),N)/N*100;
    double counts = 0.0, psy = 0.0;
    for (int i = index - period + 1; i <= index; i++) {
      if ((OHLCData[i].close ?? 0) > (OHLCData[i - 1].close ?? 0)) counts++;
    }

    psy = counts / period * 100;
    return psy;
  }

  /**
   * 计算PSY的值
   * @param OHLCData
   * @param period1
   * @param period2
   * @param index
   * @return
   */
  Map<String, double> calcPSY(List<OHLCEntity> OHLCData, int period1, int period2, int index) {
    Map<String, double> value = {};
    int counts = OHLCData.length;
    if (index < period1 || index >= counts) return {};

    double sumPsy = 0.0;
    //PSYMA:=MA(PSY,M);
    double psyma = 0.0;
    double psy = 0.0;
    if (index >= period1 + period2 - 1) {
      for (int i = index - period2 + 1; i <= index; i++) {
        sumPsy += calcINPSY(OHLCData, period1, i);
      }
      psyma = sumPsy / period2;
    }

    psy = calcINPSY(OHLCData, period1, index);

    value["PSYMA"] = psyma;
    value["PSY"] = psy;

    return value;
  }

  /**
   * 计算TRIX的tr值
   * @param OHLCData
   * @param trPeriod
   */
  void calcTRIX_TR(List<OHLCEntity> OHLCData, int trPeriod) {
    int count = OHLCData.length;

    double trPara1 = 2.0 / (trPeriod + 1);
    double trPara2 = (trPeriod - 1) / (trPeriod + 1);

    //一重指数移动平均值
    Tr1.clear();

    for (int i = 0; i < count; i++) {
      if (i < trPeriod - 1) {
        Tr1.add(0.0);
      } else if (i == trPeriod - 1) {
        Tr1.add((OHLCData[i].close ?? 0).toDouble());
      } else {
        //EMA(X,N)=2*X/(N+1)+(N-1)/(N+1)*昨天的指数收盘平均值
        Tr1.add(trPara1 * (OHLCData[i].close ?? 0) + trPara2 * Tr1[i - 1]);
      }
    }

    //二重指数移动平均
    Tr2.clear();
    for (int i = 0; i < count; ++i) {
      if (i < trPeriod) {
        Tr2.add(Tr1[i]);
      } else {
        Tr2.add(trPara1 * Tr1[i] + trPara2 * Tr2[i - 1]);
      }
    }

    //三重指数移动平均
    Tr3.clear();
    for (int i = 0; i < count; i++) {
      if (i < trPeriod) {
        Tr3.add(Tr2[i]);
      } else {
        Tr3.add(trPara1 * Tr2[i] + trPara2 * Tr3[i - 1]);
      }
    }
  }

  /**
   * 获取TRIX的TR值
   * @param OHLCData
   * @param trPeriod
   * @param index
   * @return
   */
  double getTR(List<OHLCEntity> OHLCData, int trPeriod, int index) {
    int count = OHLCData.length;
    double trValue = 0.0;
    double trPara1 = 2.0 / (trPeriod + 1);
    double trPara2 = (trPeriod - 1) / (trPeriod + 1);

    if (index < Tr3.length) {
      trValue = Tr3[index];
    } else if (index < count - 1) {
      //补全tr1,tr2,tr等值

      for (int i = Tr3.length; i < count - 1; ++i) {
        Tr1.add(trPara1 * (OHLCData[i].close ?? 0) + trPara2 * Tr1[i - 1]);
      }

      for (int i = Tr3.length; i < count - 1; ++i) {
        Tr2.add(trPara1 * Tr1[i] + trPara2 * Tr2[i - 1]);
      }

      for (int i = Tr3.length; i < count - 1; ++i) {
        Tr3.add(trPara1 * Tr2[i] + trPara2 * Tr3[i - 1]);
      }

      trValue = Tr3[index];
    } else {
      //最新数据
      if (index >= Tr1.length || index >= Tr2.length || index >= Tr3.length) {
        for (int i = Tr3.length; i <= index; ++i) {
          Tr1.add(trPara1 * (OHLCData[i].close ?? 0) + trPara2 * Tr1[i - 1]);
        }

        for (int i = Tr3.length; i <= index; ++i) {
          Tr2.add(trPara1 * Tr1[i] + trPara2 * Tr2[i - 1]);
        }

        for (int i = Tr3.length; i <= index; ++i) {
          Tr3.add(trPara1 * Tr2[i] + trPara2 * Tr3[i - 1]);
        }
      }

      trValue = trPara1 * (trPara1 * (trPara1 * (OHLCData[index].close ?? 0) + trPara2 * Tr1[index - 1]) + trPara2 * Tr2[index - 1]) + trPara2 * Tr3[index - 1];
    }

    return trValue;
  }

  /**
   * 计算Trix
   * @param OHLCData
   * @param trPeriod
   * @param matrixPeriod
   * @param index
   * @return
   */
  Map<String, double> calcTRIX(List<OHLCEntity> OHLCData, int trPeriod, int matrixPeriod, int index) {
    Map<String, double> value = <String, double>{};
    int counts = OHLCData.length;
    if (index < trPeriod || index >= counts) return {};

    double trix = 0.0, matrix = 0.0;

    //trix:=(tr-ref(tr,1))/ref(tr,1)*100
    trix = (getTR(OHLCData, trPeriod, index) - getTR(OHLCData, trPeriod, index - 1)) / getTR(OHLCData, trPeriod, index - 1) * 100;

    //matrix:=ma(trix,matrixPeriod)
    if (index < (trPeriod + matrixPeriod - 1)) {
      matrix = 0; //没有值
    } else {
      double trixSum = 0.0;
      for (int i = index - matrixPeriod + 1; i <= index; ++i) {
        trixSum += (getTR(OHLCData, trPeriod, i) - getTR(OHLCData, trPeriod, i - 1)) / getTR(OHLCData, trPeriod, i - 1) * 100;
      }
      matrix = trixSum / matrixPeriod;
    }

    value["TRIX"] = trix;
    value["MATRIX"] = matrix;
    return value;
  }

  /**
   * 计算VR
   * @param OHLCData
   * @param period
   * @param index
   * @return
   */
  double calcVR(List<OHLCEntity> OHLCData, int period, int index) {
    int counts = OHLCData.length;
    if (index < period || index >= counts) return 0;

    double uvs = 0.0;
    double dvs = 0.0;
    double pvs = 0.0;
    double vr = 0.0;

    for (int i = index - period + 1; i <= index; i++) {
      if ((OHLCData[i].close ?? 0) > (OHLCData[i].open ?? 0)) {
        uvs += OHLCData[i].volume ?? 0;
//				if(index==OHLCData.length-1){
//					Log.e("Vr计算：" , "uvs 位置：" + i + "  成交量："+ OHLCData[i].volume + "  index:"+index);
//				}
      } else if ((OHLCData[i].close ?? 0) < (OHLCData[i].open ?? 0)) {
        dvs += OHLCData[i].volume ?? 0;
//				if(index==OHLCData.length-1){
//					Log.e("Vr计算：" , "dvs 位置：" + i + "  成交量："+ OHLCData[i].volume + "  index:"+index);
//				}
      } else if (OHLCData[i].close == OHLCData[i].open) {
        pvs += OHLCData[i].volume ?? 0;
//				if(index==OHLCData.length-1){
//					Log.e("Vr计算：" , "pvs 位置：" + i + "  成交量："+ OHLCData[i].volume + "  index:"+index);
//				}
      }
    }

//		if(index==OHLCData.length-1){
//			Log.e("Vr计算：" , "uvs:"+uvs + "  dvs:"+dvs + "  pvs:"+pvs);
//		}

    vr = ((uvs + pvs / 2) / (dvs + pvs / 2)) * 100;
    return vr;
  }
}
