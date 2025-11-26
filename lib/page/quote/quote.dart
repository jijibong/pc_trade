import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:trade/page/quote/quote_data.dart';
import 'package:trade/page/quote/quote_details/quote_details.dart';
import 'package:trade/page/quote/quote_logic.dart';
import 'package:trade/util/event_bus/eventBus_utils.dart';
import 'package:trade/util/info_bar/info_bar.dart';
import 'package:trade/util/shared_preferences/shared_preferences_key.dart';
import 'package:trade/util/shared_preferences/shared_preferences_utils.dart';

import '../../model/option/sector.dart';
import '../../model/quote/contract.dart';
import '../../server/quote/market.dart';
import '../../util/dialog/add_option.dart';
import '../../util/event_bus/events.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/theme/theme.dart';
import '../../util/utils/market_util.dart';
import '../../util/utils/utils.dart';

class Quote extends StatefulWidget {
  const Quote(this.index, {this.multiScreen, super.key});
  final int index;
  final bool? multiScreen;

  @override
  State<Quote> createState() => _QuoteState();
}

class _QuoteState extends State<Quote> {
  final ThemeController themeController = Get.find<ThemeController>();
  final QuoteLogic logic = Get.put(QuoteLogic());
  final ScrollController _commScrollController = ScrollController();
  StreamSubscription? _subscription;
  StreamSubscription? _subscriptionA;
  StreamSubscription? _subscriptionB;
  StreamSubscription? _subscriptionC;
  StreamSubscription? _subscriptionD;
  double _commDragStartOffset = 0.0;
  double _commCurrentOffset = 0.0;

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
                  trTime: element.tradeTime);
              conList.add(con);

              // if (element.mfContract == e.id) {
              //   Utils.updateOption(con, true);
              // }
            }
          }
        }
        if (conList.isNotEmpty) {
          MarketUtils.contractList = conList;
        }
        SpUtils.set(SpKey.commodity, jsonEncode(value));
        SpUtils.set(SpKey.allContract, jsonEncode(conList));
        EventBusUtil.getInstance().fire(GetAllContracts());
      }
    });
  }

  listener() {
    _subscription = EventBusUtil.getInstance().on<GoKChart>().listen((event) {
      // logger.i(event.go);
      if (event.index == widget.index) {
        if (event.go) {
          logic.viewIndexList[widget.index] = 1;
          themeController.selectCommandBarIndex.value = 0;
        } else {
          logic.viewIndexList[widget.index] = 0;
        }
      }
    });

    ///板块更新
    // _subscriptionA = EventBusUtil.getInstance().on<SectorEvent>().listen((event) async {
    //   var tmp = jsonDecode(event.json);
    //   List<Sector> temp = [];
    //   for (var i in tmp) {
    //     temp.add(Sector.fromJson(i));
    //   }
    //   Map<Sector, List<Contract>> newMap = {};
    //   for (var i in temp) {
    //     bool exist = false;
    //     for (var e in sectorMap.keys) {
    //       if (i.id == e.id) {
    //         exist = true;
    //         newMap.addAll({i: sectorMap[e] ?? []});
    //       }
    //     }
    //     if (!exist) {
    //       newMap.addAll({i: []});
    //     }
    //   }
    //   sectorMap.clear();
    //   sectorMap.addAll(newMap);
    //   showSectorMap.clear();
    //   logic.sectorList.clear();
    //   for (var i in sectorMap.keys) {
    //     if (i.show == true) {
    //       showSectorMap.addAll({i: sectorMap[i] ?? []});
    //     }
    //     if (i.editable == true) {
    //       logic.sectorList.add(i);
    //     }
    //   }
    //   final serialized = serializeSectorMap(sectorMap);
    //   await SpUtils.set(SpKey.sector, serialized);
    //   if (mounted) setState(() {});
    // });

    ///自选更新
    _subscriptionB = EventBusUtil.getInstance().on<AddOptionEvent>().listen((event) async {
      bool exist = false;
      for (var i in logic.sectorMap.keys) {
        if (i.id == event.sector.id) {
          if (event.add) {
            if (logic.sectorMap[i] != null && logic.sectorMap[i]!.isNotEmpty) {
              for (var i in logic.sectorMap[i]!) {
                if (i.name == event.contract.name && i.code == event.contract.code && i.comId == event.contract.comId) {
                  exist = true;
                  break;
                }
              }
            }
            if (!exist) {
              logic.sectorMap[i]?.add(event.contract);
            }
          } else {
            if (logic.sectorMap[i]!.contains(event.contract)) {
              logic.sectorMap[i]?.remove(event.contract);
            }
          }
          break;
        }
      }
      if (exist) {
        InfoBarUtils.showErrorDialog("该合约已存在！");
      } else {
        if (event.sector.id == "1") {
          logic.optionOperate(event.contract, event.add);
        }
        if (logic.selectedSector[widget.index].id == event.sector.id) {
          logic.homePageList[widget.index] = logic.showSectorMap[logic.selectedSector[widget.index]] ?? [];
          logic.subscriptionHome(widget.index);
        }
        final serialized = logic.serializeSectorMap(logic.sectorMap);
        await SpUtils.set(SpKey.sector, serialized);
      }
    });

    ///更新账号自选
    _subscriptionC = EventBusUtil.getInstance().on<OptionRefresh>().listen((event) async {
      for (var i in logic.sectorMap.keys) {
        if (i.id == "1") {
          logic.sectorMap[i]?.clear();
          logic.sectorMap[i]?.addAll(event.contractList);
          if (i.show == true) {
            logic.showSectorMap[i]?.clear();
            logic.showSectorMap[i]?.addAll(event.contractList);
          }
          break;
        }
      }
      if (logic.selectedSector[widget.index].id == "1") {
        logic.homePageList[widget.index] = logic.showSectorMap[logic.selectedSector[widget.index]] ?? [];
        logic.subscriptionHome(widget.index);
      }
    });

    ///自选排序更新
    _subscriptionD = EventBusUtil.getInstance().on<UpdateOptionEvent>().listen((event) async {
      for (var i in logic.sectorMap.keys) {
        if (logic.selectedSector[widget.index].id == i.id) {
          logic.sectorMap[i] = logic.homePageList[widget.index];
          final serialized = logic.serializeSectorMap(logic.sectorMap);
          await SpUtils.set(SpKey.sector, serialized);
          return;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    queryExchange();
    logic.requestSector(widget.index);
    listener();
  }

  @override
  void dispose() {
    super.dispose();
    _commScrollController.dispose();
    _subscription?.cancel();
    _subscriptionA?.cancel();
    _subscriptionB?.cancel();
    _subscriptionC?.cancel();
    _subscriptionD?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(padding: EdgeInsets.zero, content: item());
  }

  Widget item() {
    return Obx(() {
      return Listener(
        child: GestureDetector(
          onDoubleTap: () {
            if (themeController.multiScreen.value != 1) {
              EventBusUtil.getInstance().fire(SelectScreen(widget.index));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: logic.viewIndexList[widget.index] == 0
                      ? QuoteData(widget.index)
                      : QuoteDetails(
                          logic.selectedContractList[widget.index],
                          widget.index,
                          multiScreen: widget.multiScreen,
                        )),
              if (logic.viewIndexList[widget.index] == 0)
                Container(
                  height: 34,
                  color: themeController.theme.inactiveBackgroundColor,
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
                      itemCount: themeController.selectIndex.value == 1 ? logic.commodityList.length : logic.showSectorMap.length + 1,
                      controller: _commScrollController,
                      itemBuilder: (BuildContext context, int index) {
                        if (themeController.selectIndex.value == 1) {
                          return GestureDetector(
                            onTap: () async {
                              logic.selectedCommodity.value = logic.commodityList[index];
                              int thisIndex = 0;
                              if (logic.selectedExchange.value.exchangeNo != null) {
                                logic.selectedMContractList[widget.index].clear();
                                logic.selectedMContractList[widget.index].addAll(await logic.getContracts(logic.selectedExchange.value.exchangeNo!));
                                for (var e in logic.selectedMContractList[widget.index]) {
                                  if (e.comType == logic.selectedCommodity.value.commodityType &&
                                      e.comId == logic.selectedCommodity.value.commodityId) {
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
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              margin: const EdgeInsets.all(5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: logic.commodityList[index] == logic.selectedCommodity.value
                                    ? themeController.theme.bottomNavigationTheme.backgroundColor
                                    : Colors.transparent,
                              ),
                              child: Text(
                                logic.commodityList[index].commodityName ?? "",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: logic.commodityList[index] == logic.selectedCommodity.value
                                        ? themeController.theme.bottomNavigationTheme.selectedColor
                                        : themeController.theme.bottomNavigationTheme.inactiveColor),
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () async {
                              if (index == logic.showSectorMap.length) {
                                // String jsonString = jsonEncode(sectorMap.keys.map((e) => e.toJson()).toList());
                                // await rustDeskWinManager.newSectorManage("newSectorManage", hold: jsonString);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddOptionDialog().editDialog(logic.sectorMap.keys.toList(), (value) async {
                                        Map<Sector, List<Contract>> newMap = {};
                                        for (var i in value) {
                                          bool exist = false;
                                          for (var e in logic.sectorMap.keys) {
                                            if (i.id == e.id) {
                                              exist = true;
                                              newMap.addAll({i: logic.sectorMap[e] ?? []});
                                            }
                                          }
                                          if (!exist) {
                                            newMap.addAll({i: []});
                                          }
                                        }
                                        logic.sectorMap.clear();
                                        logic.sectorMap.addAll(newMap);
                                        logic.showSectorMap.clear();
                                        logic.sectorList.clear();
                                        for (var i in logic.sectorMap.keys) {
                                          if (i.show == true) {
                                            logic.showSectorMap.addAll({i: logic.sectorMap[i] ?? []});
                                          }
                                          if (i.editable == true) {
                                            logic.sectorList.add(i);
                                          }
                                        }
                                        final serialized = logic.serializeSectorMap(logic.sectorMap);
                                        await SpUtils.set(SpKey.sector, serialized);
                                        if (mounted) setState(() {});
                                      });
                                    });
                              } else {
                                logic.selectedSector[widget.index] = logic.showSectorMap.keys.elementAt(index);
                                logic.homePageList[widget.index] = logic.showSectorMap[logic.selectedSector[widget.index]] ?? [];
                                logic.subscriptionHome(widget.index);
                              }
                              if (mounted) setState(() {});
                            },
                            child: index != logic.showSectorMap.length
                                ? Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                    alignment: Alignment.center,
                                    // color: showSectorMap.keys.elementAt(index) == logic.selectedSector[widget.index]
                                    //     ? themeController.theme.focusColor
                                    //     : Colors.transparent,
                                    child: Text(
                                      logic.showSectorMap.keys.elementAt(index).name ?? "",
                                      style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                    alignment: Alignment.center,
                                    color: Colors.transparent,
                                    child: Text(
                                      "...",
                                      style: TextStyle(fontSize: 14, color: themeController.theme.selectionColor),
                                    ),
                                  ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              // if (widget.index == 0)
              //   SizedBox(
              //     height: 32,
              //     child: GestureDetector(
              //       onHorizontalDragStart: (details) {
              //         _dragStartOffset = details.globalPosition.dx;
              //       },
              //       onHorizontalDragUpdate: (details) {
              //         _scrollController.jumpTo(_currentOffset + _dragStartOffset - details.globalPosition.dx);
              //       },
              //       onHorizontalDragEnd: (details) {
              //         _currentOffset = max(0, _currentOffset + _dragStartOffset - details.globalPosition.dx);
              //         _currentOffset = min(_scrollController.position.maxScrollExtent, _currentOffset + _dragStartOffset - details.globalPosition.dx);
              //       },
              //       child: ListView.builder(
              //         scrollDirection: Axis.horizontal,
              //         itemCount: themeController.selectIndex == 1 ? logic.mExchangeList.length : myPage.length + 1,
              //         controller: _scrollController,
              //         itemBuilder: (BuildContext context, int index) {
              //           if (themeController.selectIndex == 1) {
              //             return GestureDetector(
              //               onTap: () {
              //                 logic.viewIndexList[widget.index] = 0;
              //                 themeController.selectIndex = 1;
              //                 logic.switchExchange(index, widget.index);
              //                 if (mounted) setState(() {});
              //               },
              //               child: Container(
              //                 margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              //                 alignment: Alignment.center,
              //                 color: logic.mExchangeList[index] == logic.selectedExchangeList[widget.index]
              //                     ? themeController.exchangeBgColor
              //                     : Colors.transparent,
              //                 child: Text(
              //                   logic.mExchangeList[index].exchangeName ?? "",
              //                   style: TextStyle(fontSize: 17, color: themeController.exchangeTextColor),
              //                 ),
              //               ),
              //             );
              //           } else {
              //             if (index == 0) {
              //               return GestureDetector(
              //                 onTap: () {
              //                   themeController.multiScreen = 1;
              //                   if (mounted) setState(() {});
              //                 },
              //                 child: Container(
              //                   margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              //                   alignment: Alignment.center,
              //                   color: logic.mExchangeList[index] == logic.selectedExchangeList[widget.index]
              //                       ? themeController.exchangeBgColor
              //                       : Colors.transparent,
              //                   child: Text(
              //                     "我的合约",
              //                     style: TextStyle(fontSize: 17, color: themeController.exchangeTextColor),
              //                   ),
              //                 ),
              //               );
              //             } else {
              //               return GestureDetector(
              //                 onTap: () {
              //                   selectedPage = myPage[index - 1];
              //                   if (selectedPage.selectedIndex != null) logic.selectedIndex.value = selectedPage.selectedIndex!;
              //                   if (selectedPage.viewIndexList != null) logic.viewIndexList.value = selectedPage.viewIndexList!;
              //                   if (selectedPage.showChartList != null) logic.showChartList.value = selectedPage.showChartList!;
              //                   if (selectedPage.contractList != null) logic.selectedContractList.value = selectedPage.contractList!;
              //                   if (selectedPage.kPeriodList != null) logic.kPeriodList.value = selectedPage.kPeriodList!;
              //                   if (selectedPage.selectedSector != null) logic.sectorList.value = selectedPage.selectedSector!;
              //                   if (mounted) setState(() {});
              //                 },
              //                 child: Container(
              //                   margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              //                   alignment: Alignment.center,
              //                   color: myPage[index - 1] == selectedPage ? themeController.exchangeBgColor : Colors.transparent,
              //                   child: Text(
              //                     myPage[index - 1].name ?? "",
              //                     style: TextStyle(fontSize: 17, color: themeController.exchangeTextColor),
              //                   ),
              //                 ),
              //               );
              //             }
              //           }
              //           return null;
              //         },
              //       ),
              //     ),
              //     // GestureDetector(
              //     //   onTap: () {
              //     //     logic.viewIndexList[widget.index] = 0;
              //     //     logic.optionalIndexList[widget.index] = 0;
              //     //   },
              //     //   child: Container(
              //     //     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //     //     color: logic.optionalIndexList[widget.index] == 0 ? themeController.exchangeBgColor : Colors.transparent,
              //     //     child: Text(
              //     //       '自选界面',
              //     //       style: TextStyle(fontSize: 17, color: themeController.exchangeTextColor),
              //     //     ),
              //     //   ),
              //     // )
              //     // ],
              //     // )
              //   ),
            ],
          ),
        ),
        onPointerDown: (e) {
          logic.selectedIndex.value = widget.index;
        },
      );
    });
  }
}
