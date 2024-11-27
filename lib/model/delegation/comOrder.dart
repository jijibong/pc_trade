class ComOrder {
  String? name;
  String? code;
  String? date; //日期
  String? time; //时间
  String? oc; //开平
  String? bs; //买卖
  double? price; //成交价格
  int? comNum; //成交数量
  String? comNo; //成交编号
  String? deleNo; //委托号
  bool? isHistory; //历史
  int? timeStamp; //时间戳
  int? OpenClose; //开平
  String? CurrencyType; //币种
  double? FeeValue; //手续费
  String? FeeCurrency; //手续费币种
  double? FutureTickSize; //合约跳价
  bool selected = false;

  ComOrder({
    this.name,
    this.code,
    this.date,
    this.time,
    this.oc,
    this.bs,
    this.price,
    this.comNum,
    this.comNo,
    this.deleNo,
    this.isHistory,
    this.timeStamp,
    this.OpenClose,
    this.CurrencyType,
    this.FeeValue,
    this.FeeCurrency,
    this.FutureTickSize,
  });

  ComOrder.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    date = json['date'];
    time = json['time'];
    oc = json['oc'];
    bs = json['bs'];
    price = json['price']?.toDouble();
    comNum = json['comNum'];
    comNo = json['comNo'];
    deleNo = json['deleNo'];
    isHistory = json['isHistory'];
    timeStamp = json['timeStamp'];
    OpenClose = json['OpenClose'];
    CurrencyType = json['CurrencyType'];
    FeeValue = json['FeeValue']?.toDouble();
    FeeCurrency = json['FeeCurrency'];
    FutureTickSize = json['FutureTickSize']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'date': date,
      'time': time,
      'oc': oc,
      'bs': bs,
      'price': price,
      'comNum': comNum,
      'comNo': comNo,
      'deleNo': deleNo,
      'isHistory': isHistory,
      'timeStamp': timeStamp,
      'OpenClose': OpenClose,
      'CurrencyType': CurrencyType,
      'FeeValue': FeeValue,
      'FeeCurrency': FeeCurrency,
      'FutureTickSize': FutureTickSize,
    };
  }
}
