import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trade/model/quote/contract.dart';
import 'package:trade/page/quote/quote_logic.dart';
import 'package:trade/util/event_bus/events.dart';
import 'package:trade/util/utils/market_util.dart';

import '../../config/common.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/log/log.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
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
  final ScrollController verScrollController = ScrollController();
  final AutoScrollController scrollController = AutoScrollController();
  List<int> order = List.generate(17, (i) => i);
  List<String> titleList = ['序↓', '合约名称', '最新', '买价', '卖价', '买量', '卖量', '成交量', '持仓量', '涨跌', '昨结算', '开盘', '最高', '最低', '涨幅%', '时间', '合约代码'];

  listener() {
    ///跳转指定品种
    EventBusUtil.getInstance().on<RefreshCommodity>().listen((event) async {
      scrollController.scrollToIndex(
        event.index,
        duration: const Duration(milliseconds: 500),
        preferPosition: AutoScrollPosition.begin,
      );
    });
  }

  List<Widget> getList(Contract contract, int index) {
    return [
      contentItem((index + 1).toString()),
      contentItem(contract.name, flex: 1.4),
      contentItem(contract.lastPriceString, color: contract.lastPriceColor),
      contentItem(contract.buyPriceString, color: contract.buyPriceColor),
      contentItem(contract.salePriceString, color: contract.salePriceColor),
      contentItem("${(contract.delegateBuy ?? 0).toInt()}", color: contract.delegateBuyColor),
      contentItem("${(contract.delegateSale ?? 0).toInt()}", color: contract.delegateSaleColor),
      contentItem("${(contract.volume ?? 0).toInt()}", flex: 1.2, color: contract.volumeColor),
      contentItem("${(contract.position ?? 0).toInt()}", flex: 1.2, color: contract.positionColor),
      contentItem(contract.changeString, color: contract.changeColor),
      contentItem("${contract.preSettlePrice ?? 0}", flex: 1.2),
      contentItem("${contract.openPrice ?? 0}", color: contract.openColor),
      contentItem(contract.high, color: contract.highColor),
      contentItem(contract.low, color: contract.lowColor),
      contentItem(contract.changePerString, flex: 1.2, color: contract.changeColor),
      contentItem(contract.timeStr != null && contract.timeStr!.length > 19 ? contract.timeStr!.substring(10, 19) : "--", flex: 1.5),
      contentItem(contract.code, flex: 1.4),
    ];
  }

  @override
  void initState() {
    super.initState();
    if (MarketUtils.order.isNotEmpty) order = MarketUtils.order;
    if (widget.index == 0) {
      logic.loadData();
      logic.setListener();
    }
    logic.setAllListener();
    listener();
    logic.quoteEvent();
    logic.optionEvent();
  }

  @override
  void dispose() {
    super.dispose();
    logic.destroy();
  }

  @override
  Widget build(BuildContext context) {
    appTheme = context.watch<AppTheme>();
    return Scrollbar(
      controller: verScrollController,
      style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: verScrollController,
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
            child: ReorderableListView(
              buildDefaultDragHandles: false,
              scrollDirection: Axis.horizontal,
              proxyDecorator: (child, index, animation) {
                return Container(
                  color: Colors.transparent,
                  child: child,
                );
              },
              children: [for (int i = 0; i < order.length; i++) titleItem(titleList[order[i]], i)],
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex--;
                  final item = order.removeAt(oldIndex);
                  order.insert(newIndex, item);
                  MarketUtils.order = order;
                });
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              width: max(1630, 1.sw - Common.optionWidgetWidth),
              child: Obx(() {
                return ReorderableListView.builder(
                  itemCount: appTheme.selectIndex == 1 ? logic.selectedMContractList[widget.index].length : logic.homePageList[widget.index].length,
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  scrollController: scrollController,
                  proxyDecorator: (child, index, animation) {
                    return Container(
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    if (appTheme.selectIndex == 0) {
                      final contextController = FlyoutController();
                      return ReorderableDragStartListener(
                          key: Key('$index'),
                          index: index,
                          child: Listener(
                            child: GestureDetector(
                              child: FlyoutTarget(
                                controller: contextController,
                                child: Container(
                                  height: 35,
                                  color: logic.selectedContractList[widget.index] == logic.homePageList[widget.index][index]
                                      ? appTheme.commandBarColor
                                      : Colors.transparent,
                                  child: Row(children: order.map((i) => getList(logic.homePageList[widget.index][index], index)[i]).toList()),
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
                                            logic.optionOperate(logic.homePageList[widget.index][index], false);
                                            Flyout.of(context).close();
                                          },
                                        ),
                                        MenuFlyoutItem(
                                          text: const Text('取消分屏'),
                                          onPressed: () async {
                                            appTheme.multiScreen = 1;
                                          },
                                        ),
                                        MenuFlyoutItem(
                                          text: const Text('二分屏'),
                                          onPressed: () async {
                                            appTheme.multiScreen = 2;
                                            EventBusUtil.getInstance().fire(SplitScreen(2));
                                          },
                                        ),
                                        MenuFlyoutItem(
                                          text: const Text('四分屏'),
                                          onPressed: () async {
                                            appTheme.multiScreen = 4;
                                            EventBusUtil.getInstance().fire(SplitScreen(4));
                                          },
                                        ),
                                        MenuFlyoutItem(
                                          text: const Text('六分屏'),
                                          onPressed: () async {
                                            appTheme.multiScreen = 6;
                                            EventBusUtil.getInstance().fire(SplitScreen(6));
                                          },
                                        ),
                                        MenuFlyoutItem(
                                          text: const Text('九分屏'),
                                          onPressed: () async {
                                            appTheme.multiScreen = 9;
                                            EventBusUtil.getInstance().fire(SplitScreen(9));
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
                              logic.selectedContractList[widget.index] = logic.homePageList[widget.index][index];
                              EventBusUtil.getInstance().fire(SwitchContract(widget.index, logic.selectedContractList[widget.index]));
                              if (mounted) setState(() {}); //提升选中速度
                            },
                          ));
                    } else {
                      final contextController = FlyoutController();
                      return ReorderableDragStartListener(
                          key: Key('$index'),
                          index: index,
                          child: AutoScrollTag(
                              key: Key('AutoScrollTag$index'),
                              controller: scrollController,
                              index: index,
                              child: Listener(
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
                                            // MenuFlyoutItem(
                                            //   text: const Text('加入自选'),
                                            //   onPressed: () {
                                            //     logic.optionOperate(logic.selectedContractList[widget.index], add: true);
                                            //     Flyout.of(context).close();
                                            //   },
                                            // ),
                                            MenuFlyoutSubItem(
                                                text: const Text('加入自选'),
                                                leading: const Icon(
                                                  FluentIcons.accept,
                                                  color: Colors.transparent,
                                                ),
                                                items: (context) => logic.sectorList
                                                    .map((e) => MenuFlyoutItem(
                                                          text: Text(e.name ?? "--"),
                                                          onPressed: () {
                                                            EventBusUtil.getInstance()
                                                                .fire(AddOptionEvent(e, logic.selectedContractList[widget.index], true));
                                                          },
                                                        ))
                                                    .toList()),
                                            // MenuFlyoutItem(
                                            //   text: const Text('取消分屏'),
                                            //   onPressed: () async {
                                            //     appTheme.multiScreen = 0;
                                            //   },
                                            // ),
                                            // MenuFlyoutItem(
                                            //   text: const Text('四分屏'),
                                            //   onPressed: () async {
                                            //     appTheme.multiScreen = 1;
                                            //     EventBusUtil.getInstance().fire(SplitScreen(1));
                                            //   },
                                            // ),
                                            // MenuFlyoutItem(
                                            //   text: const Text('九分屏'),
                                            //   onPressed: () async {
                                            //     appTheme.multiScreen = 2;
                                            //     EventBusUtil.getInstance().fire(SplitScreen(2));
                                            //   },
                                            // ),
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
                                            children: order.map((i) => getList(logic.selectedMContractList[widget.index][index], index)[i]).toList()),
                                      )),
                                ),
                                onPointerDown: (e) {
                                  logic.selectedContractList[widget.index] = logic.selectedMContractList[widget.index][index];
                                  EventBusUtil.getInstance().fire(SwitchContract(widget.index, logic.selectedContractList[widget.index]));
                                  if (mounted) setState(() {}); //提升选中速度
                                },
                              )));
                    }
                  },
                  onReorder: (int oldIndex, int newIndex) async {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    if (appTheme.selectIndex == 0) {
                      logic.homePageList[widget.index].insert(newIndex, logic.homePageList[widget.index].removeAt(oldIndex));
                      EventBusUtil.getInstance().fire(UpdateOptionEvent());
                    } else {
                      var tmp = logic.selectedMContractList[widget.index].removeAt(oldIndex);
                      logic.selectedMContractList[widget.index].insert(newIndex, tmp);
                    }
                  },
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

  Widget titleItem(String? title, int i) {
    return ReorderableDragStartListener(
      key: Key('$i'),
      index: i,
      child: Container(
        width: 85 *
            (title == '合约名称' || title == '合约代码'
                ? 1.4
                : title == '时间'
                    ? 1.5
                    : title == '成交量' || title == '持仓量' || title == '昨结算' || title == '涨幅%'
                        ? 1.2
                        : 1),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        child: AutoSizeText(
          title ?? "--",
          maxLines: 1,
          maxFontSize: 17,
          stepGranularity: 1,
          textAlign: TextAlign.center,
          style: TextStyle(color: Common.quoteTitleColor, fontSize: 17),
        ),
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
        textAlign: TextAlign.center,
        style: TextStyle(color: color ?? appTheme.color, fontSize: 17),
      ),
    );
  }
}
