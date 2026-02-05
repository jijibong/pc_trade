import 'dart:async';
import 'dart:convert';
import 'dart:math' hide log;
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Condition;
import 'package:multi_split_view/multi_split_view.dart';
import 'package:trade/main.dart';
import 'package:trade/model/user/user.dart';
import 'package:trade/util/shared_preferences/shared_preferences_key.dart';
import 'package:trade/util/shared_preferences/shared_preferences_utils.dart';
import 'package:uuid/uuid.dart';

import '../../../config/common.dart';
import '../../../model/draw_tools/DrawTool.dart';
import '../../../model/k/OHLCEntity.dart';
import '../../../model/k/custom_line.dart';
import '../../../model/k/draw_tool_line.dart';
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
import '../../../model/k/trade_time.dart';
import '../../../model/pb/quote/fill.pb.dart';
import '../../../model/pl/pl.dart';
import '../../../model/quote/contract.dart';
import '../../../model/quote/order_type.dart';
import '../../../model/quote/position_effect_type.dart';
import '../../../model/quote/side_type.dart';
import '../../../model/socket_packet/operation.dart';
import '../../../model/trade/hold_order.dart';
import '../../../model/trade/res_hold_order.dart';
import '../../../server/condition/condition.dart';
import '../../../server/login/login.dart';
import '../../../server/pl/pl.dart';
import '../../../server/quote/market.dart';
import '../../../util/dialog/add_option.dart';
import '../../../util/dialog/contract_info.dart';
import '../../../util/dialog/line_dialog.dart';
import '../../../util/dialog/mod_condition.dart';
import '../../../util/dialog/period_dialog.dart';
import '../../../util/dialog/pl_dialog.dart';
import '../../../util/event_bus/eventBus_utils.dart';
import '../../../util/event_bus/events.dart';
import '../../../util/info_bar/info_bar.dart';
import '../../../util/log/log.dart';
import '../../../util/multi_windows_manager/consts.dart';
import '../../../util/multi_windows_manager/multi_window_manager.dart';
import '../../../util/painter/k_chart/base_k_chart_painter.dart';
import '../../../util/painter/k_chart/k_chart_painter.dart';
import '../../../util/painter/k_chart/sub_chart_painter.dart';
import '../../../util/theme/theme.dart';
import '../../../util/utils/k_util.dart';
import '../../../util/utils/market_util.dart';
import '../../../util/utils/utils.dart';
import '../../../util/widget/dash_divider.dart';
import '../../draw/draw_icons.dart';
import '../quote_logic.dart';

class QuoteDetails extends StatefulWidget {
  final Contract contract;
  final int index;
  final bool? multiScreen;

  const QuoteDetails(this.contract, this.index, {this.multiScreen, super.key});

  @override
  State<QuoteDetails> createState() => _QuoteDetailsState();
}

class _QuoteDetailsState extends State<QuoteDetails> with TickerProviderStateMixin {
  final QuoteLogic logic = Get.put(QuoteLogic());
  final ThemeController themeController = Get.find<ThemeController>();
  Contract? contract = Contract();
  List<FillData> quoteFilledData = [];
  List<HoldOrder> holdOrder = [];
  List<PLRecord> pLRecordList = [];
  var uuid = const Uuid();
  final mainMenuController = FlyoutController();
  final priceController = FlyoutController();
  late ChartPainter painter;
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
  bool showPanKou = true;

  KPeriod kPeriod = KPeriod();
  List<OHLCEntity> mOHLCData = [];
  bool isSetIndex = true;
  bool isDrawTime = true;
  bool isDrawBollinger = false;
  bool isDrawCost = true;
  bool isDrawCost1 = true;
  bool isDrawCost2 = true;
  bool isDrawCost3 = true;
  bool isDrawCost4 = true;
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

  List<int> subChartList = [1, 2];
  // bool canDrawMACD = false,
  //     canDrawVR = false,
  //     canDrawVOL = true,
  //     canDrawKDJ = false,
  //     canDrawRSI = false,
  //     canDrawCCI = false,
  //     canDrawBIAS = false,
  //     canDrawOBV = false,
  //     canDrawWR = false,
  //     canDrawDMA = false,
  //     canDrawPSY = false,
  //     canDrawMACDBANG = false;
  // bool canDrawMACD1 = false,
  //     canDrawVR1 = false,
  //     canDrawVOL1 = false,
  //     canDrawKDJ1 = true,
  //     canDrawRSI1 = false,
  //     canDrawCCI1 = false,
  //     canDrawBIAS1 = false,
  //     canDrawOBV1 = false,
  //     canDrawWR1 = false,
  //     canDrawDMA1 = false,
  //     canDrawPSY1 = false,
  //     canDrawMACDBANG1 = false;
  // bool canDrawMACD2 = true,
  //     canDrawVR2 = false,
  //     canDrawVOL2 = false,
  //     canDrawKDJ2 = false,
  //     canDrawRSI2 = false,
  //     canDrawCCI2 = false,
  //     canDrawBIAS2 = false,
  //     canDrawOBV2 = false,
  //     canDrawWR2 = false,
  //     canDrawDMA2 = false,
  //     canDrawPSY2 = false,
  //     canDrawMACDBANG2 = false;
  // bool canDrawMACD3 = false,
  //     canDrawVR3 = false,
  //     canDrawVOL3 = false,
  //     canDrawKDJ3 = false,
  //     canDrawRSI3 = true,
  //     canDrawCCI3 = false,
  //     canDrawBIAS3 = false,
  //     canDrawOBV3 = false,
  //     canDrawWR3 = false,
  //     canDrawDMA3 = false,
  //     canDrawPSY3 = false,
  //     canDrawMACDBANG3 = false;
  bool isDrawCrossLine = false;
  bool isDrawing = false;
  bool orderDrawing = false;
  bool delOrderLines = false;
  bool startDrawTool = false;
  bool drawTooling = false;
  bool drawToolEnd = false;
  int orderDrawType = 0;
  int num = 0;
  String price = "市价";
  int pathType = 0;
  int colorValue = 4294967295;
  int widthType = 1;
  int lineType = 0;
  List<CustomLine> drawOrderLines = []; //画线下单
  List<DrawToolLine> drawToolLines = []; //画线工具
  List<KPeriod> periodList = [];
  double lastClose = 0;

  ///一档报价
  int level = 1;

  /// 当前横坐标
  double currentX = -1;

  /// 当前纵坐标
  double currentY = -1;

  int hoverIndex = -1;

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
  double mStartX = 0;
  double mStartY = 0;
  int mDownIndext = 0;

  double mCandleWidth = Port.CandleWidth;
  double scaleCandleWidth = Port.CandleWidth;
  double mMaxPrice = -1;
  double mMinPrice = -1;
  String mStartDate = "";
  List<TradeTime> mTradeTimes = [];
  List<String> mFsTimes = [];
  int mFsCount = 0;
  List<DrawToolObj> drawToolObjList = [];

  String pankouLastPrice = "--";
  String pankouChange = "--";
  String pankouChangePer = "--";
  String pankouOpenprice = "--";
  String pankouHighprice = "--";
  String pankouPosition = "--";
  String pankouLowprice = "--";
  String pankouPoor = "--";
  String pankouAvr = "--";
  String pankouAllMarket = "--";
  String pankouCirMarket = "--";
  String pankouPresettle = "--";
  bool pankouUp = true;
  bool pankouLowUp = true;
  bool pankouHighUp = true;
  int selectedLine = -1; //画线下单线
  int selectedPLLine = -1; //损盈线
  int selectedIndex = -1; //画线工具线
  int selectedPoint = -1;
  Offset? startMovingPoint;
  String? initPointX1;
  String? initPointX2;
  String? initPointX3;
  double? initPointY1;
  double? initPointY2;
  double? initPointY3;
  // bool moveLine = false;
  SystemMouseCursor cursor = SystemMouseCursors.basic;
  double leftMarginSpace = 80;
  final double _hitPadding = 5.0;
  StreamSubscription? streamSubscriptionA;
  StreamSubscription? streamSubscriptionB;
  StreamSubscription? streamSubscriptionC;
  StreamSubscription? streamSubscriptionD;
  StreamSubscription? streamSubscriptionE;
  StreamSubscription? streamSubscriptionF;
  // StreamSubscription? streamSubscriptionG;
  // StreamSubscription? streamSubscriptionH;
  StreamSubscription? streamSubscriptionI;
  StreamSubscription? streamSubscriptionJ;
  StreamSubscription? streamSubscriptionK;
  StreamSubscription? streamSubscriptionL;
  StreamSubscription? streamSubscriptionM;
  StreamSubscription? streamSubscriptionN;
  StreamSubscription? streamSubscriptionO;
  StreamSubscription? streamSubscriptionP;
  MultiSplitViewController multiSplitViewController = MultiSplitViewController();

