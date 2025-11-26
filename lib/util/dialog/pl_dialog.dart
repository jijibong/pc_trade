import 'package:fluent_ui/fluent_ui.dart' hide NumberBox, TimePicker, DatePicker;
import 'package:get/get.dart';

import '../../config/common.dart';
import '../../model/trade/hold_order.dart';
import '../theme/theme.dart';
import '../../util/widget/number_box.dart';

class PLDialog {
  final ThemeController themeController = Get.find<ThemeController>();
  int selectedIndex = 0;
  double price = 0;
  double stopLossPrice = 0;
  int number = 0;
  String loseString = "1、止损单不保证成交、市价、超价、对手价下单，50%的概率成交在对手价，与触发价有1个点或更多的点差。\n2、止损单触发后，如果持仓可用数量不足，会自动撤掉原有挂单。\n3、止损单在云端运行，软件关闭后仍然有效。";
  String winString = "1、止盈单不保证成交、市价、超价、对手价下单，50%的概率成交在对手价，与触发价有1个点或更多的点差。\n2、止盈单触发后，如果持仓可用数量不足，会自动撤掉原有挂单。\n3、止盈单在云端运行，软件关闭后仍然有效。";
  String followString =
      "1、动态追踪又称之为追踪止损，是一种止损方式，不是止盈。它与静态止损的区别是与最高盈利对应的那个价位比较，而不是与开仓价位比较。2、如果你开始就做反了，行情直接向亏损的方向走，达到了止损点差参数，那么静态止损和追踪止损的效果是一样的。3、动态追踪止损的回撤点差参数，直接取你设置的止损点差，而不是取止盈点差。4、追踪止损在暂停后重启，按启动后的追踪价格重新监测。";

