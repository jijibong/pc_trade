import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart' hide Condition;

import '../../model/delegation/comOrder.dart';
import '../../model/delegation/delegateOrder.dart';
import '../../model/delegation/order_state.dart';
import '../../model/pl/pl.dart';
import '../../model/position/add_order.dart';
import '../../model/position/position.dart';
import '../../model/quote/commodity.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../../model/quote/order_type.dart';
import '../../model/quote/position_effect_type.dart';
import '../../model/quote/side_type.dart';
import '../../model/quote/time_in_force_type.dart';
import '../../model/trade/fund.dart';
import '../../model/condition/condition.dart';
import '../../model/trade/hold_order.dart';
import '../../model/trade/margin.dart';
import '../../model/trade/res_hold_order.dart';
import '../../model/user/user.dart';
import '../../server/condition/condition.dart';
import '../../server/delegation/delegation.dart';
import '../../server/delegation/transaction.dart';
import '../../server/pl/pl.dart';
import '../../server/position/position.dart';
import '../../server/trade/deal.dart';
import '../../server/user/user.dart';
import '../../util/dialog/trade_dialog.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/utils/utils.dart';

class TradeLogic extends GetxController {
  var lock = false.obs; //界面锁定
  var tradeIndex = 0.obs; //下单方式
  var posIndex = 0.obs; //持仓/条件单/盈损单
  var delIndex = 0.obs; //可撤/委托/成交
  var num = 1.obs; //下单数量
  var open = true.obs; //开仓/平仓
  var auto = true.obs; //自动（开仓/平仓）
  var dir = true.obs; //买卖
  var contract = Rx<Contract?>(null); //合约
  var hold = Rx<HoldOrder?>(null); //持仓单
  var closeIndex = 0.obs; //全平索引
  var isClosing = false.obs; //全平状态

  ///list
  var exchangeList = <Exchange>[].obs; //交易所
  var initCommodityList = <Commodity>[].obs; //初始品种
  var commodityList = <Commodity>[].obs; //当前品种
  var allContracts = <Contract>[].obs; //所有合约
  var mPlRecordList = <PLRecord>[].obs; //损盈单
  var mHoldList = <HoldOrder>[].obs; //持仓
  var mHoldDetailList = <HoldOrder>[].obs; //持仓明细
  var mComList = <ComOrder>[].obs; //成交
  var mPendList = <DelegateOrder>[].obs; //可撤
  var mDelList = <DelegateOrder>[].obs; //委托
  var mCloseList = <HoldOrder>[].obs; //全平列表
  var mConditionList = <Condition>[].obs; //条件单

  ///资金信息
  var mineAllAssets = "--".obs;
  var mineAvailFunds = "--".obs;
  var mineOccMargin = "--".obs;
  var mineFreezeMargin = "--".obs;
  var mineRiskDegree = "0.0%".obs;
  var mineCloseProfit = 0.0.obs;
  var mineFee = "--".obs;
  var mineFloatPrice = 0.0.obs;
  var canUse = 0.0.obs;
  var mInitMargin = Rx<ResInitMargin?>(null);

  ///交易价格
  var tradeBuyCanOpen = "--".obs;
  var tradeBuyCanClose = "--".obs;
  var tradeSaleCanOpen = "--".obs;
  var tradeSaleCanClose = "--".obs;
  var tradeBuyPrice = "---".obs;
  var tradeSalePrice = "---".obs;
  var tradeClosePrice = "----".obs;
  var price = "对手价".obs;

  /// 加载初始数据
  loadTradeData() async {
    List<Exchange> list = await Utils.getAllExchange();
    if (list.isNotEmpty) {
      exchangeList.clear();
      exchangeList.addAll(list);
      commodityList.clear();
      initCommodityList.value = Utils.getVariety(exchangeList[0].exchangeNo);
      commodityList.addAll(initCommodityList);
    }
  }

  /// 查询止盈止损
  void queryPLRecord() async {
    if (hold.value == null) return;
    await PLServer.getHisPLRecord(hold.value?.exCode, hold.value?.subComCode, hold.value?.subConCode, hold.value?.comType, hold.value?.orderSide)
        .then((value) {
      mPlRecordList.clear();
      if (value != null && value.isNotEmpty) {
        mPlRecordList.addAll(value);
      }
      refresh();
    });
  }

