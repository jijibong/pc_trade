import 'dart:convert';
import 'dart:math' as math;

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../main.dart';
import '../../model/pl/pl.dart';
import '../../model/pl/pl_close_type.dart';
import '../../model/quote/contract.dart';
import '../../model/trade/hold_order.dart';
import '../../model/user/user.dart';
import '../../server/pl/pl.dart';
import '../../util/http/http.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';

/// multi-tab desktop remote screen
class PlPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const PlPage({super.key, required this.params});

  @override
  State<PlPage> createState() => _PlPageState();
}

class _PlPageState extends State<PlPage> with MultiWindowListener {
  int mSelPosition = -1;
  int maxQty = 1;
  List<PLRecord> mPlRecordList = [];
  PLRecord? mPlRecord;
  HoldOrder hold = HoldOrder();
  Contract mContract = Contract();
  String setplLast = "---";
  String tips = "(温馨提示：右键添加删除止盈止损)";
  final contextController = FlyoutController();
  final contextAttachKey = GlobalKey();
  late AppTheme appTheme;

  int windowId() {
    return widget.params["windowId"];
  }

  initUrl() async {
    String? baseUrl = await SpUtils.getString(SpKey.baseUrl);
    String? userInfo = await SpUtils.getString(SpKey.currentUser);
    if (baseUrl != null && userInfo != null) {
      Config.URL = baseUrl;
      UserUtils.currentUser = User.fromJson(jsonDecode(userInfo));
      HttpUtils();
      initData();
    } else {
      InfoBarUtils.showErrorBar("获取交易地址失败，请重新登录！");
    }
  }

  initData({String? holdString}) async {
    holdString ??= widget.params["hold"];
    if (holdString != null) {
      hold = HoldOrder.fromJson(jsonDecode(holdString));
      // Contract? contract = MarketUtils.getVariety(hold.exCode, hold.code, hold.comType);
      // if (contract == null) {
      //   InfoBarUtils.showWarningBar("当前合约已过期");
      //   return;
      // }
      // mContract = contract;
      // subscriptionQuote(mContract);
      // setplLast = Utils.dealPointByOld(mContract.lastPrice, hold.FutureTickSize).toString();
      queryPLRecord();
      changeText();
      if (mounted) setState(() {});
    } else {
      InfoBarUtils.showWarningBar("合约不存在");
    }
  }

  /// 查询止盈止损
  void queryPLRecord() async {
    await PLServer.getHisPLRecord(hold.exCode, hold.subComCode, hold.subConCode, hold.comType, hold.orderSide).then((value) {
      if (value != null && value.isNotEmpty) {
        // logger.i(value);
        mPlRecordList.clear();
        mPlRecordList.addAll(value);
        if (mounted) setState(() {});
      } else {
        mPlRecordList.add(PLRecord(RealQty: 1));
        if (mounted) setState(() {});
      }
    });
  }

  /// 设置止盈止损
  void requestSetPL() async {
    // int positionType = PositionType.getType(setplPostypeTxt.trim());
    int positionType = 0;
    int period = await SpUtils.getInt(SpKey.pLPeriod) ?? PLCloseType.Today;
    int closetype = period == 0 ? PLCloseType.Today : period;
    await PLServer.setPL(hold.exCode, hold.subComCode, hold.comType, hold.subConCode, hold.orderSide, hold.PLQuantity, closetype, positionType,
            hold.ProfitPriceTicks, hold.LossPriceTicks, hold.FloatLoss)
        .then((value) {
      if (value != null) {
        mPlRecordList.clear();
        mPlRecordList.addAll(value);
        if (mounted) setState(() {});
        InfoBarUtils.showSuccessBar("止盈止损设置成功");
      } else {
        queryPLRecord();
      }
    });
  }

  ///修改止盈止损
  void modifyPLRecord() async {
    int recordId = mPlRecordList[mSelPosition].Id ?? 0;
    int period = await SpUtils.getInt(SpKey.pLPeriod) ?? PLCloseType.Today;
    int closetype = period == 0 ? PLCloseType.Today : period;
    await PLServer.modifyPL(hold.exCode, hold.subComCode, hold.comType, hold.subConCode, hold.orderSide, hold.PLQuantity, closetype, recordId,
            hold.ProfitPriceTicks, hold.LossPriceTicks, hold.FloatLoss)
        .then((value) {
      if (value != null) {
        mPlRecordList.clear();
        mPlRecordList.addAll(value);
        mSelPosition = -1;
        changeText();
        if (mounted) setState(() {});
        InfoBarUtils.showSuccessBar("止盈止损修改成功");
      } else {
        queryPLRecord();
      }
    });
  }

