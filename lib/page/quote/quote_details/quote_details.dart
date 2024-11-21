import 'dart:convert';
import 'dart:math' hide log;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../../../config/common.dart';
import '../../../model/k/OHLCEntity.dart';
import '../../../model/k/k_chart_data/AlligatorEntity.dart';
import '../../../model/k/k_chart_data/BIASEntity.dart';
import '../../../model/k/k_chart_data/BollingerEntity.dart';
import '../../../model/k/k_chart_data/CCIEntity.dart';
import '../../../model/k/k_chart_data/CostLineEntity.dart';
import '../../../model/k/k_chart_data/FallLineEntity.dart';
import '../../../model/k/k_chart_data/KDJEntity.dart';
import '../../../model/k/k_chart_data/MACDEntity.dart';
import '../../../model/k/k_chart_data/PSYEntity.dart';
import '../../../model/k/k_chart_data/RSIEntity.dart';
import '../../../model/k/k_chart_data/VREntity.dart';
import '../../../model/k/k_chart_data/VolEntity.dart';
import '../../../model/k/k_chart_data/WREntity.dart';
import '../../../model/k/k_flag.dart';
import '../../../model/k/k_preiod.dart';
import '../../../model/k/k_time.dart';
import '../../../model/k/port.dart';
import '../../../model/pb/quote/fill.pb.dart';
import '../../../model/quote/contract.dart';
import '../../../model/socket_packet/operation.dart';
import '../../../server/quote/market.dart';
import '../../../util/event_bus/eventBus_utils.dart';
import '../../../util/event_bus/events.dart';
import '../../../util/info_bar/info_bar.dart';
import '../../../util/log/log.dart';
import '../../../util/painter/k_chart/base_k_chart_painter.dart';
import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/sub_chart_painter.dart';
import '../../../util/theme/theme.dart';
import '../../../util/utils/k_util.dart';
import '../../../util/utils/market_util.dart';
import '../../../util/utils/utils.dart';
import '../../../util/widget/dash_line.dart';

class QuoteDetails extends StatefulWidget {
  final Contract contract;

  const QuoteDetails(this.contract, {super.key});

  @override
  State<QuoteDetails> createState() => _QuoteDetailsState();
}

class _QuoteDetailsState extends State<QuoteDetails> with TickerProviderStateMixin {
  Contract? contract = Contract();
  List<FillData> quoteFilledData = [];
  List<Contract> mConSelects = [];
  late AppTheme appTheme;
  final mainMenuController = FlyoutController();
  final priceController = FlyoutController();
  String lastPrice = "--";
  String change = "--";
  String changePer = "--";
  String salePrice = "--";
  String saleNum = "--";
  String buyPrice = "--";
  String buyNum = "--";
  String highPrice = "--";
  String lowPrice = "--";
  String volume = "--";

  KPeriod kPeriod = KPeriod();
  List<OHLCEntity> mOHLCData = [];

  bool isSetIndex = true;
  bool isDrawTime = true;
  bool isDrawBollinger = false;
  bool isDrawCost = true;
  bool isDrawCost1 = true;
  bool isDrawCost2 = true;
  bool isDrawCost3 = false;
  bool isDrawCost4 = false;
  bool isDrawCost5 = true;
  bool isDrawFall = false;
  bool isDrawVOL = true;
  bool isDrawVR = true;
  bool isDrawMACD = true;
  bool isDrawKDJ = true;
  bool isDrawRSI = true;
  bool isDrawCCI = true;
  bool isDrawBIAS = true;
  bool isDrawOBV = true;
  bool isDrawWR = true;
  bool isDrawDMA = true;
  bool isDrawPSY = true;
  bool isDrawMACDBANG = true;

  int subCount = 2;
  bool showSubDraw = true;
  bool canDrawMACD = true;
  bool canDrawVR = false,
      canDrawVOL = false,
      canDrawKDJ = false,
      canDrawRSI = false,
      canDrawCCI = false,
      canDrawBIAS = false,
      canDrawOBV = false,
      canDrawWR = false,
      canDrawDMA = false,
      canDrawPSY = false,
      canDrawMACDBANG = false;
  bool showSubDraw1 = true;
  bool canDrawMACD1 = true;
  bool canDrawVR1 = false,
      canDrawVOL1 = false,
      canDrawKDJ1 = false,
      canDrawRSI1 = false,
      canDrawCCI1 = false,
      canDrawBIAS1 = false,
      canDrawOBV1 = false,
      canDrawWR1 = false,
      canDrawDMA1 = false,
      canDrawPSY1 = false,
      canDrawMACDBANG1 = false;
  bool showSubDraw2 = false;
  bool canDrawMACD2 = false;
  bool canDrawVR2 = false,
      canDrawVOL2 = false,
      canDrawKDJ2 = true,
      canDrawRSI2 = false,
      canDrawCCI2 = false,
      canDrawBIAS2 = false,
      canDrawOBV2 = false,
      canDrawWR2 = false,
      canDrawDMA2 = false,
      canDrawPSY2 = false,
      canDrawMACDBANG2 = false;
  bool showSubDraw3 = false;
  bool canDrawMACD3 = false;
  bool canDrawVR3 = false,
      canDrawVOL3 = false,
      canDrawKDJ3 = false,
      canDrawRSI3 = true,
      canDrawCCI3 = false,
      canDrawBIAS3 = false,
      canDrawOBV3 = false,
      canDrawWR3 = false,
      canDrawDMA3 = false,
      canDrawPSY3 = false,
      canDrawMACDBANG3 = false;
  final menuController = FlyoutController();
  final menuController1 = FlyoutController();
  final menuController2 = FlyoutController();
  final menuController3 = FlyoutController();
  bool isDrawCrossLine = false;

  ///一档报价
  int level = 1;

  /// 当前横坐标
  double currentX = -1;

  /// 当前纵坐标
  double currentY = -1;
  bool isNeedAddData = true;

  /// MACD数据
  MACDEntity? mMACDData;

  /// RSI数据
  RSIEntity? mRSIData;

  /// 布林带数据
  BollingerEntity? mBollingerData;

  /// 均线数据
  CostLineEntity? mCostData;

  /// 瀑布线数据
  FallLineEntity? mFallData;

  /// 鳄鱼线数据
  AlligatorEntity? mAlligatorData;

  /// KDJ线数据
  KDJEntity? mKDJData;

  /// WR线数据
  WREntity? mWRData;

  /// CCI线数据
  CCIEntity? mCCIData;

  /// BIAS线数据
  BIASEntity? mBIASData;

  /// PSY线数据
  PSYEntity? mPSYData;

  /// 成交量线数据
  VolEntity? mVolData;

  /// VR线数据
  VREntity? mVRData;
  int cost_indexType = 0;
  int cost_priceType = 2;
  int Bollinger_priceType = 2;
  int Fall_priceType = 2;
  int MACD_priceType = 2;
  int RSI_priceType = 2;
  int BIAS_priceType = 2;
  int GUBI_indexType = 0;
  bool SWITHING_TIME = false;
  bool SWITHING_CODE = false;
  bool SWITHING_INDEX = false;
  bool SWITHING_PERIOD = false;
  bool ADD_DATA = false;
  bool isReachLast = false;
  bool mHaveCorrected = true;

  bool isDrawTimeDown = true;
  bool isSwithing = false;
  bool isAllowAdd = true;
  bool isSwithSmart = false;
  bool type_changed = false;
  int mDataStartIndext = 0;
  int mShowDataNum = 180;
  int scaleShowDataNum = 180;
  double mChartWidth = 0;
  int MIN_CANDLE_NUM = 12;
  int mPreSize = 0;
  num mStartX = 0;
  num mStartY = 0;
  int mDownIndext = 0;

  double mCandleWidth = Port.CandleWidth;
  double scaleCandleWidth = Port.CandleWidth;
  double mMaxPrice = -1;
  double mMinPrice = -1;
  String mStartDate = "";

  String pankouLastPrice = "--";
  String pankouChange = "--";
  String pankouBuyprice = "--";
  String pankouBuynum = "--";
  String pankouSaleprice = "--";
  String pankouSalenum = "--";
  String pankouOpenprice = "--";
  String pankouVolume = "--";
  String pankouHighprice = "--";
  String pankouPosition = "--";
  String pankouLowprice = "--";
  String pankouPoor = "--";
  String pankouAvr = "--";
  String pankouClear = "--";
  String pankouPresettle = "--";
  String pankouPreclose = "--";
  String pankouUpLimit = "--";
  String pankouExterDisk = "--";
  String pankouDownLimit = "--";
  String pankouInnerDisk = "--";
  Color pankouColor = HexColor("#ff204a");
  String chartTradeAllAssest = "--";
  String chartTradeCanuse = "--";
  String tradeBuyCanOpen = "--";
  String tradeBuyCanClose = "--";
  String tradeSaleCanOpen = "--";
  String tradeSaleCanClose = "--";
  String chartTradeFloatProfit = "--";
  double leftMarginSpace = ChartPainter.getStringWidth("000.000", TextPainter(), size: Port.ChartTextSize);

  getKPeriod() async {
    kPeriod = KPeriod(name: "分时", period: KTime.FS, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
    subscriptionKlineData(true);
    requestAllData();
  }

  void addMoreData(List<OHLCEntity> list) {
    List<OHLCEntity> localList = [];
    localList.addAll(mOHLCData);
    localList.insertAll(0, list);
    setOHLCData(localList);
  }

  void setOHLCData(List<OHLCEntity> OHLCData) {
    if (mChartWidth == 0) {
      num right = BaseKChartPainter.mCursorWidth;
      double chartWidth = ChartPainter.kChartViewWidth - 2 * BaseKChartPainter.MARGINLEFT - right - ChartPainter.leftMarginSpace;
      mChartWidth = chartWidth;
    }
    int count = 0; //增加的数据量

    if (OHLCData.isEmpty) {
      return;
    } else {
      mOHLCData.clear();
    }
    mOHLCData.addAll(OHLCData);

    if (mShowDataNum > mOHLCData.length) {
      mShowDataNum = mOHLCData.length;
    }

    if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
      mPreSize = 0;
      isReachLast = false;
    }

    if (mPreSize == 0) {
      //记录集合大小,计算增加的数据量
      count = 0;
      mPreSize = mOHLCData.length;
    } else {
      if (mOHLCData.length - mPreSize != 0) {
        // mChartViewListener.enterNext(); //K线数量有变化
      }
      count = mOHLCData.length - mPreSize == 0 ? 1 : mOHLCData.length - mPreSize + 1;
      mPreSize = mOHLCData.length;
    }

    //初始化瀑布线线数据
    if (isDrawFall) {
      if (mFallData == null) {
        mFallData = FallLineEntity();
        mFallData?.initData(mOHLCData, ChartPainter.FallPeriod1, ChartPainter.FallPeriod2, ChartPainter.FallPeriod3, ChartPainter.FallPeriod4,
            ChartPainter.FallPeriod5, ChartPainter.FallPeriod6, Fall_priceType);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mFallData?.initData(mOHLCData, ChartPainter.FallPeriod1, ChartPainter.FallPeriod2, ChartPainter.FallPeriod3, ChartPainter.FallPeriod4,
              ChartPainter.FallPeriod5, ChartPainter.FallPeriod6, Fall_priceType);
        } else {
          mFallData?.addData(mOHLCData, ChartPainter.FallPeriod1, ChartPainter.FallPeriod2, ChartPainter.FallPeriod3, ChartPainter.FallPeriod4,
              ChartPainter.FallPeriod5, ChartPainter.FallPeriod6, Fall_priceType, count);
        }
      }
    }

