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
import 'package:trade/util/info_bar/info_bar.dart';
import 'package:trade/util/shared_preferences/shared_preferences_key.dart';
import 'package:trade/util/shared_preferences/shared_preferences_utils.dart';

import '../../model/option/sector.dart';
import '../../model/quote/contract.dart';
import '../../server/quote/market.dart';
import '../../util/event_bus/events.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
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
  final ScrollController _commScrollController = ScrollController();
  StreamSubscription? _subscription;
  StreamSubscription? _subscriptionA;
  StreamSubscription? _subscriptionB;
  StreamSubscription? _subscriptionC;
  StreamSubscription? _subscriptionD;
  double _commDragStartOffset = 0.0;
  double _commCurrentOffset = 0.0;
  Map<Sector, List<Contract>> sectorMap = {};
  Map<Sector, List<Contract>> showSectorMap = {};

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

  Future requestSector() async {
    String? jsonString = await SpUtils.getString(SpKey.sector);
    sectorMap.clear();
    if (jsonString != null && jsonString != "") {
      try {
        sectorMap.addAll(deserializeSectorMap(jsonString));
        for (var i in sectorMap.keys) {
          if (i.id == "2") {
            sectorMap[i] = logic.mainContractList;
          }
          if (i.id == "3") {
            sectorMap[i] = logic.mHoldToContractList;
          }
          if (i.id == "4") {
            sectorMap[i] = logic.historyList;
          }
        }
      } catch (e) {
        logger.e(e);
      }
    } else {
      sectorMap.addAll({Sector(name: "自选", type: 0, show: true, canDelete: false, editable: true, id: "1"): []});
      sectorMap.addAll({Sector(name: "主力合约", type: 0, show: false, canDelete: false, editable: false, id: "2"): logic.mainContractList});
      sectorMap.addAll({Sector(name: "持仓合约", type: 0, show: false, canDelete: false, editable: false, id: "3"): logic.mHoldToContractList});
      sectorMap.addAll({Sector(name: "浏览记录", type: 0, show: false, canDelete: false, editable: false, id: "4"): logic.historyList});
    }
    showSectorMap.clear();
    logic.sectorList.clear();
    for (var i in sectorMap.keys) {
      if (i.show == true) {
        showSectorMap.addAll({i: sectorMap[i] ?? []});
      }
      if (i.editable == true) {
        logic.sectorList.add(i);
      }
    }
    if (logic.selectedSector[widget.index].id == null || !showSectorMap.keys.contains(logic.selectedSector[widget.index])) {
      logic.selectedSector[widget.index] = showSectorMap.keys.first;
    }
    logic.homePageList[widget.index] = showSectorMap[logic.selectedSector[widget.index]] ?? [];
    logic.subscriptionHome(widget.index);
    if (mounted) setState(() {});
  }

  ///序列化
  String serializeSectorMap(Map<Sector, List<Contract>> map) {
    final serialized = map.map((sector, contracts) => MapEntry(
          jsonEncode(sector.toJson()),
          contracts.map((person) => person.toJson()).toList(),
        ));
    return jsonEncode(serialized);
  }

  ///反序列化
  Map<Sector, List<Contract>> deserializeSectorMap(String jsonString) {
    final Map<String, dynamic> decodedMap = jsonDecode(jsonString);
    final Map<Sector, List<Contract>> resultMap = decodedMap.map((key, value) {
      final sector = Sector.fromJson(jsonDecode(key) as Map<String, dynamic>);
      final contracts = (value as List).map((item) => Contract.fromJson(item as Map<String, dynamic>)).toList();
      return MapEntry(sector, contracts);
    });
    return resultMap;
  }

  listener() {
    _subscription = EventBusUtil.getInstance().on<GoKChart>().listen((event) {
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

    ///板块更新
    _subscriptionA = EventBusUtil.getInstance().on<SectorEvent>().listen((event) async {
      var tmp = jsonDecode(event.json);
      List<Sector> temp = [];
      for (var i in tmp) {
        temp.add(Sector.fromJson(i));
      }
      Map<Sector, List<Contract>> newMap = {};
      for (var i in temp) {
        bool exist = false;
        for (var e in sectorMap.keys) {
          if (i.id == e.id) {
            exist = true;
            newMap.addAll({i: sectorMap[e] ?? []});
          }
        }
        if (!exist) {
          newMap.addAll({i: []});
        }
      }
      sectorMap.clear();
      sectorMap.addAll(newMap);
      showSectorMap.clear();
      logic.sectorList.clear();
      for (var i in sectorMap.keys) {
        if (i.show == true) {
          showSectorMap.addAll({i: sectorMap[i] ?? []});
        }
        if (i.editable == true) {
          logic.sectorList.add(i);
        }
      }
      final serialized = serializeSectorMap(sectorMap);
      await SpUtils.set(SpKey.sector, serialized);
      if (mounted) setState(() {});
    });

    ///自选更新
    _subscriptionB = EventBusUtil.getInstance().on<AddOptionEvent>().listen((event) async {
      bool exist = false;
      for (var i in sectorMap.keys) {
        if (i.id == event.sector.id) {
          if (event.add) {
            if (sectorMap[i] != null && sectorMap[i]!.isNotEmpty) {
              for (var i in sectorMap[i]!) {
                if (i.name == event.contract.name && i.code == event.contract.code && i.comId == event.contract.comId) {
                  exist = true;
                  break;
                }
              }
            }
            if (!exist) {
              sectorMap[i]?.add(event.contract);
            }
          } else {
            if (sectorMap[i]!.contains(event.contract)) {
              sectorMap[i]?.remove(event.contract);
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
          logic.homePageList[widget.index] = showSectorMap[logic.selectedSector[widget.index]] ?? [];
          logic.subscriptionHome(widget.index);
        }
        final serialized = serializeSectorMap(sectorMap);
        await SpUtils.set(SpKey.sector, serialized);
      }
      if (mounted) setState(() {});
    });

    ///更新账号自选
    _subscriptionC = EventBusUtil.getInstance().on<OptionRefresh>().listen((event) async {
      for (var i in sectorMap.keys) {
        if (i.id == "1") {
          sectorMap[i]?.clear();
          sectorMap[i]?.addAll(event.contractList);
          if (i.show == true) {
            showSectorMap[i]?.clear();
            showSectorMap[i]?.addAll(event.contractList);
          }
          break;
        }
      }
      if (logic.selectedSector[widget.index].id == "1") {
        logic.homePageList[widget.index] = showSectorMap[logic.selectedSector[widget.index]] ?? [];
        logic.subscriptionHome(widget.index);
      }
      if (mounted) setState(() {});
    });

    ///自选排序更新
    _subscriptionD = EventBusUtil.getInstance().on<UpdateOptionEvent>().listen((event) async {
      for (var i in sectorMap.keys) {
        if (logic.selectedSector[widget.index].id == i.id) {
          sectorMap[i] = logic.homePageList[widget.index];
          final serialized = serializeSectorMap(sectorMap);
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
    requestSector();
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
    appTheme = context.watch<AppTheme>();
    return ScaffoldPage(padding: EdgeInsets.zero, content: item());
  }

  Widget item() {
    return Obx(() {
      return Listener(
        child: GestureDetector(
          onDoubleTap: () {
            if (appTheme.multiScreen != 1) {
              EventBusUtil.getInstance().fire(SelectScreen(widget.index));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: logic.viewIndexList[widget.index] == 0
                      ? QuoteData(widget.index)
                      : QuoteDetails(logic.selectedContractList[widget.index], widget.index)),
              if (logic.viewIndexList[widget.index] == 0)
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
                      itemCount: appTheme.selectIndex == 1 ? logic.commodityList.length : showSectorMap.length + 1,
                      controller: _commScrollController,
                      itemBuilder: (BuildContext context, int index) {
                        if (appTheme.selectIndex == 1) {
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
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                              alignment: Alignment.center,
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
                              if (index == showSectorMap.length) {
                                String jsonString = jsonEncode(sectorMap.keys.map((e) => e.toJson()).toList());
                                await rustDeskWinManager.newSectorManage("newSectorManage", hold: jsonString);
                              } else {
                                logic.selectedSector[widget.index] = showSectorMap.keys.elementAt(index);
                                logic.homePageList[widget.index] = showSectorMap[logic.selectedSector[widget.index]] ?? [];
                                logic.subscriptionHome(widget.index);
                              }
                              if (mounted) setState(() {});
                            },
                            child: index != showSectorMap.length
                                ? Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                    alignment: Alignment.center,
                                    color: showSectorMap.keys.elementAt(index) == logic.selectedSector[widget.index]
                                        ? appTheme.exchangeBgColor
                                        : Colors.transparent,
                                    child: Text(
                                      showSectorMap.keys.elementAt(index).name ?? "",
                                      style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                    alignment: Alignment.center,
                                    color: Colors.transparent,
                                    child: Text(
                                      "...",
                                      style: TextStyle(fontSize: 14, color: appTheme.exchangeTextColor),
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
              //         itemCount: appTheme.selectIndex == 1 ? logic.mExchangeList.length : myPage.length + 1,
              //         controller: _scrollController,
              //         itemBuilder: (BuildContext context, int index) {
              //           if (appTheme.selectIndex == 1) {
              //             return GestureDetector(
              //               onTap: () {
              //                 logic.viewIndexList[widget.index] = 0;
              //                 appTheme.selectIndex = 1;
              //                 logic.switchExchange(index, widget.index);
              //                 if (mounted) setState(() {});
              //               },
              //               child: Container(
              //                 margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              //                 alignment: Alignment.center,
              //                 color: logic.mExchangeList[index] == logic.selectedExchangeList[widget.index]
              //                     ? appTheme.exchangeBgColor
              //                     : Colors.transparent,
              //                 child: Text(
              //                   logic.mExchangeList[index].exchangeName ?? "",
              //                   style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
              //                 ),
              //               ),
              //             );
              //           } else {
              //             if (index == 0) {
              //               return GestureDetector(
              //                 onTap: () {
              //                   appTheme.multiScreen = 1;
              //                   if (mounted) setState(() {});
              //                 },
              //                 child: Container(
              //                   margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              //                   alignment: Alignment.center,
              //                   color: logic.mExchangeList[index] == logic.selectedExchangeList[widget.index]
              //                       ? appTheme.exchangeBgColor
              //                       : Colors.transparent,
              //                   child: Text(
              //                     "我的合约",
              //                     style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
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
              //                   color: myPage[index - 1] == selectedPage ? appTheme.exchangeBgColor : Colors.transparent,
              //                   child: Text(
              //                     myPage[index - 1].name ?? "",
              //                     style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
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
              //     //     color: logic.optionalIndexList[widget.index] == 0 ? appTheme.exchangeBgColor : Colors.transparent,
              //     //     child: Text(
              //     //       '自选界面',
              //     //       style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
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
