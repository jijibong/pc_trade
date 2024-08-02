import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:trade/page/quote/quote_logic.dart';
import 'package:trade/util/event_bus/events.dart';

import '../../config/common.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/theme/theme.dart';

class QuoteData extends StatefulWidget {
  const QuoteData({super.key});

  @override
  State<QuoteData> createState() => _QuoteDataState();
}

class _QuoteDataState extends State<QuoteData> {
  MultiSplitViewController controller = MultiSplitViewController();
  final QuoteLogic logic = Get.put(QuoteLogic());
  late AppTheme appTheme;
  Axis axis = Axis.vertical;

  @override
  void initState() {
    super.initState();
    controller.addArea(Area(builder: (context, area) => item()));
    logic.loadData();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: item()),
        SizedBox(
            height: 35,
            child: Obx(() {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: logic.mExchangeList.length,
                // shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      logic.switchExchange(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: logic.mExchangeList[index] == logic.selectedExchange.value ? appTheme.exchangeBgColor : Colors.transparent,
                      child: Text(
                        logic.mExchangeList[index].exchangeName ?? "",
                        style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
                      ),
                    ),
                  );
                },
              );
            })),
      ],
    );
  }

  Widget item() {
    final ScrollController scrollController = ScrollController();
    final ScrollController verScrollController = ScrollController();
    // MultiSplitViewController multiSplitcontroller = MultiSplitViewController();
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
        //             axis = Axis.vertical;
        //             controller.addArea(Area(builder: (context, area) => const EmptyView()));
        //             if (mounted) setState(() {});
        //           }),
        //       MenuAction(
        //           title: '纵向分页',
        //           callback: () {
        //             axis = Axis.horizontal;
        //             controller.addArea(Area(builder: (context, area) => const EmptyView()));
        //             if (mounted) setState(() {});
        //           }),
        //       MenuAction(
        //           title: '关闭窗口',
        //           callback: () {
        //             logger.i(controller.areasCount);
        //             controller.removeAreaAt(controller.areasCount - 1);
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
                      itemCount: logic.mContractList.length,
                      shrinkWrap: true,
                      controller: verScrollController,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: Container(
                              height: 35,
                              color: logic.selectedContract.value == logic.mContractList[index] ? appTheme.commandBarColor : Colors.transparent,
                              child: Row(
                                children: [
                                  contentItem((index + 1).toString()),
                                  contentItem(logic.mContractList[index].name, flex: 1.4),
                                  contentItem(logic.mContractList[index].lastPriceString),
                                  contentItem(logic.mContractList[index].buyPriceString),
                                  contentItem(logic.mContractList[index].salePriceString),
                                  contentItem("${logic.mContractList[index].delegateBuy ?? 0}"),
                                  contentItem("${logic.mContractList[index].delegateSale ?? 0}"),
                                  contentItem("${logic.mContractList[index].volume ?? 0}", flex: 1.2),
                                  contentItem("${logic.mContractList[index].position ?? 0}", flex: 1.2),
                                  contentItem(logic.mContractList[index].changeString),
                                  contentItem("${logic.mContractList[index].preSettlePrice ?? 0}", flex: 1.2),
                                  contentItem("${logic.mContractList[index].openPrice ?? 0}"),
                                  contentItem(logic.mContractList[index].high),
                                  contentItem(logic.mContractList[index].low),
                                  contentItem(logic.mContractList[index].changePerString, flex: 1.2),
                                  contentItem(
                                      logic.mContractList[index].timeStr != null && logic.mContractList[index].timeStr!.length > 19
                                          ? logic.mContractList[index].timeStr!.substring(10, 19)
                                          : "--",
                                      flex: 1.5),
                                  contentItem(logic.mContractList[index].code, flex: 1.4),
                                ],
                              )),
                          onTap: () {
                            logic.selectedContract.value = logic.mContractList[index];
                          },
                          onDoubleTap: () {
                            logic.selectedContract.value = logic.mContractList[index];
                            EventBusUtil.getInstance().fire(GoKChart(true));
                          },
                        );
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

  Widget contentItem(String? title, {double? flex}) {
    return Container(
      width: 85 * (flex ?? 1),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      child: AutoSizeText(
        title ?? "--",
        maxLines: 1,
        maxFontSize: 17,
        stepGranularity: 1,
        style: TextStyle(color: appTheme.color, fontSize: 17),
      ),
    );
  }
}
