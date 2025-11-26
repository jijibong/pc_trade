import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Condition;
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:trade/model/user/user.dart';
import 'package:trade/page/trade/trade_logic.dart';
import '../../config/common.dart';
import '../../config/config.dart';
import '../../main.dart';
import '../../model/delegation/comOrder.dart';
import '../../model/delegation/res_comm_order.dart';
import '../../model/pl/pl.dart';
import '../../model/pl/pl_close_type.dart';
import '../../model/position/add_order.dart';
import '../../model/quote/commodity.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/order_type.dart';
import '../../model/quote/position_effect_type.dart';
import '../../model/quote/side_type.dart';
import '../../model/quote/time_in_force_type.dart';
import '../../model/trade/fund.dart';
import '../../model/trade/hold_order.dart';
import '../../model/trade/query/capital.dart';
import '../../model/trade/query/close_detail.dart';
import '../../model/trade/query/position_detail.dart';
import '../../model/trade/query/position_summary.dart';
import '../../model/trade/query/transaction_record.dart';
import '../../model/trade/query/withdrawal_record.dart';
import '../../model/trade/res_float_profit.dart';
import '../../model/trade/res_hold_order.dart';
import '../../server/condition/condition.dart';
import '../../server/login/login.dart';
import '../../server/pl/pl.dart';
import '../../server/trade/settle.dart';
import '../../util/dialog/mod_condition.dart';
import '../../util/dialog/pl_dialog.dart';
import '../../util/dialog/trade_dialog.dart';
import '../../util/dialog/trade_setting_dialog.dart';
import '../../util/http/http.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
import '../../util/theme/theme.dart';
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
  final ThemeController themeController = Get.find<ThemeController>();
  final TradeLogic tradeLogic = Get.put(TradeLogic());
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  List priceList = ["对手价", "排队价", "市价", "最新价", "超价"];
  TextEditingController lockTextEditingController = TextEditingController();

  List<Capital> capitals = [];
  List<CloseDetail> close = [];
  List<PositionDetail> positions = [];
  List<PositionSummary> positionSummary = [];
  List<TransactionRecord> transactionRecord = [];
  List<WithdrawalRecord> withdrawalRecord = [];

  int queryIndex = 0;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int settingIndex = 0;
  int exchangeIndex = 0;
  int tradeDetailIndex = 0;
  bool waiting = false;
  bool defaultTradeType = true;
  int defaultTradeMenu = 0; //默认下单面板
  LinkedScrollControllerGroup controllerGroup = LinkedScrollControllerGroup();
  ScrollController tradeDetailsTitleController = ScrollController(keepScrollOffset: true);
  ScrollController tradeDetailsItemController = ScrollController(keepScrollOffset: true);
  LinkedScrollControllerGroup delOrderControllerGroup = LinkedScrollControllerGroup();
  ScrollController delOrderTitleController = ScrollController(keepScrollOffset: true);
  ScrollController delOrderItemController = ScrollController(keepScrollOffset: true);
  LinkedScrollControllerGroup todayOrderControllerGroup = LinkedScrollControllerGroup();
  ScrollController todayOrderTitleController = ScrollController(keepScrollOffset: true);
  ScrollController todayOrderItemController = ScrollController(keepScrollOffset: true);
  LinkedScrollControllerGroup comControllerGroup = LinkedScrollControllerGroup();
  ScrollController comTitleController = ScrollController(keepScrollOffset: true);
  ScrollController comItemController = ScrollController(keepScrollOffset: true);
  LinkedScrollControllerGroup posControllerGroup = LinkedScrollControllerGroup();
  ScrollController posTitleController = ScrollController(keepScrollOffset: true);
  ScrollController posItemController = ScrollController(keepScrollOffset: true);
  LinkedScrollControllerGroup conditionControllerGroup = LinkedScrollControllerGroup();
  ScrollController conditionTitleController = ScrollController(keepScrollOffset: true);
  ScrollController conditionItemController = ScrollController(keepScrollOffset: true);
  TextEditingController textController = TextEditingController();
  TextEditingController contractController = TextEditingController();
  final conditionFlyoutController = FlyoutController();
  final flyoutController = FlyoutController();

  int windowId() {
    return widget.params["windowId"];
  }

  initData() async {
    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      if (call.method == kWindowEventNewRemoteDesktop) {
        lockTextEditingController.clear();
        windowOnTop(windowId());
      } else if (call.method == kWindowEventNewContract) {
        final args = jsonDecode(call.arguments);
        tradeLogic.contract.value = Contract.fromJson(args);
        contractController.text = tradeLogic.contract.value?.code ?? "";
        tradeLogic.refreshData();
        tradeLogic.queryInitMargin();
        tradeLogic.bsCondition();
      } else if (call.method == kWindowEventSwitchMode) {
        themeController.toggleTheme();
      } else if (call.method == kFundUpdateEvent) {
        final args = jsonDecode(call.arguments);
        ResFund mAccountInfo = ResFund.fromJson(args);
        tradeLogic.calcFloatProfit(mAccountInfo);
        tradeLogic.queryInitMargin();
      } else if (call.method == kPositionUpdateEvent) {
        if (waiting) return;
        waiting = true;
        Future.delayed(const Duration(seconds: 1), () {
          waiting = false;
          tradeLogic.requestHold();
          tradeLogic.bsCondition();
        });
      } else if (call.method == kPositionFloatEvent) {
        final args = jsonDecode(call.arguments);
        ResFloatProfit con = ResFloatProfit.fromJson(args);
        for (var hold in tradeLogic.mHoldList) {
          if (hold.noMap != null && hold.noMap!.containsKey(con.PositionNo)) {
            double floatP = 0;
            if (hold.detailList != null) {
              for (ResHoldOrder detail in hold.detailList!) {
                if (detail.PositionNo == con.PositionNo) {
                  detail.PositionProfit = con.PositionProfit;
                }
                floatP = floatP + (detail.PositionProfit ?? 0);
              }
              hold.floatProfit = floatP;
            }
          }
        }
        for (var hold in tradeLogic.mHoldDetailList) {
          if (hold.noMap != null && hold.noMap!.containsKey(con.PositionNo)) {
            double floatP = 0;
            if (hold.detailList != null) {
              for (ResHoldOrder detail in hold.detailList!) {
                if (detail.PositionNo == con.PositionNo) {
                  detail.PositionProfit = con.PositionProfit;
                }
                floatP = floatP + (detail.PositionProfit ?? 0);
              }
              hold.floatProfit = floatP;
            }
          }
        }
      } else if (call.method == kFillUpdateEvent) {
        final args = jsonDecode(call.arguments);
        ResComOrder event = ResComOrder.fromJson(args);
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
        tradeLogic.mComList.insert(0, order);
      }
    });

    await DesktopMultiWindow.invokeMethod(kMainWindowId, kTradeWindowId, {"id": kWindowId});

    String hold = widget.params['hold'];
    UserUtils.userJson = hold;
    UserUtils.currentUser = User.fromJson(jsonDecode(hold));
    String? baseUrl = await SpUtils.getString(SpKey.baseUrl);
    tradeLogic.exchangeList.value = await Utils.getAllExchange();
    defaultTradeType = await SpUtils.getBool(SpKey.defaultTradeType) ?? true;
    defaultTradeMenu = await SpUtils.getInt(SpKey.defaultTradeMenu) ?? 0;
    tradeLogic.num.value = await SpUtils.getInt(SpKey.defaultTradeNumber) ?? 1;
    String? commodity = await SpUtils.getString(SpKey.commodity);
    if (baseUrl != null) {
      Config.URL = baseUrl;
      HttpUtils();
      tradeLogic.getFund();
      tradeLogic.requestHold();
      tradeLogic.requestCancelDelOrder();
      tradeLogic.requestDelOrder();
    } else {
      InfoBarUtils.showErrorBar("获取交易地址失败，请重新登录！");
    }
    if (!defaultTradeType) {
      tradeLogic.price.value = "市价";
      textController.text = tradeLogic.price.value;
    }
    if (defaultTradeMenu != 0) {
      tradeLogic.tradeIndex.value = defaultTradeMenu;
    }

    if (widget.params['contract'] != null) {
      tradeLogic.contract.value = Contract.fromJson(jsonDecode(widget.params['contract']));
      contractController.text = tradeLogic.contract.value?.code ?? "";
      tradeLogic.refreshData();
      tradeLogic.queryInitMargin();
      tradeLogic.bsCondition();
    }

    String? contracts = await SpUtils.getString(SpKey.allContract);
    if (contracts != null) {
      List tmp = jsonDecode(contracts);
      tradeLogic.allContracts.addAll(tmp.map((e) => Contract.fromJson(e)).toList());
      MarketUtils.contractList = tradeLogic.allContracts;
    }
    if (commodity != null) {
      tradeLogic.commodityList.clear();
      List temp = jsonDecode(commodity);
      MarketUtils.commodityList = temp.map((e) => Commodity.fromJson(e)).toList();
      tradeLogic.initCommodityList.value = Utils.getVariety(tradeLogic.exchangeList[0].exchangeNo);
      tradeLogic.commodityList.addAll(tradeLogic.initCommodityList);
    }
  }

  initScrollController() {
    tradeDetailsTitleController = controllerGroup.addAndGet();
    tradeDetailsItemController = controllerGroup.addAndGet();
    delOrderTitleController = delOrderControllerGroup.addAndGet();
    delOrderItemController = delOrderControllerGroup.addAndGet();
    todayOrderTitleController = todayOrderControllerGroup.addAndGet();
    todayOrderItemController = todayOrderControllerGroup.addAndGet();
    comTitleController = comControllerGroup.addAndGet();
    comItemController = comControllerGroup.addAndGet();
    posTitleController = posControllerGroup.addAndGet();
    posItemController = posControllerGroup.addAndGet();
    conditionTitleController = conditionControllerGroup.addAndGet();
    conditionItemController = conditionControllerGroup.addAndGet();
  }

  /// 删除条件单
  void delCondition() async {
    for (var condition in tradeLogic.mConditionList) {
      if (condition.selected == true) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ContentDialog(
                style: ContentDialogThemeData(
                    padding: EdgeInsets.zero,
                    bodyPadding: EdgeInsets.zero,
                    decoration: BoxDecoration(color: themeController.theme.activeColor, borderRadius: BorderRadius.zero)),
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
                            Expanded(
                              child: Text(
                                Common.appName,
                                style: TextStyle(color: themeController.theme.activeColor),
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
                                Flexible(child: Text("确认要删除${condition.ConditionOrderNo}的条件单吗?")),
                              ],
                            )),
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          Button(
                            style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                                shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                            child: const Text(
                              "确定",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              Get.back();
                              await ConditionServer.delCondition(condition.Id ?? 0).then((value) {
                                if (value) {
                                  tradeLogic.qryCondition();
                                }
                              });
                            },
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Button(
                            style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                                shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
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

  ///全部撤单
  void delAllDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ContentDialog(
            style: ContentDialogThemeData(
                padding: EdgeInsets.zero,
                bodyPadding: EdgeInsets.zero,
                decoration: BoxDecoration(color: themeController.theme.activeColor, borderRadius: BorderRadius.zero)),
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
                        Expanded(
                          child: Text(
                            Common.appName,
                            style: TextStyle(color: themeController.theme.activeColor),
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
                            backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                            shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                        child: const Text(
                          "确定",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Get.back();
                          tradeLogic.delAllHold();
                        },
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Button(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                            shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
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

  /// 查询止盈止损
  Future<int> queryPLRecord(HoldOrder hold) async {
    int i = 0, j = 0;
    await PLServer.getHisPLRecord(hold.exCode, hold.subComCode, hold.subConCode, hold.comType, hold.orderSide).then((value) {
      if (value != null && value.isNotEmpty) {
        for (PLRecord v in value) {
          if (v.StopWin != 0) {
            i = 1;
          }
          if (v.StopLoss != 0 || v.FloatLoss != 0) {
            j = 1;
          }
        }
      }
    });
    if (i == 1 && j == 1) {
      return 3;
    } else if (i == 1) {
      return 1;
    } else if (j == 1) {
      return 2;
    }
    return 0;
  }

  ///止盈止损
  // void plSetting() async {
  //   if (mHoldOrder == null) {
  //     InfoBarUtils.showWarningDialog("请选择要止盈止损的持仓");
  //   } else {
  //     String mHold = jsonEncode(mHoldOrder);
  //     await rustDeskWinManager.newPL("pl", contract: UserUtils.userJson, hold: mHold);
  //   }
  // }

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
    await ConditionServer.addCondition(ExchangeNo, CommodityNo, CommodityType, ContractNo, OrderType, TimeInForce, ExpireTime, OrderSide, OrderPrice,
            OrderQty, PositionEffect, PriceType, ConditionType, ConditionPrice)
        .then((value) {
      if (value) {
        InfoBarUtils.showSuccessBar("添加条件单成功");
        tradeLogic.qryCondition();
      }
    });
  }

  ///资金状况
  Future getCapitals() async {
    capitals.clear();
    capitals = await SettleServer.getCapital(UserUtils.currentUser?.id, formatter.format(startTime), formatter.format(endTime), 1);
    if (mounted) setState(() {});
  }

  ///平仓明细
  Future getCloseDetailed() async {
    close.clear();
    close = await SettleServer.getCloseDetailed(UserUtils.currentUser?.id, formatter.format(startTime), formatter.format(endTime), 1);
    if (mounted) setState(() {});
  }

  ///持仓明细
  Future getPositionDetailed() async {
    positions.clear();
    positions = await SettleServer.getPositionDetailed(UserUtils.currentUser?.id, formatter.format(startTime), formatter.format(endTime), 1);
    if (mounted) setState(() {});
  }

  ///持仓汇总
  Future getPositionSummary() async {
    positionSummary.clear();
    positionSummary = await SettleServer.getPositionSummary(UserUtils.currentUser?.id, formatter.format(startTime), formatter.format(endTime), 1);
    if (mounted) setState(() {});
  }

  ///历史成交/成交记录
  Future getFillRecord() async {
    transactionRecord.clear();
    transactionRecord = await SettleServer.getFillRecord(UserUtils.currentUser?.id, formatter.format(startTime), formatter.format(endTime));
    if (mounted) setState(() {});
  }

  ///出入金
  Future getCashReport() async {
    withdrawalRecord.clear();
    withdrawalRecord = await SettleServer.getCashReport(UserUtils.currentUser?.id, formatter.format(startTime), formatter.format(endTime));
    if (mounted) setState(() {});
  }

  void startDragging(bool isMainWindow) {
    WindowController.fromWindowId(kWindowId!).startDragging();
  }

  void setMovable(bool isMainWindow, bool movable) {
    WindowController.fromWindowId(kWindowId!).setMovable(movable);
  }

  void loginOut() {
    Future.delayed(Duration.zero, () async {
      await DesktopMultiWindow.invokeMethod(kMainWindowId, kWindowEventHide, {"id": kWindowId});
      await WindowController.fromWindowId(kWindowId!).hide();
    });
  }

  @override
  void onWindowClose() async {
    await WindowController.fromWindowId(kWindowId!).hide();
    await DesktopMultiWindow.invokeMethod(kMainWindowId, kWindowEventHide, {"id": kWindowId});
    super.onWindowClose();
  }

  @override
  void initState() {
    DesktopMultiWindow.addListener(this);
    LoginServer.isLogin = true;
    initData();
    initScrollController();
    tradeLogic.loadTradeData();
    super.initState();
  }

  @override
  void dispose() {
    DesktopMultiWindow.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserUtils.appContext = context;
    return Container(
      width: 1.sw,
      color: Common.lightBgColor,
      child: Obx(() {
        return tradeLogic.lock.value
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("交易账号："),
                      SizedBox(
                        width: 150,
                        child: TextBox(
                          controller: TextEditingController(text: UserUtils.currentUser?.account ?? ""),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("交易密码："),
                      SizedBox(
                          width: 150,
                          child: TextBox(
                            obscureText: true,
                            controller: lockTextEditingController,
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Button(
                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3))),
                          child: const Text("解锁"),
                          onPressed: () async {
                            String? pwd = await SpUtils.getString(SpKey.password);
                            if (lockTextEditingController.text == pwd) {
                              tradeLogic.lock.value = false;
                              lockTextEditingController.clear();
                              if (mounted) setState(() {});
                            } else {
                              InfoBarUtils.showErrorBar("密码错误");
                            }
                          }),
                      const SizedBox(
                        width: 30,
                      ),
                      Button(
                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3))),
                          onPressed: () => loginOut(),
                          child: const Text("退出")),
                    ],
                  )
                ],
              )
            : NavigationView(
                appBar: NavigationAppBar(
                  automaticallyImplyLeading: false,
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
                      child: Container(
                        height: 50,
                        alignment: Alignment.centerLeft,
                        color: Colors.transparent,
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(text: UserUtils.currentUser?.nick ?? "", style: TextStyle(color: Common.commandTextColor)),
                            TextSpan(text: "您好，可用资金：", style: TextStyle(color: Common.commandTextColor)),
                            TextSpan(text: tradeLogic.mineAvailFunds.value, style: TextStyle(color: Common.contentDarkBgColor)),
                            TextSpan(text: "   用户权益：", style: TextStyle(color: Common.commandTextColor)),
                            TextSpan(text: tradeLogic.mineAllAssets.value, style: TextStyle(color: Common.contentDarkBgColor)),
                            TextSpan(text: "   平仓盈亏：", style: TextStyle(color: Common.commandTextColor)),
                            TextSpan(
                                text: "${tradeLogic.mineCloseProfit.value}",
                                style: TextStyle(color: tradeLogic.mineCloseProfit.value < 0 ? Common.lightDownColor : Common.quoteHighColor)),
                            TextSpan(text: "   手续费：", style: TextStyle(color: Common.commandTextColor)),
                            TextSpan(text: tradeLogic.mineFee.value, style: TextStyle(color: Common.contentDarkBgColor)),
                            TextSpan(text: "   浮动盈亏：", style: TextStyle(color: Common.commandTextColor)),
                            TextSpan(
                                text: "${tradeLogic.mineFloatPrice.value}",
                                style: TextStyle(color: tradeLogic.mineFloatPrice.value < 0 ? Common.lightDownColor : Common.quoteHighColor)),
                            TextSpan(text: "   占用保证金：", style: TextStyle(color: Common.commandTextColor)),
                            TextSpan(text: tradeLogic.mineOccMargin.value, style: TextStyle(color: Common.contentDarkBgColor)),
                            TextSpan(text: "   风险度：", style: TextStyle(color: Common.commandTextColor)),
                            TextSpan(text: "${tradeLogic.mineRiskDegree.value}%", style: TextStyle(color: Common.contentDarkBgColor)),
                          ]),
                        ),
                      )),
                  actions: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        IconButton(
                            icon: Image.asset(
                              "assets/images/icon_refresh@3x.png",
                              width: Common.iconImageWidth,
                            ),
                            style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10))),
                            onPressed: () {
                              tradeLogic.requestHold();
                              tradeLogic.requestDelOrder();
                              tradeLogic.requestCancelDelOrder();
                              tradeLogic.qryCondition();
                              tradeLogic.requestComOrder();
                              tradeLogic.queryPLRecord();
                            }),
                        IconButton(
                            icon: Image.asset(
                              "assets/images/icon_lock@3x.png",
                              width: Common.iconImageWidth,
                            ),
                            onPressed: () {
                              tradeLogic.lock.value = true;
                            }).marginSymmetric(horizontal: 10),
                        IconButton(
                          icon: Image.asset(
                            "assets/images/icon_vertical@3x.png",
                            width: Common.iconImageWidth,
                          ),
                          onPressed: () {
                            WindowController.fromWindowId(widget.params["windowId"]).minimize();
                          },
                        ),
                        IconButton(
                          icon: Image.asset(
                            "assets/images/icon_exit@3x.png",
                            width: Common.iconImageWidth,
                          ),
                          onPressed: () => loginOut(),
                        ).marginSymmetric(horizontal: 10),
                      ])),
                ),
                content: Row(
                  children: [
                    Container(
                      width: 0.32.sw,
                      decoration: BoxDecoration(color: Common.contentLightBgColor, borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.only(right: 5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Button(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll(tradeLogic.tradeIndex.value == 0 ? Common.tradeTypeButtonColor : Colors.transparent),
                                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
                                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                                  child: Text(
                                    "快捷",
                                    style: TextStyle(color: Common.contentDarkBgColor),
                                  ),
                                  onPressed: () {
                                    tradeLogic.tradeIndex.value = 0;
                                  }),
                              Button(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll(tradeLogic.tradeIndex.value == 1 ? Common.tradeTypeButtonColor : Colors.transparent),
                                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
                                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                                  child: Text(
                                    "三键",
                                    style: TextStyle(color: Common.contentDarkBgColor),
                                  ),
                                  onPressed: () {
                                    tradeLogic.tradeIndex.value = 1;
                                  }).marginSymmetric(horizontal: 10),
                              Button(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll(tradeLogic.tradeIndex.value == 2 ? Common.tradeTypeButtonColor : Colors.transparent),
                                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
                                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                                  child: Text(
                                    "传统",
                                    style: TextStyle(color: Common.contentDarkBgColor),
                                  ),
                                  onPressed: () {
                                    tradeLogic.tradeIndex.value = 2;
                                  }),
                              const Spacer(),
                              GestureDetector(
                                child: Image.asset(
                                  "assets/images/icon_fuwei@3x.png",
                                  width: Common.iconImageWidth,
                                ).marginOnly(right: 5),
                                onTap: () {
                                  tradeLogic.open.value = true;
                                  tradeLogic.auto.value = true;
                                  tradeLogic.num.value = 1;
                                  tradeLogic.price.value = "市价";
                                  tradeLogic.tradeSalePrice.value = tradeLogic.getLimitPrice(true).toString();
                                  tradeLogic.tradeBuyPrice.value = tradeLogic.getLimitPrice(false).toString();
                                },
                              ).marginOnly(right: 5),
                              GestureDetector(
                                child: Image.asset(
                                  "assets/images/icon_setting@3x.png",
                                  width: Common.iconImageWidth,
                                ).marginSymmetric(horizontal: 5),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return TradeSettingDialog().tradeSetting();
                                      });
                                },
                              ),
                            ],
                          ),
                          Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(vertical: 18),
                            child: FluentTheme(
                              // 手动提供主题上下文
                              data: FluentThemeData(), // 使用默认主题或自定义主题
                              child: AutoSuggestBox(
                                controller: contractController,
                                decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                leadingIcon: Text(
                                  "  合约",
                                  style: TextStyle(color: Common.commandTextColor),
                                ),
                                highlightColor: Colors.transparent,
                                unfocusedColor: Colors.transparent,
                                items: tradeLogic.allContracts.map((e) {
                                  return AutoSuggestBoxItem<Contract>(
                                    value: e,
                                    label: e.code ?? "--",
                                  );
                                }).toList(),
                                onSelected: (item) {
                                  if (item.value != null) {
                                    tradeLogic.contract.value = item.value!;
                                  }
                                },
                              ),
                            ),
                          ),
                          if (tradeLogic.tradeIndex.value == 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    RadioButton(
                                        checked: tradeLogic.open.value,
                                        style: RadioButtonThemeData(
                                          checkedDecoration: WidgetStateProperty.resolveWith((states) {
                                            return BoxDecoration(
                                              border: Border.all(
                                                color: Common.selectedRadioButtonColor,
                                                width: !states.isDisabled
                                                    ? states.isHovered && !states.isPressed
                                                        ? 4.4
                                                        : 6.0
                                                    : 5.0,
                                              ),
                                              shape: BoxShape.circle,
                                            );
                                          }),
                                        ),
                                        onChanged: (checked) {
                                          if (checked) {
                                            tradeLogic.open.value = checked;
                                          }
                                        }),
                                    const Text("  开仓")
                                  ],
                                ),
                                Row(
                                  children: [
                                    RadioButton(
                                        checked: !tradeLogic.open.value,
                                        style: RadioButtonThemeData(
                                          checkedDecoration: WidgetStateProperty.resolveWith((states) {
                                            return BoxDecoration(
                                              border: Border.all(
                                                color: Common.selectedRadioButtonColor,
                                                width: !states.isDisabled
                                                    ? states.isHovered && !states.isPressed
                                                        ? 4.4
                                                        : 6.0
                                                    : 5.0,
                                              ),
                                              shape: BoxShape.circle,
                                            );
                                          }),
                                        ),
                                        onChanged: (checked) {
                                          if (checked) {
                                            tradeLogic.open.value = !checked;
                                          }
                                        }),
                                    const Text("  平仓")
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Checkbox(
                                    //   checked: auto,
                                    //   onChanged: (bool? value) => state(() => auto = value ?? true),
                                    // ),
                                    RadioButton(
                                        checked: !tradeLogic.auto.value,
                                        style: RadioButtonThemeData(
                                          checkedDecoration: WidgetStateProperty.resolveWith((states) {
                                            return BoxDecoration(
                                              border: Border.all(
                                                color: Common.selectedRadioButtonColor,
                                                width: !states.isDisabled
                                                    ? states.isHovered && !states.isPressed
                                                        ? 4.4
                                                        : 6.0
                                                    : 5.0,
                                              ),
                                              shape: BoxShape.circle,
                                            );
                                          }),
                                        ),
                                        onChanged: (checked) {
                                          if (checked) {
                                            tradeLogic.auto.value = !checked;
                                          }
                                        }),
                                    const Text("  自动"),
                                  ],
                                ),
                              ],
                            ).marginOnly(bottom: 18),
                          if (tradeLogic.tradeIndex.value == 2)
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10), border: Border.all(color: Common.dialogContentBorderBgColor)),
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.only(bottom: 18),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "方向",
                                        style: TextStyle(color: Common.commandTextColor),
                                      ),
                                      RadioButton(
                                          checked: tradeLogic.dir.value,
                                          style: RadioButtonThemeData(
                                            checkedDecoration: WidgetStateProperty.resolveWith((states) {
                                              return BoxDecoration(
                                                border: Border.all(
                                                  color: Common.selectedRadioButtonColor,
                                                  width: !states.isDisabled
                                                      ? states.isHovered && !states.isPressed
                                                          ? 4.4
                                                          : 6.0
                                                      : 5.0,
                                                ),
                                                shape: BoxShape.circle,
                                              );
                                            }),
                                          ),
                                          onChanged: (checked) {
                                            if (checked) {
                                              tradeLogic.dir.value = checked;
                                            }
                                          }).marginOnly(left: 30),
                                      const Text("  买入"),
                                      RadioButton(
                                          checked: !tradeLogic.dir.value,
                                          style: RadioButtonThemeData(
                                            checkedDecoration: WidgetStateProperty.resolveWith((states) {
                                              return BoxDecoration(
                                                border: Border.all(
                                                  color: Common.selectedRadioButtonColor,
                                                  width: !states.isDisabled
                                                      ? states.isHovered && !states.isPressed
                                                          ? 4.4
                                                          : 6.0
                                                      : 5.0,
                                                ),
                                                shape: BoxShape.circle,
                                              );
                                            }),
                                          ),
                                          onChanged: (checked) {
                                            if (checked) {
                                              tradeLogic.dir.value = !checked;
                                            }
                                          }).marginOnly(left: 30),
                                      const Text("  卖出")
                                    ],
                                  ).marginOnly(bottom: 20),
                                  Row(
                                    children: [
                                      Text(
                                        "开平",
                                        style: TextStyle(color: Common.commandTextColor),
                                      ),
                                      RadioButton(
                                          checked: tradeLogic.open.value,
                                          style: RadioButtonThemeData(
                                            checkedDecoration: WidgetStateProperty.resolveWith((states) {
                                              return BoxDecoration(
                                                border: Border.all(
                                                  color: Common.selectedRadioButtonColor,
                                                  width: !states.isDisabled
                                                      ? states.isHovered && !states.isPressed
                                                          ? 4.4
                                                          : 6.0
                                                      : 5.0,
                                                ),
                                                shape: BoxShape.circle,
                                              );
                                            }),
                                          ),
                                          onChanged: (checked) {
                                            if (checked) {
                                              tradeLogic.open.value = checked;
                                            }
                                          }).marginOnly(left: 30),
                                      const Text("  开仓"),
                                      RadioButton(
                                          checked: !tradeLogic.open.value,
                                          style: RadioButtonThemeData(
                                            checkedDecoration: WidgetStateProperty.resolveWith((states) {
                                              return BoxDecoration(
                                                border: Border.all(
                                                  color: Common.selectedRadioButtonColor,
                                                  width: !states.isDisabled
                                                      ? states.isHovered && !states.isPressed
                                                          ? 4.4
                                                          : 6.0
                                                      : 5.0,
                                                ),
                                                shape: BoxShape.circle,
                                              );
                                            }),
                                          ),
                                          onChanged: (checked) {
                                            if (checked) {
                                              tradeLogic.open.value = !checked;
                                            }
                                          }).marginOnly(left: 30),
                                      const Text("  平仓")
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            height: 40,
                            margin: const EdgeInsets.only(bottom: 18),
                            child: NumberBox(
                              decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                              leadingIcon: Text(
                                "  数量",
                                style: TextStyle(color: Common.commandTextColor),
                              ),
                              highlightColor: Colors.transparent,
                              unfocusedColor: Colors.transparent,
                              value: tradeLogic.num.value,
                              min: 1,
                              max: 10000000,
                              clearButton: false,
                              onChanged: (v) => tradeLogic.num.value = v ?? 1,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RichText(
                                  text: TextSpan(children: [
                                TextSpan(text: "  买：", style: TextStyle(color: Colors.red)),
                                TextSpan(text: "可开 ", style: TextStyle(color: Common.commandTextColor)),
                                TextSpan(text: tradeLogic.tradeBuyCanOpen.value, style: TextStyle(color: Common.commandTextColor)),
                                TextSpan(text: "  可平 ", style: TextStyle(color: Common.commandTextColor)),
                                TextSpan(text: tradeLogic.tradeBuyCanClose.value, style: TextStyle(color: Common.commandTextColor))
                              ])),
                              RichText(
                                  text: TextSpan(children: [
                                TextSpan(text: "  卖：", style: TextStyle(color: Colors.green)),
                                TextSpan(text: "可开 ", style: TextStyle(color: Common.commandTextColor)),
                                TextSpan(text: tradeLogic.tradeSaleCanOpen.value, style: TextStyle(color: Common.commandTextColor)),
                                TextSpan(text: "  可平 ", style: TextStyle(color: Common.commandTextColor)),
                                TextSpan(text: tradeLogic.tradeSaleCanClose.value, style: TextStyle(color: Common.commandTextColor))
                              ])),
                            ],
                          ),
                          Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(vertical: 18),
                            child: my_combo.EditableComboBox<String>(
                              decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                              textController: textController,
                              autofocus: false,
                              prefix: Text(
                                "  价格",
                                style: TextStyle(color: Common.commandTextColor),
                              ),
                              value: tradeLogic.price.value,
                              mathValue: double.tryParse(tradeLogic.price.value) ?? tradeLogic.contract.value?.lastPrice?.toDouble(),
                              items: priceList.map<my_combo.ComboBoxItem<String>>((e) {
                                return my_combo.ComboBoxItem<String>(
                                  value: e,
                                  child: Text('$e'),
                                );
                              }).toList(),
                              onChanged: (v) {
                                tradeLogic.price.value = v!;
                                tradeLogic.tradeSalePrice.value = tradeLogic.getLimitPrice(true).toString();
                                tradeLogic.tradeBuyPrice.value = tradeLogic.getLimitPrice(false).toString();
                              },
                              onTextChanged: (text) {
                                tradeLogic.price.value = text;
                                tradeLogic.tradeSalePrice.value = tradeLogic.getLimitPrice(true).toString();
                                tradeLogic.tradeBuyPrice.value = tradeLogic.getLimitPrice(false).toString();
                              },
                              updateChange: (v) {
                                tradeLogic.price.value = v!;
                                tradeLogic.tradeSalePrice.value = tradeLogic.getLimitPrice(true).toString();
                                tradeLogic.tradeBuyPrice.value = tradeLogic.getLimitPrice(false).toString();
                              },
                              onFieldSubmitted: (String text) {
                                tradeLogic.price.value = text;
                                tradeLogic.tradeSalePrice.value = tradeLogic.getLimitPrice(true).toString();
                                tradeLogic.tradeBuyPrice.value = tradeLogic.getLimitPrice(false).toString();
                                return tradeLogic.price.value;
                              },
                            ),
                          ),
                          tradeLogic.tradeIndex.value != 2
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      child: Container(
                                        decoration:
                                            BoxDecoration(color: Common.tradeButtonColor, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: tradeLogic.tradeIndex.value == 1 ? 15 : 40),
                                        child: Column(
                                          children: [
                                            AutoSizeText(
                                              tradeLogic.tradeBuyPrice.value,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(color: Common.quoteHighColor, borderRadius: BorderRadius.circular(22)),
                                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                              margin: const EdgeInsets.only(top: 10),
                                              child: AutoSizeText(
                                                "买入",
                                                style: TextStyle(color: Common.contentLightBgColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        if (tradeLogic.contract.value?.code == null) {
                                          InfoBarUtils.showErrorBar("请选择合约");
                                          return;
                                        }
                                        AddOrder order = AddOrder(
                                          name: tradeLogic.contract.value?.name,
                                          code: tradeLogic.contract.value?.code,
                                          ExchangeNo: tradeLogic.contract.value?.exCode,
                                          CommodityNo: tradeLogic.contract.value?.subComCode,
                                          ContractNo: tradeLogic.contract.value?.subConCode,
                                          CommodityType: tradeLogic.contract.value?.comType,
                                          OrderType: tradeLogic.getOrderType(),
                                          TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
                                          ExpireTime: "",
                                          OrderSide: SideType.SIDE_BUY,
                                          OrderPrice: tradeLogic.getLimitPrice(false),
                                          StopPrice: 0,
                                          OrderQty: tradeLogic.num.value,
                                          PositionEffect: tradeLogic.open.value
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
                                        decoration:
                                            BoxDecoration(color: Common.tradeButtonColor, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: tradeLogic.tradeIndex.value == 1 ? 15 : 40),
                                        child: Column(
                                          children: [
                                            AutoSizeText(
                                              tradeLogic.tradeSalePrice.value,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(color: Common.lightDownColor, borderRadius: BorderRadius.circular(22)),
                                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                              margin: const EdgeInsets.only(top: 10),
                                              child: AutoSizeText(
                                                "卖出",
                                                style: TextStyle(color: Common.contentLightBgColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        if (tradeLogic.contract.value?.code == null) {
                                          InfoBarUtils.showErrorBar("请选择合约");
                                          return;
                                        }
                                        AddOrder order = AddOrder(
                                          name: tradeLogic.contract.value?.name,
                                          code: tradeLogic.contract.value?.code,
                                          ExchangeNo: tradeLogic.contract.value?.exCode,
                                          CommodityNo: tradeLogic.contract.value?.subComCode,
                                          ContractNo: tradeLogic.contract.value?.subConCode,
                                          CommodityType: tradeLogic.contract.value?.comType,
                                          OrderType: tradeLogic.getOrderType(),
                                          TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
                                          ExpireTime: "",
                                          OrderSide: SideType.SIDE_SELL,
                                          OrderPrice: tradeLogic.getLimitPrice(true),
                                          StopPrice: 0,
                                          OrderQty: tradeLogic.num.value,
                                          PositionEffect: tradeLogic.open.value
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
                                    if (tradeLogic.tradeIndex.value == 1)
                                      GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Common.tradeButtonColor, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                          padding: const EdgeInsets.all(15),
                                          child: Column(
                                            children: [
                                              AutoSizeText(
                                                tradeLogic.tradeClosePrice.value,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                              ),
                                              Container(
                                                decoration:
                                                    BoxDecoration(color: Common.tradeCloseButtonColor, borderRadius: BorderRadius.circular(22)),
                                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                                margin: const EdgeInsets.only(top: 10),
                                                child: AutoSizeText(
                                                  "平仓",
                                                  style: TextStyle(color: Common.contentDarkBgColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          if (tradeLogic.contract.value?.code == null) {
                                            InfoBarUtils.showErrorBar("请选择合约");
                                            return;
                                          }
                                          AddOrder order = AddOrder(
                                            name: tradeLogic.contract.value?.name,
                                            code: tradeLogic.contract.value?.code,
                                            ExchangeNo: tradeLogic.contract.value?.exCode,
                                            CommodityNo: tradeLogic.contract.value?.subComCode,
                                            ContractNo: tradeLogic.contract.value?.subConCode,
                                            CommodityType: tradeLogic.contract.value?.comType,
                                            OrderType: tradeLogic.getOrderType(),
                                            TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
                                            ExpireTime: "",
                                            OrderSide: SideType.SIDE_SELL,
                                            OrderPrice: tradeLogic.getLimitPrice(true),
                                            StopPrice: 0,
                                            OrderQty: tradeLogic.num.value,
                                            PositionEffect: tradeLogic.open.value
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
                                ).marginOnly(top: 10)
                              : SizedBox(
                                  width: double.infinity,
                                  child: Button(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                                        shape:
                                            const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(72)))),
                                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10))),
                                    onPressed: () {
                                      if (tradeLogic.contract.value?.code == null) {
                                        InfoBarUtils.showErrorBar("请选择合约");
                                        return;
                                      }
                                      AddOrder order = AddOrder(
                                        name: tradeLogic.contract.value?.name,
                                        code: tradeLogic.contract.value?.code,
                                        ExchangeNo: tradeLogic.contract.value?.exCode,
                                        CommodityNo: tradeLogic.contract.value?.subComCode,
                                        ContractNo: tradeLogic.contract.value?.subConCode,
                                        CommodityType: tradeLogic.contract.value?.comType,
                                        OrderType: tradeLogic.getOrderType(),
                                        TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
                                        ExpireTime: "",
                                        OrderSide: tradeLogic.dir.value ? SideType.SIDE_BUY : SideType.SIDE_SELL,
                                        OrderPrice: tradeLogic.getLimitPrice(!tradeLogic.dir.value),
                                        StopPrice: 0,
                                        OrderQty: tradeLogic.num.value,
                                        PositionEffect:
                                            tradeLogic.open.value ? PositionEffectType.PositionEffect_OPEN : PositionEffectType.PositionEffect_COVER,
                                      );
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return TradeDialog().addOrderDialog(order);
                                          });
                                    },
                                    child: Text(
                                      "下单",
                                      style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.bold),
                                    ),
                                  )).marginOnly(top: 10),
                          Expanded(
                              child: Center(
                                  child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Button(
                                  style: ButtonStyle(
                                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
                                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(11),
                                        side: BorderSide(color: Common.dialogContentBorderBgColor),
                                      ))),
                                  child: AutoSizeText(
                                    "设置",
                                    style: TextStyle(fontSize: 11.5, color: Common.contentDarkBgColor),
                                  ),
                                  onPressed: () {}),
                              Button(
                                      style: ButtonStyle(
                                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
                                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(11),
                                            side: BorderSide(color: Common.dialogContentBorderBgColor),
                                          ))),
                                      child: AutoSizeText(
                                        "查询",
                                        style: TextStyle(fontSize: 11.5, color: Common.contentDarkBgColor),
                                      ),
                                      onPressed: () {})
                                  .marginSymmetric(horizontal: 20),
                              Button(
                                  style: ButtonStyle(
                                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
                                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(11),
                                        side: BorderSide(color: Common.dialogContentBorderBgColor),
                                      ))),
                                  child: AutoSizeText(
                                    "高级下单",
                                    style: TextStyle(fontSize: 11.5, color: Common.contentDarkBgColor),
                                  ),
                                  onPressed: () async {
                                    if (tradeLogic.contract.value?.code == null) {
                                      InfoBarUtils.showErrorBar("请选择合约");
                                      return;
                                    }
                                    tradeLogic.contract.value?.canOpenBuy = tradeLogic.tradeBuyCanOpen.value;
                                    tradeLogic.contract.value?.canOpenSale = tradeLogic.tradeSaleCanOpen.value;
                                    await rustDeskWinManager.newAdvancedOrder("advancedOrder", hold: jsonEncode(tradeLogic.contract.value?.toJson()));
                                    // Get.dialog(AdvancedOrderDialog().orderDialog(tradeLogic.contract.value), useSafeArea: false);
                                  }),
                            ],
                          )))
                        ],
                      ),
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(color: Common.contentLightBgColor, borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buttonWidget("持仓", tradeLogic.posIndex.value == 0, () {
                                    tradeLogic.posIndex.value = 0;
                                    tradeLogic.requestHold();
                                  }),
                                  buttonWidget("条件单", tradeLogic.posIndex.value == 1, () {
                                    tradeLogic.posIndex.value = 1;
                                    tradeLogic.qryCondition();
                                  }),
                                  buttonWidget("盈损单", tradeLogic.posIndex.value == 2, () {
                                    tradeLogic.posIndex.value = 2;
                                    tradeLogic.queryPLRecord();
                                  }),
                                  const Spacer(),
                                  _buttonWidget("全平", () => tradeLogic.closeAllPos()),
                                  _buttonWidget("快平", () => tradeLogic.quickClose()).marginSymmetric(horizontal: 10),
                                  _buttonWidget("锁仓", () => tradeLogic.quickLock()),
                                  _buttonWidget("反手", () => tradeLogic.quickBack()).marginSymmetric(horizontal: 10),
                                  _buttonWidget("损盈", () {
                                    if (tradeLogic.hold.value == null) {
                                      InfoBarUtils.showInfoDialog("请选择需要设置损盈的单子");
                                      return;
                                    }
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return PLDialog().setCloudPl(tradeLogic.hold.value);
                                        });
                                  }),
                                ],
                              ).marginOnly(bottom: 10),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Common.dialogContentBorderBgColor, width: 0.5),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: posTitleController,
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        child: Container(
                                          width: tradeLogic.posIndex.value == 0 ? 0.7.sw : 1.sw,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration:
                                              BoxDecoration(border: Border(bottom: BorderSide(color: Common.checkBoxBorderLightColor, width: 1))),
                                          child: tradeLogic.posIndex.value == 0
                                              ? Row(children: [
                                                  Expanded(flex: 2, child: tableTitleItem("合约代码")),
                                                  Expanded(flex: 1, child: tableTitleItem("买卖")),
                                                  Expanded(flex: 1, child: tableTitleItem("数量")),
                                                  Expanded(flex: 1, child: tableTitleItem("可平")),
                                                  Expanded(flex: 2, child: tableTitleItem("开仓均价")),
                                                  Expanded(flex: 2, child: tableTitleItem("计算价格")),
                                                  Expanded(flex: 2, child: tableTitleItem("浮动盈亏")),
                                                  Expanded(flex: 2, child: tableTitleItem("保证金占用")),
                                                  Expanded(flex: 1, child: tableTitleItem("币种")),
                                                  Expanded(flex: 3, child: tableTitleItem("合约名称")),
                                                ])
                                              : tradeLogic.posIndex.value == 1
                                                  ? Row(children: [
                                                      Expanded(flex: 3, child: tableTitleItem("条件单编号")),
                                                      Expanded(flex: 2, child: tableTitleItem("状态")),
                                                      Expanded(flex: 5, child: tableTitleItem("条件")),
                                                      Expanded(flex: 2, child: tableTitleItem("下单类型")),
                                                      Expanded(flex: 2, child: tableTitleItem("下单价格")),
                                                      Expanded(flex: 2, child: tableTitleItem("买卖")),
                                                      Expanded(flex: 2, child: tableTitleItem("开平")),
                                                      Expanded(flex: 2, child: tableTitleItem("数量")),
                                                      Expanded(flex: 2, child: tableTitleItem("有效日期")),
                                                      Expanded(flex: 3, child: tableTitleItem("备注")),
                                                      Expanded(flex: 4, child: tableTitleItem("创建时间")),
                                                      Expanded(flex: 4, child: tableTitleItem("触发时间")),
                                                    ])
                                                  : Row(children: [
                                                      Expanded(flex: 3, child: tableTitleItem("创建时间")),
                                                      Expanded(flex: 1, child: tableTitleItem("状态")),
                                                      Expanded(flex: 1, child: tableTitleItem("品种")),
                                                      Expanded(flex: 1, child: tableTitleItem("合约代码")),
                                                      Expanded(flex: 1, child: tableTitleItem("类别")),
                                                      Expanded(flex: 2, child: tableTitleItem("触发价")),
                                                      Expanded(flex: 1, child: tableTitleItem("手数")),
                                                      Expanded(flex: 1, child: tableTitleItem("下单方式")),
                                                      Expanded(flex: 2, child: tableTitleItem("预计盈亏")),
                                                      Expanded(flex: 1, child: tableTitleItem("说明")),
                                                      Expanded(flex: 2, child: tableTitleItem("修改时间")),
                                                      Expanded(flex: 2, child: tableTitleItem("有效期")),
                                                      Expanded(flex: 2, child: tableTitleItem("编号")),
                                                    ]),
                                        ),
                                      ),
                                      Expanded(
                                        child: Scrollbar(
                                          controller: posItemController,
                                          key: UniqueKey(),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            controller: posItemController,
                                            child: SizedBox(
                                                width: tradeLogic.posIndex.value == 0 ? 0.7.sw : 1.sw,
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    controller: ScrollController(
                                                      keepScrollOffset: true,
                                                    ),
                                                    itemCount: tradeLogic.posIndex.value == 0
                                                        ? tradeLogic.mHoldDetailList.length
                                                        : tradeLogic.posIndex.value == 1
                                                            ? tradeLogic.mConditionList.length
                                                            : tradeLogic.mPlRecordList.length,
                                                    itemBuilder: (_, int index) {
                                                      String priceType = "";
                                                      String status = "";
                                                      String conStr = "";
                                                      if (tradeLogic.posIndex.value == 1) {
                                                        switch (tradeLogic.mConditionList[index].PriceType) {
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
                                                        switch (tradeLogic.mConditionList[index].ConditionType) {
                                                          case 1:
                                                            conStr = "$conStr $priceType>=${tradeLogic.mConditionList[index].ConditionPrice}";
                                                            break;
                                                          case 2:
                                                            conStr = "$conStr $priceType<=${tradeLogic.mConditionList[index].ConditionPrice}";
                                                            break;
                                                          default:
                                                            conStr =
                                                                "${tradeLogic.mConditionList[index].ContractName}(${tradeLogic.mConditionList[index].CommodityNo}${tradeLogic.mConditionList[index].ContractNo})";
                                                        }
                                                        switch (tradeLogic.mConditionList[index].Status) {
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
                                                      }
                                                      return GestureDetector(
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                                          decoration: BoxDecoration(
                                                            border: Border(bottom: BorderSide(color: Common.checkBoxBorderLightColor, width: 0.5)),
                                                          ),
                                                          child: IntrinsicHeight(
                                                            child: tradeLogic.posIndex.value == 0
                                                                ? Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                    children: [
                                                                      Expanded(
                                                                          flex: 2, child: tableContentItem(tradeLogic.mHoldDetailList[index].code)),
                                                                      Expanded(
                                                                          flex: 1,
                                                                          child: tableContentItem(
                                                                              tradeLogic.mHoldDetailList[index].orderSide == SideType.SIDE_SELL
                                                                                  ? "卖出"
                                                                                  : "买入")),
                                                                      Expanded(
                                                                          flex: 1,
                                                                          child: tableContentItem(
                                                                              (tradeLogic.mHoldDetailList[index].quantity ?? 0).toString())),
                                                                      Expanded(
                                                                          flex: 1,
                                                                          child: tableContentItem(
                                                                              (tradeLogic.mHoldDetailList[index].AvailableQty ?? 0).toString())),
                                                                      Expanded(
                                                                          flex: 2,
                                                                          child: tableContentItem(Utils.d2SBySrc(
                                                                              tradeLogic.mHoldDetailList[index].open,
                                                                              tradeLogic.mHoldDetailList[index].FutureTickSize))),
                                                                      Expanded(
                                                                          flex: 2,
                                                                          child: tableContentItem(
                                                                              (tradeLogic.mHoldDetailList[index].CalculatePrice ?? 0).toString())),
                                                                      Expanded(
                                                                          flex: 2,
                                                                          child: tableContentItem(
                                                                              Utils.d2SBySrc(tradeLogic.mHoldDetailList[index].floatProfit, 2),
                                                                              color: (tradeLogic.mHoldDetailList[index].floatProfit ?? 0) > 0
                                                                                  ? Common.quoteRedColor
                                                                                  : (tradeLogic.mHoldDetailList[index].floatProfit ?? 0) < 0
                                                                                      ? Common.quoteGreenColor
                                                                                      : null)),
                                                                      Expanded(
                                                                          flex: 2,
                                                                          child: tableContentItem(
                                                                              Utils.d2SBySrc(tradeLogic.mHoldDetailList[index].margin, 2))),
                                                                      Expanded(
                                                                          flex: 1,
                                                                          child: tableContentItem(tradeLogic.mHoldDetailList[index].CurrencyType)),
                                                                      Expanded(
                                                                          flex: 3, child: tableContentItem(tradeLogic.mHoldDetailList[index].name)),
                                                                    ],
                                                                  )
                                                                : tradeLogic.posIndex.value == 1
                                                                    ? FlyoutTarget(
                                                                        controller: conditionFlyoutController,
                                                                        child: Row(
                                                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                          children: [
                                                                            Expanded(
                                                                                flex: 3,
                                                                                child: tableContentItem(
                                                                                    tradeLogic.mConditionList[index].ConditionOrderNo)),
                                                                            Expanded(flex: 2, child: tableContentItem(status)),
                                                                            Expanded(flex: 5, child: tableContentItem(conStr)),
                                                                            Expanded(
                                                                                flex: 2,
                                                                                child: tableContentItem(tradeLogic.mConditionList[index].OrderType ==
                                                                                        Order_Type.ORDER_TYPE_MARKET
                                                                                    ? "市价"
                                                                                    : "限价")),
                                                                            Expanded(
                                                                                flex: 2,
                                                                                child: tableContentItem(
                                                                                    "${tradeLogic.mConditionList[index].OrderPrice ?? 0}")),
                                                                            Expanded(
                                                                                flex: 2,
                                                                                child: tableContentItem(
                                                                                    tradeLogic.mConditionList[index].OrderSide == SideType.SIDE_SELL
                                                                                        ? "卖出"
                                                                                        : "买入")),
                                                                            Expanded(
                                                                                flex: 2,
                                                                                child: tableContentItem(PositionEffectType.getName(
                                                                                    tradeLogic.mConditionList[index].PositionEffect))),
                                                                            Expanded(
                                                                                flex: 2,
                                                                                child: tableContentItem(
                                                                                    "${tradeLogic.mConditionList[index].OrderQty ?? 0}")),
                                                                            Expanded(
                                                                                flex: 2,
                                                                                child: tableContentItem(
                                                                                    tradeLogic.mConditionList[index].TimeInForce == 1
                                                                                        ? "当日有效"
                                                                                        : "永久有效")),
                                                                            Expanded(
                                                                                flex: 3,
                                                                                child: tableContentItem(
                                                                                    tradeLogic.mConditionList[index].SubmitResultsMsg)),
                                                                            Expanded(
                                                                                flex: 4,
                                                                                child: tableContentItem(tradeLogic.mConditionList[index].CreateAt)),
                                                                            Expanded(
                                                                                flex: 4,
                                                                                child: tableContentItem(tradeLogic.mConditionList[index].UpdateAt)),
                                                                          ],
                                                                        ))
                                                                    : FlyoutTarget(
                                                                        controller: flyoutController,
                                                                        child: Row(children: [
                                                                          Expanded(
                                                                              flex: 3,
                                                                              child: tableContentItem(tradeLogic.mPlRecordList[index].CreateAt)),
                                                                          Expanded(
                                                                              flex: 1,
                                                                              child: tableContentItem(
                                                                                  tradeLogic.mPlRecordList[index].State == 0 ? "暂停" : "运行",
                                                                                  color: tradeLogic.mPlRecordList[index].State == 0
                                                                                      ? Common.contentDarkBgColor
                                                                                      : Common.lightDownColor)),
                                                                          Expanded(
                                                                              flex: 1, child: tableContentItem(tradeLogic.hold.value?.subComCode)),
                                                                          Expanded(
                                                                              flex: 1, child: tableContentItem(tradeLogic.hold.value?.subConCode)),
                                                                          Expanded(flex: 1, child: tableContentItem("类别")),
                                                                          Expanded(
                                                                              flex: 2,
                                                                              child: tableContentItem(
                                                                                  "${tradeLogic.mPlRecordList[index].StopWin != 0 ? tradeLogic.mPlRecordList[index].StopWin : tradeLogic.mPlRecordList[index].StopLoss != 0 ? tradeLogic.mPlRecordList[index].StopLoss : (tradeLogic.mPlRecordList[index].FloatLoss ?? 0)}")),
                                                                          Expanded(
                                                                              flex: 1,
                                                                              child: tableContentItem(
                                                                                  "${tradeLogic.mPlRecordList[index].RealQty ?? "0"}")),
                                                                          Expanded(flex: 1, child: tableContentItem("--")),
                                                                          Expanded(flex: 2, child: tableContentItem("--")),
                                                                          Expanded(flex: 1, child: tableContentItem("--")),
                                                                          Expanded(flex: 2, child: tableContentItem("--")),
                                                                          Expanded(
                                                                              flex: 2,
                                                                              child: tableContentItem(
                                                                                  tradeLogic.mPlRecordList[index].CloseType == PLCloseType.Today
                                                                                      ? "当日有效"
                                                                                      : "永久有效")),
                                                                          Expanded(
                                                                              flex: 2,
                                                                              child:
                                                                                  tableContentItem("${tradeLogic.mPlRecordList[index].Id ?? "0"}")),
                                                                        ])),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          if (tradeLogic.posIndex.value == 0) {
                                                            if (tradeLogic.mHoldDetailList[index].selected == true) return;
                                                            for (var element in tradeLogic.mHoldDetailList) {
                                                              element.selected = false;
                                                            }
                                                            tradeLogic.mHoldDetailList[index].selected = true;
                                                            tradeLogic.hold.value = tradeLogic.mHoldDetailList[index];
                                                            tradeLogic.switchCon();
                                                            tradeLogic.queryPLRecord();
                                                          } else if (tradeLogic.posIndex.value == 1) {
                                                            if (tradeLogic.mConditionList[index].selected == true) return;
                                                            for (var element in tradeLogic.mConditionList) {
                                                              element.selected = false;
                                                            }
                                                            tradeLogic.mConditionList[index].selected = true;
                                                          } else if (tradeLogic.posIndex.value == 2) {
                                                            if (tradeLogic.mPlRecordList[index].selected == true) return;
                                                            for (var element in tradeLogic.mPlRecordList) {
                                                              element.selected = false;
                                                            }
                                                            tradeLogic.mPlRecordList[index].selected = true;
                                                          }
                                                        },
                                                        onSecondaryTapUp: (d) {
                                                          if (tradeLogic.posIndex.value == 1) {
                                                            conditionFlyoutController.showFlyout(
                                                                position: d.globalPosition,
                                                                builder: (flyoutContext) {
                                                                  return MenuFlyout(items: [
                                                                    MenuFlyoutItem(
                                                                      text: const Text('修改'),
                                                                      onPressed: () {
                                                                        showDialog(
                                                                            context: context,
                                                                            builder: (BuildContext context) {
                                                                              return ModConditionDialog()
                                                                                  .modDialog(context, tradeLogic.mConditionList[index]);
                                                                            });
                                                                      },
                                                                    ),
                                                                    MenuFlyoutItem(
                                                                      text: const Text('删除'),
                                                                      onPressed: () async {
                                                                        await ConditionServer.delCondition(tradeLogic.mConditionList[index].Id ?? 0)
                                                                            .then((value) {
                                                                          if (value) {
                                                                            tradeLogic.qryCondition();
                                                                          }
                                                                        });
                                                                      },
                                                                    ),
                                                                  ]);
                                                                });
                                                          } else if (tradeLogic.posIndex.value == 2) {
                                                            flyoutController.showFlyout(
                                                                position: d.globalPosition,
                                                                builder: (context) {
                                                                  return MenuFlyout(items: [
                                                                    MenuFlyoutItem(
                                                                      text: const Text('暂停'),
                                                                      onPressed: () {
                                                                        tradeLogic.enablePLRecord(tradeLogic.mPlRecordList[index], false);
                                                                      },
                                                                    ),
                                                                    MenuFlyoutItem(
                                                                      text: const Text('启动'),
                                                                      onPressed: () {
                                                                        tradeLogic.enablePLRecord(tradeLogic.mPlRecordList[index], true);
                                                                      },
                                                                    ),
                                                                    MenuFlyoutItem(
                                                                      text: const Text('修改'),
                                                                      onPressed: () {
                                                                        // tradeLogic.modifyPLRecord(tradeLogic.mPlRecordList[index]);
                                                                      },
                                                                    ),
                                                                    MenuFlyoutItem(
                                                                      text: const Text('删除'),
                                                                      onPressed: () {
                                                                        tradeLogic.delPLRecord(tradeLogic.mPlRecordList[index].Id);
                                                                      },
                                                                    ),
                                                                    const MenuFlyoutSeparator(),
                                                                    MenuFlyoutItem(
                                                                      text: const Text('刷新'),
                                                                      onPressed: () {
                                                                        tradeLogic.queryPLRecord();
                                                                      },
                                                                    ),
                                                                    const MenuFlyoutSeparator(),
                                                                    MenuFlyoutItem(
                                                                      text: const Text('暂停全部'),
                                                                      onPressed: () {
                                                                        for (var element in tradeLogic.mPlRecordList) {
                                                                          tradeLogic.enablePLRecord(element, false);
                                                                        }
                                                                      },
                                                                    ),
                                                                    MenuFlyoutItem(
                                                                      text: const Text('启动全部'),
                                                                      onPressed: () {
                                                                        for (var element in tradeLogic.mPlRecordList) {
                                                                          tradeLogic.enablePLRecord(element, true);
                                                                        }
                                                                      },
                                                                    ),
                                                                    MenuFlyoutItem(
                                                                      text: const Text('删除全部'),
                                                                      onPressed: () {
                                                                        for (var element in tradeLogic.mPlRecordList) {
                                                                          tradeLogic.delPLRecord(element.Id);
                                                                        }
                                                                      },
                                                                    ),
                                                                  ]);
                                                                });
                                                          }
                                                        },
                                                      );
                                                    })),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(color: Common.contentLightBgColor, borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    buttonWidget("可撤", tradeLogic.delIndex.value == 0, () => tradeLogic.delIndex.value = 0),
                                    buttonWidget("委托", tradeLogic.delIndex.value == 1, () => tradeLogic.delIndex.value = 1),
                                    buttonWidget("成交", tradeLogic.delIndex.value == 2, () {
                                      tradeLogic.delIndex.value = 2;
                                      tradeLogic.requestComOrder();
                                    }),
                                    const Spacer(),
                                    _buttonWidget("全撤", delAllDialog).marginOnly(right: 10),
                                    _buttonWidget("撤单", tradeLogic.delHold),
                                  ],
                                ).marginOnly(bottom: 10),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Common.dialogContentBorderBgColor, width: 1),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          controller: delOrderTitleController,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          child: Container(
                                            width: 1.sw,
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration:
                                                BoxDecoration(border: Border(bottom: BorderSide(color: Common.checkBoxBorderLightColor, width: 1))),
                                            child: tradeLogic.delIndex.value != 2
                                                ? Row(children: [
                                                    Expanded(flex: 4, child: tableTitleItem("委托时间")),
                                                    Expanded(flex: 2, child: tableTitleItem("合约代码")),
                                                    Expanded(flex: 1, child: tableTitleItem("买卖")),
                                                    Expanded(flex: 1, child: tableTitleItem("开平")),
                                                    Expanded(flex: 2, child: tableTitleItem("价格")),
                                                    Expanded(flex: 2, child: tableTitleItem("委托数量")),
                                                    Expanded(flex: 2, child: tableTitleItem("成交数量")),
                                                    Expanded(flex: 1, child: tableTitleItem("币种")),
                                                    Expanded(flex: 2, child: tableTitleItem("订单来源")),
                                                    Expanded(flex: 2, child: tableTitleItem("状态")),
                                                    Expanded(flex: 4, child: tableTitleItem("错误信息")),
                                                    Expanded(flex: 4, child: tableTitleItem("委托号")),
                                                    Expanded(flex: 3, child: tableTitleItem("合约名称")),
                                                  ])
                                                : Row(
                                                    children: [
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
                                                  ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Scrollbar(
                                            controller: delOrderItemController,
                                            key: UniqueKey(),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              controller: delOrderItemController,
                                              child: SizedBox(
                                                  width: 1.sw,
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      controller: ScrollController(
                                                        keepScrollOffset: true,
                                                      ),
                                                      itemCount: tradeLogic.delIndex.value == 0
                                                          ? tradeLogic.mPendList.length
                                                          : tradeLogic.delIndex.value == 1
                                                              ? tradeLogic.mDelList.length
                                                              : tradeLogic.mComList.length,
                                                      itemBuilder: (BuildContext context, int index) {
                                                        return GestureDetector(
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                            decoration: BoxDecoration(
                                                              border: Border(bottom: BorderSide(color: Common.checkBoxBorderLightColor, width: 0.5)),
                                                            ),
                                                            child: IntrinsicHeight(
                                                                child: tradeLogic.delIndex.value == 0
                                                                    ? Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                        children: [
                                                                          Expanded(
                                                                              flex: 4,
                                                                              child: tableContentItem(
                                                                                  "${tradeLogic.mPendList[index].date ?? ""} ${tradeLogic.mPendList[index].time ?? ""}")),
                                                                          Expanded(
                                                                              flex: 2, child: tableContentItem(tradeLogic.mPendList[index].code)),
                                                                          Expanded(
                                                                              flex: 1,
                                                                              child: tableContentItem(tradeLogic.mPendList[index].bs,
                                                                                  color: tradeLogic.mPendList[index].bs == "买入"
                                                                                      ? Colors.red
                                                                                      : Colors.green)),
                                                                          Expanded(
                                                                              flex: 1,
                                                                              child: tableContentItem(
                                                                                  PositionEffectType.getName(tradeLogic.mPendList[index].OpenClose))),
                                                                          Expanded(
                                                                              flex: 2,
                                                                              child: tableContentItem("${tradeLogic.mPendList[index].price ?? ""}")),
                                                                          Expanded(
                                                                              flex: 2,
                                                                              child:
                                                                                  tableContentItem("${tradeLogic.mPendList[index].deleNum ?? "0"}")),
                                                                          Expanded(
                                                                              flex: 2,
                                                                              child:
                                                                                  tableContentItem("${tradeLogic.mPendList[index].comNum ?? "0"}")),
                                                                          Expanded(
                                                                              flex: 1,
                                                                              child: tableContentItem(tradeLogic.mPendList[index].CurrencyType)),
                                                                          Expanded(
                                                                              flex: 2,
                                                                              child: tableContentItem(
                                                                                  OrderOpType.getName(tradeLogic.mPendList[index].orderOpType))),
                                                                          Expanded(
                                                                              flex: 2, child: tableContentItem(tradeLogic.mPendList[index].state)),
                                                                          Expanded(
                                                                              flex: 4,
                                                                              child: tableContentItem(tradeLogic.mPendList[index].ErrorText)),
                                                                          Expanded(
                                                                              flex: 4, child: tableContentItem(tradeLogic.mPendList[index].deleNo)),
                                                                          Expanded(
                                                                              flex: 3, child: tableContentItem(tradeLogic.mPendList[index].name)),
                                                                        ],
                                                                      )
                                                                    : tradeLogic.delIndex.value == 1
                                                                        ? Row(
                                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                            children: [
                                                                              Expanded(
                                                                                  flex: 4,
                                                                                  child: tableContentItem(
                                                                                      "${tradeLogic.mDelList[index].date ?? ""} ${tradeLogic.mDelList[index].time ?? ""}")),
                                                                              Expanded(
                                                                                  flex: 2, child: tableContentItem(tradeLogic.mDelList[index].code)),
                                                                              Expanded(
                                                                                  flex: 1,
                                                                                  child: tableContentItem(tradeLogic.mDelList[index].bs,
                                                                                      color: tradeLogic.mDelList[index].bs == "买入"
                                                                                          ? Colors.red
                                                                                          : Colors.green)),
                                                                              Expanded(
                                                                                  flex: 1,
                                                                                  child: tableContentItem(PositionEffectType.getName(
                                                                                      tradeLogic.mDelList[index].OpenClose))),
                                                                              Expanded(
                                                                                  flex: 2,
                                                                                  child:
                                                                                      tableContentItem("${tradeLogic.mDelList[index].price ?? ""}")),
                                                                              Expanded(
                                                                                  flex: 2,
                                                                                  child: tableContentItem(
                                                                                      "${tradeLogic.mDelList[index].deleNum ?? "0"}")),
                                                                              Expanded(
                                                                                  flex: 2,
                                                                                  child: tableContentItem(
                                                                                      "${tradeLogic.mDelList[index].comNum ?? "0"}")),
                                                                              Expanded(
                                                                                  flex: 1,
                                                                                  child: tableContentItem(tradeLogic.mDelList[index].CurrencyType)),
                                                                              Expanded(
                                                                                  flex: 2,
                                                                                  child: tableContentItem(
                                                                                      OrderOpType.getName(tradeLogic.mDelList[index].orderOpType))),
                                                                              Expanded(
                                                                                  flex: 2, child: tableContentItem(tradeLogic.mDelList[index].state)),
                                                                              Expanded(
                                                                                  flex: 4,
                                                                                  child: tableContentItem(tradeLogic.mDelList[index].ErrorText)),
                                                                              Expanded(
                                                                                  flex: 4,
                                                                                  child: tableContentItem(tradeLogic.mDelList[index].deleNo)),
                                                                              Expanded(
                                                                                  flex: 3, child: tableContentItem(tradeLogic.mDelList[index].name)),
                                                                            ],
                                                                          )
                                                                        : Row(
                                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                            children: [
                                                                              Expanded(
                                                                                  flex: 3, child: tableContentItem(tradeLogic.mComList[index].name)),
                                                                              Expanded(
                                                                                  flex: 2, child: tableContentItem(tradeLogic.mComList[index].code)),
                                                                              Expanded(
                                                                                  flex: 4, child: tableContentItem(tradeLogic.mComList[index].comNo)),
                                                                              Expanded(
                                                                                  flex: 4,
                                                                                  child: tableContentItem(tradeLogic.mComList[index].deleNo)),
                                                                              Expanded(
                                                                                  flex: 1, child: tableContentItem(tradeLogic.mComList[index].bs)),
                                                                              Expanded(
                                                                                  flex: 1,
                                                                                  child: tableContentItem(PositionEffectType.getName(
                                                                                      tradeLogic.mComList[index].OpenClose))),
                                                                              Expanded(
                                                                                  flex: 1,
                                                                                  child:
                                                                                      tableContentItem("${tradeLogic.mComList[index].comNum ?? 0}")),
                                                                              Expanded(
                                                                                  flex: 2,
                                                                                  child:
                                                                                      tableContentItem("${tradeLogic.mComList[index].price ?? 0.0}")),
                                                                              Expanded(
                                                                                  flex: 2,
                                                                                  child: tableContentItem(
                                                                                      "${tradeLogic.mComList[index].FeeValue ?? 0.0}")),
                                                                              Expanded(
                                                                                  flex: 4,
                                                                                  child: tableContentItem(
                                                                                      "${tradeLogic.mComList[index].date ?? ""} ${tradeLogic.mComList[index].time ?? ""}")),
                                                                            ],
                                                                          )),
                                                          ),
                                                          onTap: () {
                                                            if (tradeLogic.delIndex.value == 0) {
                                                              if (tradeLogic.mPendList[index].selected == true) return;
                                                              for (var element in tradeLogic.mPendList) {
                                                                element.selected = false;
                                                              }
                                                              tradeLogic.mPendList[index].selected = true;
                                                            } else if (tradeLogic.delIndex.value == 1) {
                                                              if (tradeLogic.mDelList[index].selected == true) return;
                                                              for (var element in tradeLogic.mDelList) {
                                                                element.selected = false;
                                                              }
                                                              tradeLogic.mDelList[index].selected = true;
                                                            } else if (tradeLogic.delIndex.value == 2) {
                                                              if (tradeLogic.mComList[index].selected == true) return;
                                                              for (var element in tradeLogic.mComList) {
                                                                element.selected = false;
                                                              }
                                                              tradeLogic.mComList[index].selected = true;
                                                            }
                                                          },
                                                        );
                                                      })),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ), //可撤/委托/成交
                      ],
                    )),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     tabItem("交易", 0),
                    //     tabItem("云条件单", 1),
                    //     tabItem("当日委托", 2),
                    //     tabItem("当日成交", 3),
                    //     tabItem("持仓", 4),
                    //     tabItem("结算单", 5),
                    //     tabItem("交易设置", 6),
                    //   ],
                    // ),
                    // Container(
                    //   color: themeController.theme.cardColor,
                    //   margin: const EdgeInsets.only(left: 5),
                    //   child: selectedIndex == 0 || selectedIndex == 2 || selectedIndex == 3 || selectedIndex == 4
                    //       ? tradeContent()
                    //       : selectedIndex == 1
                    //           ? cloudConditionContent()
                    //           : null,
                    // ),
                    // selectedIndex == 0
                    //     ? tradeDetails()
                    //     : selectedIndex == 1
                    //         ? cloudConditionDetails()
                    //         : selectedIndex == 2
                    //             ? orderDetails()
                    //             : selectedIndex == 3
                    //                 ? dealDetails()
                    //                 : selectedIndex == 4
                    //                     ? posDetails()
                    //                     : selectedIndex == 5
                    //                         ? queryWidget()
                    //                         : selectedIndex == 6
                    //                             ? settingWidget()
                    //                             : Container()
                  ],
                ),
              );
      }),
    );
  }

  Widget buttonWidget(String text, bool selected, Function() fun) {
    return Button(
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(selected ? Common.tradeTypeButtonColor : Colors.transparent),
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
        onPressed: fun,
        child: Text(
          text,
          style: TextStyle(color: selected ? Common.contentDarkBgColor : Common.commandTextColor, fontWeight: FontWeight.w800),
        ));
  }

  Widget _buttonWidget(String text, Function() fun) {
    return Button(
        style: ButtonStyle(
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
              side: BorderSide(color: Common.dialogContentBorderBgColor),
            ))),
        onPressed: fun,
        child: AutoSizeText(
          text,
          style: TextStyle(fontSize: 11.5, color: Common.contentDarkBgColor, fontWeight: FontWeight.w800),
        ));
  }

  Widget tableTitleItem(String text) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(color: Common.commandTextColor),
      ),
    );
  }

  Widget tableContentItem(String? text, {Color? color}) {
    return Container(
      alignment: Alignment.center,
      child: Tooltip(
          message: text ?? "--",
          style: const TooltipThemeData(preferBelow: true),
          child: Text(
            text ?? "--",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color ?? Common.contentDarkBgColor),
          )),
    );
  }

  Widget tablePlItem(int status) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(1),
      child: AnimatedFluentTheme(
          data: FluentThemeData(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: status == 1 || status == 3 ? Colors.red : Colors.grey,
                  child: const Text("盈", style: TextStyle(color: Colors.white)),
                ),
              ),
              CircleAvatar(
                radius: 15,
                backgroundColor: status == 2 || status == 3 ? Colors.green : Colors.grey,
                child: const Text("损", style: TextStyle(color: Colors.white)),
              ),
            ],
          )),
    );
  }

  Widget tableRadioItem(String check, String uncheck, int index, {bool? checked}) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
      alignment: Alignment.center,
      child: StatefulBuilder(builder: (_, state) {
        return Row(
          children: [
            RadioButton(
                checked: checked != false,
                content: Text(check),
                onChanged: (v) {
                  if (v) {
                    checked = true;
                    state(() {});
                  }
                }),
            RadioButton(
                checked: checked == false,
                content: Text(uncheck),
                onChanged: (v) {
                  if (v) {
                    checked = false;
                    state(() {});
                  }
                }),
          ],
        );
      }),
    );
  }

  Widget tablePointItem(int index, {int? value}) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
      child: StatefulBuilder(builder: (_, state) {
        return NumberBox(
          value: value ?? 0,
          min: 0,
          clearButton: false,
          onChanged: (v) {
            value = v ?? 0;
            // commodityList[index];
            state(() {});
          },
        );
      }),
    );
  }

  Widget tableOperateItem(int index) {
    return GestureDetector(
      child: Container(
          decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          child: Text(
            "重置",
            style: TextStyle(color: Colors.blue),
          )),
      onTap: () {
        tradeLogic.commodityList[index] = tradeLogic.initCommodityList[index];
        if (mounted) setState(() {});
      },
    );
  }

  // Widget tabItem(String title, int index) {
  //   return Expanded(
  //       child: GestureDetector(
  //     onTap: () {
  //       // selectedIndex = index;
  //       if (index == 0) {
  //         requestHold();
  //         requestDelOrder();
  //         requestCancelDelOrder();
  //       } else if (index == 1) {
  //         qryCondition(0);
  //       } else if (index == 2) {
  //         requestDelOrder();
  //         requestCancelDelOrder();
  //       } else if (index == 3) {
  //         requestComOrder();
  //       } else if (index == 4) {
  //         requestHold();
  //       }
  //       if (mounted) setState(() {});
  //     },
  //     child: Container(
  //       width: 138,
  //       alignment: Alignment.center,
  //       // color: selectedIndex == index ? themeController.theme.cardColor : Colors.transparent,
  //       child: Text(
  //         title,
  //         textAlign: TextAlign.center,
  //         style: const TextStyle(fontSize: 17),
  //       ),
  //     ),
  //   ));
  // }

  ///下单
  // Widget tradeContent() {
  //   TextEditingController controller = TextEditingController(text: tradeLogic.contract.value.code);
  //   List<Tab> tabs = [
  //     Tab(
  //       text: Text(
  //         '快手下单',
  //         textAlign: TextAlign.center,
  //         style: TextStyle(fontSize: 14, color: tradeLogic.tradeIndex.value == 0 ? Colors.yellow : themeController.theme.selectionColor),
  //       ),
  //       body: SizedBox(
  //         width: 388,
  //         height: 500,
  //         child: StatefulBuilder(
  //           builder: (_, state) {
  //             globalStateFirst = state;
  //             return ListView(
  //               shrinkWrap: true,
  //               children: [
  //                 Row(children: [
  //                   SizedBox(width: padWidth),
  //                   const Text("合约"),
  //                   Container(
  //                     width: boxWidth,
  //                     height: 28,
  //                     margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
  //                     child: AutoSuggestBox(
  //                       controller: controller,
  //                       items: allContracts.map((e) {
  //                         return AutoSuggestBoxItem<Contract>(
  //                           value: e,
  //                           label: e.code ?? "--",
  //                         );
  //                       }).toList(),
  //                       onSelected: (item) {
  //                         if (item.value != null) {
  //                           unSubscriptionQuote();
  //                           tradeLogic.contract.value = item.value!;
  //                           subscriptionQuote();
  //                         }
  //                       },
  //                     ),
  //                   ),
  //                   const SizedBox(
  //                     width: 58,
  //                   ),
  //                   Button(
  //                       style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 3))),
  //                       onPressed: () {
  //                         open = true;
  //                         auto = true;
  //                         num = 1;
  //                         price = "市价";
  //                         state(() {});
  //                       },
  //                       child: const Text("复位")),
  //                 ]),
  //                 Row(
  //                   children: [
  //                     SizedBox(width: padWidth),
  //                     RadioButton(
  //                         checked: open,
  //                         onChanged: (checked) {
  //                           if (checked) {
  //                             state(() => open = checked);
  //                           }
  //                         }),
  //                     const Text("  开仓"),
  //                     const SizedBox(width: 28),
  //                     RadioButton(
  //                         checked: !open,
  //                         onChanged: (checked) {
  //                           if (checked) {
  //                             state(() => open = !checked);
  //                           }
  //                         }),
  //                     const Text("  平仓"),
  //                     const SizedBox(width: 28),
  //                     Checkbox(
  //                       checked: auto,
  //                       onChanged: (bool? value) => state(() => auto = value ?? true),
  //                     ),
  //                     const Text("  自动"),
  //                   ],
  //                 ),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     SizedBox(width: padWidth),
  //                     const Text("数量"),
  //                     Container(
  //                       width: boxWidth,
  //                       height: 38,
  //                       margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
  //                       child: NumberBox(
  //                         value: num,
  //                         min: 1,
  //                         max: 10000000,
  //                         clearButton: false,
  //                         onChanged: (v) => state(() => num = v ?? 1),
  //                       ),
  //                     ),
  //                     Column(
  //                       children: [
  //                         RichText(
  //                             text: TextSpan(children: [
  //                           TextSpan(text: "  买：", style: TextStyle(color: Colors.red)),
  //                           TextSpan(text: "可开 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                           TextSpan(text: tradeBuyCanOpen, style: TextStyle(color: themeController.theme.activeColor)),
  //                           TextSpan(text: "  可平 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                           TextSpan(text: tradeBuyCanClose, style: TextStyle(color: themeController.theme.activeColor))
  //                         ])),
  //                         RichText(
  //                             text: TextSpan(children: [
  //                           TextSpan(text: "  卖：", style: TextStyle(color: Colors.green)),
  //                           TextSpan(text: "可开 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                           TextSpan(text: tradeSaleCanOpen, style: TextStyle(color: themeController.theme.activeColor)),
  //                           TextSpan(text: "  可平 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                           TextSpan(text: tradeSaleCanClose, style: TextStyle(color: themeController.theme.activeColor))
  //                         ])),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     SizedBox(width: padWidth),
  //                     const Text("价格"),
  //                     Container(
  //                       width: boxWidth,
  //                       height: 38,
  //                       margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
  //                       child: my_combo.EditableComboBox<String>(
  //                         textController: textController,
  //                         value: price,
  //                         mathValue: double.tryParse(price) ?? tradeLogic.contract.value.lastPrice?.toDouble(),
  //                         items: priceList.map<my_combo.ComboBoxItem<String>>((e) {
  //                           return my_combo.ComboBoxItem<String>(
  //                             value: e,
  //                             child: Text('$e'),
  //                           );
  //                         }).toList(),
  //                         onChanged: (v) {
  //                           price = v!;
  //                           tradeSalePrice = getLimitPrice(true).toString();
  //                           tradeBuyPrice = getLimitPrice(false).toString();
  //                           if (globalStateFirst != null) globalStateFirst!(() {});
  //                         },
  //                         onTextChanged: (text) {
  //                           price = text;
  //                           tradeSalePrice = getLimitPrice(true).toString();
  //                           tradeBuyPrice = getLimitPrice(false).toString();
  //                           if (globalStateFirst != null) globalStateFirst!(() {});
  //                         },
  //                         updateChange: (v) {
  //                           price = v!;
  //                           tradeSalePrice = getLimitPrice(true).toString();
  //                           tradeBuyPrice = getLimitPrice(false).toString();
  //                           if (globalStateFirst != null) globalStateFirst!(() {});
  //                         },
  //                         onFieldSubmitted: (String text) {
  //                           price = text;
  //                           if (globalStateFirst != null) globalStateFirst!(() {});
  //                           return price;
  //                         },
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     GestureDetector(
  //                       child: Container(
  //                         decoration: BoxDecoration(color: Colors.red, borderRadius: const BorderRadius.all(Radius.circular(5))),
  //                         margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
  //                         child: Column(
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.all(8),
  //                               child: AutoSizeText(
  //                                 tradeBuyPrice,
  //                                 maxLines: 1,
  //                                 style: const TextStyle(color: Colors.white, fontSize: 21),
  //                               ),
  //                             ),
  //                             Container(
  //                               height: 1,
  //                               width: 135,
  //                               margin: const EdgeInsets.symmetric(horizontal: 10),
  //                               color: Colors.white,
  //                             ),
  //                             const Padding(
  //                               padding: EdgeInsets.all(8),
  //                               child: AutoSizeText(
  //                                 "买入",
  //                                 maxLines: 1,
  //                                 style: TextStyle(color: Colors.white, fontSize: 21),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       onTap: () {
  //                         if (tradeLogic.contract.value.code == null) {
  //                           InfoBarUtils.showErrorBar("请选择合约");
  //                           return;
  //                         }
  //                         AddOrder order = AddOrder(
  //                           name: tradeLogic.contract.value.name,
  //                           code: tradeLogic.contract.value.code,
  //                           ExchangeNo: tradeLogic.contract.value.exCode,
  //                           CommodityNo: tradeLogic.contract.value.subComCode,
  //                           ContractNo: tradeLogic.contract.value.subConCode,
  //                           CommodityType: tradeLogic.contract.value.comType,
  //                           OrderType: getOrderType(),
  //                           TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
  //                           ExpireTime: "",
  //                           OrderSide: SideType.SIDE_BUY,
  //                           OrderPrice: getLimitPrice(false),
  //                           StopPrice: 0,
  //                           OrderQty: num,
  //                           PositionEffect: open ? PositionEffectType.PositionEffect_OPEN : PositionEffectType.PositionEffect_COVER,
  //                         );
  //                         showDialog(
  //                             context: context,
  //                             builder: (BuildContext context) {
  //                               return TradeDialog().addOrderDialog(order);
  //                             });
  //                       },
  //                     ),
  //                     GestureDetector(
  //                       child: Container(
  //                         decoration: BoxDecoration(color: Colors.green, borderRadius: const BorderRadius.all(Radius.circular(5))),
  //                         margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
  //                         child: Column(
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.all(8),
  //                               child: AutoSizeText(
  //                                 tradeSalePrice,
  //                                 maxLines: 1,
  //                                 style: const TextStyle(color: Colors.white, fontSize: 21),
  //                               ),
  //                             ),
  //                             Container(
  //                               height: 1,
  //                               width: 135,
  //                               margin: const EdgeInsets.symmetric(horizontal: 10),
  //                               color: Colors.white,
  //                             ),
  //                             const Padding(
  //                               padding: EdgeInsets.all(8),
  //                               child: AutoSizeText(
  //                                 "卖出",
  //                                 maxLines: 1,
  //                                 style: TextStyle(color: Colors.white, fontSize: 21),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       onTap: () {
  //                         if (tradeLogic.contract.value.code == null) {
  //                           InfoBarUtils.showErrorBar("请选择合约");
  //                           return;
  //                         }
  //                         AddOrder order = AddOrder(
  //                           name: tradeLogic.contract.value.name,
  //                           code: tradeLogic.contract.value.code,
  //                           ExchangeNo: tradeLogic.contract.value.exCode,
  //                           CommodityNo: tradeLogic.contract.value.subComCode,
  //                           ContractNo: tradeLogic.contract.value.subConCode,
  //                           CommodityType: tradeLogic.contract.value.comType,
  //                           OrderType: getOrderType(),
  //                           TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
  //                           ExpireTime: "",
  //                           OrderSide: SideType.SIDE_SELL,
  //                           OrderPrice: getLimitPrice(true),
  //                           StopPrice: 0,
  //                           OrderQty: num,
  //                           PositionEffect: open ? PositionEffectType.PositionEffect_OPEN : PositionEffectType.PositionEffect_COVER,
  //                         );
  //                         showDialog(
  //                             context: context,
  //                             builder: (BuildContext context) {
  //                               return TradeDialog().addOrderDialog(order);
  //                             });
  //                       },
  //                     )
  //                   ],
  //                 )
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //     Tab(
  //       text: Text(
  //         '三键下单',
  //         textAlign: TextAlign.center,
  //         style: TextStyle(fontSize: 14, color: tradeLogic.tradeIndex.value == 1 ? Colors.yellow : themeController.theme.selectionColor),
  //       ),
  //       body: SizedBox(
  //         width: 388,
  //         height: 500,
  //         child: StatefulBuilder(
  //           builder: (_, state) {
  //             globalStateSecond = state;
  //             return ListView(
  //               shrinkWrap: true,
  //               children: [
  //                 const SizedBox(height: 18),
  //                 Row(children: [
  //                   SizedBox(width: padWidth),
  //                   const Text("合约"),
  //                   Container(
  //                     width: boxWidth,
  //                     height: 28,
  //                     margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
  //                     child: AutoSuggestBox(
  //                       controller: controller,
  //                       items: allContracts.map((e) {
  //                         return AutoSuggestBoxItem<Contract>(
  //                           value: e,
  //                           label: e.code ?? "--",
  //                         );
  //                       }).toList(),
  //                       onSelected: (item) {
  //                         if (item.value != null) {
  //                           unSubscriptionQuote();
  //                           tradeLogic.contract.value = item.value!;
  //                           subscriptionQuote();
  //                         }
  //                       },
  //                     ),
  //                   ),
  //                   const SizedBox(
  //                     width: 58,
  //                   ),
  //                   Button(
  //                       style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 3))),
  //                       onPressed: () {
  //                         num = 1;
  //                         price = "市价";
  //                         state(() {});
  //                       },
  //                       child: const Text("复位")),
  //                 ]),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     SizedBox(width: padWidth),
  //                     const Text("数量"),
  //                     Container(
  //                       width: boxWidth,
  //                       height: 38,
  //                       margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
  //                       child: NumberBox(value: num, min: 1, max: 10000000, clearButton: false, onChanged: (v) => state(() => num = v ?? 1)),
  //                     ),
  //                     Column(
  //                       children: [
  //                         RichText(
  //                             text: TextSpan(children: [
  //                           TextSpan(text: "  买：", style: TextStyle(color: Colors.red)),
  //                           TextSpan(text: "可开 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                           TextSpan(text: tradeBuyCanOpen, style: TextStyle(color: themeController.theme.activeColor)),
  //                           TextSpan(text: "  可平 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                           TextSpan(text: tradeBuyCanClose, style: TextStyle(color: themeController.theme.activeColor))
  //                         ])),
  //                         RichText(
  //                             text: TextSpan(children: [
  //                           TextSpan(text: "  卖：", style: TextStyle(color: Colors.green)),
  //                           TextSpan(text: "可开 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                           TextSpan(text: tradeSaleCanOpen, style: TextStyle(color: themeController.theme.activeColor)),
  //                           TextSpan(text: "  可平 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                           TextSpan(text: tradeSaleCanClose, style: TextStyle(color: themeController.theme.activeColor))
  //                         ])),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     SizedBox(width: padWidth),
  //                     const Text("价格"),
  //                     Container(
  //                       width: boxWidth,
  //                       height: 38,
  //                       margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
  //                       child: my_combo.EditableComboBox<String>(
  //                         value: price,
  //                         mathValue: double.tryParse(price) ?? tradeLogic.contract.value.lastPrice?.toDouble(),
  //                         items: priceList.map<my_combo.ComboBoxItem<String>>((e) {
  //                           return my_combo.ComboBoxItem<String>(
  //                             value: e,
  //                             child: Text('$e'),
  //                           );
  //                         }).toList(),
  //                         onChanged: (v) {
  //                           price = v!;
  //                           tradeSalePrice = getLimitPrice(true).toString();
  //                           tradeBuyPrice = getLimitPrice(false).toString();
  //                           if (globalStateSecond != null) globalStateSecond!(() {});
  //                         },
  //                         onTextChanged: (text) {
  //                           price = text;
  //                           tradeSalePrice = getLimitPrice(true).toString();
  //                           tradeBuyPrice = getLimitPrice(false).toString();
  //                           if (globalStateSecond != null) globalStateSecond!(() {});
  //                         },
  //                         updateChange: (v) {
  //                           price = v!;
  //                           tradeSalePrice = getLimitPrice(true).toString();
  //                           tradeBuyPrice = getLimitPrice(false).toString();
  //                           if (globalStateSecond != null) globalStateSecond!(() {});
  //                         },
  //                         onFieldSubmitted: (String text) {
  //                           price = text;
  //                           if (globalStateFirst != null) globalStateSecond!(() {});
  //                           return price;
  //                         },
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     GestureDetector(
  //                       child: Container(
  //                         decoration: BoxDecoration(color: Colors.red, borderRadius: const BorderRadius.all(Radius.circular(5))),
  //                         margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
  //                         child: Column(
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.all(8),
  //                               child: AutoSizeText(
  //                                 tradeBuyPrice,
  //                                 maxLines: 1,
  //                                 style: const TextStyle(color: Colors.white, fontSize: 21),
  //                               ),
  //                             ),
  //                             Container(
  //                               height: 1,
  //                               width: 88,
  //                               margin: const EdgeInsets.symmetric(horizontal: 10),
  //                               color: Colors.white,
  //                             ),
  //                             const Padding(
  //                               padding: EdgeInsets.all(8),
  //                               child: AutoSizeText(
  //                                 "买入",
  //                                 maxLines: 1,
  //                                 style: TextStyle(color: Colors.white, fontSize: 21),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       onTap: () {
  //                         if (tradeLogic.contract.value.code == null) {
  //                           InfoBarUtils.showErrorBar("请选择合约");
  //                           return;
  //                         }
  //                         AddOrder order = AddOrder(
  //                           name: tradeLogic.contract.value.name,
  //                           code: tradeLogic.contract.value.code,
  //                           ExchangeNo: tradeLogic.contract.value.exCode,
  //                           CommodityNo: tradeLogic.contract.value.subComCode,
  //                           ContractNo: tradeLogic.contract.value.subConCode,
  //                           CommodityType: tradeLogic.contract.value.comType,
  //                           OrderType: getOrderType(),
  //                           TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
  //                           ExpireTime: "",
  //                           OrderSide: SideType.SIDE_BUY,
  //                           OrderPrice: getLimitPrice(false),
  //                           StopPrice: 0,
  //                           OrderQty: num,
  //                           PositionEffect: PositionEffectType.PositionEffect_OPEN,
  //                         );
  //                         showDialog(
  //                             context: context,
  //                             builder: (BuildContext context) {
  //                               return TradeDialog().addOrderDialog(order);
  //                             });
  //                       },
  //                     ),
  //                     GestureDetector(
  //                       child: Container(
  //                         decoration: BoxDecoration(color: Colors.green, borderRadius: const BorderRadius.all(Radius.circular(5))),
  //                         margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
  //                         child: Column(
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.all(8),
  //                               child: AutoSizeText(
  //                                 tradeSalePrice,
  //                                 maxLines: 1,
  //                                 style: const TextStyle(color: Colors.white, fontSize: 21),
  //                               ),
  //                             ),
  //                             Container(
  //                               height: 1,
  //                               width: 88,
  //                               margin: const EdgeInsets.symmetric(horizontal: 10),
  //                               color: Colors.white,
  //                             ),
  //                             const Padding(
  //                               padding: EdgeInsets.all(8),
  //                               child: AutoSizeText(
  //                                 "卖出",
  //                                 maxLines: 1,
  //                                 style: TextStyle(color: Colors.white, fontSize: 21),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       onTap: () {
  //                         if (tradeLogic.contract.value.code == null) {
  //                           InfoBarUtils.showErrorBar("请选择合约");
  //                           return;
  //                         }
  //                         AddOrder order = AddOrder(
  //                           name: tradeLogic.contract.value.name,
  //                           code: tradeLogic.contract.value.code,
  //                           ExchangeNo: tradeLogic.contract.value.exCode,
  //                           CommodityNo: tradeLogic.contract.value.subComCode,
  //                           ContractNo: tradeLogic.contract.value.subConCode,
  //                           CommodityType: tradeLogic.contract.value.comType,
  //                           OrderType: getOrderType(),
  //                           TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
  //                           ExpireTime: "",
  //                           OrderSide: SideType.SIDE_SELL,
  //                           OrderPrice: getLimitPrice(true),
  //                           StopPrice: 0,
  //                           OrderQty: num,
  //                           PositionEffect: PositionEffectType.PositionEffect_OPEN,
  //                         );
  //                         showDialog(
  //                             context: context,
  //                             builder: (BuildContext context) {
  //                               return TradeDialog().addOrderDialog(order);
  //                             });
  //                       },
  //                     ),
  //                     GestureDetector(
  //                       child: Container(
  //                         decoration: BoxDecoration(color: Colors.yellow, borderRadius: const BorderRadius.all(Radius.circular(5))),
  //                         margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
  //                         child: Column(
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.all(8),
  //                               child: AutoSizeText(
  //                                 tradeClosePrice,
  //                                 maxLines: 1,
  //                                 style: const TextStyle(color: Colors.white, fontSize: 21),
  //                               ),
  //                             ),
  //                             Container(
  //                               height: 1,
  //                               width: 88,
  //                               margin: const EdgeInsets.symmetric(horizontal: 10),
  //                               color: Colors.white,
  //                             ),
  //                             const Padding(
  //                               padding: EdgeInsets.all(8),
  //                               child: AutoSizeText(
  //                                 "平仓",
  //                                 maxLines: 1,
  //                                 style: TextStyle(color: Colors.white, fontSize: 21),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       onTap: () {
  //                         if (tradeLogic.contract.value.code == null) {
  //                           InfoBarUtils.showErrorBar("请选择合约");
  //                           return;
  //                         }
  //                         double limitPrice = getLimitPrice(false);
  //                         if (mHoldOrder?.orderSide == SideType.SIDE_BUY) {
  //                           limitPrice = getLimitPrice(true);
  //                         }
  //                         int sideType = mHoldOrder?.orderSide == SideType.SIDE_SELL ? SideType.SIDE_BUY : SideType.SIDE_SELL;
  //                         AddOrder order = AddOrder(
  //                           name: tradeLogic.contract.value.name,
  //                           code: tradeLogic.contract.value.code,
  //                           ExchangeNo: tradeLogic.contract.value.exCode,
  //                           CommodityNo: tradeLogic.contract.value.subComCode,
  //                           ContractNo: tradeLogic.contract.value.subConCode,
  //                           CommodityType: tradeLogic.contract.value.comType,
  //                           OrderType: getOrderType(),
  //                           TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
  //                           ExpireTime: "",
  //                           OrderSide: sideType,
  //                           OrderPrice: limitPrice,
  //                           StopPrice: 0,
  //                           OrderQty: num,
  //                           PositionEffect: PositionEffectType.PositionEffect_COVER,
  //                         );
  //                         showDialog(
  //                             context: context,
  //                             builder: (BuildContext context) {
  //                               return TradeDialog().addOrderDialog(order);
  //                             });
  //                       },
  //                     ),
  //                   ],
  //                 )
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //     Tab(
  //         text: Text(
  //           '传统下单',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(fontSize: 14, color: tradeLogic.tradeIndex.value == 2 ? Colors.yellow : themeController.theme.selectionColor),
  //         ),
  //         body: SizedBox(
  //           width: 388,
  //           height: 500,
  //           child: StatefulBuilder(
  //             builder: (_, state) {
  //               globalStateThird = state;
  //               return ListView(
  //                 shrinkWrap: true,
  //                 children: [
  //                   const SizedBox(height: 18),
  //                   Row(children: [
  //                     SizedBox(width: padWidth),
  //                     const Text("合约"),
  //                     Container(
  //                       width: boxWidth,
  //                       height: 28,
  //                       margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
  //                       child: AutoSuggestBox(
  //                         controller: controller,
  //                         items: allContracts.map((e) {
  //                           return AutoSuggestBoxItem<Contract>(
  //                             value: e,
  //                             label: e.code ?? "--",
  //                           );
  //                         }).toList(),
  //                         onSelected: (item) {
  //                           if (item.value != null) {
  //                             unSubscriptionQuote();
  //                             tradeLogic.contract.value = item.value!;
  //                             subscriptionQuote();
  //                           }
  //                         },
  //                       ),
  //                     ),
  //                     const SizedBox(
  //                       width: 58,
  //                     ),
  //                     Button(
  //                         style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 3))),
  //                         onPressed: () {
  //                           dir = true;
  //                           open = true;
  //                           num = 1;
  //                           price = "市价";
  //                           state(() {});
  //                         },
  //                         child: const Text("复位")),
  //                   ]),
  //                   Row(
  //                     children: [
  //                       SizedBox(
  //                         width: padWidth,
  //                         height: 58,
  //                       ),
  //                       const Text("方向   "),
  //                       RadioButton(
  //                           checked: dir,
  //                           onChanged: (checked) {
  //                             if (checked) {
  //                               state(() => dir = checked);
  //                             }
  //                           }),
  //                       const Text("  买入"),
  //                       const SizedBox(width: 28),
  //                       RadioButton(
  //                           checked: !dir,
  //                           onChanged: (checked) {
  //                             if (checked) {
  //                               state(() => dir = !checked);
  //                             }
  //                           }),
  //                       const Text("  卖出"),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       SizedBox(width: padWidth),
  //                       const Text("开平   "),
  //                       RadioButton(
  //                           checked: open,
  //                           onChanged: (checked) {
  //                             if (checked) {
  //                               state(() => open = checked);
  //                             }
  //                           }),
  //                       const Text("  开仓"),
  //                       const SizedBox(width: 28),
  //                       RadioButton(
  //                           checked: !open,
  //                           onChanged: (checked) {
  //                             if (checked) {
  //                               state(() => open = !checked);
  //                             }
  //                           }),
  //                       const Text("  平仓"),
  //                     ],
  //                   ),
  //                   Row(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       SizedBox(width: padWidth),
  //                       const Text("数量"),
  //                       Container(
  //                         width: boxWidth,
  //                         height: 38,
  //                         margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
  //                         child: NumberBox(
  //                           value: num,
  //                           min: 1,
  //                           max: 10000000,
  //                           clearButton: false,
  //                           onChanged: (v) => state(() => num = v ?? 1),
  //                         ),
  //                       ),
  //                       Column(
  //                         children: [
  //                           RichText(
  //                               text: TextSpan(children: [
  //                             TextSpan(text: "  买：", style: TextStyle(color: Colors.red)),
  //                             TextSpan(text: "可开 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                             TextSpan(text: tradeBuyCanOpen, style: TextStyle(color: themeController.theme.activeColor)),
  //                             TextSpan(text: "  可平 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                             TextSpan(text: tradeBuyCanClose, style: TextStyle(color: themeController.theme.activeColor))
  //                           ])),
  //                           RichText(
  //                               text: TextSpan(children: [
  //                             TextSpan(text: "  卖：", style: TextStyle(color: Colors.green)),
  //                             TextSpan(text: "可开 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                             TextSpan(text: tradeSaleCanOpen, style: TextStyle(color: themeController.theme.activeColor)),
  //                             TextSpan(text: "  可平 ", style: TextStyle(color: themeController.theme.selectionColor)),
  //                             TextSpan(text: tradeSaleCanClose, style: TextStyle(color: themeController.theme.activeColor))
  //                           ])),
  //                         ],
  //                       )
  //                     ],
  //                   ),
  //                   Row(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       SizedBox(width: padWidth),
  //                       const Text("价格"),
  //                       Container(
  //                         width: boxWidth,
  //                         height: 38,
  //                         margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
  //                         child: my_combo.EditableComboBox<String>(
  //                           value: price,
  //                           mathValue: double.tryParse(price) ?? tradeLogic.contract.value.lastPrice?.toDouble(),
  //                           items: priceList.map<my_combo.ComboBoxItem<String>>((e) {
  //                             return my_combo.ComboBoxItem<String>(
  //                               value: e,
  //                               child: Text('$e'),
  //                             );
  //                           }).toList(),
  //                           onChanged: (v) {
  //                             price = v!;
  //                             tradeSalePrice = getLimitPrice(true).toString();
  //                             tradeBuyPrice = getLimitPrice(false).toString();
  //                             if (globalStateThird != null) globalStateThird!(() {});
  //                           },
  //                           onTextChanged: (text) {
  //                             price = text;
  //                             tradeSalePrice = getLimitPrice(true).toString();
  //                             tradeBuyPrice = getLimitPrice(false).toString();
  //                             if (globalStateThird != null) globalStateThird!(() {});
  //                           },
  //                           updateChange: (v) {
  //                             price = v!;
  //                             tradeSalePrice = getLimitPrice(true).toString();
  //                             tradeBuyPrice = getLimitPrice(false).toString();
  //                             if (globalStateThird != null) globalStateThird!(() {});
  //                           },
  //                           onFieldSubmitted: (String text) {
  //                             price = text;
  //                             if (globalStateFirst != null) globalStateThird!(() {});
  //                             return price;
  //                           },
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   GestureDetector(
  //                     child: Container(
  //                       width: 58,
  //                       decoration: BoxDecoration(color: Colors.red, borderRadius: const BorderRadius.all(Radius.circular(5))),
  //                       margin: EdgeInsets.fromLTRB(padWidth, 20, 268, 20),
  //                       padding: const EdgeInsets.all(8),
  //                       alignment: Alignment.center,
  //                       child: const AutoSizeText(
  //                         "下单",
  //                         maxLines: 1,
  //                         style: TextStyle(color: Colors.white, fontSize: 23),
  //                       ),
  //                     ),
  //                     onTap: () {
  //                       if (tradeLogic.contract.value.code == null) {
  //                         InfoBarUtils.showErrorBar("请选择合约");
  //                         return;
  //                       }
  //                       AddOrder order = AddOrder(
  //                         name: tradeLogic.contract.value.name,
  //                         code: tradeLogic.contract.value.code,
  //                         ExchangeNo: tradeLogic.contract.value.exCode,
  //                         CommodityNo: tradeLogic.contract.value.subComCode,
  //                         ContractNo: tradeLogic.contract.value.subConCode,
  //                         CommodityType: tradeLogic.contract.value.comType,
  //                         OrderType: getOrderType(),
  //                         TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
  //                         ExpireTime: "",
  //                         OrderSide: dir ? SideType.SIDE_BUY : SideType.SIDE_SELL,
  //                         OrderPrice: getLimitPrice(!dir),
  //                         StopPrice: 0,
  //                         OrderQty: num,
  //                         PositionEffect: open ? PositionEffectType.PositionEffect_OPEN : PositionEffectType.PositionEffect_COVER,
  //                       );
  //                       showDialog(
  //                           context: context,
  //                           builder: (BuildContext context) {
  //                             return TradeDialog().addOrderDialog(order);
  //                           });
  //                     },
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //         ))
  //   ];
  //
  //   return Row(
  //     children: [
  //       SizedBox(
  //         width: 388,
  //         child: StatefulBuilder(builder: (_, refresh) {
  //           return TabView(
  //             tabs: tabs,
  //             currentIndex: tradeLogic.tradeIndex.value,
  //             onChanged: (index) {
  //               tradeLogic.tradeIndex.value = index;
  //             },
  //             tabWidthBehavior: TabWidthBehavior.equal,
  //             closeButtonVisibility: CloseButtonVisibilityMode.never,
  //             showScrollButtons: false,
  //           );
  //         }),
  //       )
  //     ],
  //   );
  // }

  ///持仓、委托、可撤
  // Widget tradeDetails() {
  //   return Expanded(
  //       child: Padding(
  //     padding: const EdgeInsets.all(15),
  //     child: Column(
  //       children: [
  //         Expanded(
  //           child: StatefulBuilder(
  //             builder: (_, state) {
  //               return Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Column(
  //                     children: [
  //                       Button(
  //                           style: const ButtonStyle(
  //                               padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                           onPressed: () {
  //                             tradeDetailIndex = 0;
  //                             state(() {});
  //                           },
  //                           child: Text(
  //                             "合\n计",
  //                             style: TextStyle(fontSize: 18, color: tradeDetailIndex == 0 ? Colors.yellow : themeController.theme.selectionColor),
  //                           )),
  //                       const SizedBox(height: 20),
  //                       Button(
  //                         style: const ButtonStyle(
  //                             padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                         onPressed: () {
  //                           tradeDetailIndex = 1;
  //                           state(() {});
  //                         },
  //                         child: Text(
  //                           "明\n细",
  //                           style: TextStyle(fontSize: 18, color: tradeDetailIndex == 1 ? Colors.yellow : themeController.theme.selectionColor),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Expanded(
  //                       child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       if (tradeDetailIndex == 0)
  //                         Container(
  //                           margin: const EdgeInsets.only(bottom: 10),
  //                           child: Row(
  //                             children: [
  //                               const SizedBox(width: 15),
  //                               Button(
  //                                   style: const ButtonStyle(
  //                                       padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                                       shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                                   onPressed: closeAllPos,
  //                                   child: Text(
  //                                     "全部平仓",
  //                                     style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                                   )),
  //                               const SizedBox(width: 15),
  //                               Button(
  //                                   style: const ButtonStyle(
  //                                       padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                                       shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                                   onPressed: quickClose,
  //                                   child: Text(
  //                                     "快捷平仓",
  //                                     style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                                   )),
  //                               const SizedBox(width: 15),
  //                               Button(
  //                                   style: const ButtonStyle(
  //                                       padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                                       shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                                   onPressed: quickBack,
  //                                   child: Text(
  //                                     "快捷反手",
  //                                     style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                                   )),
  //                               const SizedBox(width: 15),
  //                               Button(
  //                                   style: const ButtonStyle(
  //                                       padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                                       shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                                   onPressed: quickLock,
  //                                   child: Text(
  //                                     "快捷锁仓",
  //                                     style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                                   )),
  //                               const SizedBox(width: 15),
  //                               Button(
  //                                   onPressed: plSetting,
  //                                   style: const ButtonStyle(
  //                                       padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                                       shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                                   child: Text(
  //                                     "止盈止损",
  //                                     style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                                   )),
  //                             ],
  //                           ),
  //                         ),
  //                       Expanded(
  //                         child: Container(
  //                             decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
  //                             margin: const EdgeInsets.fromLTRB(15, 0, 0, 5),
  //                             child: Column(
  //                               children: [
  //                                 SingleChildScrollView(
  //                                   scrollDirection: Axis.horizontal,
  //                                   controller: tradeDetailsTitleController,
  //                                   physics: const AlwaysScrollableScrollPhysics(),
  //                                   child: SizedBox(
  //                                     width: 320.sp,
  //                                     child: Row(children: [
  //                                       Expanded(flex: 2, child: tableTitleItem("合约代码")),
  //                                       Expanded(flex: 1, child: tableTitleItem("买卖")),
  //                                       Expanded(flex: 1, child: tableTitleItem("数量")),
  //                                       Expanded(flex: 1, child: tableTitleItem("可平")),
  //                                       Expanded(flex: 2, child: tableTitleItem("开仓均价")),
  //                                       Expanded(flex: 2, child: tableTitleItem("计算价格")),
  //                                       Expanded(flex: 2, child: tableTitleItem("浮动盈亏")),
  //                                       Expanded(flex: 2, child: tableTitleItem("保证金占用")),
  //                                       Expanded(flex: 1, child: tableTitleItem("币种")),
  //                                       Expanded(flex: 3, child: tableTitleItem("合约名称")),
  //                                       if (tradeDetailIndex == 0) Expanded(flex: 2, child: tableTitleItem("止盈止损")),
  //                                       if (tradeDetailIndex == 1) Expanded(flex: 3, child: tableTitleItem("持仓编号")),
  //                                     ]),
  //                                   ),
  //                                 ),
  //                                 Expanded(
  //                                   child: Scrollbar(
  //                                     controller: tradeDetailsItemController,
  //                                     key: UniqueKey(),
  //                                     style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
  //                                     child: SingleChildScrollView(
  //                                       scrollDirection: Axis.horizontal,
  //                                       controller: tradeDetailsItemController,
  //                                       child: SizedBox(
  //                                           width: 320.sp,
  //                                           child: ListView.builder(
  //                                               shrinkWrap: true,
  //                                               key: const PageStorageKey<String>('pos'),
  //                                               controller: ScrollController(keepScrollOffset: true),
  //                                               itemCount: tradeDetailIndex == 0 ? tradeLogic.mHoldDetailList.length : mHoldList.length,
  //                                               padding: const EdgeInsets.only(bottom: 10),
  //                                               itemBuilder: (BuildContext context, int index) {
  //                                                 if (tradeDetailIndex == 0) {
  //                                                   return GestureDetector(
  //                                                     child: Container(
  //                                                       color: tradeLogic.mHoldDetailList[index].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
  //                                                       child: IntrinsicHeight(
  //                                                           child: Row(
  //                                                         crossAxisAlignment: CrossAxisAlignment.stretch,
  //                                                         children: [
  //                                                           Expanded(flex: 2, child: tableContentItem(tradeLogic.mHoldDetailList[index].code)),
  //                                                           Expanded(
  //                                                               flex: 1,
  //                                                               child: tableContentItem(
  //                                                                   tradeLogic.mHoldDetailList[index].orderSide == SideType.SIDE_SELL ? "卖出" : "买入")),
  //                                                           Expanded(
  //                                                               flex: 1, child: tableContentItem((tradeLogic.mHoldDetailList[index].quantity ?? 0).toString())),
  //                                                           Expanded(
  //                                                               flex: 1,
  //                                                               child: tableContentItem((tradeLogic.mHoldDetailList[index].AvailableQty ?? 0).toString())),
  //                                                           Expanded(
  //                                                               flex: 2,
  //                                                               child: tableContentItem(Utils.d2SBySrc(
  //                                                                   tradeLogic.mHoldDetailList[index].open, tradeLogic.mHoldDetailList[index].FutureTickSize))),
  //                                                           Expanded(
  //                                                               flex: 2,
  //                                                               child: tableContentItem((tradeLogic.mHoldDetailList[index].CalculatePrice ?? 0).toString())),
  //                                                           Expanded(
  //                                                               flex: 2,
  //                                                               child: tableContentItem(Utils.d2SBySrc(tradeLogic.mHoldDetailList[index].floatProfit, 2),
  //                                                                   color: (tradeLogic.mHoldDetailList[index].floatProfit ?? 0) > 0
  //                                                                       ? Common.quoteRedColor
  //                                                                       : (tradeLogic.mHoldDetailList[index].floatProfit ?? 0) < 0
  //                                                                           ? Common.quoteGreenColor
  //                                                                           : null)),
  //                                                           Expanded(
  //                                                               flex: 2, child: tableContentItem(Utils.d2SBySrc(tradeLogic.mHoldDetailList[index].margin, 2))),
  //                                                           Expanded(flex: 1, child: tableContentItem(tradeLogic.mHoldDetailList[index].CurrencyType)),
  //                                                           Expanded(flex: 3, child: tableContentItem(tradeLogic.mHoldDetailList[index].name)),
  //                                                           Expanded(flex: 2, child: tablePlItem(tradeLogic.mHoldDetailList[index].plStatus)),
  //                                                         ],
  //                                                       )),
  //                                                     ),
  //                                                     onTap: () {
  //                                                       if (tradeLogic.mHoldDetailList[index].selected == true) return;
  //                                                       for (var element in tradeLogic.mHoldDetailList) {
  //                                                         element.selected = false;
  //                                                       }
  //                                                       tradeLogic.mHoldDetailList[index].selected = true;
  //                                                       mHoldOrder = tradeLogic.mHoldDetailList[index];
  //                                                       switchCon();
  //                                                       state(() {});
  //                                                     },
  //                                                   );
  //                                                 } else {
  //                                                   return GestureDetector(
  //                                                     child: Container(
  //                                                       color: mHoldList[index].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
  //                                                       child: IntrinsicHeight(
  //                                                           child: Row(
  //                                                         crossAxisAlignment: CrossAxisAlignment.stretch,
  //                                                         children: [
  //                                                           Expanded(flex: 2, child: tableContentItem(mHoldList[index].code)),
  //                                                           Expanded(
  //                                                               flex: 1,
  //                                                               child:
  //                                                                   tableContentItem(mHoldList[index].orderSide == SideType.SIDE_SELL ? "卖出" : "买入")),
  //                                                           Expanded(flex: 1, child: tableContentItem((mHoldList[index].quantity ?? 0).toString())),
  //                                                           Expanded(
  //                                                               flex: 1, child: tableContentItem((mHoldList[index].AvailableQty ?? 0).toString())),
  //                                                           Expanded(
  //                                                               flex: 2,
  //                                                               child: tableContentItem(
  //                                                                   Utils.d2SBySrc(mHoldList[index].open, mHoldList[index].FutureTickSize))),
  //                                                           Expanded(
  //                                                               flex: 2, child: tableContentItem((mHoldList[index].CalculatePrice ?? 0).toString())),
  //                                                           Expanded(
  //                                                               flex: 2,
  //                                                               child: tableContentItem(Utils.d2SBySrc(mHoldList[index].floatProfit, 2),
  //                                                                   color: (mHoldList[index].floatProfit ?? 0) > 0
  //                                                                       ? Common.quoteRedColor
  //                                                                       : (mHoldList[index].floatProfit ?? 0) < 0
  //                                                                           ? Common.quoteGreenColor
  //                                                                           : null)),
  //                                                           Expanded(flex: 2, child: tableContentItem(Utils.d2SBySrc(mHoldList[index].margin, 2))),
  //                                                           Expanded(flex: 1, child: tableContentItem(mHoldList[index].CurrencyType)),
  //                                                           Expanded(flex: 3, child: tableContentItem(mHoldList[index].name)),
  //                                                           Expanded(flex: 3, child: tableContentItem(mHoldList[index].PositionNo)),
  //                                                         ],
  //                                                       )),
  //                                                     ),
  //                                                     onTap: () {
  //                                                       if (mHoldList[index].selected == true) return;
  //                                                       for (var element in mHoldList) {
  //                                                         element.selected = false;
  //                                                       }
  //                                                       mHoldList[index].selected = true;
  //                                                       mHoldOrder = mHoldList[index];
  //                                                       switchCon();
  //                                                       state(() {});
  //                                                     },
  //                                                   );
  //                                                 }
  //                                               })),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             )),
  //                       ),
  //                     ],
  //                   ))
  //                 ],
  //               );
  //             },
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 15,
  //         ),
  //         Expanded(
  //           child: StatefulBuilder(builder: (_, state) {
  //             return Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Column(
  //                   children: [
  //                     Button(
  //                         style: const ButtonStyle(
  //                             padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                         onPressed: () {
  //                           tradeAllIndex = 0;
  //                           state(() {});
  //                         },
  //                         child: Text(
  //                           "可\n撤",
  //                           style: TextStyle(fontSize: 18, color: tradeAllIndex == 0 ? Colors.yellow : themeController.theme.selectionColor),
  //                         )),
  //                     const SizedBox(height: 20),
  //                     Button(
  //                       style: const ButtonStyle(
  //                           padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                       onPressed: () {
  //                         tradeAllIndex = 1;
  //                         state(() {});
  //                       },
  //                       child: Text(
  //                         "全\n部",
  //                         style: TextStyle(fontSize: 18, color: tradeAllIndex == 1 ? Colors.yellow : themeController.theme.selectionColor),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 Expanded(
  //                     child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         const SizedBox(width: 15),
  //                         Button(
  //                             style: const ButtonStyle(
  //                                 padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                                 shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                             onPressed: delAllHold,
  //                             child: Text(
  //                               "全部撤单",
  //                               style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                             )),
  //                         const SizedBox(width: 15),
  //                         Button(
  //                             onPressed: delHold,
  //                             style: const ButtonStyle(
  //                                 padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                                 shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                             child: Text(
  //                               "撤单",
  //                               style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                             )),
  //                       ],
  //                     ),
  //                     Expanded(
  //                       child: Container(
  //                           decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
  //                           margin: const EdgeInsets.fromLTRB(15, 10, 0, 5),
  //                           child: Column(
  //                             children: [
  //                               SingleChildScrollView(
  //                                 scrollDirection: Axis.horizontal,
  //                                 controller: delOrderTitleController,
  //                                 physics: const AlwaysScrollableScrollPhysics(),
  //                                 child: SizedBox(
  //                                   width: 380.sp,
  //                                   child: Row(children: [
  //                                     Expanded(flex: 4, child: tableTitleItem("委托时间")),
  //                                     Expanded(flex: 2, child: tableTitleItem("合约代码")),
  //                                     Expanded(flex: 1, child: tableTitleItem("买卖")),
  //                                     Expanded(flex: 1, child: tableTitleItem("开平")),
  //                                     Expanded(flex: 2, child: tableTitleItem("价格")),
  //                                     Expanded(flex: 2, child: tableTitleItem("委托数量")),
  //                                     Expanded(flex: 2, child: tableTitleItem("成交数量")),
  //                                     Expanded(flex: 1, child: tableTitleItem("币种")),
  //                                     Expanded(flex: 2, child: tableTitleItem("订单来源")),
  //                                     Expanded(flex: 2, child: tableTitleItem("状态")),
  //                                     Expanded(flex: 4, child: tableTitleItem("错误信息")),
  //                                     Expanded(flex: 4, child: tableTitleItem("委托号")),
  //                                     Expanded(flex: 3, child: tableTitleItem("合约名称")),
  //                                   ]),
  //                                 ),
  //                               ),
  //                               Expanded(
  //                                 child: Scrollbar(
  //                                   controller: delOrderItemController,
  //                                   key: UniqueKey(),
  //                                   style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
  //                                   child: SingleChildScrollView(
  //                                     scrollDirection: Axis.horizontal,
  //                                     controller: delOrderItemController,
  //                                     child: SizedBox(
  //                                         width: 380.sp,
  //                                         child: ListView.builder(
  //                                             shrinkWrap: true,
  //                                             controller: ScrollController(keepScrollOffset: true),
  //                                             itemCount: tradeAllIndex == 0 ? tradeLogic.mPendList.length : tradeLogic.mDelList.length,
  //                                             padding: const EdgeInsets.only(bottom: 10),
  //                                             itemBuilder: (BuildContext context, int index) {
  //                                               if (tradeAllIndex == 0) {
  //                                                 return GestureDetector(
  //                                                   child: Container(
  //                                                     color: tradeLogic.mPendList[index].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
  //                                                     child: IntrinsicHeight(
  //                                                         child: Row(
  //                                                       crossAxisAlignment: CrossAxisAlignment.stretch,
  //                                                       children: [
  //                                                         Expanded(
  //                                                             flex: 4,
  //                                                             child:
  //                                                                 tableContentItem("${tradeLogic.mPendList[index].date ?? ""} ${tradeLogic.mPendList[index].time ?? ""}")),
  //                                                         Expanded(flex: 2, child: tableContentItem(tradeLogic.mPendList[index].code)),
  //                                                         Expanded(
  //                                                             flex: 1,
  //                                                             child: tableContentItem(tradeLogic.mPendList[index].bs,
  //                                                                 color: tradeLogic.mPendList[index].bs == "买入" ? Colors.red : Colors.green)),
  //                                                         Expanded(
  //                                                             flex: 1,
  //                                                             child: tableContentItem(PositionEffectType.getName(tradeLogic.mPendList[index].OpenClose))),
  //                                                         Expanded(flex: 2, child: tableContentItem("${tradeLogic.mPendList[index].price ?? ""}")),
  //                                                         Expanded(flex: 2, child: tableContentItem("${tradeLogic.mPendList[index].deleNum ?? "0"}")),
  //                                                         Expanded(flex: 2, child: tableContentItem("${tradeLogic.mPendList[index].comNum ?? "0"}")),
  //                                                         Expanded(flex: 1, child: tableContentItem(tradeLogic.mPendList[index].CurrencyType)),
  //                                                         Expanded(
  //                                                             flex: 2, child: tableContentItem(OrderOpType.getName(tradeLogic.mPendList[index].orderOpType))),
  //                                                         Expanded(flex: 2, child: tableContentItem(tradeLogic.mPendList[index].state)),
  //                                                         Expanded(flex: 4, child: tableContentItem(tradeLogic.mPendList[index].ErrorText)),
  //                                                         Expanded(flex: 4, child: tableContentItem(tradeLogic.mPendList[index].deleNo)),
  //                                                         Expanded(flex: 3, child: tableContentItem(tradeLogic.mPendList[index].name)),
  //                                                       ],
  //                                                     )),
  //                                                   ),
  //                                                   onTap: () {
  //                                                     if (tradeLogic.mPendList[index].selected == true) return;
  //                                                     for (var element in tradeLogic.mPendList) {
  //                                                       element.selected = false;
  //                                                     }
  //                                                     tradeLogic.mPendList[index].selected = true;
  //                                                     state(() {});
  //                                                   },
  //                                                 );
  //                                               } else {
  //                                                 return GestureDetector(
  //                                                   child: Container(
  //                                                     color: tradeLogic.mDelList[index].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
  //                                                     child: IntrinsicHeight(
  //                                                         child: Row(
  //                                                       crossAxisAlignment: CrossAxisAlignment.stretch,
  //                                                       children: [
  //                                                         Expanded(
  //                                                             flex: 4,
  //                                                             child: tableContentItem("${tradeLogic.mDelList[index].date ?? ""} ${tradeLogic.mDelList[index].time ?? ""}")),
  //                                                         Expanded(flex: 2, child: tableContentItem(tradeLogic.mDelList[index].code)),
  //                                                         Expanded(
  //                                                             flex: 1,
  //                                                             child: tableContentItem(tradeLogic.mDelList[index].bs,
  //                                                                 color: tradeLogic.mDelList[index].bs == "买入" ? Colors.red : Colors.green)),
  //                                                         Expanded(
  //                                                             flex: 1,
  //                                                             child: tableContentItem(PositionEffectType.getName(tradeLogic.mDelList[index].OpenClose))),
  //                                                         Expanded(flex: 2, child: tableContentItem("${tradeLogic.mDelList[index].price ?? ""}")),
  //                                                         Expanded(flex: 2, child: tableContentItem("${tradeLogic.mDelList[index].deleNum ?? "0"}")),
  //                                                         Expanded(flex: 2, child: tableContentItem("${tradeLogic.mDelList[index].comNum ?? "0"}")),
  //                                                         Expanded(flex: 1, child: tableContentItem(tradeLogic.mDelList[index].CurrencyType)),
  //                                                         Expanded(
  //                                                             flex: 2, child: tableContentItem(OrderOpType.getName(tradeLogic.mDelList[index].orderOpType))),
  //                                                         Expanded(flex: 2, child: tableContentItem(tradeLogic.mDelList[index].state)),
  //                                                         Expanded(flex: 4, child: tableContentItem(tradeLogic.mDelList[index].ErrorText)),
  //                                                         Expanded(flex: 4, child: tableContentItem(tradeLogic.mDelList[index].deleNo)),
  //                                                         Expanded(flex: 3, child: tableContentItem(tradeLogic.mDelList[index].name)),
  //                                                       ],
  //                                                     )),
  //                                                   ),
  //                                                   onTap: () {
  //                                                     if (tradeLogic.mDelList[index].selected == true) return;
  //                                                     for (var element in tradeLogic.mDelList) {
  //                                                       element.selected = false;
  //                                                     }
  //                                                     tradeLogic.mDelList[index].selected = true;
  //                                                     state(() {});
  //                                                   },
  //                                                 );
  //                                               }
  //                                             })),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           )),
  //                     ),
  //                   ],
  //                 ))
  //               ],
  //             );
  //           }),
  //         ),
  //       ],
  //       // ),
  //     ),
  //   ));
  // }

  ///委托、可撤
  // Widget orderDetails() {
  //   return Expanded(
  //     child: Padding(
  //         padding: const EdgeInsets.all(15),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Column(
  //               children: [
  //                 Button(
  //                     style: const ButtonStyle(
  //                         padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                     onPressed: () {
  //                       tradeWTIndex = 0;
  //                       if (mounted) setState(() {});
  //                     },
  //                     child: Text(
  //                       "可\n撤",
  //                       style: TextStyle(fontSize: 18, color: tradeWTIndex == 0 ? Colors.yellow : themeController.theme.selectionColor),
  //                     )),
  //                 const SizedBox(height: 20),
  //                 Button(
  //                   style: const ButtonStyle(
  //                       padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                   onPressed: () {
  //                     tradeWTIndex = 1;
  //                     if (mounted) setState(() {});
  //                   },
  //                   child: Text(
  //                     "全\n部",
  //                     style: TextStyle(fontSize: 18, color: tradeWTIndex == 1 ? Colors.yellow : themeController.theme.selectionColor),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Expanded(
  //                 child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     const SizedBox(width: 15),
  //                     Button(
  //                         style: const ButtonStyle(
  //                             padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                             shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                         onPressed: delAllHold,
  //                         child: Text(
  //                           "全部撤单",
  //                           style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                         )),
  //                     const SizedBox(width: 15),
  //                     Button(
  //                         onPressed: delHold,
  //                         style: const ButtonStyle(
  //                             padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                             shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                         child: Text(
  //                           "撤单",
  //                           style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                         )),
  //                   ],
  //                 ),
  //                 Expanded(
  //                   child: Container(
  //                       decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
  //                       margin: const EdgeInsets.fromLTRB(15, 10, 0, 5),
  //                       child: Column(
  //                         children: [
  //                           SingleChildScrollView(
  //                             scrollDirection: Axis.horizontal,
  //                             controller: todayOrderTitleController,
  //                             physics: const AlwaysScrollableScrollPhysics(),
  //                             child: SizedBox(
  //                               width: 1.2.sw,
  //                               child: Row(children: [
  //                                 Expanded(flex: 4, child: tableTitleItem("委托时间")),
  //                                 Expanded(flex: 2, child: tableTitleItem("合约代码")),
  //                                 Expanded(flex: 1, child: tableTitleItem("买卖")),
  //                                 Expanded(flex: 1, child: tableTitleItem("开平")),
  //                                 Expanded(flex: 1, child: tableTitleItem("价格")),
  //                                 Expanded(flex: 2, child: tableTitleItem("委托数量")),
  //                                 Expanded(flex: 2, child: tableTitleItem("成交数量")),
  //                                 Expanded(flex: 1, child: tableTitleItem("币种")),
  //                                 Expanded(flex: 2, child: tableTitleItem("订单来源")),
  //                                 Expanded(flex: 2, child: tableTitleItem("状态")),
  //                                 Expanded(flex: 5, child: tableTitleItem("错误信息")),
  //                                 Expanded(flex: 4, child: tableTitleItem("委托号")),
  //                                 Expanded(flex: 3, child: tableTitleItem("合约名称")),
  //                               ]),
  //                             ),
  //                           ),
  //                           Expanded(
  //                             child: Scrollbar(
  //                               controller: todayOrderItemController,
  //                               key: UniqueKey(),
  //                               style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
  //                               child: SingleChildScrollView(
  //                                 scrollDirection: Axis.horizontal,
  //                                 controller: todayOrderItemController,
  //                                 child: SizedBox(
  //                                     width: 1.2.sw,
  //                                     child: ListView.builder(
  //                                         shrinkWrap: true,
  //                                         controller: ScrollController(keepScrollOffset: true),
  //                                         itemCount: tradeWTIndex == 0 ? tradeLogic.mPendList.length : tradeLogic.mDelList.length,
  //                                         padding: const EdgeInsets.only(bottom: 10),
  //                                         itemBuilder: (BuildContext context, int index) {
  //                                           if (tradeWTIndex == 0) {
  //                                             return GestureDetector(
  //                                               child: Container(
  //                                                 color: tradeLogic.mPendList[index].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
  //                                                 child: IntrinsicHeight(
  //                                                     child: Row(
  //                                                   crossAxisAlignment: CrossAxisAlignment.stretch,
  //                                                   children: [
  //                                                     Expanded(
  //                                                         flex: 4,
  //                                                         child: tableContentItem("${tradeLogic.mPendList[index].date ?? ""} ${tradeLogic.mPendList[index].time ?? ""}")),
  //                                                     Expanded(flex: 2, child: tableContentItem(tradeLogic.mPendList[index].code)),
  //                                                     Expanded(
  //                                                         flex: 1,
  //                                                         child: tableContentItem(tradeLogic.mPendList[index].bs,
  //                                                             color: tradeLogic.mPendList[index].bs == "买入" ? Colors.red : Colors.green)),
  //                                                     Expanded(
  //                                                         flex: 1, child: tableContentItem(PositionEffectType.getName(tradeLogic.mPendList[index].OpenClose))),
  //                                                     Expanded(flex: 1, child: tableContentItem("${tradeLogic.mPendList[index].price ?? ""}")),
  //                                                     Expanded(flex: 2, child: tableContentItem("${tradeLogic.mPendList[index].deleNum ?? "0"}")),
  //                                                     Expanded(flex: 2, child: tableContentItem("${tradeLogic.mPendList[index].comNum ?? "0"}")),
  //                                                     Expanded(flex: 1, child: tableContentItem(tradeLogic.mPendList[index].CurrencyType)),
  //                                                     Expanded(flex: 2, child: tableContentItem(OrderOpType.getName(tradeLogic.mPendList[index].orderOpType))),
  //                                                     Expanded(flex: 2, child: tableContentItem(tradeLogic.mPendList[index].state)),
  //                                                     Expanded(flex: 5, child: tableContentItem(tradeLogic.mPendList[index].ErrorText)),
  //                                                     Expanded(flex: 4, child: tableContentItem(tradeLogic.mPendList[index].deleNo)),
  //                                                     Expanded(flex: 3, child: tableContentItem(tradeLogic.mPendList[index].name)),
  //                                                   ],
  //                                                 )),
  //                                               ),
  //                                               onTap: () {
  //                                                 if (tradeLogic.mPendList[index].selected == true) return;
  //                                                 for (var element in tradeLogic.mPendList) {
  //                                                   element.selected = false;
  //                                                 }
  //                                                 tradeLogic.mPendList[index].selected = true;
  //                                                 if (mounted) setState(() {});
  //                                               },
  //                                             );
  //                                           } else {
  //                                             return GestureDetector(
  //                                               child: Container(
  //                                                 color: tradeLogic.mDelList[index].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
  //                                                 child: IntrinsicHeight(
  //                                                     child: Row(
  //                                                   crossAxisAlignment: CrossAxisAlignment.stretch,
  //                                                   children: [
  //                                                     Expanded(
  //                                                         flex: 4,
  //                                                         child: tableContentItem("${tradeLogic.mDelList[index].date ?? ""} ${tradeLogic.mDelList[index].time ?? ""}")),
  //                                                     Expanded(flex: 2, child: tableContentItem(tradeLogic.mDelList[index].code)),
  //                                                     Expanded(
  //                                                         flex: 1,
  //                                                         child: tableContentItem(tradeLogic.mDelList[index].bs,
  //                                                             color: tradeLogic.mDelList[index].bs == "买入" ? Colors.red : Colors.green)),
  //                                                     Expanded(
  //                                                         flex: 1, child: tableContentItem(PositionEffectType.getName(tradeLogic.mDelList[index].OpenClose))),
  //                                                     Expanded(flex: 1, child: tableContentItem("${tradeLogic.mDelList[index].price ?? ""}")),
  //                                                     Expanded(flex: 2, child: tableContentItem("${tradeLogic.mDelList[index].deleNum ?? "0"}")),
  //                                                     Expanded(flex: 2, child: tableContentItem("${tradeLogic.mDelList[index].comNum ?? "0"}")),
  //                                                     Expanded(flex: 1, child: tableContentItem(tradeLogic.mDelList[index].CurrencyType)),
  //                                                     Expanded(flex: 2, child: tableContentItem(OrderOpType.getName(tradeLogic.mDelList[index].orderOpType))),
  //                                                     Expanded(flex: 2, child: tableContentItem(tradeLogic.mDelList[index].state)),
  //                                                     Expanded(flex: 5, child: tableContentItem(tradeLogic.mDelList[index].ErrorText)),
  //                                                     Expanded(flex: 4, child: tableContentItem(tradeLogic.mDelList[index].deleNo)),
  //                                                     Expanded(flex: 3, child: tableContentItem(tradeLogic.mDelList[index].name)),
  //                                                   ],
  //                                                 )),
  //                                               ),
  //                                               onTap: () {
  //                                                 if (tradeLogic.mDelList[index].selected == true) return;
  //                                                 for (var element in tradeLogic.mDelList) {
  //                                                   element.selected = false;
  //                                                 }
  //                                                 tradeLogic.mDelList[index].selected = true;
  //                                                 if (mounted) setState(() {});
  //                                               },
  //                                             );
  //                                           }
  //                                         })),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       )),
  //                 ),
  //               ],
  //             ))
  //           ],
  //         )),
  //   );
  // }

  ///成交
  Widget dealDetails() {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: comTitleController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              width: 0.8.sw,
              child: Row(children: [
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
              ]),
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: comItemController,
              key: UniqueKey(),
              style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: comItemController,
                child: SizedBox(
                    width: 0.8.sw,
                    child: ListView.builder(
                        shrinkWrap: true,
                        controller: ScrollController(keepScrollOffset: true),
                        itemCount: tradeLogic.mComList.length,
                        padding: const EdgeInsets.only(bottom: 10),
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            child: Container(
                              color: tradeLogic.mComList[index].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
                              child: IntrinsicHeight(
                                  child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 1, child: tableContentItem((index + 1).toString())),
                                  Expanded(flex: 3, child: tableContentItem(tradeLogic.mComList[index].name)),
                                  Expanded(flex: 2, child: tableContentItem(tradeLogic.mComList[index].code)),
                                  Expanded(flex: 4, child: tableContentItem(tradeLogic.mComList[index].comNo)),
                                  Expanded(flex: 4, child: tableContentItem(tradeLogic.mComList[index].deleNo)),
                                  Expanded(flex: 1, child: tableContentItem(tradeLogic.mComList[index].bs)),
                                  Expanded(flex: 1, child: tableContentItem(PositionEffectType.getName(tradeLogic.mComList[index].OpenClose))),
                                  Expanded(flex: 1, child: tableContentItem("${tradeLogic.mComList[index].comNum ?? 0}")),
                                  Expanded(flex: 2, child: tableContentItem("${tradeLogic.mComList[index].price ?? 0.0}")),
                                  Expanded(flex: 2, child: tableContentItem("${tradeLogic.mComList[index].FeeValue ?? 0.0}")),
                                  Expanded(
                                      flex: 4,
                                      child: tableContentItem("${tradeLogic.mComList[index].date ?? ""} ${tradeLogic.mComList[index].time ?? ""}")),
                                ],
                              )),
                            ),
                            onTap: () {
                              if (tradeLogic.mComList[index].selected == true) return;
                              for (var element in tradeLogic.mComList) {
                                element.selected = false;
                              }
                              tradeLogic.mComList[index].selected = true;
                              if (mounted) setState(() {});
                            },
                          );
                        })),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  ///持仓
  // Widget posDetails() {
  //   return Expanded(child: StatefulBuilder(builder: (_, state) {
  //     return Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Column(
  //           children: [
  //             Button(
  //                 style:
  //                     const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                 onPressed: () {
  //                   tradeDetailIndex = 0;
  //                   if (mounted) setState(() {});
  //                 },
  //                 child: Text(
  //                   "合\n计",
  //                   style: TextStyle(fontSize: 18, color: tradeDetailIndex == 0 ? Colors.yellow : themeController.theme.selectionColor),
  //                 )),
  //             const SizedBox(height: 20),
  //             Button(
  //               style:
  //                   const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //               onPressed: () {
  //                 tradeDetailIndex = 1;
  //                 if (mounted) setState(() {});
  //               },
  //               child: Text(
  //                 "明\n细",
  //                 style: TextStyle(fontSize: 18, color: tradeDetailIndex == 1 ? Colors.yellow : themeController.theme.selectionColor),
  //               ),
  //             ),
  //           ],
  //         ).marginOnly(left: 15),
  //         Expanded(
  //             child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             if (tradeDetailIndex == 0)
  //               Container(
  //                 margin: const EdgeInsets.only(bottom: 10),
  //                 child: Row(
  //                   children: [
  //                     const SizedBox(width: 15),
  //                     Button(
  //                         style: const ButtonStyle(
  //                             padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                             shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                         onPressed: closeAllPos,
  //                         child: Text(
  //                           "全部平仓",
  //                           style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                         )),
  //                     const SizedBox(width: 15),
  //                     Button(
  //                         style: const ButtonStyle(
  //                             padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                             shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                         onPressed: quickClose,
  //                         child: Text(
  //                           "快捷平仓",
  //                           style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                         )),
  //                     const SizedBox(width: 15),
  //                     Button(
  //                         style: const ButtonStyle(
  //                             padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                             shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                         onPressed: quickBack,
  //                         child: Text(
  //                           "快捷反手",
  //                           style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                         )),
  //                     const SizedBox(width: 15),
  //                     Button(
  //                         style: const ButtonStyle(
  //                             padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                             shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                         onPressed: quickLock,
  //                         child: Text(
  //                           "快捷锁仓",
  //                           style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                         )),
  //                     const SizedBox(width: 15),
  //                     Button(
  //                         onPressed: plSetting,
  //                         style: const ButtonStyle(
  //                             padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                             shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                         child: Text(
  //                           "止盈止损",
  //                           style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                         )),
  //                   ],
  //                 ),
  //               ),
  //             Expanded(
  //               child: Container(
  //                   decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
  //                   margin: const EdgeInsets.fromLTRB(15, 0, 0, 5),
  //                   child: Column(
  //                     children: [
  //                       SingleChildScrollView(
  //                         scrollDirection: Axis.horizontal,
  //                         controller: posTitleController,
  //                         physics: const AlwaysScrollableScrollPhysics(),
  //                         child: SizedBox(
  //                           width: 380.sp,
  //                           child: Row(children: [
  //                             Expanded(flex: 2, child: tableTitleItem("合约代码")),
  //                             Expanded(flex: 1, child: tableTitleItem("买卖")),
  //                             Expanded(flex: 1, child: tableTitleItem("数量")),
  //                             Expanded(flex: 1, child: tableTitleItem("可平")),
  //                             Expanded(flex: 2, child: tableTitleItem("开仓均价")),
  //                             Expanded(flex: 2, child: tableTitleItem("计算价格")),
  //                             Expanded(flex: 2, child: tableTitleItem("浮动盈亏")),
  //                             Expanded(flex: 2, child: tableTitleItem("保证金占用")),
  //                             Expanded(flex: 1, child: tableTitleItem("币种")),
  //                             Expanded(flex: 3, child: tableTitleItem("合约名称")),
  //                             Expanded(flex: 3, child: tableTitleItem(tradeDetailIndex == 0 ? "止盈止损" : "持仓编号")),
  //                           ]),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: Scrollbar(
  //                           controller: posItemController,
  //                           key: UniqueKey(),
  //                           style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
  //                           child: SingleChildScrollView(
  //                             scrollDirection: Axis.horizontal,
  //                             controller: posItemController,
  //                             child: SizedBox(
  //                                 width: 380.sp,
  //                                 child: ListView.builder(
  //                                     shrinkWrap: true,
  //                                     controller: ScrollController(keepScrollOffset: true),
  //                                     itemCount: tradeDetailIndex == 0 ? tradeLogic.mHoldDetailList.length : mHoldList.length,
  //                                     padding: const EdgeInsets.only(bottom: 10),
  //                                     itemBuilder: (BuildContext context, int index) {
  //                                       if (tradeDetailIndex == 0) {
  //                                         return GestureDetector(
  //                                           child: Container(
  //                                             color: tradeLogic.mHoldDetailList[index].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
  //                                             child: IntrinsicHeight(
  //                                                 child: Row(
  //                                               crossAxisAlignment: CrossAxisAlignment.stretch,
  //                                               children: [
  //                                                 Expanded(flex: 2, child: tableContentItem(tradeLogic.mHoldDetailList[index].code)),
  //                                                 Expanded(
  //                                                     flex: 1,
  //                                                     child: tableContentItem(tradeLogic.mHoldDetailList[index].orderSide == SideType.SIDE_SELL ? "卖出" : "买入")),
  //                                                 Expanded(flex: 1, child: tableContentItem((tradeLogic.mHoldDetailList[index].quantity ?? 0).toString())),
  //                                                 Expanded(flex: 1, child: tableContentItem((tradeLogic.mHoldDetailList[index].AvailableQty ?? 0).toString())),
  //                                                 Expanded(
  //                                                     flex: 2,
  //                                                     child: tableContentItem(
  //                                                         Utils.d2SBySrc(tradeLogic.mHoldDetailList[index].open, tradeLogic.mHoldDetailList[index].FutureTickSize))),
  //                                                 Expanded(flex: 2, child: tableContentItem((tradeLogic.mHoldDetailList[index].CalculatePrice ?? 0).toString())),
  //                                                 Expanded(
  //                                                     flex: 2,
  //                                                     child: tableContentItem(Utils.d2SBySrc(tradeLogic.mHoldDetailList[index].floatProfit, 2),
  //                                                         color: (tradeLogic.mHoldDetailList[index].floatProfit ?? 0) > 0
  //                                                             ? Common.quoteRedColor
  //                                                             : (tradeLogic.mHoldDetailList[index].floatProfit ?? 0) < 0
  //                                                                 ? Common.quoteGreenColor
  //                                                                 : null)),
  //                                                 Expanded(flex: 2, child: tableContentItem(Utils.d2SBySrc(tradeLogic.mHoldDetailList[index].margin, 2))),
  //                                                 Expanded(flex: 1, child: tableContentItem(tradeLogic.mHoldDetailList[index].CurrencyType)),
  //                                                 Expanded(flex: 3, child: tableContentItem(tradeLogic.mHoldDetailList[index].name)),
  //                                                 Expanded(flex: 3, child: tablePlItem(tradeLogic.mHoldDetailList[index].plStatus)),
  //                                               ],
  //                                             )),
  //                                           ),
  //                                           onTap: () {
  //                                             if (tradeLogic.mHoldDetailList[index].selected == true) return;
  //                                             for (var element in tradeLogic.mHoldDetailList) {
  //                                               element.selected = false;
  //                                             }
  //                                             tradeLogic.mHoldDetailList[index].selected = true;
  //                                             mHoldOrder = tradeLogic.mHoldDetailList[index];
  //                                             tradeLogic.switchCon();
  //                                             state(() {});
  //                                           },
  //                                         );
  //                                       } else {
  //                                         return GestureDetector(
  //                                           child: Container(
  //                                             color: mHoldList[index].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
  //                                             child: IntrinsicHeight(
  //                                                 child: Row(
  //                                               crossAxisAlignment: CrossAxisAlignment.stretch,
  //                                               children: [
  //                                                 Expanded(flex: 2, child: tableContentItem(mHoldList[index].code)),
  //                                                 Expanded(
  //                                                     flex: 1,
  //                                                     child: tableContentItem(mHoldList[index].orderSide == SideType.SIDE_SELL ? "卖出" : "买入")),
  //                                                 Expanded(flex: 1, child: tableContentItem((mHoldList[index].quantity ?? 0).toString())),
  //                                                 Expanded(flex: 1, child: tableContentItem((mHoldList[index].AvailableQty ?? 0).toString())),
  //                                                 Expanded(
  //                                                     flex: 2,
  //                                                     child:
  //                                                         tableContentItem(Utils.d2SBySrc(mHoldList[index].open, mHoldList[index].FutureTickSize))),
  //                                                 Expanded(flex: 2, child: tableContentItem((mHoldList[index].CalculatePrice ?? 0).toString())),
  //                                                 Expanded(flex: 2, child: tableContentItem(Utils.d2SBySrc(mHoldList[index].floatProfit, 2))),
  //                                                 Expanded(flex: 2, child: tableContentItem(Utils.d2SBySrc(mHoldList[index].margin, 2))),
  //                                                 Expanded(flex: 1, child: tableContentItem(mHoldList[index].CurrencyType)),
  //                                                 Expanded(flex: 3, child: tableContentItem(mHoldList[index].name)),
  //                                                 Expanded(flex: 3, child: tableContentItem(mHoldList[index].PositionNo)),
  //                                               ],
  //                                             )),
  //                                           ),
  //                                           onTap: () {
  //                                             if (mHoldList[index].selected == true) return;
  //                                             for (var element in mHoldList) {
  //                                               element.selected = false;
  //                                             }
  //                                             mHoldList[index].selected = true;
  //                                             mHoldOrder = mHoldList[index];
  //                                             tradeLogic.switchCon();
  //                                             state(() {});
  //                                           },
  //                                         );
  //                                       }
  //                                     })),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   )),
  //             ),
  //           ],
  //         ))
  //       ],
  //     );
  //   }));
  // }

  ///云条件单设置
  Widget cloudConditionContent() {
    bool open = true;
    int num = 1;
    double wtPrice = tradeLogic.contract.value?.lastPrice?.toDouble() ?? 0.0;
    double cfPrice = tradeLogic.contract.value?.lastPrice?.toDouble() ?? 0.0;
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
                            controller: TextEditingController(text: tradeLogic.contract.value?.code),
                            items: tradeLogic.allContracts.map((e) {
                              return AutoSuggestBoxItem<Contract>(
                                value: e,
                                label: e.code ?? "--",
                              );
                            }).toList(),
                            onSelected: (item) {
                              if (item.value != null) {
                                tradeLogic.contract.value = item.value!;
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
                        onChanged: (v) {
                          tradeLogic.price.value = v?.toString() ?? "0";
                          tradeLogic.tradeSalePrice.value = tradeLogic.getLimitPrice(true).toString();
                          tradeLogic.tradeBuyPrice.value = tradeLogic.getLimitPrice(false).toString();
                        },
                        onTextChange: (v) {
                          tradeLogic.price.value = v.toString();
                          tradeLogic.tradeSalePrice.value = tradeLogic.getLimitPrice(true).toString();
                          tradeLogic.tradeBuyPrice.value = tradeLogic.getLimitPrice(false).toString();
                        },
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
                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 5))),
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
                          decoration: BoxDecoration(color: Colors.red, borderRadius: const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  tradeLogic.tradeBuyPrice.value,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 135,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "买入",
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (tradeLogic.contract.value?.code == null) {
                            InfoBarUtils.showErrorDialog("请选择合约");
                            return;
                          }
                          int mOrderPriceType = Order_Type.ORDER_TYPE_MARKET,
                              mTimeInForce = 1,
                              mPositionEffect = PositionEffectType.PositionEffect_COVER;
                          int mTriggerPriceType = 1, mConditionType = 1;
                          if (type == "限价") {
                            mOrderPriceType = Order_Type.ORDER_TYPE_LIMIT;
                          }
                          if (valid == "永久有效") {
                            mTimeInForce = 2;
                          }
                          if (open) {
                            mPositionEffect = PositionEffectType.PositionEffect_OPEN;
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
                              tradeLogic.contract.value?.exCode,
                              tradeLogic.contract.value?.subComCode,
                              tradeLogic.contract.value?.comType,
                              tradeLogic.contract.value?.subConCode,
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
                          decoration: BoxDecoration(color: Colors.green, borderRadius: const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  tradeLogic.tradeSalePrice.value,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 135,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "卖出",
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (tradeLogic.contract.value?.code == null) {
                            InfoBarUtils.showErrorDialog("请选择合约");
                            return;
                          }
                          int mOrderPriceType = Order_Type.ORDER_TYPE_MARKET,
                              mTimeInForce = 1,
                              mPositionEffect = PositionEffectType.PositionEffect_COVER;
                          int mTriggerPriceType = 1, mConditionType = 1;
                          if (type == "限价") {
                            mOrderPriceType = Order_Type.ORDER_TYPE_LIMIT;
                          }
                          if (valid == "永久有效") {
                            mTimeInForce = 2;
                          }
                          if (open) {
                            mPositionEffect = PositionEffectType.PositionEffect_OPEN;
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
                              tradeLogic.contract.value?.exCode,
                              tradeLogic.contract.value?.subComCode,
                              tradeLogic.contract.value?.comType,
                              tradeLogic.contract.value?.subConCode,
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
  // Widget cloudConditionDetails() {
  //   return Expanded(
  //       child: Padding(
  //     padding: const EdgeInsets.all(5),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const SizedBox(width: 15),
  //             Button(
  //                 style: const ButtonStyle(
  //                     padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                     shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                 onPressed: () async {
  //                   await rustDeskWinManager.newCondition("condition", hold: UserUtils.userJson);
  //                 },
  //                 child: Text(
  //                   "条件单修改",
  //                   style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                 )),
  //             const SizedBox(width: 15),
  //             Button(
  //                 style: const ButtonStyle(
  //                     padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  //                     shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
  //                 onPressed: delCondition,
  //                 child: Text(
  //                   "条件单删除",
  //                   style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
  //                 )),
  //           ],
  //         ),
  //         Expanded(
  //           child: Container(
  //               decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
  //               margin: const EdgeInsets.fromLTRB(15, 10, 0, 5),
  //               child: Column(
  //                 children: [
  //                   SingleChildScrollView(
  //                     scrollDirection: Axis.horizontal,
  //                     controller: conditionTitleController,
  //                     child: SizedBox(
  //                       width: 1.2.sw,
  //                       child: Row(children: [
  //                         Expanded(flex: 3, child: tableTitleItem("条件单编号")),
  //                         Expanded(flex: 2, child: tableTitleItem("状态")),
  //                         Expanded(flex: 6, child: tableTitleItem("条件")),
  //                         Expanded(flex: 2, child: tableTitleItem("下单类型")),
  //                         Expanded(flex: 2, child: tableTitleItem("下单价格")),
  //                         Expanded(flex: 1, child: tableTitleItem("买卖")),
  //                         Expanded(flex: 1, child: tableTitleItem("开平")),
  //                         Expanded(flex: 1, child: tableTitleItem("数量")),
  //                         Expanded(flex: 2, child: tableTitleItem("有效日期")),
  //                         Expanded(flex: 3, child: tableTitleItem("备注")),
  //                         Expanded(flex: 3, child: tableTitleItem("创建时间")),
  //                         Expanded(flex: 3, child: tableTitleItem("触发时间")),
  //                       ]),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: Scrollbar(
  //                       controller: conditionItemController,
  //                       key: UniqueKey(),
  //                       style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
  //                       child: SingleChildScrollView(
  //                         scrollDirection: Axis.horizontal,
  //                         controller: conditionItemController,
  //                         child: SizedBox(
  //                             width: 1.2.sw,
  //                             child: ListView.builder(
  //                                 shrinkWrap: true,
  //                                 controller: ScrollController(keepScrollOffset: true),
  //                                 itemCount: tradeLogic.mConditionList.length,
  //                                 padding: const EdgeInsets.only(bottom: 10),
  //                                 itemBuilder: (BuildContext context, int index) {
  //                                   String priceType = "";
  //                                   switch (tradeLogic.mConditionList[index].PriceType) {
  //                                     case 1:
  //                                       priceType = "最新价";
  //                                       break;
  //                                     case 2:
  //                                       priceType = "买价";
  //                                       break;
  //                                     case 3:
  //                                       priceType = "卖价";
  //                                       break;
  //                                   }
  //                                   String constr =
  //                                       "${tradeLogic.mConditionList[index].ContractName}(${tradeLogic.mConditionList[index].CommodityNo}${tradeLogic.mConditionList[index].ContractNo})";
  //                                   switch (tradeLogic.mConditionList[index].ConditionType) {
  //                                     case 1:
  //                                       constr = "$constr $priceType>=${tradeLogic.mConditionList[index].ConditionPrice}";
  //                                       break;
  //                                     case 2:
  //                                       constr = "$constr $priceType<=${tradeLogic.mConditionList[index].ConditionPrice}";
  //                                       break;
  //                                   }
  //                                   String status = "";
  //                                   switch (tradeLogic.mConditionList[index].Status) {
  //                                     case 1:
  //                                       status = "未触发";
  //                                       break;
  //                                     case 2:
  //                                       status = "已删除";
  //                                       break;
  //                                     case 3:
  //                                       status = "到期删除";
  //                                       break;
  //                                     case 4:
  //                                       status = "已触发";
  //                                       break;
  //                                     case 5:
  //                                       status = "指令失败";
  //                                       break;
  //                                   }
  //                                   return GestureDetector(
  //                                     child: Container(
  //                                       color: tradeLogic.mConditionList[index].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
  //                                       child: IntrinsicHeight(
  //                                           child: Row(
  //                                         crossAxisAlignment: CrossAxisAlignment.stretch,
  //                                         children: [
  //                                           Expanded(flex: 3, child: tableContentItem(tradeLogic.mConditionList[index].ConditionOrderNo)),
  //                                           Expanded(flex: 2, child: tableContentItem(status)),
  //                                           Expanded(flex: 6, child: tableContentItem(constr)),
  //                                           Expanded(
  //                                               flex: 2,
  //                                               child:
  //                                                   tableContentItem(tradeLogic.mConditionList[index].OrderType == Order_Type.ORDER_TYPE_MARKET ? "市价" : "限价")),
  //                                           Expanded(flex: 2, child: tableContentItem("${tradeLogic.mConditionList[index].OrderPrice ?? 0}")),
  //                                           Expanded(
  //                                               flex: 1,
  //                                               child: tableContentItem(tradeLogic.mConditionList[index].OrderSide == SideType.SIDE_SELL ? "卖出" : "买入")),
  //                                           Expanded(
  //                                               flex: 1, child: tableContentItem(PositionEffectType.getName(tradeLogic.mConditionList[index].PositionEffect))),
  //                                           Expanded(flex: 1, child: tableContentItem("${tradeLogic.mConditionList[index].OrderQty ?? 0}")),
  //                                           Expanded(flex: 2, child: tableContentItem(tradeLogic.mConditionList[index].TimeInForce == 1 ? "当日有效" : "永久有效")),
  //                                           Expanded(flex: 3, child: tableContentItem(tradeLogic.mConditionList[index].SubmitResultsMsg)),
  //                                           Expanded(flex: 3, child: tableContentItem(tradeLogic.mConditionList[index].CreateAt)),
  //                                           Expanded(flex: 3, child: tableContentItem(tradeLogic.mConditionList[index].UpdateAt)),
  //                                         ],
  //                                       )),
  //                                     ),
  //                                     onTap: () {
  //                                       if (tradeLogic.mConditionList[index].selected == true) return;
  //                                       for (var element in tradeLogic.mConditionList) {
  //                                         element.selected = false;
  //                                       }
  //                                       tradeLogic.mConditionList[index].selected = true;
  //                                       if (mounted) setState(() {});
  //                                     },
  //                                   );
  //                                 })),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               )),
  //         ),
  //       ],
  //     ),
  //   ));
  // }

  ///结算单 Todo
  Widget queryWidget() {
    TextEditingController startController = TextEditingController(text: formatter.format(startTime));
    TextEditingController endController = TextEditingController(text: formatter.format(endTime));
    return Expanded(
      child: StatefulBuilder(builder: (_, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text("开始日期:", style: TextStyle(color: themeController.theme.selectionColor, fontSize: 13)).marginOnly(right: 15),
              SizedBox(
                width: 108,
                child: TextBox(
                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(0), border: Border.all(color: Colors.yellow))),
                  controller: startController,
                  inputFormatters: [FilteringTextInputFormatter(RegExp("[0-9 -:]"), allow: true)],
                  suffix: IconButton(
                    icon: const Icon(FluentIcons.calendar),
                    style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.only(right: 3))),
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
                        transitionDuration: const Duration(milliseconds: 200),
                        barrierDismissible: true,
                      ).then((value) => {
                            if (value != null) {startTime = value, startController.text = formatter.format(startTime), state(() {})}
                          });
                    },
                  ),
                ),
              ).marginOnly(right: 15),
              Text("结束日期:", style: TextStyle(color: themeController.theme.selectionColor, fontSize: 13)).marginOnly(right: 15),
              SizedBox(
                  width: 108,
                  child: TextBox(
                    decoration:
                        WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(0), border: Border.all(color: Colors.yellow))),
                    controller: endController,
                    inputFormatters: [FilteringTextInputFormatter(RegExp("[0-9 -:]"), allow: true)],
                    suffix: IconButton(
                      icon: const Icon(FluentIcons.calendar),
                      style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.only(right: 3))),
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
                          transitionDuration: const Duration(milliseconds: 200),
                          barrierDismissible: true,
                        ).then((value) => {
                              if (value != null) {endTime = value, endController.text = formatter.format(endTime), state(() {})}
                            });
                      },
                    ),
                  )).marginOnly(right: 30),
              Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.yellow),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 25)),
                      shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
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
                      getCloseDetailed();
                    } else if (queryIndex == 3) {
                      getPositionDetailed();
                      // } else if (queryIndex == 4) {
                      //   getPositionSummary();
                    } else if (queryIndex == 5) {
                      getCashReport();
                    }
                    state(() {});
                  })
            ]).marginSymmetric(vertical: 15),
            Row(
              children: [
                Button(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(queryIndex == 0 ? themeController.theme.selectionColor : null),
                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                        shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                    onPressed: () => state(() => queryIndex = 0),
                    child: Text(
                      "资金状况",
                      style: TextStyle(fontSize: 14, color: queryIndex == 0 ? themeController.theme.cardColor : themeController.theme.selectionColor),
                    )),
                Button(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(queryIndex == 1 ? themeController.theme.selectionColor : null),
                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                        shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                    onPressed: () => state(() => queryIndex = 1),
                    child: Text(
                      "历史成交",
                      style: TextStyle(fontSize: 14, color: queryIndex == 1 ? themeController.theme.cardColor : themeController.theme.selectionColor),
                    )).marginOnly(left: 15),
                Button(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(queryIndex == 2 ? themeController.theme.selectionColor : null),
                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                        shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                    onPressed: () => state(() => queryIndex = 2),
                    child: Text(
                      "平仓明细",
                      style: TextStyle(fontSize: 14, color: queryIndex == 2 ? themeController.theme.cardColor : themeController.theme.selectionColor),
                    )).marginOnly(left: 15),
                Button(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(queryIndex == 3 ? themeController.theme.selectionColor : null),
                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                        shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                    onPressed: () => state(() => queryIndex = 3),
                    child: Text(
                      "持仓明细",
                      style: TextStyle(fontSize: 14, color: queryIndex == 3 ? themeController.theme.cardColor : themeController.theme.selectionColor),
                    )).marginOnly(left: 15),
                // Button(
                //     style: ButtonStyle(
                //         backgroundColor: WidgetStatePropertyAll(queryIndex == 4 ? themeController.theme.selectionColor : null),
                //         padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                //         shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                //     onPressed: () => state(() => queryIndex = 4),
                //     child: Text(
                //       "持仓汇总",
                //       style: TextStyle(fontSize: 14, color: queryIndex == 4 ? themeController.theme.activeColor : themeController.theme.selectionColor),
                //     )).marginOnly(left: 15),
                Button(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(queryIndex == 5 ? themeController.theme.selectionColor : null),
                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                        shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                    onPressed: () => state(() => queryIndex = 5),
                    child: Text(
                      "出入金",
                      style:
                          TextStyle(fontSize: 14, color: queryIndex == 5 ? themeController.theme.activeColor : themeController.theme.selectionColor),
                    )).marginOnly(left: 15),
              ],
            ).marginOnly(bottom: 15),
            Expanded(
              child: queryIndex == 0
                  ? Container(
                      decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: capitals.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Row(
                                children: [
                                  Expanded(flex: 1, child: tableTitleItem("初期资金")),
                                  Expanded(flex: 1, child: tableTitleItem("期末资金")),
                                  Expanded(flex: 1, child: tableTitleItem("用户权益")),
                                  Expanded(flex: 1, child: tableTitleItem("可用资金")),
                                  Expanded(flex: 1, child: tableTitleItem("保证金占用")),
                                  Expanded(flex: 1, child: tableTitleItem("出入金")),
                                  Expanded(flex: 1, child: tableTitleItem("平仓盈亏")),
                                  Expanded(flex: 1, child: tableTitleItem("浮动盈亏")),
                                  Expanded(flex: 1, child: tableTitleItem("手续费")),
                                  Expanded(flex: 1, child: tableTitleItem("风险度")),
                                ],
                              );
                            } else {
                              return GestureDetector(
                                child: Container(
                                  color: capitals[index - 1].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
                                  child: IntrinsicHeight(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(flex: 1, child: tableContentItem("${capitals[index - 1].TermInitial ?? 0.0}")),
                                      Expanded(flex: 1, child: tableContentItem("${capitals[index - 1].TermEnd ?? 0.0}")),
                                      Expanded(flex: 1, child: tableContentItem("${capitals[index - 1].Equity ?? 0.0}")),
                                      Expanded(flex: 1, child: tableContentItem("${capitals[index - 1].Available ?? 0.0}")),
                                      Expanded(flex: 1, child: tableContentItem("${capitals[index - 1].OccupyDeposit ?? 0.0}")),
                                      Expanded(
                                          flex: 1,
                                          child: tableContentItem(
                                              "${(capitals[index - 1].CashInValue ?? 0) + (capitals[index - 1].CashOutValue ?? 0)}")),
                                      Expanded(flex: 1, child: tableContentItem("${capitals[index - 1].CloseProfit ?? 0.0}")),
                                      Expanded(flex: 1, child: tableContentItem("${capitals[index - 1].FloatProfit ?? 0.0}")),
                                      Expanded(flex: 1, child: tableContentItem("${capitals[index - 1].Fee ?? 0.0}")),
                                      Expanded(flex: 1, child: tableContentItem("${capitals[index - 1].OccupyDeposit ?? 0.0}")),
                                    ],
                                  )),
                                ),
                                onTap: () {
                                  if (capitals[index - 1].selected == true) return;
                                  for (var element in capitals) {
                                    element.selected = false;
                                  }
                                  capitals[index - 1].selected = true;
                                  if (mounted) setState(() {});
                                },
                              );
                            }
                          }))
                  : queryIndex == 1
                      ? Container(
                          decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: transactionRecord.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  return Row(
                                    children: [
                                      Expanded(flex: 3, child: tableTitleItem("合约名称")),
                                      Expanded(flex: 2, child: tableTitleItem("合约")),
                                      Expanded(flex: 4, child: tableTitleItem("成交编号")),
                                      Expanded(flex: 4, child: tableTitleItem("委托编号")),
                                      Expanded(flex: 1, child: tableTitleItem("买卖")),
                                      Expanded(flex: 1, child: tableTitleItem("开平")),
                                      Expanded(flex: 1, child: tableTitleItem("数量")),
                                      Expanded(flex: 2, child: tableTitleItem("成交价")),
                                      Expanded(flex: 2, child: tableTitleItem("手续费")),
                                      Expanded(flex: 3, child: tableTitleItem("成交时间")),
                                    ],
                                  );
                                } else {
                                  return GestureDetector(
                                    child: Container(
                                      color: transactionRecord[index - 1].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
                                      child: IntrinsicHeight(
                                          child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(flex: 3, child: tableContentItem(transactionRecord[index - 1].ContractName)),
                                          Expanded(
                                              flex: 2,
                                              child: tableContentItem(
                                                  "${transactionRecord[index - 1].CommodityNo}${transactionRecord[index - 1].ContractNo}")),
                                          Expanded(flex: 4, child: tableContentItem(transactionRecord[index - 1].MatchNo)),
                                          Expanded(flex: 4, child: tableContentItem(transactionRecord[index - 1].OrderId)),
                                          Expanded(
                                              flex: 1,
                                              child: tableContentItem(transactionRecord[index - 1].MatchSide == SideType.SIDE_SELL ? "卖" : "买")),
                                          Expanded(
                                              flex: 1,
                                              child: tableContentItem(PositionEffectType.getName(transactionRecord[index - 1].PositionEffect))),
                                          Expanded(flex: 1, child: tableContentItem("${transactionRecord[index - 1].MatchQty ?? 0}")),
                                          Expanded(flex: 2, child: tableContentItem("${transactionRecord[index - 1].MatchPrice ?? 0}")),
                                          Expanded(flex: 2, child: tableContentItem("${transactionRecord[index - 1].FeeValue ?? 0}")),
                                          Expanded(flex: 3, child: tableContentItem(transactionRecord[index - 1].MatchTime)),
                                        ],
                                      )),
                                    ),
                                    onTap: () {
                                      if (transactionRecord[index - 1].selected == true) return;
                                      for (var element in transactionRecord) {
                                        element.selected = false;
                                      }
                                      transactionRecord[index - 1].selected = true;
                                      if (mounted) setState(() {});
                                    },
                                  );
                                }
                              }))
                      : queryIndex == 2
                          ? Container(
                              decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: close.length + 1,
                                  itemBuilder: (BuildContext context, int index) {
                                    if (index == 0) {
                                      return Row(
                                        children: [
                                          Expanded(flex: 4, child: tableContentItem("平仓时间")),
                                          Expanded(flex: 2, child: tableContentItem("合约")),
                                          Expanded(flex: 2, child: tableContentItem("买卖")),
                                          Expanded(flex: 2, child: tableContentItem("成交价")),
                                          Expanded(flex: 2, child: tableContentItem("数量")),
                                          Expanded(flex: 3, child: tableContentItem("开仓均价")),
                                          Expanded(flex: 3, child: tableContentItem("平仓盈亏")),
                                          Expanded(flex: 3, child: tableContentItem("币种")),
                                        ],
                                      );
                                    } else {
                                      return GestureDetector(
                                        child: Container(
                                          color: close[index - 1].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
                                          child: IntrinsicHeight(
                                              child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(flex: 4, child: tableContentItem(close[index - 1].CreateTime)),
                                              Expanded(
                                                  flex: 2, child: tableContentItem("${close[index - 1].CommodityNo}${close[index - 1].ContractNo}")),
                                              Expanded(
                                                  flex: 2, child: tableContentItem(close[index - 1].CloseSide == SideType.SIDE_SELL ? "卖出" : "买入")),
                                              Expanded(flex: 2, child: tableContentItem("${close[index - 1].ClosePrice ?? 0.0}")),
                                              Expanded(flex: 2, child: tableContentItem("${close[index - 1].CloseQty ?? 0}")),
                                              Expanded(flex: 3, child: tableContentItem("${close[index - 1].PositionAvgPrice ?? 0.0}")),
                                              Expanded(flex: 3, child: tableContentItem("${close[index - 1].CloseProfit ?? 0.0}")),
                                              Expanded(flex: 3, child: tableContentItem(close[index - 1].TradeCurrency)),
                                            ],
                                          )),
                                        ),
                                        onTap: () {
                                          if (close[index - 1].selected == true) return;
                                          for (var element in close) {
                                            element.selected = false;
                                          }
                                          close[index - 1].selected = true;
                                          if (mounted) setState(() {});
                                        },
                                      );
                                    }
                                  }))
                          : queryIndex == 3
                              ? Container(
                                  decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: positions.length + 1,
                                      itemBuilder: (BuildContext context, int index) {
                                        if (index == 0) {
                                          return Row(
                                            children: [
                                              Expanded(flex: 2, child: tableTitleItem("合约")),
                                              Expanded(flex: 2, child: tableTitleItem("买卖")),
                                              Expanded(flex: 2, child: tableTitleItem("数量")),
                                              Expanded(flex: 3, child: tableTitleItem("开仓均价")),
                                              Expanded(flex: 3, child: tableTitleItem("持仓盈亏")),
                                              Expanded(flex: 3, child: tableTitleItem("保证金占用")),
                                              Expanded(flex: 2, child: tableTitleItem("币种")),
                                            ],
                                          );
                                        } else {
                                          return GestureDetector(
                                            child: Container(
                                              color: positions[index - 1].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
                                              child: IntrinsicHeight(
                                                  child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(flex: 2, child: tableContentItem(positions[index - 1].ContractName)),
                                                  Expanded(
                                                      flex: 2,
                                                      child: tableContentItem(positions[index - 1].MatchSide == SideType.SIDE_SELL ? "卖出" : "买入")),
                                                  Expanded(flex: 2, child: tableContentItem("${positions[index - 1].PositionQty ?? 0}")),
                                                  Expanded(flex: 3, child: tableContentItem("${positions[index - 1].PositionPrice ?? 0}")),
                                                  Expanded(flex: 3, child: tableContentItem("${positions[index - 1].PositionProfit ?? 0}")),
                                                  Expanded(flex: 3, child: tableContentItem("${positions[index - 1].MarginValue ?? 0}")),
                                                  Expanded(flex: 2, child: tableContentItem(positions[index - 1].TradeCurrency)),
                                                ],
                                              )),
                                            ),
                                            onTap: () {
                                              if (positions[index - 1].selected == true) return;
                                              for (var element in positions) {
                                                element.selected = false;
                                              }
                                              positions[index - 1].selected = true;
                                              if (mounted) setState(() {});
                                            },
                                          );
                                        }
                                      }))
                              // : queryIndex == 4
                              //     ? Container(
                              //         decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
                              //         child: ListView.builder(
                              //             shrinkWrap: true,
                              //             itemCount: positionSummary.length + 1,
                              //             itemBuilder: (BuildContext context, int index) {
                              //               if (index == 0) {
                              //                 return Row(
                              //                   children: [
                              //                     Expanded(flex: 1, child: tableTitleItem("合约")),
                              //                     Expanded(flex: 1, child: tableTitleItem("买卖")),
                              //                     Expanded(flex: 2, child: tableTitleItem("数量")),
                              //                     Expanded(flex: 3, child: tableTitleItem("开仓均价")),
                              //                     Expanded(flex: 3, child: tableTitleItem("持仓盈亏")),
                              //                     Expanded(flex: 3, child: tableTitleItem("保证金占用")),
                              //                     Expanded(flex: 2, child: tableTitleItem("币种")),
                              //                   ],
                              //                 );
                              //               } else {
                              //                 return GestureDetector(
                              //                   child: Container(
                              //                     color: positionSummary[index - 1].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
                              //                     child: IntrinsicHeight(
                              //                         child: Row(
                              //                       crossAxisAlignment: CrossAxisAlignment.stretch,
                              //                       children: [
                              //                         Expanded(flex: 1, child: tableTitleItem(positionSummary[index - 1].ContractCode)),
                              //                         Expanded(flex: 1, child: tableTitleItem(positionSummary[index - 1].ContractCode)),
                              //                         Expanded(flex: 2, child: tableTitleItem(positionSummary[index - 1].ContractCode)),
                              //                         Expanded(flex: 3, child: tableTitleItem(positionSummary[index - 1].ContractCode)),
                              //                         Expanded(flex: 3, child: tableTitleItem(positionSummary[index - 1].ContractCode)),
                              //                         Expanded(flex: 3, child: tableTitleItem(positionSummary[index - 1].ContractCode)),
                              //                         Expanded(flex: 2, child: tableTitleItem(positionSummary[index - 1].ContractCode)),
                              //                       ],
                              //                     )),
                              //                   ),
                              //                   onTap: () {
                              //                     if (positionSummary[index - 1].selected == true) return;
                              //                     for (var element in positionSummary) {
                              //                       element.selected = false;
                              //                     }
                              //                     positionSummary[index - 1].selected = true;
                              //                     if (mounted) setState(() {});
                              //                   },
                              //                 );
                              //               }
                              //             }))
                              : queryIndex == 5
                                  ? Container(
                                      decoration: BoxDecoration(border: Border.all(color: themeController.theme.micaBackgroundColor)),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: withdrawalRecord.length + 1,
                                          itemBuilder: (BuildContext context, int index) {
                                            if (index == 0) {
                                              return Row(
                                                children: [
                                                  Expanded(flex: 1, child: tableTitleItem("时间")),
                                                  Expanded(flex: 2, child: tableTitleItem("入金")),
                                                  Expanded(flex: 2, child: tableTitleItem("出金")),
                                                ],
                                              );
                                            } else {
                                              return GestureDetector(
                                                child: Container(
                                                  color: withdrawalRecord[index - 1].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
                                                  child: IntrinsicHeight(
                                                      child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      Expanded(flex: 1, child: tableContentItem(withdrawalRecord[index - 1].CreateTime)),
                                                      Expanded(
                                                          flex: 2,
                                                          child: tableContentItem(
                                                              "${withdrawalRecord[index - 1].Currency}:${withdrawalRecord[index - 1].CashInValue ?? 0}")),
                                                      Expanded(
                                                          flex: 2,
                                                          child: tableContentItem(
                                                              "${withdrawalRecord[index - 1].Currency}:${withdrawalRecord[index - 1].CashOutValue ?? 0}")),
                                                    ],
                                                  )),
                                                ),
                                                onTap: () {
                                                  if (withdrawalRecord[index - 1].selected == true) return;
                                                  for (var element in withdrawalRecord) {
                                                    element.selected = false;
                                                  }
                                                  withdrawalRecord[index - 1].selected = true;
                                                  if (mounted) setState(() {});
                                                },
                                              );
                                            }
                                          }),
                                    )
                                  : Container(),
            )
          ],
        ).marginOnly(left: 15, bottom: 15);
      }),
    );
  }

  ///交易设置
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
                      decoration:
                          BoxDecoration(border: Border(right: BorderSide(width: 3, color: settingIndex == 0 ? Colors.yellow : Colors.transparent))),
                      child: Text(
                        "止盈止损",
                        style: TextStyle(color: settingIndex == 0 ? Colors.yellow : themeController.theme.selectionColor),
                      ),
                    ),
                    onTap: () => state(() => settingIndex = 0)),
                GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 68,
                      alignment: Alignment.center,
                      decoration:
                          BoxDecoration(border: Border(right: BorderSide(width: 3, color: settingIndex == 1 ? Colors.yellow : Colors.transparent))),
                      child: Text(
                        "系统",
                        style: TextStyle(color: settingIndex == 1 ? Colors.yellow : themeController.theme.selectionColor),
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
                              itemCount: tradeLogic.exchangeList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 28),
                                    decoration: BoxDecoration(
                                        border:
                                            Border(bottom: BorderSide(width: 2, color: exchangeIndex == index ? Colors.yellow : Colors.transparent))),
                                    child: Text(
                                      tradeLogic.exchangeList[index].exchangeNo ?? "--",
                                      style: TextStyle(color: exchangeIndex == index ? Colors.yellow : themeController.theme.selectionColor),
                                    ),
                                  ),
                                  onTap: () => state(() {
                                    exchangeIndex = index;
                                    tradeLogic.commodityList.clear();
                                    tradeLogic.initCommodityList.value = Utils.getVariety(tradeLogic.exchangeList[index].exchangeNo);
                                    tradeLogic.commodityList.addAll(tradeLogic.initCommodityList);
                                  }),
                                );
                              }),
                        ),
                        Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: tradeLogic.commodityList.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == 0) {
                                    return Row(
                                      children: [
                                        Expanded(flex: 3, child: tableTitleItem("名称")),
                                        Expanded(flex: 3, child: tableTitleItem("代码")),
                                        Expanded(flex: 4, child: tableTitleItem("止损策略")),
                                        Expanded(flex: 4, child: tableTitleItem("有效期")),
                                        Expanded(flex: 3, child: tableTitleItem("跳价单位")),
                                        Expanded(flex: 3, child: tableTitleItem("止盈跳点数")),
                                        Expanded(flex: 3, child: tableTitleItem("止损跳点数")),
                                        Expanded(flex: 2, child: tableTitleItem("操作")),
                                      ],
                                    );
                                  } else {
                                    return GestureDetector(
                                      child: Container(
                                        color: Colors.transparent,
                                        child: IntrinsicHeight(
                                            child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(flex: 3, child: tableContentItem(tradeLogic.commodityList[index - 1].shortName)),
                                            Expanded(flex: 3, child: tableContentItem(tradeLogic.commodityList[index - 1].commodityNo)),
                                            Expanded(flex: 4, child: tableRadioItem("限价", "追踪", index - 1)),
                                            Expanded(flex: 4, child: tableRadioItem("当日", "永久", index - 1)),
                                            Expanded(
                                                flex: 3, child: tableContentItem(tradeLogic.commodityList[index - 1].commodityTickSize?.toString())),
                                            Expanded(flex: 3, child: tablePointItem(index - 1)),
                                            Expanded(flex: 3, child: tablePointItem(index - 1)),
                                            Expanded(flex: 2, child: tableOperateItem(index - 1)),
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
                    child: IntrinsicWidth(
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          settingItem("是否提示下单确认", true),
                          settingItem("启动默认进入自选", false),
                          settingItem("是否显示精简模式", false),
                          settingItem("是否弹出交易弹窗", true),
                          settingItem("默认下单类型", defaultTradeType, yes: "限价", no: "市价", onChange: (v) async {
                            defaultTradeType = true;
                            tradeLogic.price.value = "对手价";
                            await SpUtils.set(SpKey.defaultTradeType, defaultTradeType);
                            if (mounted) setState(() {});
                          }, onChanged: (v) async {
                            defaultTradeType = false;
                            tradeLogic.price.value = "市价";
                            await SpUtils.set(SpKey.defaultTradeType, defaultTradeType);
                            if (mounted) setState(() {});
                          }),
                          settingTypeItem("默认下单面板", defaultTradeMenu, yes: "快手下单", no: "三键下单", or: "传统下单"),
                          settingNotItem("成交提示音", "系统提示音"),
                        ],
                      ),
                    ),
                  ),
            Expanded(child: Container()),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 15, 0),
              child: Button(
                  style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 15))),
                  onPressed: () {},
                  child: const Text("保存")),
            )
          ],
        );
      }),
    );
  }

  Widget settingItem(String title, bool checked, {String? yes, String? no, String? or, Function(bool)? onChange, Function(bool)? onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(flex: 3, child: Text(title, maxLines: 1)),
          Expanded(flex: 2, child: RadioButton(checked: checked, content: Text(yes ?? "是"), onChanged: onChange)),
          Expanded(flex: 2, child: RadioButton(checked: !checked, content: Text(no ?? "否"), onChanged: onChanged)),
          Expanded(flex: 2, child: Container()),
        ],
      ),
    );
  }

  Widget settingTypeItem(String title, int index, {String? yes, String? no, String? or}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(flex: 3, child: Text(title)),
          Expanded(
              flex: 2,
              child: RadioButton(
                  checked: index == 0,
                  content: Text(yes ?? "是"),
                  onChanged: (v) async {
                    defaultTradeMenu = 0;
                    tradeLogic.tradeIndex.value = defaultTradeMenu;
                    await SpUtils.set(SpKey.defaultTradeMenu, defaultTradeMenu);
                    if (mounted) setState(() {});
                  })),
          Expanded(
              flex: 2,
              child: RadioButton(
                  checked: index == 1,
                  content: Text(no ?? "否"),
                  onChanged: (v) async {
                    defaultTradeMenu = 1;
                    tradeLogic.tradeIndex.value = defaultTradeMenu;
                    await SpUtils.set(SpKey.defaultTradeMenu, defaultTradeMenu);
                    if (mounted) setState(() {});
                  })),
          Expanded(
              flex: 2,
              child: RadioButton(
                  checked: index == 2,
                  content: Text(or ?? "或"),
                  onChanged: (v) async {
                    defaultTradeMenu = 2;
                    tradeLogic.tradeIndex.value = defaultTradeMenu;
                    await SpUtils.set(SpKey.defaultTradeMenu, defaultTradeMenu);
                    if (mounted) setState(() {});
                  })),
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
          Expanded(flex: 3, child: Text(title)),
          Expanded(flex: 2, child: RadioButton(checked: true, content: Text(content), onChanged: (v) {})),
          Expanded(flex: 2, child: Container()),
          Expanded(flex: 2, child: Container()),
        ],
      ),
    );
  }
}
