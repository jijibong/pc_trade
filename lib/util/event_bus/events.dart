import 'package:trade/model/option/sector.dart';

import '../../model/delegation/res_comm_order.dart';
import '../../model/delegation/res_del_order.dart';
import '../../model/k/custom_line.dart';
import '../../model/k/k_preiod.dart';
import '../../model/pb/quote/fill.pb.dart';
import '../../model/quote/contract.dart';
import '../../model/trade/fund.dart';
import '../../model/trade/res_float_profit.dart';
import '../../model/trade/res_hold_order.dart';

///刷新
class RefreshEvent {}

///返回
class BackEvent {
  int index;
  BackEvent(this.index);
}

///放大分屏
class SelectScreen {
  int index;
  SelectScreen(this.index);
}

///保存页面
class SavePage {
  String name;
  SavePage(this.name);
}

///连接状态
class SocketState {
  bool connected;
  SocketState(this.connected);
}

///获取所有合约
class GetAllContracts {}

///跳转品种
class RefreshCommodity {
  int index;
  RefreshCommodity(this.index);
}

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

class LoginSuccess {
  bool success;
  LoginSuccess(this.success);
}

///切换分屏
class SplitScreen {
  int index;
  SplitScreen(this.index);
}

///显示交易窗口
class ShowTrade {
  bool show;
  ShowTrade(this.show);
}

///显示K线
class GoKChart {
  bool go;
  int index;
  GoKChart(this.go, this.index);
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
  int index;
  Contract contract;
  SwitchContract(this.index, this.contract);
}

///添加自选
class AddOptionEvent {
  Sector sector;
  Contract contract;
  bool add;
  AddOptionEvent(this.sector, this.contract, this.add);
}

///自选更新
class UpdateOptionEvent {}

///自选更新
class OptionRefresh {
  List<Contract> contractList;
  OptionRefresh(this.contractList);
}

///画线
class OrderDrawing {
  int type;
  int num;
  String price;
  OrderDrawing(this.type, this.num, this.price);
}

///画线工具画线
class ToolDrawing {
  int pathType;
  int colorValue;
  int widthType;
  int lineType;
  ToolDrawing(this.pathType, this.colorValue, this.widthType, this.lineType);
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

///持仓事件刷新
class RefreshHold {}

///持仓浮盈事件
class PositionFloatEvent {
  ResFloatProfit res;
  PositionFloatEvent({required this.res});
}

///画线设置
class SetLine {
  dynamic json;
  SetLine({required this.json});
}

///画线工具箱
class DrawEvent {
  dynamic json;
  DrawEvent({required this.json});
}

///画线下单
class OrderEvent {
  dynamic json;
  OrderEvent({required this.json});
}

///板块更新
class SectorEvent {
  String json;
  SectorEvent({required this.json});
}