  getKPeriod() async {
    if (logic.kPeriodList[widget.index].name != null) {
      kPeriod = logic.kPeriodList[widget.index];
      mOHLCData.clear();
      SWITHING_TIME = true;
      if (kPeriod.period == KTime.FS) {
        isDrawTime = true;
        logic.showChartList[widget.index] = 0;
      } else {
        isDrawTime = false;
      }
    } else {
      kPeriod = KPeriod(name: "分时", period: KTime.FS, cusType: 1, kpFlag: KPFlag.Minute);
    }
    periodList.add(kPeriod);
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
    // if (mChartWidth == 0) {
    double chartWidth = ChartPainter.kChartViewWidth - 2 * BaseKChartPainter.MARGINLEFT - ChartPainter.leftMarginSpace;
    mChartWidth = max(chartWidth, 0);
    // }
    int count = 0; //增加的数据量

    if (OHLCData.isEmpty) {
      return;
    } else {
      if (OHLCData != mOHLCData) {
        mOHLCData.clear();
        mOHLCData.addAll(OHLCData);
      }
    }
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
      // if (mOHLCData.length - mPreSize != 0) {
      // mChartViewListener.enterNext(); //K线数量有变化
      // }
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
        mCostData?.initData(mOHLCData, ChartPainter.CostOnePeriod, ChartPainter.CostTwoPeriod, ChartPainter.CostThreePeriod,
            ChartPainter.CostFourPeriod, ChartPainter.CostFivePeriod, cost_indexType, cost_priceType);
      } else {
        if (SWITHING_TIME || SWITHING_CODE || isSwithSmart || type_changed || SWITHING_INDEX || SWITHING_PERIOD || ADD_DATA) {
          //是否正在切换数据
          mCostData?.initData(mOHLCData, ChartPainter.CostOnePeriod, ChartPainter.CostTwoPeriod, ChartPainter.CostThreePeriod,
              ChartPainter.CostFourPeriod, ChartPainter.CostFivePeriod, cost_indexType, cost_priceType);
        } else {
          mCostData?.addData(mOHLCData, ChartPainter.CostOnePeriod, ChartPainter.CostTwoPeriod, ChartPainter.CostThreePeriod,
              ChartPainter.CostFourPeriod, ChartPainter.CostFivePeriod, cost_indexType, cost_priceType, count);
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
    if (isDrawRSI) {
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
    // mDataStartIndext = ADD_DATA ? Utils.getStartIndex(mStartDate, mOHLCData) : mOHLCData.length - mShowDataNum;
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

    if (mounted) setState(() {});
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
        isDrawBollinger = false;
        isDrawFall = false;
        break;
      case "BOLL": //BOLL
        isDrawCost = false;
        isDrawBollinger = true;
        isDrawFall = false;
        break;
      case "PBX": //FALL
        isDrawCost = false;
        isDrawBollinger = false;
        isDrawFall = true;
        break;
    }
    isDrawTime = false;
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
        await MarketServer.queryKline(contract!, kPeriod.period!, 0, 600).then((value) {
          if (kPeriod.period == null || kPeriod.period! < 0) return;
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
          lastClose = contract!.preSettlePrice!.toDouble();
          calcFsTime(value[value.length - 1].date ?? '', value[value.length - 1].time ?? '');
          List<OHLCEntity> allList = KUtils.dealFsData(value, mFsTimes, contract?.preSettlePrice?.toDouble() ?? 0, contract?.exCode ?? '');
          setTimeData(allList);
          isAllowAdd = true;
        }
        isSwithing = false;
      });
    }
    if (mounted) setState(() {});
  }

  void calcFsTime(String staDate, String staTime) {
    List<String> list = [];
    if (mTradeTimes.isNotEmpty) {
      String? openTime = "$staDate ${mTradeTimes[0].Start}";
      String? closeTime = "$staDate ${mTradeTimes[mTradeTimes.length - 1].End}";
      String nDate = staDate;
      String nTime = staTime;

      String preTime = openTime;
      if (Utils.compareDate(openTime, closeTime) == -1) {
        //收盘早于开盘

        if (Utils.compareDate(openTime, "$staDate $nTime") == -1) {
          if (Utils.getWeek(nDate) == 1) {
            //星期一
            nDate = Utils.getDayBefore(nDate, 3);
          } else {
            nDate = Utils.getDayBefore(nDate, 1);
          }
        }

        for (int i = 0; i < mTradeTimes.length; i++) {
          String indexStart = "$staDate ${mTradeTimes[i].Start}";
          String indexEnd = "$staDate ${mTradeTimes[i].End}";
          if (Utils.compareDate(indexStart, indexEnd) == -1) {
            String start = "$nDate ${mTradeTimes[i].Start}";
            nDate = Utils.getDayAfter(nDate, 1);
            String end = "$nDate ${mTradeTimes[i].End}";
            list.add(start);
            list.add(end);

            if (Utils.getWeek(nDate) == 6) {
              nDate = Utils.getDayAfter(nDate, 2);
            }
          } else {
            if (Utils.compareDate(indexStart, preTime) == 1) {
              if (Utils.getWeek(nDate) == 5) {
                //周五
                nDate = Utils.getDayAfter(nDate, 3);
                String start = "$nDate ${mTradeTimes[i].Start}";
                String end = "$nDate ${mTradeTimes[i].End}";
                list.add(start);
                list.add(end);
              } else {
                nDate = Utils.getDayAfter(nDate, 1);
                String start = "$nDate ${mTradeTimes[i].Start}";
                String end = "$nDate ${mTradeTimes[i].End}";
                list.add(start);
                list.add(end);
              }
            } else {
              String start = "$nDate ${mTradeTimes[i].Start}";
              String end = "$nDate ${mTradeTimes[i].End}";
              list.add(start);
              list.add(end);
            }
          }
          preTime = indexEnd;
        }
      } else {
        //开盘早于收盘
        for (int i = 0; i < mTradeTimes.length; i++) {
          String start = "$nDate ${mTradeTimes[i].Start}";
          String end = "$nDate ${mTradeTimes[i].End}";
          list.add(start);
          list.add(end);
        }
      }
    }

    // for (int i = 0; i < list.length; i++) {
    //   Log.e("交易时间hxj", list[i]);
    // }

    mFsTimes.clear();
    mFsTimes.addAll(list);

    //计算分时数量
    mFsCount = 0;
    for (int i = 0; i < mFsTimes.length; i = i + 2) {
      int start = int.parse(Utils.getLongTime(mFsTimes[i]));
      int end = int.parse(Utils.getLongTime(mFsTimes[i + 1]));
      mFsCount += (end - start) ~/ 60;
    }
  }

  /// 设置交易时间
  void setTradeTimes(String? tradeTimes) {
    if (tradeTimes != null) {
      List list = jsonDecode(tradeTimes);
      mTradeTimes.clear();
      mTradeTimes.addAll(list.map((e) => TradeTime.fromJson(e)).toList());
    } else {
      TradeTime tradeTime = TradeTime(Start: "06:00:00", End: "05:00:00");
      mTradeTimes.add(tradeTime);
    }
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
  void correctKline(int count) async {
    if (kPeriod.cusType == 1) {
      await MarketServer.queryKline(contract!, kPeriod.period ?? KTime.FS, 0, count).then((value) {
        if (value != null) {
          correctData(value);
        } else {
          InfoBarUtils.showWarningBar("K线请求失败");
        }
      });
    } else {
      await MarketServer.customKline(contract!, kPeriod, 0, count).then((value) {
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

  Future getDrawLines() async {
    drawToolLines.clear();
    String? lines = await SpUtils.getString(SpKey.drawToolLines);
    if (lines != null) {
      Map temp = jsonDecode(lines);
      if (temp["${UserUtils.currentUser?.id ?? ""}${contract?.exCode}${contract?.code}${contract?.comType}"] != null) {
        var tmp = temp["${UserUtils.currentUser?.id ?? ""}${contract?.exCode}${contract?.code}${contract?.comType}"]
            .map<DrawToolLine>((json) => DrawToolLine.fromJson(json))
            .toList();
        drawToolLines.addAll(tmp.where((e) => e.period == kPeriod.name));
      }
    }
    qryCondition();
  }

  qryCondition() async {
    selectedLine = -1;
    drawOrderLines.clear();
    await ConditionServer.queryCondition().then((value) {
      if (value != null) {
        for (var con in value) {
          if (con.Status == 1) {
            CustomLine customLine = CustomLine(
              code: con.ContractNo,
              id: con.Id,
              orderType: con.OrderType,
              timeInForce: con.TimeInForce,
              expireTime: con.ExpireTime,
              orderSide: con.OrderSide,
              orderPrice: con.OrderPrice,
              orderQty: con.OrderQty,
              positionEffect: con.PositionEffect,
              priceType: con.PriceType,
              conditionType: con.ConditionType,
              conditionPrice: con.ConditionPrice,
              type: con.OrderType,
              num: con.OrderQty,
              side: con.OrderType,
              kPrice: con.OrderPrice,
            );
            drawOrderLines.add(customLine);
          }
        }
      }
    });
  }

  double calculatePrice(double Y, ChartPainter painter) {
    double rate = painter.mUperChartHeight / (mMaxPrice - mMinPrice); //计算最小单位
    double textBottom = Port.text_top;
    double price = double.parse((mMaxPrice - ((Y - textBottom) / rate)).toStringAsFixed(2));
    return price;
  }

  int calculateIndex(double X) {
    double i = (X - leftMarginSpace - BaseKChartPainter.MARGINLEFT) / mCandleWidth;
    return min(i.round() + mDataStartIndext, mOHLCData.length);
  }

  double dateTOX(String date) {
    int x = mOHLCData.indexWhere((e) => "${e.date} ${e.time}" == date);
    return BaseKChartPainter.MARGINLEFT + mCandleWidth * (x - mDataStartIndext) + leftMarginSpace;
  }

  double priceTOY(double y, ChartPainter painter) {
    double rate = painter.mUperChartHeight / (mMaxPrice - mMinPrice); //计算最小单位
    double textBottom = painter.MARGINTOP;
    return (mMaxPrice - y) * rate + textBottom;
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
    pankouChangePer = "${Utils.double2Str(Utils.dealPointBigDecimal(contract?.changePer?.toDouble(), 2))}%";
    pankouOpenprice = Utils.double2Str(Utils.dealPointByOld(contract?.openPrice, tick));
    pankouHighprice = Utils.double2Str(Utils.dealPointByOld(contract?.highPrice, tick));
    pankouPosition = "${contract?.position?.toInt() ?? 0}";
    pankouLowprice = Utils.double2Str(Utils.dealPointByOld(contract?.lowPrice, tick));
    pankouPoor = "${((contract?.position ?? 0) - (contract?.prePosition ?? 0))}";
    pankouAvr = contract?.averPrice != null ? Utils.double2Str(Utils.dealPointByOld(contract?.averPrice, tick)) : "--";
    pankouAllMarket = contract?.all_marketValue != null ? Utils.double2Str(Utils.dealPointByOld(contract?.all_marketValue, tick)) : "--";
    pankouCirMarket = contract?.cir_marketValue != null ? Utils.double2Str(Utils.dealPointByOld(contract?.cir_marketValue, tick)) : "--";
    pankouPresettle = Utils.double2Str(Utils.dealPointByOld(contract?.preSettlePrice, tick));

    if ((contract?.change ?? 0) > 0) {
      pankouUp = true;
    } else if ((contract?.change ?? 0) < 0) {
      pankouUp = false;
    }

    if (contract?.highPrice != null && contract?.openPrice != null && (contract!.highPrice! < contract!.openPrice!)) {
      pankouHighUp = false;
    }

    if (contract?.lowPrice != null && contract?.openPrice != null && (contract!.lowPrice! < contract!.openPrice!)) {
      pankouLowUp = false;
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
    if (mTradeTimes.isNotEmpty && period.cusType == 1 && period.kpFlag == KPFlag.Day) {
      newestTime = "${data.date} ${mTradeTimes[mTradeTimes.length - 1].End}";
    } else if (period.cusType == 2) {
      newestTime = "${data.date} ${data.time}";
    } else {
      newestTime = "${data.date} ${data.time}";
    }

    lastClose = preSettlePrice;
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
          newstDate = Utils.calcCustomNextDate(preTime, newestTime, period, mTradeTimes);
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
            int amount = (data.amount ?? 0) - (mOHLCList[mOHLCList.length - 1].customAmount ?? 0);
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
              newstDate = Utils.calcCustomNextDate(preTime, newestTime, period, mTradeTimes);
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
            newstDate = Utils.calcCustomNextDate(preTime, newestTime, period, mTradeTimes);
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
    if (!sub) {
      List<FillData> tmp = [];
      tmp.addAll(quoteFilledData);
      logic.quoteFilledList.add({"${contract?.exCode}.${contract?.subComCode}.${contract?.subConCode}": tmp});
      quoteFilledData.clear();
    } else {
      for (var e in logic.quoteFilledList) {
        if (e.containsKey("${contract?.exCode}.${contract?.subComCode}.${contract?.subConCode}")) {
          quoteFilledData = e["${contract?.exCode}.${contract?.subComCode}.${contract?.subConCode}"] ?? [];
        }
      }
    }
    String? excd = contract?.exCode;
    String? type = String.fromCharCode(contract?.comType ?? 0);
    String? comCode = contract?.subComCode;
    String? conCode = contract?.subConCode;
    String key = "$excd.$type.$comCode.$conCode";
    EventBusUtil.getInstance().fire(SubEvent([key], sub ? Operation.SendSubFillData : Operation.SendUnSubFillData));
    // if (mounted) setState(() {});
  }

  ///订阅\取消K线
  void subscriptionKlineData(bool sub) {
    if (contract != null) {
      List<String> json = Utils.getSubJson(0, 1, [contract!]);
      EventBusUtil.getInstance().fire(SubEvent(json, sub ? Operation.RecvSubKlineData : Operation.RecvUnSubKlineData, period: kPeriod.period));
    }
  }

  // ///添加条件单
  // void addLineCondition(
  //     String? ExchangeNo,
  //     String? CommodityNo,
  //     int? CommodityType,
  //     String? ContractNo,
  //     int? OrderType,
  //     int? TimeInForce,
  //     String? ExpireTime,
  //     int? OrderSide,
  //     double? OrderPrice,
  //     int? OrderQty,
  //     int? PositionEffect,
  //     int? PriceType,
  //     int? ConditionType,
  //     double? ConditionPrice) async {
  //   await ConditionServer.addCondition(ExchangeNo, CommodityNo, CommodityType, ContractNo, OrderType, TimeInForce, ExpireTime, OrderSide, OrderPrice,
  //           OrderQty, PositionEffect, PriceType, ConditionType, ConditionPrice)
  //       .then((value) {
  //     // if (value) {
  //     // InfoBarUtils.showSuccessBar("添加条件单成功");
  //     // qryCondition(0);
  //     // }
  //   });
  // }

  bool _checkHit(Path path, Offset point) {
    // 1. 快速边界框检查
    final bounds = path.getBounds().inflate(_hitPadding);
    if (!bounds.contains(point)) return false;

    // 2. 精确距离检查
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final closestOffset = _findClosestOffset(metric, point);
      final tangent = metric.getTangentForOffset(closestOffset);

      if (tangent != null && (tangent.position - point).distance <= _hitPadding) {
        return true;
      }
    }
    return false;
  }

  bool _checkHitPoint(double x, double y, Offset mouse) {
    if ((mouse.dx - x).abs() < 5 && (mouse.dy - y).abs() < 5) {
      return true;
    }
    return false;
  }

  double _findClosestOffset(PathMetric metric, Offset point) {
    double minOffset = 0;
    double maxOffset = metric.length;
    double closestOffset = 0;
    double closestDistance = double.infinity;
    const double threshold = 0.5; // 精度阈值

    while (maxOffset - minOffset > threshold) {
      final mid1 = minOffset + (maxOffset - minOffset) / 3;
      final mid2 = maxOffset - (maxOffset - minOffset) / 3;

      final dist1 = _distanceAtOffset(metric, mid1, point);
      final dist2 = _distanceAtOffset(metric, mid2, point);

      if (dist1 < dist2) {
        maxOffset = mid2;
        if (dist1 < closestDistance) {
          closestDistance = dist1;
          closestOffset = mid1;
        }
      } else {
        minOffset = mid1;
        if (dist2 < closestDistance) {
          closestDistance = dist2;
          closestOffset = mid2;
        }
      }
    }

    return closestOffset;
  }

  double _distanceAtOffset(PathMetric metric, double offset, Offset point) {
    final tangent = metric.getTangentForOffset(offset);
    return tangent != null ? (tangent.position - point).distance : double.infinity;
  }

  void initContract() {
    var con = widget.contract;
    Contract? mContract = MarketUtils.getVariety(con.exCode, con.code, con.comType);
    contract = mContract;
    if (con.isMain == true) {
      contract?.isMain = true;
    }
    if (contract == null) return;
    if (!logic.historyList.contains(contract)) {
      logic.historyList.add(contract!);
    }
    getKPeriod();
    getDrawLines();
    refreshData();
  }

  void listener() {
    ///登录信息
    streamSubscriptionA = EventBusUtil.getInstance().on<LoginSuccess>().listen((event) {
      if (event.success) {
        logic.requestHold();
      }
    });

    ///K线缩放
    streamSubscriptionB = EventBusUtil.getInstance().on<ScaleKLine>().listen((event) {
      if (isDrawTime) {
        return;
      }
      if (mOHLCData.isEmpty) {
        return;
      }
      int showNum = mShowDataNum;

      if (!event.enlarge) {
        mCandleWidth = mCandleWidth * 0.8;
      } else if (event.enlarge) {
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
    });

    ///行情变化
    streamSubscriptionC = EventBusUtil.getInstance().on<QuoteEvent>().listen((event) {
      Contract con = event.con;
      if (con.exCode == contract?.exCode && con.code == contract?.code && con.comType == contract?.comType) {
        contract = con;
        refreshData();

        if (mFsTimes.isNotEmpty) {
          String tradeStart = mFsTimes[0].split(" ")[1].substring(0, 5);
          String qutoTime = Utils.timeMillisToTime((contract?.timeStamps ?? 0).toInt()).substring(0, 5);
          if (tradeStart == qutoTime && isDrawTime) {
            setTradeTimes(contract?.trTime);
            requestAllData();
          }
        }
      }
    });

    ///盘口数据
    streamSubscriptionD = EventBusUtil.getInstance().on<QuoteFilledData>().listen((event) {
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
    streamSubscriptionE = EventBusUtil.getInstance().on<CorrKlineEvent>().listen((event) {
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
          ohlc.amount = event.data?.amount?.toInt();
        }
        ohlc.date = Utils.timeMillisToDate(event.data?.uxTime?.toInt() ?? 0);
        ohlc.time = Utils.timeMillisToTime(event.data?.uxTime?.toInt() ?? 0);
        if (isAllowAdd && !isSwithing) {
          calcNewData(ohlc, kPeriod, contract?.preSettlePrice?.toDouble() ?? 0);
        }
      }
    });

    ///周期变化
    streamSubscriptionF = EventBusUtil.getInstance().on<SwitchPeriod>().listen((event) {
      if (logic.selectedIndex.value == widget.index) {
        switchPeriod(event.kPeriod);
      }
    });

    // ///画线工具
    // streamSubscriptionG = EventBusUtil.getInstance().on<ToolDrawing>().listen((event) async {});

    // ///画线下单
    // streamSubscriptionH = EventBusUtil.getInstance().on<OrderDrawing>().listen((event) async {});

    ///持仓变化
    streamSubscriptionI = EventBusUtil.getInstance().on<RefreshHold>().listen((event) async {
      getPosition();
    });

    ///画线设置
    streamSubscriptionJ = EventBusUtil.getInstance().on<SetLine>().listen((event) async {
      DrawToolLine tmp = DrawToolLine.fromJson(event.json);
      int x = mOHLCData.indexWhere((e) => "${e.date} ${e.time}" == tmp.firstPointX);
      for (var e in drawToolLines) {
        if (e.id == tmp.id) {
          if (x == -1) {
            tmp.firstPointX = e.firstPointX;
          }
          if (tmp.secondPointX != null) {
            int x = mOHLCData.indexWhere((e) => "${e.date} ${e.time}" == tmp.secondPointX);
            if (x == -1) {
              tmp.secondPointX = e.secondPointX;
            }
          }
          if (tmp.thirdPointX != null) {
            int x = mOHLCData.indexWhere((e) => "${e.date} ${e.time}" == tmp.thirdPointX);
            if (x == -1) {
              tmp.thirdPointX = e.thirdPointX;
            }
          }
          drawToolLines[drawToolLines.indexOf(e)] = tmp;
        }
      }
      List temp = drawToolLines.map((e) => e.toJson()).toList();
      String jsonString = jsonEncode({"${UserUtils.currentUser?.id ?? ""}${contract?.exCode}${contract?.code}${contract?.comType}": temp});
      await SpUtils.set(SpKey.drawToolLines, jsonString);
      if (mounted) setState(() {});
    });

    ///画线工具箱
    streamSubscriptionK = EventBusUtil.getInstance().on<DrawEvent>().listen((event) async {
      var map = event.typeList;
      for (int e in map) {
        drawToolObjList.addAll(Common().drawToolTypes.where((element) => element.index == e));
      }
      if (mounted) setState(() {});
    });

    ///画线下单
    streamSubscriptionL = EventBusUtil.getInstance().on<OrderEvent>().listen((event) async {
      var map = event.json;
      if (map == false) {
        delOrderLines = true;
      } else {
        delOrderLines = false;
        orderDrawType = map['type'];
        if (orderDrawType == 0) {
          orderDrawing = false;
        } else {
          orderDrawing = true;
          if (startDrawTool) {
            startDrawTool = false;
            await DesktopMultiWindow.invokeMethod(drawToolWindowId ?? 1, drawDoneEvent, "");
          }
          num = map['num'];
          price = map['priceType'];
        }
      }
      if (mounted) setState(() {});
    });

    ///刷新
    streamSubscriptionM = EventBusUtil.getInstance().on<RefreshEvent>().listen((event) async {
      switchPeriod(kPeriod, force: true);
    });

    ///切换合约
    streamSubscriptionN = EventBusUtil.getInstance().on<SwitchContract>().listen((event) async {
      if (widget.index == event.index) {
        subscriptionKlineData(false);
        subscriptionQuote(false);
        subscriptionFill(false);
        var con = event.contract;
        Contract? mContract = MarketUtils.getVariety(con.exCode, con.code, con.comType);
        contract = mContract;
        if (con.isMain == true) {
          contract?.isMain = true;
        }
        if (contract != null && !logic.historyList.contains(contract)) {
          logic.historyList.add(contract!);
        }
        setTradeTimes(contract?.trTime);
        subscriptionKlineData(true);
        subscriptionQuote(true);
        subscriptionFill(true);
        requestAllData();
        getDrawLines();
        refreshData();
        getPosition();
      }
    });

    ///返回
    streamSubscriptionO = EventBusUtil.getInstance().on<BackEvent>().listen((event) async {
      if (event.index == widget.index) {
        if (periodList.length > 1) {
          periodList.removeLast();
          switchPeriod(periodList.last, force: true);
        } else {
          logic.viewIndexList[widget.index] = 0;
        }
      }
    });

    ///浮动盈亏变化信息
    streamSubscriptionP = EventBusUtil.getInstance().on<PositionFloatEvent>().listen((positionFloatEvent) async {
      if (!LoginServer.isLogin) return;
      for (var hold in holdOrder) {
        if (hold.noMap != null && hold.noMap!.containsKey(positionFloatEvent.res.PositionNo)) {
          double floatP = 0;
          if (hold.detailList != null) {
            for (ResHoldOrder detail in hold.detailList!) {
              if (detail.PositionNo == positionFloatEvent.res.PositionNo) {
                detail.PositionProfit = positionFloatEvent.res.PositionProfit;
              }
              floatP = floatP + (detail.PositionProfit ?? 0);
            }
            hold.floatProfit = floatP;
            await queryPLRecord(hold);
          }
        }
      }
      if (mounted) setState(() {});
    });
  }

  getPosition() async {
    holdOrder.clear();
    if (logic.mHoldList.isNotEmpty) {
      for (HoldOrder e in logic.mHoldList) {
        if (e.exCode == contract?.exCode && e.code == contract?.code && e.comType == contract?.comType) {
          await queryPLRecord(e);
          holdOrder.add(e);
        }
      }
    }
  }

  /// 查询止盈止损
  Future queryPLRecord(HoldOrder hold) async {
    pLRecordList.clear();
    await PLServer.getHisPLRecord(hold.exCode, hold.subComCode, hold.subConCode, hold.comType, hold.orderSide).then((value) {
      if (value != null && value.isNotEmpty) {
        for (var e in value) {
          if (e.State == 1) {
            pLRecordList.add(e);
          }
        }
        if (mounted) setState(() {});
      }
    });
  }

  ///修改止盈止损
  void modifyPLRecord() async {
    if (pLRecordList[selectedPLLine].price == null) {
      queryPLRecord(holdOrder.first);
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PLDialog().showPLDialog("${pLRecordList[selectedPLLine].price ?? 0}", pLRecordList[selectedPLLine].win ? "盈" : "损",
              functionConfirm: () async {
            await PLServer.modifyPL(
                    holdOrder.first.exCode,
                    holdOrder.first.subComCode,
                    holdOrder.first.comType,
                    holdOrder.first.subConCode,
                    pLRecordList[selectedPLLine].Id,
                    pLRecordList[selectedPLLine].RealQty,
                    pLRecordList[selectedPLLine].CloseType,
                    pLRecordList[selectedPLLine].win ? pLRecordList[selectedPLLine].price : pLRecordList[selectedPLLine].StopWin,
                    pLRecordList[selectedPLLine].win ? pLRecordList[selectedPLLine].StopLoss : pLRecordList[selectedPLLine].price,
                    pLRecordList[selectedPLLine].FloatLoss)
                .then((value) {
              if (value != null) {
                if (mounted) setState(() {});
                InfoBarUtils.showSuccessBar("止盈止损修改成功");
              } else {
                queryPLRecord(holdOrder.first);
              }
            });
          }, functionCancel: () async {
            queryPLRecord(holdOrder.first);
          });
        });
  }

  switchPeriod(KPeriod period, {int? index, bool? force}) async {
    if (kPeriod == period && force != true) return;
    if (index != null) themeController.selectCommandBarIndex.value = index;
    if (force != true) {
      periodList.add(period);
    }
    subscriptionKlineData(false);
    kPeriod = period;
    logic.kPeriodList[widget.index] = period;
    mOHLCData.clear();
    SWITHING_TIME = true;
    if (period.period == KTime.FS) {
      isDrawTime = true;
      logic.showChartList[widget.index] = 0;
    } else {
      isDrawTime = false;
    }
    requestAllData();
    subscriptionKlineData(true);

    drawToolLines.clear();
    String? lines = await SpUtils.getString(SpKey.drawToolLines);
    if (lines != null) {
      Map temp = jsonDecode(lines);
      if (temp["${UserUtils.currentUser?.id ?? ""}${contract?.exCode}${contract?.code}${contract?.comType}"] != null) {
        var tmp = temp["${UserUtils.currentUser?.id ?? ""}${contract?.exCode}${contract?.code}${contract?.comType}"]
            .map<DrawToolLine>((json) => DrawToolLine.fromJson(json))
            .toList();
        drawToolLines.addAll(tmp.where((e) => e.period == kPeriod.name));
      }
    }
  }

  void initChart() {
    multiSplitViewController.addArea(Area(flex: 4, builder: (context, area) => mainChart()));
    multiSplitViewController.addArea(Area(builder: (context, area) => subChart(0, area.id)));
    multiSplitViewController.addArea(Area(builder: (context, area) => subChart(1, area.id)));
  }

  @override
  void initState() {
    initContract();
    initChart();
    setTradeTimes(contract?.trTime);
    listener();
    getPosition();
    subscriptionQuote(true);
    subscriptionFill(true);
    super.initState();
  }

  @override
  void dispose() {
    mainMenuController.dispose();
    priceController.dispose();
    streamSubscriptionA?.cancel();
    streamSubscriptionB?.cancel();
    streamSubscriptionC?.cancel();
    streamSubscriptionD?.cancel();
    streamSubscriptionE?.cancel();
    streamSubscriptionF?.cancel();
    // streamSubscriptionG?.cancel();
    // streamSubscriptionH?.cancel();
    streamSubscriptionI?.cancel();
    streamSubscriptionJ?.cancel();
    streamSubscriptionK?.cancel();
    streamSubscriptionL?.cancel();
    streamSubscriptionM?.cancel();
    streamSubscriptionN?.cancel();
    streamSubscriptionO?.cancel();
    streamSubscriptionP?.cancel();
    subscriptionKlineData(false);
    subscriptionQuote(false);
    subscriptionFill(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    painter = ChartPainter(
      isDrawTime: isDrawTime,
      lastClose: lastClose,
      mTradeTimes: mTradeTimes,
      mFsTimes: mFsTimes,
      mFsCount: mFsCount,
      isDrawCrossLine: isDrawCrossLine,
      orderDrawing: orderDrawing,
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
      drawOrderLines: drawOrderLines,
      drawToolLines: drawToolLines,
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
      holdOrder: holdOrder,
      pLRecordList: pLRecordList,
      hoverIndex: hoverIndex,
    );
    return contract != null
        ? Obx(() {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 9,
                    child: logic.showChartList[widget.index] == 0
                        ? Column(
                            children: [
                              if (widget.multiScreen != true)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${contract?.name ?? ""}(${contract?.code ?? ""})",
                                      style: TextStyle(fontSize: 18, color: themeController.theme.acrylicBackgroundColor),
                                    ),
                                    IconButton(
                                        icon: Image.asset(
                                          "assets/images/icon_heart@3x.png",
                                          width: Common.iconImageWidth,
                                        ),
                                        onPressed: () {
                                          Get.dialog(AddOptionDialog().addOptionDialog(contract!));
                                        }).marginSymmetric(horizontal: 20),
                                    IconButton(
                                        icon: Image.asset(
                                          "assets/images/icon_inf@3x.png",
                                          width: Common.iconImageWidth,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                if (contract != null) {
                                                  return ContractDialog().contractInfoDialog(contract!);
                                                }
                                                return Container();
                                              });
                                        }).marginOnly(right: 20),
                                    DashedDivider(
                                      axis: Axis.vertical,
                                      length: Common.iconImageWidth,
                                      color: Common.dashDividerColor,
                                    ),
                                    ...drawToolObjList.map(
                                      (e) => IconButton(
                                          icon: Image.asset(
                                            e.iconPath,
                                            width: Common.iconImageWidth - 2,
                                          ),
                                          onPressed: () {
                                            startDrawTool = true;
                                            pathType = e.index;
                                          }).marginOnly(left: 20),
                                    ),
                                  ],
                                ),
                              Expanded(
                                child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTapUp: (event) {
                                      if ((orderDrawing || startDrawTool || drawTooling || drawToolEnd) && !isDrawTime) return;
                                      isDrawCrossLine = !isDrawCrossLine;
                                      if (isDrawCrossLine) {
                                        currentX = event.localPosition.dx;
                                        currentY = event.localPosition.dy;
                                      } else {
                                        currentX = -1;
                                        currentY = -1;
                                      }
                                      if (mounted) setState(() {});
                                    },
                                    onHorizontalDragStart: (event) {
                                      if (isDrawTime || selectedIndex != -1) {
                                        return;
                                      }
                                      mDownIndext = mDataStartIndext;
                                      mStartX = event.localPosition.dx;
                                    },
                                    onHorizontalDragUpdate: (event) {
                                      if (mOHLCData.isEmpty || isDrawTime || selectedLine != -1 || selectedIndex != -1) {
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

                                        // int maxPeriod = ChartPainter.getMaxPeriod(isDrawCost, isDrawBollinger, isDrawFall);

                                        // if (maxPeriod > mDataStartIndext && isNeedAddData && isReachLast == false) {
                                        //   //到达指定位置控制数据的向前加载
                                        //   isNeedAddData = false;
                                        //   mStartDate = "${mOHLCData[0].date} ${mOHLCData[0].time}";
                                        //   requestMoreKline(int.parse(Utils.getLongTime(mStartDate)));
                                        // }
                                        // if (isNeedAddData) {
                                        setCurrentData();
                                        // }
                                      } else {
                                        currentX = event.localPosition.dx;
                                        currentY = event.localPosition.dy;
                                      }
                                      if (mounted) setState(() {});
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: themeController.theme.cardColor,
                                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                                        ),
                                        child: isDrawTime
                                            ? timeChart()
                                            : MultiSplitViewTheme(
                                                data: MultiSplitViewThemeData(
                                                    dividerThickness: 1, dividerPainter: DividerPainter(backgroundColor: Colors.transparent)),
                                                child: MultiSplitView(
                                                  axis: Axis.vertical,
                                                  controller: multiSplitViewController,
                                                )))),
                              ),
                            ],
                          )
                        : statement()),
                if (showPanKou && widget.multiScreen != true) Expanded(flex: 2, child: dataWidget())
              ],
            );
          })
        : GestureDetector(
            child: Container(color: Colors.transparent, alignment: Alignment.center, child: const Text("合约已过期")),
            onTap: () {
              logic.selectedIndex.value = widget.index;
            },
          );
  }

  Widget timeChart() {
    final contextController = FlyoutController();
    final flyoutTargetKey = GlobalKey();
    return Listener(
      onPointerHover: (e) {
        if (isDrawCrossLine) {
          currentX = e.localPosition.dx;
          currentY = e.localPosition.dy;
          if (mounted) setState(() {});
        }
      },
      child: GestureDetector(
        onSecondaryTapUp: (d) {
          final targetContext = flyoutTargetKey.currentContext;
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
                  onPressed: () {
                    EventBusUtil.getInstance().fire(LoginEvent());
                    Flyout.of(context).close();
                  },
                ),
                MenuFlyoutSubItem(
                    text: const Text('加入自选'),
                    leading: const Icon(
                      FluentIcons.accept,
                      color: Colors.transparent,
                    ),
                    items: (context) => logic.sectorList
                        .map((e) => MenuFlyoutItem(
                              text: Text(e.name ?? "--"),
                              onPressed: () {
                                EventBusUtil.getInstance().fire(AddOptionEvent(e, logic.selectedContractList[widget.index], true));
                              },
                            ))
                        .toList()),
                // MenuFlyoutItem(
                //     text: const Text('移除自选'),
                //     onPressed: () {
                //       logic.optionOperate(logic.selectedContractList[widget.index], add: false);
                //       Flyout.of(context).close();
                //     }),
                MenuFlyoutSubItem(
                  text: const Text('切换画面'),
                  leading: const Icon(
                    FluentIcons.accept,
                    color: Colors.transparent,
                  ),
                  items: (context) => [
                    MenuFlyoutItem(
                        text: const Text('报价页面'),
                        onPressed: () {
                          logic.viewIndexList[widget.index] = 0;
                          Flyout.of(context).close();
                        }),
                    isDrawTime
                        ? MenuFlyoutItem(
                            text: const Text('K线'),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day);
                              logic.showChartList[widget.index] = 0;
                              switchPeriod(fs, index: 1);
                            })
                        : MenuFlyoutItem(
                            text: const Text('分时'),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "分时", period: KTime.FS, cusType: 1, kpFlag: KPFlag.Minute);
                              switchPeriod(fs, index: 0);
                            }),
                    if (!isDrawTime)
                      MenuFlyoutItem(
                        text: const Text('成交报表'),
                        onPressed: () {
                          logic.showChartList[widget.index] = 1;
                        },
                      ),
                  ],
                ),
                MenuFlyoutSubItem(
                  text: const Text('技术指标'),
                  leading: const Icon(
                    FluentIcons.accept,
                    color: Colors.transparent,
                  ),
                  items: (context) => [
                    MenuFlyoutSubItem(
                      text: const Text('趋势分析指标（主图）'),
                      items: (_) => [
                        MenuFlyoutItem(
                          text: const Text('MA组合'),
                          onPressed: () {
                            switchIndex("MA");
                            if (mounted) setState(() {});
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('BOLL'),
                          onPressed: () {
                            switchIndex("BOLL");
                            if (mounted) setState(() {});
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('PUBU'),
                          onPressed: () {
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
                  leading: Icon(
                    FluentIcons.accept,
                    color: showPanKou ? Colors.green : Colors.transparent,
                  ),
                  onPressed: () {
                    showPanKou = !showPanKou;
                    if (mounted) setState(() {});
                    if (!isDrawTime) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        setOHLCData(mOHLCData);
                      });
                    }
                  },
                ),
                MenuFlyoutSubItem(
                  text: const Text('周期切换'),
                  leading: const Icon(
                    FluentIcons.accept,
                    color: Colors.transparent,
                  ),
                  items: (context) => [
                    MenuFlyoutItem(
                      text: const Text('日线'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 1 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day);
                        switchPeriod(fs, index: 1);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('周线'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 2 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "周", period: KTime.WEEK, cusType: 1, kpFlag: KPFlag.Week);
                        switchPeriod(fs, index: 2);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('月线'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 3 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "月", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Month);
                        switchPeriod(fs, index: 3);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('年线'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 4 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "年", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Year);
                        switchPeriod(fs, index: 4);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('任意天'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 5 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        themeController.selectCommandBarIndex.value = 5;
                        KPFlag mKPFlag = KPFlag(name: "日", flag: KPFlag.Day, max: 365);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return PeriodDialog().showPeriodDialog(mKPFlag, "天");
                            });
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('1分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 6 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "1分钟", period: KTime.M_1, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 6);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('3分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 7 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "3分钟", period: KTime.M_3, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 7);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('5分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 8 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "5分钟", period: KTime.M_5, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 8);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('10分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 9 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "10分钟", period: KTime.M_10, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 9);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('15分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 10 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "15分钟", period: KTime.M_15, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 10);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('30分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 11 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "30分钟", period: KTime.M_30, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 11);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('60分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 12 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "1小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour);
                        switchPeriod(fs, index: 12);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('120分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 13 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "2小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour);
                        switchPeriod(fs, index: 13);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('任意分'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 14 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        themeController.selectCommandBarIndex.value = 14;
                        KPFlag mKPFlag = KPFlag(name: "分钟", flag: KPFlag.Minute, max: 1440);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return PeriodDialog().showPeriodDialog(mKPFlag, "分钟");
                            });
                      },
                    ),
                  ],
                ),
                MenuFlyoutItem(
                  text: const Text('画线下单'),
                  onPressed: () async {
                    if (LoginServer.isLogin) {
                      await rustDeskWinManager.newDrawOrder("drawOrder");
                    } else {
                      InfoBarUtils.showInfoDialog("当前用户未登录，请登录后重试");
                    }
                  },
                ),
                MenuFlyoutItem(
                  text: const Text('最大化'),
                  onPressed: Flyout.of(context).close,
                ),
                if (themeController.selectIndex.value == 0)
                  MenuFlyoutItem(
                    text: const Text('取消分屏'),
                    onPressed: () async {
                      themeController.multiScreen.value = 1;
                      logic.cancelMultiScreen();
                    },
                  ),
                if (themeController.selectIndex.value == 0)
                  MenuFlyoutItem(
                    text: const Text('二分屏'),
                    onPressed: () async {
                      themeController.multiScreen.value = 2;
                      EventBusUtil.getInstance().fire(SplitScreen(2));
                    },
                  ),
                if (themeController.selectIndex.value == 0)
                  MenuFlyoutItem(
                    text: const Text('四分屏'),
                    onPressed: () async {
                      themeController.multiScreen.value = 4;
                      EventBusUtil.getInstance().fire(SplitScreen(4));
                    },
                  ),
                if (themeController.selectIndex.value == 0)
                  MenuFlyoutItem(
                    text: const Text('六分屏'),
                    onPressed: () async {
                      themeController.multiScreen.value = 6;
                      EventBusUtil.getInstance().fire(SplitScreen(6));
                    },
                  ),
                if (themeController.selectIndex.value == 0)
                  MenuFlyoutItem(
                    text: const Text('九分屏'),
                    onPressed: () async {
                      themeController.multiScreen.value = 9;
                      EventBusUtil.getInstance().fire(SplitScreen(9));
                    },
                  ),
              ]);
            },
          );
        },
        child: FlyoutTarget(
            controller: contextController,
            key: flyoutTargetKey,
            child: RepaintBoundary(child: LayoutBuilder(builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: painter,
              );
            }))),
      ),
    );
  }

  Widget mainChart() {
    final contextController = FlyoutController();
    final flyoutTargetKey = GlobalKey();
    return Listener(
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
        onPointerDown: (e) async {
          if (isDrawTime || e.buttons == kSecondaryMouseButton) return;
          String name = "${contract?.exCode}${contract?.code}${contract?.comType}";
          if (delOrderLines) {
            if (selectedLine != -1) {
              await ConditionServer.delCondition(drawOrderLines[selectedLine].id ?? 0).then((value) {
                if (value) {
                  qryCondition();
                }
              });
              selectedLine = -1;
              cursor = SystemMouseCursors.basic;
              delOrderLines = false;
            }
          } else if (orderDrawing) {
            // if (orderDrawType == 3 && holdOrder.isEmpty) {
            //   InfoBarUtils.showWarningDialog("指定合约没有持仓，不能平仓");
            //   orderDrawing = false;
            //   await DesktopMultiWindow.invokeMethod(dOrderWindowId ?? 1, drawDoneEvent, "");
            //   return;
            // }
            orderDrawing = false;
            await DesktopMultiWindow.invokeMethod(dOrderWindowId ?? 1, drawDoneEvent, "");
            double kPrice = calculatePrice(e.localPosition.dy, painter);
            CustomLine cus = CustomLine(code: name, type: orderDrawType, num: num, price: price, lineY: e.localPosition.dy, kPrice: kPrice);
            if (orderDrawType == 3) {
              cus.side = holdOrder.first.orderSide == SideType.SIDE_SELL ? SideType.SIDE_BUY : SideType.SIDE_SELL;
            }
            await ConditionServer.addCondition(
              contract?.exCode,
              contract?.subComCode,
              contract?.comType,
              contract?.code,
              Order_Type.ORDER_TYPE_MARKET, //下单类型:市价/限价
              2, //永久有效
              "",
              (orderDrawType == 1 || (orderDrawType == 3 && holdOrder.first.orderSide == SideType.SIDE_SELL))
                  ? SideType.SIDE_BUY
                  : SideType.SIDE_SELL,
              kPrice,
              num,
              orderDrawType == 3 ? PositionEffectType.PositionEffect_COVER : PositionEffectType.PositionEffect_OPEN,
              1, //触发价格["最新价", "买价", "卖价"]
              ((orderDrawType == 3 && holdOrder.isEmpty) || orderDrawType == 1) ? 1 : 2, //条件类型1>=;2<=
              kPrice, //触发价
            ).then((value) async {
              if (value) {
                InfoBarUtils.showSuccessBar("画线下单成功");
                qryCondition();
                // qryCondition(0);
                // drawOrderLines.add(cus);
                // List temp = drawOrderLines.map((e) => e.toJson()).toList();
                // String tmp = jsonEncode({"${UserUtils.currentUser?.id ?? ""}$name": temp});
                // await SpUtils.set(SpKey.drawLines, tmp);
              }
            });
          } else if (startDrawTool) {
            double firstPointY = calculatePrice(e.localPosition.dy, painter);
            int index = calculateIndex(e.localPosition.dx);
            String firstPointX = "${mOHLCData[index].date} ${mOHLCData[index].time}";
            String randomId = uuid.v4();
            DrawToolLine tmpDrawToolLine = DrawToolLine(
                id: randomId,
                period: kPeriod.name,
                pathType: pathType,
                colorValue: colorValue,
                widthType: widthType,
                lineType: lineType,
                firstPointX: firstPointX,
                firstPointY: firstPointY);
            startDrawTool = false;
            drawToolLines.add(tmpDrawToolLine);
            if (pathType == 3 || pathType == 4 || pathType == 16 || pathType == 17) {
              await DesktopMultiWindow.invokeMethod(drawToolWindowId ?? 1, drawDoneEvent, "");
              List temp = drawToolLines.map((e) => e.toJson()).toList();
              String tmp = jsonEncode({"${UserUtils.currentUser?.id ?? ""}${contract?.exCode}${contract?.code}${contract?.comType}": temp});
              await SpUtils.set(SpKey.drawToolLines, tmp);
            } else {
              drawTooling = true;
            }
          } else if (drawTooling) {
            drawTooling = false;
            if (pathType == 1 ||
                pathType == 2 ||
                pathType == 5 ||
                pathType == 8 ||
                pathType == 10 ||
                pathType == 11 ||
                pathType == 12 ||
                pathType == 13 ||
                pathType == 14 ||
                pathType == 15 ||
                pathType == 18) {
              await DesktopMultiWindow.invokeMethod(drawToolWindowId ?? 1, drawDoneEvent, "");
              List temp = drawToolLines.map((e) => e.toJson()).toList();
              String tmp = jsonEncode({"${UserUtils.currentUser?.id ?? ""}${contract?.exCode}${contract?.code}${contract?.comType}": temp});
              await SpUtils.set(SpKey.drawToolLines, tmp);
            } else if (pathType == 6 || pathType == 7 || pathType == 9) {
              drawToolEnd = true;
            }
          } else if (drawToolEnd) {
            drawToolEnd = false;
            await DesktopMultiWindow.invokeMethod(drawToolWindowId ?? 1, drawDoneEvent, "");
            List temp = drawToolLines.map((e) => e.toJson()).toList();
            String tmp = jsonEncode({"${UserUtils.currentUser?.id ?? ""}${contract?.exCode}${contract?.code}${contract?.comType}": temp});
            await SpUtils.set(SpKey.drawToolLines, tmp);
          }
          if (mounted) setState(() {});
        },
        onPointerHover: (e) {
          if (isDrawCrossLine) {
            hoverIndex = -1;
            currentX = e.localPosition.dx;
            currentY = e.localPosition.dy;
          } else if (!isDrawTime) {
            if (!orderDrawing && !startDrawTool) {
              if (drawTooling && drawToolLines.isNotEmpty) {
                double secondPointY = calculatePrice(e.localPosition.dy, painter);
                int index = calculateIndex(e.localPosition.dx);
                String secondPointX = "${mOHLCData[index].date} ${mOHLCData[index].time}";
                drawToolLines.last.secondPointX = secondPointX;
                drawToolLines.last.secondPointY = secondPointY;
              } else if (drawToolEnd && drawToolLines.isNotEmpty) {
                double thirdPointY = calculatePrice(e.localPosition.dy, painter);
                int index = calculateIndex(e.localPosition.dx);
                String thirdPointX = "${mOHLCData[index].date} ${mOHLCData[index].time}";
                drawToolLines.last.thirdPointX = thirdPointX;
                drawToolLines.last.thirdPointY = thirdPointY;
              } else {
                if (drawOrderLines.isNotEmpty) {
                  for (var element in drawOrderLines) {
                    if (element.path != null && _checkHit(element.path!, e.localPosition)) {
                      element.color = Colors.red;
                      cursor = SystemMouseCursors.click;
                      selectedLine = drawOrderLines.indexOf(element);
                      break;
                    }
                    element.color = Colors.white;
                    cursor = SystemMouseCursors.basic;
                    selectedLine = -1;
                  }
                }
                if (drawToolLines.isNotEmpty && selectedLine == -1) {
                  for (var i in drawToolLines) {
                    if (i.firstPointX != null && i.firstPointY != null) {
                      double x = dateTOX(i.firstPointX!);
                      double y = priceTOY(i.firstPointY!, painter);
                      if (_checkHitPoint(x, y, e.localPosition)) {
                        selectedIndex = drawToolLines.indexOf(i);
                        selectedPoint = 1;
                        i.selected = true;
                        cursor = SystemMouseCursors.click;
                        break;
                      }
                    }
                    if (i.secondPointX != null && i.secondPointY != null) {
                      double x = dateTOX(i.secondPointX!);
                      double y = priceTOY(i.secondPointY!, painter);
                      if (_checkHitPoint(x, y, e.localPosition)) {
                        selectedIndex = drawToolLines.indexOf(i);
                        selectedPoint = 2;
                        i.selected = true;
                        cursor = SystemMouseCursors.click;
                        break;
                      }
                    }
                    if (i.thirdPointX != null && i.thirdPointY != null) {
                      double x = dateTOX(i.thirdPointX!);
                      double y = priceTOY(i.thirdPointY!, painter);
                      if (_checkHitPoint(x, y, e.localPosition)) {
                        selectedIndex = drawToolLines.indexOf(i);
                        selectedPoint = 3;
                        i.selected = true;
                        cursor = SystemMouseCursors.click;
                        break;
                      }
                    }
                    selectedPoint = -1;
                    if (i.path != null && _checkHit(i.path!, e.localPosition)) {
                      cursor = SystemMouseCursors.click;
                      selectedIndex = drawToolLines.indexOf(i);
                      startMovingPoint = e.localPosition;
                      i.selected = true;
                      initPointX1 = i.firstPointX;
                      initPointX2 = i.secondPointX;
                      initPointX3 = i.thirdPointX;
                      initPointY1 = i.firstPointY;
                      initPointY2 = i.secondPointY;
                      initPointY3 = i.thirdPointY;
                      break;
                    }
                    i.selected = false;
                    cursor = SystemMouseCursors.basic;
                    selectedIndex = -1;
                    startMovingPoint = null;
                    initPointX1 = null;
                    initPointX2 = null;
                    initPointX3 = null;
                    initPointY1 = null;
                    initPointY2 = null;
                    initPointY3 = null;
                  }
                }
                if (pLRecordList.isNotEmpty && selectedLine == -1 && selectedPoint == -1 && selectedIndex == -1) {
                  for (var element in pLRecordList) {
                    if (element.path != null && _checkHit(element.path!, e.localPosition)) {
                      element.selected = true;
                      cursor = SystemMouseCursors.click;
                      selectedPLLine = pLRecordList.indexOf(element);
                      break;
                    }
                    element.selected = false;
                    cursor = SystemMouseCursors.basic;
                    selectedPLLine = -1;
                  }
                }
              }
            }
          }
          if (mounted) setState(() {});
        },
        onPointerMove: (e) {
          if (isDrawTime || orderDrawing || startDrawTool || drawToolEnd || drawTooling) {
            return;
          }
          if (selectedLine != -1) {
            drawOrderLines[selectedLine].kPrice = null;
            drawOrderLines[selectedLine].lineY = e.localPosition.dy;
          } else if (selectedIndex != -1) {
            if (selectedPoint == 1) {
              int index = calculateIndex(e.localPosition.dx);
              if (index < 0) return;
              drawToolLines[selectedIndex].firstPointX = "${mOHLCData[index].date} ${mOHLCData[index].time}";
              drawToolLines[selectedIndex].firstPointY = calculatePrice(e.localPosition.dy, painter);
            } else if (selectedPoint == 2) {
              int index = calculateIndex(e.localPosition.dx);
              if (index < 0) return;
              drawToolLines[selectedIndex].secondPointX = "${mOHLCData[index].date} ${mOHLCData[index].time}";
              drawToolLines[selectedIndex].secondPointY = calculatePrice(e.localPosition.dy, painter);
            } else if (selectedPoint == 3) {
              int index = calculateIndex(e.localPosition.dx);
              if (index < 0) return;
              drawToolLines[selectedIndex].thirdPointX = "${mOHLCData[index].date} ${mOHLCData[index].time}";
              drawToolLines[selectedIndex].thirdPointY = calculatePrice(e.localPosition.dy, painter);
            } else if (startMovingPoint != null && initPointX1 != null && initPointY1 != null) {
              int index = calculateIndex(dateTOX(initPointX1!)) + calculateIndex(e.localPosition.dx) - calculateIndex(startMovingPoint!.dx);
              if (index < 0) return;
              drawToolLines[selectedIndex].firstPointX = "${mOHLCData[index].date} ${mOHLCData[index].time}";
              drawToolLines[selectedIndex].firstPointY =
                  initPointY1! + calculatePrice(e.localPosition.dy, painter) - calculatePrice(startMovingPoint!.dy, painter);
              if (drawToolLines[selectedIndex].secondPointX != null &&
                  drawToolLines[selectedIndex].secondPointY != null &&
                  initPointX2 != null &&
                  initPointY2 != null) {
                int index = calculateIndex(dateTOX(initPointX2!)) + calculateIndex(e.localPosition.dx) - calculateIndex(startMovingPoint!.dx);
                drawToolLines[selectedIndex].secondPointX = "${mOHLCData[index].date} ${mOHLCData[index].time}";
                drawToolLines[selectedIndex].secondPointY =
                    initPointY2! + calculatePrice(e.localPosition.dy, painter) - calculatePrice(startMovingPoint!.dy, painter);
                if (drawToolLines[selectedIndex].thirdPointX != null &&
                    drawToolLines[selectedIndex].thirdPointY != null &&
                    initPointX3 != null &&
                    initPointY3 != null) {
                  int index = calculateIndex(dateTOX(initPointX3!)) + calculateIndex(e.localPosition.dx) - calculateIndex(startMovingPoint!.dx);
                  drawToolLines[selectedIndex].thirdPointX = "${mOHLCData[index].date} ${mOHLCData[index].time}";
                  drawToolLines[selectedIndex].thirdPointY =
                      initPointY3! + calculatePrice(e.localPosition.dy, painter) - calculatePrice(startMovingPoint!.dy, painter);
                }
              }
            }
          } else if (selectedPLLine != -1) {
            pLRecordList[selectedPLLine].price = null;
            pLRecordList[selectedPLLine].lineY = e.localPosition.dy;
          }
          if (mounted) setState(() {});
        },
        onPointerUp: (e) async {
          if (selectedPLLine != -1) {
            modifyPLRecord();
          } else if (selectedLine != -1) {
            await ConditionServer.updateCondition(
              drawOrderLines[selectedLine].id,
              drawOrderLines[selectedLine].orderType!,
              drawOrderLines[selectedLine].timeInForce!,
              drawOrderLines[selectedLine].expireTime!,
              drawOrderLines[selectedLine].orderSide!,
              drawOrderLines[selectedLine].orderPrice!,
              drawOrderLines[selectedLine].orderQty!,
              drawOrderLines[selectedLine].positionEffect!,
              drawOrderLines[selectedLine].priceType!,
              drawOrderLines[selectedLine].conditionType!,
              drawOrderLines[selectedLine].conditionPrice!,
            ).then((value) {
              if (value) qryCondition();
            });
          }
        },
        child: MouseRegion(
            cursor: cursor,
            child: GestureDetector(
              onSecondaryTapUp: (d) {
                delOrderLines = false;
                final targetContext = flyoutTargetKey.currentContext;
                if (targetContext == null) return;
                final box = targetContext.findRenderObject() as RenderBox;
                final position = box.localToGlobal(
                  d.localPosition,
                  ancestor: Navigator.of(context).context.findRenderObject(),
                );
                if (cursor == SystemMouseCursors.click) {
                  // if (selectedLine != -1) {
                  //   contextController.showFlyout(
                  //     barrierColor: Colors.black.withOpacity(0.1),
                  //     position: position,
                  //     builder: (context) {
                  //       return MenuFlyout(items: [
                  //         MenuFlyoutItem(
                  //           text: const Text('画线属性'),
                  //           onPressed: () {
                  //             CustomLine customLine = drawOrderLines[selectedLine].copyWith();
                  //             showDialog(
                  //                 context: context,
                  //                 builder: (BuildContext context) {
                  //                   return LineDialog().showLineDialog(customLine, contract?.code ?? "--", function: () async {
                  //                     drawOrderLines[selectedLine] = customLine;
                  //                     if (mounted) setState(() {});
                  //                   });
                  //                 });
                  //           },
                  //         ),
                  //         MenuFlyoutItem(
                  //             text: const Text('删除画线'),
                  //             onPressed: () async {
                  //               await ConditionServer.delCondition(drawOrderLines[selectedLine].id ?? 0).then((value) {
                  //                 if (value) {
                  //                   qryCondition();
                  //                 }
                  //               });
                  //               selectedLine = -1;
                  //               cursor = SystemMouseCursors.basic;
                  //               if (mounted) setState(() {});
                  //             }),
                  //         MenuFlyoutItem(
                  //             text: const Text('全部删除'),
                  //             onPressed: () async {
                  //               selectedLine = -1;
                  //               cursor = SystemMouseCursors.basic;
                  //               for (var e in drawOrderLines) {
                  //                 await ConditionServer.delCondition(e.id ?? 0).then((value) {
                  //                   if (value) {
                  //                     qryCondition();
                  //                   }
                  //                 });
                  //               }
                  //               if (mounted) setState(() {});
                  //             }),
                  //       ]);
                  //     },
                  //   );
                  //   return;
                  // } else
                  if (selectedIndex != -1) {
                    contextController.showFlyout(
                      barrierColor: Colors.black.withOpacity(0.1),
                      position: position,
                      builder: (context) {
                        return MenuFlyout(items: [
                          // MenuFlyoutItem(
                          //   text: const Text('画线属性'),
                          //   onPressed: () async {
                          //     DrawToolLine drawToolLine = drawToolLines[selectedIndex].copyWith();
                          //     String tmp = jsonEncode(drawToolLine.toJson());
                          //     await rustDeskWinManager.newLineSetting("newLineSetting", hold: tmp);
                          //   },
                          // ),
                          MenuFlyoutItem(
                              text: const Text('删除画线'),
                              onPressed: () async {
                                drawToolLines.removeAt(selectedIndex);
                                selectedIndex = -1;
                                cursor = SystemMouseCursors.basic;
                                List temp = drawToolLines.map((e) => e.toJson()).toList();
                                String tmp =
                                    jsonEncode({"${UserUtils.currentUser?.id ?? ""}${contract?.exCode}${contract?.code}${contract?.comType}": temp});
                                await SpUtils.set(SpKey.drawToolLines, tmp);
                                if (mounted) setState(() {});
                              }),
                          MenuFlyoutItem(
                              text: const Text('全部删除'),
                              onPressed: () async {
                                drawToolLines.clear();
                                selectedIndex = -1;
                                cursor = SystemMouseCursors.basic;
                                List temp = drawToolLines.map((e) => e.toJson()).toList();
                                String tmp =
                                    jsonEncode({"${UserUtils.currentUser?.id ?? ""}${contract?.exCode}${contract?.code}${contract?.comType}": temp});
                                await SpUtils.set(SpKey.drawToolLines, tmp);
                                if (mounted) setState(() {});
                              }),
                        ]);
                      },
                    );
                    return;
                  }
                }
                contextController.showFlyout(
                  barrierColor: Colors.black.withOpacity(0.1),
                  position: position,
                  builder: (context) {
                    return MenuFlyout(items: [
                      MenuFlyoutItem(
                        text: const Text('下单'),
                        onPressed: () {
                          EventBusUtil.getInstance().fire(LoginEvent());
                          Flyout.of(context).close();
                        },
                      ),
                      MenuFlyoutSubItem(
                          text: const Text('加入自选'),
                          leading: const Icon(
                            FluentIcons.accept,
                            color: Colors.transparent,
                          ),
                          items: (context) => logic.sectorList
                              .map((e) => MenuFlyoutItem(
                                    text: Text(e.name ?? "--"),
                                    onPressed: () {
                                      EventBusUtil.getInstance().fire(AddOptionEvent(e, logic.selectedContractList[widget.index], true));
                                    },
                                  ))
                              .toList()),
                      // MenuFlyoutItem(
                      //     text: const Text('移除自选'),
                      //     onPressed: () {
                      //       logic.optionOperate(logic.selectedContractList[widget.index], add: false);
                      //       Flyout.of(context).close();
                      //     }),
                      MenuFlyoutSubItem(
                        text: const Text('切换画面'),
                        leading: const Icon(
                          FluentIcons.accept,
                          color: Colors.transparent,
                        ),
                        items: (context) => [
                          MenuFlyoutItem(
                              text: const Text('报价页面'),
                              onPressed: () {
                                logic.viewIndexList[widget.index] = 0;
                                Flyout.of(context).close();
                              }),
                          isDrawTime
                              ? MenuFlyoutItem(
                                  text: const Text('K线'),
                                  onPressed: () {
                                    KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day);
                                    logic.showChartList[widget.index] = 0;
                                    switchPeriod(fs, index: 1);
                                  })
                              : MenuFlyoutItem(
                                  text: const Text('分时'),
                                  onPressed: () {
                                    KPeriod fs = KPeriod(name: "分时", period: KTime.FS, cusType: 1, kpFlag: KPFlag.Minute);
                                    switchPeriod(fs, index: 0);
                                  }),
                          if (!isDrawTime)
                            MenuFlyoutItem(
                              text: const Text('成交报表'),
                              onPressed: () {
                                logic.showChartList[widget.index] = 1;
                              },
                            ),
                        ],
                      ),
                      MenuFlyoutSubItem(
                        text: const Text('技术指标'),
                        leading: const Icon(
                          FluentIcons.accept,
                          color: Colors.transparent,
                        ),
                        items: (context) => [
                          MenuFlyoutSubItem(
                            text: const Text('趋势分析指标（主图）'),
                            items: (_) => [
                              MenuFlyoutItem(
                                text: const Text('MA组合'),
                                onPressed: () {
                                  switchIndex("MA");
                                  if (mounted) setState(() {});
                                },
                              ),
                              MenuFlyoutItem(
                                text: const Text('BOLL'),
                                onPressed: () {
                                  switchIndex("BOLL");
                                  if (mounted) setState(() {});
                                },
                              ),
                              MenuFlyoutItem(
                                text: const Text('PUBU'),
                                onPressed: () {
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
                        leading: Icon(
                          FluentIcons.accept,
                          color: showPanKou ? Colors.green : Colors.transparent,
                        ),
                        onPressed: () {
                          showPanKou = !showPanKou;
                          if (mounted) setState(() {});
                          if (!isDrawTime) {
                            Future.delayed(const Duration(milliseconds: 500), () {
                              setOHLCData(mOHLCData);
                            });
                          }
                        },
                      ),
                      MenuFlyoutItem(
                        text: const Text('增加副图'),
                        onPressed: () {
                          if (multiSplitViewController.areasCount > 4) {
                            InfoBarUtils.showWarningDialog("分析区域不能超过5个");
                          } else {
                            int count = multiSplitViewController.areasCount;
                            subChartList.add(count);
                            int length = subChartList.length - 1;
                            multiSplitViewController.addArea(Area(builder: (context, area) => subChart(length, area.id)));
                            if (mounted) setState(() {});
                          }
                        },
                      ),
                      MenuFlyoutSubItem(
                        text: const Text('周期切换'),
                        leading: const Icon(
                          FluentIcons.accept,
                          color: Colors.transparent,
                        ),
                        items: (context) => [
                          MenuFlyoutItem(
                            text: const Text('日线'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 1 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day);
                              switchPeriod(fs, index: 1);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('周线'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 2 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "周", period: KTime.WEEK, cusType: 1, kpFlag: KPFlag.Week);
                              switchPeriod(fs, index: 2);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('月线'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 3 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "月", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Month);
                              switchPeriod(fs, index: 3);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('年线'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 4 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "年", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Year);
                              switchPeriod(fs, index: 4);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('任意天'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 5 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              themeController.selectCommandBarIndex.value = 5;
                              KPFlag mKPFlag = KPFlag(name: "日", flag: KPFlag.Day, max: 365);
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PeriodDialog().showPeriodDialog(mKPFlag, "天");
                                  });
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('1分钟'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 6 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "1分钟", period: KTime.M_1, cusType: 1, kpFlag: KPFlag.Minute);
                              switchPeriod(fs, index: 6);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('3分钟'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 7 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "3分钟", period: KTime.M_3, cusType: 1, kpFlag: KPFlag.Minute);
                              switchPeriod(fs, index: 7);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('5分钟'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 8 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "5分钟", period: KTime.M_5, cusType: 1, kpFlag: KPFlag.Minute);
                              switchPeriod(fs, index: 8);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('10分钟'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 9 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "10分钟", period: KTime.M_10, cusType: 1, kpFlag: KPFlag.Minute);
                              switchPeriod(fs, index: 9);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('15分钟'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 10 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "15分钟", period: KTime.M_15, cusType: 1, kpFlag: KPFlag.Minute);
                              switchPeriod(fs, index: 10);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('30分钟'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 11 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "30分钟", period: KTime.M_30, cusType: 1, kpFlag: KPFlag.Minute);
                              switchPeriod(fs, index: 11);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('60分钟'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 12 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "1小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour);
                              switchPeriod(fs, index: 12);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('120分钟'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 13 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "2小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour);
                              switchPeriod(fs, index: 13);
                            },
                          ),
                          MenuFlyoutItem(
                            text: const Text('任意分'),
                            leading: Icon(
                              FluentIcons.radio_btn_on,
                              color: themeController.selectCommandBarIndex.value == 14 ? Colors.white : Colors.transparent,
                            ),
                            onPressed: () {
                              themeController.selectCommandBarIndex.value = 14;
                              KPFlag mKPFlag = KPFlag(name: "分钟", flag: KPFlag.Minute, max: 1440);
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PeriodDialog().showPeriodDialog(mKPFlag, "分钟");
                                  });
                            },
                          ),
                        ],
                      ),
                      MenuFlyoutItem(
                        text: const Text('画线下单'),
                        onPressed: () async {
                          if (LoginServer.isLogin) {
                            await rustDeskWinManager.newDrawOrder("drawOrder");
                          } else {
                            InfoBarUtils.showInfoDialog("当前用户未登录，请登录后重试");
                          }
                        },
                      ),
                      MenuFlyoutItem(
                        text: const Text('最大化'),
                        onPressed: Flyout.of(context).close,
                      ),
                      if (themeController.selectIndex.value == 0)
                        MenuFlyoutItem(
                          text: const Text('取消分屏'),
                          onPressed: () async {
                            themeController.multiScreen.value = 1;
                            logic.cancelMultiScreen();
                          },
                        ),
                      if (themeController.selectIndex.value == 0)
                        MenuFlyoutItem(
                          text: const Text('二分屏'),
                          onPressed: () async {
                            themeController.multiScreen.value = 2;
                            EventBusUtil.getInstance().fire(SplitScreen(2));
                          },
                        ),
                      if (themeController.selectIndex.value == 0)
                        MenuFlyoutItem(
                          text: const Text('四分屏'),
                          onPressed: () async {
                            themeController.multiScreen.value = 4;
                            EventBusUtil.getInstance().fire(SplitScreen(4));
                          },
                        ),
                      if (themeController.selectIndex.value == 0)
                        MenuFlyoutItem(
                          text: const Text('六分屏'),
                          onPressed: () async {
                            themeController.multiScreen.value = 6;
                            EventBusUtil.getInstance().fire(SplitScreen(6));
                          },
                        ),
                      if (themeController.selectIndex.value == 0)
                        MenuFlyoutItem(
                          text: const Text('九分屏'),
                          onPressed: () async {
                            themeController.multiScreen.value = 9;
                            EventBusUtil.getInstance().fire(SplitScreen(9));
                          },
                        ),
                    ]);
                  },
                );
              },
              child: Stack(
                children: [
                  FlyoutTarget(
                    controller: contextController,
                    key: flyoutTargetKey,
                    child: ClipRect(
                      child: RepaintBoundary(child: LayoutBuilder(builder: (context, constraints) {
                        return CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: painter,
                        );
                      })),
                    ),
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
                                        switchIndex("MA");
                                        if (mounted) setState(() {});
                                      },
                                    ),
                                    MenuFlyoutItem(
                                      text: const Text('BOLL'),
                                      onPressed: () {
                                        switchIndex("BOLL");
                                        if (mounted) setState(() {});
                                      },
                                    ),
                                    MenuFlyoutItem(
                                      text: const Text('PUBU'),
                                      onPressed: () {
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
                            }),
                      )),
                ],
              ),
            )));
  }

  Widget subChart(int index, dynamic id) {
    int value = subChartList[index];
    final paint = SubChartPainter(
      mDataStartIndext: mDataStartIndext,
      mShowDataNum: mShowDataNum,
      mCandleWidth: mCandleWidth,
      isDrawVOL: value == 1 ? true : false,
      isDrawMACD: value == 2 ? true : false,
      isDrawKDJ: value == 3 ? true : false,
      isDrawRSI: value == 4 ? true : false,
      isDrawVR: value == 5 ? true : false,
      isDrawCCI: value == 6 ? true : false,
      isDrawBIAS: value == 7 ? true : false,
      isDrawOBV: value == 8 ? true : false,
      isDrawWR: value == 9 ? true : false,
      isDrawDMA: value == 10 ? true : false,
      isDrawPSY: value == 11 ? true : false,
      isDrawMACDBANG: value == 12 ? true : false,
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
      currentX: currentX,
      currentY: currentY,
      hoverIndex: hoverIndex,
      index: index,
      isDrawCrossLine: isDrawCrossLine,
      mKPeriod: kPeriod,
    );
    final contextController = FlyoutController();
    final menuController = FlyoutController();
    final flyoutTargetKey = GlobalKey();
    return Listener(
        onPointerHover: (e) {
          if (isDrawCrossLine) {
            hoverIndex = index;
            currentX = e.localPosition.dx;
            currentY = e.localPosition.dy;
            if (mounted) setState(() {});
          }
        },
        child: GestureDetector(
            onSecondaryTapUp: (d) {
              final targetContext = flyoutTargetKey.currentContext;
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
                      onPressed: () {
                        EventBusUtil.getInstance().fire(LoginEvent());
                        Flyout.of(context).close();
                      },
                    ),
                    MenuFlyoutSubItem(
                        text: const Text('加入自选'),
                        leading: const Icon(
                          FluentIcons.accept,
                          color: Colors.transparent,
                        ),
                        items: (context) => logic.sectorList
                            .map((e) => MenuFlyoutItem(
                                  text: Text(e.name ?? "--"),
                                  onPressed: () {
                                    EventBusUtil.getInstance().fire(AddOptionEvent(e, logic.selectedContractList[widget.index], true));
                                  },
                                ))
                            .toList()),
                    // MenuFlyoutItem(
                    //     text: const Text('移除自选'),
                    //     onPressed: () {
                    //       logic.optionOperate(logic.selectedContractList[widget.index], add: false);
                    //       Flyout.of(context).close();
                    //     }),
                    MenuFlyoutSubItem(
                      text: const Text('切换画面'),
                      leading: const Icon(
                        FluentIcons.accept,
                        color: Colors.transparent,
                      ),
                      items: (context) => [
                        MenuFlyoutItem(
                            text: const Text('报价页面'),
                            onPressed: () {
                              logic.viewIndexList[widget.index] = 0;
                              Flyout.of(context).close();
                            }),
                        isDrawTime
                            ? MenuFlyoutItem(
                                text: const Text('K线'),
                                onPressed: () {
                                  KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day);
                                  logic.showChartList[widget.index] = 0;
                                  switchPeriod(fs, index: 1);
                                })
                            : MenuFlyoutItem(
                                text: const Text('分时'),
                                onPressed: () {
                                  KPeriod fs = KPeriod(name: "分时", period: KTime.FS, cusType: 1, kpFlag: KPFlag.Minute);
                                  switchPeriod(fs, index: 0);
                                }),
                        if (!isDrawTime)
                          MenuFlyoutItem(
                            text: const Text('成交报表'),
                            onPressed: () {
                              logic.showChartList[widget.index] = 1;
                            },
                          ),
                      ],
                    ),
                    MenuFlyoutSubItem(
                      text: const Text('技术指标'),
                      leading: const Icon(
                        FluentIcons.accept,
                        color: Colors.transparent,
                      ),
                      items: (context) => [
                        MenuFlyoutSubItem(
                          text: const Text('趋势分析指标（主图）'),
                          items: (_) => [
                            MenuFlyoutItem(
                              text: const Text('MA组合'),
                              onPressed: () {
                                switchIndex("MA");
                                if (mounted) setState(() {});
                              },
                            ),
                            MenuFlyoutItem(
                              text: const Text('BOLL'),
                              onPressed: () {
                                switchIndex("BOLL");
                                if (mounted) setState(() {});
                              },
                            ),
                            MenuFlyoutItem(
                              text: const Text('PUBU'),
                              onPressed: () {
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
                      leading: Icon(
                        FluentIcons.accept,
                        color: showPanKou ? Colors.green : Colors.transparent,
                      ),
                      onPressed: () {
                        showPanKou = !showPanKou;
                        if (mounted) setState(() {});
                        if (!isDrawTime) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            setOHLCData(mOHLCData);
                          });
                        }
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('增加副图'),
                      onPressed: () {
                        if (multiSplitViewController.areasCount > 4) {
                          InfoBarUtils.showWarningDialog("分析区域不能超过5个");
                        } else {
                          int count = multiSplitViewController.areasCount;
                          subChartList.add(count);
                          int length = subChartList.length - 1;
                          multiSplitViewController.addArea(Area(builder: (context, area) => subChart(length, area.id)));
                          if (mounted) setState(() {});
                        }
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('删除副图'),
                      onPressed: () {
                        for (int i = 0; i < multiSplitViewController.areasCount; i++) {
                          if (multiSplitViewController.getArea(i).id == id) {
                            multiSplitViewController.removeAreaAt(i);
                            return;
                          }
                        }
                        if (mounted) setState(() {});
                      },
                    ),
                    MenuFlyoutSubItem(
                      text: const Text('周期切换'),
                      leading: const Icon(
                        FluentIcons.accept,
                        color: Colors.transparent,
                      ),
                      items: (context) => [
                        MenuFlyoutItem(
                          text: const Text('日线'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 1 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day);
                            switchPeriod(fs, index: 1);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('周线'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 2 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "周", period: KTime.WEEK, cusType: 1, kpFlag: KPFlag.Week);
                            switchPeriod(fs, index: 2);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('月线'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 3 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "月", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Month);
                            switchPeriod(fs, index: 3);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('年线'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 4 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "年", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Year);
                            switchPeriod(fs, index: 4);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('任意天'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 5 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            themeController.selectCommandBarIndex.value = 5;
                            KPFlag mKPFlag = KPFlag(name: "日", flag: KPFlag.Day, max: 365);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return PeriodDialog().showPeriodDialog(mKPFlag, "天");
                                });
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('1分钟'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 6 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "1分钟", period: KTime.M_1, cusType: 1, kpFlag: KPFlag.Minute);
                            switchPeriod(fs, index: 6);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('3分钟'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 7 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "3分钟", period: KTime.M_3, cusType: 1, kpFlag: KPFlag.Minute);
                            switchPeriod(fs, index: 7);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('5分钟'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 8 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "5分钟", period: KTime.M_5, cusType: 1, kpFlag: KPFlag.Minute);
                            switchPeriod(fs, index: 8);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('10分钟'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 9 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "10分钟", period: KTime.M_10, cusType: 1, kpFlag: KPFlag.Minute);
                            switchPeriod(fs, index: 9);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('15分钟'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 10 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "15分钟", period: KTime.M_15, cusType: 1, kpFlag: KPFlag.Minute);
                            switchPeriod(fs, index: 10);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('30分钟'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 11 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "30分钟", period: KTime.M_30, cusType: 1, kpFlag: KPFlag.Minute);
                            switchPeriod(fs, index: 11);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('60分钟'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 12 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "1小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour);
                            switchPeriod(fs, index: 12);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('120分钟'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 13 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            KPeriod fs = KPeriod(name: "2小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour);
                            switchPeriod(fs, index: 13);
                          },
                        ),
                        MenuFlyoutItem(
                          text: const Text('任意分'),
                          leading: Icon(
                            FluentIcons.radio_btn_on,
                            color: themeController.selectCommandBarIndex.value == 14 ? Colors.white : Colors.transparent,
                          ),
                          onPressed: () {
                            themeController.selectCommandBarIndex.value = 14;
                            KPFlag mKPFlag = KPFlag(name: "分钟", flag: KPFlag.Minute, max: 1440);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return PeriodDialog().showPeriodDialog(mKPFlag, "分钟");
                                });
                          },
                        ),
                      ],
                    ),
                    MenuFlyoutItem(
                      text: const Text('画线下单'),
                      onPressed: () async {
                        if (LoginServer.isLogin) {
                          await rustDeskWinManager.newDrawOrder("drawOrder");
                        } else {
                          InfoBarUtils.showInfoDialog("当前用户未登录，请登录后重试");
                        }
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('最大化'),
                      onPressed: Flyout.of(context).close,
                    ),
                    if (themeController.selectIndex.value == 0)
                      MenuFlyoutItem(
                        text: const Text('取消分屏'),
                        onPressed: () async {
                          themeController.multiScreen.value = 1;
                          logic.cancelMultiScreen();
                        },
                      ),
                    if (themeController.selectIndex.value == 0)
                      MenuFlyoutItem(
                        text: const Text('二分屏'),
                        onPressed: () async {
                          themeController.multiScreen.value = 2;
                          EventBusUtil.getInstance().fire(SplitScreen(2));
                        },
                      ),
                    if (themeController.selectIndex.value == 0)
                      MenuFlyoutItem(
                        text: const Text('四分屏'),
                        onPressed: () async {
                          themeController.multiScreen.value = 4;
                          EventBusUtil.getInstance().fire(SplitScreen(4));
                        },
                      ),
                    if (themeController.selectIndex.value == 0)
                      MenuFlyoutItem(
                        text: const Text('六分屏'),
                        onPressed: () async {
                          themeController.multiScreen.value = 6;
                          EventBusUtil.getInstance().fire(SplitScreen(6));
                        },
                      ),
                    if (themeController.selectIndex.value == 0)
                      MenuFlyoutItem(
                        text: const Text('九分屏'),
                        onPressed: () async {
                          themeController.multiScreen.value = 9;
                          EventBusUtil.getInstance().fire(SplitScreen(9));
                        },
                      ),
                  ]);
                },
              );
            },
            child: Stack(
              children: [
                FlyoutTarget(
                  controller: contextController,
                  key: flyoutTargetKey,
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
                          menuController.showFlyout(
                            autoModeConfiguration: FlyoutAutoConfiguration(
                              preferredMode: FlyoutPlacementMode.topLeft,
                            ),
                            builder: (context) {
                              return MenuFlyout(items: [
                                MenuFlyoutItem(
                                  text: const Text('VOL'),
                                  onPressed: () {
                                    subChartList[index] = 1;
                                    if (mounted) setState(() {});
                                  },
                                ),
                                MenuFlyoutItem(
                                  text: const Text('VR'),
                                  onPressed: () {
                                    subChartList[index] = 5;
                                    if (mounted) setState(() {});
                                  },
                                ),
                                MenuFlyoutItem(
                                  text: const Text('MACD'),
                                  onPressed: () {
                                    subChartList[index] = 2;
                                    if (mounted) setState(() {});
                                  },
                                ),
                                MenuFlyoutItem(
                                  text: const Text('KDJ'),
                                  onPressed: () {
                                    subChartList[index] = 3;
                                    if (mounted) setState(() {});
                                  },
                                ),
                                MenuFlyoutItem(
                                  text: const Text('RSI'),
                                  onPressed: () {
                                    subChartList[index] = 4;
                                    if (mounted) setState(() {});
                                  },
                                ),
                                MenuFlyoutItem(
                                  text: const Text('CCI'),
                                  onPressed: () {
                                    subChartList[index] = 6;
                                    if (mounted) setState(() {});
                                  },
                                ),
                                MenuFlyoutItem(
                                    text: const Text('BIAS'),
                                    onPressed: () {
                                      subChartList[index] = 7;
                                      if (mounted) setState(() {});
                                    }),
                                MenuFlyoutItem(
                                  text: const Text('OBV'),
                                  onPressed: Flyout.of(context).close,
                                ),
                                MenuFlyoutItem(
                                    text: const Text('WR'),
                                    onPressed: () {
                                      subChartList[index] = 9;
                                      if (mounted) setState(() {});
                                    }),
                                MenuFlyoutItem(
                                  text: const Text('DMA'),
                                  onPressed: Flyout.of(context).close,
                                ),
                                MenuFlyoutItem(
                                    text: const Text('PSY'),
                                    onPressed: () {
                                      subChartList[index] = 11;
                                      if (mounted) setState(() {});
                                    }),
                                MenuFlyoutItem(
                                  text: const Text('MACD能量棒'),
                                  onPressed: Flyout.of(context).close,
                                ),
                              ]);
                            },
                          );
                        }),
                  ),
                )
              ],
            )));
  }

  Widget statement() {
    final contextController = FlyoutController();
    final contextAttachKey = GlobalKey();
    return GestureDetector(
        onSecondaryTapUp: (d) {
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
                  onPressed: () {
                    EventBusUtil.getInstance().fire(LoginEvent());
                    Flyout.of(context).close();
                  },
                ),
                MenuFlyoutSubItem(
                    text: const Text('加入自选'),
                    leading: const Icon(
                      FluentIcons.accept,
                      color: Colors.transparent,
                    ),
                    items: (context) => logic.sectorList
                        .map((e) => MenuFlyoutItem(
                              text: Text(e.name ?? "--"),
                              onPressed: () {
                                EventBusUtil.getInstance().fire(AddOptionEvent(e, logic.selectedContractList[widget.index], true));
                              },
                            ))
                        .toList()),
                // MenuFlyoutItem(
                //     text: const Text('移除自选'),
                //     onPressed: () {
                //       logic.optionOperate(logic.selectedContractList[widget.index], add: false);
                //       Flyout.of(context).close();
                //     }),
                MenuFlyoutSubItem(
                  text: const Text('切换画面'),
                  leading: const Icon(
                    FluentIcons.accept,
                    color: Colors.transparent,
                  ),
                  items: (context) => [
                    MenuFlyoutItem(
                        text: const Text('报价页面'),
                        onPressed: () {
                          logic.viewIndexList[widget.index] = 0;
                          Flyout.of(context).close();
                        }),
                    isDrawTime
                        ? MenuFlyoutItem(
                            text: const Text('K线'),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day);
                              logic.showChartList[widget.index] = 0;
                              switchPeriod(fs, index: 1);
                            })
                        : MenuFlyoutItem(
                            text: const Text('分时'),
                            onPressed: () {
                              KPeriod fs = KPeriod(name: "分时", period: KTime.FS, cusType: 1, kpFlag: KPFlag.Minute);
                              switchPeriod(fs, index: 0);
                            }),
                    if (!isDrawTime)
                      MenuFlyoutItem(
                        text: const Text('成交报表'),
                        onPressed: () {
                          logic.showChartList[widget.index] = 1;
                        },
                      ),
                  ],
                ),
                MenuFlyoutItem(
                  text: const Text('显示盘口数据'),
                  leading: Icon(
                    FluentIcons.accept,
                    color: showPanKou ? Colors.green : Colors.transparent,
                  ),
                  onPressed: () {
                    showPanKou = !showPanKou;
                    if (mounted) setState(() {});
                    if (!isDrawTime) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        setOHLCData(mOHLCData);
                      });
                    }
                  },
                ),
                MenuFlyoutSubItem(
                  text: const Text('周期切换'),
                  leading: const Icon(
                    FluentIcons.accept,
                    color: Colors.transparent,
                  ),
                  items: (context) => [
                    MenuFlyoutItem(
                      text: const Text('日线'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 1 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day);
                        switchPeriod(fs, index: 1);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('周线'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 2 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "周", period: KTime.WEEK, cusType: 1, kpFlag: KPFlag.Week);
                        switchPeriod(fs, index: 2);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('月线'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 3 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "月", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Month);
                        switchPeriod(fs, index: 3);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('年线'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 4 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "年", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Year);
                        switchPeriod(fs, index: 4);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('任意天'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 5 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        themeController.selectCommandBarIndex.value = 5;
                        KPFlag mKPFlag = KPFlag(name: "日", flag: KPFlag.Day, max: 365);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return PeriodDialog().showPeriodDialog(mKPFlag, "天");
                            });
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('1分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 6 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "1分钟", period: KTime.M_1, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 6);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('3分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 7 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "3分钟", period: KTime.M_3, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 7);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('5分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 8 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "5分钟", period: KTime.M_5, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 8);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('10分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 9 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "10分钟", period: KTime.M_10, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 9);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('15分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 10 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "15分钟", period: KTime.M_15, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 10);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('30分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 11 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "30分钟", period: KTime.M_30, cusType: 1, kpFlag: KPFlag.Minute);
                        switchPeriod(fs, index: 11);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('60分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 12 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "1小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour);
                        switchPeriod(fs, index: 12);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('120分钟'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 13 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        KPeriod fs = KPeriod(name: "2小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour);
                        switchPeriod(fs, index: 13);
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text('任意分'),
                      leading: Icon(
                        FluentIcons.radio_btn_on,
                        color: themeController.selectCommandBarIndex.value == 14 ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () {
                        themeController.selectCommandBarIndex.value = 14;
                        KPFlag mKPFlag = KPFlag(name: "分钟", flag: KPFlag.Minute, max: 1440);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return PeriodDialog().showPeriodDialog(mKPFlag, "分钟");
                            });
                      },
                    ),
                  ],
                ),
                MenuFlyoutItem(
                  text: const Text('最大化'),
                  onPressed: Flyout.of(context).close,
                ),
                if (themeController.selectIndex.value == 0)
                  MenuFlyoutItem(
                    text: const Text('取消分屏'),
                    onPressed: () async {
                      themeController.multiScreen.value = 1;
                      logic.cancelMultiScreen();
                    },
                  ),
                // MenuFlyoutItem(
                //   text: const Text('四分屏'),
                //   onPressed: () async {
                //     themeController.multiScreen = 1;
                //     EventBusUtil.getInstance().fire(SplitScreen(1));
                //   },
                // ),
                // MenuFlyoutItem(
                //   text: const Text('九分屏'),
                //   onPressed: () async {
                //     themeController.multiScreen = 2;
                //     EventBusUtil.getInstance().fire(SplitScreen(2));
                //   },
                // ),
                // MenuFlyoutItem(
                //   text: const Text('横向分页'),
                //   onPressed: Flyout.of(context).close,
                // ),
                // MenuFlyoutItem(
                //   text: const Text('纵向分页'),
                //   onPressed: Flyout.of(context).close,
                // ),
              ]);
            },
          );
        },
        child: FlyoutTarget(
            key: contextAttachKey,
            controller: contextController,
            child: Column(
              children: [
                Row(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${contract?.name ?? ""}(${contract?.code ?? ""})<${kPeriod.name}线>",
                        style: TextStyle(fontSize: 16, color: themeController.theme.activeColor),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    statementItem("时间", flex: 3),
                    statementItem("开"),
                    statementItem("高"),
                    statementItem("低"),
                    statementItem("收"),
                    statementItem("成交量", flex: 2),
                    statementItem("持仓量", flex: 2),
                    const Spacer(flex: 1)
                  ],
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: mOHLCData.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
                      child: Row(
                        children: [
                          statementChildItem("${mOHLCData[index].date} ${mOHLCData[index].time}", flex: 3),
                          statementColorItem(mOHLCData[index].open, mOHLCData[max(0, index - 1)].close),
                          statementColorItem(mOHLCData[index].high, mOHLCData[max(0, index - 1)].close),
                          statementColorItem(mOHLCData[index].low, mOHLCData[max(0, index - 1)].close),
                          statementColorItem(mOHLCData[index].close, mOHLCData[max(0, index - 1)].close),
                          statementChildItem("${mOHLCData[index].volume ?? 0}", flex: 2),
                          statementChildItem("${mOHLCData[index].amount ?? 0}", flex: 2),
                          const Spacer(flex: 1)
                        ],
                      ),
                    );
                  },
                ))
              ],
            )));
  }

  Widget statementItem(String title, {int? flex}) {
    return Expanded(
        flex: flex ?? 1,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Common.quoteTitleColor, fontSize: 18),
          ),
        ));
  }

  Widget statementChildItem(String? content, {int? flex, Color? color}) {
    return Expanded(
        flex: flex ?? 1,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            content ?? "--",
            textAlign: TextAlign.center,
            style: TextStyle(color: color ?? Colors.white, fontSize: 17),
          ),
        ));
  }

  Widget statementColorItem(double? value, double? lastClose) {
    return Expanded(
        flex: 1,
        child: Text(
          Utils.d2SBySrc(value?.toDouble(), 0.01),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: (value ?? 0) > (lastClose ?? 0)
                  ? Common.quoteHighColor
                  : (value ?? 0) < (lastClose ?? 0)
                      ? Common.quoteLowColor
                      : Colors.white,
              fontSize: 17),
        ));
  }

  Widget dataWidget() {
    return Container(
      // width: 288,
      height: 1.sh,
      margin: EdgeInsets.only(left: 1.sp),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  lastPrice,
                  style: TextStyle(
                      color: pankouUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                IconButton(
                    icon: Image.asset(
                      "assets/images/icon_inf@3x.png",
                      width: Common.iconImageWidth,
                      color: Colors.transparent,
                    ),
                    onPressed: () {}),
                Text(
                  change,
                  style: TextStyle(color: pankouUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor),
                ),
                Text(
                  changePer,
                  style: TextStyle(color: pankouUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: themeController.theme.cardColor,
              ),
              padding: EdgeInsets.fromLTRB(5.sp, 5.sp, 5.sp, 0),
              child: Column(
                children: [
                  priceItem("卖一", "${contract!.level2List?[20].price ?? 0.00}", "${contract!.level2List?[20].volume ?? 0}"),
                  priceItem("买一", "${contract!.level2List?[0].price ?? 0.00}", "${contract!.level2List?[0].volume ?? 0}")
                      .marginSymmetric(vertical: 5.sp),
                  Container(
                    decoration:
                        BoxDecoration(border: Border(top: BorderSide(width: themeController.isDarkMode.value ? 0.8 : 0.2, color: Colors.grey))),
                    alignment: Alignment.center,
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                dataItem(pankouLastPrice, color: pankouUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor),
                                dataItem(pankouChange, color: pankouUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor),
                                dataItem(pankouChangePer, color: pankouUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor),
                                dataItem(pankouAllMarket, color: pankouUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor),
                                dataItem(pankouCirMarket),
                                dataItem(pankouPosition),
                              ],
                            ),
                          ),
                          Container(
                            width: themeController.isDarkMode.value ? 0.8 : 0.2,
                            color: Colors.grey,
                            margin: EdgeInsets.fromLTRB(5.sp, 0, 5.sp, 5.sp),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                dataItem(pankouAvr),
                                dataItem(pankouPresettle, color: pankouUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor),
                                dataItem(pankouOpenprice, color: Colors.white),
                                dataItem(pankouHighprice, color: pankouHighUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor),
                                dataItem(pankouLowprice, color: pankouLowUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor),
                                dataItem(pankouPoor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
                height: 1.sh,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: themeController.theme.cardColor,
                ),
                padding: EdgeInsets.all(4.sp),
                margin: EdgeInsets.only(top: 1.sp),
                child: IntrinsicWidth(
                  child: Column(
                    children: [
                      Text(
                        "分时成交",
                        style: TextStyle(color: themeController.theme.acrylicBackgroundColor, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        color: Colors.grey,
                        height: themeController.isDarkMode.value ? 0.8 : 0.2,
                        margin: EdgeInsets.only(bottom: 1.sp, top: 4.sp),
                      ),
                      Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: quoteFilledData.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                String timeStr = quoteFilledData[index].updateTime.split(" ")[1];
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              timeStr.substring(0, timeStr.indexOf(".")),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: themeController.theme.acrylicBackgroundColor,
                                              ),
                                            ),
                                          )),
                                    ),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          quoteFilledData[index].lastPrice.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: themeController.theme.acrylicBackgroundColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            quoteFilledData[index].volume.toInt().toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: quoteFilledData[index].orderForward == 1
                                                  ? Common.quoteHighColor
                                                  : quoteFilledData[index].orderForward == 2
                                                      ? themeController.theme.focusTheme.glowColor
                                                      : themeController.theme.acrylicBackgroundColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ).marginSymmetric(vertical: 1.sp);
                              })),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget dataItem(String? title, {Color? color, bool? thin}) {
    return Container(
      margin: EdgeInsets.only(top: 3.sp),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(title ?? "-", style: TextStyle(color: color ?? themeController.theme.acrylicBackgroundColor)),
      ),
    );
  }

  Widget priceItem(String title, String price, String count) {
    return Row(children: [
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(title, style: TextStyle(color: themeController.theme.acrylicBackgroundColor))),
        ),
      ),
      Expanded(
        child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(price, style: TextStyle(color: pankouUp ? Common.quoteHighColor : themeController.theme.focusTheme.glowColor))),
      ),
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                count,
                style: TextStyle(color: themeController.theme.acrylicBackgroundColor),
              )),
        ),
      ),
    ]);
  }
}
