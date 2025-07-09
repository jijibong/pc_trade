import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:trade/page/quote/quote_data.dart';

import '../../main.dart';
import '../../model/k/k_flag.dart';
import '../../model/k/k_preiod.dart';
import '../../model/k/k_time.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../../model/user/user.dart';
import '../../server/login/login.dart';
import '../../server/quote/market.dart';
import '../../server/socket/trade_webSocket.dart';
import '../../server/socket/webSocket.dart';
import '../../util/button/button.dart';
import '../../util/dialog/period_dialog.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/event_bus/events.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
import '../../util/utils/market_util.dart';
import '../../util/utils/utils.dart';
import '../home/home.dart';
import '../quote/quote.dart';
import '../quote/quote_details/quote_details.dart';
import '../quote/quote_logic.dart';

class SubWindow extends StatefulWidget {
  final Map<String, dynamic> params;

  const SubWindow({super.key, required this.params});

  @override
  State<SubWindow> createState() => _SubWindowState();
}

class _SubWindowState extends State<SubWindow> with MultiWindowListener {
  late AppTheme appTheme;
  final QuoteLogic logic = Get.put(QuoteLogic());

  int windowId() {
    return widget.params["windowId"];
  }

  void startDragging(bool isMainWindow) {
    if (isMainWindow) {
      windowManager.startDragging();
    } else {
      WindowController.fromWindowId(kWindowId!).startDragging();
    }
  }

  void setMovable(bool isMainWindow, bool movable) {
    if (isMainWindow) {
      windowManager.setMovable(movable);
    } else {
      WindowController.fromWindowId(kWindowId!).setMovable(movable);
    }
  }

  @override
  void onWindowClose() async {
    await WindowController.fromWindowId(kWindowId!).hide();
    super.onWindowClose();
  }

  Future queryExchange() async {
    await MarketServer.queryExchangeUrl().then((value) async {
      if (value != null) {
        Utils.saveExchange(value);
        await requestAllContract(value);
      }
    });
  }

  Future requestAllContract(List<Exchange> exchanges) async {
    await MarketServer.queryAllContractUrl().then((value) async {
      if (value != null) {
        List<Contract> conList = [];
        MarketUtils.commodityList = value;

        for (var element in value) {
          final contracts = element.contracts;
          if (contracts != null) {
            for (var e in contracts) {
              Contract con = Contract(
                  name: e.shortName,
                  comName: element.shortName,
                  code: e.contractCode,
                  exCode: element.exchangeNo,
                  comType: element.commodityType,
                  subComCode: element.commodityNo,
                  subConCode: e.contractNo,
                  comId: element.id,
                  conId: e.id,
                  contractID: e.id,
                  preSettlePrice: e.preClose,
                  futureTickSize: element.commodityTickSize,
                  contractSize: element.contractSize,
                  currency: element.tradeCurrency,
                  trTime: element.tradeTime,
                  orderNum: element.orderNum);
              conList.add(con);

              if (element.mfContract == e.id) {
                Utils.updateOption(con, true);
              }
            }
          }
        }
        if (conList.isNotEmpty) {
          MarketUtils.contractList = conList;
        }
        SpUtils.set(SpKey.commodity, jsonEncode(value));
        SpUtils.set(SpKey.allContract, jsonEncode(conList));
        // EventBusUtil.getInstance().fire(GetAllContracts(1));
      }
    });
  }

  listener() {
    EventBusUtil.getInstance().on<GoKChart>().listen((event) {
      // logger.i(event.go);
      // if (event.index == widget.index) {
      //   if (event.go) {
      //     appTheme.viewIndex[logic.selectedIndex.value] = 1;
      //     appTheme.selectCommandBarIndex = 0;
      //   } else {
      //     appTheme.viewIndex[logic.selectedIndex.value] = 0;
      //   }
      // }
    });
  }

