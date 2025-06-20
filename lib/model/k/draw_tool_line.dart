import 'package:fluent_ui/fluent_ui.dart';

class DrawToolLine {
  String? id;
  String? period;
  int? pathType;
  int? colorValue;
  int? widthType;
  int? lineType;
  String? firstPointX;
  double? firstPointY;
  String? secondPointX;
  double? secondPointY;
  String? thirdPointX;
  double? thirdPointY;
  Path? path;
  bool selected = false;

  DrawToolLine({
    this.id,
    this.period,
    this.pathType,
    this.colorValue,
    this.widthType,
    this.lineType,
    this.firstPointX,
    this.firstPointY,
    this.secondPointX,
    this.secondPointY,
    this.thirdPointX,
    this.thirdPointY,
    this.path,
  });

  DrawToolLine copyWith(
      {String? id,
      String? period,
      int? pathType,
      int? colorValue,
      int? widthType,
      int? lineType,
      String? firstPointX,
      double? firstPointY,
      String? secondPointX,
      double? secondPointY,
      String? thirdPointX,
      double? thirdPointY,
      Path? path}) {
    return DrawToolLine(
        period: period ?? this.period,
        id: id ?? this.id,
        pathType: pathType ?? this.pathType,
        colorValue: colorValue ?? this.colorValue,
        widthType: widthType ?? this.widthType,
        lineType: lineType ?? this.lineType,
        firstPointX: firstPointX ?? this.firstPointX,
        firstPointY: firstPointY ?? this.firstPointY,
        secondPointX: secondPointX ?? this.secondPointX,
        secondPointY: secondPointY ?? this.secondPointY,
        thirdPointX: thirdPointX ?? this.thirdPointX,
        thirdPointY: thirdPointY ?? this.thirdPointY,
        path: path ?? this.path);
  }

  DrawToolLine.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    period = json['period'];
    pathType = json['pathType'];
    colorValue = json['colorValue'];
    widthType = json['widthType'];
    lineType = json['lineType'];
    firstPointX = json['firstPointX'];
    firstPointY = json['firstPointY'];
    secondPointX = json['secondPointX'];
    secondPointY = json['secondPointY'];
    thirdPointX = json['thirdPointX'];
    thirdPointY = json['thirdPointY'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'pathType': pathType,
      'colorValue': colorValue,
      'widthType': widthType,
      'lineType': lineType,
      'firstPointX': firstPointX,
      'firstPointY': firstPointY,
      'secondPointX': secondPointX,
      'secondPointY': secondPointY,
      'thirdPointX': thirdPointX,
      'thirdPointY': thirdPointY,
    };
  }
}
