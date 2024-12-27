import '../../model/delegation/res_comm_order.dart';
import '../../model/delegation/res_del_order.dart';
import '../../model/k/k_preiod.dart';
import '../../model/pb/quote/fill.pb.dart';
import '../../model/quote/contract.dart';
import '../../model/trade/fund.dart';
import '../../model/trade/res_float_profit.dart';
import '../../model/trade/res_hold_order.dart';

///获取所有合约
class GetAllContracts {}

///订阅行情
class SubEvent {
  List<String> json;
  int option;
  int? period;
  SubEvent(this.json, this.option, {this.period});
}

///更新行情
class QuoteEvent {
  Contract con;
  QuoteEvent(this.con);
}

///登录
class LoginEvent {}

class LoginSuccess {}

class SwitchExchange {
  int index;
  SwitchExchange(this.index);
}

///显示交易窗口
class ShowTrade {
  bool show;
  ShowTrade(this.show);
}

///显示K线
class GoKChart {
  bool go;
  GoKChart(this.go);
}

///K线放大/缩小
class ScaleKLine {
  bool enlarge;
  ScaleKLine(this.enlarge);
}

///显示盘口数据
class QuoteFilledData {
  FillData quoteFilledData;

  QuoteFilledData(this.quoteFilledData);
}

///切换K线周期
class SwitchPeriod {
  KPeriod kPeriod;

  SwitchPeriod(this.kPeriod);
}

///切换合约
class SwitchContract {
  Contract contract;

  SwitchContract(this.contract);
}

///K线更新矫正
class CorrKlineEvent {
  DataBean? data;
  String? key;

  CorrKlineEvent({this.data, this.key});
}

class DataBean {
  double? close;
  double? high;
  double? low;
  double? open;
  num? uxTime;
  double? volume;
  double? amount;

  DataBean({this.close, this.high, this.low, this.open, this.uxTime, this.volume, this.amount});
}

///委托事件
class FundUpdateEvent {
  ResFund res;
  FundUpdateEvent({required this.res});
}

///委托事件
class DelRecordEvent {
  ResDelOrder res;
  DelRecordEvent({required this.res});
}

///成交事件
class FillUpdateEvent {
  ResComOrder res;
  FillUpdateEvent({required this.res});
}

///持仓事件
class PositionUpdateEvent {
  ResHoldOrder res;
  PositionUpdateEvent({required this.res});
}

///持仓浮盈事件
class PositionFloatEvent {
  ResFloatProfit res;
  PositionFloatEvent({required this.res});
}
