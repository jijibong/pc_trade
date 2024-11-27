/**
 * 委托单
 */
class DelegateOrder {
  String? name;
  String? code;
  String? exCode;
  String? date;
  String? time;
  int? timeStamp;
  String? oc;
  String? bs;
  double? price;
  double? FutureTickSize;
  int? deleNum;
  int? comNum;
  int? OpenClose;
  int? comType;
  int? orderType;
  int? orderOpType;
  String? state;
  String? CurrencyType;
  String? deleNo;
  String? ErrorText;
  bool? isHistory;
  bool selected = false;

  DelegateOrder({
    this.name,
    this.code,
    this.exCode,
    this.date,
    this.time,
    this.timeStamp,
    this.oc,
    this.bs,
    this.price,
    this.FutureTickSize,
    this.deleNum,
    this.comNum,
    this.OpenClose,
    this.comType,
    this.orderType,
    this.orderOpType,
    this.state,
    this.CurrencyType,
    this.deleNo,
    this.ErrorText,
    this.isHistory,
  });

  DelegateOrder.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    exCode = json['exCode'];
    date = json['date'];
    time = json['time'];
    timeStamp = json['timeStamp'];
    oc = json['oc'];
    bs = json['bs'];
    price = json['price']?.toDouble();
    FutureTickSize = json['FutureTickSize']?.toDouble();
    deleNum = json['deleNum'];
    comNum = json['comNum'];
    OpenClose = json['OpenClose'];
    comType = json['comType'];
    orderType = json['orderType'];
    orderOpType = json['orderOpType'];
    state = json['state'];
    CurrencyType = json['CurrencyType'];
    deleNo = json['deleNo'];
    ErrorText = json['ErrorText'];
    isHistory = json['isHistory'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'exCode': exCode,
      'date': date,
      'time': time,
      'timeStamp': timeStamp,
      'oc': oc,
      'bs': bs,
      'price': price,
      'FutureTickSize': FutureTickSize,
      'deleNum': deleNum,
      'comNum': comNum,
      'OpenClose': OpenClose,
      'comType': comType,
      'orderType': orderType,
      'orderOpType': orderOpType,
      'state': state,
      'CurrencyType': CurrencyType,
      'deleNo': deleNo,
      'ErrorText': ErrorText,
      'isHistory': isHistory,
    };
  }
}
