import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:trade/page/quote/quote_data.dart';
import 'package:trade/page/quote/quote_details/quote_details.dart';
import 'package:trade/page/quote/quote_logic.dart';
import 'package:trade/util/event_bus/eventBus_utils.dart';
import 'package:trade/util/shared_preferences/shared_preferences_key.dart';
import 'package:trade/util/shared_preferences/shared_preferences_utils.dart';

import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../../server/quote/market.dart';
import '../../util/event_bus/events.dart';
import '../../util/log/log.dart';
import '../../util/theme/theme.dart';
import '../../util/utils/market_util.dart';
import '../../util/utils/utils.dart';

class Quote extends StatefulWidget {
  const Quote(this.index, {super.key});
  final int index;

  @override
  State<Quote> createState() => _QuoteState();
}

class _QuoteState extends State<Quote> {
  final QuoteLogic logic = Get.put(QuoteLogic());
  // final MultiSplitViewController _controller = MultiSplitViewController();
  late AppTheme appTheme;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _commScrollController = ScrollController();
  double _dragStartOffset = 0.0;
  double _commDragStartOffset = 0.0;
  double _currentOffset = 0.0;
  double _commCurrentOffset = 0.0;

  Future queryExchange() async {
    // List<Exchange> tmp = await Utils.getAllExchange();
    // if (tmp.isNotEmpty) {
    //   await requestAllContract(tmp);
    // } else {
    if (widget.index == 0) {
      await MarketServer.queryExchangeUrl().then((value) async {
        if (value != null) {
          Utils.saveExchange(value);
          await requestAllContract();
        }
      });
    }
    // }
  }

  Future requestAllContract() async {
    await MarketServer.queryAllContractUrl().then((value) async {
      if (value != null) {
        List<Contract> conList = [];
        MarketUtils.commodityList = value;

        for (var element in value) {
          final contracts = element.contracts;
          if (contracts != null) {
            for (var e in contracts) {
              Contract con = Contract(
                  name: e.shortName,
                  comName: element.shortName,
                  code: e.contractCode,
                  exCode: element.exchangeNo,
                  comType: element.commodityType,
                  subComCode: element.commodityNo,
                  subConCode: e.contractNo,
                  comId: element.id,
                  conId: e.id,
                  contractID: e.id,
                  preSettlePrice: e.preClose,
                  futureTickSize: element.commodityTickSize,
                  contractSize: element.contractSize,
                  currency: element.tradeCurrency,
                  trTime: element.tradeTime,
                  orderNum: element.orderNum);
              conList.add(con);

              if (element.mfContract == e.id) {
                Utils.updateOption(con, true);
              }
            }
          }
        }
        if (conList.isNotEmpty) {
          MarketUtils.contractList = conList;
        }
        SpUtils.set(SpKey.commodity, jsonEncode(value));
        SpUtils.set(SpKey.allContract, jsonEncode(conList));
        EventBusUtil.getInstance().fire(GetAllContracts(widget.index));
      }
    });
  }

