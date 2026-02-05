import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:trade/util/info_bar/info_bar.dart';
import 'package:trade/util/log/log.dart';
import 'package:window_manager/window_manager.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../main.dart';
import '../../model/broker/broker.dart';
import '../../model/k/k_flag.dart';
import '../../model/k/k_preiod.dart';
import '../../model/k/k_time.dart';
import '../../model/message/message.dart';
import '../../model/option/myPage.dart';
import '../../model/quote/contract.dart';
import '../../model/trade/res_hold_order.dart';
import '../../model/user/user.dart';
import '../../server/login/login.dart';
import '../../server/socket/trade_webSocket.dart';
import '../../server/socket/webSocket.dart';
import '../../util/button/button.dart';
import '../../util/dialog/custom_period.dart';
import '../../util/dialog/save_page_dialog.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/event_bus/events.dart';
import '../../util/http/http.dart';
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
import 'message.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WindowListener, MultiWindowListener {
  final ThemeController themeController = Get.find<ThemeController>();
  final QuoteLogic logic = Get.put(QuoteLogic());
  final _controller = WebviewController();
  TextEditingController severController = TextEditingController(text: Common.brokerId);
  TextEditingController accountController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController vCodeController = TextEditingController();
  MultiSplitViewController multiSplitViewController = MultiSplitViewController();
  final ScrollController _scrollController = ScrollController();
  final systemController = FlyoutController();
  final helpController = FlyoutController();
  final pageController = FlyoutController();
  final screenController = FlyoutController();
  final messageController = FlyoutController();
  final systemKey = GlobalKey();
  final helpKey = GlobalKey();
  Broker broker = Broker(brokerId: Common.brokerId);
  IpAddress ipAddress = IpAddress();
  List brokerList = [];
  bool savePwd = false;
  String? mVCodeId;
  String? mVCodeUrl;
  String? errorMsg;
  bool connected = false;
  bool isSearching = false;
  double _dragStartOffset = 0.0;
  double _currentOffset = 0.0;
  List<MyPage> myPage = [];
  MyPage? selectedPage;
  bool myContract = true;
  bool riskDialogShowing = false;
  int selectedIndex = 0;
  int perIndex = -1;
  List<KPeriod> kPeriodList = [];
  List<MessageDate> messageList = []; //消息通知
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _currentFocusIndex = -1;
  late void Function(void Function()) globalState;
  TextEditingController searchController = TextEditingController();
  String _currentDateTime = '';
  DateFormat dateFormatter = DateFormat('yyyy年MM月dd日');
  DateFormat timeFormatter = DateFormat('HH时mm分ss秒');
  List<String> weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
  Timer? timer;

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
    if (firstOpen != false && !riskDialogShowing) {
      riskDialogShowing = true;
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
              dismissWithEsc: false,
              builder: (_) {
                return PopScope(
                    canPop: false,
                    child: ContentDialog(
                        constraints: BoxConstraints(
                          maxWidth: ScreenUtil().screenWidth * 0.9,
                          maxHeight: ScreenUtil().screenHeight * 0.9,
                        ),
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
    String? kPeriod = await SpUtils.getString(SpKey.kPeriod);
    if (account != null) {
      accountController.text = account;
    }
    if (save == true && password != null) {
      savePwd = true;
      pwdController.text = password;
    }
    if (kPeriod != null) {
      List<dynamic> list = jsonDecode(kPeriod);
      kPeriodList.clear();
      for (var element in list) {
        kPeriodList.add(KPeriod.fromJson(element));
      }
    } else {
      kPeriodList = KPeriod.getDefaultKPeriodList();
    }
    if (mounted) setState(() {});

    List<Display> displayList = await screenRetriever.getAllDisplays();
    Size size = displayList.first.size;
    Map map = {"width": size.width, "height": size.height};
    await SpUtils.set(SpKey.screenSize, jsonEncode(map));

    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      ///退出登录
      if (call.method == kWindowEventHide) {
        LoginServer.isLogin = false;
        UserUtils.currentUser = null;
        EventBusUtil.getInstance().fire(LoginSuccess(false));
        TradeWebSocketServer().dispose();
        tradeWindowId = null;
        await rustDeskWinManager.unregisterActiveWindow(call.arguments['id']);
        await rustDeskWinManager.closeAllSubWindows();
        tradeAccount();
      } else if (call.method == kWindowEventRequestQuote) {
        Contract? con = MarketUtils.getVariety(
          call.arguments['exCode'],
          call.arguments['code'],
          call.arguments['comType'],
        );
        if (con != null) {
          EventBusUtil.getInstance().fire(SwitchContract(0, con));
          // } else {
          //   InfoBarUtils.showErrorDialog("查询合约失败，请稍后再试");
        }
      } else if (call.method == kTradeWindowId) {
        tradeWindowId = call.arguments['id'];
      } else if (call.method == drawLineWindowId) {
        drawToolWindowId = call.arguments['id'];
      } else if (call.method == drawOrderWindowId) {
        dOrderWindowId = call.arguments['id'];
      } else if (call.method == setLine) {
        var json = jsonDecode(call.arguments["line"]);
        EventBusUtil.getInstance().fire(SetLine(json: json));
      } else if (call.method == kDrawEvent) {
        // EventBusUtil.getInstance().fire(DrawEvent(typeList: call.arguments));
        logic.drawToolObjList.clear();
        var map = call.arguments;
        for (int e in map) {
          logic.drawToolObjList.addAll(Common().drawToolTypes.where((element) => element.index == e));
        }
        await SpUtils.set(SpKey.drawToolLineTypes, jsonEncode(map));
      } else if (call.method == kOrderEvent) {
        if (!LoginServer.isLogin) {
          InfoBarUtils.showInfoDialog("当前用户未登录，请登录后重试");
          return;
        }
        var map = jsonDecode(call.arguments);
        EventBusUtil.getInstance().fire(OrderEvent(json: map));
        // } else if (call.method == kWindowEventSectorManageEvent) {
        //   var jsonString = call.arguments["sectorList"];
        //   EventBusUtil.getInstance().fire(SectorEvent(json: jsonString));
      } else if (call.method == delLines) {
        EventBusUtil.getInstance().fire(OrderEvent(json: false));
      }
    });
  }

  initPage() async {
    String? jsonString = await SpUtils.getString(SpKey.myPage);
    if (jsonString != null && jsonString != "") {
      try {
        myPage.clear();
        var tmp = jsonDecode(jsonString);
        myPage.addAll(tmp.map<MyPage>((e) => MyPage.fromJson(e)).toList());
      } catch (e) {
        logger.e(e);
      }
      if (mounted) setState(() {});
    }
  }

  tradeAccount() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        if (!LoginServer.isLogin) {
          showLogin();
        } else {
          if (logic.selectedContractList[logic.selectedIndex.value].code != null) {
            String contract = jsonEncode(logic.selectedContractList[logic.selectedIndex.value]);
            await rustDeskWinManager.newRemoteDesktop("trade", contract: contract, hold: UserUtils.userJson);
          } else {
            await rustDeskWinManager.newRemoteDesktop("trade", hold: UserUtils.userJson);
          }
        }
      }
    });
  }

  showLogin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      dismissWithEsc: false,
      builder: (context) {
        return ContentDialog(
          style: ContentDialogThemeData(decoration: themeController.theme.dialogTheme.decoration, padding: EdgeInsets.zero),
          content: StatefulBuilder(builder: (context, state) {
            globalState = state;
            return Stack(
              children: [
                ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(20)), child: Image.asset("assets/images/pic@3x.png")),
                Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: const Icon(FluentIcons.clear),
                      onPressed: () => quit(),
                      // onPressed: () => Get.back(),
                    )),
                Positioned.fill(
                    child: FocusScope(
                        child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "欢迎登录",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ).marginOnly(bottom: 20),
                    boxItem('请输入服务商代码', severController, _focusNodes[0], readOnly: true),
                    boxItem('请输入交易账号', accountController, _focusNodes[1]),
                    boxItem('请输入交易密码', pwdController, _focusNodes[2], isPwd: true, refresh: () {
                      state(() {});
                    }),
                    boxItem('请输入验证码', vCodeController, _focusNodes[3]),
                    Row(
                      children: [
                        Checkbox(
                          checked: savePwd,
                          style: const CheckboxThemeData(
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.zero,
                            // uncheckedDecoration:
                            //     WidgetStatePropertyAll(BoxDecoration(color: themeController.theme.menuColor, borderRadius: BorderRadius.circular(5))),
                            // checkedDecoration:
                            //     WidgetStatePropertyAll(BoxDecoration(color: themeController.theme.menuColor, borderRadius: BorderRadius.circular(5))),
                          ),
                          onChanged: (bool? value) {
                            savePwd = value ?? false;
                            state(() {});
                          },
                        ),
                        const Text("记住密码"),
                        const Spacer(),
                        HyperlinkButton(
                          child: Text(
                            "忘记密码",
                            style: TextStyle(color: Common.hyperlinkColor),
                          ),
                          onPressed: () {
                            InfoBarUtils.showWarningDialog("忘记密码请联系系统管理员！");
                          },
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 50).marginOnly(top: 10, bottom: 20),
                    if (errorMsg != null)
                      Text(
                        errorMsg!,
                        style: TextStyle(color: Colors.red),
                      ).marginSymmetric(vertical: 10),
                    FilledButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Common.loginButtonColor),
                          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25)))),
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 80))),
                      onPressed: () async {
                        await login().then((_) => state(() {}));
                      },
                      child: const Text(
                        '确认登录',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ).marginSymmetric(vertical: 10),
                    Text(
                      '上海元泓软件科技有限公司荣誉出品',
                      style: TextStyle(color: Colors.red),
                    ).marginOnly(top: 35),
                  ],
                )))
              ],
            );
          }),
        );
      },
    );
  }

  // 获取并格式化当前日期时间
  void _updateCurrentDateTime() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      setState(() {
        _currentDateTime = "日期：${dateFormatter.format(now)}（${weekdays[now.weekday % 7]}） 时间：${timeFormatter.format(now)}";
      });
    });
  }

  void _onFocusChange(int index, bool hasFocus) {
    if (hasFocus) {
      _currentFocusIndex = index;
    } else if (_currentFocusIndex == index) {
      _currentFocusIndex = -1;
    }
    globalState(() {});
    // print('$index ${hasFocus ? "获得焦点" : "失去焦点"}');
  }

  quit() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            content: SizedBox(
              width: 296,
              height: 154,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '确定要退出${Common.appName}吗？',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ).marginOnly(bottom: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Button(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Common.contentLightBgColor),
                            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), side: BorderSide(color: Common.dialogContentBorderBgColor)))),
                        onPressed: () {
                          Navigator.pop(_);
                        },
                        child: Text('取消', style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.w500)),
                      ),
                      Button(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                        onPressed: () {
                          exit(0);
                        },
                        child: Text(
                          '确定',
                          style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    } else {
      exit(0);
    }
  }

  getVCode() async {
    await LoginServer.getVCode().then((value) {
      if (value != null) {
        mVCodeId = value;
        mVCodeUrl = "${Config.URL}${Config.vcodeImgUrl}$value.png";
        if (mounted) setState(() {});
      }
    });
  }

  Future login() async {
    if (severController.text.isEmpty) {
      errorMsg = "请输入服务商代码";
    } else if (accountController.text.isEmpty || pwdController.text.isEmpty) {
      errorMsg = "账号或密码不能为空";
    } else {
      await LoginServer.login(
              accountController.text, pwdController.text, Common.brokerId, mVCodeId ?? "", vCodeController.text, "", ipAddress.cip ?? "")
          .then((value) async {
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
          EventBusUtil.getInstance().fire(LoginSuccess(true));
          Get.back();
          TradeWebSocketServer().initSocket(broker.quoteUrl);
          showRiskDialog();
          if (logic.selectedContractList[logic.selectedIndex.value].code != null) {
            String contract = jsonEncode(logic.selectedContractList[logic.selectedIndex.value]);
            await rustDeskWinManager.newRemoteDesktop("trade", contract: contract, hold: UserUtils.userJson);
          } else {
            await rustDeskWinManager.newRemoteDesktop("trade", hold: UserUtils.userJson);
          }
        } else {
          errorMsg = value;
        }
      });
    }
  }

  void listener() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        _onFocusChange(i, _focusNodes[i].hasFocus);
      });
    }

    ///登录
    EventBusUtil.getInstance().on<LoginEvent>().listen((event) {
      tradeAccount();
    });

    ///行情连接状态
    EventBusUtil.getInstance().on<SocketState>().listen((event) {
      connected = event.connected;
      if (mounted) setState(() {});
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
      logic.requestHold();
      String string = jsonEncode(positionUpdateEvent.res);
      await DesktopMultiWindow.invokeMethod(tradeWindowId ?? 1, kPositionUpdateEvent, string);
    });

    ///浮动盈亏变化信息
    EventBusUtil.getInstance().on<PositionFloatEvent>().listen((positionFloatEvent) async {
      if (!LoginServer.isLogin) return;
      for (var hold in logic.mHoldList) {
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
          }
        }
      }
      String string = jsonEncode(positionFloatEvent.res);
      await DesktopMultiWindow.invokeMethod(tradeWindowId ?? 1, kPositionFloatEvent, string);
    });

    ///成交订单信息
    EventBusUtil.getInstance().on<FillUpdateEvent>().listen((fillUpdateEvent) async {
      if (!LoginServer.isLogin) return;
      String string = jsonEncode(fillUpdateEvent.res);
      await DesktopMultiWindow.invokeMethod(tradeWindowId ?? 1, kFillUpdateEvent, string);
    });

    ///切换分屏
    EventBusUtil.getInstance().on<SplitScreen>().listen((event) async {
      splitScreen(event.index);
    });

    ///放大分屏
    EventBusUtil.getInstance().on<SelectScreen>().listen((event) async {
      perIndex = themeController.multiScreen.value;
      selectedIndex = event.index;
      themeController.multiScreen.value = 1;
    });

    ///保存页面
    EventBusUtil.getInstance().on<SavePage>().listen((event) async {});
  }

  splitScreen(int count) {
    if (count == 2) {
      while (multiSplitViewController.areasCount > 0) {
        multiSplitViewController.removeAreaAt(multiSplitViewController.areasCount - 1);
      }
      multiSplitViewController.addArea(
        Area(
            builder: (context, area) => MultiSplitView(initialAreas: [
                  Area(builder: (context, area) => const Quote(0, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(1, multiScreen: true)),
                ])),
      );
    } else if (count == 4) {
      while (multiSplitViewController.areasCount > 0) {
        multiSplitViewController.removeAreaAt(multiSplitViewController.areasCount - 1);
      }
      multiSplitViewController.addArea(
        Area(
            builder: (context, area) => MultiSplitView(initialAreas: [
                  Area(builder: (context, area) => const Quote(0, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(1, multiScreen: true)),
                ])),
      );
      multiSplitViewController.addArea(
        Area(
            builder: (context, area) => MultiSplitView(initialAreas: [
                  Area(builder: (context, area) => const Quote(2, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(3, multiScreen: true)),
                ])),
      );
    } else if (count == 6) {
      while (multiSplitViewController.areasCount > 0) {
        multiSplitViewController.removeAreaAt(multiSplitViewController.areasCount - 1);
      }
      multiSplitViewController.addArea(
        Area(
            builder: (context, area) => MultiSplitView(initialAreas: [
                  Area(builder: (context, area) => const Quote(0, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(1, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(2, multiScreen: true)),
                ])),
      );
      multiSplitViewController.addArea(
        Area(
            builder: (context, area) => MultiSplitView(initialAreas: [
                  Area(builder: (context, area) => const Quote(3, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(4, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(5, multiScreen: true)),
                ])),
      );
    } else if (count == 9) {
      while (multiSplitViewController.areasCount > 0) {
        multiSplitViewController.removeAreaAt(multiSplitViewController.areasCount - 1);
      }
      multiSplitViewController.addArea(
        Area(
            builder: (context, area) => MultiSplitView(initialAreas: [
                  Area(builder: (context, area) => const Quote(0, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(1, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(2, multiScreen: true)),
                ])),
      );
      multiSplitViewController.addArea(
        Area(
            builder: (context, area) => MultiSplitView(initialAreas: [
                  Area(builder: (context, area) => const Quote(3, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(4, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(5, multiScreen: true)),
                ])),
      );
      multiSplitViewController.addArea(
        Area(
            builder: (context, area) => MultiSplitView(initialAreas: [
                  Area(builder: (context, area) => const Quote(6, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(7, multiScreen: true)),
                  Area(builder: (context, area) => const Quote(8, multiScreen: true)),
                ])),
      );
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    DesktopMultiWindow.addListener(this);
    rustDeskWinManager.registerActiveWindowListener(onActiveWindowChanged);
    UserUtils.appContext = context;
    initInfo();
    initPage();
    tradeAccount();
    WebSocketServer().initSocket();
    requestNetIp();
    refreshBroker();
    listener();
    _updateCurrentDateTime();
    messageList = [
      MessageDate("交易所于12月10日发布通知‌，自12月12日(星期五)收盘结算时起，调整白银期货AG2602合约的交易规则：涨跌停板幅度扩大至15%，套保持仓交易保证金比例设为16%，一般持仓交易保证金比例设为17%。若遇市场风险情况，将在此基础上进一步调整。‌",
          "10:05", false),
      MessageDate("中国期货业协会近期信息‌显示，已有超30家国内保险机构参与期市套保，期货市场在服务实体经济方面持续发挥作用，例如通过“保险+期货”项目支持农业产业。‌", "10:05", false),
      MessageDate("浙商期货提醒客户注意2601合约临近交割月的持仓调整要求，并根据上期所通知同步调整白银期货的保证金比例和涨跌停板幅度。‌", "12-08", true),
      MessageDate("浙商期货提醒客户注意0312合约临近交割月", "12-08", true),
    ];
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
    DesktopMultiWindow.removeListener(this);
    WebSocketServer().dispose();
    _controller.dispose();
    _scrollController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return NavigationView(
        appBar: NavigationAppBar(
          height: 60,
          automaticallyImplyLeading: false,
          backgroundColor: themeController.theme.inactiveBackgroundColor,
          title: () {
            return DragToMoveArea(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        Text(
                          "  ${Common.appName}",
                          style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                                icon: Image.asset(
                                  "assets/images/icon_more@3x.png",
                                  width: Common.iconImageWidth,
                                ),
                                onPressed: () {})
                            .marginSymmetric(horizontal: 18),
                        !isSearching
                            ? IconButton(
                                icon: Image.asset(
                                  "assets/images/icon_search@3x.png",
                                  width: Common.iconImageWidth,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isSearching = true;
                                  });
                                })
                            : SizedBox(
                                height: 36,
                                child: AutoSuggestBox(
                                  controller: searchController,
                                  decoration: WidgetStatePropertyAll(BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Common.dialogContentBorderBgColor, width: 1))),
                                  trailingIcon: Image.asset(
                                    "assets/images/icon_search@3x.png",
                                    width: Common.iconImageWidth,
                                  ),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  items: MarketUtils.contractList.map((e) {
                                    return AutoSuggestBoxItem<Contract>(
                                      value: e,
                                      label: e.code ?? "--",
                                    );
                                  }).toList(),
                                  onSelected: (item) {
                                    if (item.value != null) {
                                      EventBusUtil.getInstance().fire(SwitchContract(0, logic.selectedContractList[0]));
                                      EventBusUtil.getInstance().fire(GoKChart(true, 0));
                                    }
                                  },
                                ),
                              ),
                      ],
                    )),
                    SizedBox(
                      width: 45.sp,
                      child: Row(
                        children: [
                          Expanded(
                              child: Button(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(themeController.selectIndex.value == 0
                                          ? themeController.theme.navigationPaneTheme.backgroundColor
                                          : themeController.theme.navigationPaneTheme.highlightColor),
                                      shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.horizontal(
                                          right: Radius.zero,
                                          left: Radius.circular(25),
                                        ),
                                      )),
                                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8, horizontal: 10))),
                                  onPressed: () {
                                    logic.viewIndexList[0] = 0;
                                    themeController.selectIndex.value = 0;
                                    if (mounted) setState(() {});
                                  },
                                  child: const Text(
                                    "首页",
                                  ))),
                          const Divider(
                            direction: Axis.vertical,
                            size: 3,
                          ),
                          Expanded(
                              child: Button(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(themeController.selectIndex.value == 1
                                          ? themeController.theme.navigationPaneTheme.backgroundColor
                                          : themeController.theme.navigationPaneTheme.highlightColor),
                                      shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.horizontal(
                                          left: Radius.zero,
                                          right: Radius.circular(25),
                                        ),
                                      )),
                                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8, horizontal: 10))),
                                  onPressed: () {
                                    logic.viewIndexList[0] = 0;
                                    selectedIndex = 0;
                                    perIndex = -1;
                                    themeController.selectIndex.value = 1;
                                    themeController.multiScreen.value = 1;
                                    if (mounted) setState(() {});
                                  },
                                  child: const Text(
                                    "期货",
                                  ))),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ).marginSymmetric(vertical: 10),
              ),
            );
          }(),
          actions: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                  icon: Image.asset(
                    "assets/images/icon_transaction@3x.png",
                    width: Common.iconImageWidth,
                  ),
                  onPressed: () {}),
              IconButton(
                  icon: FlyoutTarget(
                    controller: messageController,
                    child: Image.asset(
                      "assets/images/icon_message@3x.png",
                      width: Common.iconImageWidth,
                    ),
                  ),
                  onPressed: () {
                    messageController.showFlyout(
                        placementMode: FlyoutPlacementMode.bottomRight,
                        builder: (context) {
                          return FlyoutContent(
                            color: themeController.isDarkMode.value ? Common.dialogDarkBgColor : Common.dialogLightBgColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: SizedBox(
                              width: 350,
                              height: messageList.isNotEmpty ? 400 : 120,
                              child: Column(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: themeController.isDarkMode.value
                                                      ? Common.checkBoxBorderDarkColor
                                                      : Common.textBoxBorderLightColor))),
                                      child: Row(
                                        children: [
                                          const Text("消息通知", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                          const Spacer(),
                                          if (messageList.isNotEmpty)
                                            GestureDetector(
                                              child: Text("查看全部",
                                                  style: TextStyle(fontSize: 14, color: Common.hyperlinkColor, fontWeight: FontWeight.w600)),
                                              onTap: () {
                                                Get.to(() => MessagePage(messageList));
                                              },
                                            ),
                                        ],
                                      )),
                                  messageList.isNotEmpty
                                      ? Expanded(
                                          child: ListView.builder(
                                              itemCount: messageList.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      margin: const EdgeInsets.only(top: 3),
                                                      decoration: BoxDecoration(
                                                        color: messageList[index].read == true
                                                            ? Colors.transparent
                                                            : themeController.theme.focusTheme.glowColor,
                                                        borderRadius: BorderRadius.circular(3),
                                                      ),
                                                    ).marginOnly(right: 12),
                                                    Expanded(
                                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                      Flexible(
                                                          child: Text(
                                                        messageList[index].message ?? "",
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      )).marginOnly(bottom: 8),
                                                      Text(
                                                        messageList[index].time ?? "",
                                                        style: TextStyle(
                                                            color: themeController.isDarkMode.value
                                                                ? Common.commandTextColor
                                                                : Common.msgTimeLightColor),
                                                      )
                                                    ]))
                                                  ],
                                                ).marginOnly(bottom: 8);
                                              }),
                                        )
                                      : Container(
                                          height: 76,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "暂无消息通知",
                                            style: TextStyle(
                                                color: themeController.isDarkMode.value ? Common.commandTextColor : Common.msgTimeLightColor),
                                          ),
                                        )
                                ],
                              ),
                            ),
                          );
                        });
                  }).marginSymmetric(horizontal: 11),
              IconButton(
                  icon: Image.asset(
                    "assets/images/icon_sun@3x.png",
                    width: Common.iconImageWidth,
                  ),
                  onPressed: () async {
                    themeController.toggleTheme();
                    if (dOrderWindowId != null) {
                      await DesktopMultiWindow.invokeMethod(dOrderWindowId!, toggleTheme, themeController.isDarkMode.value);
                    }
                    if (drawToolWindowId != null) {
                      await DesktopMultiWindow.invokeMethod(drawToolWindowId!, toggleTheme, themeController.isDarkMode.value);
                    }
                  }).marginSymmetric(horizontal: 11),
              IconButton(
                  icon: Image.asset(
                    "assets/images/hx_icon_14@3x.png",
                    width: Common.iconImageWidth,
                  ),
                  onPressed: () {
                    tradeAccount();
                  }).marginOnly(right: 11),
              if (!kIsWeb) const WindowButtons(),
            ]),
          ),
        ),
        content: Column(
          children: [
            Container(
                color: themeController.theme.cardColor,
                child: Row(
                  children: [
                    Expanded(
                        child: CommandBar(
                      overflowBehavior: CommandBarOverflowBehavior.wrap,
                      compactBreakpointWidth: 0.8.sw,
                      primaryItems: [
                        CommandBarButton(
                          icon: Image.asset(
                            "assets/images/icon_back@3x.png",
                            width: Common.iconImageWidth,
                          ).marginSymmetric(horizontal: 5),
                          onPressed: () {
                            if (perIndex != -1 && themeController.selectIndex.value == 0) {
                              themeController.multiScreen.value = perIndex;
                              perIndex = -1;
                              return;
                            }
                            if (logic.viewIndexList[logic.selectedIndex.value] == 1) {
                              EventBusUtil.getInstance().fire(BackEvent(logic.selectedIndex.value));
                            }
                          },
                        ),
                        CommandBarButton(
                          icon: Image.asset(
                            "assets/images/icon_menu@3x.png",
                            width: Common.iconImageWidth,
                          ).marginSymmetric(horizontal: 5),
                          onPressed: () {
                            logic.viewIndexList[logic.selectedIndex.value] = 0;
                            logic.showChartList[logic.selectedIndex.value] = 0;
                            if (mounted) setState(() {});
                          },
                        ),
                        CommandBarButton(
                          icon: Image.asset(
                            "assets/images/icon_refresh@3x.png",
                            width: Common.iconImageWidth,
                          ).marginSymmetric(horizontal: 5),
                          onPressed: () async {
                            EventBusUtil.getInstance().fire(RefreshEvent());
                          },
                        ),
                        // CommandBarButton(
                        //   icon: Image.asset(
                        //     "assets/images/icon_back@3x.png",
                        //     width: Common.iconImageWidth,
                        //   ),
                        //   onPressed: () async {
                        //     if (themeController.multiScreen.value != 1) {
                        //       showDialog(
                        //           context: context,
                        //           builder: (BuildContext context) {
                        //             return PageDialog().savePageDialog((e) {
                        //               EventBusUtil.getInstance().fire(SavePage(e));
                        //             });
                        //           });
                        //     }
                        //     // EventBusUtil.getInstance().fire(RefreshEvent());
                        //   },
                        // ),
                        CommandBarButton(
                          icon: Image.asset(
                            "assets/images/icon_full@3x.png",
                            width: Common.iconImageWidth,
                          ).marginSymmetric(horizontal: 5),
                          onPressed: () {
                            EventBusUtil.getInstance().fire(ScaleKLine(true));
                          },
                        ),
                        CommandBarButton(
                          icon: Image.asset(
                            "assets/images/icon_full_exit@3x.png",
                            width: Common.iconImageWidth,
                          ).marginSymmetric(horizontal: 5),
                          onPressed: () {
                            EventBusUtil.getInstance().fire(ScaleKLine(false));
                          },
                        ),
                        CommandBarButton(
                          icon: Image.asset(
                            "assets/images/icon_fanye_down@3x.png",
                            width: Common.iconImageWidth,
                          ).marginSymmetric(horizontal: 5),
                          onPressed: () {
                            Contract contract = logic.selectedContractList[logic.selectedIndex.value];
                            if (contract.code != null) {
                              if (themeController.selectIndex.value == 1) {
                                int index = logic.selectedMContractList[logic.selectedIndex.value].indexOf(contract);
                                if (index + 1 == logic.selectedMContractList[logic.selectedIndex.value].length) {
                                  index = -1;
                                }
                                Contract newContract = logic.selectedMContractList[logic.selectedIndex.value][index + 1];
                                logic.selectedContractList[logic.selectedIndex.value] = newContract;
                                EventBusUtil.getInstance().fire(SwitchContract(logic.selectedIndex.value, newContract));
                              } else {
                                int index = logic.homePageList[logic.selectedIndex.value].indexOf(contract);
                                if (index + 1 == logic.homePageList[logic.selectedIndex.value].length) {
                                  index = -1;
                                }
                                Contract newContract = logic.homePageList[logic.selectedIndex.value][index + 1];
                                logic.selectedContractList[logic.selectedIndex.value] = newContract;
                                EventBusUtil.getInstance().fire(SwitchContract(logic.selectedIndex.value, newContract));
                              }
                            }
                          },
                        ),
                        CommandBarButton(
                          icon: Image.asset(
                            "assets/images/icon_fanye_up@3x.png",
                            width: Common.iconImageWidth,
                          ).marginSymmetric(horizontal: 5),
                          onPressed: () {
                            Contract contract = logic.selectedContractList[logic.selectedIndex.value];
                            if (contract.code != null) {
                              if (themeController.selectIndex.value == 1) {
                                int index = logic.selectedMContractList[logic.selectedIndex.value].indexOf(contract);
                                if (index == 0) {
                                  index = logic.selectedMContractList[logic.selectedIndex.value].length;
                                }
                                Contract newContract = logic.selectedMContractList[logic.selectedIndex.value][index - 1];
                                logic.selectedContractList[logic.selectedIndex.value] = newContract;
                                EventBusUtil.getInstance().fire(SwitchContract(logic.selectedIndex.value, newContract));
                              } else {
                                int index = logic.homePageList[logic.selectedIndex.value].indexOf(contract);
                                if (index == 0) {
                                  index = logic.homePageList[logic.selectedIndex.value].length;
                                }
                                Contract newContract = logic.homePageList[logic.selectedIndex.value][index - 1];
                                logic.selectedContractList[logic.selectedIndex.value] = newContract;
                                EventBusUtil.getInstance().fire(SwitchContract(logic.selectedIndex.value, newContract));
                              }
                            }
                          },
                        ),
                        // CommandBarButton(
                        //   icon: Icon(FluentIcons.tablet_mode, color: themeController.theme.color),
                        //   label: Text('画线下单', style: TextStyle(color: themeController.theme.color)),
                        //   onPressed: () async {
                        //     if (LoginServer.isLogin) {
                        //       await rustDeskWinManager.newDrawOrder("drawOrder");
                        //     } else {
                        //       InfoBarUtils.showInfoDialog("当前用户未登录，请登录后重试");
                        //     }
                        //   },
                        // ),
                        CommandBarButton(
                          // icon: Icon(FluentIcons.line_chart,
                          //     color: themeController.selectCommandBarIndex.value == 0
                          //         ? themeController.theme.exchangeTextColor
                          //         : themeController.theme.color),
                          icon: Image.asset("assets/images/icon_line_chart@3x.png",
                                  width: Common.iconImageWidth,
                                  color: themeController.selectCommandBarIndex.value == -1
                                      ? themeController.theme.inactiveColor
                                      : Common.commandTextColor)
                              .marginSymmetric(horizontal: 5),
                          // label: Text('分时图', style: TextStyle(color: themeController.theme.color)),
                          onPressed: () {
                            if (ButtonUtil.checkClick()) {
                              themeController.selectCommandBarIndex.value = -1;
                              KPeriod fs = KPeriod(name: "分时", period: KTime.FS, cusType: 1, kpFlag: KPFlag.Minute);
                              if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                                if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                                  return;
                                }
                                logic.kPeriodList[logic.selectedIndex.value] = fs;
                                logic.viewIndexList[logic.selectedIndex.value] = 1;
                              } else {
                                EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                              }
                            }
                          },
                        ),
                        ...kPeriodList.map((period) {
                          return CommandBarButton(
                            label: Text(
                                    (period.kpFlag == KPFlag.Minute
                                            ? "${period.name?.substring(0, (period.name?.length ?? 2) - 2)}"
                                            : period.kpFlag == KPFlag.Hour
                                                ? "${period.name?.substring(0, (period.name?.length ?? 2) - 2)}h"
                                                : period.period == 1
                                                    ? period.periodType
                                                    : period.name) ??
                                        "",
                                    style: TextStyle(
                                        color: themeController.selectCommandBarIndex.value == kPeriodList.indexOf(period)
                                            ? themeController.theme.inactiveColor
                                            : Common.commandTextColor))
                                .marginSymmetric(horizontal: 5),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                themeController.selectCommandBarIndex.value = kPeriodList.indexOf(period);
                                KPeriod fs = KPeriod(name: period.name, period: period.period, cusType: period.cusType, kpFlag: period.kpFlag);
                                if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                                  if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                                    return;
                                  }
                                  logic.kPeriodList[logic.selectedIndex.value] = fs;
                                  logic.viewIndexList[logic.selectedIndex.value] = 1;
                                } else {
                                  EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                                }
                              }
                            },
                          );
                        }),
                        // CommandBarButton(
                        //   label: Text('1', style: TextStyle(color: Common.commandTextColor)).marginSymmetric(horizontal: 5),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 6;
                        //       KPeriod fs = KPeriod(name: "1分钟", period: KTime.M_1, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('3', style: TextStyle(color: Common.commandTextColor)).marginSymmetric(horizontal: 5),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 7;
                        //       KPeriod fs = KPeriod(name: "3分钟", period: KTime.M_3, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('5', style: TextStyle(color: Common.commandTextColor)).marginSymmetric(horizontal: 5),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 8;
                        //       KPeriod fs = KPeriod(name: "5分钟", period: KTime.M_5, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('15', style: TextStyle(color: Common.commandTextColor)).marginSymmetric(horizontal: 5),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 10;
                        //       KPeriod fs = KPeriod(name: "15分钟", period: KTime.M_15, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('1h', style: TextStyle(color: Common.commandTextColor)).marginSymmetric(horizontal: 5),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 12;
                        //       KPeriod fs = KPeriod(name: "1小时", period: KTime.H_1, cusType: 1, kpFlag: KPFlag.Hour, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('日', style: TextStyle(color: Common.commandTextColor)).marginSymmetric(horizontal: 5),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 1;
                        //       KPeriod fs = KPeriod(name: "日", period: KTime.DAY, cusType: 1, kpFlag: KPFlag.Day, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('周', style: TextStyle(color: Common.commandTextColor)).marginSymmetric(horizontal: 5),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 2;
                        //       KPeriod fs = KPeriod(name: "周", period: 1, cusType: 2, kpFlag: KPFlag.Week, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('月', style: TextStyle(color: Common.commandTextColor)).marginSymmetric(horizontal: 5),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 3;
                        //       KPeriod fs = KPeriod(name: "月", period: 1, cusType: 2, kpFlag: KPFlag.Month, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('年', style: TextStyle(color: Common.commandTextColor)).marginSymmetric(horizontal: 5),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 4;
                        //       KPeriod fs = KPeriod(name: "年", period: 1, cusType: 2, kpFlag: KPFlag.Year, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        CommandBarButton(
                          label: Text('自',
                                  style: TextStyle(
                                      color: themeController.selectCommandBarIndex.value == kPeriodList.length
                                          ? themeController.theme.inactiveColor
                                          : Common.commandTextColor))
                              .marginSymmetric(horizontal: 5),
                          onPressed: () {
                            if (ButtonUtil.checkClick()) {
                              themeController.selectCommandBarIndex.value = kPeriodList.length;
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    List<KPeriod> tmp = [];
                                    tmp.addAll(kPeriodList);
                                    return CustomPeriodDialog().customPeriod(tmp, (value) async {
                                      kPeriodList.clear();
                                      kPeriodList.addAll(value);
                                      if (mounted) setState(() {});
                                      List tmp = [];
                                      for (var element in kPeriodList) {
                                        tmp.add(element.toJson());
                                      }
                                      String temp = jsonEncode(tmp);
                                      await SpUtils.set(SpKey.kPeriod, temp);
                                    });
                                  });
                            }
                          },
                        ),
                        if (themeController.selectIndex.value == 0)
                          CommandBarButton(
                            icon: FlyoutTarget(
                                controller: screenController,
                                child: Image.asset(
                                  "assets/images/icon_fenping@3x.png",
                                  width: Common.iconImageWidth,
                                ).marginSymmetric(horizontal: 5)),
                            onPressed: () {
                              screenController.showFlyout(builder: (context) {
                                return MenuFlyout(
                                    color: themeController.isDarkMode.value ? Common.dialogDarkBgColor : Common.dialogLightBgColor,
                                    items: [
                                      MenuFlyoutItem(
                                        text: Text(
                                          '一键分屏',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Common.commandTextColor),
                                        ).marginSymmetric(vertical: 5),
                                        onPressed: () {},
                                      ),
                                      MenuFlyoutItem(
                                        text: Image.asset(
                                          "assets/images/icon_2 screens@3x.png",
                                          width: Common.iconImageWidth * 1.5,
                                          height: Common.iconImageWidth * 2,
                                          fit: BoxFit.contain,
                                        ),
                                        onPressed: () async {
                                          themeController.multiScreen.value = 2;
                                          EventBusUtil.getInstance().fire(SplitScreen(2));
                                        },
                                      ),
                                      MenuFlyoutItem(
                                        text: Image.asset(
                                          "assets/images/icon_4 screens@3x.png",
                                          width: Common.iconImageWidth * 1.5,
                                          height: Common.iconImageWidth * 2,
                                          fit: BoxFit.contain,
                                        ),
                                        onPressed: () async {
                                          themeController.multiScreen.value = 4;
                                          EventBusUtil.getInstance().fire(SplitScreen(4));
                                        },
                                      ),
                                      MenuFlyoutItem(
                                        text: Image.asset(
                                          "assets/images/icon_6 screens@3x.png",
                                          width: Common.iconImageWidth * 1.5,
                                          height: Common.iconImageWidth * 2,
                                          fit: BoxFit.contain,
                                        ),
                                        onPressed: () async {
                                          themeController.multiScreen.value = 6;
                                          EventBusUtil.getInstance().fire(SplitScreen(6));
                                        },
                                      ),
                                      MenuFlyoutItem(
                                        text: Image.asset(
                                          "assets/images/icon_9 screens@3x.png",
                                          width: Common.iconImageWidth * 1.5,
                                          height: Common.iconImageWidth * 2,
                                          fit: BoxFit.contain,
                                        ).marginOnly(bottom: 10),
                                        onPressed: () async {
                                          themeController.multiScreen.value = 9;
                                          EventBusUtil.getInstance().fire(SplitScreen(9));
                                        },
                                      ),
                                    ]);
                              });
                            },
                          ),
                        if (themeController.selectIndex.value == 0)
                          CommandBarButton(
                            icon: Image.asset(
                              "assets/images/icon_save@3x.png",
                              width: Common.iconImageWidth,
                            ).marginSymmetric(horizontal: 5),
                            onPressed: () {
                              if (ButtonUtil.checkClick()) {
                                if (themeController.multiScreen.value != 1) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SavePageDialog().savePage(myPage, (e) async {
                                          if (themeController.selectIndex.value == 0) {
                                            List tmp = [];
                                            tmp.addAll(logic.viewIndexList);
                                            final MyPage thisPage = MyPage(
                                                name: e,
                                                multiScreen: themeController.multiScreen.value,
                                                selectedIndex: logic.selectedIndex.value,
                                                viewIndexList: List.from(logic.viewIndexList),
                                                showChartList: List.from(logic.showChartList),
                                                contractList: List.from(logic.selectedContractList),
                                                kPeriodList: List.from(logic.kPeriodList),
                                                selectedSector: List.from(logic.sectorList));
                                            myPage.add(thisPage);
                                            if (mounted) setState(() {});
                                            var jsonString = jsonEncode(myPage.map((e) => e.toJson()).toList());
                                            await SpUtils.set(SpKey.myPage, jsonString);
                                          }
                                        });
                                      });
                                }
                              }
                            },
                          ),
                        CommandBarButton(
                          icon: Image.asset(
                            "assets/images/icon_brush@3x.png",
                            width: Common.iconImageWidth,
                          ).marginSymmetric(horizontal: 5),
                          onPressed: () async {
                            if (ButtonUtil.checkClick()) {
                              // Get.dialog(DrawToolDialog().drawTool(() {}));
                              await rustDeskWinManager.newDrawTool("draw");
                            }
                          },
                        ),
                        // CommandBarButton(
                        //   label: Text('X',
                        //       style: TextStyle(
                        //           color: themeController.selectCommandBarIndex.value == 5
                        //               ? themeController.theme.exchangeTextColor
                        //               : themeController.theme.color)),
                        //   onPressed: () {
                        //     themeController.selectCommandBarIndex.value = 5;
                        //     KPFlag mKPFlag = KPFlag(name: "日", flag: KPFlag.Day, max: 365);
                        //     showDialog(
                        //         context: context,
                        //         builder: (BuildContext context) {
                        //           return PeriodDialog().showPeriodDialog(mKPFlag, "天");
                        //         });
                        //     // KPeriod fs = KPeriod(name: "年", period: KTime.MON, cusType: 1, kpFlag: KPFlag.Year, isDel: false);
                        //     // EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('1',
                        //       style: TextStyle(
                        //           color: themeController.selectCommandBarIndex.value == 6
                        //               ? themeController.theme.exchangeTextColor
                        //               : themeController.theme.color)),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 6;
                        //       KPeriod fs = KPeriod(name: "1分钟", period: KTime.M_1, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('3',
                        //       style: TextStyle(
                        //           color: themeController.selectCommandBarIndex.value == 7
                        //               ? themeController.theme.exchangeTextColor
                        //               : themeController.theme.color)),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 7;
                        //       KPeriod fs = KPeriod(name: "3分钟", period: KTime.M_3, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('5',
                        //       style: TextStyle(
                        //           color: themeController.selectCommandBarIndex.value == 8
                        //               ? themeController.theme.exchangeTextColor
                        //               : themeController.theme.color)),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 8;
                        //       KPeriod fs = KPeriod(name: "5分钟", period: KTime.M_5, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('10',
                        //       style: TextStyle(
                        //           color: themeController.selectCommandBarIndex.value == 9
                        //               ? themeController.theme.exchangeTextColor
                        //               : themeController.theme.color)),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 9;
                        //       KPeriod fs = KPeriod(name: "10分钟", period: KTime.M_10, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('15',
                        //       style: TextStyle(
                        //           color: themeController.selectCommandBarIndex.value == 10
                        //               ? themeController.theme.exchangeTextColor
                        //               : themeController.theme.color)),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 10;
                        //       KPeriod fs = KPeriod(name: "15分钟", period: KTime.M_15, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('30',
                        //       style: TextStyle(
                        //           color: themeController.selectCommandBarIndex.value == 11
                        //               ? themeController.theme.exchangeTextColor
                        //               : themeController.theme.color)),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 11;
                        //       KPeriod fs = KPeriod(name: "30分钟", period: KTime.M_30, cusType: 1, kpFlag: KPFlag.Minute, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('120',
                        //       style: TextStyle(
                        //           color: themeController.selectCommandBarIndex.value == 13
                        //               ? themeController.theme.exchangeTextColor
                        //               : themeController.theme.color)),
                        //   onPressed: () {
                        //     if (ButtonUtil.checkClick()) {
                        //       themeController.selectCommandBarIndex.value = 13;
                        //       KPeriod fs = KPeriod(name: "2小时", period: 2, cusType: 2, kpFlag: KPFlag.Hour, isDel: false);
                        //       if (logic.viewIndexList[logic.selectedIndex.value] == 0) {
                        //         if (logic.selectedContractList[logic.selectedIndex.value].code == null) {
                        //           return;
                        //         }
                        //         logic.kPeriodList[logic.selectedIndex.value] = fs;
                        //         logic.viewIndexList[logic.selectedIndex.value] = 1;
                        //       } else {
                        //         EventBusUtil.getInstance().fire(SwitchPeriod(fs));
                        //       }
                        //     }
                        //   },
                        // ),
                        // CommandBarButton(
                        //   label: Text('Y',
                        //       style: TextStyle(
                        //           color: themeController.selectCommandBarIndex.value == 14
                        //               ? themeController.theme.exchangeTextColor
                        //               : themeController.theme.color)),
                        //   onPressed: () {
                        //     themeController.selectCommandBarIndex.value = 14;
                        //     KPFlag mKPFlag = KPFlag(name: "分钟", flag: KPFlag.Minute, max: 1440);
                        //     showDialog(
                        //         context: context,
                        //         builder: (BuildContext context) {
                        //           return PeriodDialog().showPeriodDialog(mKPFlag, "分钟");
                        //         });
                        //   },
                        // ),
                      ],
                    )),
                    IconButton(
                      icon: Image.asset(
                        "assets/images/icon_edit@3x.png",
                        width: Common.iconImageWidth,
                      ).marginSymmetric(horizontal: 10),
                      onPressed: () async {
                        if (LoginServer.isLogin) {
                          await rustDeskWinManager.newDrawOrder("drawOrder");
                        } else {
                          InfoBarUtils.showInfoDialog("当前用户未登录，请登录后重试");
                        }
                      },
                    ),
                    Image.asset(
                      "assets/images/icon_network@3x.png",
                      width: Common.iconImageWidth,
                    ).marginSymmetric(horizontal: 10),
                    Image.asset(
                      "assets/images/icon_connect@3x.png",
                      width: Common.iconImageWidth,
                    ).marginSymmetric(horizontal: 10),
                  ],
                )),
            Expanded(
              child: Container(
                  color: themeController.theme.inactiveBackgroundColor,
                  child: Column(
                    children: [
                      Expanded(
                          child: themeController.multiScreen.value == 1
                              ? Quote(selectedIndex)
                              : MultiSplitViewTheme(
                                  data: MultiSplitViewThemeData(
                                      dividerThickness: 5,
                                      dividerPainter: DividerPainter(backgroundColor: themeController.theme.navigationPaneTheme.backgroundColor)),
                                  child: MultiSplitView(
                                    axis: Axis.vertical,
                                    controller: multiSplitViewController,
                                  ))),
                      Container(
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: themeController.theme.inactiveBackgroundColor,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey,
                              width: themeController.isDarkMode.value ? 0.8 : 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onHorizontalDragStart: (details) {
                                  _dragStartOffset = details.globalPosition.dx;
                                },
                                onHorizontalDragUpdate: (details) {
                                  _scrollController.jumpTo(_currentOffset + _dragStartOffset - details.globalPosition.dx);
                                },
                                onHorizontalDragEnd: (details) {
                                  _currentOffset = max(0, _currentOffset + _dragStartOffset - details.globalPosition.dx);
                                  _currentOffset =
                                      min(_scrollController.position.maxScrollExtent, _currentOffset + _dragStartOffset - details.globalPosition.dx);
                                },
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: themeController.selectIndex.value == 1 ? logic.mExchangeList.length : myPage.length + 1,
                                  controller: _scrollController,
                                  itemBuilder: (BuildContext context, int index) {
                                    if (themeController.selectIndex.value == 1) {
                                      return GestureDetector(
                                        onTap: () {
                                          logic.viewIndexList[0] = 0;
                                          themeController.selectIndex.value = 1;
                                          logic.switchExchange(index, 0);
                                          if (mounted) setState(() {});
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                          margin: const EdgeInsets.all(5),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(25),
                                            color: logic.mExchangeList[index] == logic.selectedExchange.value
                                                ? themeController.theme.bottomNavigationTheme.backgroundColor
                                                : Colors.transparent,
                                          ),
                                          child: Text(
                                            logic.mExchangeList[index].exchangeName ?? "",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: logic.mExchangeList[index] == logic.selectedExchange.value
                                                    ? themeController.theme.bottomNavigationTheme.selectedColor
                                                    : themeController.theme.bottomNavigationTheme.inactiveColor),
                                          ),
                                        ),
                                      );
                                    } else {
                                      if (index == 0) {
                                        return GestureDetector(
                                          onTap: () {
                                            selectedPage = null;
                                            myContract = true;
                                            themeController.multiScreen.value = 1;
                                            logic.selectedIndex.value = 0;
                                            logic.viewIndexList[0] = 0;
                                            if (mounted) setState(() {});
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                            margin: const EdgeInsets.all(5),
                                            alignment: Alignment.center,
                                            // color: myContract ? themeController.theme.selectionColor : Colors.transparent,
                                            child: Text(
                                              "我的合约",
                                              style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
                                            ),
                                          ),
                                        );
                                      } else {
                                        final flyoutTargetKey = GlobalKey();
                                        return FlyoutTarget(
                                          key: flyoutTargetKey,
                                          controller: pageController,
                                          child: GestureDetector(
                                            onTap: () {
                                              selectedPage = myPage[index - 1];
                                              myContract = false;
                                              themeController.multiScreen.value = selectedPage?.multiScreen ?? 1;
                                              if (selectedPage?.selectedIndex != null) logic.selectedIndex.value = selectedPage!.selectedIndex!;
                                              if (selectedPage?.viewIndexList != null) {
                                                logic.viewIndexList.clear();
                                                logic.viewIndexList.addAll(selectedPage!.viewIndexList!);
                                              }
                                              if (selectedPage?.showChartList != null) {
                                                logic.showChartList.clear();
                                                logic.showChartList.addAll(selectedPage!.showChartList!);
                                              }
                                              if (selectedPage?.contractList != null) {
                                                logic.selectedContractList.clear();
                                                logic.selectedContractList.addAll(selectedPage!.contractList!);
                                              }
                                              if (selectedPage?.kPeriodList != null) {
                                                logic.kPeriodList.clear();
                                                logic.kPeriodList.addAll(selectedPage!.kPeriodList!);
                                              }
                                              if (selectedPage?.selectedSector != null) {
                                                logic.sectorList.clear();
                                                logic.sectorList.addAll(selectedPage!.selectedSector!);
                                              }
                                              splitScreen(themeController.multiScreen.value);
                                            },
                                            onSecondaryTapDown: (d) {
                                              final targetContext = flyoutTargetKey.currentContext;
                                              if (targetContext == null) return;
                                              final box = targetContext.findRenderObject() as RenderBox;
                                              final position = box.localToGlobal(
                                                d.localPosition,
                                                ancestor: Navigator.of(context).context.findRenderObject(),
                                              );
                                              pageController.showFlyout(
                                                  barrierDismissible: true,
                                                  dismissOnPointerMoveAway: false,
                                                  dismissWithEsc: true,
                                                  position: position,
                                                  builder: (context) {
                                                    return MenuFlyout(items: [
                                                      MenuFlyoutItem(
                                                        text: const Text('删除'),
                                                        onPressed: () async {
                                                          myPage.removeAt(index - 1);
                                                          var jsonString = jsonEncode(myPage.map((e) => e.toJson()).toList());
                                                          await SpUtils.set(SpKey.myPage, jsonString);
                                                          if (mounted) setState(() {});
                                                        },
                                                      ),
                                                    ]);
                                                  });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                              margin: const EdgeInsets.all(5),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(25),
                                                color: myPage[index - 1] == selectedPage
                                                    ? themeController.theme.bottomNavigationTheme.backgroundColor
                                                    : Colors.transparent,
                                              ),
                                              child: Text(
                                                myPage[index - 1].name ?? "",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: myPage[index - 1] == selectedPage
                                                        ? themeController.theme.bottomNavigationTheme.selectedColor
                                                        : themeController.theme.bottomNavigationTheme.inactiveColor),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            Text(
                              _currentDateTime,
                              style: TextStyle(color: themeController.theme.bottomNavigationTheme.inactiveColor, fontSize: 16),
                            ).marginOnly(left: 10)
                          ],
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     logic.viewIndexList[widget.index] = 0;
                        //     logic.optionalIndexList[widget.index] = 0;
                        //   },
                        //   child: Container(
                        //     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        //     color: logic.optionalIndexList[widget.index] == 0 ? appTheme.exchangeBgColor : Colors.transparent,
                        //     child: Text(
                        //       '自选界面',
                        //       style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
                        //     ),
                        //   ),
                        // )
                        // ],
                        // )
                      ),
                    ],
                  ).marginAll(6)),
            ),
          ],
        ),
      );
    });
  }

  Widget boxItem(String tip, TextEditingController controller, FocusNode focusNode, {bool? showPic, bool? isPwd, bool? readOnly, Function? refresh}) {
    return Container(
        margin: const EdgeInsets.fromLTRB(50, 15, 50, 5),
        decoration: BoxDecoration(
          border: Border.all(
              color: focusNode.hasFocus
                  ? themeController.theme.sliderTheme.labelForegroundColor!
                  : themeController.theme.sliderTheme.labelBackgroundColor!,
              width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextBox(
          controller: controller,
          obscureText: isPwd ?? false,
          readOnly: readOnly ?? false,
          placeholder: tip,
          placeholderStyle: TextStyle(color: Common.commandTextColor),
          style: TextStyle(color: themeController.theme.acrylicBackgroundColor, fontSize: 15),
          focusNode: focusNode,
          highlightColor: Colors.transparent,
          unfocusedColor: Colors.transparent,
          decoration: WidgetStatePropertyAll(BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          )),
          suffix: showPic == true && mVCodeUrl != null
              ? GestureDetector(
                  onTap: getVCode,
                  child: Container(
                    color: Colors.white,
                    child: Image.network(
                      mVCodeUrl!,
                      width: 100.sp,
                      height: 28.sp,
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              // : isPwd == true
              //     ? GestureDetector(
              //         onTap: () {
              //           obscure = !obscure;
              //           refresh!();
              //         },
              //         child: Icon(
              //           obscure ? material.Icons.visibility_off_outlined : material.Icons.visibility_outlined,
              //           color: themeController.theme.acrylicBackgroundColor,
              //         ),
              //       ).marginOnly(right: 10)
              : null,
        ));
  }

  @override
  void onWindowClose() async {
    quit();
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
