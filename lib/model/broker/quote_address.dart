/**
 * 行情地址
 */
class QuoteAddr {
  int? id;
  String? name;
  String? quoteHost;
  int? quotePort;
  int? platAttr;
  String? time;

  QuoteAddr({this.id, this.name, this.quoteHost, this.quotePort, this.platAttr, this.time});

  QuoteAddr.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    quoteHost = json['QuoteHost'];
    quotePort = json['QuotePort'];
    platAttr = json['PlatAttr'];
    time = json['Time'];
  }
}