  ///打开关闭止盈止损记录
  void enablePLRecord(PLRecord pLRecord, bool checked) async {
    await PLServer.enablePLRecord(hold.exCode, hold.subComCode, hold.comType, hold.subConCode, hold.orderSide, pLRecord.Id, checked).then((value) {
      if (value != null) {
        mPlRecordList.clear();
        mPlRecordList.addAll(value);
        if (mounted) setState(() {});
      } else {
        queryPLRecord();
      }
    });
  }

  ///删除止盈止损
  void delPLRecord(int? recordId) async {
    await PLServer.delPLRecord(hold.exCode, hold.subComCode, hold.subConCode, hold.comType, hold.orderSide, recordId).then((value) {
      if (value != null) {
        mPlRecordList.clear();
        mPlRecordList.addAll(value);
        if (mounted) setState(() {});
        InfoBarUtils.showSuccessBar("删除成功");
      } else {
        queryPLRecord();
      }
    });
  }

  /// 改变文字
  void changeText() {
    // if (mSelPosition == -1) {
    //   textEditingController3.text = "1";
    //   if (hold.TPosition != null && hold.TPosition != 0) {
    //     setplPostypeTxt = "今仓";
    //     setplTdNum = "${hold.TPosition ?? ''}";
    //     setplYdNum = "${hold.YPosition ?? ''}";
    //     maxQty = hold.TPosition!;
    //   } else if (hold.YPosition != null && hold.YPosition != 0) {
    //     setplPostypeTxt = "昨仓";
    //     setplTdNum = "${hold.TPosition ?? ''}";
    //     setplYdNum = "${hold.YPosition ?? ''}";
    //     maxQty = hold.YPosition!;
    //   } else {
    //     setplPostypeTxt = "不分";
    //     setplYdText = "持仓";
    //     setplTdNum = "---";
    //     setplYdNum = "${hold.quantity ?? ''}";
    //     maxQty = hold.quantity ?? 0;
    //   }
    // } else {
    //   PLRecord plRecord = mPlRecordList[mSelPosition];
    //   if (plRecord.FloatLoss != null && plRecord.FloatLoss! > 0) {
    //     setplStopTxt = "追踪止损";
    //     textEditingController2.text = plRecord.FloatLoss.toString();
    //   } else {
    //     setplStopTxt = "止损价";
    //     textEditingController2.text = plRecord.StopLoss.toString();
    //   }
    //   textEditingController1.text = plRecord.StopWin.toString();
    //   textEditingController3.text = plRecord.RealQty.toString();
    //   if (plRecord.PositionType == PositionType.POSITION_TODAY) {
    //     setplPostypeTxt = "今仓";
    //     setplYdText = "昨仓";
    //     setplTdNum = "${hold.TPosition ?? ''}";
    //     setplYdNum = "${hold.YPosition ?? ''}";
    //     maxQty = hold.TPosition ?? 0;
    //   } else if (plRecord.PositionType == PositionType.POSITION_YESTODAY) {
    //     setplPostypeTxt = "昨仓";
    //     setplYdText = "昨仓";
    //     setplTdNum = "${hold.TPosition ?? ''}";
    //     setplYdNum = "${hold.YPosition ?? ''}";
    //     maxQty = hold.YPosition ?? 0;
    //   } else {
    //     setplPostypeTxt = "不分";
    //     setplYdText = "持仓";
    //     setplTdNum = "---";
    //     setplYdNum = "${hold.quantity ?? ''}";
    //     maxQty = hold.quantity ?? 0;
    //   }
    // }
    // if (mounted) setState(() {});
  }

  String? _format(num? value) {
    if (value == null) return null;
    if (value is int) {
      return value.toString();
    }
    final mul = math.pow(10, 2);
    return NumberFormat().format((value * mul).roundToDouble() / mul);
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
    notMainWindowClose(WindowController windowController) async {
      await windowController.hide();
      await rustDeskWinManager.call(WindowType.Main, kWindowEventHide, {"id": kWindowId!});
    }

    // hide window on close
    final controller = WindowController.fromWindowId(kWindowId!);
    await notMainWindowClose(controller);
    super.onWindowClose();
  }

