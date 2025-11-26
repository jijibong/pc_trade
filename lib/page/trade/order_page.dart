import 'dart:convert';
import 'dart:ui';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart' hide Condition;
import '../../config/common.dart';
import '../../main.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/order_type.dart';
import '../../model/quote/position_effect_type.dart';
import '../../model/quote/side_type.dart';
import '../../model/quote/time_in_force_type.dart';
import '../../server/trade/deal.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
import '../../util/widget/number_box.dart';

class OrderPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const OrderPage({super.key, required this.params});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with MultiWindowListener {
  int selectedIndex = 0;
  bool autoClose = false;
  bool dir = true;
  bool toggle = false;
  bool addCondition = true;
  int num = 1;
  int lossType = 1;
  int winType = 1;
  double price = 0;
  double lossTriggerPrice = 0;
  double lossSpreadPrice = 0;
  double lossPrice = 0;
  double winTriggerPrice = 0;
  double winSpreadPrice = 0;
  double winPrice = 0;
  double lossMargin = 0;
  double winMargin = 0;
  Contract? contract;
  List openTypeList = ["开仓", "平仓", "反手"]; //内盘+平今仓
  String openType = "开仓";
  List winLossTypeList = ["限价止损+限价止盈", "动态追踪", "限价止损", "限价止盈", "指定止损/止盈触发价"]; //内盘+平今仓
  String winLossType = "限价止损+限价止盈";
  List conditionTypeList = ["大于等于", "小于等于"];
  String conditionType = "大于等于";
  List orderTypeList = ["买入", "卖出"];
  String orderType = "买入";
  // List addConditionTypeList = ["大于等于", "小于等于"];
  // String addConditionType = "大于等于";
  List timeLimitList = ["永久有效", "当日有效"];
  String timeLimit = "永久有效";
  int conditionNum = 1;
  // int addConditionNum = 1;
  int orderNum = 1;
  Size size = PlatformDispatcher.instance.implicitView!.physicalSize / PlatformDispatcher.instance.implicitView!.devicePixelRatio;

  int windowId() {
    return widget.params["windowId"];
  }

