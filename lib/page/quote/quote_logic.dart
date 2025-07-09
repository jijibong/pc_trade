import 'dart:async';
import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';
import 'package:trade/util/event_bus/events.dart';

import '../../config/common.dart';
import '../../main.dart';
import '../../model/position/position.dart';
import '../../model/quote/commodity.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../../model/socket_packet/operation.dart';
import '../../model/trade/hold_order.dart';
import '../../model/user/user.dart';
import '../../server/login/login.dart';
import '../../server/position/position.dart';
import '../../server/quote/market.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/utils/market_util.dart';
import '../../util/utils/utils.dart';

class QuoteLogic extends GetxController {
  var mExchangeList = <Exchange>[].obs;
  var selectedExchangeList = List.filled(4, Exchange()).obs;
  // var mContractList = <Contract>[].obs;
  var selectedMContractList = List.filled(4, <Contract>[]).obs;
  var selectedContractList = List.filled(4, Contract()).obs;
  var selectedIndex = 0.obs;
  var mOptionalList = <Contract>[].obs;
  var mVarietyList = <Contract>[].obs;
  var commodityList = <Commodity>[].obs;
  var mHoldList = <HoldOrder>[].obs;

  // var selectIndex = -1.obs;
  // var viewIndex = 0.obs;

  late StreamSubscription quoteEventSubscription;
  late StreamSubscription optionEventSubscription;

  setListener() {
    ///登录成功
    EventBusUtil.getInstance().on<LoginSuccess>().listen((event) async {
      await queryOption();
      await requestHold();
    });

    ///获取合约
    EventBusUtil.getInstance().on<GetAllContracts>().listen((event) async {
      loadData(event.index);
    });
  }

  setAllListener(){
    ///切换合约
    EventBusUtil.getInstance().on<SwitchContract>().listen((event) async {
      String msg = jsonEncode(event.contract);
      if (tradeWindowId != null) {
        await DesktopMultiWindow.invokeMethod(tradeWindowId!, kWindowEventNewContract, msg);
      }
    });
  }

  loadData(int index) async {
    if (mExchangeList.isNotEmpty && selectedMContractList.first.isNotEmpty) return;
    List<Exchange> list = await Utils.getAllExchange();
    List<Contract> tmp = [];
    if (list.isNotEmpty) {
      mExchangeList.clear();
      mExchangeList.addAll(list);
      mExchangeList.refresh();

      selectedExchangeList.value = List.filled(4, mExchangeList[0]);
      selectedExchangeList.refresh();
      if (MarketUtils.getDataVarietys(mExchangeList[0].exchangeNo!).isNotEmpty) {
        tmp = MarketUtils.getDataVarietys(mExchangeList[0].exchangeNo!);
      } else {
        tmp = await Utils.getContractWithMain(mExchangeList[0].exchangeNo!);
      }
      selectedMContractList.value = List.filled(4, tmp);
      refreshData(index);
    }
  }

  ///切换交易所
  void switchExchange(int index, int viewIndex) async {
    unSubscriptionQuote(viewIndex);
    selectedExchangeList[viewIndex] = mExchangeList[index];
    selectedExchangeList.refresh();
    if (MarketUtils.getDataVarietys(selectedExchangeList[viewIndex].exchangeNo).isNotEmpty) {
      selectedMContractList[viewIndex] = MarketUtils.getDataVarietys(selectedExchangeList[viewIndex].exchangeNo);
    } else {
      selectedMContractList[viewIndex] = await Utils.getContractWithMain(selectedExchangeList[viewIndex].exchangeNo!);
    }
    refreshData(viewIndex);
  }

  /// 取消订阅
  void unSubscriptionQuote(int viewIndex) {
    if (selectedMContractList[viewIndex].isNotEmpty) {
      List<String> json = [];
      json = Utils.getSubJson(0, selectedMContractList[viewIndex].length, selectedMContractList[viewIndex]);
      EventBusUtil.getInstance().fire(SubEvent(json, Operation.UnSendSub));
    }
  }

