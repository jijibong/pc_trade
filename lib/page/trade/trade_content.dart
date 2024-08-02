import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart' hide AutoSuggestBox, AutoSuggestBoxItem, NumberBox, SpinButtonPlacementMode;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';

import '../../model/quote/commodity.dart';
import '../../util/log/log.dart';
import '../../util/theme/theme.dart';
import '../../util/utils/utils.dart';
import '../../util/widget/auto_suggest_box.dart';
import '../../util/widget/combo_box.dart' as my_combo;
import '../../util/widget/number_box.dart';
import '../quote/quote_logic.dart';

class TradeContent extends StatefulWidget {
  const TradeContent({super.key});

  @override
  State<TradeContent> createState() => _TradeContentState();
}

class _TradeContentState extends State<TradeContent> {
  final QuoteLogic logic = Get.put(QuoteLogic());
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  late AppTheme appTheme;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appTheme = context.watch<AppTheme>();
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tabItem("交易", 0),
            tabItem("云条件单", 1),
            tabItem("当日委托", 2),
            tabItem("当日成交", 3),
            tabItem("持仓", 4),
            tabItem("查询", 5),
            tabItem("交易设置", 6),
          ],
        ),
        Container(
          color: appTheme.commandBarColor,
          margin: const EdgeInsets.only(left: 5),
          child: selectedIndex == 0 || selectedIndex == 2 || selectedIndex == 3 || selectedIndex == 4
              ? Obx(() => tradeContent())
              : selectedIndex == 1
                  ? Obx(() => cloudConditionContent())
                  : null,
        ),
        selectedIndex == 0
            ? tradeDetails()
            : selectedIndex == 1
                ? cloudConditionDetails()
                : selectedIndex == 2
                    ? orderDetails()
                    : selectedIndex == 3
                        ? dealDetails()
                        : selectedIndex == 4
                            ? posDetails()
                            : selectedIndex == 5
                                ? queryWidget()
                                : selectedIndex == 6
                                    ? settingWidget()
                                    : Container()
      ],
    );
  }

  Widget tableTitleItem(String? text) {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: Text(
          text ?? "--",
        ));
  }

  Widget tableRadioItem(String check, String uncheck, {bool? checked}) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
      alignment: Alignment.center,
      child: StatefulBuilder(builder: (_, state) {
        return Row(
          children: [
            RadioButton(
                checked: checked != false,
                content: Text(check),
                onChanged: (v) {
                  if (v) {
                    state(() => checked = true);
                  }
                }),
            RadioButton(
                checked: checked == false,
                content: Text(uncheck),
                onChanged: (v) {
                  if (v) {
                    state(() => checked = false);
                  }
                }),
          ],
        );
      }),
    );
  }

  Widget tablePointItem({int? value}) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
      child: StatefulBuilder(builder: (_, state) {
        return NumberBox(
          value: value ?? 0,
          min: 0,
          clearButton: false,
          onChanged: (v) => state(() => value = v ?? 0),
          mode: SpinButtonPlacementMode.inline,
        );
      }),
    );
  }

  Widget tableOperateItem(int index) {
    return GestureDetector(
      child: Container(
          decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          child: Text(
            "重置",
            style: TextStyle(color: Colors.blue),
          )),
      onTap: () {},
    );
  }

  Widget tabItem(String title, int index) {
    return Expanded(
        child: GestureDetector(
      onTap: () {
        selectedIndex = index;
        if (mounted) setState(() {});
      },
      child: Container(
        width: 138,
        alignment: Alignment.center,
        color: selectedIndex == index ? appTheme.commandBarColor : Colors.transparent,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17),
        ),
      ),
    ));
  }

  Widget tradeContent() {
    bool open = true;
    bool auto = true;
    bool dir = true;
    int num = 1;
    String price = "0.00";
    double boxWidth = 158;
    double padWidth = 20;
    List priceList = ["对手价", "排队价", "市价", "最新价", "超价"];
    TextEditingController controller = TextEditingController(text: logic.selectedContract.value.code);

    List<Tab> tabs = [
      Tab(
        text: Text(
          '快手下单',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: appTheme.tradeIndex == 0 ? Colors.yellow : appTheme.exchangeTextColor),
        ),
        body: SizedBox(
          width: 388,
          height: 500,
          child: StatefulBuilder(
            builder: (_, state) {
              return ListView(
                shrinkWrap: true,
                children: [
                  Row(children: [
                    SizedBox(width: padWidth),
                    const Text("合约"),
                    Container(
                      width: boxWidth,
                      height: 28,
                      margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
                      child: AutoSuggestBox(
                        controller: controller,
                        items: logic.mContractList.map((e) {
                          return AutoSuggestBoxItem<String>(
                            value: e.code ?? "--",
                            label: e.code ?? "--",
                          );
                        }).toList(),
                        onSelected: (item) {},
                        onOverlayVisibilityChanged: (visible) {},
                      ),
                    ),
                    const SizedBox(
                      width: 58,
                    ),
                    Button(
                        style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 3))),
                        onPressed: () {},
                        child: const Text("复位")),
                  ]),
                  Row(
                    children: [
                      SizedBox(width: padWidth),
                      RadioButton(
                          checked: open,
                          onChanged: (checked) {
                            if (checked) {
                              state(() => open = checked);
                            }
                          }),
                      const Text("  开仓"),
                      const SizedBox(width: 28),
                      RadioButton(
                          checked: !open,
                          onChanged: (checked) {
                            if (checked) {
                              state(() => open = !checked);
                            }
                          }),
                      const Text("  平仓"),
                      const SizedBox(width: 28),
                      Checkbox(
                        checked: auto,
                        onChanged: (bool? value) => state(() => auto = value ?? true),
                      ),
                      const Text("  自动"),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: padWidth),
                      const Text("数量"),
                      Container(
                        width: boxWidth,
                        height: 38,
                        margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
                        child: NumberBox(
                          value: num,
                          min: 1,
                          max: 10000000,
                          clearButton: false,
                          onChanged: (v) => state(() => num = v ?? 1),
                          mode: SpinButtonPlacementMode.inline,
                        ),
                      ),
                      Column(
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(text: "  买：", style: TextStyle(color: Colors.red)),
                            TextSpan(text: "可开 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                            TextSpan(text: "--", style: TextStyle(color: appTheme.color)),
                            TextSpan(text: "  可平 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                            TextSpan(text: "0", style: TextStyle(color: appTheme.color))
                          ])),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(text: "  卖：", style: TextStyle(color: Colors.green)),
                            TextSpan(text: "可开 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                            TextSpan(text: "--", style: TextStyle(color: appTheme.color)),
                            TextSpan(text: "  可平 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                            TextSpan(text: "0", style: TextStyle(color: appTheme.color))
                          ])),
                        ],
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: padWidth),
                      const Text("价格"),
                      Container(
                        width: boxWidth,
                        height: 38,
                        margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                        child: my_combo.EditableComboBox<String>(
                          value: price,
                          items: priceList.map<my_combo.ComboBoxItem<String>>((e) {
                            return my_combo.ComboBoxItem<String>(
                              value: e,
                              child: Text('$e'),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() => price = v ?? "0.00");
                          },
                          onFieldSubmitted: (String text) {
                            return text;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.red, borderRadius: const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  price,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 135,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "买入",
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.green, borderRadius: const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  price,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 135,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "卖出",
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
      Tab(
        text: Text(
          '三键下单',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: appTheme.tradeIndex == 1 ? Colors.yellow : appTheme.exchangeTextColor),
        ),
        body: SizedBox(
          width: 388,
          height: 500,
          child: StatefulBuilder(
            builder: (_, state) {
              return ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 18),
                  Row(children: [
                    SizedBox(width: padWidth),
                    const Text("合约"),
                    Container(
                      width: boxWidth,
                      height: 28,
                      margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                      child: AutoSuggestBox(
                        controller: controller,
                        items: logic.mContractList.map((e) {
                          return AutoSuggestBoxItem<String>(
                            value: e.code ?? "--",
                            label: e.code ?? "--",
                          );
                        }).toList(),
                        onSelected: (item) {},
                        onOverlayVisibilityChanged: (visible) {},
                      ),
                    ),
                    const SizedBox(
                      width: 58,
                    ),
                    Button(
                        style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 3))),
                        onPressed: () {},
                        child: const Text("复位")),
                  ]),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: padWidth),
                      const Text("数量"),
                      Container(
                        width: boxWidth,
                        height: 38,
                        margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
                        child: NumberBox(
                          value: num,
                          min: 1,
                          max: 10000000,
                          clearButton: false,
                          onChanged: (v) => state(() => num = v ?? 1),
                          mode: SpinButtonPlacementMode.inline,
                        ),
                      ),
                      Column(
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(text: "  买：", style: TextStyle(color: Colors.red)),
                            TextSpan(text: "可开 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                            TextSpan(text: "--", style: TextStyle(color: appTheme.color)),
                            TextSpan(text: "  可平 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                            TextSpan(text: "0", style: TextStyle(color: appTheme.color))
                          ])),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(text: "  卖：", style: TextStyle(color: Colors.green)),
                            TextSpan(text: "可开 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                            TextSpan(text: "--", style: TextStyle(color: appTheme.color)),
                            TextSpan(text: "  可平 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                            TextSpan(text: "0", style: TextStyle(color: appTheme.color))
                          ])),
                        ],
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: padWidth),
                      const Text("价格"),
                      Container(
                        width: boxWidth,
                        height: 38,
                        margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                        child: my_combo.EditableComboBox<String>(
                          value: price,
                          items: priceList.map<my_combo.ComboBoxItem<String>>((e) {
                            return my_combo.ComboBoxItem<String>(
                              value: e,
                              child: Text('$e'),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() => price = v ?? "0.00");
                          },
                          onFieldSubmitted: (String text) {
                            return text;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.red, borderRadius: const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  price,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 88,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "买入",
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.green, borderRadius: const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  price,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 88,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "卖出",
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.yellow, borderRadius: const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  price,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 88,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "平仓",
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
      Tab(
          text: Text(
            '传统下单',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: appTheme.tradeIndex == 2 ? Colors.yellow : appTheme.exchangeTextColor),
          ),
          body: SizedBox(
            width: 388,
            height: 500,
            child: StatefulBuilder(
              builder: (_, state) {
                return ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 18),
                    Row(children: [
                      SizedBox(width: padWidth),
                      const Text("合约"),
                      Container(
                        width: boxWidth,
                        height: 28,
                        margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                        child: AutoSuggestBox(
                          controller: controller,
                          items: logic.mContractList.map((e) {
                            return AutoSuggestBoxItem<String>(
                              value: e.code ?? "--",
                              label: e.code ?? "--",
                            );
                          }).toList(),
                          onSelected: (item) {},
                          onOverlayVisibilityChanged: (visible) {},
                        ),
                      ),
                      const SizedBox(
                        width: 58,
                      ),
                      Button(
                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 3))),
                          onPressed: () {},
                          child: const Text("复位")),
                    ]),
                    Row(
                      children: [
                        SizedBox(
                          width: padWidth,
                          height: 58,
                        ),
                        const Text("方向   "),
                        RadioButton(
                            checked: dir,
                            onChanged: (checked) {
                              if (checked) {
                                state(() => dir = checked);
                              }
                            }),
                        const Text("  买入"),
                        const SizedBox(width: 28),
                        RadioButton(
                            checked: !dir,
                            onChanged: (checked) {
                              if (checked) {
                                state(() => dir = !checked);
                              }
                            }),
                        const Text("  卖出"),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: padWidth),
                        const Text("开平   "),
                        RadioButton(
                            checked: open,
                            onChanged: (checked) {
                              if (checked) {
                                state(() => open = checked);
                              }
                            }),
                        const Text("  开仓"),
                        const SizedBox(width: 28),
                        RadioButton(
                            checked: !open,
                            onChanged: (checked) {
                              if (checked) {
                                state(() => open = !checked);
                              }
                            }),
                        const Text("  平仓"),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: padWidth),
                        const Text("数量"),
                        Container(
                          width: boxWidth,
                          height: 38,
                          margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
                          child: NumberBox(
                            value: num,
                            min: 1,
                            max: 10000000,
                            clearButton: false,
                            onChanged: (v) => state(() => num = v ?? 1),
                            mode: SpinButtonPlacementMode.inline,
                          ),
                        ),
                        Column(
                          children: [
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(text: "  买：", style: TextStyle(color: Colors.red)),
                              TextSpan(text: "可开 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                              TextSpan(text: "--", style: TextStyle(color: appTheme.color)),
                              TextSpan(text: "  可平 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                              TextSpan(text: "0", style: TextStyle(color: appTheme.color))
                            ])),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(text: "  卖：", style: TextStyle(color: Colors.green)),
                              TextSpan(text: "可开 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                              TextSpan(text: "--", style: TextStyle(color: appTheme.color)),
                              TextSpan(text: "  可平 ", style: TextStyle(color: appTheme.exchangeTextColor)),
                              TextSpan(text: "0", style: TextStyle(color: appTheme.color))
                            ])),
                          ],
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: padWidth),
                        const Text("价格"),
                        Container(
                          width: boxWidth,
                          height: 38,
                          margin: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                          child: my_combo.EditableComboBox<String>(
                            value: price,
                            items: priceList.map<my_combo.ComboBoxItem<String>>((e) {
                              return my_combo.ComboBoxItem<String>(
                                value: e,
                                child: Text('$e'),
                              );
                            }).toList(),
                            onChanged: (v) {
                              setState(() => price = v ?? "0.00");
                            },
                            onFieldSubmitted: (String text) {
                              return text;
                            },
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      child: Container(
                        width: 58,
                        decoration: BoxDecoration(color: Colors.red, borderRadius: const BorderRadius.all(Radius.circular(5))),
                        margin: EdgeInsets.fromLTRB(padWidth, 20, 268, 20),
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: const AutoSizeText(
                          "下单",
                          maxLines: 1,
                          style: TextStyle(color: Colors.white, fontSize: 23),
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                );
              },
            ),
          ))
    ];

    return Row(
      children: [
        SizedBox(
          width: 388,
          child: StatefulBuilder(builder: (_, refresh) {
            return TabView(
              tabs: tabs,
              currentIndex: appTheme.tradeIndex,
              onChanged: (index) => appTheme.tradeIndex = index,
              tabWidthBehavior: TabWidthBehavior.equal,
              closeButtonVisibility: CloseButtonVisibilityMode.never,
              showScrollButtons: false,
            );
          }),
        )
      ],
    );
  }

  Widget tradeDetails() {
    ScrollController scrollController = ScrollController();
    ScrollController secScrollController = ScrollController();
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(15),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Button(
                        style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        onPressed: () {
                          appTheme.tradeDetailIndex = 0;
                        },
                        child: Text(
                          "合\n计",
                          style: TextStyle(fontSize: 18, color: appTheme.tradeDetailIndex == 0 ? Colors.yellow : appTheme.exchangeTextColor),
                        )),
                    const SizedBox(height: 20),
                    Button(
                      style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                      onPressed: () {
                        appTheme.tradeDetailIndex = 1;
                      },
                      child: Text(
                        "明\n细",
                        style: TextStyle(fontSize: 18, color: appTheme.tradeDetailIndex == 1 ? Colors.yellow : appTheme.exchangeTextColor),
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 15),
                        Button(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                            onPressed: () {},
                            child: Text(
                              "全部平仓",
                              style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                            )),
                        const SizedBox(width: 15),
                        Button(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                            onPressed: () {},
                            child: Text(
                              "快捷平仓",
                              style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                            )),
                        const SizedBox(width: 15),
                        Button(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                            onPressed: () {},
                            child: Text(
                              "快捷反手",
                              style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                            )),
                        const SizedBox(width: 15),
                        Button(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                            onPressed: () {},
                            child: Text(
                              "快捷锁仓",
                              style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                            )),
                        const SizedBox(width: 15),
                        Button(
                            onPressed: () {},
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                            child: Text(
                              "止盈止损",
                              style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                            )),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
                      margin: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                      child: Scrollbar(
                        controller: scrollController,
                        style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
                        child: SingleChildScrollView(
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                                width: 0.8.sw,
                                height: 168,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: 1,
                                    // itemCount: data.length + 1,
                                    itemBuilder: (BuildContext context, int index) {
                                      // if (index == 0) {
                                      return Row(
                                        children: [
                                          Expanded(flex: 2, child: tableTitleItem("合约代码")),
                                          Expanded(flex: 1, child: tableTitleItem("买卖")),
                                          Expanded(flex: 1, child: tableTitleItem("数量")),
                                          Expanded(flex: 1, child: tableTitleItem("可平")),
                                          Expanded(flex: 2, child: tableTitleItem("开仓均价")),
                                          Expanded(flex: 2, child: tableTitleItem("计算价格")),
                                          Expanded(flex: 2, child: tableTitleItem("浮动盈亏")),
                                          Expanded(flex: 2, child: tableTitleItem("保证金占用")),
                                          Expanded(flex: 1, child: tableTitleItem("币种")),
                                          Expanded(flex: 3, child: tableTitleItem("合约名称")),
                                          Expanded(flex: 2, child: tableTitleItem("止盈止损")),
                                        ],
                                      );
                                      // }
                                      // else {
                                      //   return GestureDetector(
                                      //     child: Container(
                                      //       color: data[index - 1].selected
                                      //           ? Colors.black.withOpacity(0.2)
                                      //           : Colors.transparent,
                                      //       child: IntrinsicHeight(
                                      //           child: Row(
                                      //             crossAxisAlignment: CrossAxisAlignment.stretch,
                                      //             children: [
                                      //               Expanded(flex: 1, child: tableItem(data[index - 1].OrderQty.toString())),
                                      //               Expanded(flex: 2, child: tableItem(data[index - 1].Account)),
                                      //               Expanded(flex: 3, child: tableItem(data[index - 1].SubmitResultsMsg)),
                                      //               Expanded(flex: 3, child: tableItem(data[index - 1].CreateAt)),
                                      //               Expanded(flex: 3, child: tableItem(data[index - 1].UpdateAt)),
                                      //               Expanded(flex: 2, child: buttonItem(data[index - 1].Id))
                                      //             ],
                                      //           )),
                                      //     ),
                                      //     onTap: () {
                                      //       // if (data[index - 1].selected == true) return;
                                      //       // for (var element in data) {
                                      //       //   element.selected = false;
                                      //       // }
                                      //       // data[index - 1].selected = true;
                                      //       // if (mounted) setState(() {});
                                      //     },
                                      //   );
                                      // }
                                    }))),
                      ),
                    ),
                  ],
                ))
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Button(
                        style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        onPressed: () {
                          appTheme.tradeDetailIndex = 0;
                        },
                        child: Text(
                          "可\n撤",
                          style: TextStyle(fontSize: 18, color: appTheme.tradeDetailIndex == 0 ? Colors.yellow : appTheme.exchangeTextColor),
                        )),
                    const SizedBox(height: 20),
                    Button(
                      style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                      onPressed: () {
                        appTheme.tradeDetailIndex = 1;
                      },
                      child: Text(
                        "全\n部",
                        style: TextStyle(fontSize: 18, color: appTheme.tradeDetailIndex == 1 ? Colors.yellow : appTheme.exchangeTextColor),
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 15),
                        Button(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                            onPressed: () {},
                            child: Text(
                              "全部撤单",
                              style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                            )),
                        const SizedBox(width: 15),
                        Button(
                            onPressed: () {},
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                            child: Text(
                              "撤单",
                              style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                            )),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
                      margin: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                      child: Scrollbar(
                        controller: secScrollController,
                        style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
                        child: SingleChildScrollView(
                            controller: secScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                                width: 0.8.sw,
                                height: 168,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: 1,
                                    // itemCount: data.length + 1,
                                    itemBuilder: (BuildContext context, int index) {
                                      // if (index == 0) {
                                      return Row(
                                        children: [
                                          Expanded(flex: 3, child: tableTitleItem("委托时间")),
                                          Expanded(flex: 2, child: tableTitleItem("合约代码")),
                                          Expanded(flex: 1, child: tableTitleItem("买卖")),
                                          Expanded(flex: 1, child: tableTitleItem("开平")),
                                          Expanded(flex: 1, child: tableTitleItem("价格")),
                                          Expanded(flex: 2, child: tableTitleItem("委托数量")),
                                          Expanded(flex: 2, child: tableTitleItem("成交数量")),
                                          Expanded(flex: 1, child: tableTitleItem("币种")),
                                          Expanded(flex: 2, child: tableTitleItem("订单来源")),
                                          Expanded(flex: 1, child: tableTitleItem("状态")),
                                          Expanded(flex: 2, child: tableTitleItem("错误信息")),
                                          Expanded(flex: 3, child: tableTitleItem("委托号")),
                                          Expanded(flex: 3, child: tableTitleItem("合约名称")),
                                        ],
                                      );
                                      // }
                                      // else {
                                      //   return GestureDetector(
                                      //     child: Container(
                                      //       color: data[index - 1].selected
                                      //           ? Colors.black.withOpacity(0.2)
                                      //           : Colors.transparent,
                                      //       child: IntrinsicHeight(
                                      //           child: Row(
                                      //             crossAxisAlignment: CrossAxisAlignment.stretch,
                                      //             children: [
                                      //               Expanded(flex: 1, child: tableItem(data[index - 1].OrderQty.toString())),
                                      //               Expanded(flex: 2, child: tableItem(data[index - 1].Account)),
                                      //               Expanded(flex: 3, child: tableItem(data[index - 1].SubmitResultsMsg)),
                                      //               Expanded(flex: 3, child: tableItem(data[index - 1].CreateAt)),
                                      //               Expanded(flex: 3, child: tableItem(data[index - 1].UpdateAt)),
                                      //               Expanded(flex: 2, child: buttonItem(data[index - 1].Id))
                                      //             ],
                                      //           )),
                                      //     ),
                                      //     onTap: () {
                                      //       // if (data[index - 1].selected == true) return;
                                      //       // for (var element in data) {
                                      //       //   element.selected = false;
                                      //       // }
                                      //       // data[index - 1].selected = true;
                                      //       // if (mounted) setState(() {});
                                      //     },
                                      //   );
                                      // }
                                    }))),
                      ),
                    ),
                  ],
                ))
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget orderDetails() {
    ScrollController scrollController = ScrollController();
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(15),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Button(
                    style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                    onPressed: () {
                      appTheme.tradeDetailIndex = 0;
                    },
                    child: Text(
                      "可\n撤",
                      style: TextStyle(fontSize: 18, color: appTheme.tradeDetailIndex == 0 ? Colors.yellow : appTheme.exchangeTextColor),
                    )),
                const SizedBox(height: 20),
                Button(
                  style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                  onPressed: () {
                    appTheme.tradeDetailIndex = 1;
                  },
                  child: Text(
                    "全\n部",
                    style: TextStyle(fontSize: 18, color: appTheme.tradeDetailIndex == 1 ? Colors.yellow : appTheme.exchangeTextColor),
                  ),
                ),
              ],
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        onPressed: () {},
                        child: Text(
                          "全部撤单",
                          style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        onPressed: () {},
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        child: Text(
                          "撤单",
                          style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                  ],
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
                    margin: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                    child: Scrollbar(
                      controller: scrollController,
                      style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                              width: 0.8.sw,
                              height: 168,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 1,
                                  // itemCount: data.length + 1,
                                  itemBuilder: (BuildContext context, int index) {
                                    // if (index == 0) {
                                    return Row(
                                      children: [
                                        Expanded(flex: 3, child: tableTitleItem("委托时间")),
                                        Expanded(flex: 2, child: tableTitleItem("合约代码")),
                                        Expanded(flex: 1, child: tableTitleItem("买卖")),
                                        Expanded(flex: 1, child: tableTitleItem("开平")),
                                        Expanded(flex: 1, child: tableTitleItem("价格")),
                                        Expanded(flex: 2, child: tableTitleItem("委托数量")),
                                        Expanded(flex: 2, child: tableTitleItem("成交数量")),
                                        Expanded(flex: 1, child: tableTitleItem("币种")),
                                        Expanded(flex: 2, child: tableTitleItem("订单来源")),
                                        Expanded(flex: 1, child: tableTitleItem("状态")),
                                        Expanded(flex: 2, child: tableTitleItem("错误信息")),
                                        Expanded(flex: 3, child: tableTitleItem("委托号")),
                                        Expanded(flex: 3, child: tableTitleItem("合约名称")),
                                      ],
                                    );
                                    // }
                                    // else {
                                    //   return GestureDetector(
                                    //     child: Container(
                                    //       color: data[index - 1].selected
                                    //           ? Colors.black.withOpacity(0.2)
                                    //           : Colors.transparent,
                                    //       child: IntrinsicHeight(
                                    //           child: Row(
                                    //             crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //             children: [
                                    //               Expanded(flex: 1, child: tableItem(data[index - 1].OrderQty.toString())),
                                    //               Expanded(flex: 2, child: tableItem(data[index - 1].Account)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].SubmitResultsMsg)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].CreateAt)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].UpdateAt)),
                                    //               Expanded(flex: 2, child: buttonItem(data[index - 1].Id))
                                    //             ],
                                    //           )),
                                    //     ),
                                    //     onTap: () {
                                    //       // if (data[index - 1].selected == true) return;
                                    //       // for (var element in data) {
                                    //       //   element.selected = false;
                                    //       // }
                                    //       // data[index - 1].selected = true;
                                    //       // if (mounted) setState(() {});
                                    //     },
                                    //   );
                                    // }
                                  }))),
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    ));
  }

  Widget dealDetails() {
    ScrollController scrollController = ScrollController();
    return Expanded(
        child: ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
        child: Scrollbar(
          controller: scrollController,
          style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
          child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                  width: 0.8.sw,
                  alignment: Alignment.topLeft,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 1,
                      // itemCount: data.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        // if (index == 0) {
                        return Row(
                          children: [
                            Expanded(flex: 3, child: tableTitleItem("委托时间")),
                            Expanded(flex: 2, child: tableTitleItem("合约代码")),
                            Expanded(flex: 1, child: tableTitleItem("买卖")),
                            Expanded(flex: 1, child: tableTitleItem("开平")),
                            Expanded(flex: 1, child: tableTitleItem("价格")),
                            Expanded(flex: 2, child: tableTitleItem("委托数量")),
                            Expanded(flex: 2, child: tableTitleItem("成交数量")),
                            Expanded(flex: 1, child: tableTitleItem("币种")),
                            Expanded(flex: 2, child: tableTitleItem("订单来源")),
                            Expanded(flex: 1, child: tableTitleItem("状态")),
                            Expanded(flex: 2, child: tableTitleItem("错误信息")),
                            Expanded(flex: 3, child: tableTitleItem("委托号")),
                            Expanded(flex: 3, child: tableTitleItem("合约名称")),
                          ],
                        );
                        // }
                        // else {
                        //   return GestureDetector(
                        //     child: Container(
                        //       color: data[index - 1].selected
                        //           ? Colors.black.withOpacity(0.2)
                        //           : Colors.transparent,
                        //       child: IntrinsicHeight(
                        //           child: Row(
                        //             crossAxisAlignment: CrossAxisAlignment.stretch,
                        //             children: [
                        //               Expanded(flex: 1, child: tableItem(data[index - 1].OrderQty.toString())),
                        //               Expanded(flex: 2, child: tableItem(data[index - 1].Account)),
                        //               Expanded(flex: 3, child: tableItem(data[index - 1].SubmitResultsMsg)),
                        //               Expanded(flex: 3, child: tableItem(data[index - 1].CreateAt)),
                        //               Expanded(flex: 3, child: tableItem(data[index - 1].UpdateAt)),
                        //               Expanded(flex: 2, child: buttonItem(data[index - 1].Id))
                        //             ],
                        //           )),
                        //     ),
                        //     onTap: () {
                        //       // if (data[index - 1].selected == true) return;
                        //       // for (var element in data) {
                        //       //   element.selected = false;
                        //       // }
                        //       // data[index - 1].selected = true;
                        //       // if (mounted) setState(() {});
                        //     },
                        //   );
                        // }
                      }))),
        ),
      ),
    ));
  }

  Widget posDetails() {
    ScrollController scrollController = ScrollController();
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(left: 15, top: 5, right: 5),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Button(
                    style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                    onPressed: () {
                      appTheme.tradeDetailIndex = 0;
                    },
                    child: Text(
                      "合\n计",
                      style: TextStyle(fontSize: 18, color: appTheme.tradeDetailIndex == 0 ? Colors.yellow : appTheme.exchangeTextColor),
                    )),
                const SizedBox(height: 20),
                Button(
                  style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(10)), shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                  onPressed: () {
                    appTheme.tradeDetailIndex = 1;
                  },
                  child: Text(
                    "明\n细",
                    style: TextStyle(fontSize: 18, color: appTheme.tradeDetailIndex == 1 ? Colors.yellow : appTheme.exchangeTextColor),
                  ),
                ),
              ],
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        onPressed: () {},
                        child: Text(
                          "全部平仓",
                          style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        onPressed: () {},
                        child: Text(
                          "快捷平仓",
                          style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        onPressed: () {},
                        child: Text(
                          "快捷反手",
                          style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        onPressed: () {},
                        child: Text(
                          "快捷锁仓",
                          style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        onPressed: () {},
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        child: Text(
                          "止盈止损",
                          style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                  ],
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
                    margin: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                    child: Scrollbar(
                      controller: scrollController,
                      style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                              width: 0.8.sw,
                              height: 168,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 1,
                                  // itemCount: data.length + 1,
                                  itemBuilder: (BuildContext context, int index) {
                                    // if (index == 0) {
                                    return Row(
                                      children: [
                                        Expanded(flex: 2, child: tableTitleItem("合约代码")),
                                        Expanded(flex: 1, child: tableTitleItem("买卖")),
                                        Expanded(flex: 1, child: tableTitleItem("数量")),
                                        Expanded(flex: 1, child: tableTitleItem("可平")),
                                        Expanded(flex: 2, child: tableTitleItem("开仓均价")),
                                        Expanded(flex: 2, child: tableTitleItem("计算价格")),
                                        Expanded(flex: 2, child: tableTitleItem("浮动盈亏")),
                                        Expanded(flex: 2, child: tableTitleItem("保证金占用")),
                                        Expanded(flex: 1, child: tableTitleItem("币种")),
                                        Expanded(flex: 3, child: tableTitleItem("合约名称")),
                                        Expanded(flex: 2, child: tableTitleItem("止盈止损")),
                                      ],
                                    );
                                    // }
                                    // else {
                                    //   return GestureDetector(
                                    //     child: Container(
                                    //       color: data[index - 1].selected
                                    //           ? Colors.black.withOpacity(0.2)
                                    //           : Colors.transparent,
                                    //       child: IntrinsicHeight(
                                    //           child: Row(
                                    //             crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //             children: [
                                    //               Expanded(flex: 1, child: tableItem(data[index - 1].OrderQty.toString())),
                                    //               Expanded(flex: 2, child: tableItem(data[index - 1].Account)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].SubmitResultsMsg)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].CreateAt)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].UpdateAt)),
                                    //               Expanded(flex: 2, child: buttonItem(data[index - 1].Id))
                                    //             ],
                                    //           )),
                                    //     ),
                                    //     onTap: () {
                                    //       // if (data[index - 1].selected == true) return;
                                    //       // for (var element in data) {
                                    //       //   element.selected = false;
                                    //       // }
                                    //       // data[index - 1].selected = true;
                                    //       // if (mounted) setState(() {});
                                    //     },
                                    //   );
                                    // }
                                  }))),
                    ),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    ));
  }

  Widget cloudConditionContent() {
    bool open = true;
    int num = 1;
    double price = 0.00;
    double boxWidth = 108;
    double boxHeight = 34;
    double padWidth = 12;
    List typeList = ["市价", "限价"];
    String type = "市价";
    List priceList = ["最新价", "买价", "卖价"];
    String selectedPrice = "最新价";
    List priceTypeList = [">=", "<="];
    String priceType = ">=";
    List validList = ["当日有效", "永久有效"];
    String valid = "当日有效";

    return Row(
      children: [
        SizedBox(
          width: 388,
          height: 500,
          child: StatefulBuilder(
            builder: (_, state) {
              return ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                      child: Text(
                        "云条件单",
                        style: TextStyle(color: Colors.yellow),
                      )),
                  Row(children: [
                    SizedBox(width: padWidth),
                    const Text("合约"),
                    Expanded(
                      child: Container(
                          height: boxHeight,
                          margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                          child: AutoSuggestBox(
                            controller: TextEditingController(text: logic.selectedContract.value.code),
                            items: logic.mContractList.map((e) {
                              return AutoSuggestBoxItem<String>(
                                value: e.code ?? "--",
                                label: e.code ?? "--",
                              );
                            }).toList(),
                            clearButtonEnabled: false,
                            onSelected: (item) {},
                          )),
                    ),
                    SizedBox(
                      width: padWidth,
                    ),
                    const Text("下单类型"),
                    Container(
                      height: boxHeight,
                      width: boxWidth,
                      margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: ComboBox<String>(
                        value: type,
                        isExpanded: true,
                        items: typeList.map((e) {
                          return ComboBoxItem<String>(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (v) => state(() => type = v!),
                      ),
                    ),
                    SizedBox(
                      width: padWidth,
                    ),
                  ]),
                  Row(children: [
                    SizedBox(width: padWidth),
                    const Text("委托价格"),
                    Expanded(
                        child: Container(
                      height: boxHeight,
                      margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: NumberBox(
                        value: price,
                        onChanged: (v) {},
                        smallChange: 0.1,
                        mode: SpinButtonPlacementMode.compact,
                      ),
                    )),
                    SizedBox(
                      width: padWidth,
                    ),
                    const Text("委托数量"),
                    Container(
                      height: boxHeight,
                      width: boxWidth,
                      margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: NumberBox(
                        value: num,
                        onChanged: (v) {},
                        mode: SpinButtonPlacementMode.compact,
                      ),
                    ),
                    SizedBox(
                      width: padWidth,
                    ),
                  ]),
                  Row(children: [
                    SizedBox(width: padWidth),
                    const Text("触发价格"),
                    Expanded(
                        child: Container(
                      height: boxHeight,
                      margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: ComboBox<String>(
                        value: selectedPrice,
                        isExpanded: true,
                        items: priceList.map((e) {
                          return ComboBoxItem<String>(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (v) => state(() => selectedPrice = v!),
                      ),
                    )),
                    Container(
                      height: boxHeight,
                      width: boxWidth * 0.6,
                      margin: EdgeInsets.fromLTRB(padWidth, 8, 0, 8),
                      child: ComboBox<String>(
                        value: priceType,
                        isExpanded: true,
                        items: priceTypeList.map((e) {
                          return ComboBoxItem<String>(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (v) => state(() => priceType = v!),
                      ),
                    ),
                    Container(
                      height: boxHeight,
                      width: boxWidth * 0.8,
                      margin: EdgeInsets.fromLTRB(padWidth, 8, 0, 8),
                      child: NumberBox(
                        value: price,
                        onChanged: (v) {},
                        mode: SpinButtonPlacementMode.compact,
                      ),
                    ),
                    SizedBox(
                      width: padWidth,
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: padWidth),
                      RadioButton(
                          checked: open,
                          onChanged: (checked) {
                            if (checked) {
                              state(() => open = checked);
                            }
                          }),
                      const Text("  开仓"),
                      const SizedBox(width: 28),
                      RadioButton(
                          checked: !open,
                          onChanged: (checked) {
                            if (checked) {
                              state(() => open = !checked);
                            }
                          }),
                      const Text("  平仓"),
                      Container(
                        height: boxHeight,
                        width: boxWidth,
                        margin: EdgeInsets.fromLTRB(padWidth, 0, padWidth, 0),
                        child: ComboBox<String>(
                          value: valid,
                          isExpanded: true,
                          items: validList.map((e) {
                            return ComboBoxItem<String>(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (v) => state(() => valid = v!),
                        ),
                      ),
                      Button(
                          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 5))),
                          onPressed: () {},
                          child: const Text("复位")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.red, borderRadius: const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  price.toString(),
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 135,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "买入",
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.green, borderRadius: const BorderRadius.all(Radius.circular(5))),
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: AutoSizeText(
                                  price.toString(),
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 135,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: AutoSizeText(
                                  "卖出",
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white, fontSize: 21),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget cloudConditionDetails() {
    ScrollController scrollController = ScrollController();
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(5),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        onPressed: () {},
                        child: Text(
                          "条件单修改",
                          style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                    const SizedBox(width: 15),
                    Button(
                        style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                        onPressed: () {},
                        child: Text(
                          "条件单删除",
                          style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                        )),
                  ],
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
                    margin: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                    child: Scrollbar(
                      controller: scrollController,
                      style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                              width: 0.8.sw,
                              // height: 168,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 1,
                                  // itemCount: data.length + 1,
                                  itemBuilder: (BuildContext context, int index) {
                                    // if (index == 0) {
                                    return Row(
                                      children: [
                                        Expanded(flex: 3, child: tableTitleItem("条件单编号")),
                                        Expanded(flex: 1, child: tableTitleItem("状态")),
                                        Expanded(flex: 3, child: tableTitleItem("条件")),
                                        Expanded(flex: 2, child: tableTitleItem("下单类型")),
                                        Expanded(flex: 2, child: tableTitleItem("下单价格")),
                                        Expanded(flex: 1, child: tableTitleItem("买卖")),
                                        Expanded(flex: 1, child: tableTitleItem("开平")),
                                        Expanded(flex: 1, child: tableTitleItem("数量")),
                                        Expanded(flex: 2, child: tableTitleItem("有效日期")),
                                        Expanded(flex: 3, child: tableTitleItem("备注")),
                                        Expanded(flex: 3, child: tableTitleItem("创建时间")),
                                        Expanded(flex: 3, child: tableTitleItem("触发时间")),
                                      ],
                                    );
                                    // }
                                    // else {
                                    //   return GestureDetector(
                                    //     child: Container(
                                    //       color: data[index - 1].selected
                                    //           ? Colors.black.withOpacity(0.2)
                                    //           : Colors.transparent,
                                    //       child: IntrinsicHeight(
                                    //           child: Row(
                                    //             crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //             children: [
                                    //               Expanded(flex: 1, child: tableItem(data[index - 1].OrderQty.toString())),
                                    //               Expanded(flex: 2, child: tableItem(data[index - 1].Account)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].SubmitResultsMsg)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].CreateAt)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].UpdateAt)),
                                    //               Expanded(flex: 2, child: buttonItem(data[index - 1].Id))
                                    //             ],
                                    //           )),
                                    //     ),
                                    //     onTap: () {
                                    //       // if (data[index - 1].selected == true) return;
                                    //       // for (var element in data) {
                                    //       //   element.selected = false;
                                    //       // }
                                    //       // data[index - 1].selected = true;
                                    //       // if (mounted) setState(() {});
                                    //     },
                                    //   );
                                    // }
                                  }))),
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    ));
  }

  Widget queryWidget() {
    int queryIndex = 0;
    DateTime startTime = DateTime.now();
    DateTime endTime = DateTime.now();
    TextEditingController startController = TextEditingController(text: formatter.format(startTime));
    TextEditingController endController = TextEditingController(text: formatter.format(endTime));
    ScrollController scrollController = ScrollController();
    return Expanded(
      child: StatefulBuilder(builder: (_, state) {
        return Row(
          children: [
            Container(
              width: 388,
              color: appTheme.commandBarColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: queryIndex == 0 ? Colors.yellow : Colors.transparent))),
                                child: Text(
                                  "资金状况",
                                  style: TextStyle(color: queryIndex == 0 ? Colors.yellow : appTheme.exchangeTextColor),
                                ),
                              ),
                              onTap: () => state(() => queryIndex = 0))),
                      Expanded(
                          child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: queryIndex == 1 ? Colors.yellow : Colors.transparent))),
                                child: Text(
                                  "历史成交",
                                  style: TextStyle(color: queryIndex == 1 ? Colors.yellow : appTheme.exchangeTextColor),
                                ),
                              ),
                              onTap: () => state(() => queryIndex = 1))),
                      Expanded(
                          child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: queryIndex == 2 ? Colors.yellow : Colors.transparent))),
                                child: Text(
                                  "结算单",
                                  style: TextStyle(color: queryIndex == 2 ? Colors.yellow : appTheme.exchangeTextColor),
                                ),
                              ),
                              onTap: () => state(() => queryIndex = 2))),
                      Expanded(
                          child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: queryIndex == 3 ? Colors.yellow : Colors.transparent))),
                                child: Text(
                                  "出入金",
                                  style: TextStyle(color: queryIndex == 3 ? Colors.yellow : appTheme.exchangeTextColor),
                                ),
                              ),
                              onTap: () => state(() => queryIndex = 3))),
                    ],
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("开始日期:", style: TextStyle(color: appTheme.exchangeTextColor, fontSize: 13)),
                      SizedBox(
                          width: 108,
                          child: TextBox(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(0), border: Border.all(color: Colors.yellow)),
                            controller: startController,
                            inputFormatters: [FilteringTextInputFormatter(RegExp("[0-9 -:]"), allow: true)],
                            suffix: IconButton(
                              icon: const Icon(FluentIcons.calendar),
                              style: ButtonStyle(padding: ButtonState.all(const EdgeInsets.only(right: 3))),
                              onPressed: () async {
                                await showOmniDateTimePicker(
                                  context: context,
                                  initialDate: startTime,
                                  type: OmniDateTimePickerType.date,
                                  borderRadius: BorderRadius.zero,
                                  constraints: const BoxConstraints(
                                    maxWidth: 350,
                                    maxHeight: 380,
                                  ),
                                  transitionDuration: const Duration(milliseconds: 200),
                                  barrierDismissible: true,
                                ).then((value) => {
                                      if (value != null) {startTime = value, startController.text = formatter.format(startTime), state(() {})}
                                    });
                              },
                            ),
                          )),
                      Text("结束日期:", style: TextStyle(color: appTheme.exchangeTextColor, fontSize: 13)),
                      SizedBox(
                          width: 108,
                          child: TextBox(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(0), border: Border.all(color: Colors.yellow)),
                            controller: endController,
                            inputFormatters: [FilteringTextInputFormatter(RegExp("[0-9 -:]"), allow: true)],
                            suffix: IconButton(
                              icon: const Icon(FluentIcons.calendar),
                              style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.only(right: 3))),
                              onPressed: () async {
                                await showOmniDateTimePicker(
                                  context: context,
                                  initialDate: endTime,
                                  type: OmniDateTimePickerType.date,
                                  borderRadius: BorderRadius.zero,
                                  constraints: const BoxConstraints(
                                    maxWidth: 350,
                                    maxHeight: 380,
                                  ),
                                  transitionDuration: const Duration(milliseconds: 200),
                                  barrierDismissible: true,
                                ).then((value) => {
                                      if (value != null) {endTime = value, endController.text = formatter.format(endTime), state(() {})}
                                    });
                              },
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 38,
                  ),
                  Button(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.yellow),
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 25)),
                          shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                      child: const Text(
                        "查询",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {})
                ],
              ),
            ),
            Expanded(
              child: queryIndex == 0 || queryIndex == 1
                  ? ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
                        child: Scrollbar(
                          controller: scrollController,
                          style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
                          child: SingleChildScrollView(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                  width: 0.8.sw,
                                  alignment: Alignment.topLeft,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: 1,
                                      // itemCount: data.length + 1,
                                      itemBuilder: (BuildContext context, int index) {
                                        // if (index == 0) {
                                        return Row(
                                          children: [
                                            Expanded(flex: 1, child: tableTitleItem("初期资金")),
                                            Expanded(flex: 1, child: tableTitleItem("期末资金")),
                                            Expanded(flex: 1, child: tableTitleItem("用户权益")),
                                            Expanded(flex: 1, child: tableTitleItem("可用资金")),
                                            Expanded(flex: 1, child: tableTitleItem("保证金占用")),
                                            Expanded(flex: 1, child: tableTitleItem("出入金")),
                                            Expanded(flex: 1, child: tableTitleItem("平仓盈亏")),
                                            Expanded(flex: 1, child: tableTitleItem("浮动盈亏")),
                                            Expanded(flex: 1, child: tableTitleItem("手续费")),
                                            Expanded(flex: 1, child: tableTitleItem("风险度")),
                                          ],
                                        );
                                        // }
                                        // else {
                                        //   return GestureDetector(
                                        //     child: Container(
                                        //       color: data[index - 1].selected
                                        //           ? Colors.black.withOpacity(0.2)
                                        //           : Colors.transparent,
                                        //       child: IntrinsicHeight(
                                        //           child: Row(
                                        //             crossAxisAlignment: CrossAxisAlignment.stretch,
                                        //             children: [
                                        //               Expanded(flex: 1, child: tableItem(data[index - 1].OrderQty.toString())),
                                        //               Expanded(flex: 2, child: tableItem(data[index - 1].Account)),
                                        //               Expanded(flex: 3, child: tableItem(data[index - 1].SubmitResultsMsg)),
                                        //               Expanded(flex: 3, child: tableItem(data[index - 1].CreateAt)),
                                        //               Expanded(flex: 3, child: tableItem(data[index - 1].UpdateAt)),
                                        //               Expanded(flex: 2, child: buttonItem(data[index - 1].Id))
                                        //             ],
                                        //           )),
                                        //     ),
                                        //     onTap: () {
                                        //       // if (data[index - 1].selected == true) return;
                                        //       // for (var element in data) {
                                        //       //   element.selected = false;
                                        //       // }
                                        //       // data[index - 1].selected = true;
                                        //       // if (mounted) setState(() {});
                                        //     },
                                        //   );
                                        // }
                                      }))),
                        ),
                      ),
                    )
                  : queryIndex == 2
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: RichText(
                                text: const TextSpan(children: [TextSpan(text: "账户："), TextSpan(text: "姓名："), TextSpan(text: "日期：")]),
                              ),
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Button(
                                    style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                        shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                                    onPressed: () {},
                                    child: Text(
                                      "资金状况",
                                      style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                                    )),
                                const SizedBox(width: 15),
                                Button(
                                    style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                        shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                                    onPressed: () {},
                                    child: Text(
                                      "成交记录",
                                      style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                                    )),
                                const SizedBox(width: 15),
                                Button(
                                    style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                        shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                                    onPressed: () {},
                                    child: Text(
                                      "平仓明细",
                                      style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                                    )),
                                const SizedBox(width: 15),
                                Button(
                                    style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                        shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                                    onPressed: () {},
                                    child: Text(
                                      "持仓明细",
                                      style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                                    )),
                                const SizedBox(width: 15),
                                Button(
                                    onPressed: () {},
                                    style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                                        shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                                    child: Text(
                                      "持仓汇总",
                                      style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                                    )),
                              ],
                            ),
                            Expanded(
                                child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, physics: const AlwaysScrollableScrollPhysics()),
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
                                child: Scrollbar(
                                  controller: scrollController,
                                  style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
                                  child: SingleChildScrollView(
                                      controller: scrollController,
                                      scrollDirection: Axis.horizontal,
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      child: Container(
                                          width: 0.8.sw,
                                          alignment: Alignment.topLeft,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: 1,
                                              // itemCount: data.length + 1,
                                              itemBuilder: (BuildContext context, int index) {
                                                // if (index == 0) {
                                                return Row(
                                                  children: [
                                                    Expanded(flex: 1, child: tableTitleItem("初期资金")),
                                                    Expanded(flex: 1, child: tableTitleItem("期末资金")),
                                                    Expanded(flex: 1, child: tableTitleItem("用户权益")),
                                                    Expanded(flex: 1, child: tableTitleItem("可用资金")),
                                                    Expanded(flex: 1, child: tableTitleItem("保证金占用")),
                                                    Expanded(flex: 1, child: tableTitleItem("出入金")),
                                                    Expanded(flex: 1, child: tableTitleItem("平仓盈亏")),
                                                    Expanded(flex: 1, child: tableTitleItem("浮动盈亏")),
                                                    Expanded(flex: 1, child: tableTitleItem("手续费")),
                                                    Expanded(flex: 1, child: tableTitleItem("风险度")),
                                                  ],
                                                );
                                                // }
                                                // else {
                                                //   return GestureDetector(
                                                //     child: Container(
                                                //       color: data[index - 1].selected
                                                //           ? Colors.black.withOpacity(0.2)
                                                //           : Colors.transparent,
                                                //       child: IntrinsicHeight(
                                                //           child: Row(
                                                //             crossAxisAlignment: CrossAxisAlignment.stretch,
                                                //             children: [
                                                //               Expanded(flex: 1, child: tableItem(data[index - 1].OrderQty.toString())),
                                                //               Expanded(flex: 2, child: tableItem(data[index - 1].Account)),
                                                //               Expanded(flex: 3, child: tableItem(data[index - 1].SubmitResultsMsg)),
                                                //               Expanded(flex: 3, child: tableItem(data[index - 1].CreateAt)),
                                                //               Expanded(flex: 3, child: tableItem(data[index - 1].UpdateAt)),
                                                //               Expanded(flex: 2, child: buttonItem(data[index - 1].Id))
                                                //             ],
                                                //           )),
                                                //     ),
                                                //     onTap: () {
                                                //       // if (data[index - 1].selected == true) return;
                                                //       // for (var element in data) {
                                                //       //   element.selected = false;
                                                //       // }
                                                //       // data[index - 1].selected = true;
                                                //       // if (mounted) setState(() {});
                                                //     },
                                                //   );
                                                // }
                                              }))),
                                ),
                              ),
                            )),
                          ],
                        )
                      : queryIndex == 3
                          ? Container(
                              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
                              alignment: Alignment.topLeft,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 1,
                                  // itemCount: data.length + 1,
                                  itemBuilder: (BuildContext context, int index) {
                                    // if (index == 0) {
                                    return Row(
                                      children: [
                                        Expanded(flex: 1, child: tableTitleItem("时间")),
                                        Expanded(flex: 2, child: tableTitleItem("入金")),
                                        Expanded(flex: 2, child: tableTitleItem("出金")),
                                      ],
                                    );
                                    // }
                                    // else {
                                    //   return GestureDetector(
                                    //     child: Container(
                                    //       color: data[index - 1].selected
                                    //           ? Colors.black.withOpacity(0.2)
                                    //           : Colors.transparent,
                                    //       child: IntrinsicHeight(
                                    //           child: Row(
                                    //             crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //             children: [
                                    //               Expanded(flex: 1, child: tableItem(data[index - 1].OrderQty.toString())),
                                    //               Expanded(flex: 2, child: tableItem(data[index - 1].Account)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].SubmitResultsMsg)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].CreateAt)),
                                    //               Expanded(flex: 3, child: tableItem(data[index - 1].UpdateAt)),
                                    //               Expanded(flex: 2, child: buttonItem(data[index - 1].Id))
                                    //             ],
                                    //           )),
                                    //     ),
                                    //     onTap: () {
                                    //       // if (data[index - 1].selected == true) return;
                                    //       // for (var element in data) {
                                    //       //   element.selected = false;
                                    //       // }
                                    //       // data[index - 1].selected = true;
                                    //       // if (mounted) setState(() {});
                                    //     },
                                    //   );
                                    // }
                                  }),
                            )
                          : Container(),
            )
          ],
        );
      }),
    );
  }

  Widget settingWidget() {
    int settingIndex = 0;
    int exchangeIndex = 0;
    List<Commodity> commodityList = Utils.getVariety(logic.mExchangeList[0].exchangeNo);
    return Expanded(
      child: StatefulBuilder(builder: (_, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(border: Border(right: BorderSide(width: 3, color: settingIndex == 0 ? Colors.yellow : Colors.transparent))),
                      child: Text(
                        "止盈止损",
                        style: TextStyle(color: settingIndex == 0 ? Colors.yellow : appTheme.exchangeTextColor),
                      ),
                    ),
                    onTap: () => state(() => settingIndex = 0)),
                GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(border: Border(right: BorderSide(width: 3, color: settingIndex == 1 ? Colors.yellow : Colors.transparent))),
                      child: Text(
                        "系统",
                        style: TextStyle(color: settingIndex == 1 ? Colors.yellow : appTheme.exchangeTextColor),
                      ),
                    ),
                    onTap: () => state(() => settingIndex = 1)),
              ],
            ),
            settingIndex == 0
                ? Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: logic.mExchangeList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 28),
                                    decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(width: 2, color: exchangeIndex == index ? Colors.yellow : Colors.transparent))),
                                    child: Text(
                                      logic.mExchangeList[index].exchangeNo ?? "--",
                                      style: TextStyle(color: exchangeIndex == index ? Colors.yellow : appTheme.exchangeTextColor),
                                    ),
                                  ),
                                  onTap: () => state(() {
                                    exchangeIndex = index;
                                    commodityList = Utils.getVariety(logic.mExchangeList[index].exchangeNo);
                                  }),
                                );
                              }),
                        ),
                        Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: commodityList.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  return Row(
                                    children: [
                                      Expanded(flex: 3, child: tableTitleItem("名称")),
                                      Expanded(flex: 3, child: tableTitleItem("代码")),
                                      Expanded(flex: 4, child: tableTitleItem("止损策略")),
                                      Expanded(flex: 4, child: tableTitleItem("有效期")),
                                      Expanded(flex: 3, child: tableTitleItem("跳价单位")),
                                      Expanded(flex: 3, child: tableTitleItem("止盈跳点数")),
                                      Expanded(flex: 3, child: tableTitleItem("止损跳点数")),
                                      Expanded(flex: 2, child: tableTitleItem("操作")),
                                    ],
                                  );
                                } else {
                                  return GestureDetector(
                                    child: Container(
                                      color: Colors.transparent,
                                      child: IntrinsicHeight(
                                          child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(flex: 3, child: tableTitleItem(commodityList[index - 1].shortName)),
                                          Expanded(flex: 3, child: tableTitleItem(commodityList[index - 1].commodityNo)),
                                          Expanded(flex: 4, child: tableRadioItem("限价", "追踪")),
                                          Expanded(flex: 4, child: tableRadioItem("当日", "永久")),
                                          Expanded(flex: 3, child: tableTitleItem(commodityList[index - 1].commodityTickSize?.toString())),
                                          Expanded(flex: 3, child: tablePointItem()),
                                          Expanded(flex: 3, child: tablePointItem()),
                                          Expanded(flex: 2, child: tableOperateItem(index)),
                                        ],
                                      )),
                                    ),
                                    onTap: () {},
                                  );
                                }
                              }),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        settingItem("是否提示下单确认", true),
                        settingItem("启动默认进入自选", false),
                        settingItem("是否显示精简模式", false),
                        settingItem("是否弹出交易弹窗", true),
                        settingItem("默认下单类型", true, yes: "限价", no: "市价"),
                        settingTypeItem("默认下单面板", 0, yes: "快手下单", no: "三键下单", or: "传统下单"),
                        settingNotItem("成交提示音", "系统提示音"),
                      ],
                    ),
                  ),
            Expanded(child: Container()),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 15, 0),
              child: Button(
                  style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 15))),
                  onPressed: () {},
                  child: const Text("保存")),
            )
          ],
        );
      }),
    );
  }

  Widget settingItem(String title, bool checked, {String? yes, String? no, String? or}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Text(title)),
          Expanded(child: RadioButton(checked: checked, content: Text(yes ?? "是"), onChanged: (v) {})),
          Expanded(child: RadioButton(checked: !checked, content: Text(no ?? "否"), onChanged: (v) {})),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Widget settingTypeItem(String title, int index, {String? yes, String? no, String? or}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Text(title)),
          Expanded(child: RadioButton(checked: index == 0, content: Text(yes ?? "是"), onChanged: (v) {})),
          Expanded(child: RadioButton(checked: index == 1, content: Text(no ?? "否"), onChanged: (v) {})),
          Expanded(child: RadioButton(checked: index == 2, content: Text(or ?? "或"), onChanged: (v) {})),
        ],
      ),
    );
  }

  Widget settingNotItem(String title, String content) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Text(title)),
          Expanded(child: RadioButton(checked: true, content: Text(content), onChanged: (v) {})),
          Expanded(flex: 2, child: Container()),
        ],
      ),
    );
  }
}
