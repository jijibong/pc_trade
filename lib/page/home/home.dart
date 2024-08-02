import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/broker/broker.dart';
import '../../model/user/user.dart';
import '../../server/login/login.dart';
import '../../server/socket/webSocket.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/event_bus/events.dart';
import '../../util/http/http.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
import '../../util/theme/theme.dart';
import '../quote/quote.dart';
import '../quote/quote_logic.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WindowListener {
  final QuoteLogic logic = Get.put(QuoteLogic());
  TextEditingController severController = TextEditingController(text: Common.brokerId);
  TextEditingController accountController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController vCodeController = TextEditingController();
  IpAddress ipAddress = IpAddress();
  List brokerList = [];
  bool savePwd = false;

  requestNetIp() async {
    await LoginServer.requestNetIp().then((value) {
      if (value != null) {
        ipAddress = value;
      }
    });
  }

  refreshBroker() async {
    await LoginServer.queryBroker(Common.brokerId).then((value) {
      if (value != null) {
        Config.URL = "${value.tradeUrl}:${value.tradePort}";
        HttpUtils();
      }
    });
  }

  initInfo() async {
    String? account = await SpUtils.getString(SpKey.account);
    String? password = await SpUtils.getString(SpKey.password);
    if (account != null) {
      accountController.text = account;
    }
    if (password != null) {
      savePwd = true;
      pwdController.text = password;
    }
  }

  tradeAccount() {
    if (!LoginServer.isLogin) {
      showLogin();
    }
  }

  showLogin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ContentDialog(
          style: const ContentDialogThemeData(
              decoration: ShapeDecoration(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)), padding: EdgeInsets.zero),
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
                        uncheckedDecoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.zero, border: Border.all(color: Colors.blue))),
                      ),
                      onChanged: (bool? value) {
                        savePwd = value ?? false;
                        state(() {});
                      },
                    ),
                    const Text("保存密码", style: TextStyle(color: Colors.black))
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15, top: 60),
                  child: FilledButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.yellow),
                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 80))),
                    onPressed: login,
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

  login() async {
    if (severController.text.isEmpty) {
      InfoBarUtils.showWarningBar("请输入服务商代码");
    } else if (accountController.text.isEmpty || pwdController.text.isEmpty) {
      InfoBarUtils.showWarningBar("账号或密码不能为空");
    } else {
      await LoginServer.login(accountController.text, pwdController.text, Common.brokerId, "", ipAddress.cip ?? "").then((value) {
        if (value == true) {
          SpUtils.set(SpKey.account, accountController.text);
          if (savePwd) {
            SpUtils.set(SpKey.password, pwdController.text);
          } else {
            SpUtils.remove(SpKey.password);
          }
          EventBusUtil.getInstance().fire(LoginEvent(true));
          Get.back();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    UserUtils.appContext = context;
    WebSocketServer().initSocket();
    requestNetIp();
    refreshBroker();
    initInfo();
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
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
                  )
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
              onChanged: (v) {
                if (v) {
                  appTheme.mode = ThemeMode.light;
                } else {
                  appTheme.mode = ThemeMode.dark;
                }
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
                          logic.viewIndex.value = 0;
                        },
                      ),
                      CommandBarButton(
                        icon: Icon(FluentIcons.home, color: appTheme.exchangeTextColor),
                        label: Text('首页', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: Icon(FluentIcons.refresh, color: appTheme.exchangeTextColor),
                        label: Text('刷新', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: Icon(FluentIcons.scale_volume, color: appTheme.exchangeTextColor),
                        label: Text('放大', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: Icon(FluentIcons.scale_up, color: appTheme.exchangeTextColor),
                        label: Text('缩小', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: Icon(FluentIcons.edit_create, color: appTheme.exchangeTextColor),
                        label: Text('画图工具', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: Icon(FluentIcons.tablet_mode, color: appTheme.exchangeTextColor),
                        label: Text('画线下单', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        icon: Icon(FluentIcons.line_chart, color: appTheme.exchangeTextColor),
                        label: Text('分时图', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('日', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('周', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('月', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('年', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('X', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('1', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('3', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('5', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('10', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('15', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('30', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('60', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('120', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      CommandBarButton(
                        label: Text('Y', style: TextStyle(color: appTheme.exchangeTextColor)),
                        onPressed: () {},
                      ),
                      // const CommandBarSeparator(),
                    ],
                  )),
                  // Image.asset("assets/images/quote_st.png"),
                  // Image.asset("assets/images/user_st.png")
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
                onPressed: () {
                  Navigator.pop(_);
                  windowManager.destroy();
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