  /// 订阅行情
  void subscriptionQuote(int viewIndex) {
    if (selectedMContractList[viewIndex].isNotEmpty) {
      List<String> json = [];

      json = Utils.getSubJson(0, selectedMContractList[viewIndex].length, selectedMContractList[viewIndex]);
      EventBusUtil.getInstance().fire(SubEvent(json, Operation.SendSub));
    }
  }

  /// 取消订阅自选
  void unSubscriptionOption() {
    if (mOptionalList.isNotEmpty) {
      List<String> json = [];
      json = Utils.getSubJson(0, mOptionalList.length, mOptionalList);
      EventBusUtil.getInstance().fire(SubEvent(json, Operation.UnSendSub));
    }
  }

  /// 订阅自选
  void subscriptionOption({int? start, int? end}) {
    if (mOptionalList.isNotEmpty) {
      List<String> json = [];
      json = Utils.getSubJson(start ?? 0, end ?? mOptionalList.length, mOptionalList);
      EventBusUtil.getInstance().fire(SubEvent(json, Operation.SendSub));
    }
  }

  /// 请求持仓单
  Future requestHold() async {
    if (!LoginServer.isLogin) {
      mHoldList.clear();
      mHoldList.refresh();
      return;
    }
    await PositionServer.queryPosition().then((value) async {
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
            AvailableQty: res.AvailableQty,
          );
          if (res.PositionType == PositionType.POSITION_TODAY) {
            hold.TPosition = res.PositionQty;
          } else if (res.PositionType == PositionType.POSITION_YESTODAY) {
            hold.YPosition = res.PositionQty;
          }
          mHoldList.add(hold);
        }
        mHoldList.refresh();
        EventBusUtil.getInstance().fire(RefreshHold());
      }
    });
  }

  void quoteEvent() {
    quoteEventSubscription = EventBusUtil.getInstance().on<QuoteEvent>().listen((event) {
      Contract con = event.con;
      for (var item in selectedMContractList) {
        for (var element in item) {
          if (element.exCode == con.exCode && element.code == con.code && element.comType == con.comType) {
            element.lastPrice = con.lastPrice;
            element.change = con.change;
            element.changePer = con.changePer;
            element.buyPrice = con.buyPrice;
            element.salePrice = con.salePrice;
            element.volume = con.volume;
            element.highPrice = con.highPrice;
            element.lowPrice = con.lowPrice;
            element.position = con.position;
            element.timeStr = con.timeStr;
            element.delegateSale = con.delegateSale;
            element.delegateBuy = con.delegateBuy;
            element.changeString = con.changeString;
            element.preSettlePrice = con.preSettlePrice;
            element.openPrice = con.openPrice;
            element.high = con.high;
            element.low = con.low;
            element.changePerString = con.changePerString;
            dataHandle(element);
          }
        }
        selectedMContractList.refresh();
      }
    });
  }

  ///自选行情变化
  void optionEvent() {
    optionEventSubscription = EventBusUtil.getInstance().on<QuoteEvent>().listen((event) {
      Contract con = event.con;
      for (var element in mOptionalList) {
        if (element.exCode == con.exCode && element.code == con.code && element.comType == con.comType) {
          element.lastPrice = con.lastPrice;
          element.change = con.change;
          element.changePer = con.changePer;
          element.buyPrice = con.buyPrice;
          element.salePrice = con.salePrice;
          element.volume = con.volume;
          element.highPrice = con.highPrice;
          element.lowPrice = con.lowPrice;
          element.position = con.position;
          element.timeStr = con.timeStr;
          element.delegateSale = con.delegateSale;
          element.delegateBuy = con.delegateBuy;
          element.changeString = con.changeString;
          element.preSettlePrice = con.preSettlePrice;
          element.openPrice = con.openPrice;
          element.high = con.high;
          element.low = con.low;
          element.changePerString = con.changePerString;
          dataHandle(element);
        }
      }
      mOptionalList.refresh();
    });
  }

  ///数据处理
  Contract dataHandle(Contract con) {
    double tick = 0;
    if (con.futureTickSize != null) {
      try {
        tick = double.parse(con.futureTickSize.toString());
      } catch (e) {
        logger.e("${con.futureTickSize} : $e");
      }
    }

    if (con.lastPrice == 0) {
      con.changeString = Utils.double2Str(Utils.dealPointByOld(con.change, tick));
      con.buyPriceString = Utils.d2SBySrc(con.buyPrice?.toDouble(), tick);
      con.salePriceString = Utils.d2SBySrc(con.salePrice?.toDouble(), tick);
      if (con.change != null) {
        if (con.change! < 0) {
          con.changePerString = "${Utils.double2Str(Utils.dealPointBigDecimal(con.changePer?.toDouble(), 2))}%";
          con.changeColor = Common.quoteLowColor;
        } else {
          con.changePerString = "${Utils.double2Str(Utils.dealPointBigDecimal(con.changePer?.toDouble(), 2))}%";
          con.changeColor = Common.quoteHighColor;
        }
      }
      con.high = Utils.d2SBySrc(con.highPrice?.toDouble(), tick);
      con.low = Utils.d2SBySrc(con.lowPrice?.toDouble(), tick);
    } else {
      con.lastPriceString = Utils.d2SBySrc(con.lastPrice?.toDouble(), tick);
      con.changeString = Utils.double2Str(Utils.dealPointByOld(con.change, tick));
      con.buyPriceString = Utils.d2SBySrc(con.buyPrice?.toDouble(), tick);
      con.salePriceString = Utils.d2SBySrc(con.salePrice?.toDouble(), tick);
      if (con.change != null) {
        if (con.change! < 0) {
          con.changePerString = "${Utils.double2Str(Utils.dealPointBigDecimal(con.changePer?.toDouble(), 2))}%";
          con.changeColor = Common.quoteLowColor;
        } else {
          con.changePerString = "${Utils.double2Str(Utils.dealPointBigDecimal(con.changePer?.toDouble(), 2))}%";
          con.changeColor = Common.quoteHighColor;
        }
      }
      con.high = Utils.d2SBySrc(con.highPrice?.toDouble(), tick);
      con.low = Utils.d2SBySrc(con.lowPrice?.toDouble(), tick);
    }

    if (con.preSettlePrice != null) {
      if (con.lastPrice != null) {
        if (con.lastPrice! > con.preSettlePrice!) {
          con.lastPriceColor = Common.quoteHighColor;
        } else if (con.lastPrice! < con.preSettlePrice!) {
          con.lastPriceColor = Common.quoteLowColor;
        }
      }
      if (con.highPrice != null) {
        if (con.highPrice! > con.preSettlePrice!) {
          con.highColor = Common.quoteHighColor;
        } else if (con.highPrice! < con.preSettlePrice!) {
          con.highColor = Common.quoteLowColor;
        }
      }
      if (con.lowPrice != null) {
        if (con.lowPrice! > con.preSettlePrice!) {
          con.lowColor = Common.quoteHighColor;
        } else if (con.lowPrice! < con.preSettlePrice!) {
          con.lowColor = Common.quoteLowColor;
        }
      }
    }
    return con;
  }

  /// 刷新表格数据
  void refreshData(int index) async {
    if (LoginServer.isLogin) {
      if (MarketUtils.optionList.isEmpty) {
        await MarketServer.queryOption().then((value) {
          if (value != null) {
            for (var element in selectedMContractList[index]) {
              element.optional = false;
              for (var item in MarketUtils.optionList) {
                if (item.exCode == element.exCode && item.code == element.code && item.comType == element.comType && item.isMain == element.isMain) {
                  element.optional = true;
                }
              }
            }
          }
        });
      } else {
        for (var element in selectedMContractList[index]) {
          element.optional = false;
          for (var item in MarketUtils.optionList) {
            if (item.exCode == element.exCode && item.code == element.code && item.comType == element.comType && item.isMain == element.isMain) {
              element.optional = true;
            }
          }
        }
      }
    } else {
      List<Contract> list = await MarketUtils.getLocalOptions();
      if (list.isNotEmpty) {
        for (var element in selectedMContractList[index]) {
          element.optional = false;
          for (var e in list) {
            if (e.exCode == element.exCode && e.code == element.code && e.comType == element.comType && e.isMain == element.isMain) {
              element.optional = true;
            }
          }
        }
      }
    }
    selectedMContractList.refresh();
    subscriptionQuote(index);
  }

  ///自选操作
  void optionOperate(Contract pos, {bool? add}) async {
    if (add != true && pos.optional == false) {
      InfoBarUtils.showErrorBar("该合约尚未加入自选");
    } else if (add == true || pos.optional == false) {
      if (LoginServer.isLogin) {
        List<Contract> list = [];
        list.add(pos);
        await MarketServer.addOption(pos).then((value) {
          if (value) {
            Utils.operateOption(pos, true, UserUtils.currentUser!.id!);
            optionChange(pos, true);
            InfoBarUtils.showInfoBar("${pos.name}已加入自选");
          }
        });
      } else {
        Utils.operateOption(pos, true, 0);
        optionChange(pos, true);
        InfoBarUtils.showInfoBar("加入自选成功");
      }
    } else {
      if (LoginServer.isLogin) {
        List<Contract> list = [];
        list.add(pos);
        await MarketServer.delOption(list).then((value) {
          if (value != null) {
            optionChange(pos, false);
            Utils.operateOption(pos, false, UserUtils.currentUser!.id!);
            InfoBarUtils.showInfoBar("${pos.name}已删除自选");
          }
        });
      } else {
        Utils.operateOption(pos, false, 0);
        InfoBarUtils.showInfoBar("删除自选成功");
        optionChange(pos, false);
      }
    }
  }

  ///自选页删除自选
  void delOption(Contract pos) async {
    if (LoginServer.isLogin) {
      List<Contract> list = [];
      list.add(pos);
      MarketServer.delOption(list).then((value) {
        if (value != null) {
          mOptionalList.clear();
          mOptionalList.addAll(value);
          mOptionalList.refresh();
          Utils.operateOption(pos, false, UserUtils.currentUser!.id!);
          InfoBarUtils.showInfoBar("${pos.name}已移出自选");
        } else {
          queryOption();
        }
      });
    } else {
      Utils.operateOption(pos, false, 0).then((value) async {
        InfoBarUtils.showInfoBar("${pos.name}已移出自选");
        List<Contract> list = await MarketUtils.getLocalOptions();
        mOptionalList.clear();
        mOptionalList.addAll(list);
        mOptionalList.refresh();
      });
    }
  }

  ///查询自选
  Future queryOption() async {
    if (LoginServer.isLogin) {
      await MarketServer.queryOption().then((value) {
        if (value != null) {
          mOptionalList.clear();
          mOptionalList.addAll(value);
          mOptionalList.refresh();
        }
      });
    } else {
      List<Contract> list = await MarketUtils.getLocalOptions();
      mOptionalList.clear();
      mOptionalList.addAll(list);
      mOptionalList.refresh();
    }
    subscriptionOption();
  }

  /// 自选变化通知
  void optionChange(Contract con, bool change) {
    for (var e in selectedMContractList) {
      for (Contract contract in e) {
        if (contract.exCode == con.exCode && contract.code == con.code && contract.comType == con.comType && contract.isMain == con.isMain) {
          contract.optional = change;
          break;
        }
      }
    }
    if (change) {
      mOptionalList.add(con);
    } else {
      mOptionalList.removeWhere((e) => e.exCode == con.exCode && e.code == con.code && e.comType == con.comType);
    }
    selectedMContractList.refresh();
    mOptionalList.refresh();
  }
}
