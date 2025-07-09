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
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/theme/theme.dart';

class QuoteData extends StatefulWidget {
  final int index;
  const QuoteData(this.index, {super.key});

  @override
  State<QuoteData> createState() => _QuoteDataState();
}

class _QuoteDataState extends State<QuoteData> {
  final QuoteLogic logic = Get.put(QuoteLogic());
  late AppTheme appTheme;
  final ScrollController scrollController = ScrollController();
  final ScrollController verScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.index == 0) {
      logic.loadData(0);
      logic.setListener();
    }
    logic.setAllListener();
    logic.queryOption();
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
                      itemCount:
                          appTheme.selectIndex[widget.index] == 1 ? logic.selectedMContractList[widget.index].length : logic.mOptionalList.length,
                      shrinkWrap: true,
                      controller: verScrollController,
                      itemBuilder: (context, index) {
                        if (appTheme.selectIndex[widget.index] == 0) {
                          final contextController = FlyoutController();
                          return Listener(
                            child: GestureDetector(
                              child: FlyoutTarget(
                                controller: contextController,
                                child: Container(
                                  height: 35,
                                  color: logic.selectedContractList[widget.index] == logic.mOptionalList[index]
                                      ? appTheme.commandBarColor
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      contentItem((index + 1).toString()),
                                      contentItem(logic.mOptionalList[index].name, flex: 1.4),
                                      contentItem(logic.mOptionalList[index].lastPriceString, color: logic.mOptionalList[index].lastPriceColor),
                                      contentItem(logic.mOptionalList[index].buyPriceString, color: logic.mOptionalList[index].buyPriceColor),
                                      contentItem(logic.mOptionalList[index].salePriceString, color: logic.mOptionalList[index].salePriceColor),
                                      contentItem("${(logic.mOptionalList[index].delegateBuy ?? 0).toInt()}",
                                          color: logic.mOptionalList[index].delegateBuyColor),
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
                                      contentItem(logic.mOptionalList[index].changePerString,
                                          flex: 1.2, color: logic.mOptionalList[index].changeColor),
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
                              onSecondaryTapUp: (d) {
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
                                        MenuFlyoutItem(
                                          text: Text(appTheme.multiScreen ? '取消分屏' : '添加分屏'),
                                          onPressed: () async {
                                            // await rustDeskWinManager.newSubWindows("subWindow");
                                            appTheme.multiScreen = !appTheme.multiScreen;
                                          },
                                        ),
                                      ]);
                                    });
                              },
                              onDoubleTap: () {
                                EventBusUtil.getInstance().fire(GoKChart(true, widget.index));
                              },
                            ),
                            onPointerDown: (e) {
                              logic.selectedContractList[widget.index] = logic.mOptionalList[index];
                              EventBusUtil.getInstance().fire(SwitchContract(logic.selectedContractList[widget.index]));
                              if (mounted) setState(() {}); //提升选中速度
                            },
                          );
                        } else {
                          final contextController = FlyoutController();
                          return Listener(
                            child: GestureDetector(
                              onSecondaryTapUp: (d) {
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
                                            logic.optionOperate(logic.selectedContractList[widget.index], add: true);
                                            Flyout.of(context).close();
                                          },
                                        ),
                                        MenuFlyoutItem(
                                          text: const Text('移除自选'),
                                          onPressed: () {
                                            logic.optionOperate(logic.selectedContractList[widget.index], add: false);
                                            Flyout.of(context).close();
                                          },
                                        ),
                                        MenuFlyoutItem(
                                          text: Text(appTheme.multiScreen ? '取消分屏' : '添加分屏'),
                                          onPressed: () async {
                                            appTheme.multiScreen = !appTheme.multiScreen;
                                            // await rustDeskWinManager.newSubWindows("subWindow");
                                          },
                                        ),
                                      ]);
                                    });
                              },
                              onDoubleTap: () {
                                EventBusUtil.getInstance().fire(GoKChart(true, widget.index));
                              },
                              child: FlyoutTarget(
                                  controller: contextController,
                                  child: Container(
                                      height: 35,
                                      color: logic.selectedContractList[widget.index] == logic.selectedMContractList[widget.index][index]
                                          ? appTheme.commandBarColor
                                          : Colors.transparent,
                                      child: Row(
                                        children: [
                                          contentItem((index + 1).toString()),
                                          contentItem(logic.selectedMContractList[widget.index][index].name, flex: 1.4),
                                          contentItem(logic.selectedMContractList[widget.index][index].lastPriceString,
                                              color: logic.selectedMContractList[widget.index][index].lastPriceColor),
                                          contentItem(logic.selectedMContractList[widget.index][index].buyPriceString,
                                              color: logic.selectedMContractList[widget.index][index].buyPriceColor),
                                          contentItem(logic.selectedMContractList[widget.index][index].salePriceString,
                                              color: logic.selectedMContractList[widget.index][index].salePriceColor),
                                          contentItem(
                                              "${(logic.selectedMContractList[widget.index][index].delegateBuy != null ? logic.selectedMContractList[widget.index][index].delegateBuy!.toInt() : "--")}",
                                              color: logic.selectedMContractList[widget.index][index].delegateBuyColor),
                                          contentItem(
                                              "${(logic.selectedMContractList[widget.index][index].delegateSale != null ? logic.selectedMContractList[widget.index][index].delegateSale!.toInt() : "--")}",
                                              color: logic.selectedMContractList[widget.index][index].delegateSaleColor),
                                          contentItem(
                                              "${(logic.selectedMContractList[widget.index][index].volume != null ? logic.selectedMContractList[widget.index][index].volume!.toInt() : "--")}",
                                              flex: 1.2,
                                              color: logic.selectedMContractList[widget.index][index].volumeColor),
                                          contentItem(
                                              "${(logic.selectedMContractList[widget.index][index].position != null ? logic.selectedMContractList[widget.index][index].position!.toInt() : "--")}",
                                              flex: 1.2,
                                              color: logic.selectedMContractList[widget.index][index].positionColor),
                                          contentItem(logic.selectedMContractList[widget.index][index].changeString,
                                              color: logic.selectedMContractList[widget.index][index].changeColor),
                                          contentItem("${logic.selectedMContractList[widget.index][index].preSettlePrice ?? "--"}",
                                              flex: 1.2, color: appTheme.color),
                                          contentItem("${logic.selectedMContractList[widget.index][index].openPrice ?? "--"}",
                                              color: logic.selectedMContractList[widget.index][index].openColor),
                                          contentItem(logic.selectedMContractList[widget.index][index].high,
                                              color: logic.selectedMContractList[widget.index][index].highColor),
                                          contentItem(logic.selectedMContractList[widget.index][index].low,
                                              color: logic.selectedMContractList[widget.index][index].lowColor),
                                          contentItem(logic.selectedMContractList[widget.index][index].changePerString,
                                              flex: 1.2, color: logic.selectedMContractList[widget.index][index].changeColor),
                                          contentItem(
                                              logic.selectedMContractList[widget.index][index].timeStr != null &&
                                                      logic.selectedMContractList[widget.index][index].timeStr!.length > 19
                                                  ? logic.selectedMContractList[widget.index][index].timeStr!.substring(10, 19)
                                                  : "--",
                                              flex: 1.5),
                                          contentItem(logic.selectedMContractList[widget.index][index].code, flex: 1.4),
                                        ],
                                      ))),
                            ),
                            onPointerDown: (e) {
                              logic.selectedContractList[widget.index] = logic.selectedMContractList[widget.index][index];
                              EventBusUtil.getInstance().fire(SwitchContract(logic.selectedContractList[widget.index]));
                              if (mounted) setState(() {}); //提升选中速度
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
