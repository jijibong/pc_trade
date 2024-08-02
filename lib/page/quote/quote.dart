import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:trade/page/quote/quote_data.dart';
import 'package:trade/page/quote/quote_details/quote_details.dart';
import 'package:trade/page/quote/quote_logic.dart';
import 'package:trade/util/event_bus/eventBus_utils.dart';

import '../../config/common.dart';
import '../../model/quote/contract.dart';
import '../../model/quote/exchange.dart';
import '../../server/login/login.dart';
import '../../server/quote/market.dart';
import '../../util/event_bus/events.dart';
import '../../util/log/log.dart';
import '../../util/style/paint.dart';
import '../../util/theme/theme.dart';
import '../../util/utils/market_util.dart';
import '../../util/utils/utils.dart';
import '../trade/trade.dart';

class Quote extends StatefulWidget {
  const Quote({super.key});

  @override
  State<Quote> createState() => _QuoteState();
}

class _QuoteState extends State<Quote> {
  final QuoteLogic logic = Get.put(QuoteLogic());
  final MultiSplitViewController _controller = MultiSplitViewController();
  late AppTheme appTheme;

  Future queryExchange() async {
    await MarketServer.queryExchangeUrl().then((value) async {
      if (value != null) {
        List<Exchange> local = await Utils.getAllExchange();
        for (var element in local) {
          for (var e in value) {
            if (element.exchangeNo == e.exchangeNo) {
              e.orderUser = element.orderUser;
              e.isMyExchange = element.isMyExchange;
              break;
            }
          }
        }
        if (local.isEmpty) {
          for (var element in value) {
            element.isMyExchange = true;
          }
        }
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
        // StartupConfig.startUp();
        // isLoginEd();
        EventBusUtil.getInstance().fire(GetAllContracts());
      }
    });
  }

  listener() {
    EventBusUtil.getInstance().on<LoginEvent>().listen((event) {
      if (event.loginSuccess) {
        _controller.addArea(Area(data: const Trade(), flex: 1.2));
      } else {
        if (_controller.areasCount == 2) {
          _controller.removeAreaAt(1);
          LoginServer.isLogin = false;
        }
      }
      if (mounted) setState(() {});
    });

    EventBusUtil.getInstance().on<GoKChart>().listen((event) {
      if (event.go) {
        logic.viewIndex.value = 1;
      } else {
        logic.viewIndex.value = 0;
      }
    });

    EventBusUtil.getInstance().on<ShowTrade>().listen((event) {
      if (event.show) {
        _controller.removeAreaAt(1);
        _controller.addArea(Area(data: const Trade(), flex: 1.2));
      } else {
        _controller.removeAreaAt(1);
        _controller.addArea(Area(data: const Trade(), size: 30));
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.areas = [
      Area(data: item()),
    ];
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
      content: MultiSplitView(axis: Axis.vertical, resizable: false, controller: _controller, builder: (BuildContext context, Area area) => area.data),
    );
  }

  Widget item() {
    return Obx(() {
      return Row(
        children: [
          SizedBox(
            height: 1.sh,
            width: Common.optionWidgetWidth,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [
                GestureDetector(
                  child: Container(
                    width: Common.optionWidgetWidth,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    alignment: Alignment.center,
                    child: CustomPaint(
                      painter: TrapeziumPainter(color: logic.selectIndex.value == 0 ? appTheme.commandBarColor : Colors.transparent),
                      child: Text(
                        '自\n选\n界\n面',
                        style: TextStyle(fontSize: 19, color: logic.selectIndex.value == 0 ? Colors.yellow : appTheme.color),
                      ),
                    ),
                  ),
                  onTap: () {
                    logic.selectIndex.value = 0;
                  },
                ),
                GestureDetector(
                  child: Container(
                    width: Common.optionWidgetWidth,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    alignment: Alignment.center,
                    child: CustomPaint(
                      painter: TrapeziumPainter(color: logic.selectIndex.value == 1 ? appTheme.commandBarColor : Colors.transparent),
                      child: Text(
                        '国\n际\n期\n货',
                        style: TextStyle(fontSize: 19, color: logic.selectIndex.value == 1 ? Colors.yellow : appTheme.color),
                      ),
                    ),
                  ),
                  onTap: () {
                    logic.selectIndex.value = 1;
                  },
                ),
              ],
            ),
          ),
          Expanded(child: logic.viewIndex.value == 0 ? const QuoteData() : QuoteDetails(logic.selectedContract.value))
        ],
      );
    });
  }
}
