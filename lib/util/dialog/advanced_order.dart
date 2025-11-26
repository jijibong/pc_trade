import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:trade/model/quote/contract.dart';

import '../../config/common.dart';
import '../../page/quote/quote_logic.dart';

class AdvancedOrderDialog {
  final QuoteLogic logic = Get.put(QuoteLogic());
  int selectedIndex = 0;
  bool autoClose = false;
  bool dir = true;
  bool toggle = false;
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

  Widget orderDialog(Contract? contract) {
    return FluentTheme(
        data: FluentThemeData(),
        child: ContentDialog(
          style: ContentDialogThemeData(
            decoration: BoxDecoration(
              color: Common.tradeButtonColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(15),
          ),
          constraints: const BoxConstraints(
            maxWidth: 812.0,
            maxHeight: 598.0,
          ),
          content: StatefulBuilder(builder: (_, state) {
            return SizedBox(
              width: 772,
              height: 558,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(FluentIcons.cancel))
                    ],
                  ),
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
                          onPressed: () {
                            selectedIndex = 0;
                            state(() {});
                          },
                          child: Text(
                            "止损开仓",
                            style: TextStyle(
                                fontSize: 14,
                                color: selectedIndex == 0 ? Common.contentDarkBgColor : Common.commandTextColor,
                                fontWeight: FontWeight.w800),
                          )).marginOnly(right: 10),
                      Button(
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(selectedIndex == 1 ? Common.tradeTypeButtonColor : Colors.transparent),
                              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                          onPressed: () {
                            selectedIndex = 1;
                            state(() {});
                          },
                          child: Text(
                            "条件单",
                            style: TextStyle(
                                fontSize: 14,
                                color: selectedIndex == 1 ? Common.contentDarkBgColor : Common.commandTextColor,
                                fontWeight: FontWeight.w800),
                          )),
                    ],
                  ),
                  Container(
                    height: 380,
                    decoration: BoxDecoration(border: Border.all(color: Common.dialogContentBorderBgColor), borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(24),
                    child: selectedIndex == 0
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Column(
                                        // mainAxisAlignment: MainAxisAlignment.start,
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
                                                      state(() {});
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
                                                      state(() {});
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
                                                  min: 1,
                                                  max: 10000000,
                                                  clearButton: false,
                                                  onChanged: (v) => state(() => num = v ?? 1),
                                                ),
                                              ),
                                            ],
                                          ),
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
                                                  min: 1,
                                                  max: 10000000,
                                                  clearButton: false,
                                                  onChanged: (v) => state(() => price = v ?? 1),
                                                ),
                                              ),
                                              ToggleSwitch(
                                                checked: toggle,
                                                onChanged: (v) => state(() => toggle = v),
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
                                      Container(
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
                                              "(买入开仓)",
                                              style: TextStyle(color: Common.contentDarkBgColor),
                                            ),
                                          ],
                                        ),
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
                                              state(() {});
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
                                              state(() {});
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
                                          min: 1,
                                          max: 10000000,
                                          clearButton: false,
                                          onChanged: (v) => state(() => lossTriggerPrice = v ?? 0),
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
                                              state(() {});
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
                                          min: 1,
                                          max: 10000000,
                                          clearButton: false,
                                          onChanged: (v) => state(() => winTriggerPrice = v ?? 1),
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
                                              state(() {});
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
                                          min: 1,
                                          max: 10000000,
                                          clearButton: false,
                                          onChanged: (v) => state(() => lossSpreadPrice = v ?? 0),
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
                                              state(() {});
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
                                          min: 1,
                                          max: 10000000,
                                          clearButton: false,
                                          onChanged: (v) => state(() => winSpreadPrice = v ?? 1),
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
                                              state(() {});
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
                                          min: 1,
                                          max: 10000000,
                                          clearButton: false,
                                          onChanged: (v) => state(() => lossPrice = v ?? 0),
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
                                              state(() {});
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
                                          min: 1,
                                          max: 10000000,
                                          clearButton: false,
                                          onChanged: (v) => state(() => winPrice = v ?? 1),
                                        ),
                                      ),
                                      unitText("元").marginOnly(left: 5),
                                    ],
                                  )),
                                ],
                              ),
                            ],
                          )
                        : Column(),
                  ),
                  Text(
                    selectedIndex == 0
                        ? "*提示：1、止损开仓是在挂单列表生成一条止损预备单，可以挂单列表中修改或删除。2、止损预备单在委托成交后会自动转化为损盈单，止损预备单在云端运行，软件关闭后仍有效。"
                        : "*提示：1、条件单不保证成交，也不保证成交在触发价。2、条件单平仓时，如果持仓可用数量不足，会自动撤掉原有挂单。3、条件单在云端运行，软件关闭后仍然有效。4、上期所有合约，按照设置决定是滞优先平今仓。",
                    style: TextStyle(color: Common.commandTextColor),
                  )
                ],
              ),
            );
          }),
        ));
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
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(color: Common.contentDarkBgColor),
      ),
    );
  }
}