  listener() {
    EventBusUtil.getInstance().on<GoKChart>().listen((event) {
      // logger.i(event.go);
      if (event.index == widget.index) {
        if (event.go) {
          logic.viewIndexList[widget.index] = 1;
          appTheme.selectCommandBarIndex = 0;
        } else {
          logic.viewIndexList[widget.index] = 0;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    queryExchange();
    listener();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appTheme = context.watch<AppTheme>();
    return ScaffoldPage(
        padding: EdgeInsets.zero,
        content:
            // Row(
            //   children: [
            //     SizedBox(
            //       height: 1.sh,
            //       width: Common.optionWidgetWidth,
            //       child: ListView(
            //         shrinkWrap: true,
            //         scrollDirection: Axis.vertical,
            //         children: [
            //           GestureDetector(
            //             child: Container(
            //                 width: Common.optionWidgetWidth,
            //                 padding: const EdgeInsets.symmetric(vertical: 30),
            //                 alignment: Alignment.center,
            //                 child: CustomPaint(
            //                   painter: TrapeziumPainter(color: appTheme.selectIndex == 0 ? appTheme.commandBarColor : Colors.transparent),
            //                   child: Text(
            //                     '自\n选\n界\n面',
            //                     style: TextStyle(fontSize: 19, color: appTheme.selectIndex == 0 ? Colors.yellow : appTheme.color),
            //                   ),
            //                 )),
            //             onTap: () {
            //               appTheme.viewIndex = 0;
            //               appTheme.selectIndex = 0;
            //             },
            //           ),
            //           GestureDetector(
            //             child: Container(
            //                 width: Common.optionWidgetWidth,
            //                 padding: const EdgeInsets.symmetric(vertical: 30),
            //                 alignment: Alignment.center,
            //                 child: CustomPaint(
            //                   painter: TrapeziumPainter(color: appTheme.selectIndex == 1 ? appTheme.commandBarColor : Colors.transparent),
            //                   child: Text(
            //                     '国\n际\n期\n货',
            //                     style: TextStyle(fontSize: 19, color: appTheme.selectIndex == 1 ? Colors.yellow : appTheme.color),
            //                   ),
            //                 )),
            //             onTap: () {
            //               appTheme.viewIndex = 0;
            //               appTheme.selectIndex = 1;
            //             },
            //           ),
            //         ],
            //       ),
            //     ),
            // Expanded(child:
            item()
        // MultiSplitView(axis: Axis.vertical, resizable: false, controller: _controller, builder: (BuildContext context, Area area) => area.data),
        // ),
        //   ],
        // ),
        );
  }

  Widget item() {
    return Obx(() {
      return Listener(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: logic.viewIndexList[widget.index] == 0
                    ? QuoteData(widget.index)
                    : QuoteDetails(logic.selectedContractList[widget.index], widget.index)),
            if (widget.index == 0)
              SizedBox(
                height: 28,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    _commDragStartOffset = details.globalPosition.dx;
                  },
                  onHorizontalDragUpdate: (details) {
                    _commScrollController.jumpTo(_commCurrentOffset + _commDragStartOffset - details.globalPosition.dx);
                  },
                  onHorizontalDragEnd: (details) {
                    _commCurrentOffset = max(0, _commCurrentOffset + _commDragStartOffset - details.globalPosition.dx);
                    _commCurrentOffset =
                        min(_commScrollController.position.maxScrollExtent, _commCurrentOffset + _commDragStartOffset - details.globalPosition.dx);
                  },
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: logic.commodityList.length,
                    controller: _commScrollController,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () async {
                          logic.selectedCommodity.value = logic.commodityList[index];
                          int thisIndex = 0;
                          if (logic.selectedExchangeList[widget.index].exchangeNo != null) {
                            logic.selectedMContractList[widget.index].clear();
                            logic.selectedMContractList[widget.index]
                                .addAll(await logic.getContracts(logic.selectedExchangeList[widget.index].exchangeNo!));
                            for (var e in logic.selectedMContractList[widget.index]) {
                              if (e.comType == logic.selectedCommodity.value.commodityType && e.comId == logic.selectedCommodity.value.commodityId) {
                                // logic.selectedMContractList[widget.index].add(e);
                                thisIndex = logic.selectedMContractList[widget.index].indexOf(e);
                                break;
                              }
                            }
                          }
                          logic.commodityList.refresh();
                          logic.selectedMContractList.refresh();
                          EventBusUtil.getInstance().fire(RefreshCommodity(thisIndex));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          color: logic.commodityList[index] == logic.selectedCommodity.value ? appTheme.exchangeBgColor : Colors.transparent,
                          child: Text(
                            logic.commodityList[index].commodityName ?? "",
                            style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (widget.index == 0)
              SizedBox(
                  height: 38,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onHorizontalDragStart: (details) {
                            _dragStartOffset = details.globalPosition.dx;
                          },
                          onHorizontalDragUpdate: (details) {
                            _scrollController.jumpTo(_currentOffset + _dragStartOffset - details.globalPosition.dx);
                          },
                          onHorizontalDragEnd: (details) {
                            _currentOffset = max(0, _currentOffset + _dragStartOffset - details.globalPosition.dx);
                            _currentOffset =
                                min(_scrollController.position.maxScrollExtent, _currentOffset + _dragStartOffset - details.globalPosition.dx);
                          },
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: logic.mExchangeList.length,
                            controller: _scrollController,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  logic.viewIndexList[widget.index] = 0;
                                  logic.optionalIndexList[widget.index] = 1;
                                  logic.switchExchange(index, widget.index);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  color: logic.mExchangeList[index] == logic.selectedExchangeList[widget.index]
                                      ? appTheme.exchangeBgColor
                                      : Colors.transparent,
                                  child: Text(
                                    logic.mExchangeList[index].exchangeName ?? "",
                                    style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          logic.viewIndexList[widget.index] = 0;
                          logic.optionalIndexList[widget.index] = 0;
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          color: logic.optionalIndexList[widget.index] == 0 ? appTheme.exchangeBgColor : Colors.transparent,
                          child: Text(
                            '自选界面',
                            style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
                          ),
                        ),
                      )
                    ],
                  )),
          ],
        ),
        onPointerDown: (e) {
          logic.selectedIndex.value = widget.index;
        },
      );
    });
  }
}
