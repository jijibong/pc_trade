import 'dart:async';
import 'dart:convert';

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
import '../../util/theme/theme.dart';
import '../../util/utils/market_util.dart';
import '../../util/utils/utils.dart';

class Quote extends StatefulWidget {
  const Quote({super.key});

  @override
  State<Quote> createState() => _QuoteState();
}

class _QuoteState extends State<Quote> {
  final QuoteLogic logic = Get.put(QuoteLogic());
  // final MultiSplitViewController _controller = MultiSplitViewController();
  late AppTheme appTheme;

  Future queryExchange() async {
    await MarketServer.queryExchangeUrl().then((value) async {
      if (value != null) {
        Utils.saveExchange(value);
        await requestAllContract(value);
      }
    });
  }

  Future requestAllContract(List<Exchange> exchanges) async {
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
        EventBusUtil.getInstance().fire(GetAllContracts());
      }
    });
  }

  listener() {
    EventBusUtil.getInstance().on<GoKChart>().listen((event) {
      // logger.i(event.go);
      if (event.go) {
        appTheme.viewIndex = 1;
      } else {
        appTheme.viewIndex = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // _controller.areas = [
    //   Area(data: item()),
    // ];
    queryExchange();
    listener();
  }

  @override
  void dispose() {
    super.dispose();
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: appTheme.viewIndex == 0 ? const QuoteDatas() : QuoteDetails(logic.selectedContract.value)),
          SizedBox(
              height: 38,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: logic.mExchangeList.length,
                      // shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            appTheme.viewIndex = 0;
                            appTheme.selectIndex = 1;
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
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      appTheme.viewIndex = 0;
                      appTheme.selectIndex = 0;
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: appTheme.selectIndex == 0 ? appTheme.exchangeBgColor : Colors.transparent,
                      child: Text(
                        '自选界面',
                        style: TextStyle(fontSize: 17, color: appTheme.exchangeTextColor),
                      ),
                    ),
                  )
                ],
              )),
        ],
      );
    });
  }
}
