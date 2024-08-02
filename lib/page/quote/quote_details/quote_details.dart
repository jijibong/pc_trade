import 'dart:convert';
import 'dart:math' hide log;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../../../config/common.dart';
import '../../../model/k/OHLCEntity.dart';
import '../../../model/k/k_chart_data/ATREntity.dart';
import '../../../model/k/k_chart_data/AlligatorEntity.dart';
import '../../../model/k/k_chart_data/BIASEntity.dart';
import '../../../model/k/k_chart_data/BollingerEntity.dart';
import '../../../model/k/k_chart_data/CCIEntity.dart';
import '../../../model/k/k_chart_data/CostLineEntity.dart';
import '../../../model/k/k_chart_data/DKXEntity.dart';
import '../../../model/k/k_chart_data/DMIEntity.dart';
import '../../../model/k/k_chart_data/FallLineEntity.dart';
import '../../../model/k/k_chart_data/GUBIEntity.dart';
import '../../../model/k/k_chart_data/KDJEntity.dart';
import '../../../model/k/k_chart_data/KIndex.dart';
import '../../../model/k/k_chart_data/MACDEntity.dart';
import '../../../model/k/k_chart_data/MIKEEntity.dart';
import '../../../model/k/k_chart_data/PSYEntity.dart';
import '../../../model/k/k_chart_data/RSIEntity.dart';
import '../../../model/k/k_chart_data/TRIXEntity.dart';
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

  List<KIndex> mKIndexMainList = [];
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
  String chartVerCode = "--";
  String chartVerName = "--";
  Color commonColor = Colors.white;

  List indexMain = ["MA", "BOLL", "PBX", "VOL", "VR", "MACD", "RSI", "KDJ", "CCI"];
  List tabArry = ["持仓", "可撤", "委托", "成交"];
  List orderTypeArry = ["限价", "市价", "止损", "限价止损"];
  String mSelSubIndex = "MACD";
  String mSelMainIndex = "BOLL";
  String mSelMidIndex = "VOL";
  KPeriod kPeriod = KPeriod();
  List<KPeriod> mKPeriodList = [];
  List<OHLCEntity> mOHLCData = [];
  String selectType = "持仓";

  bool doDeal = false;
  bool isSetIndex = true;
  bool isDrawTime = true;
  bool isDrawMacd = true;
  bool isDrawRsi = false;
  bool isDrawDmi = false;
  bool isDrawBollinger = true;
  bool isDrawDKX = false;
  bool isDrawCost = false;
  bool isDrawCost1 = true;
  bool isDrawCost2 = true;
  bool isDrawCost3 = false;
  bool isDrawCost4 = false;
  bool isDrawCost5 = true;
  bool isDrawFall = false;
  bool isDrawAlligator = false;
  bool isDrawKDJ = false;
  bool isDrawWR = false;
  bool isDrawCCI = false;
  bool isDrawATR = false;
  bool isDrawBIAS = false;
  bool isDrawPSY = false;
  bool isDrawTRIX = false;
  bool isDrawMIKE = false;
  bool isDrawGUBI = false;
  bool isDrawVolume = true;
  bool isDrawVR = false;
  bool isDrawCrossLine = false;

  bool isTriggerLong = false;
  int downTime = 0;
  int mPointerCount = 0;
  /**当前横坐标*/
  double currentX = -1;
  /**当前纵坐标*/
  double currentY = -1;
  bool isNeedAddData = true;

  /** MACD数据 */
  MACDEntity? mMACDData;
  /** DMI数据 */
  DMIEntity? mDMIData;
  /** RSI数据 */
  RSIEntity? mRSIData;
  /** 布林带数据 */
  BollingerEntity? mBollingerData;
  /** 多空线数据 */
  DKXEntity? mDKXData;
  /** 均线数据 */
  CostLineEntity? mCostData;
  /** 瀑布线数据 */
  FallLineEntity? mFallData;
  /** 鳄鱼线数据 */
  AlligatorEntity? mAlligatorData;
  /** KDJ线数据 */
  KDJEntity? mKDJData;
  /** WR线数据 */
  WREntity? mWRData;
  /** CCI线数据 */
  CCIEntity? mCCIData;
  /** ATR线数据 */
  ATREntity? mATRData;
  /** BIAS线数据 */
  BIASEntity? mBIASData;
  /** PSY线数据 */
  PSYEntity? mPSYData;
  /** TRIX线数据 */
  TRIXEntity? mTRIXData;
  /** MIKE线数据 */
  MIKEEntity? mMIKEData;
  /** MIKE线数据 */
  GUBIEntity? mGUBIData;
  /** 成交量线数据 */
  VolEntity? mVolData;
  /** VR线数据 */
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
  num mDownSpace = 0;

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

  Color chartTradeFloatProfitColor = Colors.white;

  getKPeriod() async {
    List<KPeriod> plist = await KUtils.getKPeriodList(true, false);
    mKPeriodList.addAll(plist);
    kPeriod = mKPeriodList.first;
    subscriptionKlineData(true);
    mKIndexMainList.addAll(indexMain.map((e) => KIndex(name: e)).toList());

    mKIndexMainList.insert(3, KIndex(itemType: 1));
    mKIndexMainList.insert(6, KIndex(itemType: 1));
    if (Port.isDrawCost) {
      mKIndexMainList[0].isSelected = true;
    }
    if (Port.isDrawBollinger) {
      mKIndexMainList[1].isSelected = true;
    }
    if (Port.isDrawFall) {
      mKIndexMainList[2].isSelected = true;
    }
    if (Port.isDrawVol) {
      mKIndexMainList[4].isSelected = true;
    }
    if (Port.isDrawVR) {
      mKIndexMainList[5].isSelected = true;
    }
    if (Port.isDrawMacd) {
      mKIndexMainList[7].isSelected = true;
    }
    if (Port.isDrawRsi) {
      mKIndexMainList[8].isSelected = true;
    }
    if (Port.isDrawKDJ) {
      mKIndexMainList[9].isSelected = true;
    }
    if (Port.isDrawCCI) {
      mKIndexMainList[10].isSelected = true;
    }
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
      num right = Port.drawFlag == 0 ? BaseKChartPainter.mCursorWidth : ChartPainter.getStringWidth("00000000", TextPainter());
      double chartWidth = ChartPainter.kChartViewWidth - 2 * BaseKChartPainter.MARGINLEFT - right;
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

    if (isDrawAlligator) {
      if (mAlligatorData == null) {
        mAlligatorData = AlligatorEntity();
        mAlligatorData?.initData(mOHLCData, ChartPainter.JawPeriod, ChartPainter.TeethPeriod, ChartPainter.LipsPeriod);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mAlligatorData?.initData(mOHLCData, ChartPainter.JawPeriod, ChartPainter.TeethPeriod, ChartPainter.LipsPeriod);
        } else {
          mAlligatorData?.addData(mOHLCData, ChartPainter.JawPeriod, ChartPainter.TeethPeriod, ChartPainter.LipsPeriod, count);
        }
      }
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

    //初始化顾比均线数据
    if (isDrawGUBI) {
      if (mGUBIData == null) {
        mGUBIData = GUBIEntity();
        mGUBIData?.initData(
            OHLCData,
            ChartPainter.GUBIPeriod1,
            ChartPainter.GUBIPeriod2,
            ChartPainter.GUBIPeriod3,
            ChartPainter.GUBIPeriod4,
            ChartPainter.GUBIPeriod5,
            ChartPainter.GUBIPeriod6,
            ChartPainter.GUBIPeriod7,
            ChartPainter.GUBIPeriod8,
            ChartPainter.GUBIPeriod9,
            ChartPainter.GUBIPeriod10,
            ChartPainter.GUBIPeriod11,
            ChartPainter.GUBIPeriod12,
            GUBI_indexType,
            2);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mGUBIData?.initData(
              OHLCData,
              ChartPainter.GUBIPeriod1,
              ChartPainter.GUBIPeriod2,
              ChartPainter.GUBIPeriod3,
              ChartPainter.GUBIPeriod4,
              ChartPainter.GUBIPeriod5,
              ChartPainter.GUBIPeriod6,
              ChartPainter.GUBIPeriod7,
              ChartPainter.GUBIPeriod8,
              ChartPainter.GUBIPeriod9,
              ChartPainter.GUBIPeriod10,
              ChartPainter.GUBIPeriod11,
              ChartPainter.GUBIPeriod12,
              GUBI_indexType,
              2);
        } else {
          mGUBIData?.addData(
              OHLCData,
              ChartPainter.GUBIPeriod1,
              ChartPainter.GUBIPeriod2,
              ChartPainter.GUBIPeriod3,
              ChartPainter.GUBIPeriod4,
              ChartPainter.GUBIPeriod5,
              ChartPainter.GUBIPeriod6,
              ChartPainter.GUBIPeriod7,
              ChartPainter.GUBIPeriod8,
              ChartPainter.GUBIPeriod9,
              ChartPainter.GUBIPeriod10,
              ChartPainter.GUBIPeriod11,
              ChartPainter.GUBIPeriod12,
              GUBI_indexType,
              2,
              count);
        }
      }
    }

    //初始化多空线数据
    if (isDrawDKX) {
      if (mDKXData == null) {
        mDKXData = DKXEntity();
        mDKXData?.initData(mOHLCData, ChartPainter.DKXPeriod, ChartPainter.MADKXPeriod);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mDKXData?.initData(mOHLCData, ChartPainter.DKXPeriod, ChartPainter.MADKXPeriod);
        } else {
          mDKXData?.addData(mOHLCData, ChartPainter.DKXPeriod, ChartPainter.MADKXPeriod, count);
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

    //初始化布林线数据
    if (isDrawMIKE) {
      if (mMIKEData == null) {
        mMIKEData = MIKEEntity();
        mMIKEData?.initData(OHLCData, ChartPainter.MikePeriod, 2);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mMIKEData?.initData(OHLCData, ChartPainter.MikePeriod, 2);
        } else {
          mMIKEData?.addData(OHLCData, ChartPainter.MikePeriod, 2, count);
        }
      }
    }

    //初始化MACD数据
    if (isDrawMacd) {
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
    if (isDrawRsi) {
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

    //初始化DMI数据
    if (isDrawDmi) {
      if (mDMIData == null) {
        mDMIData = DMIEntity();
        mDMIData?.initData(mOHLCData, ChartPainter.dmiPeriod);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mDMIData?.initData(mOHLCData, ChartPainter.dmiPeriod);
        } else {
          mDMIData?.addData(mOHLCData, ChartPainter.dmiPeriod, count);
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

    //初始化ATR数据
    if (isDrawATR) {
      if (mATRData == null) {
        mATRData = ATREntity();
        mATRData?.initData(OHLCData, ChartPainter.ATRPeriod, 2);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mATRData?.initData(OHLCData, ChartPainter.ATRPeriod, 2);
        } else {
          mATRData?.addData(OHLCData, ChartPainter.ATRPeriod, 2, count);
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
        mPSYData = new PSYEntity();
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

    //初始化TRIX数据
    if (isDrawTRIX) {
      if (mTRIXData == null) {
        mTRIXData = TRIXEntity();
        mTRIXData?.initData(OHLCData, ChartPainter.TRIXPeriod, ChartPainter.TRIXMAPeriod, 2);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mTRIXData?.initData(OHLCData, ChartPainter.TRIXPeriod, ChartPainter.TRIXMAPeriod, 2);
        } else {
          mTRIXData?.addData(OHLCData, ChartPainter.TRIXPeriod, ChartPainter.TRIXMAPeriod, 2, count);
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
    if (isDrawVolume) {
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

    // logger.i("mShowDataNum:$mShowDataNum  length:${mOHLCData.length}   mDataStartIndext:$mDataStartIndext  MIN_CANDLE_NUM:$MIN_CANDLE_NUM");
    if (mShowDataNum > mOHLCData.length) {
      mShowDataNum = mOHLCData.length;
    }
    if (MIN_CANDLE_NUM > mOHLCData.length) {
      mShowDataNum = MIN_CANDLE_NUM;
    }

    // logger.f("mShowDataNum:$mShowDataNum  length:${mOHLCData.length}   mDataStartIndext:$mDataStartIndext  MIN_CANDLE_NUM:$MIN_CANDLE_NUM");
    if (mShowDataNum > mOHLCData.length) {
      mDataStartIndext = 0;
    } else if (mShowDataNum + mDataStartIndext > mOHLCData.length) {
      mDataStartIndext = mOHLCData.length - mShowDataNum;
    } else if (isSetIndex) {
      //初始化蜡烛线开始位置
      mDataStartIndext = mOHLCData.length - mShowDataNum;
      isSetIndex = false;
    }
    // logger.w("mShowDataNum:$mShowDataNum  length:${mOHLCData.length}   mDataStartIndext:$mDataStartIndext");

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

    //计算鳄鱼线的最大最小值
    if (mAlligatorData != null && isDrawAlligator && mAlligatorData!.JawList.length != 0) {
      //下巴
      for (int i = mDataStartIndext; i < mShowDataNum + mDataStartIndext + ChartPainter.JawSpeed; i++) {
        if (i >= ChartPainter.JawPeriod - 1 + ChartPainter.JawSpeed) {
          int loction = i - (ChartPainter.JawPeriod - 1 + ChartPainter.JawSpeed);
          if (loction < mAlligatorData!.JawList.length) {
            mMinPrice = mMinPrice < mAlligatorData!.JawList[loction] ? mMinPrice : mAlligatorData!.JawList[loction];
            mMaxPrice = mMaxPrice > mAlligatorData!.JawList[loction] ? mMaxPrice : mAlligatorData!.JawList[loction];
          }
        }
      }

      //牙齿
      for (int i = mDataStartIndext; i < mShowDataNum + mDataStartIndext + ChartPainter.TeethSpeed; i++) {
        if (i >= ChartPainter.TeethPeriod - 1 + ChartPainter.TeethSpeed) {
          int loction = i - (ChartPainter.TeethPeriod - 1 + ChartPainter.TeethSpeed);
          if (loction < mAlligatorData!.TeethList.length) {
            mMinPrice = mMinPrice < mAlligatorData!.TeethList[loction] ? mMinPrice : mAlligatorData!.TeethList[loction];
            mMaxPrice = mMaxPrice > mAlligatorData!.TeethList[loction] ? mMaxPrice : mAlligatorData!.TeethList[loction];
          }
        }
      }

      //嘴唇
      for (int i = mDataStartIndext; i < mShowDataNum + mDataStartIndext + ChartPainter.LipsSpeed; i++) {
        if (i >= ChartPainter.LipsPeriod - 1 + ChartPainter.LipsSpeed) {
          int loction = i - (ChartPainter.LipsPeriod - 1 + ChartPainter.LipsSpeed);
          if (loction < mAlligatorData!.LipsList.length) {
            mMinPrice = mMinPrice < mAlligatorData!.LipsList[loction] ? mMinPrice : mAlligatorData!.LipsList[loction];
            mMaxPrice = mMaxPrice > mAlligatorData!.LipsList[loction] ? mMaxPrice : mAlligatorData!.LipsList[loction];
          }
        }
      }
    }

    //计算有多空线线时的最大 最小值
    if (mDKXData != null && isDrawDKX && mDKXData!.DKX.isNotEmpty) {
      for (int i = mDataStartIndext; i < mOHLCData.length && i < mShowDataNum + mDataStartIndext; i++) {
        if (i >= ChartPainter.DKXPeriod - 1) {
          int loction = i - (ChartPainter.DKXPeriod - 1);
          if (loction < mDKXData!.DKX.length) {
            mMinPrice = mMinPrice < mDKXData!.DKX[loction] ? mMinPrice : mDKXData!.DKX[loction];
            mMaxPrice = mMaxPrice > mDKXData!.DKX[loction] ? mMaxPrice : mDKXData!.DKX[loction];
          }
        }

        if (i >= ChartPainter.DKXPeriod + ChartPainter.MADKXPeriod - 2) {
          int loction = i - (ChartPainter.DKXPeriod + ChartPainter.MADKXPeriod - 2);
          if (loction < mDKXData!.MADKX.length) {
            mMinPrice = mMinPrice < mDKXData!.MADKX[loction] ? mMinPrice : mDKXData!.MADKX[loction];
            mMaxPrice = mMaxPrice > mDKXData!.MADKX[loction] ? mMaxPrice : mDKXData!.MADKX[loction];
          }
        }
      }
    }

    //计算有MIKE线时的最大 最小值
    if (mMIKEData != null && isDrawMIKE && mMIKEData!.WR.isNotEmpty) {
      for (int i = mDataStartIndext; i < mOHLCData.length && i < mShowDataNum + mDataStartIndext; i++) {
        if (i >= ChartPainter.MikePeriod - 1) {
          int loction = i - (ChartPainter.MikePeriod - 1);
          if (loction < mMIKEData!.WR.length &&
              loction < mMIKEData!.MR.length &&
              loction < mMIKEData!.SR.length &&
              loction < mMIKEData!.WS.length &&
              loction < mMIKEData!.MS.length &&
              loction < mMIKEData!.SS.length) {
            mMinPrice = mMinPrice < mMIKEData!.WR[loction] ? mMinPrice : mMIKEData!.WR[loction];
            mMaxPrice = mMaxPrice > mMIKEData!.WR[loction] ? mMaxPrice : mMIKEData!.WR[loction];
            mMinPrice = mMinPrice < mMIKEData!.MR[loction] ? mMinPrice : mMIKEData!.MR[loction];
            mMaxPrice = mMaxPrice > mMIKEData!.MR[loction] ? mMaxPrice : mMIKEData!.MR[loction];
            mMinPrice = mMinPrice < mMIKEData!.SR[loction] ? mMinPrice : mMIKEData!.SR[loction];
            mMaxPrice = mMaxPrice > mMIKEData!.SR[loction] ? mMaxPrice : mMIKEData!.SR[loction];
            mMinPrice = mMinPrice < mMIKEData!.WS[loction] ? mMinPrice : mMIKEData!.WS[loction];
            mMaxPrice = mMaxPrice > mMIKEData!.WS[loction] ? mMaxPrice : mMIKEData!.WS[loction];
            mMinPrice = mMinPrice < mMIKEData!.MS[loction] ? mMinPrice : mMIKEData!.MS[loction];
            mMaxPrice = mMaxPrice > mMIKEData!.MS[loction] ? mMaxPrice : mMIKEData!.MS[loction];
            mMinPrice = mMinPrice < mMIKEData!.SS[loction] ? mMinPrice : mMIKEData!.SS[loction];
            mMaxPrice = mMaxPrice > mMIKEData!.SS[loction] ? mMaxPrice : mMIKEData!.SS[loction];
          }
        }
      }
    }

    //计算有均线时的最大 最小值
    if (mCostData != null && isDrawCost && mCostData!.CostOne.length != 0) {
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

    // 计算有顾比均线时的最大 最小值
    if (mGUBIData != null && isDrawGUBI && mGUBIData!.Cost1.isNotEmpty) {
      for (int i = mDataStartIndext; i < mOHLCData.length && i < mShowDataNum + mDataStartIndext; i++) {
        if (i >= ChartPainter.GUBIPeriod1 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod1 - 1);
          if (loction < mGUBIData!.Cost1.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost1[loction] ? mMinPrice : mGUBIData!.Cost1[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost1[loction] ? mMaxPrice : mGUBIData!.Cost1[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod2 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod2 - 1);
          if (loction < mGUBIData!.Cost2.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost2[loction] ? mMinPrice : mGUBIData!.Cost2[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost2[loction] ? mMaxPrice : mGUBIData!.Cost2[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod3 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod3 - 1);
          if (loction < mGUBIData!.Cost3.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost3[loction] ? mMinPrice : mGUBIData!.Cost3[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost3[loction] ? mMaxPrice : mGUBIData!.Cost3[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod4 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod4 - 1);
          if (loction < mGUBIData!.Cost4.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost4[loction] ? mMinPrice : mGUBIData!.Cost4[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost4[loction] ? mMaxPrice : mGUBIData!.Cost4[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod5 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod5 - 1);
          if (loction < mGUBIData!.Cost5.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost5[loction] ? mMinPrice : mGUBIData!.Cost5[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost5[loction] ? mMaxPrice : mGUBIData!.Cost5[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod6 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod6 - 1);
          if (loction < mGUBIData!.Cost6.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost6[loction] ? mMinPrice : mGUBIData!.Cost6[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost6[loction] ? mMaxPrice : mGUBIData!.Cost6[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod7 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod7 - 1);
          if (loction < mGUBIData!.Cost7.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost7[loction] ? mMinPrice : mGUBIData!.Cost7[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost7[loction] ? mMaxPrice : mGUBIData!.Cost7[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod8 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod8 - 1);
          if (loction < mGUBIData!.Cost8.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost8[loction] ? mMinPrice : mGUBIData!.Cost8[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost8[loction] ? mMaxPrice : mGUBIData!.Cost8[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod9 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod9 - 1);
          if (loction < mGUBIData!.Cost9.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost9[loction] ? mMinPrice : mGUBIData!.Cost9[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost9[loction] ? mMaxPrice : mGUBIData!.Cost9[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod10 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod10 - 1);
          if (loction < mGUBIData!.Cost10.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost10[loction] ? mMinPrice : mGUBIData!.Cost10[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost10[loction] ? mMaxPrice : mGUBIData!.Cost10[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod11 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod11 - 1);
          if (loction < mGUBIData!.Cost11.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost11[loction] ? mMinPrice : mGUBIData!.Cost11[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost11[loction] ? mMaxPrice : mGUBIData!.Cost11[loction];
          }
        }

        if (i >= ChartPainter.GUBIPeriod12 - 1) {
          int loction = i - (ChartPainter.GUBIPeriod12 - 1);
          if (loction < mGUBIData!.Cost12.length) {
            mMinPrice = mMinPrice < mGUBIData!.Cost12[loction] ? mMinPrice : mGUBIData!.Cost12[loction];
            mMaxPrice = mMaxPrice > mGUBIData!.Cost12[loction] ? mMaxPrice : mGUBIData!.Cost12[loction];
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
    if (mMACDData != null && isDrawMacd) {
      mMACDData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.macdSPeriod, ChartPainter.macdLPeriod, ChartPainter.macdPeriod);
    }

    if (mKDJData != null && isDrawKDJ) {
      mKDJData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.KDJPeriod);
    }

    if (mCCIData != null && isDrawCCI) {
      mCCIData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.CCIPeriod);
    }

    if (mATRData != null && isDrawATR) {
      mATRData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.ATRPeriod);
    }

    if (mBIASData != null && isDrawBIAS) {
      mBIASData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.BIAS1Period, ChartPainter.BIAS2Period, ChartPainter.BIAS3Period);
    }

    if (mTRIXData != null && isDrawTRIX) {
      mTRIXData?.calclatePrice(mDataStartIndext, mShowDataNum, ChartPainter.TRIXPeriod, ChartPainter.TRIXMAPeriod);
    }

    if (mVolData != null && isDrawVolume) {
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
        isDrawDKX = false;
        isDrawAlligator = false;
        isDrawFall = false;
        isDrawMIKE = false;
        isDrawGUBI = false;
        break;
      case "BOLL": //BOLL
        isDrawCost = false;
        isDrawCost1 = Port.isDrawCost1;
        isDrawCost2 = Port.isDrawCost2;
        isDrawCost3 = Port.isDrawCost3;
        isDrawCost4 = Port.isDrawCost4;
        isDrawCost5 = Port.isDrawCost5;
        isDrawBollinger = true;
        isDrawDKX = false;
        isDrawAlligator = false;
        isDrawFall = false;
        isDrawMIKE = false;
        isDrawGUBI = false;
        break;
      case "PBX": //FALL
        isDrawCost = false;
        isDrawCost1 = Port.isDrawCost1;
        isDrawCost2 = Port.isDrawCost2;
        isDrawCost3 = Port.isDrawCost3;
        isDrawCost4 = Port.isDrawCost4;
        isDrawCost5 = Port.isDrawCost5;
        isDrawBollinger = false;
        isDrawDKX = false;
        isDrawAlligator = false;
        isDrawFall = true;
        isDrawMIKE = false;
        isDrawGUBI = false;
        break;
      case "VOL": //volume
        isDrawVolume = true;
        isDrawVR = false;
        break;
      case "VR": //vR
        isDrawVolume = false;
        isDrawVR = true;
        break;
      case "MACD": //MACD
        isDrawMacd = true;
        isDrawDmi = false;
        isDrawRsi = false;
        isDrawKDJ = false;
        isDrawWR = false;
        isDrawCCI = false;
        isDrawATR = false;
        isDrawBIAS = false;
        isDrawPSY = false;
        isDrawTRIX = false;
        break;
      case "RSI": //"RSI",
        isDrawMacd = false;
        isDrawDmi = false;
        isDrawRsi = true;
        isDrawKDJ = false;
        isDrawWR = false;
        isDrawCCI = false;
        isDrawATR = false;
        isDrawBIAS = false;
        isDrawPSY = false;
        isDrawTRIX = false;
        break;
      case "KDJ": //"KDJ",
        isDrawMacd = false;
        isDrawDmi = false;
        isDrawRsi = false;
        isDrawKDJ = true;
        isDrawWR = false;
        isDrawCCI = false;
        isDrawATR = false;
        isDrawBIAS = false;
        isDrawPSY = false;
        isDrawTRIX = false;
        break;
      case "CCI": //"CCI",
        isDrawMacd = false;
        isDrawDmi = false;
        isDrawRsi = false;
        isDrawKDJ = false;
        isDrawWR = false;
        isDrawCCI = true;
        isDrawATR = false;
        isDrawBIAS = false;
        isDrawPSY = false;
        isDrawTRIX = false;
        break;
    }
    isAllowAdd = false;
    SWITHING_INDEX = true;
    List<OHLCEntity> tmp = [];
    tmp.addAll(mOHLCData);
    setOHLCData(tmp);
    isAllowAdd = true;
  }

  void switchMidIndex() {
    int index = 4;
    for (int i = 4; i <= 5; i++) {
      if (mKIndexMainList[i].name == mSelMidIndex) {
        index = i + 1;
        index = index > 5 ? 4 : index;
        mSelMidIndex = mKIndexMainList[index].name;
        break;
      }
    }

    switchIndex(mKIndexMainList[index].name);
    refreshIndexRv(index, 2);
  }

  void switchSubIndex() {
    int index = 7;
    for (int i = 7; i < mKIndexMainList.length; i++) {
      if (mKIndexMainList[i].name == mSelSubIndex) {
        index = i + 1;
        index = index >= mKIndexMainList.length ? 7 : index;
        mSelSubIndex = mKIndexMainList[index].name;
        break;
      }
    }

    switchIndex(mKIndexMainList[index].name);
    refreshIndexRv(index, 3);
  }

  void refreshIndexRv(int position, int orderno) {
    if (orderno == 1) {
      for (int i = 0; i <= 2; i++) {
        if (position == i) {
          mKIndexMainList[i].isSelected = true;
        } else {
          mKIndexMainList[i].isSelected = false;
        }
      }
    } else if (orderno == 2) {
      for (int i = 4; i <= 5; i++) {
        if (position == i) {
          mKIndexMainList[i].isSelected = true;
        } else {
          mKIndexMainList[i].isSelected = false;
        }
      }
    } else if (orderno == 3) {
      for (int i = 7; i < mKIndexMainList.length; i++) {
        if (position == i) {
          mKIndexMainList[i].isSelected = true;
        } else {
          mKIndexMainList[i].isSelected = false;
        }
      }
    }
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
    chartVerCode = contract?.code ?? "--";
    if (contract?.isMain == true) {
      chartVerName = "${contract?.comName}主";
    } else {
      chartVerName = contract?.name ?? "--";
    }

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
    // EventBusUtil.getInstance().on<CorrKlineEvent>().listen((event) {
    //   List<String>? keyArr = event.key?.split(",");
    //   String? excd = keyArr?[0];
    //   String? type = keyArr?[1];
    //   String? comCode = keyArr?[2];
    //   String? conCode = keyArr?[3];
    //
    //   if (excd == contract?.exCode &&
    //       comCode == contract?.subComCode &&
    //       conCode == contract?.subConCode &&
    //       type == String.fromCharCode(contract?.comType ?? 0)) {
    //     OHLCEntity ohlc = OHLCEntity(
    //       open: event.data?.open,
    //       high: event.data?.high,
    //       close: event.data?.close,
    //       low: event.data?.low,
    //       volume: event.data?.volume?.toInt(),
    //     );
    //     if (event.data?.amount != 0) {
    //       ohlc.amount = event.data?.amount;
    //     }
    //     ohlc.date = Utils.timeMillisToDate(event.data?.uxTime?.toInt() ?? 0);
    //     ohlc.time = Utils.timeMillisToTime(event.data?.uxTime?.toInt() ?? 0);
    //     if (isAllowAdd && !isSwithing) {
    //       calcNewData(ohlc, kPeriod, contract?.preSettlePrice?.toDouble() ?? 0);
    //     }
    //   }
    // });
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
      isDrawMacd: isDrawMacd,
      isDrawRsi: isDrawRsi,
      isDrawDmi: isDrawDmi,
      isDrawBollinger: isDrawBollinger,
      isDrawDKX: isDrawDKX,
      isDrawCost: isDrawCost,
      isDrawCost1: isDrawCost1,
      isDrawCost2: isDrawCost2,
      isDrawCost3: isDrawCost3,
      isDrawCost4: isDrawCost4,
      isDrawCost5: isDrawCost5,
      isDrawFall: isDrawFall,
      isDrawAlligator: isDrawAlligator,
      isDrawKDJ: isDrawKDJ,
      isDrawWR: isDrawWR,
      isDrawCCI: isDrawCCI,
      isDrawATR: isDrawATR,
      isDrawBIAS: isDrawBIAS,
      isDrawPSY: isDrawPSY,
      isDrawTRIX: isDrawTRIX,
      isDrawMIKE: isDrawMIKE,
      isDrawGUBI: isDrawGUBI,
      isDrawVolume: isDrawVolume,
      isDrawVR: isDrawVR,
      mPreSize: mPreSize,
      mMACDData: mMACDData,
      mDMIData: mDMIData,
      mRSIData: mRSIData,
      mBollingerData: mBollingerData,
      mDKXData: mDKXData,
      mCostData: mCostData,
      mFallData: mFallData,
      mAlligatorData: mAlligatorData,
      mKDJData: mKDJData,
      mWRData: mWRData,
      mCCIData: mCCIData,
      mATRData: mATRData,
      mBIASData: mBIASData,
      mPSYData: mPSYData,
      mTRIXData: mTRIXData,
      mMIKEData: mMIKEData,
      mGUBIData: mGUBIData,
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (event) {
        logger.i("onTapUp:$event");
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          return;
        }
        if (isDrawTime) {
          if (isDrawCrossLine) {
            isDrawCrossLine = false;
            if (mounted) setState(() {});
          }
          return;
        }
        if (isTriggerLong) {
          isTriggerLong = false;
        }
        //最后一根到达当前数据最后一根时才开始刷新界面，处于历史位置都不刷新
        if (mDataStartIndext + mShowDataNum == mOHLCData.length) {
          isAllowAdd = true; // mChartViewListener.startAddData();//开始K线刷新
        } else {
          isAllowAdd = false; // mChartViewListener.stopAddData();//停止K线刷新
        }
        if (isDrawCrossLine) {
          isDrawCrossLine = false;
        } else {
          if (event.localPosition.dy < BaseKChartPainter.MID_CHART_TOP) {
            int mainEnd = 0;
            int index = 0;
            for (int i = 0; i < mKIndexMainList.length; i++) {
              if (mKIndexMainList[i].itemType == 1) {
                mainEnd = i - 1;
                break;
              }
            }
            for (int i = 0; i <= mainEnd; i++) {
              if (mKIndexMainList[i].name == mSelMainIndex) {
                index = i + 1;
                index = index > mainEnd ? 0 : index;
                mSelMainIndex = mKIndexMainList[index].name;
                break;
              }
            }
            switchIndex(mSelMainIndex);
            refreshIndexRv(index, 1);
          } else if (event.localPosition.dy < BaseKChartPainter.LOWER_CHART_TOP && event.localPosition.dy > BaseKChartPainter.MID_CHART_TOP) {
            switchMidIndex();
          } else if (event.localPosition.dy > BaseKChartPainter.LOWER_CHART_TOP) {
            switchSubIndex();
          }
        }
        if (mounted) setState(() {});
      },
      onScaleStart: (event) {
        event.pointerCount;
        scaleCandleWidth = mCandleWidth;
        scaleShowDataNum = mShowDataNum;
      },
      onScaleUpdate: (event) {
        var candleWidth = scaleCandleWidth;
        var showDataNum = scaleShowDataNum;
        if (isDrawTime) {
          return;
        }
        if (isDrawCrossLine) {
          currentX = event.localFocalPoint.dx;
          currentY = event.localFocalPoint.dy;
        } else {
          if (mOHLCData.isEmpty) {
            return;
          }
          mStartX = event.localFocalPoint.dx;
          mStartY = event.localFocalPoint.dy;

          int showNum = showDataNum;
          candleWidth = candleWidth * event.scale;
          if (candleWidth > mChartWidth / MIN_CANDLE_NUM) {
            candleWidth = mChartWidth / MIN_CANDLE_NUM;
          }
          if (candleWidth < 2) {
            candleWidth = 2;
          }
          showDataNum = (mChartWidth ~/ candleWidth) - 1; //减1是为了最后一根不超出右边界线
          if (showDataNum > mOHLCData.length) {
            showDataNum = MIN_CANDLE_NUM > mOHLCData.length ? MIN_CANDLE_NUM : mOHLCData.length;
          }
          if (isDrawAlligator) {
            showDataNum = showDataNum - ChartPainter.JawSpeed; //绘制鳄鱼线时全屏显示根数需要减少
          }
          if (mDataStartIndext + showNum == mOHLCData.length) {
            //如果缩放之前，K线在最新数据，保持最右边数据不动（显示到最新数据）
            mDataStartIndext = mOHLCData.length - showDataNum;
          }
          mCandleWidth = candleWidth;
          mShowDataNum = showDataNum;
          mDownSpace = event.scale;
          setCurrentData();
          if (mounted) setState(() {});
        }
      },
      onScaleEnd: (event) {
        Port.CandleWidth = mCandleWidth;
      },
      onLongPressStart: (event) {
        logger.i("onLongPressStart:$event");
        isDrawCrossLine = true;
        currentX = event.localPosition.dx;
        currentY = event.localPosition.dy;
        if (mounted) setState(() {});
      },
      onLongPressMoveUpdate: (event) {
        currentX = event.localPosition.dx;
        currentY = event.localPosition.dy;
        if (mounted) setState(() {});
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

          int maxPeriod = ChartPainter.getMaxPeriod(isDrawAlligator, isDrawCost, isDrawDKX, isDrawBollinger, isDrawFall, isDrawMacd, isDrawDmi, isDrawRsi,
              isDrawTRIX, isDrawPSY, isDrawATR, isDrawBIAS, isDrawCCI, isDrawKDJ, isDrawWR, isDrawMIKE, isDrawGUBI);

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
      child: RepaintBoundary(
          child: CustomPaint(
        size: Size(0.77.sw, 1.sh),
        painter: painter,
      )),
    );
  }

  Widget dataWidget() {
    return SizedBox(
      width: 288,
      child: Column(
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
                  IconButton(icon: const Icon(FluentIcons.query_list), onPressed: () {})
                ],
              )),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(border: Border.all(color: Colors.red)),
            alignment: Alignment.center,
            child: RichText(
              text: TextSpan(style: const TextStyle(fontSize: 22), children: [
                TextSpan(text: "卖一   ", style: TextStyle(color: appTheme.color)),
                TextSpan(text: "74.24   ", style: TextStyle(color: Colors.red)),
                TextSpan(text: "25", style: TextStyle(color: Colors.yellow))
              ]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(border: Border.all(color: Colors.red)),
            alignment: Alignment.center,
            child: RichText(
              text: TextSpan(style: const TextStyle(fontSize: 22), children: [
                TextSpan(text: "买一   ", style: TextStyle(color: appTheme.color)),
                TextSpan(text: "74.21   ", style: TextStyle(color: Colors.red)),
                TextSpan(text: "13", style: TextStyle(color: Colors.yellow))
              ]),
            ),
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
          Expanded(
            child: Container(
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
                            itemCount: quoteFilledData.length + 1,
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
          )
        ],
      ),
    );
  }

  Widget dataItem(String? title, {Color? color, bool? thin}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(title ?? "-", style: TextStyle(fontWeight: thin == true ? FontWeight.w100 : FontWeight.bold, fontSize: 16, color: color ?? appTheme.color)),
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
                    : Colors.white),
      ),
    );
  }
}