    //初始化均线数据
    if (isDrawCost) {
      if (mCostData == null) {
        mCostData = CostLineEntity();
        mCostData?.initData(mOHLCData, ChartPainter.CostOnePeriod, ChartPainter.CostTwoPeriod, ChartPainter.CostThreePeriod, ChartPainter.CostFourPeriod,
            ChartPainter.CostFivePeriod, cost_indexType, cost_priceType);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mCostData?.initData(mOHLCData, ChartPainter.CostOnePeriod, ChartPainter.CostTwoPeriod, ChartPainter.CostThreePeriod, ChartPainter.CostFourPeriod,
              ChartPainter.CostFivePeriod, cost_indexType, cost_priceType);
        } else {
          mCostData?.addData(mOHLCData, ChartPainter.CostOnePeriod, ChartPainter.CostTwoPeriod, ChartPainter.CostThreePeriod, ChartPainter.CostFourPeriod,
              ChartPainter.CostFivePeriod, cost_indexType, cost_priceType, count);
        }
      }
    }

    //初始化布林线数据
    if (isDrawBollinger) {
      if (mBollingerData == null) {
        mBollingerData = BollingerEntity();
        mBollingerData?.initData(mOHLCData, ChartPainter.BollingerPeriod, 0, Bollinger_priceType);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mBollingerData?.initData(mOHLCData, ChartPainter.BollingerPeriod, 0, Bollinger_priceType);
        } else {
          mBollingerData?.addData(mOHLCData, ChartPainter.BollingerPeriod, 0, Bollinger_priceType, count);
        }
      }
    }

    //初始化MACD数据
    if (isDrawMACD) {
      if (mMACDData == null) {
        mMACDData = MACDEntity();
        mMACDData?.initData(mOHLCData, ChartPainter.macdSPeriod, ChartPainter.macdLPeriod, ChartPainter.macdPeriod, MACD_priceType);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mMACDData?.initData(mOHLCData, ChartPainter.macdSPeriod, ChartPainter.macdLPeriod, ChartPainter.macdPeriod, MACD_priceType);
        } else {
          mMACDData?.addData(mOHLCData, ChartPainter.macdSPeriod, ChartPainter.macdLPeriod, ChartPainter.macdPeriod, MACD_priceType, count);
        }
      }
    }

    //初始化RSI数据
    if (isDrawMACD) {
      if (mRSIData == null) {
        mRSIData = RSIEntity();
        mRSIData?.initData(mOHLCData, ChartPainter.rsiPeriod, 2);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mRSIData?.initData(mOHLCData, ChartPainter.rsiPeriod, RSI_priceType);
        } else {
          mRSIData?.addData(mOHLCData, ChartPainter.rsiPeriod, RSI_priceType, count);
        }
      }
    }

    //初始化KDJ数据
    if (isDrawKDJ) {
      if (mKDJData == null) {
        mKDJData = KDJEntity();
        mKDJData?.initData(OHLCData, ChartPainter.KDJPeriod, 2, ChartPainter.KDJ_M1, ChartPainter.KDJ_M2);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mKDJData?.initData(OHLCData, ChartPainter.KDJPeriod, 2, ChartPainter.KDJ_M1, ChartPainter.KDJ_M2);
        } else {
          mKDJData?.addData(OHLCData, ChartPainter.KDJPeriod, 2, count, ChartPainter.KDJ_M1, ChartPainter.KDJ_M2);
        }
      }
    }

    //初始化WR数据
    if (isDrawWR) {
      if (mWRData == null) {
        mWRData = WREntity();
        mWRData?.initData(OHLCData, ChartPainter.Wr1Period, ChartPainter.Wr2Period, 2);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mWRData?.initData(OHLCData, ChartPainter.Wr1Period, ChartPainter.Wr2Period, 2);
        } else {
          mWRData?.addData(OHLCData, ChartPainter.Wr1Period, ChartPainter.Wr2Period, 2, count);
        }
      }
    }

    //初始化CCI数据
    if (isDrawCCI) {
      if (mCCIData == null) {
        mCCIData = CCIEntity();
        mCCIData?.initData(OHLCData, ChartPainter.CCIPeriod, 2);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mCCIData?.initData(OHLCData, ChartPainter.CCIPeriod, 2);
        } else {
          mCCIData?.addData(OHLCData, ChartPainter.CCIPeriod, 2, count);
        }
      }
    }

    //初始化BIAS数据
    if (isDrawBIAS) {
      if (mBIASData == null) {
        mBIASData = BIASEntity();
        mBIASData?.initData(OHLCData, ChartPainter.BIAS1Period, ChartPainter.BIAS2Period, ChartPainter.BIAS3Period, BIAS_priceType);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mBIASData?.initData(OHLCData, ChartPainter.BIAS1Period, ChartPainter.BIAS2Period, ChartPainter.BIAS3Period, BIAS_priceType);
        } else {
          mBIASData?.addData(OHLCData, ChartPainter.BIAS1Period, ChartPainter.BIAS2Period, ChartPainter.BIAS3Period, BIAS_priceType, count);
        }
      }
    }

    //初始化PSY数据
    if (isDrawPSY) {
      if (mPSYData == null) {
        mPSYData = PSYEntity();
        mPSYData?.initData(OHLCData, ChartPainter.PSYPeriod, ChartPainter.PSYMAPeriod, 2);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mPSYData?.initData(OHLCData, ChartPainter.PSYPeriod, ChartPainter.PSYMAPeriod, 2);
        } else {
          mPSYData?.addData(OHLCData, ChartPainter.PSYPeriod, ChartPainter.PSYMAPeriod, 2, count);
        }
      }
    }

    //初始化VR数据
    if (isDrawVR) {
      if (mVRData == null) {
        mVRData = VREntity();
        mVRData?.initData(mOHLCData, ChartPainter.VRPeriod);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mVRData?.initData(mOHLCData, ChartPainter.VRPeriod);
        } else {
          mVRData?.addData(mOHLCData, ChartPainter.VRPeriod, count);
        }
      }
    }

    //初始化VOL数据
    if (isDrawVOL) {
      if (mVolData == null) {
        mVolData = VolEntity();
        mVolData?.initData(OHLCData);
      } else {
        mVolData?.initData(OHLCData);
      }
    }

    mShowDataNum = mChartWidth == 0 ? mShowDataNum : mChartWidth ~/ mCandleWidth - 1; //减1是为了最后一根不超出右边界线
    if (mShowDataNum > mOHLCData.length) {
      mShowDataNum = mOHLCData.length;
    }
    mDataStartIndext = ADD_DATA == true ? Utils.getStartIndex(mStartDate, mOHLCData) : mOHLCData.length - mShowDataNum;
    SWITHING_TIME = false; //数据切换结束
    SWITHING_CODE = false; //切换商品代码结束
    isSwithSmart = false; //智能系统切换
    type_changed = false; //类型切换结束
    SWITHING_INDEX = false; //指标切换结束
    SWITHING_PERIOD = false; //z周期切换结束
    ADD_DATA = false; //添加数据集合结束
    mHaveCorrected = true;
    setCurrentData();
  }

  /// 计算当前屏幕中将绘制的K线数据的最高价最低价
  void setCurrentData() {
    if (mOHLCData.isEmpty) return;

    if (mShowDataNum > mOHLCData.length) {
      mShowDataNum = mOHLCData.length;
    }
    if (MIN_CANDLE_NUM > mOHLCData.length) {
      mShowDataNum = MIN_CANDLE_NUM;
    }

    if (mShowDataNum > mOHLCData.length) {
      mDataStartIndext = 0;
    } else if (mShowDataNum + mDataStartIndext > mOHLCData.length) {
      mDataStartIndext = mOHLCData.length - mShowDataNum;
    } else if (isSetIndex) {
      //初始化蜡烛线开始位置
      mDataStartIndext = mOHLCData.length - mShowDataNum;
      isSetIndex = false;
    }

    // 计算蜡烛线的最高价最低价
    mMinPrice = mOHLCData[mDataStartIndext].low?.toDouble() ?? 0;
    mMaxPrice = mOHLCData[mDataStartIndext].high?.toDouble() ?? 0;
    for (int i = mDataStartIndext + 1; i < mOHLCData.length && i < mShowDataNum + mDataStartIndext; i++) {
      OHLCEntity entity = mOHLCData[i];
      mMinPrice = mMinPrice < (entity.low ?? 0) ? mMinPrice : (entity.low?.toDouble() ?? 0);
      mMaxPrice = mMaxPrice > (entity.high ?? 0) ? mMaxPrice : (entity.high?.toDouble() ?? 0);
    }

    if (mBollingerData != null && isDrawBollinger && mBollingerData!.BollingerAVE.isNotEmpty) {
      for (int i = mDataStartIndext; i < mOHLCData.length && i < mShowDataNum + mDataStartIndext; i++) {
        if (i >= ChartPainter.BollingerPeriod - 1) {
          int loction = i - (ChartPainter.BollingerPeriod - 1);
          if (loction < mBollingerData!.BollingerAVE.length && loction < mBollingerData!.BollingerSQRT.length) {
            mMinPrice = mMinPrice < mBollingerData!.BollingerAVE[loction] - ChartPainter.BollingerSD * mBollingerData!.BollingerSQRT[loction]
                ? mMinPrice
                : mBollingerData!.BollingerAVE[loction] - ChartPainter.BollingerSD * mBollingerData!.BollingerSQRT[loction];
            mMinPrice = mMinPrice < mBollingerData!.BollingerAVE[loction] + ChartPainter.BollingerSD * mBollingerData!.BollingerSQRT[loction]
                ? mMinPrice
                : mBollingerData!.BollingerAVE[loction] + ChartPainter.BollingerSD * mBollingerData!.BollingerSQRT[loction];
            mMaxPrice = mMaxPrice > mBollingerData!.BollingerAVE[loction] - ChartPainter.BollingerSD * mBollingerData!.BollingerSQRT[loction]
                ? mMaxPrice
                : mBollingerData!.BollingerAVE[loction] - ChartPainter.BollingerSD * mBollingerData!.BollingerSQRT[loction];
            mMaxPrice = mMaxPrice > mBollingerData!.BollingerAVE[loction] + ChartPainter.BollingerSD * mBollingerData!.BollingerSQRT[loction]
                ? mMaxPrice
                : mBollingerData!.BollingerAVE[loction] + ChartPainter.BollingerSD * mBollingerData!.BollingerSQRT[loction];
          }
        }
      }
    }

    //计算有均线时的最大 最小值
    if (mCostData != null && isDrawCost && mCostData!.CostOne.isNotEmpty) {
      for (int i = mDataStartIndext; i < mOHLCData.length && i < mShowDataNum + mDataStartIndext; i++) {
        if (i >= ChartPainter.CostOnePeriod - 1 && isDrawCost1) {
          int loction = i - (ChartPainter.CostOnePeriod - 1);
          if (loction < mCostData!.CostOne.length) {
            mMinPrice = mMinPrice < mCostData!.CostOne[loction] ? mMinPrice : mCostData!.CostOne[loction];
            mMaxPrice = mMaxPrice > mCostData!.CostOne[loction] ? mMaxPrice : mCostData!.CostOne[loction];
          }
        }

        if (i >= ChartPainter.CostTwoPeriod - 1 && isDrawCost2) {
          int loction = i - (ChartPainter.CostTwoPeriod - 1);
          if (loction < mCostData!.CostTwo.length) {
            mMinPrice = mMinPrice < mCostData!.CostTwo[loction] ? mMinPrice : mCostData!.CostTwo[loction];
            mMaxPrice = mMaxPrice > mCostData!.CostTwo[loction] ? mMaxPrice : mCostData!.CostTwo[loction];
          }
        }

        if (i >= ChartPainter.CostThreePeriod - 1 && isDrawCost3) {
          int loction = i - (ChartPainter.CostThreePeriod - 1);
          if (loction < mCostData!.CostThree.length) {
            mMinPrice = mMinPrice < mCostData!.CostThree[loction] ? mMinPrice : mCostData!.CostThree[loction];
            mMaxPrice = mMaxPrice > mCostData!.CostThree[loction] ? mMaxPrice : mCostData!.CostThree[loction];
          }
        }

        if (i >= ChartPainter.CostFourPeriod - 1 && isDrawCost4) {
          int loction = i - (ChartPainter.CostFourPeriod - 1);
          if (loction < mCostData!.CostFour.length) {
            mMinPrice = mMinPrice < mCostData!.CostFour[loction] ? mMinPrice : mCostData!.CostFour[loction];
            mMaxPrice = mMaxPrice > mCostData!.CostFour[loction] ? mMaxPrice : mCostData!.CostFour[loction];
          }
        }

        if (i >= ChartPainter.CostFivePeriod - 1 && isDrawCost5) {
          int loction = i - (ChartPainter.CostFivePeriod - 1);
          if (loction < mCostData!.CostFive.length) {
            mMinPrice = mMinPrice < mCostData!.CostFive[loction] ? mMinPrice : mCostData!.CostFive[loction];
            mMaxPrice = mMaxPrice > mCostData!.CostFive[loction] ? mMaxPrice : mCostData!.CostFive[loction];
          }
        }
      }
    }

    // 计算有瀑布线时的最大 最小值
    if (mFallData != null && isDrawFall && mFallData!.PBX1.isNotEmpty) {
      for (int i = mDataStartIndext; i < mOHLCData.length && i < mShowDataNum + mDataStartIndext; i++) {
        if (i >= (ChartPainter.FallPeriod1 * 4 - 1)) {
          int loction = i - ((ChartPainter.FallPeriod1 * 4 - 1));
          if (loction < mFallData!.PBX1.length) {
            mMinPrice = mMinPrice < mFallData!.PBX1[loction] ? mMinPrice : mFallData!.PBX1[loction];
            mMaxPrice = mMaxPrice > mFallData!.PBX1[loction] ? mMaxPrice : mFallData!.PBX1[loction];
          }
        }

        if (i >= (ChartPainter.FallPeriod2 * 4 - 1)) {
          int loction = i - ((ChartPainter.FallPeriod2 * 4 - 1));
          if (loction < mFallData!.PBX2.length) {
            mMinPrice = mMinPrice < mFallData!.PBX2[loction] ? mMinPrice : mFallData!.PBX2[loction];
            mMaxPrice = mMaxPrice > mFallData!.PBX2[loction] ? mMaxPrice : mFallData!.PBX2[loction];
          }
        }

        if (i >= (ChartPainter.FallPeriod3 * 4 - 1)) {
          int loction = i - ((ChartPainter.FallPeriod3 * 4 - 1));
          if (loction < mFallData!.PBX3.length) {
            mMinPrice = mMinPrice < mFallData!.PBX3[loction] ? mMinPrice : mFallData!.PBX3[loction];
            mMaxPrice = mMaxPrice > mFallData!.PBX3[loction] ? mMaxPrice : mFallData!.PBX3[loction];
          }
        }

        if (i >= (ChartPainter.FallPeriod4 * 4 - 1)) {
          int loction = i - ((ChartPainter.FallPeriod4 * 4 - 1));
          if (loction < mFallData!.PBX4.length) {
            mMinPrice = mMinPrice < mFallData!.PBX4[loction] ? mMinPrice : mFallData!.PBX4[loction];
            mMaxPrice = mMaxPrice > mFallData!.PBX4[loction] ? mMaxPrice : mFallData!.PBX4[loction];
          }
        }

        if (i >= (ChartPainter.FallPeriod5 * 4 - 1)) {
          int loction = i - ((ChartPainter.FallPeriod5 * 4 - 1));
          if (loction < mFallData!.PBX5.length) {
            mMinPrice = mMinPrice < mFallData!.PBX5[loction] ? mMinPrice : mFallData!.PBX5[loction];
            mMaxPrice = mMaxPrice > mFallData!.PBX5[loction] ? mMaxPrice : mFallData!.PBX5[loction];
          }
        }

        if (i >= (ChartPainter.FallPeriod6 * 4 - 1)) {
          int loction = i - ((ChartPainter.FallPeriod6 * 4 - 1));
          if (loction < mFallData!.PBX6.length) {
            mMinPrice = mMinPrice < mFallData!.PBX6[loction] ? mMinPrice : mFallData!.PBX6[loction];
            mMaxPrice = mMaxPrice > mFallData!.PBX6[loction] ? mMaxPrice : mFallData!.PBX6[loction];
          }
        }
      }
    }

    //计算下部MACD指标线数据的最高价，最低价
    if (mMACDData != null && isDrawMACD) {
      mMACDData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.macdSPeriod, ChartPainter.macdLPeriod, ChartPainter.macdPeriod);
    }

    if (mKDJData != null && isDrawKDJ) {
      mKDJData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.KDJPeriod);
    }

    if (mCCIData != null && isDrawCCI) {
      mCCIData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.CCIPeriod);
    }

    if (mBIASData != null && isDrawBIAS) {
      mBIASData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.BIAS1Period, ChartPainter.BIAS2Period, ChartPainter.BIAS3Period);
    }

    if (mVolData != null && isDrawVOL) {
      mVolData?.calclatePrice(mDataStartIndext, mShowDataNum);
    }

    if (mVRData != null && isDrawVR) {
      mVRData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.VRPeriod);
    }
  }

  void setTimeData(List<OHLCEntity> data) {
    if (data.isEmpty) {
      return;
    } else {
      mOHLCData.clear();
    }
    mOHLCData.addAll(data);
    if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
      mPreSize = 0;
    }
    if (mPreSize == 0) {
      //记录集合大小,计算增加的数据量
      mPreSize = mOHLCData.length;
    } else {
      if (mOHLCData.length - mPreSize != 0) {
        // mChartViewListener.enterNext();//K线数量有变化
      }
      mPreSize = mOHLCData.length;
    }
    mMinPrice = mOHLCData.first.close?.toDouble() ?? 0;
    mMaxPrice = mOHLCData.first.close?.toDouble() ?? 0;
    for (int i = 1; i < mOHLCData.length; i++) {
      mMinPrice = min(mMinPrice, mOHLCData[i].close?.toDouble() ?? 0);
      mMaxPrice = max(mMaxPrice, mOHLCData[i].close?.toDouble() ?? 0);
      mMinPrice = min(mMinPrice, mOHLCData[i].average?.toDouble() ?? 0);
      mMaxPrice = max(mMaxPrice, mOHLCData[i].average?.toDouble() ?? 0);
    }

    if (isDrawTimeDown) {
      BaseKChartPainter.TimeMarginLeft = 2;
      BaseKChartPainter.TimeMarginRight = 2;
      if (mVolData == null) {
        mVolData = VolEntity();
        mVolData?.initData(data);
      } else {
        mVolData?.initData(data);
      }
      mVolData?.calclatePrice(0, mOHLCData.length);
    }

    SWITHING_TIME = false; //数据切换结束
    SWITHING_CODE = false; //切换商品代码结束
    isSwithSmart = false; //智能系统切换
    type_changed = false; //类型切换结束
    SWITHING_INDEX = false; //指标切换结束
    SWITHING_PERIOD = false; //z周期切换结束
    ADD_DATA = false; //添加数据集合结束
  }

  void switchIndex(String name) {
    switch (name) {
      case "MA": //MA
        isDrawCost = true;
        isDrawCost1 = Port.isDrawCost1;
        isDrawCost2 = Port.isDrawCost2;
        isDrawCost3 = Port.isDrawCost3;
        isDrawCost4 = Port.isDrawCost4;
        isDrawCost5 = Port.isDrawCost5;
        isDrawBollinger = false;
        isDrawFall = false;
        break;
      case "BOLL": //BOLL
        isDrawCost = false;
        isDrawCost1 = Port.isDrawCost1;
        isDrawCost2 = Port.isDrawCost2;
        isDrawCost3 = Port.isDrawCost3;
        isDrawCost4 = Port.isDrawCost4;
        isDrawCost5 = Port.isDrawCost5;
        isDrawBollinger = true;
        isDrawFall = false;
        break;
      case "PBX": //FALL
        isDrawCost = false;
        isDrawCost1 = Port.isDrawCost1;
        isDrawCost2 = Port.isDrawCost2;
        isDrawCost3 = Port.isDrawCost3;
        isDrawCost4 = Port.isDrawCost4;
        isDrawCost5 = Port.isDrawCost5;
        isDrawBollinger = false;
        isDrawFall = true;
        break;
    }
    isAllowAdd = false;
    SWITHING_INDEX = true;
    List<OHLCEntity> tmp = [];
    tmp.addAll(mOHLCData);
    setOHLCData(tmp);
    isAllowAdd = true;
  }

  void switchSubIndex(String name) {
    switch (name) {
      case "VOL":
        isDrawVOL = true;
        break;
      case "VR":
        isDrawVR = true;
        break;
      case "MACD":
        isDrawMACD = true;
        break;
      case "KDJ":
        isDrawKDJ = true;
        break;
      case "RSI":
        isDrawRSI = true;
        break;
      case "CCI":
        isDrawCCI = true;
        break;
      case "BIAS":
        isDrawBIAS = true;
        break;
      case "OBV":
        // setAllMidFalse();
        // isMidDrawVolume = true;
        break;
      case "WR":
        isDrawWR = true;
        break;
      case "DMA":
        // setAllMidFalse();
        // isMidDrawVolume = true;
        break;
      case "PSY":
        isDrawPSY = true;
        break;
      case "MACD能量棒":
        // setAllMidFalse();
        // isMidDrawVolume = true;
        break;
    }
    isAllowAdd = false;
    SWITHING_INDEX = true;
    List<OHLCEntity> tmp = [];
    tmp.addAll(mOHLCData);
    setOHLCData(tmp);
    isAllowAdd = true;
  }

  /// 请求所有数据
  void requestAllData() async {
    isSwithing = true;
    if (kPeriod.period != null && kPeriod.period! >= 0) {
      if (kPeriod.cusType == 1) {
        await MarketServer.queryKline(contract!, kPeriod.period ?? KTime.FS, 0, 500).then((value) {
          if (value != null) {
            SWITHING_TIME = true;
            setOHLCData(value);
            isAllowAdd = true;
          }
          isSwithing = false;
        });
      } else {
        await MarketServer.customKline(contract!, kPeriod, 0, 500).then((value) {
          if (value != null) {
            SWITHING_TIME = true;
            setOHLCData(value);
            isAllowAdd = true;
          }
          isSwithing = false;
        });
      }
    } else {
      await MarketServer.queryFs(contract!).then((value) {
        if (value != null) {
          SWITHING_TIME = true;
          ChartPainter.lastClose = contract!.preSettlePrice!.toDouble();
          ChartPainter.calcFsTime(value[value.length - 1].date ?? '', value[value.length - 1].time ?? '');
          List<OHLCEntity> allList = KUtils.dealFsData(value, ChartPainter.mFsTimes, contract?.preSettlePrice?.toDouble() ?? 0, contract?.exCode ?? '');
          setTimeData(allList);
          isAllowAdd = true;
        }
        isSwithing = false;
      });
    }
    if (mounted) setState(() {});
  }

  void requestMoreKline(int UnixTime) async {
    if (kPeriod.cusType == 1) {
      await MarketServer.queryKline(contract!, kPeriod.period ?? KTime.FS, UnixTime, 100).then((value) {
        if (value != null) {
          ADD_DATA = true;
          isNeedAddData = true;
          isReachLast = false;
          addMoreData(value);
        } else {
          isNeedAddData = true;
          isReachLast = true;
          InfoBarUtils.showInfoBar("没有更多数据");
        }
      });
    } else {
      await MarketServer.customKline(contract!, kPeriod, UnixTime, 100).then((value) {
        if (value != null) {
          ADD_DATA = true;
          isNeedAddData = true;
          isReachLast = false;
          addMoreData(value);
        } else {
          isNeedAddData = true;
          isReachLast = true;
          InfoBarUtils.showInfoBar("没有更多数据");
        }
      });
    }
  }

  /// 矫正K线
  void correctKline(int count) {
    if (kPeriod.cusType == 1) {
      MarketServer.queryKline(contract!, kPeriod.period ?? KTime.FS, 0, count).then((value) {
        if (value != null) {
          correctData(value);
        } else {
          InfoBarUtils.showWarningBar("K线请求失败");
        }
      });
    } else {
      MarketServer.customKline(contract!, kPeriod, 0, count).then((value) {
        if (value != null) {
          correctData(value);
        } else {
          InfoBarUtils.showWarningBar("K线请求失败");
        }
      });
    }
  }

  void correctData(List<OHLCEntity> list) {
    if (mOHLCData.isEmpty) return;
    List<OHLCEntity> localList = [];
    localList.addAll(mOHLCData);
    String lastTime = "${localList[localList.length - 1].date} ${localList[localList.length - 1].time}";

    List<OHLCEntity> sameList = [];
    List<OHLCEntity> diffList = [];

    for (int i = 0; i < list.length; i++) {
      String newTime = "${list[i].date} ${list[i].time}";
      if (Utils.compareDate(lastTime, newTime) == 1) {
        //新周期时间直接添加
        diffList.add(list[i]);
      } else {
        sameList.add(list[i]);
      }
    }

    for (int i = 0; i < sameList.length; i++) {
      String newTime = "${sameList[i].date} ${sameList[i].time}";

      for (int j = localList.length - 1; j >= 0; j--) {
        String oldTime = "${localList[j].date} ${localList[j].time}";
        if (newTime == oldTime) {
          localList[j].open = sameList[i].open;
          localList[j].high = sameList[i].high;
          localList[j].close = sameList[i].close;
          localList[j].low = sameList[i].low;
          localList[j].volume = sameList[i].volume;
          localList[j].amount = sameList[i].amount;
          break;
        }
      }
    }
    localList.addAll(diffList);
    if (isDrawTime) {
      setTimeData(localList);
    } else {
      setOHLCData(localList);
    }
    isAllowAdd = true;
  }

  void refreshData() {
    String vol = "";
    if ((contract?.volume ?? 0) > 10000) {
      vol = "${Utils.dealPointBigDecimal((contract?.volume ?? 0) / 10000, 2)}万";
    } else if ((contract?.volume ?? 0) > 100000000) {
      vol = "${Utils.dealPointBigDecimal((contract?.volume ?? 0) / 100000000, 2)}亿";
    } else {
      vol = (contract?.volume ?? 0).toInt().toString();
    }

    double tick = (contract?.futureTickSize ?? 0).toDouble();
    lastPrice = Utils.d2SBySrc((contract?.lastPrice ?? 0).toDouble(), tick);
    change = Utils.double2Str(Utils.dealPointByOld(contract?.change, tick));
    if ((contract?.change ?? 0) < 0) {
      changePer = "-${Utils.double2Str(Utils.dealPointBigDecimal(contract?.changePer?.toDouble(), 2))}%";
    } else {
      changePer = "${Utils.double2Str(Utils.dealPointBigDecimal(contract?.changePer?.toDouble(), 2))} %";
    }

    buyPrice = Utils.d2SBySrc(contract?.buyPrice?.toDouble(), tick);
    salePrice = Utils.d2SBySrc(contract?.salePrice?.toDouble(), tick);
    buyNum = (contract?.level2List?[0].volume ?? 0).toInt().toString();
    saleNum = (contract?.level2List?[20].volume ?? 0).toInt().toString();
    highPrice = Utils.d2SBySrc(contract?.highPrice?.toDouble(), tick);
    lowPrice = Utils.d2SBySrc(contract?.lowPrice?.toDouble(), tick);
    volume = vol;

    // if ((contract?.change ?? 0) > 0) {
    //   commonColor = Common.quote_red_color;
    // } else if ((contract?.change ?? 0) < 0) {
    //   commonColor = Common.quote_green_color;
    // } else {
    //   commonColor = Common.quote_gray_color;
    // }
    pankouRefresh();
    if (mounted) setState(() {});
  }

  void pankouRefresh() {
    double tick = (contract?.futureTickSize ?? 0).toDouble();
    pankouLastPrice = Utils.double2Str(Utils.dealPointByOld(contract?.lastPrice, tick));
    pankouChange = Utils.double2Str(Utils.dealPointByOld(contract?.change, tick));
    pankouBuyprice = Utils.double2Str(Utils.dealPointByOld(contract?.buyPrice, tick));
    pankouBuynum = "${contract?.level2List?[0].volume?.toInt() ?? 0}";
    pankouSalenum = "${contract?.level2List?[20].volume?.toInt() ?? 0}";
    pankouSaleprice = Utils.double2Str(Utils.dealPointByOld(contract?.salePrice, tick));
    pankouOpenprice = Utils.double2Str(Utils.dealPointByOld(contract?.openPrice, tick));
    pankouVolume = "${contract?.volume?.toInt() ?? 0}";
    pankouHighprice = Utils.double2Str(Utils.dealPointByOld(contract?.highPrice, tick));
    pankouPosition = "${contract?.position?.toInt() ?? 0}";
    pankouLowprice = Utils.double2Str(Utils.dealPointByOld(contract?.lowPrice, tick));
    pankouPoor = "${((contract?.position ?? 0) - (contract?.prePosition ?? 0))}";
    pankouAvr = Utils.double2Str(Utils.dealPointByOld(contract?.averPrice, tick));
    pankouClear = Utils.double2Str(Utils.dealPointByOld(contract?.settlePrice, tick));
    pankouPresettle = Utils.double2Str(Utils.dealPointByOld(contract?.preSettlePrice, tick));
    pankouPreclose = Utils.double2Str(Utils.dealPointByOld(contract?.prePrice, tick));
    pankouUpLimit = Utils.double2Str(Utils.dealPointByOld(contract?.limitPrice, tick));
    pankouExterDisk = "${contract?.out_vouume ?? 0}";
    pankouDownLimit = Utils.double2Str(Utils.dealPointByOld(contract?.stopPrice, tick));
    pankouInnerDisk = "${contract?.in_vouume ?? 0}";

    if ((contract?.change ?? 0) > 0) {
      pankouColor = HexColor("#ff204a");
    } else if ((contract?.change ?? 0) < 0) {
      pankouColor = HexColor("#3aff20");
    } else {
      pankouColor = HexColor("#ffffff");
    }
  }

  /// 计算最新数据
  void calcNewData(OHLCEntity data, KPeriod period, double preSettlePrice) {
    if (mOHLCData.isEmpty) return;
    List<OHLCEntity> mOHLCList = [];
    mOHLCList.addAll(mOHLCData);
    double newPrice = 0.0;
    String? newestTime;
    bool isWithin = false;

    String standardTime = "${mOHLCList[0].date} ${mOHLCList[0].time}";
    String? oldDate = mOHLCList[mOHLCList.length - 1].date;
    String? oldTime = mOHLCList[mOHLCList.length - 1].time;

    newPrice = data.close?.toDouble() ?? 0;
    if (ChartPainter.mTradeTimes.isNotEmpty && period.cusType == 1 && period.kpFlag == KPFlag.Day) {
      newestTime = "${data.date} ${ChartPainter.mTradeTimes[ChartPainter.mTradeTimes.length - 1].End}";
    } else if (period.cusType == 2) {
      newestTime = "${data.date} ${data.time}";
    } else {
      newestTime = "${data.date} ${data.time}";
    }

    ChartPainter.lastClose = preSettlePrice;
    if (newPrice == 0 || newestTime == "") {
      return;
    }

    String preTime = "$oldDate $oldTime";
    DateTime? dateOld;
    DateTime? dateNew;
    try {
      dateOld = Common.ymdhmsFormat.parse(preTime);
      dateNew = Common.ymdhmsFormat.parse(newestTime);
    } catch (e) {
      logger.e("时间处理异常：$e");
    }

    if (dateNew!.isBefore(dateOld!) && period.cusType == 1) {
      logger.e("异常旧时间：$oldDate $oldTime");
      logger.e("异常新时间：$newestTime");
      return;
    }

    isWithin = KUtils.isInPeriod(dateOld, dateNew, period);
    // logger.i("是否在同一 周期：$isWithin");
    if (isDrawTime) {
      if (isWithin == true) {
        //在一个周期，更新集合最后一根数据的收盘价,均价
        mOHLCList[mOHLCList.length - 1].close = newPrice; //更新收盘价
        mOHLCList[mOHLCList.length - 1].open = data.open;
        mOHLCList[mOHLCList.length - 1].high = data.high;
        mOHLCList[mOHLCList.length - 1].low = data.low;
        mOHLCList[mOHLCList.length - 1].amount = data.amount;
        mOHLCList[mOHLCList.length - 1].volume = data.volume;
        double averagePrice = (newPrice + (mOHLCList[mOHLCList.length - 2].average ?? 0) * (mOHLCList.length - 1)) / mOHLCList.length;
        mOHLCList[mOHLCList.length - 1].average = averagePrice; //更新均价
      } else {
        //最新数据和数组最后一根数据不在一个周期直接给集合添加一根最新数据
        String newstDate = newestTime; //处理最新时间;
        newstDate = Utils.getUnifiedTime(newstDate, period, standardTime);
        if (period.cusType == 2) {
          newstDate = Utils.calcCustomNextDate(preTime, newestTime, period, ChartPainter.mTradeTimes);
        }
        String newDate1 = newstDate.substring(0, 10);
        String newTime1 = newstDate.substring(11, 19);
        double averagePrice = (newPrice + (mOHLCList[mOHLCList.length - 1].average ?? 0) * mOHLCList.length) / (mOHLCList.length + 1);
        if (newTime1 != oldTime) {
          OHLCEntity ohlc = OHLCEntity(
            average: averagePrice,
            close: data.close,
            high: data.high,
            open: data.open,
            low: data.low,
            volume: data.volume,
            amount: data.amount,
            date: newDate1,
            time: newTime1,
          );
          mOHLCList.add(ohlc);
        }
      }
      //更新分时数据
      setTimeData(mOHLCList);
    } else {
      if (isWithin == true) {
        //在一个周期，更新集合最后一根数据的收盘价,最高价，最低价
        if (period.cusType == 1) {
          mOHLCList[mOHLCList.length - 1].close = newPrice; //更新收盘价
          mOHLCList[mOHLCList.length - 1].open = data.open;
          mOHLCList[mOHLCList.length - 1].high = data.high;
          mOHLCList[mOHLCList.length - 1].low = data.low;
          mOHLCList[mOHLCList.length - 1].amount = data.amount;
          mOHLCList[mOHLCList.length - 1].volume = data.volume;
        } else {
          OHLCEntity ohlc = mOHLCList[mOHLCList.length - 1];
          mOHLCList[mOHLCList.length - 1].close = newPrice; //更新收盘价
          mOHLCList[mOHLCList.length - 1].open = ohlc.open;
          mOHLCList[mOHLCList.length - 1].high = max(data.high ?? 0, ohlc.high ?? 0);
          mOHLCList[mOHLCList.length - 1].low = min(data.low ?? 0, ohlc.low ?? 0);

          if (ohlc.customStamp != data.timeStamp) {
            mOHLCList[mOHLCList.length - 1].customStamp = data.timeStamp;
            mOHLCList[mOHLCList.length - 1].customVolume = data.volume;
            mOHLCList[mOHLCList.length - 1].customAmount = data.amount;
            mOHLCList[mOHLCList.length - 1].amount = (mOHLCList[mOHLCList.length - 1].amount ?? 0) + (data.amount ?? 0);
            mOHLCList[mOHLCList.length - 1].volume = (mOHLCList[mOHLCList.length - 1].volume ?? 0) + (data.volume ?? 0);
          } else {
            num amount = (data.amount ?? 0) - (mOHLCList[mOHLCList.length - 1].customAmount ?? 0);
            int volume = (data.volume ?? 0) - (mOHLCList[mOHLCList.length - 1].customVolume ?? 0);
            mOHLCList[mOHLCList.length - 1].amount = (mOHLCList[mOHLCList.length - 1].amount ?? 0) + amount;
            mOHLCList[mOHLCList.length - 1].volume = (mOHLCList[mOHLCList.length - 1].volume ?? 0) + volume;
            mOHLCList[mOHLCList.length - 1].customVolume = data.volume;
            mOHLCList[mOHLCList.length - 1].customAmount = data.amount;
          }
        }
      } else {
        //不在一个周期，判断是否需要修正数据

        int count = KUtils.getCount(preTime, newestTime, period); //计算缺少的历史数据数量

        if (count > 1) {
          //需要修正数据
          if (mHaveCorrected) {
            isAllowAdd = false;
            correctKline(count + 4);
            mHaveCorrected = false;

            String newstDate = newestTime; //处理最新时间;
            newstDate = Utils.getUnifiedTime(newstDate, period, standardTime);
            if (period.cusType == 2) {
              newstDate = Utils.calcCustomNextDate(preTime, newestTime, period, ChartPainter.mTradeTimes);
            }
            String newDate1 = newstDate.substring(0, 10);
            String newTime1 = newstDate.substring(11, 19);
            OHLCEntity ohlc = OHLCEntity(
              close: data.close,
              high: data.high,
              open: data.open,
              low: data.low,
              volume: data.volume,
              amount: data.amount,
              date: newDate1,
              time: newTime1,
              customStamp: data.timeStamp,
              customAmount: data.amount,
              customVolume: data.volume,
            );
            mOHLCList.add(ohlc);
            setOHLCData(mOHLCList);
          }
          return;
        } else {
          mHaveCorrected = true;
          String newstDate = newestTime; //处理最新时间;
          newstDate = Utils.getUnifiedTime(newstDate, period, standardTime);
          if (period.cusType == 2) {
            newstDate = Utils.calcCustomNextDate(preTime, newestTime, period, ChartPainter.mTradeTimes);
          }
          String newDate1 = newstDate.substring(0, 10);
          String newTime1 = newstDate.substring(11, 19);
          OHLCEntity ohlc = OHLCEntity(
            close: data.close,
            high: data.high,
            open: data.open,
            low: data.low,
            volume: data.volume,
            amount: data.amount,
            date: newDate1,
            time: newTime1,
            customStamp: data.timeStamp,
            customAmount: data.amount,
            customVolume: data.volume,
          );
          mOHLCList.add(ohlc);
        }
      }
      setOHLCData(mOHLCList);
    }
  }

  ///订阅\取消行情
  void subscriptionQuote(bool sub) {
    if (contract != null) {
      List<String> json = Utils.getSubJson(0, 1, [contract!]);
      EventBusUtil.getInstance().fire(SubEvent(json, sub ? Operation.SendSub : Operation.UnSendSub));
    }
  }

  ///订阅\取消成交明细
  void subscriptionFill(bool sub) {
    String? excd = contract?.exCode;
    String? type = String.fromCharCode(contract?.comType ?? 0);
    String? comCode = contract?.subComCode;
    String? conCode = contract?.subConCode;
    String key = "$excd.$type.$comCode.$conCode";
    EventBusUtil.getInstance().fire(SubEvent([key], sub ? Operation.SendSubFillData : Operation.SendUnSubFillData));
  }

  ///订阅\取消K线
  void subscriptionKlineData(bool sub) {
    if (contract != null) {
      List<String> json = Utils.getSubJson(0, 1, [contract!]);
      EventBusUtil.getInstance().fire(SubEvent(json, sub ? Operation.RecvSubKlineData : Operation.RecvUnSubKlineData, period: kPeriod.period));
    }
  }

  void initContract() {
    var con = widget.contract;
    Contract? mContract = MarketUtils.getVariety(con.exCode, con.code, con.comType);
    contract = mContract;
    if (con.isMain == true) {
      contract?.isMain = true;
    }
    refreshData();
  }

  void listener() {
    ///行情变化
    EventBusUtil.getInstance().on<QuoteEvent>().listen((event) {
      Contract con = event.con;
      if (con.exCode == contract?.exCode && con.code == contract?.code && con.comType == contract?.comType) {
        contract = con;
        refreshData();

        if (ChartPainter.mFsTimes.isNotEmpty) {
          String tradeStart = ChartPainter.mFsTimes[0].split(" ")[1].substring(0, 5);
          String qutoTime = Utils.timeMillisToTime((contract?.timeStamps ?? 0).toInt()).substring(0, 5);
          if (tradeStart == qutoTime && isDrawTime) {
            ChartPainter.setTradeTimes(contract?.trTime);
            requestAllData();
          }
        }
      }
    });

    ///盘口数据
    EventBusUtil.getInstance().on<QuoteFilledData>().listen((event) {
      FillData fill = event.quoteFilledData;
      if (contract?.exCode == fill.exchangeNo &&
          contract?.subConCode == fill.contractNo &&
          contract?.subComCode == fill.commodityNo &&
          contract?.comType == ascii.encode(fill.commodityType).single) {
        quoteFilledData.add(fill);
        quoteFilledData.sort(
          (lhs, rhs) {
            if (Utils.MilsStringToTimestamp(lhs.updateTime) == Utils.MilsStringToTimestamp(rhs.updateTime)) {
              return 0;
            } else {
              return Utils.MilsStringToTimestamp(lhs.updateTime) < Utils.MilsStringToTimestamp(rhs.updateTime) ? 1 : -1;
            }
          },
        );
        if (quoteFilledData.length > 100) {
          quoteFilledData.removeAt(quoteFilledData.length - 1);
        }
      }
    });

    ///k线数据
    EventBusUtil.getInstance().on<CorrKlineEvent>().listen((event) {
      List<String>? keyArr = event.key?.split(",");
      String? excd = keyArr?[0];
      String? type = keyArr?[1];
      String? comCode = keyArr?[2];
      String? conCode = keyArr?[3];

      if (excd == contract?.exCode &&
          comCode == contract?.subComCode &&
          conCode == contract?.subConCode &&
          type == String.fromCharCode(contract?.comType ?? 0)) {
        OHLCEntity ohlc = OHLCEntity(
          open: event.data?.open,
          high: event.data?.high,
          close: event.data?.close,
          low: event.data?.low,
          volume: event.data?.volume?.toInt(),
        );
        if (event.data?.amount != 0) {
          ohlc.amount = event.data?.amount;
        }
        ohlc.date = Utils.timeMillisToDate(event.data?.uxTime?.toInt() ?? 0);
        ohlc.time = Utils.timeMillisToTime(event.data?.uxTime?.toInt() ?? 0);
        if (isAllowAdd && !isSwithing) {
          calcNewData(ohlc, kPeriod, contract?.preSettlePrice?.toDouble() ?? 0);
        }
      }
    });

    ///周期变化
    EventBusUtil.getInstance().on<SwitchPeriod>().listen((event) {
      if (kPeriod == event.kPeriod) return;
      subscriptionKlineData(false);
      kPeriod = event.kPeriod;
      mOHLCData.clear();
      SWITHING_TIME = true;
      if (event.kPeriod.period == KTime.FS) {
        isDrawTime = true;
      } else {
        isDrawTime = false;
      }
      requestAllData();
      subscriptionKlineData(true);
    });
  }

  @override
  void initState() {
    initContract();
    ChartPainter.setTradeTimes(contract?.trTime);
    listener();
    getKPeriod();
    subscriptionQuote(true);
    subscriptionFill(true);
    super.initState();
  }

  @override
  void dispose() {
    subscriptionKlineData(false);
    subscriptionQuote(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = ChartPainter(
      isDrawTime: isDrawTime,
      isDrawCrossLine: isDrawCrossLine,
      mKPeriod: kPeriod,
      mOHLCData: mOHLCData,
      SWITHING_TIME: SWITHING_TIME,
      SWITHING_CODE: SWITHING_CODE,
      SWITHING_INDEX: SWITHING_INDEX,
      SWITHING_PERIOD: SWITHING_PERIOD,
      ADD_DATA: ADD_DATA,
      type_changed: type_changed,
      mDataStartIndext: mDataStartIndext,
      mShowDataNum: mShowDataNum,
      mChartWidth: mChartWidth,
      mCandleWidth: mCandleWidth,
      MIN_CANDLE_NUM: MIN_CANDLE_NUM,
      mMaxPrice: mMaxPrice,
      mMinPrice: mMinPrice,
      currentX: currentX,
      currentY: currentY,
      isDrawBollinger: isDrawBollinger,
      isDrawCost: isDrawCost,
      isDrawCost1: isDrawCost1,
      isDrawCost2: isDrawCost2,
      isDrawCost3: isDrawCost3,
      isDrawCost4: isDrawCost4,
      isDrawCost5: isDrawCost5,
      isDrawFall: isDrawFall,
      mPreSize: mPreSize,
      mMACDData: mMACDData,
      mRSIData: mRSIData,
      mBollingerData: mBollingerData,
      mCostData: mCostData,
      mFallData: mFallData,
      mAlligatorData: mAlligatorData,
      mKDJData: mKDJData,
      mWRData: mWRData,
      mCCIData: mCCIData,
      mBIASData: mBIASData,
      mPSYData: mPSYData,
      mVolData: mVolData,
      mVRData: mVRData,
      isDrawTimeDown: isDrawTimeDown,
    );
    appTheme = context.watch<AppTheme>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Expanded(child: kChart(painter)), dataWidget()],
    );
  }

  Widget kChart(painter) {
    final contextController = FlyoutController();
    final contextAttachKey = GlobalKey();
    final paint = SubChartPainter(
      mDataStartIndext: mDataStartIndext,
      mShowDataNum: mShowDataNum,
      mCandleWidth: mCandleWidth,
      isDrawVOL: canDrawVOL,
      isDrawVR: canDrawVR,
      isDrawMACD: canDrawMACD,
      isDrawKDJ: canDrawKDJ,
      isDrawRSI: canDrawRSI,
      isDrawCCI: canDrawCCI,
      isDrawBIAS: canDrawBIAS,
      isDrawOBV: canDrawOBV,
      isDrawWR: canDrawWR,
      isDrawDMA: canDrawDMA,
      isDrawPSY: canDrawPSY,
      isDrawMACDBANG: canDrawMACDBANG,
      mOHLCData: mOHLCData,
      mMACDData: mMACDData,
      mRSIData: mRSIData,
      mKDJData: mKDJData,
      mWRData: mWRData,
      mCCIData: mCCIData,
      mBIASData: mBIASData,
      mPSYData: mPSYData,
      mVolData: mVolData,
      mVRData: mVRData,
    );
    final paint1 = SubChartPainter(
      mDataStartIndext: mDataStartIndext,
      mShowDataNum: mShowDataNum,
      mCandleWidth: mCandleWidth,
      isDrawVOL: canDrawVOL1,
      isDrawVR: canDrawVR1,
      isDrawMACD: canDrawMACD1,
      isDrawKDJ: canDrawKDJ1,
      isDrawRSI: canDrawRSI1,
      isDrawCCI: canDrawCCI1,
      isDrawBIAS: canDrawBIAS1,
      isDrawOBV: canDrawOBV1,
      isDrawWR: canDrawWR1,
      isDrawDMA: canDrawDMA1,
      isDrawPSY: canDrawPSY1,
      isDrawMACDBANG: canDrawMACDBANG1,
      mOHLCData: mOHLCData,
      mMACDData: mMACDData,
      mRSIData: mRSIData,
      mKDJData: mKDJData,
      mWRData: mWRData,
      mCCIData: mCCIData,
      mBIASData: mBIASData,
      mPSYData: mPSYData,
      mVolData: mVolData,
      mVRData: mVRData,
    );
    final paint2 = SubChartPainter(
      mDataStartIndext: mDataStartIndext,
      mShowDataNum: mShowDataNum,
      mCandleWidth: mCandleWidth,
      isDrawVOL: canDrawVOL2,
      isDrawVR: canDrawVR2,
      isDrawMACD: canDrawMACD2,
      isDrawKDJ: canDrawKDJ2,
      isDrawRSI: canDrawRSI2,
      isDrawCCI: canDrawCCI2,
      isDrawBIAS: canDrawBIAS2,
      isDrawOBV: canDrawOBV2,
      isDrawWR: canDrawWR2,
      isDrawDMA: canDrawDMA2,
      isDrawPSY: canDrawPSY2,
      isDrawMACDBANG: canDrawMACDBANG2,
      mOHLCData: mOHLCData,
      mMACDData: mMACDData,
      mRSIData: mRSIData,
      mKDJData: mKDJData,
      mWRData: mWRData,
      mCCIData: mCCIData,
      mBIASData: mBIASData,
      mPSYData: mPSYData,
      mVolData: mVolData,
      mVRData: mVRData,
    );
    final paint3 = SubChartPainter(
      mDataStartIndext: mDataStartIndext,
      mShowDataNum: mShowDataNum,
      mCandleWidth: mCandleWidth,
      isDrawVOL: canDrawVOL3,
      isDrawVR: canDrawVR3,
      isDrawMACD: canDrawMACD3,
      isDrawKDJ: canDrawKDJ3,
      isDrawRSI: canDrawRSI3,
      isDrawCCI: canDrawCCI3,
      isDrawBIAS: canDrawBIAS3,
      isDrawOBV: canDrawOBV3,
      isDrawWR: canDrawWR3,
      isDrawDMA: canDrawDMA3,
      isDrawPSY: canDrawPSY3,
      isDrawMACDBANG: canDrawMACDBANG3,
      mOHLCData: mOHLCData,
      mMACDData: mMACDData,
      mRSIData: mRSIData,
      mKDJData: mKDJData,
      mWRData: mWRData,
      mCCIData: mCCIData,
      mBIASData: mBIASData,
      mPSYData: mPSYData,
      mVolData: mVolData,
      mVRData: mVRData,
    );

    return Column(
      children: [
        Row(
          children: [
            Text(
              "${contract?.name ?? ""}(${contract?.code ?? ""})<${kPeriod.name}线>",
              style: TextStyle(fontSize: 16, color: appTheme.color),
            ),
          ],
        ),
        Expanded(
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                if (isDrawTime) {
                  return;
                }
                if (mOHLCData.isEmpty) {
                  return;
                }
                mStartX = pointerSignal.position.dx;
                mStartY = pointerSignal.position.dy;

                int showNum = mShowDataNum;

                if (pointerSignal.scrollDelta.direction > 0) {
                  mCandleWidth = mCandleWidth * 0.8;
                } else if (pointerSignal.scrollDelta.direction < 0) {
                  mCandleWidth = mCandleWidth * 1.2;
                }
                if (mCandleWidth > mChartWidth / MIN_CANDLE_NUM * 0.8) {
                  mCandleWidth = mChartWidth / MIN_CANDLE_NUM * 0.8;
                }
                if (mCandleWidth < 2) {
                  mCandleWidth = 2;
                }
                mShowDataNum = (mChartWidth ~/ mCandleWidth) - 1; //减1是为了最后一根不超出右边界线
                if (mShowDataNum > mOHLCData.length) {
                  mShowDataNum = MIN_CANDLE_NUM > mOHLCData.length ? MIN_CANDLE_NUM : mOHLCData.length;
                }
                if (mDataStartIndext + showNum == mOHLCData.length) {
                  //如果缩放之前，K线在最新数据，保持最右边数据不动（显示到最新数据）
                  mDataStartIndext = mOHLCData.length - mShowDataNum;
                }
                setCurrentData();
                if (mounted) setState(() {});
              }
            },
            onPointerHover: (e) {
              if (isDrawCrossLine) {
                currentX = e.localPosition.dx;
                currentY = e.localPosition.dy;
                if (mounted) setState(() {});
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTapDown: (event) {
                isDrawCrossLine = !isDrawCrossLine;
              },
              onHorizontalDragStart: (event) {
                if (isDrawTime) {
                  return;
                }
                mDownIndext = mDataStartIndext;
                mStartX = event.localPosition.dx;
              },
              onHorizontalDragUpdate: (event) {
                if (mOHLCData.isEmpty || isDrawTime) {
                  return;
                }
                if (!isDrawCrossLine) {
                  double horizontalSpacing = event.localPosition.dx - mStartX;
                  if (horizontalSpacing < 0) {
                    mDataStartIndext = (mDownIndext + (horizontalSpacing / mCandleWidth).abs()).toInt();
                  } else if (horizontalSpacing > 0) {
                    mDataStartIndext = (mDownIndext - horizontalSpacing / mCandleWidth).toInt();
                    if (mDataStartIndext < 0) {
                      mDataStartIndext = 0;
                    }
                  }

                  if (mOHLCData.length - mPreSize != 0) {
                    //检查数据集合在没有刷新阶段是否有增加，增加的应该去除掉
                    int number = mOHLCData.length - mPreSize;
                    for (int i = 1; i <= number; i++) {
                      mOHLCData.removeAt(mOHLCData.length - 1);
                    }
                  }

                  int maxPeriod = ChartPainter.getMaxPeriod(isDrawCost, isDrawBollinger, isDrawFall);

                  if (maxPeriod > mDataStartIndext && isNeedAddData && isReachLast == false) {
                    //到达指定位置控制数据的向前加载
                    isNeedAddData = false;
                    mStartDate = "${mOHLCData[0].date} ${mOHLCData[0].time}";
                    requestMoreKline(int.parse(Utils.getLongTime(mStartDate)));
                  }
                  if (isNeedAddData) {
                    setCurrentData();
                  }
                } else {
                  currentX = event.localPosition.dx;
                  currentY = event.localPosition.dy;
                }
                if (mounted) setState(() {});
              },
              onSecondaryTapUp: (d) {
                // logger.i(d.localPosition);
                final targetContext = contextAttachKey.currentContext;
                if (targetContext == null) return;
                final box = targetContext.findRenderObject() as RenderBox;
                final position = box.localToGlobal(
                  d.localPosition,
                  ancestor: Navigator.of(context).context.findRenderObject(),
                );
                contextController.showFlyout(
                  barrierColor: Colors.black.withOpacity(0.1),
                  position: position,
                  builder: (context) {
                    return MenuFlyout(items: [
                      MenuFlyoutItem(
                        text: const Text('下单'),
                        onPressed: Flyout.of(context).close,
                      ),
                      MenuFlyoutItem(
                        text: const Text('加入自选'),
                        onPressed: Flyout.of(context).close,
                      ),
                      MenuFlyoutItem(
                        text: const Text('移除自选'),
                        onPressed: Flyout.of(context).close,
                      ),
                      MenuFlyoutSubItem(
                        text: const Text('切换画面'),
                        items: (context) => [
                          MenuFlyoutItem(
                            text: const Text('报价页面'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('分时'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('成交报表'),
                            onPressed: Flyout.of(context).close,
                          ),
                        ],
                      ),
                      MenuFlyoutSubItem(
                        text: const Text('技术指标'),
                        items: (context) => [
                          MenuFlyoutSubItem(
                            text: const Text('趋势分析指标（主图）'),
                            items: (_) => [
                              MenuFlyoutItem(
                                text: const Text('MA组合'),
                                trailing: const Text('移动平均线组合'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('BOLL'),
                                trailing: const Text('布林通道线'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('PUBU'),
                                trailing: const Text('瀑布线'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('DSX'),
                                trailing: const Text('全形量化'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('DDHX'),
                                trailing: const Text('高低点划线'),
                                onPressed: Flyout.of(context).close,
                              ),
                            ],
                          ),
                          MenuFlyoutSubItem(
                            text: const Text('量仓分析'),
                            items: (_) => [
                              MenuFlyoutItem(
                                text: const Text('VOL'),
                                trailing: const Text('成交量'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('VR'),
                                trailing: const Text('VR容量比率'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('OBV'),
                                trailing: const Text('能量潮'),
                                onPressed: Flyout.of(context).close,
                              )
                            ],
                          ),
                          MenuFlyoutSubItem(
                            text: const Text('摆动分析'),
                            items: (_) => [
                              MenuFlyoutItem(
                                text: const Text('MACD'),
                                trailing: const Text('平滑移动平均线'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('KDJ'),
                                trailing: const Text('随机指标'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('RSI'),
                                trailing: const Text('相对强弱指标'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('CCI'),
                                trailing: const Text('顺势指标'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('BIAS'),
                                trailing: const Text('乖离率'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('WR'),
                                trailing: const Text('威廉指标'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('DMA'),
                                trailing: const Text('平均线差'),
                                onPressed: Flyout.of(context).close,
                              ),
                              MenuFlyoutItem(
                                text: const Text('PSY'),
                                trailing: const Text('心理线'),
                                onPressed: Flyout.of(context).close,
                              ),
                            ],
                          ),
                        ],
                      ),
                      MenuFlyoutItem(
                        text: const Text('指标修改'),
                        onPressed: Flyout.of(context).close,
                      ),
                      MenuFlyoutItem(
                        text: const Text('显示盘口数据'),
                        onPressed: Flyout.of(context).close,
                      ),
                      MenuFlyoutItem(
                        text: const Text('增加副图'),
                        onPressed: () {
                          Flyout.of(context).close;
                          if (showSubDraw && showSubDraw1 && showSubDraw2 && showSubDraw3 || subCount >= 4) {
                            InfoBarUtils.showWarningBar("分析区域不能超过5个");
                          } else if (!showSubDraw) {
                            showSubDraw = true;
                            subCount++;
                          } else if (!showSubDraw1) {
                            showSubDraw1 = true;
                            subCount++;
                          } else if (!showSubDraw2) {
                            showSubDraw2 = true;
                            subCount++;
                          } else if (!showSubDraw3) {
                            showSubDraw3 = true;
                            subCount++;
                          }
                          if (mounted) setState(() {});
                        },
                      ),
                      MenuFlyoutItem(
                        text: const Text('删除副图'),
                        onPressed: () {
                          Flyout.of(context).close;
                          if (subCount <= 0 || !showSubDraw && !showSubDraw1 && !showSubDraw2 && !showSubDraw3) {
                            return;
                          } else if (showSubDraw3) {
                            showSubDraw3 = false;
                            subCount--;
                          } else if (showSubDraw2) {
                            showSubDraw2 = false;
                            subCount--;
                          } else if (showSubDraw1) {
                            showSubDraw1 = false;
                            subCount--;
                          } else if (showSubDraw) {
                            showSubDraw = false;
                            subCount--;
                          }
                          if (mounted) setState(() {});
                        },
                      ),
                      MenuFlyoutSubItem(
                        text: const Text('周期切换'),
                        items: (context) => [
                          MenuFlyoutItem(
                            text: const Text('日线'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('周线'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('月线'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('年线'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('任意天'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('1分钟'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('3分钟'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('5分钟'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('10分钟'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('15分钟'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('30分钟'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('60分钟'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('120分钟'),
                            onPressed: Flyout.of(context).close,
                          ),
                          MenuFlyoutItem(
                            text: const Text('任意分'),
                            onPressed: Flyout.of(context).close,
                          ),
                        ],
                      ),
                      MenuFlyoutItem(
                        text: const Text('画线下单'),
                        onPressed: Flyout.of(context).close,
                      ),
                      MenuFlyoutItem(
                        text: const Text('最大化'),
                        onPressed: Flyout.of(context).close,
                      ),
                      MenuFlyoutItem(
                        text: const Text('横向分页'),
                        onPressed: Flyout.of(context).close,
                      ),
                      MenuFlyoutItem(
                        text: const Text('纵向分页'),
                        onPressed: Flyout.of(context).close,
                      ),
                      MenuFlyoutItem(
                        text: const Text('关闭窗口'),
                        onPressed: Flyout.of(context).close,
                      ),
                    ]);
                  },
                );
              },
              child: FlyoutTarget(
                key: contextAttachKey,
                controller: contextController,
                child: Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.red))),
                  child: isDrawTime
                      ? RepaintBoundary(
                          child: CustomPaint(
                          size: Size(1.sw, 1.sh),
                          painter: painter,
                        ))
                      : Column(
                          children: [
                            Expanded(
                              flex: 6 - subCount,
                              child: Stack(
                                children: [
                                  IgnorePointer(
                                    child: RepaintBoundary(child: CustomPaint(size: Size(1.sw, 1.sh), painter: painter)),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: Port.defult_margin_top, left: leftMarginSpace),
                                      width: Port.defult_icon_width,
                                      child: FlyoutTarget(
                                        controller: mainMenuController,
                                        child: IconButton(
                                          icon: const Icon(FluentIcons.query_list),
                                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                                          onPressed: () {
                                            mainMenuController.showFlyout(
                                              autoModeConfiguration: FlyoutAutoConfiguration(
                                                preferredMode: FlyoutPlacementMode.topLeft,
                                              ),
                                              builder: (context) {
                                                return MenuFlyout(items: [
                                                  MenuFlyoutItem(
                                                    text: const Text('MA组合'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      switchIndex("MA");
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('BOLL'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      switchIndex("BOLL");
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('PUBU'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      switchIndex("PBX");
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('DSX全形量化'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('DDHX高低点划线'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                ]);
                                              },
                                            );
                                          },
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            if (showSubDraw)
                              Expanded(
                                child: Stack(
                                  children: [
                                    IgnorePointer(
                                      child: CustomPaint(
                                        key: UniqueKey(),
                                        size: Size(1.sw, 1.sh),
                                        painter: paint,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: Port.defult_margin_top, left: leftMarginSpace),
                                      width: Port.defult_icon_width,
                                      child: FlyoutTarget(
                                        controller: menuController,
                                        child: IconButton(
                                          icon: const Icon(FluentIcons.query_list),
                                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                                          onPressed: () {
                                            logger.i("onPressed");
                                            menuController.showFlyout(
                                              autoModeConfiguration: FlyoutAutoConfiguration(
                                                preferredMode: FlyoutPlacementMode.topLeft,
                                              ),
                                              builder: (context) {
                                                return MenuFlyout(items: [
                                                  MenuFlyoutItem(
                                                    text: const Text('VOL'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD = false;
                                                      canDrawVR = false;
                                                      canDrawVOL = true;
                                                      canDrawKDJ = false;
                                                      canDrawRSI = false;
                                                      canDrawCCI = false;
                                                      canDrawBIAS = false;
                                                      canDrawWR = false;
                                                      canDrawPSY = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('VR'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD = false;
                                                      canDrawVR = true;
                                                      canDrawVOL = false;
                                                      canDrawKDJ = false;
                                                      canDrawRSI = false;
                                                      canDrawCCI = false;
                                                      canDrawBIAS = false;
                                                      canDrawWR = false;
                                                      canDrawPSY = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('MACD'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD = true;
                                                      canDrawVR = false;
                                                      canDrawVOL = false;
                                                      canDrawKDJ = false;
                                                      canDrawRSI = false;
                                                      canDrawCCI = false;
                                                      canDrawBIAS = false;
                                                      canDrawWR = false;
                                                      canDrawPSY = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('KDJ'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD = false;
                                                      canDrawVR = false;
                                                      canDrawVOL = false;
                                                      canDrawKDJ = true;
                                                      canDrawRSI = false;
                                                      canDrawCCI = false;
                                                      canDrawBIAS = false;
                                                      canDrawWR = false;
                                                      canDrawPSY = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('RSI'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD = false;
                                                      canDrawVR = false;
                                                      canDrawVOL = false;
                                                      canDrawKDJ = false;
                                                      canDrawRSI = true;
                                                      canDrawCCI = false;
                                                      canDrawBIAS = false;
                                                      canDrawWR = false;
                                                      canDrawPSY = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('CCI'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD = false;
                                                      canDrawVR = false;
                                                      canDrawVOL = false;
                                                      canDrawKDJ = false;
                                                      canDrawRSI = false;
                                                      canDrawCCI = true;
                                                      canDrawBIAS = false;
                                                      canDrawWR = false;
                                                      canDrawPSY = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('BIAS'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD = false;
                                                        canDrawVR = false;
                                                        canDrawVOL = false;
                                                        canDrawKDJ = false;
                                                        canDrawRSI = false;
                                                        canDrawCCI = false;
                                                        canDrawBIAS = true;
                                                        canDrawWR = false;
                                                        canDrawPSY = false;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('OBV'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('WR'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD = false;
                                                        canDrawVR = false;
                                                        canDrawVOL = false;
                                                        canDrawKDJ = false;
                                                        canDrawRSI = false;
                                                        canDrawCCI = false;
                                                        canDrawBIAS = false;
                                                        canDrawWR = true;
                                                        canDrawPSY = false;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('DMA'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('PSY'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD = false;
                                                        canDrawVR = false;
                                                        canDrawVOL = false;
                                                        canDrawKDJ = false;
                                                        canDrawRSI = false;
                                                        canDrawCCI = false;
                                                        canDrawBIAS = false;
                                                        canDrawWR = false;
                                                        canDrawPSY = true;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('MACD能量棒'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                ]);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            if (showSubDraw1)
                              Expanded(
                                child: Stack(
                                  children: [
                                    IgnorePointer(
                                      child: CustomPaint(
                                        key: UniqueKey(),
                                        size: Size(1.sw, 1.sh),
                                        painter: paint1,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: Port.defult_margin_top, left: leftMarginSpace),
                                      width: Port.defult_icon_width,
                                      child: FlyoutTarget(
                                        controller: menuController1,
                                        child: IconButton(
                                          icon: const Icon(FluentIcons.query_list),
                                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                                          onPressed: () {
                                            logger.i("onPressed");
                                            menuController1.showFlyout(
                                              autoModeConfiguration: FlyoutAutoConfiguration(
                                                preferredMode: FlyoutPlacementMode.topLeft,
                                              ),
                                              builder: (context) {
                                                return MenuFlyout(items: [
                                                  MenuFlyoutItem(
                                                    text: const Text('VOL'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD1 = false;
                                                      canDrawVR1 = false;
                                                      canDrawVOL1 = true;
                                                      canDrawKDJ1 = false;
                                                      canDrawRSI1 = false;
                                                      canDrawCCI1 = false;
                                                      canDrawBIAS1 = false;
                                                      canDrawWR1 = false;
                                                      canDrawPSY1 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('VR'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD1 = false;
                                                      canDrawVR1 = true;
                                                      canDrawVOL1 = false;
                                                      canDrawKDJ1 = false;
                                                      canDrawRSI1 = false;
                                                      canDrawCCI1 = false;
                                                      canDrawBIAS1 = false;
                                                      canDrawWR1 = false;
                                                      canDrawPSY1 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('MACD'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD1 = true;
                                                      canDrawVR1 = false;
                                                      canDrawVOL1 = false;
                                                      canDrawKDJ1 = false;
                                                      canDrawRSI1 = false;
                                                      canDrawCCI1 = false;
                                                      canDrawBIAS1 = false;
                                                      canDrawWR1 = false;
                                                      canDrawPSY1 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('KDJ'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD1 = false;
                                                      canDrawVR1 = false;
                                                      canDrawVOL1 = false;
                                                      canDrawKDJ1 = true;
                                                      canDrawRSI1 = false;
                                                      canDrawCCI1 = false;
                                                      canDrawBIAS1 = false;
                                                      canDrawWR1 = false;
                                                      canDrawPSY1 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('RSI'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD1 = false;
                                                      canDrawVR1 = false;
                                                      canDrawVOL1 = false;
                                                      canDrawKDJ1 = false;
                                                      canDrawRSI1 = true;
                                                      canDrawCCI1 = false;
                                                      canDrawBIAS1 = false;
                                                      canDrawWR1 = false;
                                                      canDrawPSY1 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('CCI'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD1 = false;
                                                      canDrawVR1 = false;
                                                      canDrawVOL1 = false;
                                                      canDrawKDJ1 = false;
                                                      canDrawRSI1 = false;
                                                      canDrawCCI1 = true;
                                                      canDrawBIAS1 = false;
                                                      canDrawWR1 = false;
                                                      canDrawPSY1 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('BIAS'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD1 = false;
                                                        canDrawVR1 = false;
                                                        canDrawVOL1 = false;
                                                        canDrawKDJ1 = false;
                                                        canDrawRSI1 = false;
                                                        canDrawCCI1 = false;
                                                        canDrawBIAS1 = true;
                                                        canDrawWR1 = false;
                                                        canDrawPSY1 = false;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('OBV'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('WR'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD1 = false;
                                                        canDrawVR1 = false;
                                                        canDrawVOL1 = false;
                                                        canDrawKDJ1 = false;
                                                        canDrawRSI1 = false;
                                                        canDrawCCI1 = false;
                                                        canDrawBIAS1 = false;
                                                        canDrawWR1 = true;
                                                        canDrawPSY1 = false;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('DMA'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('PSY'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD1 = false;
                                                        canDrawVR1 = false;
                                                        canDrawVOL1 = false;
                                                        canDrawKDJ1 = false;
                                                        canDrawRSI1 = false;
                                                        canDrawCCI1 = false;
                                                        canDrawBIAS1 = false;
                                                        canDrawWR1 = false;
                                                        canDrawPSY1 = true;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('MACD能量棒'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                ]);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            if (showSubDraw2)
                              Expanded(
                                child: Stack(
                                  children: [
                                    IgnorePointer(
                                      child: CustomPaint(
                                        key: UniqueKey(),
                                        size: Size(1.sw, 1.sh),
                                        painter: paint2,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: Port.defult_margin_top, left: leftMarginSpace),
                                      width: Port.defult_icon_width,
                                      child: FlyoutTarget(
                                        controller: menuController2,
                                        child: IconButton(
                                          icon: const Icon(FluentIcons.query_list),
                                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                                          onPressed: () {
                                            menuController2.showFlyout(
                                              autoModeConfiguration: FlyoutAutoConfiguration(
                                                preferredMode: FlyoutPlacementMode.topLeft,
                                              ),
                                              builder: (context) {
                                                logger.i("onPressed");
                                                return MenuFlyout(items: [
                                                  MenuFlyoutItem(
                                                    text: const Text('VOL'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD2 = false;
                                                      canDrawVR2 = false;
                                                      canDrawVOL2 = true;
                                                      canDrawKDJ2 = false;
                                                      canDrawRSI2 = false;
                                                      canDrawCCI2 = false;
                                                      canDrawBIAS2 = false;
                                                      canDrawWR2 = false;
                                                      canDrawPSY2 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('VR'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD2 = false;
                                                      canDrawVR2 = true;
                                                      canDrawVOL2 = false;
                                                      canDrawKDJ2 = false;
                                                      canDrawRSI2 = false;
                                                      canDrawCCI2 = false;
                                                      canDrawBIAS2 = false;
                                                      canDrawWR2 = false;
                                                      canDrawPSY2 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('MACD'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD2 = true;
                                                      canDrawVR2 = false;
                                                      canDrawVOL2 = false;
                                                      canDrawKDJ2 = false;
                                                      canDrawRSI2 = false;
                                                      canDrawCCI2 = false;
                                                      canDrawBIAS2 = false;
                                                      canDrawWR2 = false;
                                                      canDrawPSY2 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('KDJ'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD2 = false;
                                                      canDrawVR2 = false;
                                                      canDrawVOL2 = false;
                                                      canDrawKDJ2 = true;
                                                      canDrawRSI2 = false;
                                                      canDrawCCI2 = false;
                                                      canDrawBIAS2 = false;
                                                      canDrawWR2 = false;
                                                      canDrawPSY2 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('RSI'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD2 = false;
                                                      canDrawVR2 = false;
                                                      canDrawVOL2 = false;
                                                      canDrawKDJ2 = false;
                                                      canDrawRSI2 = true;
                                                      canDrawCCI2 = false;
                                                      canDrawBIAS2 = false;
                                                      canDrawWR2 = false;
                                                      canDrawPSY2 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('CCI'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD2 = false;
                                                      canDrawVR2 = false;
                                                      canDrawVOL2 = false;
                                                      canDrawKDJ2 = false;
                                                      canDrawRSI2 = false;
                                                      canDrawCCI2 = true;
                                                      canDrawBIAS2 = false;
                                                      canDrawWR2 = false;
                                                      canDrawPSY2 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('BIAS'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD2 = false;
                                                        canDrawVR2 = false;
                                                        canDrawVOL2 = false;
                                                        canDrawKDJ2 = false;
                                                        canDrawRSI2 = false;
                                                        canDrawCCI2 = false;
                                                        canDrawBIAS2 = true;
                                                        canDrawWR2 = false;
                                                        canDrawPSY2 = false;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('OBV'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('WR'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD2 = false;
                                                        canDrawVR2 = false;
                                                        canDrawVOL2 = false;
                                                        canDrawKDJ2 = false;
                                                        canDrawRSI2 = false;
                                                        canDrawCCI2 = false;
                                                        canDrawBIAS2 = false;
                                                        canDrawWR2 = true;
                                                        canDrawPSY2 = false;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('DMA'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('PSY'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD2 = false;
                                                        canDrawVR2 = false;
                                                        canDrawVOL2 = false;
                                                        canDrawKDJ2 = false;
                                                        canDrawRSI2 = false;
                                                        canDrawCCI2 = false;
                                                        canDrawBIAS2 = false;
                                                        canDrawWR2 = false;
                                                        canDrawPSY2 = true;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('MACD能量棒'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                ]);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            if (showSubDraw3)
                              Expanded(
                                child: Stack(
                                  children: [
                                    IgnorePointer(
                                      child: CustomPaint(
                                        key: UniqueKey(),
                                        size: Size(1.sw, 1.sh),
                                        painter: paint3,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: Port.defult_margin_top, left: leftMarginSpace),
                                      width: Port.defult_icon_width,
                                      child: FlyoutTarget(
                                        controller: menuController3,
                                        child: IconButton(
                                          icon: const Icon(FluentIcons.query_list),
                                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                                          onPressed: () {
                                            logger.i("onPressed");
                                            menuController3.showFlyout(
                                              autoModeConfiguration: FlyoutAutoConfiguration(
                                                preferredMode: FlyoutPlacementMode.topLeft,
                                              ),
                                              builder: (context) {
                                                return MenuFlyout(items: [
                                                  MenuFlyoutItem(
                                                    text: const Text('VOL'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD3 = false;
                                                      canDrawVR3 = false;
                                                      canDrawVOL3 = true;
                                                      canDrawKDJ3 = false;
                                                      canDrawRSI3 = false;
                                                      canDrawCCI3 = false;
                                                      canDrawBIAS3 = false;
                                                      canDrawWR3 = false;
                                                      canDrawPSY3 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('VR'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD3 = false;
                                                      canDrawVR3 = true;
                                                      canDrawVOL3 = false;
                                                      canDrawKDJ3 = false;
                                                      canDrawRSI3 = false;
                                                      canDrawCCI3 = false;
                                                      canDrawBIAS3 = false;
                                                      canDrawWR3 = false;
                                                      canDrawPSY3 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('MACD'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD3 = true;
                                                      canDrawVR3 = false;
                                                      canDrawVOL3 = false;
                                                      canDrawKDJ3 = false;
                                                      canDrawRSI3 = false;
                                                      canDrawCCI3 = false;
                                                      canDrawBIAS3 = false;
                                                      canDrawWR3 = false;
                                                      canDrawPSY3 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('KDJ'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD3 = false;
                                                      canDrawVR3 = false;
                                                      canDrawVOL3 = false;
                                                      canDrawKDJ3 = true;
                                                      canDrawRSI3 = false;
                                                      canDrawCCI3 = false;
                                                      canDrawBIAS3 = false;
                                                      canDrawWR3 = false;
                                                      canDrawPSY3 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('RSI'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD3 = false;
                                                      canDrawVR3 = false;
                                                      canDrawVOL3 = false;
                                                      canDrawKDJ3 = false;
                                                      canDrawRSI3 = true;
                                                      canDrawCCI3 = false;
                                                      canDrawBIAS3 = false;
                                                      canDrawWR3 = false;
                                                      canDrawPSY3 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                    text: const Text('CCI'),
                                                    onPressed: () {
                                                      Flyout.of(context).close;
                                                      canDrawMACD3 = false;
                                                      canDrawVR3 = false;
                                                      canDrawVOL3 = false;
                                                      canDrawKDJ3 = false;
                                                      canDrawRSI3 = false;
                                                      canDrawCCI3 = true;
                                                      canDrawBIAS3 = false;
                                                      canDrawWR3 = false;
                                                      canDrawPSY3 = false;
                                                      if (mounted) setState(() {});
                                                    },
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('BIAS'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD3 = false;
                                                        canDrawVR3 = false;
                                                        canDrawVOL3 = false;
                                                        canDrawKDJ3 = false;
                                                        canDrawRSI3 = false;
                                                        canDrawCCI3 = false;
                                                        canDrawBIAS3 = true;
                                                        canDrawWR3 = false;
                                                        canDrawPSY3 = false;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('OBV'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('WR'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD3 = false;
                                                        canDrawVR3 = false;
                                                        canDrawVOL3 = false;
                                                        canDrawKDJ3 = false;
                                                        canDrawRSI3 = false;
                                                        canDrawCCI3 = false;
                                                        canDrawBIAS3 = false;
                                                        canDrawWR3 = true;
                                                        canDrawPSY3 = false;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('DMA'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                  MenuFlyoutItem(
                                                      text: const Text('PSY'),
                                                      onPressed: () {
                                                        Flyout.of(context).close;
                                                        canDrawMACD3 = false;
                                                        canDrawVR3 = false;
                                                        canDrawVOL3 = false;
                                                        canDrawKDJ3 = false;
                                                        canDrawRSI3 = false;
                                                        canDrawCCI3 = false;
                                                        canDrawBIAS3 = false;
                                                        canDrawWR3 = false;
                                                        canDrawPSY3 = true;
                                                        if (mounted) setState(() {});
                                                      }),
                                                  MenuFlyoutItem(
                                                    text: const Text('MACD能量棒'),
                                                    onPressed: Flyout.of(context).close,
                                                  ),
                                                ]);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget dataWidget() {
    return SizedBox(
      width: 288,
      height: 1.sh,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
        child: ListView(
          children: [
            Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.red)),
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "${contract?.name ?? ""}(${contract?.code ?? ""})",
                            style: TextStyle(fontSize: 24, color: Colors.yellow),
                          )),
                    ),
                    FlyoutTarget(
                      controller: priceController,
                      child: IconButton(
                        icon: const Icon(FluentIcons.query_list),
                        style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                        onPressed: () {
                          priceController.showFlyout(
                            autoModeConfiguration: FlyoutAutoConfiguration(
                              preferredMode: FlyoutPlacementMode.topLeft,
                            ),
                            builder: (context) {
                              return MenuFlyout(items: [
                                MenuFlyoutItem(
                                  text: const Text('一档报价'),
                                  onPressed: () {
                                    Flyout.of(context).close;
                                    level = 1;
                                    if (mounted) setState(() {});
                                  },
                                ),
                                MenuFlyoutItem(
                                  text: const Text('五档报价'),
                                  onPressed: () {
                                    Flyout.of(context).close;
                                    level = 5;
                                    if (mounted) setState(() {});
                                  },
                                ),
                                MenuFlyoutItem(
                                  text: const Text('十档报价'),
                                  onPressed: () {
                                    Flyout.of(context).close;
                                    level = 10;
                                    if (mounted) setState(() {});
                                  },
                                ),
                              ]);
                            },
                          );
                        },
                      ),
                    )
                  ],
                )),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (level == 10) priceItem("卖十", "0.00", "0"),
                  if (level == 10) priceItem("卖九", "0.00", "0"),
                  if (level == 10) priceItem("卖八", "0.00", "0"),
                  if (level == 10) priceItem("卖七", "0.00", "0"),
                  if (level == 10) priceItem("卖六", "0.00", "0"),
                  if (level == 10 || level == 5) priceItem("卖五", "0.00", "0"),
                  if (level == 10 || level == 5) priceItem("卖四", "0.00", "0"),
                  if (level == 10 || level == 5) priceItem("卖三", "0.00", "0"),
                  if (level == 10 || level == 5) priceItem("卖二", "0.00", "0"),
                  priceItem("卖一", "74.21", "13", fontSize: 22),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                priceItem("买一", "74.21", "13", fontSize: 22),
                if (level == 10 || level == 5) priceItem("买二", "0.00", "0"),
                if (level == 10 || level == 5) priceItem("买三", "0.00", "0"),
                if (level == 10 || level == 5) priceItem("买四", "0.00", "0"),
                if (level == 10 || level == 5) priceItem("买五", "0.00", "0"),
                if (level == 10) priceItem("买六", "0.00", "0"),
                if (level == 10) priceItem("买七", "0.00", "0"),
                if (level == 10) priceItem("买八", "0.00", "0"),
                if (level == 10) priceItem("买九", "0.00", "0"),
                if (level == 10) priceItem("买十", "0.00", "0"),
              ]),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        dataItem("最新", thin: true),
                        dataItem("涨跌", thin: true),
                        dataItem("幅度", thin: true),
                        dataItem("总手", thin: true),
                        dataItem("现手", thin: true),
                        dataItem("持仓", thin: true),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        dataItem("74.19", color: Colors.red),
                        dataItem("0.50", color: Colors.red),
                        dataItem("0.68%", color: Colors.red),
                        dataItem("4096", color: Colors.red),
                        dataItem("-", color: Colors.yellow),
                        dataItem("85763", color: Colors.yellow),
                      ],
                    ),
                  ),
                  DashedLine(
                    axis: Axis.vertical,
                    dashColor: Colors.red,
                    children: [
                      Container(
                        width: 1,
                        height: 180,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          dataItem("均价", thin: true),
                          dataItem("昨结", thin: true),
                          dataItem("开盘", thin: true),
                          dataItem("最高", thin: true),
                          dataItem("最低", thin: true),
                          dataItem("仓差", thin: true),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      dataItem(null, color: Colors.yellow),
                      dataItem("73.69", color: Colors.red),
                      dataItem("73.04", color: Colors.red),
                      dataItem("73.16", color: Colors.red),
                      dataItem("73.33", color: Colors.red),
                      dataItem(null, color: Colors.yellow),
                    ],
                  ),
                ],
              ),
            ),
            Container(
                height: 0.6.sh,
                decoration: BoxDecoration(border: Border.all(color: Colors.red)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 2, child: detailItem("时间", fontSize: 16)),
                        Expanded(flex: 2, child: detailItem("价位", fontSize: 16)),
                        Expanded(flex: 1, child: detailItem("现手", fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: quoteFilledData.length,
                            itemBuilder: (BuildContext context, int index) {
                              String timeStr = quoteFilledData[index].updateTime.split(" ")[1];
                              return Row(
                                children: [
                                  Expanded(flex: 2, child: detailItem(timeStr.substring(0, timeStr.indexOf(".")))),
                                  Expanded(flex: 2, child: detailItem(quoteFilledData[index].lastPrice.toString(), up: 1)),
                                  Expanded(
                                      flex: 1, child: detailItem(quoteFilledData[index].volume.toInt().toString(), up: quoteFilledData[index].orderForward)),
                                ],
                              );
                            })),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget dataItem(String? title, {Color? color, bool? thin}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(title ?? "-", style: TextStyle(fontWeight: thin == true ? FontWeight.w100 : FontWeight.bold, fontSize: 16, color: color ?? appTheme.color)),
    );
  }

  Widget priceItem(String title, String price, String count, {double? fontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Expanded(child: Text(title, style: TextStyle(fontSize: fontSize ?? 14, color: appTheme.color))),
        Expanded(child: Text(price, textAlign: TextAlign.right, style: TextStyle(fontSize: fontSize ?? 16, color: Colors.red))),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: Text(count, style: TextStyle(fontSize: fontSize ?? 16, color: Colors.yellow))),
      ]),
    );
  }

  Widget detailItem(String? text, {int? up, double? fontSize}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        text ?? "--",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: fontSize ?? 15,
            color: up == 1
                ? Colors.red
                : up == 2
                    ? Colors.green
                    : appTheme.color),
      ),
    );
  }
}
