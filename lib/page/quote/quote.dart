import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:trade/page/quote/quote_data.dart';
import 'package:trade/page/quote/quote_details/quote_details.dart';
import 'package:trade/page/quote/quote_logic.dart';
import 'package:trade/util/event_bus/eventBus_utils.dart';
import 'package:trade/util/shared_preferences/shared_preferences_key.dart';
import 'package:trade/util/shared_preferences/shared_preferences_utils.dart';

import '../../config/common.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../../server/quote/market.dart';
import '../../util/dialog/add_option_dialog.dart';
import '../../util/event_bus/events.dart';
import '../../util/log/log.dart';
import '../../util/style/paint.dart';
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
  late AppTheme appTheme;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _commScrollController = ScrollController();
  double _dragStartOffset = 0.0;
  double _commDragStartOffset = 0.0;
  double _currentOffset = 0.0;
  double _commCurrentOffset = 0.0;
  List optionFiles = ["我的自选", "..."];
  String selectedFile = "我的自选";

  Future queryExchange() async {
    if (widget.index == 0) {
      await MarketServer.queryExchangeUrl().then((value) async {
        if (value != null) {
          Utils.saveExchange(value);
          await requestAllContract();
        }
      });
    }
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

  Future requestFiles() async {
    String? string = await SpUtils.getString(SpKey.myOption);
    if (string != null) {
      List tmp = jsonDecode(string);
      for (Map i in tmp) {
        // optionFiles.insert(optionFiles.length-2, element);
      }
    }
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
    return ScaffoldPage(padding: EdgeInsets.zero, content: item());
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
            if (widget.index == 0 && logic.viewIndexList[widget.index] == 0)
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
                    itemCount: appTheme.selectIndex == 1 ? logic.commodityList.length : optionFiles.length,
                    controller: _commScrollController,
                    itemBuilder: (BuildContext context, int index) {
                      if (appTheme.selectIndex == 1) {
                        return GestureDetector(
                          onTap: () async {
                            logic.selectedCommodity.value = logic.commodityList[index];
                            int thisIndex = 0;
                            if (logic.selectedExchangeList[widget.index].exchangeNo != null) {
                              logic.selectedMContractList[widget.index].clear();
                              logic.selectedMContractList[widget.index]
                                  .addAll(await logic.getContracts(logic.selectedExchangeList[widget.index].exchangeNo!));
                              for (var e in logic.selectedMContractList[widget.index]) {
                                if (e.comType == logic.selectedCommodity.value.commodityType &&
                                    e.comId == logic.selectedCommodity.value.commodityId) {
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
                      } else {
                        return GestureDetector(
                          onTap: () async {
                            if (index == optionFiles.length - 1) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddOptionDialog().addOptionDialog((e) {});
                                  });
                            } else {
                              selectedFile = optionFiles[index];
                            }
                            if (mounted) setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                            alignment: Alignment.center,
                            color: optionFiles[index] == selectedFile ? appTheme.exchangeBgColor : Colors.transparent,
                            child: Text(
                              optionFiles[index] ?? "",
                              style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            if (widget.index == 0 && appTheme.selectIndex == 1)
              SizedBox(
                height: 38,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    _dragStartOffset = details.globalPosition.dx;
                  },
                  onHorizontalDragUpdate: (details) {
                    _scrollController.jumpTo(_currentOffset + _dragStartOffset - details.globalPosition.dx);
                  },
                  onHorizontalDragEnd: (details) {
                    _currentOffset = max(0, _currentOffset + _dragStartOffset - details.globalPosition.dx);
                    _currentOffset = min(_scrollController.position.maxScrollExtent, _currentOffset + _dragStartOffset - details.globalPosition.dx);
                  },
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: logic.mExchangeList.length,
                    controller: _scrollController,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          logic.viewIndexList[widget.index] = 0;
                          appTheme.selectIndex = 1;
                          logic.switchExchange(index, widget.index);
                          if (mounted) setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          color:
                              logic.mExchangeList[index] == logic.selectedExchangeList[widget.index] ? appTheme.exchangeBgColor : Colors.transparent,
                          child: Text(
                            logic.mExchangeList[index].exchangeName ?? "",
                            style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // GestureDetector(
                //   onTap: () {
                //     logic.viewIndexList[widget.index] = 0;
                //     logic.optionalIndexList[widget.index] = 0;
                //   },
                //   child: Container(
                //     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                //     color: logic.optionalIndexList[widget.index] == 0 ? appTheme.exchangeBgColor : Colors.transparent,
                //     child: Text(
                //       '自选界面',
                //       style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
                //     ),
                //   ),
                // )
                // ],
                // )
              ),
          ],
        ),
        onPointerDown: (e) {
          logic.selectedIndex.value = widget.index;
        },
      );
    });
  }
}
