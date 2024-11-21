import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:trade/page/quote/quote_logic.dart';
import 'package:trade/util/event_bus/events.dart';

import '../../config/common.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/theme/theme.dart';

class QuoteDatas extends StatefulWidget {
  const QuoteDatas({super.key});

  @override
  State<QuoteDatas> createState() => _QuoteDatasState();
}

class _QuoteDatasState extends State<QuoteDatas> {
  final QuoteLogic logic = Get.put(QuoteLogic());
  late AppTheme appTheme;
  final ScrollController scrollController = ScrollController();
  final ScrollController verScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    logic.loadData();
    logic.queryOption();
    logic.setListener();
    logic.quoteEvent();
    logic.optionEvent();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appTheme = context.watch<AppTheme>();
    return Scrollbar(
      controller: scrollController,
      style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        // child: ContextMenuWidget(
        //   menuProvider: (_) {
        //     return Menu(children: [
        //       MenuAction(
        //           title: '横向分页',
        //           callback: () {
        //             // axis = Axis.vertical;
        //             // controller.addArea(Area(builder: (context, area) => const EmptyView()));
        //             if (mounted) setState(() {});
        //           }),
        //       MenuAction(
        //           title: '纵向分页',
        //           callback: () {
        //             // axis = Axis.horizontal;
        //             // controller.addArea(Area(builder: (context, area) => const EmptyView()));
        //             if (mounted) setState(() {});
        //           }),
        //       MenuAction(
        //           title: '关闭窗口',
        //           callback: () {
        //             // logger.i(controller.areasCount);
        //             // controller.removeAreaAt(controller.areasCount - 1);
        //             if (mounted) setState(() {});
        //           }),
        //     ]);
        //   },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 35,
            width: max(1630, 1.sw - Common.optionWidgetWidth),
            child: Row(
              children: [
                titleItem('序↓'),
                titleItem('合约名称', flex: 1.4),
                titleItem('最新'),
                titleItem('买价'),
                titleItem('卖价'),
                titleItem('买量'),
                titleItem('卖量'),
                titleItem('成交量', flex: 1.2),
                titleItem('持仓量', flex: 1.2),
                titleItem('涨跌'),
                titleItem('昨结算', flex: 1.2),
                titleItem('开盘'),
                titleItem('最高'),
                titleItem('最低'),
                titleItem('涨幅%', flex: 1.2),
                titleItem('时间', flex: 1.5),
                titleItem('合约代码', flex: 1.4),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: max(1630, 1.sw - Common.optionWidgetWidth),
              child: Obx(() {
                return Scrollbar(
                  controller: verScrollController,
                  style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
                  child: ListView.builder(
                      itemCount: appTheme.selectIndex == 1 ? logic.mContractList.length : logic.mOptionalList.length,
                      shrinkWrap: true,
                      controller: verScrollController,
                      itemBuilder: (context, index) {
                        if (appTheme.selectIndex == 0) {
                          final contextController = FlyoutController();
                          return GestureDetector(
                            child: FlyoutTarget(
                              controller: contextController,
                              child: Container(
                                height: 35,
                                color: logic.selectedContract.value == logic.mOptionalList[index] ? appTheme.commandBarColor : Colors.transparent,
                                child: Row(
                                  children: [
                                    contentItem((index + 1).toString()),
                                    contentItem(logic.mOptionalList[index].name, flex: 1.4),
                                    contentItem(logic.mOptionalList[index].lastPriceString, color: logic.mOptionalList[index].lastPriceColor),
                                    contentItem(logic.mOptionalList[index].buyPriceString, color: logic.mOptionalList[index].buyPriceColor),
                                    contentItem(logic.mOptionalList[index].salePriceString, color: logic.mOptionalList[index].salePriceColor),
                                    contentItem("${(logic.mOptionalList[index].delegateBuy ?? 0).toInt()}", color: logic.mOptionalList[index].delegateBuyColor),
                                    contentItem("${(logic.mOptionalList[index].delegateSale ?? 0).toInt()}",
                                        color: logic.mOptionalList[index].delegateSaleColor),
                                    contentItem("${(logic.mOptionalList[index].volume ?? 0).toInt()}",
                                        flex: 1.2, color: logic.mOptionalList[index].volumeColor),
                                    contentItem("${(logic.mOptionalList[index].position ?? 0).toInt()}",
                                        flex: 1.2, color: logic.mOptionalList[index].positionColor),
                                    contentItem(logic.mOptionalList[index].changeString, color: logic.mOptionalList[index].changeColor),
                                    contentItem("${logic.mOptionalList[index].preSettlePrice ?? 0}", flex: 1.2),
                                    contentItem("${logic.mOptionalList[index].openPrice ?? 0}", color: logic.mOptionalList[index].openColor),
                                    contentItem(logic.mOptionalList[index].high, color: logic.mOptionalList[index].highColor),
                                    contentItem(logic.mOptionalList[index].low, color: logic.mOptionalList[index].lowColor),
                                    contentItem(logic.mOptionalList[index].changePerString, flex: 1.2, color: logic.mOptionalList[index].changeColor),
                                    contentItem(
                                        logic.mOptionalList[index].timeStr != null && logic.mOptionalList[index].timeStr!.length > 19
                                            ? logic.mOptionalList[index].timeStr!.substring(10, 19)
                                            : "--",
                                        flex: 1.5),
                                    contentItem(logic.mOptionalList[index].code, flex: 1.4),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              logic.selectedContract.value = logic.mOptionalList[index];
                              EventBusUtil.getInstance().fire(SwitchContract(logic.selectedContract.value));
                            },
                            onSecondaryTapUp: (d) {
                              logic.selectedContract.value = logic.mOptionalList[index];
                              EventBusUtil.getInstance().fire(SwitchContract(logic.selectedContract.value));
                              contextController.showFlyout(
                                  barrierColor: Colors.black.withOpacity(0.1),
                                  position: d.globalPosition,
                                  builder: (context) {
                                    return MenuFlyout(items: [
                                      MenuFlyoutItem(
                                        text: const Text('下单'),
                                        onPressed: () {
                                          EventBusUtil.getInstance().fire(LoginEvent());
                                          Flyout.of(context).close();
                                        },
                                      ),
                                      MenuFlyoutItem(
                                        text: const Text('移除自选'),
                                        onPressed: () {
                                          logic.delOption(logic.mOptionalList[index]);
                                          Flyout.of(context).close();
                                        },
                                      ),
                                    ]);
                                  });
                            },
                            onDoubleTap: () {
                              logic.selectedContract.value = logic.mOptionalList[index];
                              EventBusUtil.getInstance().fire(SwitchContract(logic.selectedContract.value));
                              EventBusUtil.getInstance().fire(GoKChart(true));
                            },
                          );
                        } else {
                          final contextController = FlyoutController();
                          return GestureDetector(
                            child: FlyoutTarget(
                                controller: contextController,
                                child: Container(
                                    height: 35,
                                    color: logic.selectedContract.value == logic.mContractList[index] ? appTheme.commandBarColor : Colors.transparent,
                                    child: Row(
                                      children: [
                                        contentItem((index + 1).toString()),
                                        contentItem(logic.mContractList[index].name, flex: 1.4),
                                        contentItem(logic.mContractList[index].lastPriceString, color: logic.mContractList[index].lastPriceColor),
                                        contentItem(logic.mContractList[index].buyPriceString, color: logic.mContractList[index].buyPriceColor),
                                        contentItem(logic.mContractList[index].salePriceString, color: logic.mContractList[index].salePriceColor),
                                        contentItem(
                                            "${(logic.mContractList[index].delegateBuy != null ? logic.mContractList[index].delegateBuy!.toInt() : "--")}",
                                            color: logic.mContractList[index].delegateBuyColor),
                                        contentItem(
                                            "${(logic.mContractList[index].delegateSale != null ? logic.mContractList[index].delegateSale!.toInt() : "--")}",
                                            color: logic.mContractList[index].delegateSaleColor),
                                        contentItem("${(logic.mContractList[index].volume != null ? logic.mContractList[index].volume!.toInt() : "--")}",
                                            flex: 1.2, color: logic.mContractList[index].volumeColor),
                                        contentItem("${(logic.mContractList[index].position != null ? logic.mContractList[index].position!.toInt() : "--")}",
                                            flex: 1.2, color: logic.mContractList[index].positionColor),
                                        contentItem(logic.mContractList[index].changeString, color: logic.mContractList[index].changeColor),
                                        contentItem("${logic.mContractList[index].preSettlePrice ?? "--"}", flex: 1.2, color: appTheme.color),
                                        contentItem("${logic.mContractList[index].openPrice ?? "--"}", color: logic.mContractList[index].openColor),
                                        contentItem(logic.mContractList[index].high, color: logic.mContractList[index].highColor),
                                        contentItem(logic.mContractList[index].low, color: logic.mContractList[index].lowColor),
                                        contentItem(logic.mContractList[index].changePerString, flex: 1.2, color: logic.mContractList[index].changeColor),
                                        contentItem(
                                            logic.mContractList[index].timeStr != null && logic.mContractList[index].timeStr!.length > 19
                                                ? logic.mContractList[index].timeStr!.substring(10, 19)
                                                : "--",
                                            flex: 1.5),
                                        contentItem(logic.mContractList[index].code, flex: 1.4),
                                      ],
                                    ))),
                            onTap: () async {
                              logic.selectedContract.value = logic.mContractList[index];
                              EventBusUtil.getInstance().fire(SwitchContract(logic.selectedContract.value));
                            },
                            onSecondaryTapUp: (d) {
                              logic.selectedContract.value = logic.mContractList[index];
                              EventBusUtil.getInstance().fire(SwitchContract(logic.selectedContract.value));
                              contextController.showFlyout(
                                  barrierColor: Colors.black.withOpacity(0.1),
                                  position: d.globalPosition,
                                  builder: (context) {
                                    return MenuFlyout(items: [
                                      MenuFlyoutItem(
                                        text: const Text('下单'),
                                        onPressed: () {
                                          EventBusUtil.getInstance().fire(LoginEvent());
                                          Flyout.of(context).close();
                                        },
                                      ),
                                      MenuFlyoutItem(
                                        text: const Text('加入自选'),
                                        onPressed: () {
                                          logic.optionOperate(logic.selectedContract.value, add: true);
                                          Flyout.of(context).close();
                                        },
                                      ),
                                      MenuFlyoutItem(
                                        text: const Text('移除自选'),
                                        onPressed: () {
                                          logic.optionOperate(logic.selectedContract.value, add: false);
                                          Flyout.of(context).close();
                                        },
                                      ),
                                    ]);
                                  });
                            },
                            onDoubleTap: () {
                              logic.selectedContract.value = logic.mContractList[index];
                              EventBusUtil.getInstance().fire(SwitchContract(logic.selectedContract.value));
                              EventBusUtil.getInstance().fire(GoKChart(true));
                            },
                          );
                        }
                      }),
                );
              }),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ]),
        // ),
      ),
    );
  }

  Widget titleItem(String? title, {double? flex}) {
    return Container(
      width: 85 * (flex ?? 1),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      child: AutoSizeText(
        title ?? "--",
        maxLines: 1,
        maxFontSize: 18,
        stepGranularity: 1,
        style: TextStyle(color: Common.quoteTitleColor, fontSize: 18),
      ),
    );
  }

  Widget contentItem(String? title, {double? flex, Color? color}) {
    return Container(
      width: 85 * (flex ?? 1),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      child: AutoSizeText(
        title ?? "--",
        maxLines: 1,
        maxFontSize: 17,
        stepGranularity: 1,
        style: TextStyle(color: color ?? appTheme.color, fontSize: 17),
      ),
    );
  }
}
