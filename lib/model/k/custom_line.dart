import 'package:fluent_ui/fluent_ui.dart';

class CustomLine {
  String? code;
  int? type;
  int? num;
  int? side;
  double? kPrice;
  String? price;
  double? lineY;
  Path? path;
  Color color = Colors.white;

  CustomLine({
    this.code,
    this.type,
    this.num,
    this.side,
    this.kPrice,
    this.price,
    this.lineY,
    this.path,
  });

  CustomLine copyWith({String? code, int? type, int? num, int? side, double? kPrice, String? price, double? lineY, Path? path}) {
    return CustomLine(
        code: code ?? this.code,
        type: type ?? this.type,
        num: num ?? this.num,
        side: side ?? this.side,
        kPrice: kPrice ?? this.kPrice,
        price: price ?? this.price,
        lineY: lineY ?? this.lineY,
        path: path ?? this.path);
  }

  CustomLine.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    num = json['num'];
    side = json['side'];
    kPrice = json['kPrice'];
    price = json['price'];
    lineY = json['lineY'];
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'num': num,
      'side': side,
      'kPrice': kPrice,
      'price': price,
      'lineY': lineY,
    };
  }
}
