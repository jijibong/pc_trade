import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Condition;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:trade/model/user/user.dart';
import 'package:trade/util/event_bus/events.dart';
import '../../config/common.dart';
import '../../config/config.dart';
import '../../main.dart';
import '../../model/broker/broker.dart';
import '../../model/condition/condition.dart';
import '../../model/delegation/comOrder.dart';
import '../../model/delegation/delegateOrder.dart';
import '../../model/delegation/order_state.dart';
import '../../model/delegation/res_comm_order.dart';
import '../../model/position/add_order.dart';
import '../../model/position/position.dart';
import '../../model/quote/commodity.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../../model/quote/order_type.dart';
import '../../model/quote/position_effect_type.dart';
import '../../model/quote/side_type.dart';
import '../../model/quote/time_in_force_type.dart';
import '../../model/socket_packet/operation.dart' as socket_operation;
import '../../model/trade/fund.dart';
import '../../model/trade/hold_order.dart';
import '../../model/trade/margin.dart';
import '../../model/trade/query/capital.dart';
import '../../model/trade/query/close_detail.dart';
import '../../model/trade/query/position_detail.dart';
import '../../model/trade/query/position_summary.dart';
import '../../model/trade/query/transaction_record.dart';
import '../../model/trade/query/withdrawal_record.dart';
import '../../model/trade/res_hold_order.dart';
import '../../server/condition/condition.dart';
import '../../server/delegation/delegation.dart';
import '../../server/delegation/transaction.dart';
import '../../server/login/login.dart';
import '../../server/position/position.dart';
import '../../server/socket/trade_webSocket.dart';
import '../../server/socket/webSocket.dart';
import '../../server/trade/deal.dart';
import '../../server/trade/settle.dart';
import '../../server/user/user.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/http/http.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
import '../../util/theme/theme.dart';
import '../../util/trade/trade_dialog.dart';
import '../../util/utils/market_util.dart';
import '../../util/utils/utils.dart';
import '../../util/widget/combo_box.dart' as my_combo;
import '../../util/widget/number_box.dart';

class Trade extends StatefulWidget {
  final Map<String, dynamic> params;

  const Trade({super.key, required this.params});

  @override
  State<Trade> createState() => _TradeState();
}

class _TradeState extends State<Trade> with MultiWindowListener {
  String mineAllAssets = "--";
  String mineAvailFunds = "--";
  String mineOccMargin = "--";
  String mineFreezeMargin = "--";
  String mineRiskDegree = "0.0%";
  String mineCloseProfit = "--";
  String mineFee = "--";
  String mineFloatPrice = "--";
  double canUse = 0;
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  late AppTheme appTheme;
  int selectedIndex = 0;
  int num = 1;
  bool open = true;
  bool auto = true;
  bool dir = true;
  double boxWidth = 158;
  double padWidth = 20;
  String price = "市价";
  List priceList = ["对手价", "排队价", "市价", "最新价", "超价"];

  List<Contract> allContracts = [];
  ResInitMargin? mInitMargin; //合约初始保证金
  HoldOrder? mHoldOrder; //当前品种所属持仓单
  List<DelegateOrder> mPendList = [];
  List<DelegateOrder> mDelList = [];
  List<HoldOrder> mHoldList = [];
  List<HoldOrder> mCloseList = [];
  List<Condition> mConditionList = [];
  List<Exchange> exchangeList = [];
  List<Commodity> commodityList = [];
  Contract contract = Contract();
  int closeIndex = 0;
  bool isClosing = false;
  List<ComOrder> mComList = [];
  List<Capital> capitals = [];
  List<CloseDetail> close = [];
  List<PositionDetail> positions = [];
  List<PositionSummary> positionSummary = [];
  List<TransactionRecord> transactionRecord = [];
  List<WithdrawalRecord> withdrawalRecord = [];
  String tradeBuyCanOpen = "--";
  String tradeBuyCanClose = "--";
  String tradeSaleCanOpen = "--";
  String tradeSaleCanClose = "--";
  String tradeBuyPrice = "---";
  String tradeSalePrice = "---";
  String tradeClosePrice = "----";
  int queryIndex = 0;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int settingIndex = 0;
  int exchangeIndex = 0;
  bool inputting = false;
  void Function(void Function())? globalStateFirst;
  void Function(void Function())? globalStateSecond;
  void Function(void Function())? globalStateThird;

  int windowId() {
    return widget.params["windowId"];
  }

