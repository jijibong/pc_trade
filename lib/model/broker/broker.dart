class Broker {
  String? brokerId;
  String? brokerName;
  String? tradeUrl;
  String? tradePort;
  String? quoteUrl;
  String? quotePort;
  String? time;
  int? environmentalType;

  Broker({this.brokerId, this.brokerName, this.tradeUrl, this.tradePort, this.quoteUrl, this.quotePort, this.time, this.environmentalType});

  Broker.fromJson(Map<String, dynamic> json) {
    brokerId = json['BrokerId'];
    brokerName = json['BrokerName'];
    tradeUrl = json['TradeUrl'];
    tradePort = json['TradePort'];
    quoteUrl = json['QuoteUrl'];
    quotePort = json['QuotePort'];
    time = json['Time'];
    environmentalType = json['EnvironmentalType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BrokerId'] = brokerId;
    data['BrokerName'] = brokerName;
    data['TradeUrl'] = tradeUrl;
    data['TradePort'] = tradePort;
    data['QuoteUrl'] = quoteUrl;
    data['QuotePort'] = quotePort;
    data['Time'] = time;
    data['EnvironmentalType'] = environmentalType;
    return data;
  }
}

class IpAddress {
  String? cip;
  String? cid;
  String? cname;

  IpAddress({this.cip, this.cid, this.cname});

  IpAddress.fromJson(Map<String, dynamic> json) {
    cip = json['cip'];
    cid = json['cid'];
    cname = json['cname'];
  }
}