  /// 设置止盈止损
  void requestSetPL() async {
    if (mPlRecordList.isEmpty) return;
    for (var record in mPlRecordList) {
      if (record.StopWin != 0 && record.StopLoss != 0 && record.FloatLoss != 0) {
        await PLServer.setPL(hold.value?.exCode, hold.value?.subComCode, hold.value?.comType, hold.value?.subConCode, hold.value?.orderSide,
                record.RealQty, record.CloseType, record.PositionType, record.StopWin ?? 0, record.StopLoss ?? 0, record.FloatLoss ?? 0)
            .then((value) {
          if (mPlRecordList.indexOf(record) == mPlRecordList.length - 1) {
            if (value != null) {
              mPlRecordList.clear();
              mPlRecordList.addAll(value);
              InfoBarUtils.showSuccessBar("设置止盈止损成功");
            } else {
              queryPLRecord();
            }
          }
        });
      }
    }
  }

  ///打开关闭止盈止损记录
  void enablePLRecord(PLRecord pLRecord, bool checked) async {
    await PLServer.enablePLRecord(
            hold.value?.exCode, hold.value?.subComCode, hold.value?.comType, hold.value?.subConCode, hold.value?.orderSide, pLRecord.Id, checked)
        .then((value) {
      if (value != null) {
        mPlRecordList.clear();
        mPlRecordList.addAll(value);
      } else {
        queryPLRecord();
      }
    });
  }

  ///删除止盈止损
  void delPLRecord(int? recordId) async {
    await PLServer.delPLRecord(
            hold.value?.exCode, hold.value?.subComCode, hold.value?.subConCode, hold.value?.comType, hold.value?.orderSide, recordId)
        .then((value) {
      if (value != null) {
        mPlRecordList.clear();
        mPlRecordList.addAll(value);
        InfoBarUtils.showSuccessBar("删除成功");
      } else {
        queryPLRecord();
      }
    });
  }

  /// 查询合约初始保证金
  void queryInitMargin() async {
    if (contract.value == null) return;
    mInitMargin.value = null;
    await DealServer.getInitMargin(contract.value?.exCode, contract.value?.subComCode, contract.value?.comType, contract.value?.code).then((value) {
      if (value != null) {
        mInitMargin.value = value;
        if (mInitMargin.value == null || mInitMargin.value?.Margin?.MarginValue == 0) {
          tradeBuyCanOpen.value = "---";
          tradeSaleCanOpen.value = "---";
        } else {
          double rate = UserUtils.currentUser?.rates?.where((element) => element.currency == contract.value?.currency).first.rate ?? 1;
          int canOpen = canUse ~/ ((mInitMargin.value?.Margin?.MarginValue ?? 0) * rate);
          tradeBuyCanOpen.value = "$canOpen";
          tradeSaleCanOpen.value = "$canOpen";
        }
      }
    });
  }

  /// 请求持仓单
  void requestHold() async {
    await PositionServer.queryPosition().then((value) async {
      if (value != null) {
        mHoldList.clear();
        mHoldDetailList.clear();
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

          bool isExist = false;
          int position = -1;

          for (var hold in mHoldDetailList) {
            if (isSameOrder(hold, res)) {
              position = mHoldDetailList.indexOf(hold);
              isExist = true;
              break;
            }
          }
          if (isExist) {
            //已存在
            mHoldDetailList[position].detailList?.add(res);
            mHoldDetailList[position].noMap?[res.PositionNo ?? ""] = res.PositionNo ?? "";
            //重新计算此单的均价和数量
            List<ResHoldOrder> details = mHoldDetailList[position].detailList ?? [];
            int qty = 0;
            int availableQty = 0;
            double price = 0;
            double margin = 0;
            double profit = 0;

            for (var detail in details) {
              qty = qty + (detail.PositionQty ?? 0);
              availableQty = availableQty + (detail.AvailableQty ?? 0);
              profit = profit + (detail.PositionProfit ?? 0);
              price = price + (detail.PositionPrice ?? 0) * (detail.PositionQty ?? 0);
              margin = margin + (detail.MarginValue ?? 0) * (detail.PositionQty ?? 0);
            }

            price = price / qty;
            mHoldDetailList[position].quantity = qty;
            mHoldDetailList[position].AvailableQty = availableQty;
            mHoldDetailList[position].open = price;
            mHoldDetailList[position].margin = margin;
            mHoldDetailList[position].floatProfit = profit;
            if (res.PositionType == PositionType.POSITION_TODAY) {
              mHoldDetailList[position].TPosition = (mHoldDetailList[position].TPosition ?? 0) + (res.PositionQty ?? 0);
            } else if (res.PositionType == PositionType.POSITION_YESTODAY) {
              mHoldDetailList[position].YPosition = (mHoldDetailList[position].YPosition ?? 0) + (res.PositionQty ?? 0);
            }
          } else {
            // hold.plStatus = await queryPLRecord(hold);
            mHoldDetailList.add(hold);
          }
        }
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
    });
  }

