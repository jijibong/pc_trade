import 'dart:async';
import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';
import 'package:trade/util/event_bus/events.dart';

import '../../config/common.dart';
import '../../main.dart';
import '../../model/quote/commodity.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../../model/socket_packet/operation.dart';
import '../../model/user/user.dart';
import '../../server/login/login.dart';
import '../../server/quote/market.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/utils/market_util.dart';
import '../../util/utils/utils.dart';

class QuoteLogic extends GetxController {
  var mExchangeList = <Exchange>[].obs;
  var selectedExchange = Exchange().obs;
  var mContractList = <Contract>[].obs;
  var selectedContract = Contract().obs;
  var mOptionalList = <Contract>[].obs;
  var mVarietyList = <Contract>[].obs;
  var commodityList = <Commodity>[].obs;

  // var selectIndex = 1.obs;
  // var viewIndex = 0.obs;

  late StreamSubscription quoteEventSubscription;
  late StreamSubscription optionEventSubscription;

  setListener() {
    EventBusUtil.getInstance().on<LoginSuccess>().listen((event) async {
      queryOption();
    });

    EventBusUtil.getInstance().on<GetAllContracts>().listen((event) async {
      loadData();
    });

    EventBusUtil.getInstance().on<SwitchContract>().listen((event) async {
      List<int> wnds = await RustDeskMultiWindowManager.instance.getAllSubWindowIds();
      if (wnds.isNotEmpty) {
        String msg = jsonEncode(event.contract);
        await DesktopMultiWindow.invokeMethod(wnds[0], kWindowEventNewContract, msg);
      }
    });
  }

  loadData() async {
    List<Exchange> list = await Utils.getMyExchange(true);
    if (list.isNotEmpty) {
      mExchangeList.clear();
      mExchangeList.addAll(list);
      mExchangeList.refresh();

      selectedExchange.value = mExchangeList[0];
      if (MarketUtils.getDataVarietys(selectedExchange.value.exchangeNo!).isNotEmpty) {
        mContractList.clear();
        mContractList.addAll(MarketUtils.getDataVarietys(selectedExchange.value.exchangeNo!));
        refreshData();
      } else {
        getContract();
      }
    }
  }

  ///切换交易所
  void switchExchange(int index) {
    unSubscriptionQuote();
    selectedExchange.value = mExchangeList[index];
    mExchangeList.refresh();
    selectedExchange.refresh();
    if (MarketUtils.getDataVarietys(selectedExchange.value.exchangeNo).isNotEmpty) {
      mContractList.clear();
      mContractList.addAll(MarketUtils.getDataVarietys(selectedExchange.value.exchangeNo));
      mContractList.refresh();
      refreshData();
    } else {
      getContract();
    }
  }

  /// 取消订阅
  void unSubscriptionQuote() {
    if (mContractList.isNotEmpty) {
      List<String> json = [];
      json = Utils.getSubJson(0, mContractList.length, mContractList);
      EventBusUtil.getInstance().fire(SubEvent(json, Operation.UnSendSub));
    }
  }

  /// 订阅行情
  void subscriptionQuote() {
    if (mContractList.isNotEmpty) {
      List<String> json = [];

      json = Utils.getSubJson(0, mContractList.length, mContractList);
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

  ///获取合约数据
  void getContract() async {
    mContractList.clear();
    mContractList.addAll(await Utils.getContractWithMain(selectedExchange.value.exchangeNo!));
    refreshData();
  }

  void quoteEvent() {
    quoteEventSubscription = EventBusUtil.getInstance().on<QuoteEvent>().listen((event) {
      Contract con = event.con;
      for (var element in mContractList) {
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
      mContractList.refresh();
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

  /// 刷新表格是数据
  void refreshData() async {
    if (LoginServer.isLogin) {
      if (MarketUtils.optionList.isEmpty) {
        await MarketServer.queryOption().then((value) {
          if (value != null) {
            for (var element in mContractList) {
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
        for (var element in mContractList) {
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
        for (var element in mContractList) {
          element.optional = false;
          for (var e in list) {
            if (e.exCode == element.exCode && e.code == element.code && e.comType == element.comType && e.isMain == element.isMain) {
              element.optional = true;
            }
          }
        }
      }
    }
    mContractList.refresh();
    subscriptionQuote();
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
  void queryOption() async {
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
    for (Contract contract in mContractList) {
      if (contract.exCode == con.exCode && contract.code == con.code && contract.comType == con.comType && contract.isMain == con.isMain) {
        contract.optional = change;
        break;
      }
    }
    if (change) {
      mOptionalList.add(con);
    } else {
      mOptionalList.removeWhere((e) => e.exCode == con.exCode && e.code == con.code && e.comType == con.comType);
    }
    mContractList.refresh();
    mOptionalList.refresh();
  }

  ///市场详情页
  goDetails(Contract? contract, {bool? fromOption}) {
    // if (fromOption == true) {
    //   unSubscriptionOption();
    // } else {
    //   unSubscriptionQuote();
    // }
    // if (contract == null) return;
    // Get.to(() => MarketDetail(contract))?.then((value) {
    //   if (value != null) {
    //     contract.optional = value.optional;
    //     if (fromOption == true) {
    //       queryOption();
    //     } else {
    //       mContractList.refresh();
    //       mOptionalList.refresh();
    //       subscriptionQuote();
    //     }
    //   }
    // });
  }
}