  Widget showPLDialog(String price, String win, {void Function()? functionConfirm, void Function()? functionCancel}) {
    return ContentDialog(
      style: ContentDialogThemeData(
          padding: EdgeInsets.zero,
          bodyPadding: EdgeInsets.zero,
          decoration: BoxDecoration(color: themeController.theme.inactiveColor, borderRadius: BorderRadius.zero)),
      content: Container(
          height: 180,
          color: Common.dialogContentColor,
          child: StatefulBuilder(builder: (_, state) {
            return Column(
              children: [
                Container(
                  color: Common.dialogTitleColor,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "修改止盈止损价格",
                          style: TextStyle(color: themeController.theme.activeColor),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(FluentIcons.cancel))
                    ],
                  ),
                ),
                Text(
                  "修改止$win价格为：$price",
                  style: TextStyle(color: themeController.theme.activeColor),
                ).marginSymmetric(vertical: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Button(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                          shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                      child: const Text(
                        "确认",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Get.back();
                        if (functionConfirm != null) functionConfirm();
                      },
                    ),
                    Button(
                      style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                      child: const Text(
                        "取消",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                        if (functionCancel != null) functionCancel();
                      },
                    ),
                  ],
                ).marginSymmetric(vertical: 15)
              ],
            );
          })),
    );
  }

  Widget setCloudPl(HoldOrder? holdOrder) {
    return ContentDialog(
        style: ContentDialogThemeData(
            padding: EdgeInsets.zero,
            bodyPadding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Common.tradeButtonColor, borderRadius: const BorderRadius.all(Radius.circular(20)))),
        constraints: const BoxConstraints(
          maxWidth: 630,
          maxHeight: 380,
        ),
        content: StatefulBuilder(builder: (_, state) {
          return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
              "设置云损盈",
              style: TextStyle(color: Common.contentDarkBgColor, fontSize: 18, fontWeight: FontWeight.bold),
            ).marginOnly(bottom: 10),
            Row(children: [
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
                    "云止损单",
                    style: TextStyle(
                        fontSize: 14, color: selectedIndex == 0 ? Common.contentDarkBgColor : Common.commandTextColor, fontWeight: FontWeight.w800),
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
                    "云止盈单",
                    style: TextStyle(
                        fontSize: 14, color: selectedIndex == 1 ? Common.contentDarkBgColor : Common.commandTextColor, fontWeight: FontWeight.w800),
                  )),
              Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(selectedIndex == 2 ? Common.tradeTypeButtonColor : Colors.transparent),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  onPressed: () {
                    selectedIndex = 2;
                    state(() {});
                  },
                  child: Text(
                    "动态追踪",
                    style: TextStyle(
                        fontSize: 14, color: selectedIndex == 2 ? Common.contentDarkBgColor : Common.commandTextColor, fontWeight: FontWeight.w800),
                  )),
            ]),
            Container(
                height: 150,
                decoration: BoxDecoration(
                    color: Common.contentLightBgColor,
                    border: Border.all(color: Common.dialogContentBorderBgColor),
                    borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (selectedIndex == 2)
                        //   Container(
                        //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        //     decoration: BoxDecoration(color: Common.tradeCloseButtonColor.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(FluentIcons.volume3, color: Common.goldenTextColor),
                        //         Text(
                        //           "您已设置静态止损",
                        //           style: TextStyle(color: Common.goldenTextColor),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        Row(
                          children: [
                            titleWidget("市场委托"),
                            Text(
                              holdOrder?.name ?? "",
                              style: TextStyle(color: Common.contentDarkBgColor),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            titleWidget(selectedIndex == 0
                                ? "止损触发价"
                                : selectedIndex == 1
                                    ? "止盈触发价"
                                    : "止损金额"),
                            if (selectedIndex == 0 || selectedIndex == 1)
                              SizedBox(
                                height: 36,
                                width: 100,
                                child: NumberBox(
                                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  style: TextStyle(color: Common.contentDarkBgColor),
                                  value: price,
                                  min: 1,
                                  max: 10000000,
                                  clearButton: false,
                                  onChanged: (v) => state(() => price = v ?? 1),
                                ),
                              ).marginOnly(right: 15),
                            if (selectedIndex == 0 || selectedIndex == 1)
                              SizedBox(
                                height: 36,
                                width: 100,
                                child: NumberBox(
                                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  style: TextStyle(color: Common.contentDarkBgColor),
                                  value: number,
                                  min: 1,
                                  max: 10000000,
                                  clearButton: false,
                                  onChanged: (v) => state(() => number = v ?? 1),
                                ),
                              ),
                            if (selectedIndex == 2)
                              SizedBox(
                                height: 36,
                                width: 100,
                                child: NumberBox(
                                  decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                                  highlightColor: Colors.transparent,
                                  unfocusedColor: Colors.transparent,
                                  style: TextStyle(color: Common.contentDarkBgColor),
                                  value: stopLossPrice,
                                  min: 1,
                                  max: 10000000,
                                  clearButton: false,
                                  onChanged: (v) => state(() => stopLossPrice = v ?? 1),
                                ),
                              ),
                            Text(
                              selectedIndex != 2 ? "   手" : "  元",
                              style: TextStyle(color: Common.commandTextColor),
                            )
                          ],
                        ).marginSymmetric(vertical: 16),

                        ///TODO
                        Text(
                          "价差214，预期亏损1000元，百分比12%",
                          style: TextStyle(color: Common.commandTextColor, fontSize: 12),
                        ).marginOnly(left: 100, top: 5),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Common.dialogContentBorderBgColor,
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(text: "最新价", style: TextStyle(color: Common.contentDarkBgColor)),
                                TextSpan(text: "--", style: TextStyle(color: Common.quoteHighColor)),
                              ]),
                            )
                          ],
                        ).marginOnly(right: 20, bottom: 20),
                        Button(
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Common.greenButtonColor),
                                    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 50, vertical: 10)),
                                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(FluentIcons.play, size: 12, color: Common.dialogLightBgColor),
                                  Text("开启", style: TextStyle(color: Common.dialogLightBgColor))
                                ]),
                                onPressed: () {})
                            .marginSymmetric(vertical: 10),
                        Text(
                          "${selectedIndex == 0 ? "止损单" : selectedIndex == 1 ? "止盈单" : "动态追踪"}已暂停，点击开启",
                          style: TextStyle(color: Common.commandTextColor, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ])),
            Text(
              selectedIndex == 0
                  ? loseString
                  : selectedIndex == 1
                      ? winString
                      : followString,
              style: TextStyle(color: Common.commandTextColor, fontSize: 12, height: 1.5),
            )
          ]);
        }));
  }

  Widget titleWidget(String text) {
    return SizedBox(
      width: 100,
      child: Text(
        text,
        style: TextStyle(color: Common.commandTextColor),
      ),
    );
  }
}