  initData() async {
    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      if (call.method == kWindowEventNewRemoteDesktop) {
        windowOnTop(windowId());
      } else if (call.method == kWindowEventNewContract) {
        if (contract.code != null) {
          unSubscriptionQuote();
        }
        inputting = false;
        final args = jsonDecode(call.arguments);
        contract = Contract.fromJson(args);
        refreshData();
        subscriptionQuote();
        queryInitMargin();
      }
    });

    Broker? broker = await Utils.getBroker();
    String? baseUrl = await SpUtils.getString(SpKey.baseUrl);
    String? userInfo = await SpUtils.getString(SpKey.currentUser);
    exchangeList = await Utils.getMyExchange(true);
    String? commodity = await SpUtils.getString(SpKey.commodity);
    WebSocketServer().initSocket();
    if (baseUrl != null && userInfo != null) {
      Config.URL = baseUrl;
      UserUtils.currentUser = User.fromJson(jsonDecode(userInfo));
      TradeWebSocketServer().initSocket(broker?.quoteUrl);
      HttpUtils();
      getFund();
      requestHold();
      requestCancelDelOrder();
      requestDelOrder();
    } else {
      InfoBarUtils.showErrorBar("获取交易地址失败，请重新登录！");
    }

    if (widget.params['contract'] != null) {
      contract = Contract.fromJson(jsonDecode(widget.params['contract']));
      refreshData();
      subscriptionQuote();
      queryInitMargin();
      if (mounted) setState(() {});
    }

    String? contracts = await SpUtils.getString(SpKey.allContract);
    if (contracts != null) {
      List tmp = jsonDecode(contracts);
      allContracts.addAll(tmp.map((e) => Contract.fromJson(e)).toList());
      MarketUtils.contractList = allContracts;
    }
    if (commodity != null) {
      List temp = jsonDecode(commodity);
      MarketUtils.commodityList =
          temp.map((e) => Commodity.fromJson(e)).toList();
      commodityList = Utils.getVariety(exchangeList[0].exchangeNo);
    }
  }

  getFund() async {
    await UserServer.getAccountFound().then((value) {
      if (value != null) {
        calcFloatProfit(value);
      }
    });
  }

  /// 取消订阅
  void unSubscriptionQuote() {
    List<String> json = [];
    json = Utils.getSubJson(0, 1, [contract]);
    EventBusUtil.getInstance()
        .fire(SubEvent(json, socket_operation.Operation.UnSendSub));
  }

  /// 订阅行情
  void subscriptionQuote() {
    List<String> json = [];
    json = Utils.getSubJson(0, 1, [contract]);
    EventBusUtil.getInstance()
        .fire(SubEvent(json, socket_operation.Operation.SendSub));
  }

  void listener() {
    ///账户资金数据
    EventBusUtil.getInstance().on<FundUpdateEvent>().listen((event) {
      ResFund mAccountInfo = event.res;
      double floatP = mAccountInfo.FloatProfit ?? 0;
      mineFloatPrice = Utils.dealPointBigDecimal(floatP, 2).toString();
      //可用资金 = 期初结存+平仓盈亏+浮动盈亏-保证金占用-保证金冻结-手续费+出入金-冻结手续费
      //客户权益=期初结存+平仓盈亏+浮动盈亏-手续费+出入金
      //保证金占用/用户权益*100%
      canUse = mAccountInfo.Available ?? 0;
      double all = mAccountInfo.Equity ?? 0;
      mineAllAssets == Utils.double2Str(Utils.dealPointBigDecimal(all, 2));
      mineAvailFunds = Utils.double2Str(Utils.dealPointBigDecimal(canUse, 2));
      if (mounted) setState(() {});
    });

    ///行情变化
    EventBusUtil.getInstance().on<QuoteEvent>().listen((event) {
      Contract con = event.con;
      if (con.exCode == contract.exCode &&
          con.code == contract.code &&
          con.comType == contract.comType) {
        contract = con;
        if (inputting) {
          // if (mounted) setState(() {});
          return;
        }
        // refreshData();
      }
    });

    ///账户资金数据
    EventBusUtil.getInstance().on<FundUpdateEvent>().listen((event) {
      ResFund mAccountInfo = event.res;
      double canuse = mAccountInfo.Available ?? 0;
      // logger.f(
      //     "${UserUtils.currentUser?.rates};${contract.currency};${UserUtils.currentUser?.rates?.where((element) => element.currency == contract.currency)}");
      double rate = contract.currency == "USD" || contract.currency == null
          ? 1
          : UserUtils.currentUser?.rates
                  ?.where((element) => element.currency == contract.currency)
                  .first
                  .rate ??
              1;
      if (mInitMargin == null || mInitMargin?.Margin?.MarginValue == 0) {
        tradeBuyCanOpen = "---";
        tradeSaleCanOpen = "---";
      } else {
        int canopen =
            canuse ~/ ((mInitMargin?.Margin?.MarginValue ?? 0) * rate);
        tradeBuyCanOpen = "$canopen";
        tradeSaleCanOpen = "$canopen";
      }
      if (mounted) setState(() {});
    });

    ///订单状态变化
    EventBusUtil.getInstance().on<DelRecordEvent>().listen((event) {
      if (!LoginServer.isLogin) return;
      switch (event.res.OrderState) {
        case OrderState.ORDER_STATE_FAIL:
        case OrderState.ORDER_STATE_ACCEPT:
        case OrderState.ORDER_STATE_SUPPENDED:
        case OrderState.ORDER_STATE_CANCELED:
        case OrderState.ORDER_STATE_DELETEDFOREXPIRE:
        case OrderState.ORDER_STATE_PARTCANCELED:
          // 挂单，委托
          switch (selectedIndex) {
            case 0:
              requestHold();
              requestDelOrder();
              requestCancelDelOrder();
              break;
            case 2:
              requestDelOrder();
              break;
            case 3:
              requestComOrder();
              break;
            case 4:
              requestHold();
              break;
          }
          break;
        case OrderState.ORDER_STATE_PARTFINISHED:
        case OrderState.ORDER_STATE_FINISHED:
          // switch (_dealTabController.index) {
          //   case 2: //委托
          //     requestDelOrder();
          //     break;
          //   case 3: //成交
          //     requestComOrder();
          //     break;
          // }
          break;
      }
    });

    ///持仓变化信息
    EventBusUtil.getInstance().on<PositionUpdateEvent>().listen((event) {
      // requestHold();
      // requestCancelDelOrder();
    });

    ///浮动盈亏变化信息
    EventBusUtil.getInstance().on<PositionFloatEvent>().listen((event) {
      // ResFloatProfit con = event.res;
      // for (int i = 0; i < mHoldList.length; i++) {
      //   HoldOrder hold = mHoldList[i];
      //   if (hold.noMap != null && hold.noMap!.containsKey(con.PositionNo)) {
      //     double floatP = 0;
      //     if (hold.detailList != null) {
      //       for (ResHoldOrder detail in hold.detailList!) {
      //         if (detail.PositionNo == con.PositionNo) {
      //           detail.PositionProfit = con.PositionProfit;
      //         }
      //         floatP = floatP + (detail.PositionProfit ?? 0);
      //       }
      //       hold.floatProfit = floatP;
      //     }
      //   }
      // }
      if (mounted) setState(() {});
    });

    ///成交订单信息
    EventBusUtil.getInstance().on<FillUpdateEvent>().listen((fillUpdateEvent) {
      ResComOrder event = fillUpdateEvent.res;
      ComOrder order = ComOrder(
        name: event.ContractName,
        bs: event.MatchSide == SideType.SIDE_SELL ? "卖出" : "买入",
        price: event.MatchPrice,
        comNum: event.MatchQty,
        comNo: event.MatchNo,
        deleNo: event.OrderId,
        OpenClose: event.PositionEffect,
        CurrencyType: event.FeeCurrency,
        date: event.MatchTime?.split(" ")[0],
        time: event.MatchTime?.split(" ")[1],
        timeStamp: int.parse(Utils.getLongTime(event.MatchTime ?? "")),
      );
      mComList.insert(0, order);
      if (mounted) setState(() {});
    });
  }

  void refreshData() {
    double tick = (contract.futureTickSize ?? 0).toDouble();
    if (price == "对手价") {
      tradeBuyPrice = Utils.d2SBySrc(contract.salePrice?.toDouble(), tick);
      tradeSalePrice = Utils.d2SBySrc(contract.buyPrice?.toDouble(), tick);
    }
    if (price == "市价") {
      tradeBuyPrice = Utils.d2SBySrc(contract.lastPrice?.toDouble(), tick);
      tradeSalePrice = Utils.d2SBySrc(contract.lastPrice?.toDouble(), tick);
    }
    if (appTheme.tradeIndex == 0) {
      if (globalStateFirst != null) globalStateFirst!(() {});
    } else if (appTheme.tradeIndex == 1) {
      if (globalStateSecond != null) globalStateSecond!(() {});
    } else if (appTheme.tradeIndex == 2) {
      if (globalStateThird != null) globalStateThird!(() {});
    }
    if (mounted) setState(() {});
  }

  /// 计算浮盈
  void calcFloatProfit(ResFund mAccountInfo) {
    //可用资金 = 期初结存+平仓盈亏+浮动盈亏-保证金占用-保证金冻结-手续费+出入金-冻结手续费
    //客户权益=期初结存+平仓盈亏+浮动盈亏-手续费+出入金
    //保证金占用/用户权益*100%
    canUse = mAccountInfo.Available?.toDouble() ?? 0;
    double all = mAccountInfo.Equity?.toDouble() ?? 1;
    double agree =
        all == 0 ? 0 : ((mAccountInfo.OccupyDeposit ?? 0) / all) * 100;
    mineAllAssets = Utils.double2Str(Utils.dealPointBigDecimal(all, 2));
    mineAvailFunds = Utils.double2Str(Utils.dealPointBigDecimal(canUse, 2));
    mineOccMargin =
        Utils.dealPointBigDecimal(mAccountInfo.OccupyDeposit?.toDouble(), 2)
            .toString();
    mineFreezeMargin =
        Utils.dealPointBigDecimal(mAccountInfo.FrozenDeposit?.toDouble(), 2)
            .toString();
    mineRiskDegree = Utils.dealPointBigDecimal(agree, 2).toString();
    mineCloseProfit =
        Utils.dealPointBigDecimal(mAccountInfo.CloseProfit?.toDouble(), 2)
            .toString();
    mineFee =
        Utils.dealPointBigDecimal(mAccountInfo.Fee?.toDouble(), 2).toString();

    double floatP = mAccountInfo.FloatProfit?.toDouble() ?? 0;
    mineFloatPrice = Utils.dealPointBigDecimal(floatP, 2).toString();
    // if (floatP > 0) {
    //   mineFloatColor = Common.quote_red_color;
    // } else if (floatP < 0) {
    //   mineFloatColor = Common.quote_green_color;
    // } else {
    //   mineFloatColor = Colors.white;
    // }

    // if (mAccountInfo.CloseProfit != null) {
    //   if (mAccountInfo.CloseProfit! >= 0) {
    //     mineCloseProfitColor = Common.quote_red_color;
    //   } else {
    //     mineCloseProfitColor = Common.quote_green_color;
    //   }
    // }
    if (mounted) setState(() {});
  }

  /// 获取限价价格
  double getLimitPrice(bool side) {
    double value = 0;
    switch (price.trim()) {
      case "排队价":
        //side true卖出
        if (side) {
          value = Utils.getIntegerPrice(
              contract.salePrice, contract.futureTickSize);
        } else {
          value =
              Utils.getIntegerPrice(contract.buyPrice, contract.futureTickSize);
        }
        break;
      case "对手价":
        if (side) {
          value =
              Utils.getIntegerPrice(contract.buyPrice, contract.futureTickSize);
        } else {
          value = Utils.getIntegerPrice(
              contract.salePrice, contract.futureTickSize);
        }
        break;
      case "市价":
        value = 0;
        break;
      case "最新价":
        value =
            Utils.getIntegerPrice(contract.lastPrice, contract.futureTickSize);
        break;
      case "超价":
        if (side) {
          value = Utils.getIntegerPrice(
              (contract.buyPrice ?? 0) - (contract.futureTickSize ?? 0),
              contract.futureTickSize);
        } else {
          value = Utils.getIntegerPrice(
              (contract.salePrice ?? 0) - (contract.futureTickSize ?? 0),
              contract.futureTickSize);
        }
        break;
    }
    if (price != "市价" &&
        price != "排队价" &&
        price != "对手价" &&
        price != "最新价" &&
        price != "超价") {
      String str = price.trim();
      if (str.startsWith(".") || str.endsWith(".") || str == "") {
        InfoBarUtils.showWarningBar("请输入正确价格");
      } else {
        value = double.parse(price.trim());
        value = Utils.getIntegerPrice(value, contract.futureTickSize);
      }
    }
    return value;
  }

  void setCloseText() {
    if (mHoldOrder == null) {
      return;
    }
    switch (price.trim()) {
      case "市价":
        tradeClosePrice = "市价";
        break;
      case "排队价":
        tradeClosePrice = "排队价";
        break;
      case "对手价":
        tradeClosePrice = "对手价";
        break;
      case "最新价":
        tradeClosePrice = "最新价";
        break;
      case "超价":
        tradeClosePrice = "超价";
        break;
      default:
        tradeClosePrice = price.trim();
        break;
    }
  }

  /// 获取下单类型
  int getOrderType() {
    int type = 2;
    switch (price) {
      case "排队价":
      case "对手价":
      case "最新价":
      case "超价":
        type = Order_Type.ORDER_TYPE_LIMIT;
        break;
      case "市价":
        type = Order_Type.ORDER_TYPE_MARKET;
        break;
      default:
        type = Order_Type.ORDER_TYPE_LIMIT;
    }
    return type;
  }

  /// 查询合约初始保证金
  void queryInitMargin() async {
    mInitMargin = null;
    await DealServer.getInitMargin(contract.exCode, contract.subComCode,
            contract.comType, contract.code)
        .then((value) {
      if (value != null) {
        mInitMargin = value;
        if (mInitMargin == null || mInitMargin?.Margin?.MarginValue == 0) {
          tradeBuyCanOpen = "---";
          tradeSaleCanOpen = "---";
        } else {
          double rate = UserUtils.currentUser?.rates
                  ?.where((element) => element.currency == contract.currency)
                  .first
                  .rate ??
              1;
          int canopen =
              canUse ~/ ((mInitMargin?.Margin?.MarginValue ?? 0) * rate);
          tradeBuyCanOpen = "$canopen";
          tradeSaleCanOpen = "$canopen";
        }
        if (mounted) setState(() {});
      }
    });
  }

  /// 选择持仓买卖条件
  void bsCondition() async {
    // int exist = 0;
    // for (var order in mHoldList) {
    //   if (order.exCode == contract.exCode && order.code == contract.code && order.comType == contract.comType) {
    //     exist++;
    //   }
    // }
    int buynum = 0, salenum = 0;
    for (HoldOrder order in mHoldList) {
      if (isSameContract(order, contract)) {
        if (order.orderSide == SideType.SIDE_SELL) {
          salenum = order.quantity ?? 0;
        } else {
          buynum = order.quantity ?? 0;
        }
      }
    }
    tradeBuyCanClose = salenum.toString();
    tradeSaleCanClose = buynum.toString();
    if (mounted) setState(() {});
  }

  /// 判断持仓单与当前合约是否相同
  bool isSameContract(HoldOrder order, Contract? con) {
    bool isSame = false;
    if (con != null &&
        order.exCode == con.exCode &&
        order.code == con.code &&
        order.comType == con.comType) {
      isSame = true;
    }
    return isSame;
  }

  /// 请求持仓单
  void requestHold() async {
    await PositionServer.queryPosition().then((value) {
      if (value != null) {
        mHoldList.clear();
        for (var res in value) {
          HoldOrder hold = HoldOrder(
              name: res.ContractName,
              code: "${res.CommodityNo}${res.ContractNo}",
              exCode: res.ExchangeNo,
              comType: res.CommodityType,
              subComCode: res.CommodityNo,
              subConCode: res.ContractNo,
              orderSide: res.MatchSide,
              quantity: res.PositionQty,
              open: res.PositionPrice,
              margin: (res.MarginValue ?? 0) * (res.PositionQty ?? 0),
              floatProfit: res.PositionProfit,
              FutureContractSize: res.ContractSize,
              FutureTickSize: res.CommodityTickSize,
              CurrencyType: res.TradeCurrency,
              PositionNo: res.PositionNo,
              CalculatePrice: res.CalculatePrice,
              AvailableQty: res.AvailableQty);
          if (res.PositionType == PositionType.POSITION_TODAY) {
            hold.TPosition = res.PositionQty;
          } else if (res.PositionType == PositionType.POSITION_YESTODAY) {
            hold.YPosition = res.PositionQty;
          }

          List<ResHoldOrder> details = [];
          details.add(res);
          hold.detailList = details;
          hold.noMap = {res.PositionNo ?? "": res.PositionNo ?? ""};

          mHoldList.add(hold);
        }
        bsCondition();
        if (mounted) setState(() {});
      }
    });
  }

  ///查询可撤委托订单
  void requestCancelDelOrder() async {
    await DealServer.queryCancelOrder().then((value) {
      if (value != null) {
        mPendList.clear();
        for (var del in value) {
          DelegateOrder order = DelegateOrder(
            name: del.ContractName,
            code: "${del.CommodityNo}${del.ContractNo}",
            exCode: del.ExchangeNo,
            state: OrderState.getOrderState(del.OrderState),
            bs: del.OrderSide == SideType.SIDE_SELL ? "卖出" : "买入",
            price: del.OrderPrice,
            deleNum: del.OrderQty,
            comNum: del.MatchQty,
            deleNo: del.OrderId,
            OpenClose: del.PositionEffect,
            comType: del.CommodityType,
            CurrencyType: del.TradeCurrency,
            FutureTickSize: del.CommodityTickSize,
            date: del.CreateTime?.split(" ")[0],
            time: del.CreateTime?.split(" ")[1],
            timeStamp: int.parse(Utils.getLongTime(del.CreateTime ?? "")),
          );
          mPendList.add(order);
          mPendList.sort((a, b) {
            if (a.timeStamp == b.timeStamp) {
              return b.timeStamp?.compareTo(a.timeStamp ?? 0) ?? 0;
            }
            return b.timeStamp?.compareTo(a.timeStamp ?? 0) ?? 0;
          });
          if (mounted) setState(() {});
        }
      }
    });
  }

  ///查询委托记录
  void requestDelOrder() async {
    await DelegationServer.queryDelOrder().then((value) {
      if (value != null) {
        mDelList.clear();
        for (var del in value) {
          DelegateOrder order = DelegateOrder(
            name: del.ContractName,
            code: "${del.CommodityNo}${del.ContractNo}",
            exCode: del.ExchangeNo,
            state: OrderState.getOrderState(del.OrderState),
            bs: del.OrderSide == SideType.SIDE_SELL ? "卖出" : "买入",
            price: del.OrderPrice,
            deleNum: del.OrderQty,
            comNum: del.MatchQty,
            deleNo: del.OrderId,
            OpenClose: del.PositionEffect,
            comType: del.CommodityType,
            CurrencyType: del.TradeCurrency,
            FutureTickSize: del.CommodityTickSize,
            orderType: del.OrderType,
            orderOpType: del.OrderOpType,
            time: del.CreateTime,
            ErrorText: del.ErrorText,
            timeStamp: int.parse(Utils.getLongTime(del.CreateTime ?? "")),
          );
          mDelList.add(order);
          mDelList.sort((a, b) {
            if (a.timeStamp == b.timeStamp) {
              return b.timeStamp?.compareTo(a.timeStamp ?? 0) ?? 0;
            }
            return b.timeStamp?.compareTo(a.timeStamp ?? 0) ?? 0;
          });
          if (mounted) setState(() {});
        }
      }
    });
  }

  ///请求成交单
  void requestComOrder() async {
    await TransactionServer.queryComOrder().then((value) {
      mComList.clear();
      if (value != null) {
        for (var del in value) {
          ComOrder order = ComOrder(
            name: del.ContractName,
            code: "${del.CommodityNo ?? ""}${del.ContractNo ?? ""}",
            bs: del.MatchSide == SideType.SIDE_SELL ? "卖出" : "买入",
            price: del.MatchPrice,
            comNum: del.MatchQty,
            comNo: del.MatchNo,
            deleNo: del.OrderId,
            OpenClose: del.PositionEffect,
            CurrencyType: del.FeeCurrency,
            FeeValue: del.FeeValue,
            FutureTickSize: del.CommodityTickSize,
            date: del.MatchTime?.split(" ")[0],
            time: del.MatchTime?.split(" ")[1],
            timeStamp: int.parse(Utils.getLongTime(del.MatchTime ?? "")),
          );
          mComList.add(order);
        }
        mComList.sort((lhs, rhs) {
          if (lhs.timeStamp == rhs.timeStamp) {
            return 0;
          } else {
            return (lhs.timeStamp ?? 0) > (rhs.timeStamp ?? 0) ? -1 : 1;
          }
        });
      }
      if (mounted) setState(() {});
    });
  }

  ///查询条件单
  void qryCondition(int status) async {
    await ConditionServer.queryTodayCondition().then((value) {
      if (value != null) {
        mConditionList.clear();
        for (Condition con in value) {
          if (status != 0) {
            if (con.Status == status) {
              mConditionList.add(con);
            }
          } else {
            mConditionList.add(con);
          }
        }
        mConditionList.sort((lhs, rhs) {
          if (lhs.UpdateStamp == null) {
            return 1;
          }
          if (rhs.UpdateStamp == null) {
            return -1;
          }
          if (lhs.UpdateStamp == rhs.UpdateStamp) {
            return 0;
          } else {
            return lhs.UpdateStamp! > rhs.UpdateStamp! ? -1 : 1;
          }
        });

        if (mounted) setState(() {});
      }
    });
  }

  /// 删除条件单
  void delCondition() async {
    for (var condition in mConditionList) {
      if (condition.selected == true) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ContentDialog(
                style: ContentDialogThemeData(
                    padding: EdgeInsets.zero,
                    bodyPadding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                        color: appTheme.color,
                        borderRadius: BorderRadius.zero)),
                content: Container(
                  height: 200,
                  color: Common.dialogContentColor,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        color: Common.dialogTitleColor,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/jmaster.ico",
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                Common.appName,
                                style: TextStyle(color: appTheme.color),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(FluentIcons.cancel))
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FluentIcons.warning,
                                  size: 36,
                                  color: Colors.yellow,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Flexible(child: Text("确认要删除全部订单吗?")),
                              ],
                            )),
                      ),
                      Row(
                        children: [
                          Expanded(child: Container()),
                          Button(
                            style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    Common.dialogButtonTextColor),
                                padding: const WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 3)),
                                shape: const WidgetStatePropertyAll(
                                    RoundedRectangleBorder())),
                            child: const Text(
                              "确定",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              Get.back();
                              await ConditionServer.delCondition(
                                      condition.Id ?? 0)
                                  .then((value) {
                                if (value) {
                                  qryCondition(0);
                                }
                              });
                            },
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Button(
                            style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    Common.dialogButtonTextColor),
                                padding: const WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 3)),
                                shape: const WidgetStatePropertyAll(
                                    RoundedRectangleBorder())),
                            child: const Text(
                              "取消",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      )
                    ],
                  ),
                ),
              );
            });
        return;
      }
    }
    InfoBarUtils.showWarningDialog("请选择要删除的条件单");
  }

  /// 是否为同方向持仓订单
  bool isSameOrder(HoldOrder hold, ResHoldOrder res) {
    if (hold.exCode == res.ExchangeNo &&
        hold.subComCode == res.CommodityNo &&
        hold.subConCode == res.ContractNo &&
        hold.comType == res.CommodityType &&
        hold.orderSide == res.MatchSide) {
      return true;
    } else {
      return false;
    }
  }

  /// 获取锁仓手数
  int getLockPositionNum(HoldOrder src) {
    int count = src.quantity ?? 0;
    for (HoldOrder order in mHoldList) {
      if (order.exCode == src.exCode &&
          order.code == src.code &&
          order.comType == src.comType &&
          order.orderSide != src.orderSide) {
        count = count - (order.quantity ?? 0);
        break;
      }
    }
    return count;
  }

  /// 全平
  void closeAll() async {
    if (closeIndex < mCloseList.length) {
      HoldOrder hold = mCloseList[closeIndex];
      String? ExchangeNo = hold.exCode;
      String? CommodityNo = hold.subComCode;
      String? ContractNo = hold.subConCode;
      String ExpireTime = "";
      // String localOrderId = DeviceUtil.createLocalOrderId();
      int CommodityType = hold.comType ?? 0;
      int OrderType = Order_Type.ORDER_TYPE_MARKET;
      int TimeInForce = TimeInForceType.ORDER_TIMEINFORCE_GFD;
      int PositionEffect = PositionEffectType.PositionEffect_COVER;
      int OrderQty = hold.quantity ?? 0;
      double OrderPrice = 0;
      double StopPrice = 0;
      int OrderSide = 0;

      if (hold.orderSide == SideType.SIDE_BUY) {
        OrderSide = SideType.SIDE_SELL;
      } else if (hold.orderSide == SideType.SIDE_SELL) {
        OrderSide = SideType.SIDE_BUY;
      }
      await DealServer.addOrder(
              ExchangeNo ?? "",
              CommodityNo ?? "",
              ContractNo ?? "",
              CommodityType,
              OrderType,
              TimeInForce,
              ExpireTime,
              OrderSide,
              OrderPrice,
              StopPrice,
              OrderQty,
              PositionEffect,
              "")
          .then((value) {
        closeIndex++;
        closeAll();
      });
    } else {
      isClosing = false;
      closeIndex = 0;
      mHoldList.clear();
      requestHold();
    }
  }

  ///全部平仓
  void closeAllPos() {
    if (mHoldList.isEmpty) {
      InfoBarUtils.showInfoDialog("当前没有持仓单");
      return;
    }
    closeIndex = 0;
    isClosing = true;
    mCloseList.clear();
    mCloseList.addAll(mHoldList);
    closeAll();
  }

  ///快捷平仓
  void quickClose() {
    if (mHoldList.isEmpty) {
      InfoBarUtils.showInfoDialog("当前没有持仓单");
      return;
    }
    if (mHoldOrder == null) {
      InfoBarUtils.showInfoDialog("请选择需要平仓的单子");
      return;
    }
    int orderSide = mHoldOrder?.orderSide == SideType.SIDE_BUY
        ? SideType.SIDE_SELL
        : SideType.SIDE_BUY;
    AddOrder order = AddOrder(
      name: mHoldOrder?.name,
      code: mHoldOrder?.code,
      ExchangeNo: mHoldOrder?.exCode,
      CommodityNo: mHoldOrder?.subComCode,
      ContractNo: mHoldOrder?.subConCode,
      CommodityType: mHoldOrder?.comType,
      OrderType: Order_Type.ORDER_TYPE_MARKET,
      TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
      ExpireTime: "",
      OrderSide: orderSide,
      OrderPrice: 0,
      StopPrice: 0,
      OrderQty: mHoldOrder?.quantity,
      PositionEffect: PositionEffectType.PositionEffect_COVER,
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return TradeDialog().addOrderDialog(order);
        });
  }

  ///快捷反手
  void quickBack() {
    if (mHoldList.isEmpty) {
      InfoBarUtils.showInfoDialog("当前没有持仓单");
      return;
    }
    if (mHoldOrder == null) {
      InfoBarUtils.showInfoDialog("请选择需要反手的单子");
      return;
    }
    int orderSide = mHoldOrder?.orderSide == SideType.SIDE_BUY
        ? SideType.SIDE_SELL
        : SideType.SIDE_BUY;
    AddOrder order = AddOrder(
      name: mHoldOrder?.name,
      code: mHoldOrder?.code,
      ExchangeNo: mHoldOrder?.exCode,
      CommodityNo: mHoldOrder?.subComCode,
      ContractNo: mHoldOrder?.subConCode,
      CommodityType: mHoldOrder?.comType,
      OrderType: Order_Type.ORDER_TYPE_MARKET,
      TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
      ExpireTime: mHoldOrder?.ExpireTime,
      OrderSide: orderSide,
      OrderPrice: 0,
      StopPrice: 0,
      OrderQty: mHoldOrder?.quantity,
      PositionEffect: PositionEffectType.PositionEffect_COVER,
    );
    order.needBackHand = true;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return TradeDialog().addOrderDialog(order);
        });
  }

  ///快捷锁仓
  void quickLock() {
    if (mHoldList.isEmpty) {
      InfoBarUtils.showInfoDialog("当前没有可锁仓的单子");
      return;
    }
    if (mHoldOrder == null) {
      InfoBarUtils.showInfoDialog("请选择需要锁仓的单子");
      return;
    }
    int Quantity = getLockPositionNum(mHoldOrder!);
    if (Quantity > 0) {
      int orderSide = mHoldOrder?.orderSide == SideType.SIDE_BUY
          ? SideType.SIDE_SELL
          : SideType.SIDE_BUY;
      AddOrder order = AddOrder(
        name: mHoldOrder?.name,
        code: mHoldOrder?.code,
        ExchangeNo: mHoldOrder?.exCode,
        CommodityNo: mHoldOrder?.subComCode,
        ContractNo: mHoldOrder?.subConCode,
        CommodityType: mHoldOrder?.comType,
        OrderType: Order_Type.ORDER_TYPE_MARKET,
        TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
        ExpireTime: mHoldOrder?.ExpireTime,
        OrderSide: orderSide,
        OrderPrice: 0,
        StopPrice: 0,
        OrderQty: Quantity,
        PositionEffect: PositionEffectType.PositionEffect_OPEN,
      );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return TradeDialog().addOrderDialog(order);
          });
    } else {
      InfoBarUtils.showInfoDialog("当前持仓单不需要锁仓");
    }
  }

  ///止盈止损
  void plSetting() async {
    if (mHoldOrder == null) {
      InfoBarUtils.showWarningDialog("请选择要止盈止损的持仓");
    } else {
      String mHold = jsonEncode(mHoldOrder);
      await rustDeskWinManager.newPL("pl", hold: mHold);
    }
  }

  ///撤单
  void delHold() async {
    if (appTheme.tradeAllIndex == 0) {
      for (var hold in mPendList) {
        if (hold.selected) {
          await DealServer.cancelOrder(hold.deleNo ?? "").then((value) {
            if (value) {
              InfoBarUtils.showSuccessBar("撤单成功");
            }
          });
          requestCancelDelOrder();
          return;
        }
      }
      InfoBarUtils.showWarningDialog("请选择一笔可撤订单");
    } else {
      for (var hold in mDelList) {
        if (hold.selected) {
          await DealServer.cancelOrder(hold.deleNo ?? "").then((value) {
            if (value) {
              InfoBarUtils.showSuccessBar("撤单成功");
            }
          });
          requestCancelDelOrder();
          return;
        }
      }
      InfoBarUtils.showWarningDialog("请选择一笔可撤订单");
    }
  }

  ///全部撤单
  void delAllHold() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ContentDialog(
            style: ContentDialogThemeData(
                padding: EdgeInsets.zero,
                bodyPadding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    color: appTheme.color, borderRadius: BorderRadius.zero)),
            content: Container(
              height: 200,
              color: Common.dialogContentColor,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    color: Common.dialogTitleColor,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/jmaster.ico",
                          width: 20,
                        ),
                        Expanded(
                          child: Text(
                            Common.appName,
                            style: TextStyle(color: appTheme.color),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: const Icon(FluentIcons.cancel))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FluentIcons.warning,
                              size: 36,
                              color: Colors.yellow,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            const Flexible(child: Text("确认要撤销全部订单吗?")),
                          ],
                        )),
                  ),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      Button(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Common.dialogButtonTextColor),
                            padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 3)),
                            shape: const WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        child: const Text(
                          "确定",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Get.back();
                          if (appTheme.tradeAllIndex == 0) {
                            for (var hold in mPendList) {
                              await DealServer.cancelOrder(hold.deleNo ?? "")
                                  .then((value) {
                                if (value) {
                                  InfoBarUtils.showSuccessBar("撤单成功");
                                }
                              });
                            }
                            requestCancelDelOrder();
                          } else {
                            for (var hold in mDelList) {
                              await DealServer.cancelOrder(hold.deleNo ?? "")
                                  .then((value) {
                                if (value) {
                                  InfoBarUtils.showSuccessBar("撤单成功");
                                }
                              });
                            }
                            requestCancelDelOrder();
                          }
                        },
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Button(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Common.dialogButtonTextColor),
                            padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 3)),
                            shape: const WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        child: const Text(
                          "取消",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
          );
        });
  }

  ///添加条件单
  void reqAddCondition(
      String? ExchangeNo,
      String? CommodityNo,
      int? CommodityType,
      String? ContractNo,
      int? OrderType,
      int? TimeInForce,
      String? ExpireTime,
      int? OrderSide,
      double? OrderPrice,
      int? OrderQty,
      int? PositionEffect,
      int? PriceType,
      int? ConditionType,
      double? ConditionPrice) async {
    await ConditionServer.addCondition(
            ExchangeNo,
            CommodityNo,
            CommodityType,
            ContractNo,
            OrderType,
            TimeInForce,
            ExpireTime,
            OrderSide,
            OrderPrice,
            OrderQty,
            PositionEffect,
            PriceType,
            ConditionType,
            ConditionPrice)
        .then((value) {
      if (value) {
        InfoBarUtils.showSuccessBar("添加条件单成功");
        qryCondition(0);
      }
    });
  }

  ///资金状况
  Future getCapitals() async {
    capitals = await SettleServer.getCapital(UserUtils.currentUser?.id,
        formatter.format(startTime), formatter.format(endTime), 1);
  }

  ///平仓明细
  Future getCloseDetailed() async {
    close = await SettleServer.getCloseDetailed(UserUtils.currentUser?.id,
        formatter.format(startTime), formatter.format(endTime), 1);
  }

  ///持仓明细
  Future getPositionDetailed() async {
    positions = await SettleServer.getPositionDetailed(
        UserUtils.currentUser?.id,
        formatter.format(startTime),
        formatter.format(endTime),
        1);
  }

  ///持仓汇总
  Future getPositionSummary() async {
    positionSummary = await SettleServer.getPositionSummary(
        UserUtils.currentUser?.id,
        formatter.format(startTime),
        formatter.format(endTime),
        1);
  }

  ///历史成交/成交记录
  Future getFillRecord() async {
    transactionRecord = await SettleServer.getFillRecord(
        UserUtils.currentUser?.id,
        formatter.format(startTime),
        formatter.format(endTime));
  }

  ///出入金
  Future getCashReport() async {
    withdrawalRecord = await SettleServer.getCashReport(
        UserUtils.currentUser?.id,
        formatter.format(startTime),
        formatter.format(endTime));
  }

  void startDragging(bool isMainWindow) {
    WindowController.fromWindowId(kWindowId!).startDragging();
  }

  void setMovable(bool isMainWindow, bool movable) {
    WindowController.fromWindowId(kWindowId!).setMovable(movable);
  }

  loadTradeData() async {
    List<Exchange> list = await Utils.getMyExchange(true);
    if (list.isNotEmpty) {
      exchangeList.clear();
      exchangeList.addAll(list);
      commodityList = Utils.getVariety(exchangeList[0].exchangeNo);
      if (mounted) setState(() {});
    }
  }

  @override
  void onWindowClose() async {
    notMainWindowClose(WindowController windowController) async {
      await windowController.hide();
      await rustDeskWinManager
          .call(WindowType.Main, kWindowEventHide, {"id": kWindowId!});
    }

    final controller = WindowController.fromWindowId(kWindowId!);
    await notMainWindowClose(controller);
    super.onWindowClose();
  }

  @override
  void initState() {
    DesktopMultiWindow.addListener(this);
    initData();
    listener();
    loadTradeData();
    super.initState();
  }

  @override
  void dispose() {
    DesktopMultiWindow.removeListener(this);
    WebSocketServer().dispose();
    TradeWebSocketServer().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appTheme = context.watch<AppTheme>();
    UserUtils.appContext = context;
    return Container(
      color: appTheme.commandBarColor,
      child: NavigationView(
        appBar: NavigationAppBar(
          automaticallyImplyLeading: false,
          height: 30,
          title: GestureDetector(
              onPanStart: (_) => startDragging(false),
              onPanCancel: () {
                if (isMacOS) {
                  setMovable(false, false);
                }
              },
              onPanEnd: (_) {
                if (isMacOS) {
                  setMovable(false, false);
                }
              },
              child: Row(
                children: [
                  Expanded(
                      child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: UserUtils.currentUser?.nick ?? "",
                          style: TextStyle(color: Colors.yellow)),
                      TextSpan(
                          text: "您好，您的可用资金：",
                          style: TextStyle(color: appTheme.exchangeTextColor)),
                      TextSpan(
                          text: mineAvailFunds,
                          style: TextStyle(color: Colors.yellow)),
                      TextSpan(
                          text: "   用户权益：",
                          style: TextStyle(color: appTheme.exchangeTextColor)),
                      TextSpan(
                          text: mineAllAssets,
                          style: TextStyle(color: Colors.yellow)),
                      TextSpan(
                          text: "   平仓盈亏：",
                          style: TextStyle(color: appTheme.exchangeTextColor)),
                      TextSpan(
                          text: mineCloseProfit,
                          style: TextStyle(color: Colors.red)),
                      TextSpan(
                          text: "   手续费：",
                          style: TextStyle(color: appTheme.exchangeTextColor)),
                      TextSpan(
                          text: mineFee,
                          style: TextStyle(color: Colors.yellow)),
                      TextSpan(
                          text: "   浮动盈亏：",
                          style: TextStyle(color: appTheme.exchangeTextColor)),
                      TextSpan(
                          text: mineFloatPrice,
                          style: TextStyle(color: Colors.red)),
                      TextSpan(
                          text: "   占用保证金：",
                          style: TextStyle(color: appTheme.exchangeTextColor)),
                      TextSpan(
                          text: mineOccMargin,
                          style: TextStyle(color: Colors.yellow)),
                      TextSpan(
                          text: "   风险度：",
                          style: TextStyle(color: appTheme.exchangeTextColor)),
                      TextSpan(
                          text: "$mineRiskDegree%",
                          style: TextStyle(color: Colors.red)),
                    ]),
                  ))
                ],
              )),
          actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Button(
              onPressed: () {
                inputting = false;
                if (selectedIndex == 0) {
                  requestHold();
                  requestDelOrder();
                  requestCancelDelOrder();
                } else if (selectedIndex == 1) {
                  qryCondition(0);
                } else if (selectedIndex == 2) {
                  requestDelOrder();
                  requestCancelDelOrder();
                } else if (selectedIndex == 3) {
                  requestComOrder();
                } else if (selectedIndex == 4) {
                  requestHold();
                }
              },
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(appTheme.commandBarColor),
                  padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 3, horizontal: 8))),
              child: const Text('刷新', textAlign: TextAlign.center),
            ),
            const SizedBox(
              width: 3,
            ),
            Button(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(appTheme.commandBarColor),
                  padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 3, horizontal: 8))),
              child: const Text('锁定', textAlign: TextAlign.center),
            ),
            const SizedBox(
              width: 3,
            ),
            IconButton(
                icon: const Icon(FluentIcons.minimum_value, size: 22),
                style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 10))),
                onPressed: () {
                  WindowController.fromWindowId(widget.params["windowId"])
                      .minimize();
                }),
            IconButton(
                icon: const Icon(FluentIcons.sign_out, size: 22),
                style: const ButtonStyle(
                    padding:
                        WidgetStatePropertyAll(EdgeInsets.only(right: 10))),
                onPressed: () async {
                  Future.delayed(Duration.zero, () async {
                    await DesktopMultiWindow.invokeMethod(
                        kMainWindowId, kWindowEventHide, null);
                    await WindowController.fromWindowId(kWindowId!).close();
                  });
                  // EventBusUtil.getInstance().fire(LoginEvent(false));
                }),
          ]),
        ),
        content: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tabItem("交易", 0),
                tabItem("云条件单", 1),
                tabItem("当日委托", 2),
                tabItem("当日成交", 3),
                tabItem("持仓", 4),
                tabItem("查询", 5),
                tabItem("交易设置", 6),
              ],
            ),
            Container(
              color: appTheme.commandBarColor,
              margin: const EdgeInsets.only(left: 5),
              child: selectedIndex == 0 ||
                      selectedIndex == 2 ||
                      selectedIndex == 3 ||
                      selectedIndex == 4
                  ? tradeContent()
                  : selectedIndex == 1
                      ? cloudConditionContent()
                      : null,
            ),
            selectedIndex == 0
                ? tradeDetails()
                : selectedIndex == 1
                    ? cloudConditionDetails()
                    : selectedIndex == 2
                        ? orderDetails()
                        : selectedIndex == 3
                            ? dealDetails()
                            : selectedIndex == 4
                                ? posDetails()
                                : selectedIndex == 5
                                    ? queryWidget()
                                    : selectedIndex == 6
                                        ? settingWidget()
                                        : Container()
          ],
        ),
      ),
    );
  }

  Widget tableTitleItem(String? text) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
      padding: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: AnimatedFluentTheme(
        data: FluentThemeData(),
        child: Tooltip(
            message: text ?? "--",
            style: const TooltipThemeData(preferBelow: true),
            child: Text(
              text ?? "--",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: appTheme.color),
            )),
      ),
    );
  }

  Widget tablePlItem({bool? win, bool? lose}) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
      alignment: Alignment.center,
      child: AnimatedFluentTheme(
          data: FluentThemeData(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: win == true ? Colors.red : Colors.grey,
                child: const Text("盈", style: TextStyle(color: Colors.white)),
              ),
              CircleAvatar(
                radius: 15,
                backgroundColor: lose == true ? Colors.red : Colors.grey,
                child: const Text("损", style: TextStyle(color: Colors.white)),
              ),
            ],
          )),
    );
  }

  Widget tableRadioItem(String check, String uncheck, {bool? checked}) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
      alignment: Alignment.center,
      child: StatefulBuilder(builder: (_, state) {
        return Row(
          children: [
            RadioButton(
                checked: checked != false,
                content: Text(check),
                onChanged: (v) {
                  if (v) {
                    state(() => checked = true);
                  }
                }),
            RadioButton(
                checked: checked == false,
                content: Text(uncheck),
                onChanged: (v) {
                  if (v) {
                    state(() => checked = false);
                  }
                }),
          ],
        );
      }),
    );
  }

  Widget tablePointItem({int? value}) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
      child: StatefulBuilder(builder: (_, state) {
        return NumberBox(
          value: value ?? 0,
          min: 0,
          clearButton: false,
          onChanged: (v) => state(() => value = v ?? 0),
        );
      }),
    );
  }

  Widget tableOperateItem(int index) {
    return GestureDetector(
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: appTheme.exchangeBgColor)),
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          child: Text(
            "重置",
            style: TextStyle(color: Colors.blue),
          )),
      onTap: () {},
    );
  }

  Widget tabItem(String title, int index) {
    return Expanded(
        child: GestureDetector(
      onTap: () {
        selectedIndex = index;
        inputting = false;
        if (index == 0) {
          requestHold();
          requestDelOrder();
          requestCancelDelOrder();
        } else if (index == 1) {
          qryCondition(0);
        } else if (index == 2) {
          requestDelOrder();
          requestCancelDelOrder();
        } else if (index == 3) {
          requestComOrder();
        } else if (index == 4) {
          requestHold();
        }
        if (mounted) setState(() {});
      },
      child: Container(
        width: 138,
        alignment: Alignment.center,
        color: selectedIndex == index
            ? appTheme.commandBarColor
            : Colors.transparent,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17),
        ),
      ),
    ));
  }

  ///下单
  Widget tradeContent() {
    TextEditingController controller =
        TextEditingController(text: contract.code);
    List<Tab> tabs = [
      Tab(
        text: Text(
          '快手下单',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14,
              color: appTheme.tradeIndex == 0
                  ? Colors.yellow
                  : appTheme.exchangeTextColor),
        ),
        body: SizedBox(
          width: 388,
          height: 500,
          child: StatefulBuilder(
            builder: (_, state) {
              globalStateFirst = state;
              return ListView(
                shrinkWrap: true,
                children: [
                  Row(children: [
                    SizedBox(width: padWidth),
                    const Text("合约"),
                    Container(
                      width: boxWidth,
                      height: 28,
                      margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
                      child: AutoSuggestBox(
                        controller: controller,
                        items: allContracts.map((e) {
                          return AutoSuggestBoxItem<Contract>(
                            value: e,
                            label: e.code ?? "--",
                          );
                        }).toList(),
                        onSelected: (item) {
                          if (item.value != null) {
                            unSubscriptionQuote();
                            contract = item.value!;
                            subscriptionQuote();
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 58,
                    ),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3))),
                        onPressed: () {
                          open = true;
                          auto = true;
                          num = 1;
                          price = "市价";
                          state(() {});
                        },
                        child: const Text("复位")),
                  ]),
                  Row(
                    children: [
                      SizedBox(width: padWidth),
                      RadioButton(
                          checked: open,
                          onChanged: (checked) {
                            if (checked) {
                              state(() => open = checked);
                            }
                          }),
                      const Text("  开仓"),
                      const SizedBox(width: 28),
                      RadioButton(
                          checked: !open,
                          onChanged: (checked) {
                            if (checked) {
                              state(() => open = !checked);
                            }
                          }),
                      const Text("  平仓"),
                      const SizedBox(width: 28),
                      Checkbox(
                        checked: auto,
                        onChanged: (bool? value) =>
                            state(() => auto = value ?? true),
                      ),
                      const Text("  自动"),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: padWidth),
                      const Text("数量"),
                      Container(
                        width: boxWidth,
                        height: 38,
                        margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
                        child: NumberBox(
                          value: num,
                          min: 1,
                          max: 10000000,
                          clearButton: false,
                          onChanged: (v) => state(() => num = v ?? 1),
                        ),
                      ),
                      Column(
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: "  买：",
                                style: TextStyle(color: Colors.red)),
                            TextSpan(
                                text: "可开 ",
                                style: TextStyle(
                                    color: appTheme.exchangeTextColor)),
                            TextSpan(
                                text: tradeBuyCanOpen,
                                style: TextStyle(color: appTheme.color)),
                            TextSpan(
                                text: "  可平 ",
                                style: TextStyle(
                                    color: appTheme.exchangeTextColor)),
                            TextSpan(
                                text: tradeBuyCanClose,
                                style: TextStyle(color: appTheme.color))
                          ])),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: "  卖：",
                                style: TextStyle(color: Colors.green)),
                            TextSpan(
                                text: "可开 ",
                                style: TextStyle(
                                    color: appTheme.exchangeTextColor)),
                            TextSpan(
                                text: tradeSaleCanOpen,
                                style: TextStyle(color: appTheme.color)),
                            TextSpan(
                                text: "  可平 ",
                                style: TextStyle(
                                    color: appTheme.exchangeTextColor)),
                            TextSpan(
                                text: tradeSaleCanClose,
                                style: TextStyle(color: appTheme.color))
                          ])),
                        ],
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: padWidth),
                      const Text("价格"),
                      Container(
                        width: boxWidth,
                        height: 38,
                        margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                        child: my_combo.EditableComboBox<String>(
                          value: price,
                          mathValue: contract.lastPrice?.toDouble(),
                          items:
                              priceList.map<my_combo.ComboBoxItem<String>>((e) {
                            return my_combo.ComboBoxItem<String>(
                              value: e,
                              child: Text('$e'),
                            );
                          }).toList(),
                          onChanged: (v) {
                            tradeSalePrice = getLimitPrice(true).toString();
                            tradeBuyPrice = getLimitPrice(false).toString();
                            if (globalStateFirst != null)
                              globalStateFirst!(() {});
                          },
                          onFieldSubmitted: (String text) {
                            return text;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  tradeBuyPrice,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 135,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "买入",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (contract.code == null) {
                            InfoBarUtils.showErrorBar("请选择合约");
                            return;
                          }
                          AddOrder order = AddOrder(
                            name: contract.name,
                            code: contract.code,
                            ExchangeNo: contract.exCode,
                            CommodityNo: contract.subComCode,
                            ContractNo: contract.subConCode,
                            CommodityType: contract.comType,
                            OrderType: getOrderType(),
                            TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
                            ExpireTime: "",
                            OrderSide: SideType.SIDE_BUY,
                            OrderPrice: getLimitPrice(false),
                            StopPrice: 0,
                            OrderQty: num,
                            PositionEffect: open
                                ? PositionEffectType.PositionEffect_OPEN
                                : PositionEffectType.PositionEffect_COVER,
                          );
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return TradeDialog().addOrderDialog(order);
                              });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  tradeSalePrice,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 135,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "卖出",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (contract.code == null) {
                            InfoBarUtils.showErrorBar("请选择合约");
                            return;
                          }
                          AddOrder order = AddOrder(
                            name: contract.name,
                            code: contract.code,
                            ExchangeNo: contract.exCode,
                            CommodityNo: contract.subComCode,
                            ContractNo: contract.subConCode,
                            CommodityType: contract.comType,
                            OrderType: getOrderType(),
                            TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
                            ExpireTime: "",
                            OrderSide: SideType.SIDE_SELL,
                            OrderPrice: getLimitPrice(false),
                            StopPrice: 0,
                            OrderQty: num,
                            PositionEffect: open
                                ? PositionEffectType.PositionEffect_OPEN
                                : PositionEffectType.PositionEffect_COVER,
                          );
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return TradeDialog().addOrderDialog(order);
                              });
                        },
                      )
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
      Tab(
        text: Text(
          '三键下单',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14,
              color: appTheme.tradeIndex == 1
                  ? Colors.yellow
                  : appTheme.exchangeTextColor),
        ),
        body: SizedBox(
          width: 388,
          height: 500,
          child: StatefulBuilder(
            builder: (_, state) {
              globalStateSecond = state;
              return ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 18),
                  Row(children: [
                    SizedBox(width: padWidth),
                    const Text("合约"),
                    Container(
                      width: boxWidth,
                      height: 28,
                      margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                      child: AutoSuggestBox(
                        controller: controller,
                        items: allContracts.map((e) {
                          return AutoSuggestBoxItem<Contract>(
                            value: e,
                            label: e.code ?? "--",
                          );
                        }).toList(),
                        onSelected: (item) {
                          if (item.value != null) {
                            unSubscriptionQuote();
                            contract = item.value!;
                            subscriptionQuote();
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 58,
                    ),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3))),
                        onPressed: () {
                          num = 1;
                          price = "市价";
                          state(() {});
                        },
                        child: const Text("复位")),
                  ]),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: padWidth),
                      const Text("数量"),
                      Container(
                        width: boxWidth,
                        height: 38,
                        margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
                        child: NumberBox(
                            value: num,
                            min: 1,
                            max: 10000000,
                            clearButton: false,
                            onChanged: (v) => state(() => num = v ?? 1)),
                      ),
                      Column(
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: "  买：",
                                style: TextStyle(color: Colors.red)),
                            TextSpan(
                                text: "可开 ",
                                style: TextStyle(
                                    color: appTheme.exchangeTextColor)),
                            TextSpan(
                                text: "--",
                                style: TextStyle(color: appTheme.color)),
                            TextSpan(
                                text: "  可平 ",
                                style: TextStyle(
                                    color: appTheme.exchangeTextColor)),
                            TextSpan(
                                text: "0",
                                style: TextStyle(color: appTheme.color))
                          ])),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: "  卖：",
                                style: TextStyle(color: Colors.green)),
                            TextSpan(
                                text: "可开 ",
                                style: TextStyle(
                                    color: appTheme.exchangeTextColor)),
                            TextSpan(
                                text: "--",
                                style: TextStyle(color: appTheme.color)),
                            TextSpan(
                                text: "  可平 ",
                                style: TextStyle(
                                    color: appTheme.exchangeTextColor)),
                            TextSpan(
                                text: "0",
                                style: TextStyle(color: appTheme.color))
                          ])),
                        ],
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: padWidth),
                      const Text("价格"),
                      Container(
                        width: boxWidth,
                        height: 38,
                        margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                        child: my_combo.EditableComboBox<String>(
                          value: price,
                          mathValue: contract.lastPrice?.toDouble(),
                          items:
                              priceList.map<my_combo.ComboBoxItem<String>>((e) {
                            return my_combo.ComboBoxItem<String>(
                              value: e,
                              child: Text('$e'),
                            );
                          }).toList(),
                          onChanged: (v) {
                            tradeSalePrice = getLimitPrice(true).toString();
                            tradeBuyPrice = getLimitPrice(false).toString();
                            if (globalStateSecond != null)
                              globalStateSecond!(() {});
                          },
                          onFieldSubmitted: (String text) {
                            return text;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  tradeBuyPrice,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 88,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "买入",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (contract.code == null) {
                            InfoBarUtils.showErrorBar("请选择合约");
                            return;
                          }
                          AddOrder order = AddOrder(
                            name: contract.name,
                            code: contract.code,
                            ExchangeNo: contract.exCode,
                            CommodityNo: contract.subComCode,
                            ContractNo: contract.subConCode,
                            CommodityType: contract.comType,
                            OrderType: getOrderType(),
                            TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
                            ExpireTime: "",
                            OrderSide: SideType.SIDE_BUY,
                            OrderPrice: getLimitPrice(false),
                            StopPrice: 0,
                            OrderQty: num,
                            PositionEffect:
                                PositionEffectType.PositionEffect_OPEN,
                          );
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return TradeDialog().addOrderDialog(order);
                              });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  tradeSalePrice,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 88,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "卖出",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (contract.code == null) {
                            InfoBarUtils.showErrorBar("请选择合约");
                            return;
                          }
                          AddOrder order = AddOrder(
                            name: contract.name,
                            code: contract.code,
                            ExchangeNo: contract.exCode,
                            CommodityNo: contract.subComCode,
                            ContractNo: contract.subConCode,
                            CommodityType: contract.comType,
                            OrderType: getOrderType(),
                            TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
                            ExpireTime: "",
                            OrderSide: SideType.SIDE_SELL,
                            OrderPrice: getLimitPrice(false),
                            StopPrice: 0,
                            OrderQty: num,
                            PositionEffect:
                                PositionEffectType.PositionEffect_OPEN,
                          );
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return TradeDialog().addOrderDialog(order);
                              });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  tradeClosePrice,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 88,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "平仓",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (contract.code == null) {
                            InfoBarUtils.showErrorBar("请选择合约");
                            return;
                          }
                          double limitPrice = getLimitPrice(true);
                          if (mHoldOrder?.orderSide == SideType.SIDE_BUY) {
                            limitPrice = getLimitPrice(true);
                          } else {
                            limitPrice = getLimitPrice(false);
                          }
                          int sideType =
                              mHoldOrder?.orderSide == SideType.SIDE_SELL
                                  ? SideType.SIDE_BUY
                                  : SideType.SIDE_SELL;
                          AddOrder order = AddOrder(
                            name: contract.name,
                            code: contract.code,
                            ExchangeNo: contract.exCode,
                            CommodityNo: contract.subComCode,
                            ContractNo: contract.subConCode,
                            CommodityType: contract.comType,
                            OrderType: getOrderType(),
                            TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
                            ExpireTime: "",
                            OrderSide: sideType,
                            OrderPrice: limitPrice,
                            StopPrice: 0,
                            OrderQty: num,
                            PositionEffect:
                                PositionEffectType.PositionEffect_COVER,
                          );
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return TradeDialog().addOrderDialog(order);
                              });
                        },
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
      Tab(
          text: Text(
            '传统下单',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: appTheme.tradeIndex == 2
                    ? Colors.yellow
                    : appTheme.exchangeTextColor),
          ),
          body: SizedBox(
            width: 388,
            height: 500,
            child: StatefulBuilder(
              builder: (_, state) {
                globalStateThird = state;
                return ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 18),
                    Row(children: [
                      SizedBox(width: padWidth),
                      const Text("合约"),
                      Container(
                        width: boxWidth,
                        height: 28,
                        margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                        child: AutoSuggestBox(
                          controller: controller,
                          items: allContracts.map((e) {
                            return AutoSuggestBoxItem<Contract>(
                              value: e,
                              label: e.code ?? "--",
                            );
                          }).toList(),
                          onSelected: (item) {
                            if (item.value != null) {
                              unSubscriptionQuote();
                              contract = item.value!;
                              subscriptionQuote();
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 58,
                      ),
                      Button(
                          style: const ButtonStyle(
                              padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3))),
                          onPressed: () {
                            dir = true;
                            open = true;
                            num = 1;
                            price = "市价";
                            state(() {});
                          },
                          child: const Text("复位")),
                    ]),
                    Row(
                      children: [
                        SizedBox(
                          width: padWidth,
                          height: 58,
                        ),
                        const Text("方向   "),
                        RadioButton(
                            checked: dir,
                            onChanged: (checked) {
                              if (checked) {
                                state(() => dir = checked);
                              }
                            }),
                        const Text("  买入"),
                        const SizedBox(width: 28),
                        RadioButton(
                            checked: !dir,
                            onChanged: (checked) {
                              if (checked) {
                                state(() => dir = !checked);
                              }
                            }),
                        const Text("  卖出"),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: padWidth),
                        const Text("开平   "),
                        RadioButton(
                            checked: open,
                            onChanged: (checked) {
                              if (checked) {
                                state(() => open = checked);
                              }
                            }),
                        const Text("  开仓"),
                        const SizedBox(width: 28),
                        RadioButton(
                            checked: !open,
                            onChanged: (checked) {
                              if (checked) {
                                state(() => open = !checked);
                              }
                            }),
                        const Text("  平仓"),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: padWidth),
                        const Text("数量"),
                        Container(
                          width: boxWidth,
                          height: 38,
                          margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
                          child: NumberBox(
                            value: num,
                            min: 1,
                            max: 10000000,
                            clearButton: false,
                            onChanged: (v) => state(() => num = v ?? 1),
                          ),
                        ),
                        Column(
                          children: [
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: "  买：",
                                  style: TextStyle(color: Colors.red)),
                              TextSpan(
                                  text: "可开 ",
                                  style: TextStyle(
                                      color: appTheme.exchangeTextColor)),
                              TextSpan(
                                  text: "--",
                                  style: TextStyle(color: appTheme.color)),
                              TextSpan(
                                  text: "  可平 ",
                                  style: TextStyle(
                                      color: appTheme.exchangeTextColor)),
                              TextSpan(
                                  text: "0",
                                  style: TextStyle(color: appTheme.color))
                            ])),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: "  卖：",
                                  style: TextStyle(color: Colors.green)),
                              TextSpan(
                                  text: "可开 ",
                                  style: TextStyle(
                                      color: appTheme.exchangeTextColor)),
                              TextSpan(
                                  text: "--",
                                  style: TextStyle(color: appTheme.color)),
                              TextSpan(
                                  text: "  可平 ",
                                  style: TextStyle(
                                      color: appTheme.exchangeTextColor)),
                              TextSpan(
                                  text: "0",
                                  style: TextStyle(color: appTheme.color))
                            ])),
                          ],
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: padWidth),
                        const Text("价格"),
                        Container(
                          width: boxWidth,
                          height: 38,
                          margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                          child: my_combo.EditableComboBox<String>(
                            value: price,
                            mathValue: contract.lastPrice?.toDouble(),
                            items: priceList
                                .map<my_combo.ComboBoxItem<String>>((e) {
                              return my_combo.ComboBoxItem<String>(
                                value: e,
                                child: Text('$e'),
                              );
                            }).toList(),
                            onChanged: (v) {
                              tradeSalePrice = getLimitPrice(true).toString();
                              tradeBuyPrice = getLimitPrice(false).toString();
                              if (globalStateThird != null)
                                globalStateThird!(() {});
                            },
                            onFieldSubmitted: (String text) {
                              return text;
                            },
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      child: Container(
                        width: 58,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        margin: EdgeInsets.fromLTRB(padWidth, 20, 268, 20),
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: const AutoSizeText(
                          "下单",
                          maxLines: 1,
                          style: TextStyle(color: Colors.white, fontSize: 23),
                        ),
                      ),
                      onTap: () {
                        if (contract.code == null) {
                          InfoBarUtils.showErrorBar("请选择合约");
                          return;
                        }
                        AddOrder order = AddOrder(
                          name: contract.name,
                          code: contract.code,
                          ExchangeNo: contract.exCode,
                          CommodityNo: contract.subComCode,
                          ContractNo: contract.subConCode,
                          CommodityType: contract.comType,
                          OrderType: getOrderType(),
                          TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
                          ExpireTime: "",
                          OrderSide:
                              dir ? SideType.SIDE_BUY : SideType.SIDE_SELL,
                          OrderPrice: getLimitPrice(dir),
                          StopPrice: 0,
                          OrderQty: num,
                          PositionEffect: open
                              ? PositionEffectType.PositionEffect_OPEN
                              : PositionEffectType.PositionEffect_COVER,
                        );
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return TradeDialog().addOrderDialog(order);
                            });
                      },
                    ),
                  ],
                );
              },
            ),
          ))
    ];

    return Row(
      children: [
        SizedBox(
          width: 388,
          child: StatefulBuilder(builder: (_, refresh) {
            return TabView(
              tabs: tabs,
              currentIndex: appTheme.tradeIndex,
              onChanged: (index) => appTheme.tradeIndex = index,
              tabWidthBehavior: TabWidthBehavior.equal,
              closeButtonVisibility: CloseButtonVisibilityMode.never,
              showScrollButtons: false,
            );
          }),
        )
      ],
    );
  }

  ///持仓、委托、可撤
  Widget tradeDetails() {
    ScrollController scrollController = ScrollController();
    ScrollController secScrollController = ScrollController();
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(15),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        onPressed: () {
                          appTheme.tradeDetailIndex = 0;
                        },
                        child: Text(
                          "合\n计",
                          style: TextStyle(
                              fontSize: 18,
                              color: appTheme.tradeDetailIndex == 0
                                  ? Colors.yellow
                                  : appTheme.exchangeTextColor),
                        )),
                    const SizedBox(height: 20),
                    Button(
                      style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                          shape:
                              WidgetStatePropertyAll(RoundedRectangleBorder())),
                      onPressed: () {
                        appTheme.tradeDetailIndex = 1;
                      },
                      child: Text(
                        "明\n细",
                        style: TextStyle(
                            fontSize: 18,
                            color: appTheme.tradeDetailIndex == 1
                                ? Colors.yellow
                                : appTheme.exchangeTextColor),
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (appTheme.tradeDetailIndex == 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const SizedBox(width: 15),
                            Button(
                                style: const ButtonStyle(
                                    padding: WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10)),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder())),
                                onPressed: closeAllPos,
                                child: Text(
                                  "全部平仓",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: appTheme.exchangeTextColor),
                                )),
                            const SizedBox(width: 15),
                            Button(
                                style: const ButtonStyle(
                                    padding: WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10)),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder())),
                                onPressed: quickClose,
                                child: Text(
                                  "快捷平仓",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: appTheme.exchangeTextColor),
                                )),
                            const SizedBox(width: 15),
                            Button(
                                style: const ButtonStyle(
                                    padding: WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10)),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder())),
                                onPressed: quickBack,
                                child: Text(
                                  "快捷反手",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: appTheme.exchangeTextColor),
                                )),
                            const SizedBox(width: 15),
                            Button(
                                style: const ButtonStyle(
                                    padding: WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10)),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder())),
                                onPressed: quickLock,
                                child: Text(
                                  "快捷锁仓",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: appTheme.exchangeTextColor),
                                )),
                            const SizedBox(width: 15),
                            Button(
                                onPressed: plSetting,
                                style: const ButtonStyle(
                                    padding: WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10)),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder())),
                                child: Text(
                                  "止盈止损",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: appTheme.exchangeTextColor),
                                )),
                          ],
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: appTheme.exchangeBgColor)),
                      margin: const EdgeInsets.fromLTRB(15, 0, 0, 5),
                      child: Scrollbar(
                        controller: scrollController,
                        key: UniqueKey(),
                        style: const ScrollbarThemeData(
                            thickness: 10,
                            padding: EdgeInsets.zero,
                            hoveringPadding: EdgeInsets.zero),
                        child: SingleChildScrollView(
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                                width: 0.8.sw,
                                height: 168,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: mHoldList.length + 1,
                                    padding: const EdgeInsets.only(bottom: 10),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (index == 0) {
                                        return Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: tableTitleItem("合约代码")),
                                            Expanded(
                                                flex: 1,
                                                child: tableTitleItem("买卖")),
                                            Expanded(
                                                flex: 1,
                                                child: tableTitleItem("数量")),
                                            Expanded(
                                                flex: 1,
                                                child: tableTitleItem("可平")),
                                            Expanded(
                                                flex: 2,
                                                child: tableTitleItem("开仓均价")),
                                            Expanded(
                                                flex: 2,
                                                child: tableTitleItem("计算价格")),
                                            Expanded(
                                                flex: 2,
                                                child: tableTitleItem("浮动盈亏")),
                                            Expanded(
                                                flex: 2,
                                                child: tableTitleItem("保证金占用")),
                                            Expanded(
                                                flex: 1,
                                                child: tableTitleItem("币种")),
                                            Expanded(
                                                flex: 3,
                                                child: tableTitleItem("合约名称")),
                                            Expanded(
                                                flex: 3,
                                                child: tableTitleItem(
                                                    appTheme.tradeDetailIndex ==
                                                            0
                                                        ? "止盈止损"
                                                        : "持仓编号")),
                                          ],
                                        );
                                      } else {
                                        return GestureDetector(
                                          child: Container(
                                            color: mHoldList[index - 1].selected
                                                ? Colors.black.withOpacity(0.2)
                                                : Colors.transparent,
                                            child: IntrinsicHeight(
                                                child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                    flex: 2,
                                                    child: tableTitleItem(
                                                        mHoldList[index - 1]
                                                            .code)),
                                                Expanded(
                                                    flex: 1,
                                                    child: tableTitleItem(
                                                        mHoldList[index - 1]
                                                                    .orderSide ==
                                                                SideType
                                                                    .SIDE_SELL
                                                            ? "卖出"
                                                            : "买入")),
                                                Expanded(
                                                    flex: 1,
                                                    child: tableTitleItem(
                                                        (mHoldList[index - 1]
                                                                    .quantity ??
                                                                0)
                                                            .toString())),
                                                Expanded(
                                                    flex: 1,
                                                    child: tableTitleItem(
                                                        (mHoldList[index - 1]
                                                                    .AvailableQty ??
                                                                0)
                                                            .toString())),
                                                Expanded(
                                                    flex: 2,
                                                    child: tableTitleItem(
                                                        Utils.d2SBySrc(
                                                            mHoldList[index - 1]
                                                                .open,
                                                            mHoldList[index - 1]
                                                                .FutureTickSize))),
                                                Expanded(
                                                    flex: 2,
                                                    child: tableTitleItem(
                                                        (mHoldList[index - 1]
                                                                    .CalculatePrice ??
                                                                0)
                                                            .toString())),
                                                Expanded(
                                                    flex: 2,
                                                    child: tableTitleItem(
                                                        Utils.d2SBySrc(
                                                            mHoldList[index - 1]
                                                                .floatProfit,
                                                            2))),
                                                Expanded(
                                                    flex: 2,
                                                    child: tableTitleItem(
                                                        Utils.d2SBySrc(
                                                            mHoldList[index - 1]
                                                                .margin,
                                                            2))),
                                                Expanded(
                                                    flex: 1,
                                                    child: tableTitleItem(
                                                        mHoldList[index - 1]
                                                            .CurrencyType)),
                                                Expanded(
                                                    flex: 3,
                                                    child: tableTitleItem(
                                                        mHoldList[index - 1]
                                                            .name)),
                                                Expanded(
                                                    flex: 3,
                                                    child: appTheme
                                                                .tradeDetailIndex ==
                                                            0
                                                        ? tablePlItem(
                                                            win: false,
                                                            lose: false)
                                                        : tableTitleItem(
                                                            mHoldList[index - 1]
                                                                .PositionNo)),
                                              ],
                                            )),
                                          ),
                                          onTap: () {
                                            if (mHoldList[index - 1].selected ==
                                                true) return;
                                            for (var element in mHoldList) {
                                              element.selected = false;
                                            }
                                            mHoldList[index - 1].selected =
                                                true;
                                            mHoldOrder = mHoldList[index - 1];
                                            if (mounted) setState(() {});
                                          },
                                        );
                                      }
                                    }))),
                      ),
                    ),
                  ],
                ))
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        onPressed: () {
                          appTheme.tradeAllIndex = 0;
                        },
                        child: Text(
                          "可\n撤",
                          style: TextStyle(
                              fontSize: 18,
                              color: appTheme.tradeAllIndex == 0
                                  ? Colors.yellow
                                  : appTheme.exchangeTextColor),
                        )),
                    const SizedBox(height: 20),
                    Button(
                      style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                          shape:
                              WidgetStatePropertyAll(RoundedRectangleBorder())),
                      onPressed: () {
                        appTheme.tradeAllIndex = 1;
                      },
                      child: Text(
                        "全\n部",
                        style: TextStyle(
                            fontSize: 18,
                            color: appTheme.tradeAllIndex == 1
                                ? Colors.yellow
                                : appTheme.exchangeTextColor),
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 15),
                        Button(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10)),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder())),
                            onPressed: delAllHold,
                            child: Text(
                              "全部撤单",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: appTheme.exchangeTextColor),
                            )),
                        const SizedBox(width: 15),
                        Button(
                            onPressed: delHold,
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10)),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder())),
                            child: Text(
                              "撤单",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: appTheme.exchangeTextColor),
                            )),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: appTheme.exchangeBgColor)),
                      margin: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                      child: Scrollbar(
                        key: UniqueKey(),
                        controller: secScrollController,
                        style: const ScrollbarThemeData(
                            thickness: 10,
                            padding: EdgeInsets.zero,
                            hoveringPadding: EdgeInsets.zero),
                        child: SingleChildScrollView(
                            controller: secScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                                width: 1.sw,
                                height: 168,
                                child: appTheme.tradeAllIndex == 0
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: mPendList.length + 1,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          if (index == 0) {
                                            return Row(
                                              children: [
                                                Expanded(
                                                    flex: 3,
                                                    child:
                                                        tableTitleItem("委托时间")),
                                                Expanded(
                                                    flex: 2,
                                                    child:
                                                        tableTitleItem("合约代码")),
                                                Expanded(
                                                    flex: 1,
                                                    child:
                                                        tableTitleItem("买卖")),
                                                Expanded(
                                                    flex: 1,
                                                    child:
                                                        tableTitleItem("开平")),
                                                Expanded(
                                                    flex: 1,
                                                    child:
                                                        tableTitleItem("价格")),
                                                Expanded(
                                                    flex: 2,
                                                    child:
                                                        tableTitleItem("委托数量")),
                                                Expanded(
                                                    flex: 2,
                                                    child:
                                                        tableTitleItem("成交数量")),
                                                Expanded(
                                                    flex: 1,
                                                    child:
                                                        tableTitleItem("币种")),
                                                Expanded(
                                                    flex: 2,
                                                    child:
                                                        tableTitleItem("订单来源")),
                                                Expanded(
                                                    flex: 2,
                                                    child:
                                                        tableTitleItem("状态")),
                                                Expanded(
                                                    flex: 5,
                                                    child:
                                                        tableTitleItem("错误信息")),
                                                Expanded(
                                                    flex: 4,
                                                    child:
                                                        tableTitleItem("委托号")),
                                                Expanded(
                                                    flex: 3,
                                                    child:
                                                        tableTitleItem("合约名称")),
                                              ],
                                            );
                                          } else {
                                            return GestureDetector(
                                              child: Container(
                                                color: mPendList[index - 1]
                                                        .selected
                                                    ? Colors.black
                                                        .withOpacity(0.2)
                                                    : Colors.transparent,
                                                child: IntrinsicHeight(
                                                    child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: tableTitleItem(
                                                            "${mPendList[index - 1].date ?? ""} ${mPendList[index - 1].time ?? ""}")),
                                                    Expanded(
                                                        flex: 3,
                                                        child: tableTitleItem(
                                                            mPendList[index - 1]
                                                                .code)),
                                                    Expanded(
                                                        flex: 2,
                                                        child: tableTitleItem(
                                                            mPendList[index - 1]
                                                                .bs)),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            PositionEffectType
                                                                .getName(mPendList[
                                                                        index -
                                                                            1]
                                                                    .OpenClose))),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "${mPendList[index - 1].price ?? ""}")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "${mPendList[index - 1].deleNum ?? "0"}")),
                                                    Expanded(
                                                        flex: 2,
                                                        child: tableTitleItem(
                                                            "${mPendList[index - 1].comNum ?? "0"}")),
                                                    Expanded(
                                                        flex: 2,
                                                        child: tableTitleItem(
                                                            mPendList[index - 1]
                                                                .CurrencyType)),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            OrderOpType.getName(
                                                                mPendList[
                                                                        index -
                                                                            1]
                                                                    .orderOpType))),
                                                    Expanded(
                                                        flex: 2,
                                                        child: tableTitleItem(
                                                            mPendList[index - 1]
                                                                .state)),
                                                    Expanded(
                                                        flex: 2,
                                                        child: tableTitleItem(
                                                            mPendList[index - 1]
                                                                .ErrorText)),
                                                    Expanded(
                                                        flex: 5,
                                                        child: tableTitleItem(
                                                            mPendList[index - 1]
                                                                .deleNo)),
                                                    Expanded(
                                                        flex: 4,
                                                        child: tableTitleItem(
                                                            mPendList[index - 1]
                                                                .name)),
                                                  ],
                                                )),
                                              ),
                                              onTap: () {
                                                if (mPendList[index - 1]
                                                        .selected ==
                                                    true) return;
                                                for (var element in mPendList) {
                                                  element.selected = false;
                                                }
                                                mPendList[index - 1].selected =
                                                    true;
                                                if (mounted) setState(() {});
                                              },
                                            );
                                          }
                                        })
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: mDelList.length + 1,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          if (index == 0) {
                                            return Row(
                                              children: [
                                                Expanded(
                                                    flex: 3,
                                                    child:
                                                        tableTitleItem("委托时间")),
                                                Expanded(
                                                    flex: 2,
                                                    child:
                                                        tableTitleItem("合约代码")),
                                                Expanded(
                                                    flex: 1,
                                                    child:
                                                        tableTitleItem("买卖")),
                                                Expanded(
                                                    flex: 1,
                                                    child:
                                                        tableTitleItem("开平")),
                                                Expanded(
                                                    flex: 1,
                                                    child:
                                                        tableTitleItem("价格")),
                                                Expanded(
                                                    flex: 2,
                                                    child:
                                                        tableTitleItem("委托数量")),
                                                Expanded(
                                                    flex: 2,
                                                    child:
                                                        tableTitleItem("成交数量")),
                                                Expanded(
                                                    flex: 1,
                                                    child:
                                                        tableTitleItem("币种")),
                                                Expanded(
                                                    flex: 2,
                                                    child:
                                                        tableTitleItem("订单来源")),
                                                Expanded(
                                                    flex: 2,
                                                    child:
                                                        tableTitleItem("状态")),
                                                Expanded(
                                                    flex: 5,
                                                    child:
                                                        tableTitleItem("错误信息")),
                                                Expanded(
                                                    flex: 4,
                                                    child:
                                                        tableTitleItem("委托号")),
                                                Expanded(
                                                    flex: 3,
                                                    child:
                                                        tableTitleItem("合约名称")),
                                              ],
                                            );
                                          } else {
                                            return GestureDetector(
                                              child: Container(
                                                color:
                                                    mDelList[index - 1].selected
                                                        ? Colors.black
                                                            .withOpacity(0.2)
                                                        : Colors.transparent,
                                                child: IntrinsicHeight(
                                                    child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: tableTitleItem(
                                                            "${mDelList[index - 1].date ?? ""} ${mDelList[index - 1].time ?? ""}")),
                                                    Expanded(
                                                        flex: 2,
                                                        child: tableTitleItem(
                                                            mDelList[index - 1]
                                                                .code)),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            mDelList[index - 1]
                                                                .bs)),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            PositionEffectType
                                                                .getName(mDelList[
                                                                        index -
                                                                            1]
                                                                    .OpenClose))),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "${mDelList[index - 1].price ?? ""}")),
                                                    Expanded(
                                                        flex: 2,
                                                        child: tableTitleItem(
                                                            "${mDelList[index - 1].deleNum ?? "0"}")),
                                                    Expanded(
                                                        flex: 2,
                                                        child: tableTitleItem(
                                                            "${mDelList[index - 1].comNum ?? "0"}")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            mDelList[index - 1]
                                                                .CurrencyType)),
                                                    Expanded(
                                                        flex: 2,
                                                        child: tableTitleItem(
                                                            OrderOpType.getName(
                                                                mDelList[index -
                                                                        1]
                                                                    .orderOpType))),
                                                    Expanded(
                                                        flex: 2,
                                                        child: tableTitleItem(
                                                            mDelList[index - 1]
                                                                .state)),
                                                    Expanded(
                                                        flex: 5,
                                                        child: tableTitleItem(
                                                            mDelList[index - 1]
                                                                .ErrorText)),
                                                    Expanded(
                                                        flex: 4,
                                                        child: tableTitleItem(
                                                            mDelList[index - 1]
                                                                .deleNo)),
                                                    Expanded(
                                                        flex: 3,
                                                        child: tableTitleItem(
                                                            mDelList[index - 1]
                                                                .name)),
                                                  ],
                                                )),
                                              ),
                                              onTap: () {
                                                if (mDelList[index - 1]
                                                        .selected ==
                                                    true) return;
                                                for (var element in mDelList) {
                                                  element.selected = false;
                                                }
                                                mDelList[index - 1].selected =
                                                    true;
                                                if (mounted) setState(() {});
                                              },
                                            );
                                          }
                                        }))),
                      ),
                    ),
                  ],
                ))
              ],
            ),
          ],
        ),
      ),
    ));
  }

  ///委托、可撤
  Widget orderDetails() {
    ScrollController scrollController = ScrollController();
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(15),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Button(
                    style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                        shape:
                            WidgetStatePropertyAll(RoundedRectangleBorder())),
                    onPressed: () {
                      appTheme.tradeAllIndex = 0;
                    },
                    child: Text(
                      "可\n撤",
                      style: TextStyle(
                          fontSize: 18,
                          color: appTheme.tradeAllIndex == 0
                              ? Colors.yellow
                              : appTheme.exchangeTextColor),
                    )),
                const SizedBox(height: 20),
                Button(
                  style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                  onPressed: () {
                    appTheme.tradeAllIndex = 1;
                  },
                  child: Text(
                    "全\n部",
                    style: TextStyle(
                        fontSize: 18,
                        color: appTheme.tradeAllIndex == 1
                            ? Colors.yellow
                            : appTheme.exchangeTextColor),
                  ),
                ),
              ],
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        onPressed: delAllHold,
                        child: Text(
                          "全部撤单",
                          style: TextStyle(
                              fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        onPressed: delHold,
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        child: Text(
                          "撤单",
                          style: TextStyle(
                              fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                  ],
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: appTheme.exchangeBgColor)),
                    margin: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                    child: Scrollbar(
                      controller: scrollController,
                      key: UniqueKey(),
                      style: const ScrollbarThemeData(
                          thickness: 10,
                          padding: EdgeInsets.zero,
                          hoveringPadding: EdgeInsets.zero),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                              width: 1.sw,
                              height: 168,
                              child: appTheme.tradeAllIndex == 0
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: mPendList.length + 1,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                  flex: 3,
                                                  child:
                                                      tableTitleItem("委托时间")),
                                              Expanded(
                                                  flex: 2,
                                                  child:
                                                      tableTitleItem("合约代码")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("买卖")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("开平")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("价格")),
                                              Expanded(
                                                  flex: 2,
                                                  child:
                                                      tableTitleItem("委托数量")),
                                              Expanded(
                                                  flex: 2,
                                                  child:
                                                      tableTitleItem("成交数量")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("币种")),
                                              Expanded(
                                                  flex: 2,
                                                  child:
                                                      tableTitleItem("订单来源")),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem("状态")),
                                              Expanded(
                                                  flex: 5,
                                                  child:
                                                      tableTitleItem("错误信息")),
                                              Expanded(
                                                  flex: 4,
                                                  child: tableTitleItem("委托号")),
                                              Expanded(
                                                  flex: 3,
                                                  child:
                                                      tableTitleItem("合约名称")),
                                            ],
                                          );
                                        } else {
                                          return GestureDetector(
                                            child: Container(
                                              color:
                                                  mPendList[index - 1].selected
                                                      ? Colors.black
                                                          .withOpacity(0.2)
                                                      : Colors.transparent,
                                              child: IntrinsicHeight(
                                                  child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                      flex: 3,
                                                      child: tableTitleItem(
                                                          "${mPendList[index - 1].date ?? ""} ${mPendList[index - 1].time ?? ""}")),
                                                  Expanded(
                                                      flex: 3,
                                                      child: tableTitleItem(
                                                          mPendList[index - 1]
                                                              .code)),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableTitleItem(
                                                          mPendList[index - 1]
                                                              .bs)),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          PositionEffectType
                                                              .getName(mPendList[
                                                                      index - 1]
                                                                  .OpenClose))),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          "${mPendList[index - 1].price ?? ""}")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          "${mPendList[index - 1].deleNum ?? "0"}")),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableTitleItem(
                                                          "${mPendList[index - 1].comNum ?? "0"}")),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableTitleItem(
                                                          mPendList[index - 1]
                                                              .CurrencyType)),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          OrderOpType.getName(
                                                              mPendList[
                                                                      index - 1]
                                                                  .orderOpType))),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableTitleItem(
                                                          mPendList[index - 1]
                                                              .state)),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableTitleItem(
                                                          mPendList[index - 1]
                                                              .ErrorText)),
                                                  Expanded(
                                                      flex: 5,
                                                      child: tableTitleItem(
                                                          mPendList[index - 1]
                                                              .deleNo)),
                                                  Expanded(
                                                      flex: 4,
                                                      child: tableTitleItem(
                                                          mPendList[index - 1]
                                                              .name)),
                                                ],
                                              )),
                                            ),
                                            onTap: () {
                                              if (mPendList[index - 1]
                                                      .selected ==
                                                  true) return;
                                              for (var element in mPendList) {
                                                element.selected = false;
                                              }
                                              mPendList[index - 1].selected =
                                                  true;
                                              if (mounted) setState(() {});
                                            },
                                          );
                                        }
                                      })
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: mDelList.length + 1,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                  flex: 3,
                                                  child:
                                                      tableTitleItem("委托时间")),
                                              Expanded(
                                                  flex: 2,
                                                  child:
                                                      tableTitleItem("合约代码")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("买卖")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("开平")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("价格")),
                                              Expanded(
                                                  flex: 2,
                                                  child:
                                                      tableTitleItem("委托数量")),
                                              Expanded(
                                                  flex: 2,
                                                  child:
                                                      tableTitleItem("成交数量")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("币种")),
                                              Expanded(
                                                  flex: 2,
                                                  child:
                                                      tableTitleItem("订单来源")),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem("状态")),
                                              Expanded(
                                                  flex: 5,
                                                  child:
                                                      tableTitleItem("错误信息")),
                                              Expanded(
                                                  flex: 4,
                                                  child: tableTitleItem("委托号")),
                                              Expanded(
                                                  flex: 3,
                                                  child:
                                                      tableTitleItem("合约名称")),
                                            ],
                                          );
                                        } else {
                                          return GestureDetector(
                                            child: Container(
                                              color:
                                                  mDelList[index - 1].selected
                                                      ? Colors.black
                                                          .withOpacity(0.2)
                                                      : Colors.transparent,
                                              child: IntrinsicHeight(
                                                  child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                      flex: 3,
                                                      child: tableTitleItem(
                                                          "${mDelList[index - 1].date ?? ""} ${mDelList[index - 1].time ?? ""}")),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableTitleItem(
                                                          mDelList[index - 1]
                                                              .code)),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          mDelList[index - 1]
                                                              .bs)),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          PositionEffectType
                                                              .getName(mDelList[
                                                                      index - 1]
                                                                  .OpenClose))),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          "${mDelList[index - 1].price ?? ""}")),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableTitleItem(
                                                          "${mDelList[index - 1].deleNum ?? "0"}")),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableTitleItem(
                                                          "${mDelList[index - 1].comNum ?? "0"}")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          mDelList[index - 1]
                                                              .CurrencyType)),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableTitleItem(
                                                          OrderOpType.getName(
                                                              mDelList[
                                                                      index - 1]
                                                                  .orderOpType))),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableTitleItem(
                                                          mDelList[index - 1]
                                                              .state)),
                                                  Expanded(
                                                      flex: 5,
                                                      child: tableTitleItem(
                                                          mDelList[index - 1]
                                                              .ErrorText)),
                                                  Expanded(
                                                      flex: 4,
                                                      child: tableTitleItem(
                                                          mDelList[index - 1]
                                                              .deleNo)),
                                                  Expanded(
                                                      flex: 3,
                                                      child: tableTitleItem(
                                                          mDelList[index - 1]
                                                              .name)),
                                                ],
                                              )),
                                            ),
                                            onTap: () {
                                              if (mDelList[index - 1]
                                                      .selected ==
                                                  true) return;
                                              for (var element in mDelList) {
                                                element.selected = false;
                                              }
                                              mDelList[index - 1].selected =
                                                  true;
                                              if (mounted) setState(() {});
                                            },
                                          );
                                        }
                                      }))),
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    ));
  }

  ///成交
  Widget dealDetails() {
    ScrollController scrollController = ScrollController();
    return Expanded(
        child: ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration:
            BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
        child: Scrollbar(
          key: UniqueKey(),
          controller: scrollController,
          style: const ScrollbarThemeData(
              thickness: 10,
              padding: EdgeInsets.zero,
              hoveringPadding: EdgeInsets.zero),
          child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                  width: 0.8.sw,
                  alignment: Alignment.topLeft,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: mComList.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Row(
                            children: [
                              Expanded(flex: 1, child: tableTitleItem("序号")),
                              Expanded(flex: 3, child: tableTitleItem("合约名称")),
                              Expanded(flex: 2, child: tableTitleItem("合约代码")),
                              Expanded(flex: 4, child: tableTitleItem("成交编号")),
                              Expanded(flex: 4, child: tableTitleItem("委托编号")),
                              Expanded(flex: 1, child: tableTitleItem("买卖")),
                              Expanded(flex: 1, child: tableTitleItem("开平")),
                              Expanded(flex: 1, child: tableTitleItem("数量")),
                              Expanded(flex: 2, child: tableTitleItem("成交价")),
                              Expanded(flex: 2, child: tableTitleItem("手续费")),
                              Expanded(flex: 4, child: tableTitleItem("成交时间")),
                            ],
                          );
                        } else {
                          return GestureDetector(
                            child: Container(
                              color: mComList[index - 1].selected
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.transparent,
                              child: IntrinsicHeight(
                                  child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: tableTitleItem(index.toString())),
                                  Expanded(
                                      flex: 3,
                                      child: tableTitleItem(
                                          mComList[index - 1].name)),
                                  Expanded(
                                      flex: 2,
                                      child: tableTitleItem(
                                          mComList[index - 1].code)),
                                  Expanded(
                                      flex: 4,
                                      child: tableTitleItem(
                                          mComList[index - 1].comNo)),
                                  Expanded(
                                      flex: 4,
                                      child: tableTitleItem(
                                          mComList[index - 1].deleNo)),
                                  Expanded(
                                      flex: 1,
                                      child: tableTitleItem(
                                          mComList[index - 1].bs)),
                                  Expanded(
                                      flex: 1,
                                      child: tableTitleItem(
                                          PositionEffectType.getName(
                                              mComList[index - 1].OpenClose))),
                                  Expanded(
                                      flex: 1,
                                      child: tableTitleItem(
                                          "${mComList[index - 1].comNum ?? 0}")),
                                  Expanded(
                                      flex: 2,
                                      child: tableTitleItem(
                                          "${mComList[index - 1].price ?? 0.0}")),
                                  Expanded(
                                      flex: 2,
                                      child: tableTitleItem(
                                          "${mComList[index - 1].FeeValue ?? 0.0}")),
                                  Expanded(
                                      flex: 4,
                                      child: tableTitleItem(
                                          "${mComList[index - 1].date ?? ""} ${mComList[index - 1].time ?? ""}")),
                                ],
                              )),
                            ),
                            onTap: () {
                              if (mComList[index - 1].selected == true) return;
                              for (var element in mComList) {
                                element.selected = false;
                              }
                              mComList[index - 1].selected = true;
                              if (mounted) setState(() {});
                            },
                          );
                        }
                      }))),
        ),
      ),
    ));
  }

  ///持仓
  Widget posDetails() {
    ScrollController scrollController = ScrollController();
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(left: 15, top: 5, right: 5),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Button(
                    style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                        shape:
                            WidgetStatePropertyAll(RoundedRectangleBorder())),
                    onPressed: () {
                      appTheme.tradeDetailIndex = 0;
                    },
                    child: Text(
                      "合\n计",
                      style: TextStyle(
                          fontSize: 18,
                          color: appTheme.tradeDetailIndex == 0
                              ? Colors.yellow
                              : appTheme.exchangeTextColor),
                    )),
                const SizedBox(height: 20),
                Button(
                  style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                  onPressed: () {
                    appTheme.tradeDetailIndex = 1;
                  },
                  child: Text(
                    "明\n细",
                    style: TextStyle(
                        fontSize: 18,
                        color: appTheme.tradeDetailIndex == 1
                            ? Colors.yellow
                            : appTheme.exchangeTextColor),
                  ),
                ),
              ],
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        onPressed: closeAllPos,
                        child: Text(
                          "全部平仓",
                          style: TextStyle(
                              fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        onPressed: quickClose,
                        child: Text(
                          "快捷平仓",
                          style: TextStyle(
                              fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        onPressed: quickBack,
                        child: Text(
                          "快捷反手",
                          style: TextStyle(
                              fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        onPressed: quickLock,
                        child: Text(
                          "快捷锁仓",
                          style: TextStyle(
                              fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        onPressed: plSetting,
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        child: Text(
                          "止盈止损",
                          style: TextStyle(
                              fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                  ],
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: appTheme.exchangeBgColor)),
                    margin: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                    child: Scrollbar(
                      key: UniqueKey(),
                      controller: scrollController,
                      style: const ScrollbarThemeData(
                          thickness: 10,
                          padding: EdgeInsets.zero,
                          hoveringPadding: EdgeInsets.zero),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                              width: 0.8.sw,
                              height: 168,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: mHoldList.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index == 0) {
                                      return Row(
                                        children: [
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("合约代码")),
                                          Expanded(
                                              flex: 1,
                                              child: tableTitleItem("买卖")),
                                          Expanded(
                                              flex: 1,
                                              child: tableTitleItem("数量")),
                                          Expanded(
                                              flex: 1,
                                              child: tableTitleItem("可平")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("开仓均价")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("计算价格")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("浮动盈亏")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("保证金占用")),
                                          Expanded(
                                              flex: 1,
                                              child: tableTitleItem("币种")),
                                          Expanded(
                                              flex: 3,
                                              child: tableTitleItem("合约名称")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("止盈止损")),
                                        ],
                                      );
                                    } else {
                                      return GestureDetector(
                                        child: Container(
                                          color: mHoldList[index - 1].selected
                                              ? Colors.black.withOpacity(0.2)
                                              : Colors.transparent,
                                          child: IntrinsicHeight(
                                              child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem(
                                                      mHoldList[index - 1]
                                                          .code)),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem(
                                                      mHoldList[index - 1]
                                                                  .orderSide ==
                                                              SideType.SIDE_SELL
                                                          ? "卖出"
                                                          : "买入")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem(
                                                      "${mHoldList[index - 1].quantity ?? 0}")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem(
                                                      "${mHoldList[index - 1].AvailableQty ?? 0}")),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem(
                                                      Utils.d2SBySrc(
                                                          mHoldList[index - 1]
                                                              .open,
                                                          mHoldList[index - 1]
                                                              .FutureTickSize))),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem(
                                                      "${mHoldList[index - 1].CalculatePrice ?? 0}")),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem(
                                                      Utils.d2SBySrc(
                                                          mHoldList[index - 1]
                                                              .floatProfit,
                                                          2))),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem(
                                                      Utils.d2SBySrc(
                                                          mHoldList[index - 1]
                                                              .margin,
                                                          2))),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem(
                                                      mHoldList[index - 1]
                                                          .CurrencyType)),
                                              Expanded(
                                                  flex: 3,
                                                  child: tableTitleItem(
                                                      mHoldList[index - 1]
                                                          .name)),
                                              Expanded(
                                                  flex: 2,
                                                  child: tablePlItem(
                                                      win: false, lose: false)),
                                            ],
                                          )),
                                        ),
                                        onTap: () {
                                          if (mHoldList[index - 1].selected ==
                                              true) return;
                                          for (var element in mHoldList) {
                                            element.selected = false;
                                          }
                                          mHoldList[index - 1].selected = true;
                                          mHoldOrder = mHoldList[index - 1];
                                          if (mounted) setState(() {});
                                        },
                                      );
                                    }
                                  }))),
                    ),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    ));
  }

  ///云条件单设置
  Widget cloudConditionContent() {
    bool open = true;
    int num = 1;
    double wtPrice = contract.lastPrice?.toDouble() ?? 0.0;
    double cfPrice = contract.lastPrice?.toDouble() ?? 0.0;
    double boxWidth = 108;
    double boxHeight = 34;
    double padWidth = 12;
    List typeList = ["市价", "限价"];
    String type = "市价";
    List priceList = ["最新价", "买价", "卖价"];
    String selectedPrice = "最新价";
    List priceTypeList = [">=", "<="];
    String priceType = ">=";
    List validList = ["当日有效", "永久有效"];
    String valid = "当日有效";

    return Row(
      children: [
        SizedBox(
          width: 388,
          child: StatefulBuilder(
            builder: (_, state) {
              return ListView(
                // shrinkWrap: true,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                      child: Text(
                        "云条件单",
                        style: TextStyle(color: Colors.yellow),
                      )),
                  Row(children: [
                    SizedBox(width: padWidth),
                    const Text("合约"),
                    Expanded(
                      child: Container(
                          height: boxHeight,
                          margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                          child: AutoSuggestBox(
                            controller:
                                TextEditingController(text: contract.code),
                            items: allContracts.map((e) {
                              return AutoSuggestBoxItem<Contract>(
                                value: e,
                                label: e.code ?? "--",
                              );
                            }).toList(),
                            onSelected: (item) {
                              if (item.value != null) {
                                unSubscriptionQuote();
                                contract = item.value!;
                                subscriptionQuote();
                              }
                            },
                          )),
                    ),
                    SizedBox(
                      width: padWidth,
                    ),
                    const Text("下单类型"),
                    Container(
                      height: boxHeight,
                      width: boxWidth,
                      margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: ComboBox<String>(
                        value: type,
                        isExpanded: true,
                        items: typeList.map((e) {
                          return ComboBoxItem<String>(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (v) => state(() => type = v!),
                      ),
                    ),
                    SizedBox(
                      width: padWidth,
                    ),
                  ]),
                  Row(children: [
                    SizedBox(width: padWidth),
                    const Text("委托价格"),
                    Expanded(
                        child: Container(
                      height: boxHeight,
                      margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: NumberBox(
                        value: wtPrice,
                        onChanged: (v) {},
                        smallChange: 0.1,
                        clearButton: false,
                      ),
                    )),
                    SizedBox(
                      width: padWidth,
                    ),
                    const Text("委托数量"),
                    Container(
                      height: boxHeight,
                      width: boxWidth,
                      margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: NumberBox(
                        value: num,
                        onChanged: (v) {},
                      ),
                    ),
                    SizedBox(
                      width: padWidth,
                    ),
                  ]),
                  Row(children: [
                    SizedBox(width: padWidth),
                    const Text("触发价格"),
                    Expanded(
                        child: Container(
                      height: boxHeight,
                      margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: ComboBox<String>(
                        value: selectedPrice,
                        isExpanded: true,
                        items: priceList.map((e) {
                          return ComboBoxItem<String>(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (v) => state(() => selectedPrice = v!),
                      ),
                    )),
                    Container(
                      height: boxHeight,
                      width: boxWidth * 0.6,
                      margin: EdgeInsets.fromLTRB(padWidth, 8, 0, 8),
                      child: ComboBox<String>(
                        value: priceType,
                        isExpanded: true,
                        items: priceTypeList.map((e) {
                          return ComboBoxItem<String>(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (v) => state(() => priceType = v!),
                      ),
                    ),
                    Container(
                      height: boxHeight,
                      width: boxWidth * 0.8,
                      margin: EdgeInsets.fromLTRB(padWidth, 8, 0, 8),
                      child: NumberBox(
                        value: cfPrice,
                        onChanged: (v) {},
                      ),
                    ),
                    SizedBox(
                      width: padWidth,
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: padWidth),
                      RadioButton(
                          checked: open,
                          onChanged: (checked) {
                            if (checked) {
                              state(() => open = checked);
                            }
                          }),
                      const Text("  开仓"),
                      const SizedBox(width: 28),
                      RadioButton(
                          checked: !open,
                          onChanged: (checked) {
                            if (checked) {
                              state(() => open = !checked);
                            }
                          }),
                      const Text("  平仓"),
                      Container(
                        height: boxHeight,
                        width: boxWidth,
                        margin: EdgeInsets.fromLTRB(padWidth, 0, padWidth, 0),
                        child: ComboBox<String>(
                          value: valid,
                          isExpanded: true,
                          items: validList.map((e) {
                            return ComboBoxItem<String>(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (v) => state(() => valid = v!),
                        ),
                      ),
                      Button(
                          style: const ButtonStyle(
                              padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5))),
                          onPressed: () {
                            type = "市价";
                            wtPrice = 0;
                            cfPrice = 0;
                            num = 1;
                            selectedPrice = "最新价";
                            priceType = ">=";
                            open = true;
                            valid = "当日有效";
                            state(() {});
                          },
                          child: const Text("复位")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  tradeBuyPrice,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 135,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "买入",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (contract.code == null) {
                            InfoBarUtils.showErrorDialog("请选择合约");
                            return;
                          }
                          int mOrderPriceType = Order_Type.ORDER_TYPE_MARKET,
                              mTimeInForce = 1,
                              mPositionEffect =
                                  PositionEffectType.PositionEffect_COVER;
                          int mTriggerPriceType = 1, mConditionType = 1;
                          if (type == "限价") {
                            mOrderPriceType = Order_Type.ORDER_TYPE_LIMIT;
                          }
                          if (valid == "永久有效") {
                            mTimeInForce = 2;
                          }
                          if (open) {
                            mPositionEffect =
                                PositionEffectType.PositionEffect_OPEN;
                          }
                          if (selectedPrice == "买价") {
                            mTriggerPriceType = 2;
                          } else if (selectedPrice == "卖价") {
                            mTriggerPriceType = 3;
                          }
                          if (priceType == "<=") {
                            mConditionType = 2;
                          }
                          reqAddCondition(
                              contract.exCode,
                              contract.subComCode,
                              contract.comType,
                              contract.subConCode,
                              mOrderPriceType,
                              mTimeInForce,
                              "",
                              SideType.SIDE_BUY,
                              wtPrice,
                              num,
                              mPositionEffect,
                              mTriggerPriceType,
                              mConditionType,
                              cfPrice);
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  tradeSalePrice,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 135,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "卖出",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (contract.code == null) {
                            InfoBarUtils.showErrorDialog("请选择合约");
                            return;
                          }
                          int mOrderPriceType = Order_Type.ORDER_TYPE_MARKET,
                              mTimeInForce = 1,
                              mPositionEffect =
                                  PositionEffectType.PositionEffect_COVER;
                          int mTriggerPriceType = 1, mConditionType = 1;
                          if (type == "限价") {
                            mOrderPriceType = Order_Type.ORDER_TYPE_LIMIT;
                          }
                          if (valid == "永久有效") {
                            mTimeInForce = 2;
                          }
                          if (open) {
                            mPositionEffect =
                                PositionEffectType.PositionEffect_OPEN;
                          }
                          if (selectedPrice == "买价") {
                            mTriggerPriceType = 2;
                          } else if (selectedPrice == "卖价") {
                            mTriggerPriceType = 3;
                          }
                          if (priceType == "<=") {
                            mConditionType = 2;
                          }
                          reqAddCondition(
                              contract.exCode,
                              contract.subComCode,
                              contract.comType,
                              contract.subConCode,
                              mOrderPriceType,
                              mTimeInForce,
                              "",
                              SideType.SIDE_SELL,
                              wtPrice,
                              num,
                              mPositionEffect,
                              mTriggerPriceType,
                              mConditionType,
                              cfPrice);
                        },
                      )
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  ///云条件单列表
  Widget cloudConditionDetails() {
    ScrollController scrollController = ScrollController();
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(5),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        onPressed: () async {
                          await rustDeskWinManager.newCondition("condition");
                        },
                        child: Text(
                          "条件单修改",
                          style: TextStyle(
                              fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder())),
                        onPressed: delCondition,
                        child: Text(
                          "条件单删除",
                          style: TextStyle(
                              fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                  ],
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: appTheme.exchangeBgColor)),
                    margin: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                    child: Scrollbar(
                      key: UniqueKey(),
                      controller: scrollController,
                      style: const ScrollbarThemeData(
                          thickness: 10,
                          padding: EdgeInsets.zero,
                          hoveringPadding: EdgeInsets.zero),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                              width: 1.2.sw,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: mConditionList.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index == 0) {
                                      return Row(
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child: tableTitleItem("条件单编号")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("状态")),
                                          Expanded(
                                              flex: 6,
                                              child: tableTitleItem("条件")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("下单类型")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("下单价格")),
                                          Expanded(
                                              flex: 1,
                                              child: tableTitleItem("买卖")),
                                          Expanded(
                                              flex: 1,
                                              child: tableTitleItem("开平")),
                                          Expanded(
                                              flex: 1,
                                              child: tableTitleItem("数量")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("有效日期")),
                                          Expanded(
                                              flex: 3,
                                              child: tableTitleItem("备注")),
                                          Expanded(
                                              flex: 3,
                                              child: tableTitleItem("创建时间")),
                                          Expanded(
                                              flex: 3,
                                              child: tableTitleItem("触发时间")),
                                        ],
                                      );
                                    } else {
                                      String priceType = "";
                                      switch (
                                          mConditionList[index - 1].PriceType) {
                                        case 1:
                                          priceType = "最新价";
                                          break;
                                        case 2:
                                          priceType = "买价";
                                          break;
                                        case 3:
                                          priceType = "卖价";
                                          break;
                                      }
                                      String constr =
                                          "${mConditionList[index - 1].ContractName}(${mConditionList[index - 1].CommodityNo}${mConditionList[index - 1].ContractNo})";
                                      switch (mConditionList[index - 1]
                                          .ConditionType) {
                                        case 1:
                                          constr =
                                              "$constr $priceType>=${mConditionList[index - 1].ConditionPrice}";
                                          break;
                                        case 2:
                                          constr =
                                              "$constr $priceType<=${mConditionList[index - 1].ConditionPrice}";
                                          break;
                                      }
                                      String status = "";
                                      switch (
                                          mConditionList[index - 1].Status) {
                                        case 1:
                                          status = "未触发";
                                          break;
                                        case 2:
                                          status = "已删除";
                                          break;
                                        case 3:
                                          status = "到期删除";
                                          break;
                                        case 4:
                                          status = "已触发";
                                          break;
                                        case 5:
                                          status = "指令失败";
                                          break;
                                      }
                                      return GestureDetector(
                                        child: Container(
                                          color: mConditionList[index - 1]
                                                  .selected
                                              ? Colors.black.withOpacity(0.2)
                                              : Colors.transparent,
                                          child: IntrinsicHeight(
                                              child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                  flex: 3,
                                                  child: tableTitleItem(
                                                      mConditionList[index - 1]
                                                          .ConditionOrderNo)),
                                              Expanded(
                                                  flex: 2,
                                                  child:
                                                      tableTitleItem(status)),
                                              Expanded(
                                                  flex: 6,
                                                  child:
                                                      tableTitleItem(constr)),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem(
                                                      mConditionList[index - 1]
                                                                  .OrderType ==
                                                              Order_Type
                                                                  .ORDER_TYPE_MARKET
                                                          ? "市价"
                                                          : "限价")),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem(
                                                      "${mConditionList[index - 1].OrderPrice ?? 0}")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem(
                                                      mConditionList[index - 1]
                                                                  .OrderSide ==
                                                              SideType.SIDE_SELL
                                                          ? "卖出"
                                                          : "买入")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem(
                                                      PositionEffectType.getName(
                                                          mConditionList[
                                                                  index - 1]
                                                              .PositionEffect))),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem(
                                                      "${mConditionList[index - 1].OrderQty ?? 0}")),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem(
                                                      mConditionList[index - 1]
                                                                  .TimeInForce ==
                                                              1
                                                          ? "当日有效"
                                                          : "永久有效")),
                                              Expanded(
                                                  flex: 3,
                                                  child: tableTitleItem(
                                                      mConditionList[index - 1]
                                                          .SubmitResultsMsg)),
                                              Expanded(
                                                  flex: 3,
                                                  child: tableTitleItem(
                                                      mConditionList[index - 1]
                                                          .CreateAt)),
                                              Expanded(
                                                  flex: 3,
                                                  child: tableTitleItem(
                                                      mConditionList[index - 1]
                                                          .UpdateAt)),
                                            ],
                                          )),
                                        ),
                                        onTap: () {
                                          if (mConditionList[index - 1]
                                                  .selected ==
                                              true) return;
                                          for (var element in mConditionList) {
                                            element.selected = false;
                                          }
                                          mConditionList[index - 1].selected =
                                              true;
                                          if (mounted) setState(() {});
                                        },
                                      );
                                    }
                                  }))),
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    ));
  }

  ///查询
  Widget queryWidget() {
    TextEditingController startController =
        TextEditingController(text: formatter.format(startTime));
    TextEditingController endController =
        TextEditingController(text: formatter.format(endTime));
    ScrollController scrollController = ScrollController();
    return Expanded(
      child: StatefulBuilder(builder: (_, state) {
        return Row(
          children: [
            Container(
              width: 388,
              color: appTheme.commandBarColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: queryIndex == 0
                                                ? Colors.yellow
                                                : Colors.transparent))),
                                child: Text(
                                  "资金状况",
                                  style: TextStyle(
                                      color: queryIndex == 0
                                          ? Colors.yellow
                                          : appTheme.exchangeTextColor),
                                ),
                              ),
                              onTap: () => state(() => queryIndex = 0))),
                      Expanded(
                          child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: queryIndex == 1
                                                ? Colors.yellow
                                                : Colors.transparent))),
                                child: Text(
                                  "历史成交",
                                  style: TextStyle(
                                      color: queryIndex == 1
                                          ? Colors.yellow
                                          : appTheme.exchangeTextColor),
                                ),
                              ),
                              onTap: () => state(() => queryIndex = 1))),
                      Expanded(
                          child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: queryIndex == 2
                                                ? Colors.yellow
                                                : Colors.transparent))),
                                child: Text(
                                  "结算单",
                                  style: TextStyle(
                                      color: queryIndex == 2
                                          ? Colors.yellow
                                          : appTheme.exchangeTextColor),
                                ),
                              ),
                              onTap: () => state(() => queryIndex = 2))),
                      Expanded(
                          child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: queryIndex == 3
                                                ? Colors.yellow
                                                : Colors.transparent))),
                                child: Text(
                                  "出入金",
                                  style: TextStyle(
                                      color: queryIndex == 3
                                          ? Colors.yellow
                                          : appTheme.exchangeTextColor),
                                ),
                              ),
                              onTap: () => state(() => queryIndex = 3))),
                    ],
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("开始日期:",
                          style: TextStyle(
                              color: appTheme.exchangeTextColor, fontSize: 13)),
                      SizedBox(
                        width: 108,
                        child: TextBox(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              border: Border.all(color: Colors.yellow)),
                          controller: startController,
                          inputFormatters: [
                            FilteringTextInputFormatter(RegExp("[0-9 -:]"),
                                allow: true)
                          ],
                          suffix: IconButton(
                            icon: const Icon(FluentIcons.calendar),
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.only(right: 3))),
                            onPressed: () async {
                              await showOmniDateTimePicker(
                                context: context,
                                initialDate: startTime,
                                type: OmniDateTimePickerType.date,
                                borderRadius: BorderRadius.zero,
                                constraints: const BoxConstraints(
                                  maxWidth: 350,
                                  maxHeight: 380,
                                ),
                                transitionDuration:
                                    const Duration(milliseconds: 200),
                                barrierDismissible: true,
                              ).then((value) => {
                                    if (value != null)
                                      {
                                        startTime = value,
                                        startController.text =
                                            formatter.format(startTime),
                                        state(() {})
                                      }
                                  });
                            },
                          ),
                        ),
                      ),
                      Text("结束日期:",
                          style: TextStyle(
                              color: appTheme.exchangeTextColor, fontSize: 13)),
                      SizedBox(
                          width: 108,
                          child: TextBox(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                                border: Border.all(color: Colors.yellow)),
                            controller: endController,
                            inputFormatters: [
                              FilteringTextInputFormatter(RegExp("[0-9 -:]"),
                                  allow: true)
                            ],
                            suffix: IconButton(
                              icon: const Icon(FluentIcons.calendar),
                              style: const ButtonStyle(
                                  padding: WidgetStatePropertyAll(
                                      EdgeInsets.only(right: 3))),
                              onPressed: () async {
                                await showOmniDateTimePicker(
                                  context: context,
                                  initialDate: endTime,
                                  type: OmniDateTimePickerType.date,
                                  borderRadius: BorderRadius.zero,
                                  constraints: const BoxConstraints(
                                    maxWidth: 350,
                                    maxHeight: 380,
                                  ),
                                  transitionDuration:
                                      const Duration(milliseconds: 200),
                                  barrierDismissible: true,
                                ).then((value) => {
                                      if (value != null)
                                        {
                                          endTime = value,
                                          endController.text =
                                              formatter.format(endTime),
                                          state(() {})
                                        }
                                    });
                              },
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 38,
                  ),
                  Button(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.yellow),
                          padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 25)),
                          shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder())),
                      child: const Text(
                        "查询",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        if (queryIndex == 0) {
                          getCapitals();
                        } else if (queryIndex == 1) {
                          getFillRecord();
                        } else if (queryIndex == 2) {
                          getCapitals();
                          getFillRecord();
                          getCloseDetailed();
                          getPositionDetailed();
                          getPositionSummary();
                        } else if (queryIndex == 3) {
                          getCashReport();
                        }
                        state(() {});
                      })
                ],
              ),
            ),
            Expanded(
              child: queryIndex == 0
                  ? ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                          scrollbars: false,
                          physics: const AlwaysScrollableScrollPhysics()),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: appTheme.exchangeBgColor)),
                        child: Scrollbar(
                          key: UniqueKey(),
                          controller: scrollController,
                          style: const ScrollbarThemeData(
                              thickness: 10,
                              padding: EdgeInsets.zero,
                              hoveringPadding: EdgeInsets.zero),
                          child: SingleChildScrollView(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                  width: 0.8.sw,
                                  alignment: Alignment.topLeft,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: capitals.length + 1,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child:
                                                      tableTitleItem("初期资金")),
                                              Expanded(
                                                  flex: 1,
                                                  child:
                                                      tableTitleItem("期末资金")),
                                              Expanded(
                                                  flex: 1,
                                                  child:
                                                      tableTitleItem("用户权益")),
                                              Expanded(
                                                  flex: 1,
                                                  child:
                                                      tableTitleItem("可用资金")),
                                              Expanded(
                                                  flex: 1,
                                                  child:
                                                      tableTitleItem("保证金占用")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("出入金")),
                                              Expanded(
                                                  flex: 1,
                                                  child:
                                                      tableTitleItem("平仓盈亏")),
                                              Expanded(
                                                  flex: 1,
                                                  child:
                                                      tableTitleItem("浮动盈亏")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("手续费")),
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem("风险度")),
                                            ],
                                          );
                                        } else {
                                          return GestureDetector(
                                            child: Container(
                                              color:
                                                  capitals[index - 1].selected
                                                      ? Colors.black
                                                          .withOpacity(0.2)
                                                      : Colors.transparent,
                                              child: IntrinsicHeight(
                                                  child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          capitals[index - 1]
                                                                  .TermInitial
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              "0")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          capitals[index - 1]
                                                                  .TermEnd
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              "0")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          capitals[index - 1]
                                                                  .Equity
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              "0")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          capitals[index - 1]
                                                                  .Available1
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              "0")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          capitals[index - 1]
                                                                  .OccupyDeposit
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              "0")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          capitals[index - 1]
                                                                  .CashValue
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              "0")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          capitals[index - 1]
                                                                  .CloseProfit
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              "0")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          capitals[index - 1]
                                                                  .PositionFloat
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              "0")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          capitals[index - 1]
                                                                  .Fee
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              "0")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: tableTitleItem(
                                                          capitals[index - 1]
                                                                  .Equity
                                                                  ?.toStringAsFixed(
                                                                      2) ??
                                                              "0")),
                                                ],
                                              )),
                                            ),
                                            onTap: () {
                                              if (capitals[index - 1]
                                                      .selected ==
                                                  true) return;
                                              for (var element in capitals) {
                                                element.selected = false;
                                              }
                                              capitals[index - 1].selected =
                                                  true;
                                              if (mounted) setState(() {});
                                            },
                                          );
                                        }
                                      }))),
                        ),
                      ),
                    )
                  : queryIndex == 2
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: RichText(
                                text: const TextSpan(children: [
                                  TextSpan(text: "账户："),
                                  TextSpan(text: "姓名："),
                                  TextSpan(text: "日期：")
                                ]),
                              ),
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Button(
                                    style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10)),
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder())),
                                    onPressed: () {},
                                    child: Text(
                                      "资金状况",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: appTheme.exchangeTextColor),
                                    )),
                                const SizedBox(width: 15),
                                Button(
                                    style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10)),
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder())),
                                    onPressed: () {},
                                    child: Text(
                                      "成交记录",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: appTheme.exchangeTextColor),
                                    )),
                                const SizedBox(width: 15),
                                Button(
                                    style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10)),
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder())),
                                    onPressed: () {},
                                    child: Text(
                                      "平仓明细",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: appTheme.exchangeTextColor),
                                    )),
                                const SizedBox(width: 15),
                                Button(
                                    style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10)),
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder())),
                                    onPressed: () {},
                                    child: Text(
                                      "持仓明细",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: appTheme.exchangeTextColor),
                                    )),
                                const SizedBox(width: 15),
                                Button(
                                    onPressed: () {},
                                    style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10)),
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder())),
                                    child: Text(
                                      "持仓汇总",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: appTheme.exchangeTextColor),
                                    )),
                              ],
                            ),
                            Expanded(
                                child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(
                                  scrollbars: false,
                                  physics:
                                      const AlwaysScrollableScrollPhysics()),
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: appTheme.exchangeBgColor)),
                                child: Scrollbar(
                                  key: UniqueKey(),
                                  controller: scrollController,
                                  style: const ScrollbarThemeData(
                                      thickness: 10,
                                      padding: EdgeInsets.zero,
                                      hoveringPadding: EdgeInsets.zero),
                                  child: SingleChildScrollView(
                                      controller: scrollController,
                                      scrollDirection: Axis.horizontal,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: Container(
                                          width: 0.8.sw,
                                          alignment: Alignment.topLeft,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: 1,
                                              // itemCount: data.length + 1,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                // if (index == 0) {
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "初期资金")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "期末资金")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "用户权益")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "可用资金")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "保证金占用")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "出入金")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "平仓盈亏")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "浮动盈亏")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "手续费")),
                                                    Expanded(
                                                        flex: 1,
                                                        child: tableTitleItem(
                                                            "风险度")),
                                                  ],
                                                );
                                                // }
                                                // else {
                                                //   return GestureDetector(
                                                //     child: Container(
                                                //       color: data[index - 1].selected
                                                //           ? Colors.black.withOpacity(0.2)
                                                //           : Colors.transparent,
                                                //       child: IntrinsicHeight(
                                                //           child: Row(
                                                //             crossAxisAlignment: CrossAxisAlignment.stretch,
                                                //             children: [
                                                //               Expanded(flex: 1, child: tableItem(data[index - 1].OrderQty.toString())),
                                                //               Expanded(flex: 2, child: tableItem(data[index - 1].Account)),
                                                //               Expanded(flex: 3, child: tableItem(data[index - 1].SubmitResultsMsg)),
                                                //               Expanded(flex: 3, child: tableItem(data[index - 1].CreateAt)),
                                                //               Expanded(flex: 3, child: tableItem(data[index - 1].UpdateAt)),
                                                //               Expanded(flex: 2, child: buttonItem(data[index - 1].Id))
                                                //             ],
                                                //           )),
                                                //     ),
                                                //     onTap: () {
                                                //       // if (data[index - 1].selected == true) return;
                                                //       // for (var element in data) {
                                                //       //   element.selected = false;
                                                //       // }
                                                //       // data[index - 1].selected = true;
                                                //       // if (mounted) setState(() {});
                                                //     },
                                                //   );
                                                // }
                                              }))),
                                ),
                              ),
                            )),
                          ],
                        )
                      : queryIndex == 3
                          ? Container(
                              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: appTheme.exchangeBgColor)),
                              alignment: Alignment.topLeft,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: withdrawalRecord.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index == 0) {
                                      return Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: tableTitleItem("时间")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("入金")),
                                          Expanded(
                                              flex: 2,
                                              child: tableTitleItem("出金")),
                                        ],
                                      );
                                    } else {
                                      return GestureDetector(
                                        child: Container(
                                          color: withdrawalRecord[index - 1]
                                                  .selected
                                              ? Colors.black.withOpacity(0.2)
                                              : Colors.transparent,
                                          child: IntrinsicHeight(
                                              child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: tableTitleItem(
                                                      withdrawalRecord[
                                                              index - 1]
                                                          .Time
                                                          .toString())),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem(
                                                      withdrawalRecord[
                                                              index - 1]
                                                          .Currency)),
                                              Expanded(
                                                  flex: 2,
                                                  child: tableTitleItem(
                                                      withdrawalRecord[
                                                              index - 1]
                                                          .Currency))
                                            ],
                                          )),
                                        ),
                                        onTap: () {
                                          if (withdrawalRecord[index - 1]
                                                  .selected ==
                                              true) return;
                                          for (var element
                                              in withdrawalRecord) {
                                            element.selected = false;
                                          }
                                          withdrawalRecord[index - 1].selected =
                                              true;
                                          if (mounted) setState(() {});
                                        },
                                      );
                                    }
                                  }),
                            )
                          : Container(),
            )
          ],
        );
      }),
    );
  }

  Widget settingWidget() {
    return Expanded(
      child: StatefulBuilder(builder: (_, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  width: 3,
                                  color: settingIndex == 0
                                      ? Colors.yellow
                                      : Colors.transparent))),
                      child: Text(
                        "止盈止损",
                        style: TextStyle(
                            color: settingIndex == 0
                                ? Colors.yellow
                                : appTheme.exchangeTextColor),
                      ),
                    ),
                    onTap: () => state(() => settingIndex = 0)),
                GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  width: 3,
                                  color: settingIndex == 1
                                      ? Colors.yellow
                                      : Colors.transparent))),
                      child: Text(
                        "系统",
                        style: TextStyle(
                            color: settingIndex == 1
                                ? Colors.yellow
                                : appTheme.exchangeTextColor),
                      ),
                    ),
                    onTap: () => state(() => settingIndex = 1)),
              ],
            ),
            settingIndex == 0
                ? Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: exchangeList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 28),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 2,
                                                color: exchangeIndex == index
                                                    ? Colors.yellow
                                                    : Colors.transparent))),
                                    child: Text(
                                      exchangeList[index].exchangeNo ?? "--",
                                      style: TextStyle(
                                          color: exchangeIndex == index
                                              ? Colors.yellow
                                              : appTheme.exchangeTextColor),
                                    ),
                                  ),
                                  onTap: () => state(() {
                                    exchangeIndex = index;
                                    commodityList = Utils.getVariety(
                                        exchangeList[index].exchangeNo);
                                  }),
                                );
                              }),
                        ),
                        Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: commodityList.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == 0) {
                                    return Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: tableTitleItem("名称")),
                                        Expanded(
                                            flex: 3,
                                            child: tableTitleItem("代码")),
                                        Expanded(
                                            flex: 4,
                                            child: tableTitleItem("止损策略")),
                                        Expanded(
                                            flex: 4,
                                            child: tableTitleItem("有效期")),
                                        Expanded(
                                            flex: 3,
                                            child: tableTitleItem("跳价单位")),
                                        Expanded(
                                            flex: 3,
                                            child: tableTitleItem("止盈跳点数")),
                                        Expanded(
                                            flex: 3,
                                            child: tableTitleItem("止损跳点数")),
                                        Expanded(
                                            flex: 2,
                                            child: tableTitleItem("操作")),
                                      ],
                                    );
                                  } else {
                                    return GestureDetector(
                                      child: Container(
                                        color: Colors.transparent,
                                        child: IntrinsicHeight(
                                            child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                                flex: 3,
                                                child: tableTitleItem(
                                                    commodityList[index - 1]
                                                        .shortName)),
                                            Expanded(
                                                flex: 3,
                                                child: tableTitleItem(
                                                    commodityList[index - 1]
                                                        .commodityNo)),
                                            Expanded(
                                                flex: 4,
                                                child:
                                                    tableRadioItem("限价", "追踪")),
                                            Expanded(
                                                flex: 4,
                                                child:
                                                    tableRadioItem("当日", "永久")),
                                            Expanded(
                                                flex: 3,
                                                child: tableTitleItem(
                                                    commodityList[index - 1]
                                                        .commodityTickSize
                                                        ?.toString())),
                                            Expanded(
                                                flex: 3,
                                                child: tablePointItem()),
                                            Expanded(
                                                flex: 3,
                                                child: tablePointItem()),
                                            Expanded(
                                                flex: 2,
                                                child: tableOperateItem(index)),
                                          ],
                                        )),
                                      ),
                                      onTap: () {},
                                    );
                                  }
                                })),
                      ],
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        settingItem("是否提示下单确认", true),
                        settingItem("启动默认进入自选", false),
                        settingItem("是否显示精简模式", false),
                        settingItem("是否弹出交易弹窗", true),
                        settingItem("默认下单类型", true, yes: "限价", no: "市价"),
                        settingTypeItem("默认下单面板", 0,
                            yes: "快手下单", no: "三键下单", or: "传统下单"),
                        settingNotItem("成交提示音", "系统提示音"),
                      ],
                    ),
                  ),
            Expanded(child: Container()),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 15, 0),
              child: Button(
                  style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 5, horizontal: 15))),
                  onPressed: () {},
                  child: const Text("保存")),
            )
          ],
        );
      }),
    );
  }

  Widget settingItem(String title, bool checked,
      {String? yes, String? no, String? or}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Text(title, maxLines: 1)),
          Expanded(
              child: RadioButton(
                  checked: checked,
                  content: Text(yes ?? "是"),
                  onChanged: (v) {})),
          Expanded(
              child: RadioButton(
                  checked: !checked,
                  content: Text(no ?? "否"),
                  onChanged: (v) {})),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Widget settingTypeItem(String title, int index,
      {String? yes, String? no, String? or}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Text(title)),
          Expanded(
              child: RadioButton(
                  checked: index == 0,
                  content: Text(yes ?? "是"),
                  onChanged: (v) {})),
          Expanded(
              child: RadioButton(
                  checked: index == 1,
                  content: Text(no ?? "否"),
                  onChanged: (v) {})),
          Expanded(
              child: RadioButton(
                  checked: index == 2,
                  content: Text(or ?? "或"),
                  onChanged: (v) {})),
        ],
      ),
    );
  }

  Widget settingNotItem(String title, String content) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Text(title)),
          Expanded(
              child: RadioButton(
                  checked: true, content: Text(content), onChanged: (v) {})),
          Expanded(flex: 2, child: Container()),
        ],
      ),
    );
  }
}