  initInfo() async {
    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      if (call.method == kWindowEventSubWindow) {
        windowOnTop(windowId());
      } else if (call.method == kWindowEventRequestQuote) {
        Contract? con = MarketUtils.getVariety(
          call.arguments['exCode'],
          call.arguments['code'],
          call.arguments['comType'],
        );
        if (con != null) {
          EventBusUtil.getInstance().fire(SwitchContract(con));
        }
      } else if (call.method == kTradeWindowId) {
        tradeWindowId = call.arguments['id'];
      } else if (call.method == drawLineWindowId) {
        drawToolWindowId = call.arguments['id'];
      } else if (call.method == drawOrderWindowId) {
        dOrderWindowId = call.arguments['id'];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initInfo();
    WebSocketServer().initSocket();
    listener();
    queryExchange();
  }

  @override
  void dispose() {
    DesktopMultiWindow.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appTheme = context.watch<AppTheme>();
    // UserUtils.appContext = context;
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
                child: Row(children: [
                  Image.asset('assets/images/jmaster.ico', width: 16, height: 16),
                  Expanded(
                      child: const Text(
                    "行情",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ).marginOnly(left: 2))
                ]).marginOnly(
                  left: 2,
                  right: 2,
                ),
              ),
              actions: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!kIsWeb) WindowButtons(),
                  //
                  // IconButton(
                  //     icon: const Icon(
                  //       FluentIcons.chrome_minimize,
                  //       color: Colors.white,
                  //     ),
                  //     onPressed: () {
                  //       Future.delayed(Duration.zero, () async {
                  //         await WindowController.fromWindowId(kWindowId!).minimize();
                  //       });
                  //     }),
                  // IconButton(
                  //     icon: const Icon(
                  //       FluentIcons.chrome_restore,
                  //       color: Colors.white,
                  //     ),
                  //     onPressed: () {
                  //       Future.delayed(Duration.zero, () async {
                  //         bool fullscreen = await WindowController.fromWindowId(kWindowId!).isFullScreen();
                  //         logger.i(fullscreen);
                  //         await WindowController.fromWindowId(kWindowId!).setFullscreen(!fullscreen);
                  //         // if (await WindowController.fromWindowId(kWindowId!).isFullScreen()) {
                  //         //   await WindowController.fromWindowId(kWindowId!).setFullscreen(true);
                  //         // } else {
                  //         //   await WindowController.fromWindowId(kWindowId!).setFrame(const Offset(0, 0) & const Size(1450, 850));
                  //         // }
                  //       });
                  //     }),
                  // IconButton(
                  //     icon: const Icon(
                  //       FluentIcons.chrome_close,
                  //       color: Colors.white,
                  //     ),
                  //     onPressed: () {
                  //       Future.delayed(Duration.zero, () async {
                  //         await WindowController.fromWindowId(kWindowId!).hide();
                  //       });
                  //     })
                ],
              )),
          content: Column(
            children: [
              Container(
                  color: appTheme.commandBarColor,
                  child: Row(
                    children: [
                      Expanded(
                          child: CommandBar(
                        overflowBehavior: CommandBarOverflowBehavior.wrap,
                        compactBreakpointWidth: 0.8.sw,
                        primaryItems: [
                          CommandBarButton(
                            icon: Icon(FluentIcons.back, color: appTheme.exchangeTextColor),
                            label: Text('返回', style: TextStyle(color: appTheme.exchangeTextColor)),
                            onPressed: () {
                              if (appTheme.viewIndex[logic.selectedIndex.value] == 1) {
                                if (appTheme.selectCommandBarIndex == 0) {
                                  appTheme.viewIndex[logic.selectedIndex.value] = 0;
                                } else {
                                  if (!appTheme.showChart) {
                                    appTheme.showChart = true;
                                    return;
                                  }
                                  appTheme.selectCommandBarIndex = 0;
                                  KPeriod fs = KPeriod(name: "分时", period: KTime.FS, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                                  EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                                }
                              }
                            },
                          ),
                          CommandBarButton(
                            icon: Icon(FluentIcons.home, color: appTheme.exchangeTextColor),
                            label: Text('首页', style: TextStyle(color: appTheme.exchangeTextColor)),
                            onPressed: () {
                              appTheme.viewIndex[logic.selectedIndex.value] = 0;
                              appTheme.showChart = true;
                            },
                          ),
                          CommandBarButton(
                            icon: Icon(FluentIcons.refresh, color: appTheme.exchangeTextColor),
                            label: Text('刷新', style: TextStyle(color: appTheme.exchangeTextColor)),
                            onPressed: () async {},
                          ),
                          CommandBarButton(
                            icon: Icon(FluentIcons.scale_volume, color: appTheme.exchangeTextColor),
                            label: Text('放大', style: TextStyle(color: appTheme.exchangeTextColor)),
                            onPressed: () {
                              EventBusUtil.getInstance().fire(ScaleKLine(true));
                            },
                          ),
                          CommandBarButton(
                            icon: Icon(FluentIcons.scale_up, color: appTheme.exchangeTextColor),
                            label: Text('缩小', style: TextStyle(color: appTheme.exchangeTextColor)),
                            onPressed: () {
                              EventBusUtil.getInstance().fire(ScaleKLine(false));
                            },
                          ),
                          CommandBarButton(
                            icon: Icon(FluentIcons.edit_create, color: appTheme.exchangeTextColor),
                            label: Text('画图工具', style: TextStyle(color: appTheme.exchangeTextColor)),
                            onPressed: () async {
                              await rustDeskWinManager.newDrawTool("draw");
                            },
                          ),
                          CommandBarButton(
                            icon: Icon(FluentIcons.tablet_mode, color: appTheme.exchangeTextColor),
                            label: Text('画线下单', style: TextStyle(color: appTheme.exchangeTextColor)),
                            onPressed: () async {
                              if (LoginServer.isLogin) {
                                await rustDeskWinManager.newDrawOrder("drawOrder");
                              } else {
                                InfoBarUtils.showInfoDialog("当前用户未登录，请登录后重试");
                              }
                            },
                          ),
                          CommandBarButton(
                            icon: Icon(FluentIcons.line_chart,
                                color: appTheme.selectCommandBarIndex == 0 ? appTheme.exchangeTextColor : appTheme.color),
                            label: Text('分时图', style: TextStyle(color: appTheme.exchangeTextColor)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 0;
                                KPeriod fs = KPeriod(name: "分时", period: KTime.FS, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label:
                                Text('日', style: TextStyle(color: appTheme.selectCommandBarIndex == 1 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 1;
                                KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label:
                                Text('周', style: TextStyle(color: appTheme.selectCommandBarIndex == 2 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 2;
                                KPeriod fs = KPeriod(name: "周", period: 1, cusType: 2, kpFlag: KPFlag.Week, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label:
                                Text('月', style: TextStyle(color: appTheme.selectCommandBarIndex == 3 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 3;
                                KPeriod fs = KPeriod(name: "月", period: 1, cusType: 2, kpFlag: KPFlag.Month, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label:
                                Text('年', style: TextStyle(color: appTheme.selectCommandBarIndex == 4 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              ///Todo period
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 4;
                                KPeriod fs = KPeriod(name: "年", period: 1, cusType: 2, kpFlag: KPFlag.Year, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label:
                                Text('X', style: TextStyle(color: appTheme.selectCommandBarIndex == 5 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              appTheme.selectCommandBarIndex = 5;
                              KPFlag mKPFlag = KPFlag(name: "日", flag: KPFlag.Day, max: 365);
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PeriodDialog().showPeriodDialog(mKPFlag, "天");
                                  });
                              // KPeriod fs = KPeriod(name: "年", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Year, isDel: false);
                              // EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                            },
                          ),
                          CommandBarButton(
                            label:
                                Text('1', style: TextStyle(color: appTheme.selectCommandBarIndex == 6 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 6;
                                KPeriod fs = KPeriod(name: "1分钟", period: KTime.M_1, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label:
                                Text('3', style: TextStyle(color: appTheme.selectCommandBarIndex == 7 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 7;
                                KPeriod fs = KPeriod(name: "3分钟", period: KTime.M_3, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label:
                                Text('5', style: TextStyle(color: appTheme.selectCommandBarIndex == 8 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 8;
                                KPeriod fs = KPeriod(name: "5分钟", period: KTime.M_5, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label: Text('10',
                                style: TextStyle(color: appTheme.selectCommandBarIndex == 9 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 9;
                                KPeriod fs = KPeriod(name: "10分钟", period: KTime.M_10, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label: Text('15',
                                style: TextStyle(color: appTheme.selectCommandBarIndex == 10 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 10;
                                KPeriod fs = KPeriod(name: "15分钟", period: KTime.M_15, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label: Text('30',
                                style: TextStyle(color: appTheme.selectCommandBarIndex == 11 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 11;
                                KPeriod fs = KPeriod(name: "30分钟", period: KTime.M_30, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label: Text('60',
                                style: TextStyle(color: appTheme.selectCommandBarIndex == 12 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 12;
                                KPeriod fs = KPeriod(name: "1小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label: Text('120',
                                style: TextStyle(color: appTheme.selectCommandBarIndex == 13 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              ///Todo period
                              if (ButtonUtil.checkClick()) {
                                appTheme.selectCommandBarIndex = 13;
                                KPeriod fs = KPeriod(name: "2小时", period: 2, cusType: 2, kpFlag: KPFlag.Hour, isDel: false);
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            },
                          ),
                          CommandBarButton(
                            label: Text('Y',
                                style: TextStyle(color: appTheme.selectCommandBarIndex == 14 ? appTheme.exchangeTextColor : appTheme.color)),
                            onPressed: () {
                              appTheme.selectCommandBarIndex = 14;
                              KPFlag mKPFlag = KPFlag(name: "分钟", flag: KPFlag.Minute, max: 1440);
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PeriodDialog().showPeriodDialog(mKPFlag, "分钟");
                                  });
                              // KPeriod fs = KPeriod(name: "年", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Year, isDel: false);
                              // EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                            },
                          ),
                          // const CommandBarSeparator(),
                        ],
                      )),
                      const Icon(FluentIcons.join_online_meeting),
                      SizedBox(width: 2.sp),
                      const Icon(FluentIcons.plug_connected), //FluentIcons.plug_disconnected
                      SizedBox(width: 2.sp),
                    ],
                  )),
              const Expanded(
                child: Quote(1),
              )
            ],
          ),
        ));
  }
}
