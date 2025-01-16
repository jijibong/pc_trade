import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../main.dart';
import '../../model/broker/broker.dart';
import '../../model/k/k_flag.dart';
import '../../model/k/k_preiod.dart';
import '../../model/k/k_time.dart';
import '../../model/quote/contract.dart';
import '../../model/user/user.dart';
import '../../server/login/login.dart';
import '../../server/socket/trade_webSocket.dart';
import '../../server/socket/webSocket.dart';
import '../../util/button/button.dart';
import '../../util/dialog/period_dialog.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/event_bus/events.dart';
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
import '../quote/quote.dart';
import '../quote/quote_logic.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WindowListener, MultiWindowListener {
  final QuoteLogic logic = Get.put(QuoteLogic());
  final _controller = WebviewController();
  TextEditingController severController = TextEditingController(text: Common.brokerId);
  TextEditingController accountController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController vCodeController = TextEditingController();
  final systemController = FlyoutController();
  final helpController = FlyoutController();
  final systemKey = GlobalKey();
  final helpKey = GlobalKey();
  Broker broker = Broker(brokerId: Common.brokerId);
  IpAddress ipAddress = IpAddress();
  List brokerList = [];
  bool savePwd = false;
  String? errorMsg;

  requestNetIp() async {
    await LoginServer.requestNetIp().then((value) {
      if (value != null) {
        ipAddress = value;
      }
    });
  }

  refreshBroker() async {
    await LoginServer.queryBroker(broker.brokerId ?? Common.brokerId).then((value) {
      if (value != null) {
        broker = value;
        Config.URL = "${value.tradeUrl}:${value.tradePort}";
        SpUtils.set(SpKey.baseUrl, "${value.tradeUrl}:${value.tradePort}");
        HttpUtils();
      }
    });
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    // final decision = await showDialog<WebviewPermissionDecision>(
    //   context: context,
    //   builder: (BuildContext context) => ContentDialog(
    //     title: const Text('WebView permission requested'),
    //     content: Text('WebView has requested permission \'$kind\''),
    //     actions: <Widget>[
    //       Button(
    //         onPressed: () => Navigator.pop(context, WebviewPermissionDecision.deny),
    //         child: const Text('Deny'),
    //       ),
    //       Button(
    //         onPressed: () => Navigator.pop(context, WebviewPermissionDecision.allow),
    //         child: const Text('Allow'),
    //       ),
    //     ],
    //   ),
    // );
    //
    // return decision ?? WebviewPermissionDecision.none;
    return WebviewPermissionDecision.none;
  }

  showRiskDialog() async {
    bool? firstOpen = await SpUtils.getBool(SpKey.firstOpen);
    if (firstOpen != false) {
      // if (1 == 1) {
      await _controller.initialize();
      _controller
        ..setBackgroundColor(Colors.white)
        ..setPopupWindowPolicy(WebviewPopupWindowPolicy.deny)
        ..loadUrl(Common.RiskUrl);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) {
                return PopScope(
                    canPop: false,
                    child: ContentDialog(
                        style: const ContentDialogThemeData(decoration: BoxDecoration(color: Colors.white)),
                        content: SizedBox(
                          height: ScreenUtil().screenHeight * 0.8,
                          width: ScreenUtil().screenWidth * 0.82,
                          child: Column(
                            children: [
                              Expanded(
                                child: Webview(
                                  _controller,
                                  permissionRequested: _onPermissionRequested,
                                ),
                              ),
                              // Row(
                              //   crossAxisAlignment: CrossAxisAlignment.center,
                              //   children: [
                              //     StatefulBuilder(
                              //       builder: (context, state) {
                              //         return Container(
                              //           padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 12.sp),
                              //           child: GestureDetector(
                              //             onTap: () {
                              //               agree = !agree;
                              //               state(() {});
                              //             },
                              //             child: Image.asset(
                              //               agree ? "images/option_radio_select.png" : "images/option_radio_unselect.png",
                              //               width: 20.sp,
                              //               height: 20.sp,
                              //             ),
                              //           ),
                              //         );
                              //       },
                              //     ),
                              //     Text(
                              //       "我已阅读并同意",
                              //       textAlign: TextAlign.center,
                              //       style: TextStyle(color: Colors.red, fontSize: 18.sp),
                              //     )
                              //   ],
                              // ),
                              Button(
                                  style: const ButtonStyle(
                                    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 25)),
                                    // shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.sp)))),
                                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                                  ),
                                  onPressed: () async {
                                    await SpUtils.set(SpKey.firstOpen, false).then((value) {
                                      Get.back();
                                    });
                                  },
                                  child: const Text(
                                    "确认",
                                    style: TextStyle(color: Colors.black, fontSize: 20),
                                  )),
                            ],
                          ),
                        )));
              });
        }
      });
    }
  }

  initInfo() async {
    String? account = await SpUtils.getString(SpKey.account);
    bool? save = await SpUtils.getBool(SpKey.savePwd);
    String? password = await SpUtils.getString(SpKey.password);
    if (account != null) {
      accountController.text = account;
    }
    if (save == true && password != null) {
      savePwd = true;
      pwdController.text = password;
    }

    List<Display> displayList = await screenRetriever.getAllDisplays();
    Size size = displayList.first.size;
    Map map = {"width": size.width, "height": size.height};
    await SpUtils.set(SpKey.screenSize, jsonEncode(map));

    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      if (call.method == kWindowEventHide) {
        LoginServer.isLogin = false;
        UserUtils.currentUser = null;
        await rustDeskWinManager.unregisterActiveWindow(call.arguments['id']);
      } else if (call.method == kWindowEventRequestQuote) {
        Contract? con = MarketUtils.getVariety(
          call.arguments['exCode'],
          call.arguments['code'],
          call.arguments['comType'],
        );
        if (con != null) {
          EventBusUtil.getInstance().fire(SwitchContract(con));
        } else {
          InfoBarUtils.showErrorDialog("查询合约失败，请稍后再试");
        }
      } else if (call.method == kTradeWindowId) {
        tradeWindowId = call.arguments['id'];
      }
    });
  }

  tradeAccount() async {
    if (!LoginServer.isLogin) {
      showLogin();
    } else {
      if (logic.selectedContract.value.code != null) {
        String contract = jsonEncode(logic.selectedContract.value);
        await rustDeskWinManager.newRemoteDesktop("trade", contract: contract);
      } else {
        await rustDeskWinManager.newRemoteDesktop("trade");
      }
    }
  }

  showLogin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ContentDialog(
          style: const ContentDialogThemeData(
              decoration: ShapeDecoration(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              padding: EdgeInsets.zero),
          content: StatefulBuilder(builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/tradelogin_bk.png"),
                    Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                          icon: const Icon(FluentIcons.clear),
                          onPressed: () => Get.back(),
                        ))
                  ],
                ),
                boxItem('请输入服务商代码', severController, readOnly: true),
                boxItem('请输入交易账号', accountController),
                boxItem('请输入交易密码', pwdController, isPwd: true),
                // boxItem('请输入验证码', vCodeController),
                // EditableComboBox<String>(
                //   textController: severController,
                //   items: brokerList.map<ComboBoxItem<String>>((e) {
                //     return ComboBoxItem<String>(
                //       value: e,
                //       child: Text(e),
                //     );
                //   }).toList(),
                //   onChanged: (v) {
                //     setState(() => severController.text = v ?? "");
                //   },
                //   placeholder: const Text('请输入服务商代码'),
                //   onFieldSubmitted: (String text) {
                //     return text;
                //   },
                // ),
                Row(
                  children: [
                    const SizedBox(
                      width: 50,
                    ),
                    Checkbox(
                      checked: savePwd,
                      style: CheckboxThemeData(
                        margin: const EdgeInsets.only(right: 10),
                        checkedDecoration: WidgetStatePropertyAll(BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.zero)),
                        uncheckedDecoration:
                            WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.zero, border: Border.all(color: Colors.blue))),
                      ),
                      onChanged: (bool? value) {
                        savePwd = value ?? false;
                        state(() {});
                      },
                    ),
                    const Text("保存密码", style: TextStyle(color: Colors.black))
                  ],
                ),
                if (errorMsg != null)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Text(
                      errorMsg!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15, top: 30),
                  child: FilledButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.yellow),
                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 80))),
                    onPressed: () async {
                      await login().then((_) => state(() {}));
                    },
                    child: const Text(
                      '登 录',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Future login() async {
    if (severController.text.isEmpty) {
      errorMsg = "请输入服务商代码";
    } else if (accountController.text.isEmpty || pwdController.text.isEmpty) {
      errorMsg = "账号或密码不能为空";
    } else {
      await LoginServer.login(accountController.text, pwdController.text, Common.brokerId, "", ipAddress.cip ?? "").then((value) async {
        if (value == true) {
          SpUtils.set(SpKey.account, accountController.text);
          SpUtils.set(SpKey.password, pwdController.text);
          Utils.saveBroker(broker);
          if (savePwd) {
            SpUtils.set(SpKey.savePwd, true);
          } else {
            pwdController.clear();
            SpUtils.set(SpKey.savePwd, false);
          }
          EventBusUtil.getInstance().fire(LoginSuccess());
          Get.back();
          TradeWebSocketServer().initSocket(broker.quoteUrl);
          if (logic.selectedContract.value.code != null) {
            String contract = jsonEncode(logic.selectedContract.value);
            await rustDeskWinManager.newRemoteDesktop("trade", contract: contract);
          } else {
            await rustDeskWinManager.newRemoteDesktop("trade");
          }
        } else {
          errorMsg = value;
        }
      });
    }
  }

  void listener() {
    ///登录
    EventBusUtil.getInstance().on<LoginEvent>().listen((event) {
      tradeAccount();
    });

    ///账户资金数据
    EventBusUtil.getInstance().on<FundUpdateEvent>().listen((fundUpdateEvent) async {
      if (!LoginServer.isLogin) return;
      String string = jsonEncode(fundUpdateEvent.res);
      await DesktopMultiWindow.invokeMethod(tradeWindowId ?? 1, kFundUpdateEvent, string);
    });

    ///行情变化
    // EventBusUtil.getInstance().on<QuoteEvent>().listen((quoteEvent) async {
    //   String string = jsonEncode(quoteEvent.con);
    //   await rustDeskWinManager.call(WindowType.Main, kQuoteEvent, {"quoteEvent": string});
    // });

    ///订单状态变化
    EventBusUtil.getInstance().on<DelRecordEvent>().listen((delRecordEvent) async {
      if (!LoginServer.isLogin) return;
      String string = jsonEncode(delRecordEvent.res);
      await rustDeskWinManager.newLocalNotification("localNotification", hold: string);
    });

    ///持仓变化信息
    EventBusUtil.getInstance().on<PositionUpdateEvent>().listen((positionUpdateEvent) async {
      if (!LoginServer.isLogin) return;
      String string = jsonEncode(positionUpdateEvent.res);
      await DesktopMultiWindow.invokeMethod(tradeWindowId ?? 1, kPositionUpdateEvent, string);
    });

    ///浮动盈亏变化信息
    EventBusUtil.getInstance().on<PositionFloatEvent>().listen((positionFloatEvent) async {
      if (!LoginServer.isLogin) return;
      String string = jsonEncode(positionFloatEvent.res);
      await DesktopMultiWindow.invokeMethod(tradeWindowId ?? 1, kPositionFloatEvent, string);
    });

    ///成交订单信息
    EventBusUtil.getInstance().on<FillUpdateEvent>().listen((fillUpdateEvent) async {
      if (!LoginServer.isLogin) return;
      String string = jsonEncode(fillUpdateEvent.res);
      await DesktopMultiWindow.invokeMethod(tradeWindowId ?? 1, kFillUpdateEvent, string);
    });
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    DesktopMultiWindow.addListener(this);
    rustDeskWinManager.registerActiveWindowListener(onActiveWindowChanged);
    UserUtils.appContext = context;
    initInfo();
    showRiskDialog();
    WebSocketServer().initSocket();
    requestNetIp();
    refreshBroker();
    listener();
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
    DesktopMultiWindow.removeListener(this);
    WebSocketServer().dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return NavigationView(
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: () {
          return DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/jmaster.ico",
                    width: 8.sp,
                  ),
                  Text(
                    "  ${Common.appName}",
                    style: TextStyle(fontSize: 5.sp),
                  ),
                  FlyoutTarget(
                      controller: systemController,
                      child: Button(
                          style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                              elevation: WidgetStatePropertyAll(0),
                              shape: WidgetStatePropertyAll(LinearBorder(side: BorderSide.none))),
                          onPressed: () {
                            systemController.showFlyout(
                                autoModeConfiguration: FlyoutAutoConfiguration(
                                  preferredMode: FlyoutPlacementMode.topCenter,
                                ),
                                barrierDismissible: true,
                                dismissOnPointerMoveAway: false,
                                dismissWithEsc: true,
                                builder: (context) {
                                  return MenuFlyout(items: [
                                    MenuFlyoutItem(
                                      text: Text('快捷键设置', style: TextStyle(fontSize: 5.sp)),
                                      onPressed: Flyout.of(context).close,
                                    ),
                                    MenuFlyoutItem(
                                      text: Text('币种显示设置', style: TextStyle(fontSize: 5.sp)),
                                      onPressed: Flyout.of(context).close,
                                    ),
                                  ]);
                                });
                          },
                          child: Text(
                            "系统",
                            style: TextStyle(fontSize: 5.sp),
                          ))),
                  FlyoutTarget(
                      controller: systemController,
                      child: Button(
                          style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                              elevation: WidgetStatePropertyAll(0),
                              shape: WidgetStatePropertyAll(LinearBorder(side: BorderSide.none))),
                          onPressed: () {
                            systemController.showFlyout(
                                autoModeConfiguration: FlyoutAutoConfiguration(
                                  preferredMode: FlyoutPlacementMode.topCenter,
                                ),
                                barrierDismissible: true,
                                dismissOnPointerMoveAway: false,
                                dismissWithEsc: true,
                                builder: (context) {
                                  return MenuFlyout(items: [
                                    MenuFlyoutItem(
                                      text: Text('关于', style: TextStyle(fontSize: 5.sp)),
                                      onPressed: Flyout.of(context).close,
                                    ),
                                    MenuFlyoutItem(
                                      text: Text('画图', style: TextStyle(fontSize: 5.sp)),
                                      onPressed: Flyout.of(context).close,
                                    ),
                                  ]);
                                });
                          },
                          child: Text(
                            "帮助",
                            style: TextStyle(fontSize: 5.sp),
                          ))),
                ],
              ),
            ),
          );
        }(),
        actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Button(
            onPressed: tradeAccount,
            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(appTheme.commandBarColor)),
            child: const Text('交易账户', textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
            child: ToggleSwitch(
              content: const Text('台灯'),
              checked: FluentTheme.of(context).brightness.isLight,
              onChanged: (v) async {
                // int modeIndex = 0;
                if (v) {
                  appTheme.mode = ThemeMode.light;
                  // modeIndex = 1;
                } else {
                  appTheme.mode = ThemeMode.dark;
                }
                // List<int> wnds = await RustDeskMultiWindowManager.instance.getAllSubWindowIds();
                // if (wnds.isNotEmpty) {
                //   for (int wnd in wnds) {
                //     await DesktopMultiWindow.invokeMethod(wnd, kWindowEventSwitchMode, modeIndex);
                //   }
                // }
              },
            ),
          ),
          if (!kIsWeb) const WindowButtons(),
        ]),
      ),
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
                          if (appTheme.viewIndex == 1) {
                            if (appTheme.selectCommandBarIndex == 0) {
                              appTheme.viewIndex = 0;
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
                          appTheme.viewIndex = 0;
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
                          // await rustDeskWinManager.newDrawTool("draw");
                        },
                      ),
                      CommandBarButton(
                        icon: Icon(FluentIcons.tablet_mode, color: appTheme.exchangeTextColor),
                        label: Text('画线下单', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: Icon(FluentIcons.line_chart, color: appTheme.selectCommandBarIndex == 0 ? appTheme.exchangeTextColor : appTheme.color),
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
                        label: Text('日', style: TextStyle(color: appTheme.selectCommandBarIndex == 1 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 1;
                            KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label: Text('周', style: TextStyle(color: appTheme.selectCommandBarIndex == 2 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 2;
                            KPeriod fs = KPeriod(name: "周", period: KTime.WEEK, cusType: 1, kpFlag: KPFlag.Week, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label: Text('月', style: TextStyle(color: appTheme.selectCommandBarIndex == 3 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 3;
                            KPeriod fs = KPeriod(name: "月", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Month, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label: Text('年', style: TextStyle(color: appTheme.selectCommandBarIndex == 4 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          ///Todo period
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 4;
                            KPeriod fs = KPeriod(name: "年", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Year, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label: Text('X', style: TextStyle(color: appTheme.selectCommandBarIndex == 5 ? appTheme.exchangeTextColor : appTheme.color)),
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
                        label: Text('1', style: TextStyle(color: appTheme.selectCommandBarIndex == 6 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 6;
                            KPeriod fs = KPeriod(name: "1分钟", period: KTime.M_1, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label: Text('3', style: TextStyle(color: appTheme.selectCommandBarIndex == 7 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 7;
                            KPeriod fs = KPeriod(name: "3分钟", period: KTime.M_3, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label: Text('5', style: TextStyle(color: appTheme.selectCommandBarIndex == 8 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 8;
                            KPeriod fs = KPeriod(name: "5分钟", period: KTime.M_5, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label: Text('10', style: TextStyle(color: appTheme.selectCommandBarIndex == 9 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 9;
                            KPeriod fs = KPeriod(name: "10分钟", period: KTime.M_10, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label:
                            Text('15', style: TextStyle(color: appTheme.selectCommandBarIndex == 10 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 10;
                            KPeriod fs = KPeriod(name: "15分钟", period: KTime.M_15, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label:
                            Text('30', style: TextStyle(color: appTheme.selectCommandBarIndex == 11 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 11;
                            KPeriod fs = KPeriod(name: "30分钟", period: KTime.M_30, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label:
                            Text('60', style: TextStyle(color: appTheme.selectCommandBarIndex == 12 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 12;
                            KPeriod fs = KPeriod(name: "1小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label:
                            Text('120', style: TextStyle(color: appTheme.selectCommandBarIndex == 13 ? appTheme.exchangeTextColor : appTheme.color)),
                        onPressed: () {
                          ///Todo period
                          if (ButtonUtil.checkClick()) {
                            appTheme.selectCommandBarIndex = 13;
                            KPeriod fs = KPeriod(name: "2小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour, isDel: false);
                            EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                          }
                        },
                      ),
                      CommandBarButton(
                        label: Text('Y', style: TextStyle(color: appTheme.selectCommandBarIndex == 14 ? appTheme.exchangeTextColor : appTheme.color)),
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
            child: Quote(),
          )
        ],
      ),
    );
  }

  Widget boxItem(String tip, TextEditingController controller, {bool? isPwd, bool? readOnly}) {
    return Container(
        margin: const EdgeInsets.fromLTRB(50, 20, 50, 10),
        child: TextBox(
          controller: controller,
          obscureText: isPwd ?? false,
          readOnly: readOnly ?? false,
          placeholder: tip,
          placeholderStyle: const TextStyle(color: Colors.grey),
          style: TextStyle(color: Colors.blue, fontSize: 17),
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide.none,
                left: BorderSide.none,
                right: BorderSide.none,
                bottom: BorderSide(color: Colors.grey),
              ),
              borderRadius: BorderRadius.zero),
          suffix: isPwd == true
              ? HyperlinkButton(
                  child: Text(
                    "忘记密码",
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                  onPressed: () {},
                )
              : null,
        ));
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('提示'),
            content: const Text('确认要退出${Common.appName}吗？'),
            actions: [
              FilledButton(
                child: const Text('确定'),
                onPressed: () async {
                  Navigator.pop(_);
                  mainWindowClose() async => await windowManager.hide();
                  if (rustDeskWinManager.getActiveWindows().contains(kMainWindowId)) {
                    await rustDeskWinManager.unregisterActiveWindow(kMainWindowId);
                  }
                  await mainWindowClose();
                },
              ),
              Button(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(_);
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: FluentTheme.of(context).brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
