import 'dart:async';
import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';
import 'package:trade/util/event_bus/events.dart';

import '../../config/common.dart';
import '../../main.dart';
import '../../model/k/k_preiod.dart';
import '../../model/option/sector.dart';
import '../../model/pb/quote/fill.pb.dart';
import '../../model/position/position.dart';
import '../../model/quote/commodity.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../../model/socket_packet/operation.dart';
import '../../model/trade/hold_order.dart';
import '../../model/trade/res_hold_order.dart';
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
  // var selectedExchangeList = List.filled(Common.screenCount, Exchange()).obs;
  var selectedExchange = Exchange().obs;
  var selectedMContractList = List.filled(Common.screenCount, <Contract>[]).obs;
  var selectedContractList = List.filled(Common.screenCount, Contract()).obs;
  var selectedIndex = 0.obs; //分屏下当前屏幕序号
  var viewIndexList = List.filled(Common.screenCount, 0).obs; //首页\详情页
  var showChartList = List.filled(Common.screenCount, 0).obs; //图表\列表
  var kPeriodList = List.filled(Common.screenCount, KPeriod()).obs; //周期
  // var homePageList = <Contract>[].obs;
  var selectedSector = List.filled(Common.screenCount, Sector()).obs;
  var homePageList = List.filled(Common.screenCount, <Contract>[]).obs;
  // var mOptionalList = <Contract>[].obs;
  var historyList = <Contract>[].obs;
  var mainContractList = <Contract>[].obs;
  var commodityList = <Commodity>[].obs;
  var mHoldList = <HoldOrder>[].obs;
  var mHoldToContractList = <Contract>[].obs;
  var selectedCommodity = Commodity().obs;
  var quoteFilledList = <Map<String, List<FillData>>>[].obs;
  var sectorList = <Sector>[].obs;

  StreamSubscription? quoteEventSubscription;
  StreamSubscription? optionEventSubscription;
  StreamSubscription? subscriptionA;
  StreamSubscription? subscriptionB;
  StreamSubscription? subscriptionC;

  setListener() {
    ///登录成功
    subscriptionA = EventBusUtil.getInstance().on<LoginSuccess>().listen((event) async {
      await queryOption();
      await requestHold();
    });

    ///获取合约
    subscriptionB = EventBusUtil.getInstance().on<GetAllContracts>().listen((event) async {
      loadData();
    });
  }

  setAllListener() {
    ///切换合约
    subscriptionC = EventBusUtil.getInstance().on<SwitchContract>().listen((event) async {
      String msg = jsonEncode(event.contract);
      if (tradeWindowId != null) {
        await DesktopMultiWindow.invokeMethod(tradeWindowId!, kWindowEventNewContract, msg);
      }
    });
  }

  loadData() async {
    if (mExchangeList.isNotEmpty && selectedMContractList.first.isNotEmpty) return;
    List<Exchange> list = await Utils.getAllExchange();
    if (list.isNotEmpty) {
      mExchangeList.clear();
      mExchangeList.addAll(list);
      mExchangeList.refresh();

      selectedExchange.value = mExchangeList[0];
      // selectedExchangeList.refresh();
      commodityList.value = Utils.getVariety(mExchangeList[0].exchangeNo);
      selectedMContractList.value = List.filled(Common.screenCount, await getContracts(mExchangeList[0].exchangeNo!));
      getMainContracts();
      subscriptionQuote(0);
      // refreshData(index);
    }
    queryOption();
  }

  ///切换交易所
  void switchExchange(int index, int viewIndex) async {
    unSubscriptionQuote(viewIndex);
    selectedExchange.value = mExchangeList[index];
    // selectedExchangeList.refresh();
    commodityList.value = Utils.getVariety(selectedExchange.value.exchangeNo);
    selectedMContractList[viewIndex] = await getContracts(selectedExchange.value.exchangeNo!);
    subscriptionQuote(viewIndex);
    // refreshData(viewIndex);
  }

  Future<List<Contract>> getContracts(String exchangeNo) async {
    List<Contract> tmp = [];
    if (MarketUtils.getDataVarietys(exchangeNo).isNotEmpty) {
      tmp = MarketUtils.getDataVarietys(exchangeNo);
    } else {
      tmp = await Utils.getContract(exchangeNo);
    }
    return tmp;
  }

  getMainContracts() async {
    mainContractList.value = await Utils.getMainContract();
    mainContractList.refresh();
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

  // /// 取消订阅自选
  // void unSubscriptionOption() {
  //   if (mOptionalList.isNotEmpty) {
  //     List<String> json = [];
  //     json = Utils.getSubJson(0, mOptionalList.length, mOptionalList);
  //     EventBusUtil.getInstance().fire(SubEvent(json, Operation.UnSendSub));
  //   }
  // }
  //
  // /// 订阅自选
  // void subscriptionOption({int? start, int? end}) {
  //   if (mOptionalList.isNotEmpty) {
  //     List<String> json = [];
  //     json = Utils.getSubJson(start ?? 0, end ?? mOptionalList.length, mOptionalList);
  //     EventBusUtil.getInstance().fire(SubEvent(json, Operation.SendSub));
  //   }
  // }

  /// 取消订阅首页合约
  void unSubscriptionHome(int index) {
    if (homePageList.isNotEmpty) {
      List<String> json = [];
      json = Utils.getSubJson(0, homePageList[index].length, homePageList[index]);
      EventBusUtil.getInstance().fire(SubEvent(json, Operation.UnSendSub));
    }
  }

  /// 订阅首页合约
  void subscriptionHome(int index, {int? start, int? end}) {
    if (homePageList.isNotEmpty) {
      List<String> json = [];
      json = Utils.getSubJson(start ?? 0, end ?? homePageList[index].length, homePageList[index]);
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
          List<ResHoldOrder> details = [];
          details.add(res);
          hold.detailList = details;
          hold.noMap = {res.PositionNo ?? "": res.PositionNo ?? ""};
          bool isExist = false;
          int position = -1;

          for (var hold in mHoldList) {
            if (isSameOrder(hold, res)) {
              position = mHoldList.indexOf(hold);
              isExist = true;
              break;
            }
          }
          if (isExist) {
            //已存在
            mHoldList[position].detailList?.add(res);
            mHoldList[position].noMap?[res.PositionNo ?? ""] = res.PositionNo ?? "";
            //重新计算此单的均价和数量
            List<ResHoldOrder> details = mHoldList[position].detailList ?? [];
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
            mHoldList[position].quantity = qty;
            mHoldList[position].AvailableQty = availableQty;
            mHoldList[position].open = price;
            mHoldList[position].margin = margin;
            mHoldList[position].floatProfit = profit;
            if (res.PositionType == PositionType.POSITION_TODAY) {
              mHoldList[position].TPosition = (mHoldList[position].TPosition ?? 0) + (res.PositionQty ?? 0);
            } else if (res.PositionType == PositionType.POSITION_YESTODAY) {
              mHoldList[position].YPosition = (mHoldList[position].YPosition ?? 0) + (res.PositionQty ?? 0);
            }
          } else {
            // hold.plStatus = await queryPLRecord(hold);
            mHoldList.add(hold);
          }

          Contract? con = MarketUtils.getVariety(hold.exCode, hold.code, hold.comType);
          if (con != null) {
            mHoldToContractList.add(con);
          }
        }
        mHoldList.refresh();
        mHoldToContractList.refresh();
        EventBusUtil.getInstance().fire(RefreshHold());
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
      for (var item in homePageList) {
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
      }
      homePageList.refresh();
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

  ///刷新自选状态
  void refreshData(int index) async {
    // if (LoginServer.isLogin) {
    //   if (MarketUtils.optionList.isEmpty) {
    //     await MarketServer.queryOption().then((value) {
    //       if (value != null) {
    //         for (var element in selectedMContractList[index]) {
    //           element.optional = false;
    //           for (var item in MarketUtils.optionList) {
    //             if (item.exCode == element.exCode && item.code == element.code && item.comType == element.comType && item.isMain == element.isMain) {
    //               element.optional = true;
    //             }
    //           }
    //         }
    //       }
    //     });
    //   } else {
    //     for (var element in selectedMContractList[index]) {
    //       element.optional = false;
    //       for (var item in MarketUtils.optionList) {
    //         if (item.exCode == element.exCode && item.code == element.code && item.comType == element.comType && item.isMain == element.isMain) {
    //           element.optional = true;
    //         }
    //       }
    //     }
    //   }
    // } else {
    //   List<Contract> list = await MarketUtils.getLocalOptions();
    //   if (list.isNotEmpty) {
    //     for (var element in selectedMContractList[index]) {
    //       element.optional = false;
    //       for (var e in list) {
    //         if (e.exCode == element.exCode && e.code == element.code && e.comType == element.comType && e.isMain == element.isMain) {
    //           element.optional = true;
    //         }
    //       }
    //     }
    //   }
    // }
    // selectedMContractList.refresh();
    // subscriptionQuote(index);
  }

  ///自选操作
  void optionOperate(Contract pos, bool add) async {
    if (LoginServer.isLogin) {
      if (add) {
        await MarketServer.addOption(pos).then((value) {
          if (value) {
            InfoBarUtils.showInfoBar("${pos.name}已加入自选");
          }
        });
      } else {
        await MarketServer.delOption([pos]).then((value) {
          if (value != null) {
            InfoBarUtils.showInfoBar("${pos.name}已移出自选");
          } else {
            queryOption();
          }
        });
      }
    }
  }

  ///取消分屏
  void cancelMultiScreen() {
    selectedIndex = 0.obs;
    viewIndexList.removeRange(1, Common.screenCount);
    viewIndexList.addAll(List.filled(Common.screenCount - 1, 0));
    selectedSector.removeRange(1, Common.screenCount);
    selectedSector.addAll(List.filled(Common.screenCount - 1, Sector()));
  }

  // ///自选页删除自选
  // void delOption(Contract pos) async {
  //   if (LoginServer.isLogin) {
  //     List<Contract> list = [];
  //     list.add(pos);
  //     await MarketServer.delOption(list).then((value) {
  //       if (value != null) {
  //         // Utils.operateOption(pos, false, UserUtils.currentUser!.id!);
  //         InfoBarUtils.showInfoBar("${pos.name}已移出自选");
  //       } else {
  //         queryOption();
  //       }
  //     });
  //   }
  // }

  ///查询自选
  Future queryOption() async {
    if (LoginServer.isLogin) {
      await MarketServer.queryOption().then((value) {
        if (value != null) {
          EventBusUtil.getInstance().fire(OptionRefresh(value));
        }
      });
    }
  }

  /// 自选变化通知
  // void optionChange(Contract con, bool change) {
  //   for (var e in selectedMContractList) {
  //     for (Contract contract in e) {
  //       if (contract.exCode == con.exCode && contract.code == con.code && contract.comType == con.comType && contract.isMain == con.isMain) {
  //         contract.optional = change;
  //         break;
  //       }
  //     }
  //   }
  //   if (change) {
  //     mOptionalList.add(con);
  //   } else {
  //     mOptionalList.removeWhere((e) => e.exCode == con.exCode && e.code == con.code && e.comType == con.comType);
  //   }
  //   selectedMContractList.refresh();
  //   mOptionalList.refresh();
  // }

  ///保存本地自选
  // void saveOption() async {
  //   if (mOptionalList.isNotEmpty) {
  //     List<Option> tmp = [];
  //     for (var element in mOptionalList) {
  //       Option option =
  //           Option(excd: element.exCode, scode: element.code, comCode: element.subComCode, comType: element.comType, isMain: element.isMain);
  //       tmp.add(option);
  //     }
  //     SpUtils.set(SpKey.option, jsonEncode(tmp));
  //   }
  // }

  void destroy() {
    quoteEventSubscription?.cancel();
    optionEventSubscription?.cancel();
    subscriptionA?.cancel();
    subscriptionB?.cancel();
    subscriptionC?.cancel();
  }
}