  initData() async {
    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      if (call.method == kWindowEventAdvancedOrder) {
        windowOnTop(windowId());
      }
    });

    if (widget.params['hold'] != null) {
      contract = Contract.fromJson(jsonDecode(widget.params['hold']));
      if (mounted) setState(() {});
    }

    String? string = await SpUtils.getString(SpKey.screenSize);
    if (string != null) {
      Map map = jsonDecode(string);
      size = Size(map["width"], map["height"]);
    }
    if (isWindows11) {
      size = Size(size.width * 1.5, size.height * 2);
    }
  }

  void startDragging(bool isMainWindow) {
    WindowController.fromWindowId(kWindowId!).startDragging();
  }

  void setMovable(bool isMainWindow, bool movable) {
    WindowController.fromWindowId(kWindowId!).setMovable(movable);
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
    initData();
    super.initState();
  }

  @override
  void dispose() {
    DesktopMultiWindow.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Common.lightBgColor,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () async {
                        await WindowController.fromWindowId(kWindowId!).hide();
                      },
                      icon: const Icon(FluentIcons.cancel))
                ],
              ).paddingOnly(top: 15)),
          Text(
            "高级下单",
            style: TextStyle(color: Common.contentDarkBgColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(selectedIndex == 0 ? Common.tradeTypeButtonColor : Colors.transparent),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  onPressed: () async {
                    WindowController.fromWindowId(kWindowId!)
                      ..setFrame(const Offset(0, 0) & Size(size.width * 0.45, size.height * 0.56))
                      ..center()
                      ..show();
                    selectedIndex = 0;
                    if (mounted) setState(() {});
                  },
                  child: Text(
                    "止损开仓",
                    style: TextStyle(
                        fontSize: 14, color: selectedIndex == 0 ? Common.contentDarkBgColor : Common.commandTextColor, fontWeight: FontWeight.w800),
                  )).marginOnly(right: 10),
              Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(selectedIndex == 1 ? Common.tradeTypeButtonColor : Colors.transparent),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  onPressed: () async {
                    WindowController.fromWindowId(kWindowId!)
                      ..setFrame(const Offset(0, 0) & Size(size.width * 0.33, size.height * 0.61))
                      ..center()
                      ..show();
                    selectedIndex = 1;
                    if (mounted) setState(() {});
                  },
                  child: Text(
                    "条件单",
                    style: TextStyle(
                        fontSize: 14, color: selectedIndex == 1 ? Common.contentDarkBgColor : Common.commandTextColor, fontWeight: FontWeight.w800),
                  )),
            ],
          ),
          Container(
            decoration: BoxDecoration(
                color: Common.contentLightBgColor,
                border: Border.all(color: Common.dialogContentBorderBgColor),
                borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.only(top: 10, bottom: 15),
            padding: const EdgeInsets.all(24),
            child: selectedIndex == 0
                ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      titleWidget("合约"),
                                      Text(
                                        contract?.name ?? "--",
                                        style: TextStyle(color: Common.contentDarkBgColor),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      titleWidget("方向"),
                                      RadioButton(
                                          checked: dir,
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
                                              dir = checked;
                                              setState(() {});
                                            }
                                          }),
                                      const Text("  买入"),
                                      RadioButton(
                                          checked: !dir,
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
                                              dir = !checked;
                                              if (mounted) setState(() {});
                                            }
                                          }).marginOnly(left: 30),
                                      const Text("  卖出")
                                    ],
                                  ).marginSymmetric(vertical: 16),
                                  Row(
                                    children: [
                                      titleWidget("手数"),
                                      SizedBox(
                                        height: 36,
                                        width: 100,
                                        child: NumberBox(
                                          decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                          highlightColor: Colors.transparent,
                                          unfocusedColor: Colors.transparent,
                                          value: num,
                                          min: 0,
                                          clearButton: false,
                                          onChanged: (v) => setState(() => num = v ?? 1),
                                        ),
                                      ),
                                      unitText("   ≤${dir ? contract?.canOpenBuy : contract?.canOpenSale ?? "0"}手").marginOnly(left: 5),
                                    ],
                                  ).marginOnly(bottom: 10),
                                  Row(
                                    children: [
                                      titleWidget("价格"),
                                      Container(
                                        height: 36,
                                        width: 100,
                                        margin: const EdgeInsets.only(right: 10),
                                        child: NumberBox(
                                          decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                          highlightColor: Colors.transparent,
                                          unfocusedColor: Colors.transparent,
                                          value: price,
                                          min: 0,
                                          clearButton: false,
                                          onChanged: (v) => setState(() => price = v ?? 1),
                                        ),
                                      ),
                                      ToggleSwitch(
                                        checked: toggle,
                                        onChanged: (v) => setState(() => toggle = v),
                                      )
                                    ],
                                  ),
                                  Text(
                                    "开启状态下输入价格，关闭状态下以市价开仓",
                                    style: TextStyle(color: Common.commandTextColor, fontSize: 12),
                                  ).marginOnly(left: 60, top: 5),
                                ],
                              )),
                          Expanded(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                                  decoration: BoxDecoration(color: Common.tradeCloseButtonColor, borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "下单",
                                        style: TextStyle(color: Common.contentDarkBgColor, fontSize: 20, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        dir ? "(买入开仓)" : "(卖出开仓)",
                                        style: TextStyle(color: Common.contentDarkBgColor),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  await DealServer.addOrder(
                                      contract?.exCode ?? '',
                                      contract?.subComCode ?? '',
                                      contract?.subConCode ?? '',
                                      contract?.comType ?? 0,
                                      Order_Type.ORDER_TYPE_MARKET,
                                      TimeInForceType.ORDER_TIMEINFORCE_GFD,
                                      "",
                                      dir ? SideType.SIDE_BUY : SideType.SIDE_SELL,
                                      toggle ? price : 0,
                                      0,
                                      num,
                                      PositionEffectType.PositionEffect_OPEN,
                                      "");
                                  if (autoClose) {
                                    WindowController.fromWindowId(kWindowId!).hide();
                                  }
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    checked: autoClose,
                                    style: const CheckboxThemeData(
                                      margin: EdgeInsets.only(right: 10),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onChanged: (bool? value) {
                                      autoClose = value ?? false;
                                      setState(() {});
                                    },
                                  ),
                                  Text("下单后关闭", style: TextStyle(color: Common.contentDarkBgColor))
                                ],
                              ).marginOnly(top: 8)
                            ],
                          )),
                        ],
                      ),
                      Container(
                        color: Common.dialogContentBorderBgColor,
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Row(
                            children: [
                              titleWidget("止损"),
                              RadioButton(
                                  checked: lossType == 1,
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
                                      lossType = 1;
                                      setState(() {});
                                    }
                                  }),
                              _titleWidget("止损触发价"),
                              SizedBox(
                                height: 36,
                                width: 100,
                                child: NumberBox(
                                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  value: lossTriggerPrice,
                                  min: 0,
                                  clearButton: false,
                                  onChanged: (v) => setState(() => lossTriggerPrice = v ?? 0),
                                ),
                              ),
                              unitText("点").marginOnly(left: 5),
                            ],
                          )),
                          Expanded(
                              child: Row(
                            children: [
                              titleWidget("止盈"),
                              RadioButton(
                                  checked: winType == 1,
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
                                      winType = 1;
                                      setState(() {});
                                    }
                                  }),
                              _titleWidget("止盈触发价"),
                              SizedBox(
                                height: 36,
                                width: 100,
                                child: NumberBox(
                                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  value: winTriggerPrice,
                                  min: 0,
                                  clearButton: false,
                                  onChanged: (v) => setState(() => winTriggerPrice = v ?? 1),
                                ),
                              ),
                              unitText("点").marginOnly(left: 5),
                            ],
                          )),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Row(
                            children: [
                              RadioButton(
                                  checked: lossType == 2,
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
                                      lossType = 2;
                                      setState(() {});
                                    }
                                  }).marginOnly(left: 60),
                              _titleWidget("止损价差"),
                              SizedBox(
                                height: 36,
                                width: 100,
                                child: NumberBox(
                                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  value: lossSpreadPrice,
                                  min: 0,
                                  clearButton: false,
                                  onChanged: (v) => setState(() => lossSpreadPrice = v ?? 0),
                                ),
                              ),
                              unitText("最小变动价").marginOnly(left: 5),
                            ],
                          )),
                          Expanded(
                              child: Row(
                            children: [
                              RadioButton(
                                  checked: winType == 2,
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
                                      winType = 2;
                                      setState(() {});
                                    }
                                  }).marginOnly(left: 60),
                              _titleWidget("止盈价差"),
                              SizedBox(
                                height: 36,
                                width: 100,
                                child: NumberBox(
                                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  value: winSpreadPrice,
                                  min: 0,
                                  clearButton: false,
                                  onChanged: (v) => setState(() => winSpreadPrice = v ?? 1),
                                ),
                              ),
                              unitText("最小变动价").marginOnly(left: 5),
                            ],
                          )),
                        ],
                      ).marginSymmetric(vertical: 10),
                      Row(
                        children: [
                          Expanded(
                              child: Row(
                            children: [
                              RadioButton(
                                  checked: lossType == 3,
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
                                      lossType = 3;
                                      setState(() {});
                                    }
                                  }).marginOnly(left: 60),
                              _titleWidget("止损金额"),
                              SizedBox(
                                height: 36,
                                width: 100,
                                child: NumberBox(
                                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  value: lossPrice,
                                  min: 0,
                                  clearButton: false,
                                  onChanged: (v) => setState(() => lossPrice = v ?? 0),
                                ),
                              ),
                              unitText("元").marginOnly(left: 5),
                            ],
                          )),
                          Expanded(
                              child: Row(
                            children: [
                              RadioButton(
                                  checked: winType == 3,
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
                                      winType = 3;
                                      setState(() {});
                                    }
                                  }).marginOnly(left: 60),
                              _titleWidget("止盈金额"),
                              SizedBox(
                                height: 36,
                                width: 100,
                                child: NumberBox(
                                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  value: winPrice,
                                  min: 0,
                                  clearButton: false,
                                  onChanged: (v) => setState(() => winPrice = v ?? 1),
                                ),
                              ),
                              unitText("元").marginOnly(left: 5),
                            ],
                          )),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          titleWidget("合约"),
                          Text(
                            contract?.name ?? "--",
                            style: TextStyle(color: Common.contentDarkBgColor),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          titleWidget("条件"),
                          textWidget("当前新价"),
                          Container(
                            width: 100,
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ComboBox<String>(
                              value: conditionType,
                              isExpanded: true,
                              items: conditionTypeList.map((e) {
                                return ComboBoxItem<String>(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => conditionType = v!),
                            ),
                          ),
                          SizedBox(
                            height: 36,
                            width: 100,
                            child: NumberBox(
                              decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                              highlightColor: Colors.transparent,
                              unfocusedColor: Colors.transparent,
                              value: conditionNum,
                              min: 1,
                              clearButton: false,
                              onChanged: (v) => setState(() => conditionNum = v ?? 1),
                            ),
                          ),
                          Text(
                            "   手",
                            style: TextStyle(color: Common.commandTextColor),
                          )
                        ],
                      ).marginSymmetric(vertical: 10),
                      Row(
                        children: [
                          titleWidget("订单"),
                          SizedBox(
                            width: 100,
                            height: 36,
                            child: ComboBox<String>(
                              value: orderType,
                              isExpanded: true,
                              items: orderTypeList.map((e) {
                                return ComboBoxItem<String>(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => orderType = v!),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ComboBox<String>(
                              value: openType,
                              isExpanded: true,
                              items: openTypeList.map((e) {
                                return ComboBoxItem<String>(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => openType = v!),
                            ),
                          ),
                          SizedBox(
                            height: 36,
                            width: 100,
                            child: NumberBox(
                              decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                              highlightColor: Colors.transparent,
                              unfocusedColor: Colors.transparent,
                              value: orderNum,
                              min: 1,
                              clearButton: false,
                              onChanged: (v) => setState(() => orderNum = v ?? 1),
                            ),
                          ),
                          Text(
                            "   手",
                            style: TextStyle(color: Common.commandTextColor),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          titleWidget("时效"),
                          SizedBox(
                            width: 100,
                            height: 36,
                            child: ComboBox<String>(
                              value: timeLimit,
                              isExpanded: true,
                              items: timeLimitList.map((e) {
                                return ComboBoxItem<String>(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => timeLimit = v!),
                            ),
                          ),
                        ],
                      ).marginSymmetric(vertical: 10),
                      // Container(
                      //   margin: const EdgeInsets.only(left: 60),
                      //   padding: const EdgeInsets.all(10),
                      //   decoration: BoxDecoration(
                      //       color: Common.containerBgColor,
                      //       borderRadius: BorderRadius.circular(8),
                      //       border: Border.all(color: Common.dialogContentBorderBgColor)),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       RadioButton(
                      //           checked: addCondition,
                      //           style: RadioButtonThemeData(
                      //             checkedDecoration: WidgetStateProperty.resolveWith((states) {
                      //               return BoxDecoration(
                      //                 border: Border.all(
                      //                   color: Common.selectedRadioButtonColor,
                      //                   width: !states.isDisabled
                      //                       ? states.isHovered && !states.isPressed
                      //                           ? 4.4
                      //                           : 6.0
                      //                       : 5.0,
                      //                 ),
                      //                 shape: BoxShape.circle,
                      //               );
                      //             }),
                      //           ),
                      //           onChanged: (checked) {
                      //             if (checked) {
                      //               addCondition = checked;
                      //               setState(() {});
                      //             }
                      //           }),
                      //       Text("附加条件", style: TextStyle(color: Common.contentDarkBgColor)).marginSymmetric(horizontal: 10),
                      //       textWidget("最新价"),
                      //       Container(
                      //         width: 100,
                      //         height: 36,
                      //         margin: const EdgeInsets.symmetric(horizontal: 10),
                      //         child: ComboBox<String>(
                      //           value: addConditionType,
                      //           isExpanded: true,
                      //           items: addConditionTypeList.map((e) {
                      //             return ComboBoxItem<String>(
                      //               value: e,
                      //               child: Text(e),
                      //             );
                      //           }).toList(),
                      //           onChanged: (v) => setState(() => addConditionType = v!),
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         height: 36,
                      //         width: 100,
                      //         child: NumberBox(
                      //           decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                      //           highlightColor: Colors.transparent,
                      //           unfocusedColor: Colors.transparent,
                      //           value: addConditionNum,
                      //           min: 1,
                      //           clearButton: false,
                      //           onChanged: (v) => setState(() => addConditionNum = v ?? 1),
                      //         ),
                      //       ),
                      //       Text(
                      //         "   手",
                      //         style: TextStyle(color: Common.commandTextColor),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      Row(
                        children: [
                          titleWidget("损盈"),
                          SizedBox(
                            width: 186,
                            height: 36,
                            child: ComboBox<String>(
                              value: winLossType,
                              isExpanded: true,
                              items: winLossTypeList.map((e) {
                                return ComboBoxItem<String>(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => winLossType = v!),
                            ),
                          ),
                        ],
                      ).marginSymmetric(vertical: 10),
                      Container(
                        margin: const EdgeInsets.only(left: 60),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Common.containerBgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Common.dialogContentBorderBgColor)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            textWidget(winLossType == "限价止损+限价止盈"
                                ? "止损价差"
                                : winLossType == "动态追踪"
                                    ? "回撤差价"
                                    : winLossType == "限价止损"
                                        ? "止损差价"
                                        : winLossType == "限价止盈"
                                            ? "止盈差价"
                                            : winLossType == "指定止损/止盈触发价"
                                                ? "止损触发价"
                                                : ""),
                            Container(
                              width: 100,
                              height: 36,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              child: NumberBox(
                                decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                highlightColor: Colors.transparent,
                                unfocusedColor: Colors.transparent,
                                value: lossMargin,
                                min: 0,
                                clearButton: false,
                                onChanged: (v) => setState(() => lossMargin = v ?? 1),
                              ),
                            ),
                            if (winLossType == "限价止损+限价止盈" || winLossType == "指定止损/止盈触发价") textWidget(winLossType == "限价止损+限价止盈" ? "止盈价差" : "止盈触发价"),
                            if (winLossType == "限价止损+限价止盈" || winLossType == "指定止损/止盈触发价")
                              Container(
                                height: 36,
                                width: 100,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                child: NumberBox(
                                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  value: winMargin,
                                  min: 0,
                                  clearButton: false,
                                  onChanged: (v) => setState(() => winMargin = v ?? 1),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          Text(
            selectedIndex == 0
                ? "*提示：1、止损开仓是在挂单列表生成一条止损预备单，可以挂单列表中修改或删除。2、止损预备单在委托成交后会自动转化为损盈单，止损预备单在云端运行，软件关闭后仍有效。"
                : "*提示：1、条件单不保证成交，也不保证成交在触发价。2、条件单平仓时，如果持仓可用数量不足，会自动撤掉原有挂单。3、条件单在云端运行，软件关闭后仍然有效。4、上期所有合约，按照设置决定是滞优先平今仓。",
            style: TextStyle(color: Common.commandTextColor),
          ),
          if (selectedIndex == 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.contentLightBgColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), side: BorderSide(color: Common.dialogContentBorderBgColor)))),
                  onPressed: () async {
                    await WindowController.fromWindowId(kWindowId!).hide();
                  },
                  child: Text('取消', style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.w500)),
                ).marginOnly(right: 15),
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  onPressed: () async {
                    // await DealServer.addOrder(
                    //         contract?.exCode,
                    //         contract?.subComCode,
                    //         contract?.subConCode,
                    //         contract?.comType,
                    //         contract?.OrderType,
                    //         TimeInForceType.ORDER_TIMEINFORCE_GFD,
                    //         "",
                    //         contract?.OrderSide,
                    //         contract?.OrderPrice,
                    //         contract?.StopPrice,
                    //         contract?.OrderQty,
                    //         contract?.PositionEffect,
                    //         "")
                    //     .then((value) async {
                    //   if (value) {
                    //     await WindowController.fromWindowId(kWindowId!).hide();
                    //   }
                    // });
                  },
                  child: Text(
                    '确定',
                    style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ).marginOnly(top: 20)
        ],
      ),
    );
  }

  Widget titleWidget(String text) {
    return SizedBox(
      width: 60,
      child: Text(
        text,
        style: TextStyle(color: Common.commandTextColor),
      ),
    );
  }

  Widget unitText(String text) {
    return Text(
      text,
      style: TextStyle(color: Common.commandTextColor),
    );
  }

  Widget _titleWidget(String text) {
    return Container(
      width: 80,
      padding: const EdgeInsets.only(left: 5),
      child: Text(
        text,
        style: TextStyle(color: Common.contentDarkBgColor),
      ),
    );
  }

  Widget textWidget(String text) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Common.lightBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      width: 100,
      height: 36,
      child: Text(
        text,
        style: TextStyle(color: Common.commandTextColor),
      ),
    );
  }
}
