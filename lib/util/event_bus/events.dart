import '../../model/pb/quote/fill.pb.dart';
import '../../model/quote/contract.dart';

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
class LoginEvent{
  bool loginSuccess;
  LoginEvent(this.loginSuccess);
}

///显示交易窗口
class ShowTrade{
  bool show;
  ShowTrade(this.show);
}

///显示交易窗口
class GoKChart{
  bool go;
  GoKChart(this.go);
}

///显示盘口数据
class QuoteFilledData {
  FillData quoteFilledData;

  QuoteFilledData(this.quoteFilledData);
}

