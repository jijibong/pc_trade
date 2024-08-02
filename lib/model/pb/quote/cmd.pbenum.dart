//
//  Generated code. Do not modify.
//  source: proto/quote/cmd.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Option extends $pb.ProtobufEnum {
  static const Option OPT_start = Option._(0, _omitEnumNames ? '' : 'OPT_start');
  static const Option OPT_Auth = Option._(1, _omitEnumNames ? '' : 'OPT_Auth');
  static const Option OPT_Sub = Option._(2, _omitEnumNames ? '' : 'OPT_Sub');
  static const Option OPT_SubFill = Option._(3, _omitEnumNames ? '' : 'OPT_SubFill');
  static const Option OPT_UnSubFill = Option._(4, _omitEnumNames ? '' : 'OPT_UnSubFill');
  static const Option OPT_SubQuote = Option._(5, _omitEnumNames ? '' : 'OPT_SubQuote');
  static const Option OPT_UnSubQuote = Option._(6, _omitEnumNames ? '' : 'OPT_UnSubQuote');
  static const Option OPT_SubKline = Option._(7, _omitEnumNames ? '' : 'OPT_SubKline');
  static const Option OPT_UnSubKline = Option._(8, _omitEnumNames ? '' : 'OPT_UnSubKline');
  static const Option OPT_RtnFill = Option._(9, _omitEnumNames ? '' : 'OPT_RtnFill');
  static const Option OPT_RtnQuote = Option._(10, _omitEnumNames ? '' : 'OPT_RtnQuote');
  static const Option OPT_RtnKline = Option._(11, _omitEnumNames ? '' : 'OPT_RtnKline');
  static const Option OPT_UnSubAll = Option._(20, _omitEnumNames ? '' : 'OPT_UnSubAll');

  static const $core.List<Option> values = <Option> [
    OPT_start,
    OPT_Auth,
    OPT_Sub,
    OPT_SubFill,
    OPT_UnSubFill,
    OPT_SubQuote,
    OPT_UnSubQuote,
    OPT_SubKline,
    OPT_UnSubKline,
    OPT_RtnFill,
    OPT_RtnQuote,
    OPT_RtnKline,
    OPT_UnSubAll,
  ];

  static final $core.Map<$core.int, Option> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Option? valueOf($core.int value) => _byValue[value];

  const Option._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