  @override
  void initState() {
    super.initState();
    DesktopMultiWindow.addListener(this);
    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      // logger.i("fromWindowId:$fromWindowId;method:${call.method};arguments:${call.arguments}");
      if (call.method == kWindowEventNewPL) {
        windowOnTop(windowId());
        Map<String, dynamic> map = jsonDecode(call.arguments);
        String holdString = map["hold"];
        initData(holdString: holdString);
      }
    });
    initUrl();
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
                    "止盈止损设置",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ).marginOnly(left: 2))
                ]).marginOnly(
                  left: 2,
                  right: 2,
                ),
              ),
              actions: IconButton(
                  icon: const Icon(
                    FluentIcons.chrome_close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    WindowController.fromWindowId(windowId()).close();
                  })),
          content: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(text: "为(${widget.params["contractId"] ?? ""}${widget.params["contractId"] ?? ""}  )设置止盈止损"),
                      TextSpan(text: tips, style: TextStyle(color: Colors.red))
                    ]))
                  ],
                ),
                Expanded(
                  child: GestureDetector(
                    child: FlyoutTarget(
                      key: contextAttachKey,
                      controller: contextController,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: mPlRecordList.length + 1,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Row(
                                children: [
                                  Expanded(flex: 7, child: tableItem("设置时间")),
                                  Expanded(flex: 3, child: tableItem("数量")),
                                  Expanded(flex: 4, child: tableItem("止盈价格")),
                                  Expanded(flex: 10, child: tableItem("止损价格")),
                                  Expanded(flex: 10, child: tableItem("有效期")),
                                ],
                              );
                            } else {
                              return GestureDetector(
                                child: Container(
                                  color: mPlRecordList[index - 1].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
                                  child: IntrinsicHeight(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(flex: 7, child: tableItem(mPlRecordList[index - 1].CreateAt)),
                                      Expanded(flex: 3, child: numItem(mPlRecordList[index - 1].RealQty ?? 0)),
                                      Expanded(flex: 4, child: priceItem(mPlRecordList[index - 1].StopWin ?? 0.0)),
                                      Expanded(
                                          flex: 10, child: typeItem(mPlRecordList[index - 1].StopLoss ?? 0.0, mPlRecordList[index - 1].State ?? 0)),
                                      Expanded(flex: 10, child: validItem(mPlRecordList[index - 1].CloseType ?? 0, mPlRecordList[index - 1].State)),
                                    ],
                                  )),
                                ),
                                onTap: () {
                                  if (mPlRecordList[index - 1].selected == true) return;
                                  for (var element in mPlRecordList) {
                                    element.selected = false;
                                  }
                                  mPlRecordList[index - 1].selected = true;
                                  mPlRecord = mPlRecordList[index - 1];
                                  if (mounted) setState(() {});
                                },
                                onSecondaryTapUp: (d) {
                                  final targetContext = contextAttachKey.currentContext;
                                  if (targetContext == null) return;
                                  final box = targetContext.findRenderObject() as RenderBox;
                                  final position = box.localToGlobal(
                                    d.localPosition,
                                    ancestor: Navigator.of(context).context.findRenderObject(),
                                  );
                                  contextController.showFlyout(
                                    barrierColor: Colors.black.withOpacity(0.1),
                                    position: position,
                                    builder: (context) {
                                      return MenuFlyout(items: [
                                        MenuFlyoutItem(
                                          text: const Text('添加'),
                                          onPressed: () {
                                            mPlRecordList.add(PLRecord());
                                            if (mounted) setState(() {});
                                          },
                                        ),
                                        MenuFlyoutItem(
                                            text: const Text('删除'),
                                            onPressed: () {
                                              mPlRecordList.removeAt(index - 1);
                                            }),
                                      ]);
                                    },
                                  );
                                },
                              );
                            }
                          }),
                    ),
                    onSecondaryTapUp: (d) {
                      final targetContext = contextAttachKey.currentContext;
                      if (targetContext == null) return;
                      final box = targetContext.findRenderObject() as RenderBox;
                      final position = box.localToGlobal(
                        d.localPosition,
                        ancestor: Navigator.of(context).context.findRenderObject(),
                      );
                      contextController.showFlyout(
                        barrierColor: Colors.black.withOpacity(0.1),
                        position: position,
                        builder: (context) {
                          return MenuFlyout(items: [
                            MenuFlyoutItem(
                              text: const Text('添加'),
                              onPressed: () {
                                mPlRecordList.add(PLRecord());
                                if (mounted) setState(() {});
                              },
                            ),
                            MenuFlyoutItem(
                                text: const Text('删除'),
                                onPressed: () {
                                  Flyout.of(context).close();
                                }),
                          ]);
                        },
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Text("修改完成后，请点击保存", style: TextStyle(color: Colors.red)),
                    Expanded(child: Container()),
                    Button(
                        style: ButtonStyle(
                            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            backgroundColor: WidgetStatePropertyAll(Colors.yellow),
                            shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                        child: const Text("保存"),
                        onPressed: () {}),
                    const SizedBox(width: 10),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            backgroundColor: WidgetStatePropertyAll(Colors.grey),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        child: Text(
                          "取消",
                          style: TextStyle(color: Common.exchangeTextColor),
                        ),
                        onPressed: () async {
                          WindowController.fromWindowId(windowId()).hide();
                        }),
                    const SizedBox(width: 10),
                    Button(
                        style: ButtonStyle(
                            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            backgroundColor: WidgetStatePropertyAll(Colors.yellow),
                            shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                        child: const Text("全部删除"),
                        onPressed: () {}),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget tableItem(String? text) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Common.exchangeBgColor)),
      padding: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: Text(
        text ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget numItem(int num) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Common.exchangeBgColor)),
      padding: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: numberSelect(num, 1),
    );
  }

  Widget priceItem(double num) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Common.exchangeBgColor)),
      padding: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: numberSelect(num, 0.01),
    );
  }

  Widget typeItem(double num, int state) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Common.exchangeBgColor)),
      padding: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: StatefulBuilder(builder: (context, setter) {
        return Row(
          children: [
            const SizedBox(
              width: 3,
            ),
            RadioButton(
                checked: state == 0,
                content: const Text("止损价"),
                onChanged: (e) {
                  state = 0;
                  setter(() {});
                }),
            const SizedBox(
              width: 3,
            ),
            RadioButton(
                checked: state == 1,
                content: const Text("点差价"),
                onChanged: (e) {
                  state = 1;
                  setter(() {});
                }),
            numberSelect(num, 0.01),
          ],
        );
      }),
    );
  }

  Widget validItem(int type, int? state) {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Common.exchangeBgColor)),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: StatefulBuilder(builder: (context, setter) {
          return Row(
            children: [
              const SizedBox(
                width: 3,
              ),
              RadioButton(
                  checked: type == PLCloseType.Today,
                  content: const Text("当日有效"),
                  onChanged: (e) {
                    type = PLCloseType.Today;
                    setter(() {});
                  }),
              const SizedBox(
                width: 3,
              ),
              RadioButton(
                  checked: type == PLCloseType.Permanent,
                  content: const Text("永久有效"),
                  onChanged: (e) {
                    type = PLCloseType.Permanent;
                    setter(() {});
                  }),
              const SizedBox(
                width: 5,
              ),
              if (state != null)
                ToggleSwitch(
                  checked: state == 1,
                  onChanged: (bool value) {
                    if (value) {
                      state = 1;
                    } else {
                      state = 0;
                    }
                    setter(() {});
                  },
                ),
            ],
          );
        }));
  }

  Widget numberSelect(num value, num smallChange) {
    TextEditingController controller = TextEditingController(text: "   $value");
    return StatefulBuilder(builder: (context, setter) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 28,
            child: TextBox(
              controller: controller,
              // padding: EdgeInsets.zero,
              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.zero, border: Border.all(color: Colors.transparent)),
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(FluentIcons.chevron_up, size: 8),
                iconButtonMode: IconButtonMode.small,
                onPressed: () {
                  value = value + smallChange;
                  controller.text = _format(value) ?? '';
                  setter(() {});
                },
              ),
              IconButton(
                icon: const Icon(FluentIcons.chevron_down, size: 8),
                iconButtonMode: IconButtonMode.small,
                onPressed: () {
                  value = math.max(0, value - smallChange);
                  controller.text = _format(value) ?? '';
                  setter(() {});
                },
              ),
            ],
          )
        ],
      );
    });
  }
}
