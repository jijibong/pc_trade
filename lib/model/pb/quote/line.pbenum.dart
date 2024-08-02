//
//  Generated code. Do not modify.
//  source: proto/quote/line.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Line extends $pb.ProtobufEnum {
  static const Line KL1M = Line._(0, _omitEnumNames ? '' : 'KL1M');
  static const Line KL5M = Line._(1, _omitEnumNames ? '' : 'KL5M');
  static const Line KL10M = Line._(2, _omitEnumNames ? '' : 'KL10M');
  static const Line KL15M = Line._(3, _omitEnumNames ? '' : 'KL15M');
  static const Line KL30M = Line._(4, _omitEnumNames ? '' : 'KL30M');
  static const Line KL1H = Line._(5, _omitEnumNames ? '' : 'KL1H');
  static const Line KL1D = Line._(6, _omitEnumNames ? '' : 'KL1D');
  static const Line KL3M = Line._(7, _omitEnumNames ? '' : 'KL3M');

  static const $core.List<Line> values = <Line> [
    KL1M,
    KL5M,
    KL10M,
    KL15M,
    KL30M,
    KL1H,
    KL1D,
    KL3M,
  ];

  static final $core.Map<$core.int, Line> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Line? valueOf($core.int value) => _byValue[value];

  const Line._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
