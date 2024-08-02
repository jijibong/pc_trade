class Rate {
  String? currency;
  double? rate;
  int? type;

  Rate({this.currency, this.rate, this.type});

  Rate.fromJson(Map<String, dynamic> json) {
    currency = json['Currency'];
    rate = json['Rate']?.toDouble();
    type = json['Type'];
  }

}
