class OHLCEntity {
  num? open; // 开盘价
  num? high; // 最高价
  num? low; // 最低价
  num? close; // 收盘价
  num? preClose; //昨日收盘价
  num? amount; // 成交额
  int? volume; // 成交量
  int? sAllVolume; // 周期开始总成交量
  num? average; //平均价
  String? date; // 日期，如：2013-09-18
  String? time; // 时间，如：18:25
  String? code; // 代码，如：LSAG15
  String? name; // 代码，如：LSAG15
  int? timeStamp; // 时间戳.
  int? customStamp; // 自定义K线计算
  int? customVolume; // 自定义K线计算
  num? customAmount; // 自定义K线计算
  int? id;

  OHLCEntity({
    this.open,
    this.high,
    this.low,
    this.close,
    this.preClose,
    this.amount,
    this.volume,
    this.sAllVolume,
    this.average,
    this.date,
    this.time,
    this.code,
    this.name,
    this.timeStamp,
    this.customStamp,
    this.customVolume,
    this.customAmount,
    this.id,
  });

  OHLCEntity.fromJson(Map<String, dynamic> json) {
    open = json['open'] != null ? double.tryParse(json['open']) : 0;
    high = json['open'] != null ? double.tryParse(json['high']) : 0;
    low = json['low'] != null ? double.tryParse(json['low']) : 0;
    close = json['close'] != null ? double.tryParse(json['close']) : 0;
    preClose = json['preClose'] != null ? double.tryParse(json['preClose']) : 0;
    amount = json['amount'] != null ? int.tryParse(json['amount']) : 0;
    volume = json['volume'] != null ? int.tryParse(json['volume']) : 0;
    sAllVolume = json['sAllVolume'] != null ? int.tryParse(json['sAllVolume']) : 0;
    average = json['average'] != null ? double.tryParse(json['average']) : 0;
    date = json['date'];
    time = json['time'];
    code = json['code'];
    name = json['name'];
    timeStamp = json['timeStamp'] != null ? int.tryParse(json['timeStamp']) : 0;
    customStamp = json['customStamp'] != null ? int.tryParse(json['customStamp']) : 0;
    customVolume = json['customVolume'] != null ? int.tryParse(json['customVolume']) : 0;
    customAmount = json['customAmount'] != null ? double.tryParse(json['customAmount']) : 0;
    id = json['id'] != null ? int.tryParse(json['id']) : 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'preClose': preClose,
      'amount': amount,
      'volume': volume,
      'sAllVolume': sAllVolume,
      'average': average,
      'date': date,
      'time': time,
      'code': code,
      'name': name,
      'timeStamp': timeStamp,
      'customStamp': customStamp,
      'customVolume': customVolume,
      'customAmount': customAmount,
      'id': id,
    };
  }
}