  ///查询条件单
  void qryCondition() async {
    await ConditionServer.queryCondition().then((value) {
      if (value != null) {
        mConditionList.clear();
        for (Condition con in value) {
          mConditionList.add(con);
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
      }
    });
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

  ///全部平仓
  void closeAllPos() {
    if (mHoldList.isEmpty) {
      InfoBarUtils.showInfoDialog("当前没有持仓单");
      return;
    }
    closeIndex.value = 0;
    isClosing.value = true;
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
    if (hold.value == null) {
      InfoBarUtils.showInfoDialog("请选择需要平仓的单子");
      return;
    }
    int orderSide = hold.value?.orderSide == SideType.SIDE_BUY ? SideType.SIDE_SELL : SideType.SIDE_BUY;
    AddOrder order = AddOrder(
      name: hold.value?.name,
      code: hold.value?.code,
      ExchangeNo: hold.value?.exCode,
      CommodityNo: hold.value?.subComCode,
      ContractNo: hold.value?.subConCode,
      CommodityType: hold.value?.comType,
      OrderType: Order_Type.ORDER_TYPE_MARKET,
      TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
      ExpireTime: "",
      OrderSide: orderSide,
      OrderPrice: 0,
      StopPrice: 0,
      OrderQty: hold.value?.quantity,
      PositionEffect: PositionEffectType.PositionEffect_COVER,
    );
    Get.dialog(TradeDialog().addOrderDialog(order));
  }

  ///快捷反手
  void quickBack() {
    if (mHoldList.isEmpty) {
      InfoBarUtils.showInfoDialog("当前没有持仓单");
      return;
    }
    if (hold.value == null) {
      InfoBarUtils.showInfoDialog("请选择需要反手的单子");
      return;
    }
    int orderSide = hold.value?.orderSide == SideType.SIDE_BUY ? SideType.SIDE_SELL : SideType.SIDE_BUY;
    AddOrder order = AddOrder(
      name: hold.value?.name,
      code: hold.value?.code,
      ExchangeNo: hold.value?.exCode,
      CommodityNo: hold.value?.subComCode,
      ContractNo: hold.value?.subConCode,
      CommodityType: hold.value?.comType,
      OrderType: Order_Type.ORDER_TYPE_MARKET,
      TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
      ExpireTime: hold.value?.ExpireTime,
      OrderSide: orderSide,
      OrderPrice: 0,
      StopPrice: 0,
      OrderQty: hold.value?.quantity,
      PositionEffect: PositionEffectType.PositionEffect_COVER,
    );
    order.needBackHand = true;
    Get.dialog(TradeDialog().addOrderDialog(order));
  }

  ///快捷锁仓
  void quickLock() {
    if (mHoldList.isEmpty) {
      InfoBarUtils.showInfoDialog("当前没有可锁仓的单子");
      return;
    }
    if (hold.value == null) {
      InfoBarUtils.showInfoDialog("请选择需要锁仓的单子");
      return;
    }
    int quantity = getLockPositionNum(hold.value!);
    if (quantity > 0) {
      int orderSide = hold.value?.orderSide == SideType.SIDE_BUY ? SideType.SIDE_SELL : SideType.SIDE_BUY;
      AddOrder order = AddOrder(
        name: hold.value?.name,
        code: hold.value?.code,
        ExchangeNo: hold.value?.exCode,
        CommodityNo: hold.value?.subComCode,
        ContractNo: hold.value?.subConCode,
        CommodityType: hold.value?.comType,
        OrderType: Order_Type.ORDER_TYPE_MARKET,
        TimeInForce: TimeInForceType.ORDER_TIMEINFORCE_GFD,
        ExpireTime: hold.value?.ExpireTime,
        OrderSide: orderSide,
        OrderPrice: 0,
        StopPrice: 0,
        OrderQty: quantity,
        PositionEffect: PositionEffectType.PositionEffect_OPEN,
      );
      Get.dialog(TradeDialog().addOrderDialog(order));
    } else {
      InfoBarUtils.showInfoDialog("当前持仓单不需要锁仓");
    }
  }

  /// 全平
  void closeAll() async {
    if (closeIndex < mCloseList.length) {
      HoldOrder hold = mCloseList[closeIndex.value];
      String? exchangeNo = hold.exCode;
      String? commodityNo = hold.subComCode;
      String? contractNo = hold.subConCode;
      String expireTime = "";
      // String localOrderId = DeviceUtil.createLocalOrderId();
      int commodityType = hold.comType ?? 0;
      int orderType = Order_Type.ORDER_TYPE_MARKET;
      int timeInForce = TimeInForceType.ORDER_TIMEINFORCE_GFD;
      int positionEffect = PositionEffectType.PositionEffect_COVER;
      int orderQty = hold.quantity ?? 0;
      double orderPrice = 0;
      double stopPrice = 0;
      int orderSide = 0;

      if (hold.orderSide == SideType.SIDE_BUY) {
        orderSide = SideType.SIDE_SELL;
      } else if (hold.orderSide == SideType.SIDE_SELL) {
        orderSide = SideType.SIDE_BUY;
      }
      await DealServer.addOrder(exchangeNo ?? "", commodityNo ?? "", contractNo ?? "", commodityType, orderType, timeInForce, expireTime, orderSide,
              orderPrice, stopPrice, orderQty, positionEffect, "")
          .then((value) {
        closeIndex++;
        closeAll();
      });
    } else {
      isClosing.value = false;
      closeIndex.value = 0;
      mHoldList.clear();
      requestHold();
    }
  }

  ///撤单
  void delHold() async {
    if (delIndex.value == 0) {
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

  ///全撤
  void delAllHold() async {
    if (delIndex.value == 0) {
      for (var hold in mPendList) {
        await DealServer.cancelOrder(hold.deleNo ?? "").then((value) {
          if (value) {
            InfoBarUtils.showSuccessBar("撤单成功");
          }
        });
      }
      requestCancelDelOrder();
    } else {
      for (var hold in mDelList) {
        await DealServer.cancelOrder(hold.deleNo ?? "").then((value) {
          if (value) {
            InfoBarUtils.showSuccessBar("撤单成功");
          }
        });
      }
      requestCancelDelOrder();
    }
  }

  /// 查询资金
  void getFund() async {
    await UserServer.getAccountFound().then((value) {
      if (value != null) {
        calcFloatProfit(value);
      }
    });
  }

  /// 切换合约
  void switchCon() async {
    if (hold.value == null) return;
    if (!isSameContract(hold.value!, contract.value)) {
      await DesktopMultiWindow.invokeMethod(
          kMainWindowId, kWindowEventRequestQuote, {"exCode": hold.value!.exCode, "code": hold.value!.code, "comType": hold.value!.comType});
    }
  }

  /// 计算浮盈
  void calcFloatProfit(ResFund mAccountInfo) {
    //可用资金 = 期初结存+平仓盈亏+浮动盈亏-保证金占用-保证金冻结-手续费+出入金-冻结手续费
    //客户权益=期初结存+平仓盈亏+浮动盈亏-手续费+出入金
    //保证金占用/用户权益*100%
    canUse.value = mAccountInfo.Available?.toDouble() ?? 0;
    double all = mAccountInfo.Equity?.toDouble() ?? 1;
    double agree = all == 0 ? 0 : ((mAccountInfo.OccupyDeposit ?? 0) / all) * 100;
    mineAllAssets.value = Utils.double2Str(Utils.dealPointBigDecimal(all, 2));
    mineAvailFunds.value = Utils.double2Str(Utils.dealPointBigDecimal(canUse.value, 2));
    mineOccMargin.value = Utils.dealPointBigDecimal(mAccountInfo.OccupyDeposit?.toDouble(), 2).toString();
    mineFreezeMargin.value = Utils.dealPointBigDecimal(mAccountInfo.FrozenDeposit?.toDouble(), 2).toString();
    mineRiskDegree.value = Utils.dealPointBigDecimal(agree, 2).toString();
    mineCloseProfit.value = Utils.dealPointBigDecimal(mAccountInfo.CloseProfit?.toDouble(), 2);
    mineFee.value = Utils.dealPointBigDecimal(mAccountInfo.Fee?.toDouble(), 2).toString();

    double floatP = mAccountInfo.FloatProfit?.toDouble() ?? 0;
    mineFloatPrice.value = Utils.dealPointBigDecimal(floatP, 2);
  }

  ///刷新价格
  void refreshData() {
    double tick = (contract.value?.futureTickSize ?? 0).toDouble();
    if (price.value == "对手价") {
      tradeBuyPrice.value = Utils.d2SBySrc(contract.value?.salePrice?.toDouble(), tick);
      tradeSalePrice.value = Utils.d2SBySrc(contract.value?.buyPrice?.toDouble(), tick);
    }
    if (price.value == "市价") {
      tradeBuyPrice.value = Utils.d2SBySrc(contract.value?.lastPrice?.toDouble(), tick);
      tradeSalePrice.value = Utils.d2SBySrc(contract.value?.lastPrice?.toDouble(), tick);
    }
  }

  /// 获取锁仓手数
  int getLockPositionNum(HoldOrder src) {
    int count = src.quantity ?? 0;
    for (HoldOrder order in mHoldList) {
      if (order.exCode == src.exCode && order.code == src.code && order.comType == src.comType && order.orderSide != src.orderSide) {
        count = count - (order.quantity ?? 0);
        break;
      }
    }
    return count;
  }

  /// 获取限价价格 side true卖出
  double getLimitPrice(bool side) {
    double value = 0;
    switch (price.value.trim()) {
      case "排队价":
        if (side) {
          value = Utils.getIntegerPrice(contract.value?.salePrice, contract.value?.futureTickSize);
        } else {
          value = Utils.getIntegerPrice(contract.value?.buyPrice, contract.value?.futureTickSize);
        }
        break;
      case "对手价":
        if (side) {
          value = Utils.getIntegerPrice(contract.value?.buyPrice, contract.value?.futureTickSize);
        } else {
          value = Utils.getIntegerPrice(contract.value?.salePrice, contract.value?.futureTickSize);
        }
        break;
      case "市价":
        value = 0;
        break;
      case "最新价":
        value = Utils.getIntegerPrice(contract.value?.lastPrice, contract.value?.futureTickSize);
        break;
      case "超价":
        if (side) {
          value = Utils.getIntegerPrice((contract.value?.buyPrice ?? 0) - (contract.value?.futureTickSize ?? 0), contract.value?.futureTickSize);
        } else {
          value = Utils.getIntegerPrice((contract.value?.salePrice ?? 0) - (contract.value?.futureTickSize ?? 0), contract.value?.futureTickSize);
        }
        break;
    }
    if (price.value != "市价" && price.value != "排队价" && price.value != "对手价" && price.value != "最新价" && price.value != "超价") {
      String str = price.trim();
      if (str.startsWith(".") || str.endsWith(".") || str == "") {
        // InfoBarUtils.showWarningDialog("请输入正确价格");
      } else {
        value = double.parse(price.trim());
        value = Utils.getIntegerPrice(value, contract.value?.futureTickSize);
      }
    }
    return value;
  }

  /// 获取下单类型
  int getOrderType() {
    int type = 2;
    switch (price.value) {
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

  /// 选择持仓买卖条件
  void bsCondition() async {
    int buyNum = 0, saleNum = 0;
    for (HoldOrder order in mHoldDetailList) {
      if (isSameContract(order, contract.value)) {
        if (order.orderSide == SideType.SIDE_SELL) {
          saleNum = order.quantity ?? 0;
        } else {
          buyNum = order.quantity ?? 0;
        }
      }
    }
    tradeBuyCanClose.value = saleNum.toString();
    tradeSaleCanClose.value = buyNum.toString();
  }

  /// 判断持仓单与当前合约是否相同
  bool isSameContract(HoldOrder order, Contract? con) {
    bool isSame = false;
    if (con != null && order.exCode == con.exCode && order.code == con.code && order.comType == con.comType) {
      isSame = true;
    }
    return isSame;
  }
}
