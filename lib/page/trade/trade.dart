import 'dart:ffi';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:trade/model/user/user.dart';
import 'package:trade/page/quote/quote_logic.dart';
import 'package:trade/page/trade/trade_content.dart';
import 'package:trade/util/event_bus/events.dart';

import '../../model/trade/fund.dart';
import '../../server/user/user.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/theme/theme.dart';
import '../../util/utils/utils.dart';

class Trade extends StatefulWidget {
  const Trade({super.key});

  @override
  State<Trade> createState() => _TradeState();
}

class _TradeState extends State<Trade> {
  final QuoteLogic logic = Get.put(QuoteLogic());
  String mineAllAssets = "--";
  String mineAvailFunds = "--";
  double? mineOccMargin;
  double? mineFreezeMargin;
  double? mineRiskDegree;
  double? mineCloseProfit;
  double? mineFee;
  double? mineFloatPrice;

  getFund() {
    UserServer.getAccountFound().then((value) {
      if (value != null) {
        calcFloatProfit(value);
      }
    });
  }

  /// 计算浮盈
  void calcFloatProfit(ResFund mAccountInfo) {
    //可用资金 = 期初结存+平仓盈亏+浮动盈亏-保证金占用-保证金冻结-手续费+出入金-冻结手续费
    //客户权益=期初结存+平仓盈亏+浮动盈亏-手续费+出入金
    //保证金占用/用户权益*100%
    double canuse = mAccountInfo.Available?.toDouble() ?? 0;
    double all = mAccountInfo.Equity?.toDouble() ?? 1;
    double agree = all == 0 ? 0 : ((mAccountInfo.OccupyDeposit ?? 0) / all) * 100;
    mineAllAssets = Utils.double2Str(Utils.dealPointBigDecimal(all, 2));
    mineAvailFunds = Utils.double2Str(Utils.dealPointBigDecimal(canuse, 2));
    mineOccMargin = Utils.dealPointBigDecimal(mAccountInfo.OccupyDeposit?.toDouble(), 2);
    mineFreezeMargin = Utils.dealPointBigDecimal(mAccountInfo.FrozenDeposit?.toDouble(), 2);
    mineRiskDegree = Utils.dealPointBigDecimal(agree, 2);
    mineCloseProfit = Utils.dealPointBigDecimal(mAccountInfo.CloseProfit?.toDouble(), 2);
    mineFee = Utils.dealPointBigDecimal(mAccountInfo.Fee?.toDouble(), 2);

    double floatP = mAccountInfo.FloatProfit?.toDouble() ?? 0;
    mineFloatPrice = Utils.dealPointBigDecimal(floatP, 2);
    // if (floatP > 0) {
    //   mineFloatColor = Common.quote_red_color;
    // } else if (floatP < 0) {
    //   mineFloatColor = Common.quote_green_color;
    // } else {
    //   mineFloatColor = Colors.white;
    // }

    // if (mAccountInfo.CloseProfit != null) {
    //   if (mAccountInfo.CloseProfit! >= 0) {
    //     mineCloseProfitColor = Common.quote_red_color;
    //   } else {
    //     mineCloseProfitColor = Common.quote_green_color;
    //   }
    // }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    getFund();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return NavigationView(
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        height: 30,
        title: RichText(
          text: TextSpan(children: [
            TextSpan(text: UserUtils.currentUser?.nick ?? "", style: TextStyle(color: Colors.yellow)),
            TextSpan(text: "您好，您的可用资金：", style: TextStyle(color: appTheme.exchangeTextColor)),
            TextSpan(text: mineAvailFunds, style: TextStyle(color: Colors.yellow)),
            TextSpan(text: "   用户权益：", style: TextStyle(color: appTheme.exchangeTextColor)),
            TextSpan(text: mineAllAssets, style: TextStyle(color: Colors.yellow)),
            TextSpan(text: "   平仓盈亏：", style: TextStyle(color: appTheme.exchangeTextColor)),
            TextSpan(text: "${mineCloseProfit ?? 0}", style: TextStyle(color: Colors.red)),
            TextSpan(text: "   手续费：", style: TextStyle(color: appTheme.exchangeTextColor)),
            TextSpan(text: "${mineFee ?? 0}", style: TextStyle(color: Colors.yellow)),
            TextSpan(text: "   浮动盈亏：", style: TextStyle(color: appTheme.exchangeTextColor)),
            TextSpan(text: "${mineFloatPrice ?? 0}", style: TextStyle(color: Colors.red)),
            TextSpan(text: "   占用保证金：", style: TextStyle(color: appTheme.exchangeTextColor)),
            TextSpan(text: "${mineOccMargin ?? 0}", style: TextStyle(color: Colors.yellow)),
            TextSpan(text: "   风险度：", style: TextStyle(color: appTheme.exchangeTextColor)),
            TextSpan(text: mineRiskDegree != null ? "$mineRiskDegree%" : "0.0%", style: TextStyle(color: Colors.red)),
          ]),
        ),
        actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Button(
            onPressed: () {},
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(appTheme.commandBarColor),
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 3, horizontal: 12))),
            child: const Text('刷新', textAlign: TextAlign.center),
          ),
          const SizedBox(
            width: 15,
          ),
          Button(
            onPressed: () {},
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(appTheme.commandBarColor),
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 3, horizontal: 12))),
            child: const Text('锁定', textAlign: TextAlign.center),
          ),
          const SizedBox(
            width: 15,
          ),
          IconButton(
              icon: const Icon(FluentIcons.minimum_value, size: 22),
              style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 0))),
              onPressed: () {
                logic.showContent.value = !logic.showContent.value;
                EventBusUtil.getInstance().fire(ShowTrade(logic.showContent.value));
              }),
          IconButton(
              icon: const Icon(FluentIcons.sign_out, size: 22),
              style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.only(left: 10, right: 20))),
              onPressed: () {
                EventBusUtil.getInstance().fire(LoginEvent(false));
              }),
        ]),
      ),
      content: logic.showContent.value ? const TradeContent() : Container(),
    );
  }
}
