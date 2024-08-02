//
//  Generated code. Do not modify.
//  source: proto/trade/cmd.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Option extends $pb.ProtobufEnum {
  static const Option REQ_OPT_UNIVERSAL = Option._(0, _omitEnumNames ? '' : 'REQ_OPT_UNIVERSAL');
  static const Option REQ_OPT_AUTH = Option._(1, _omitEnumNames ? '' : 'REQ_OPT_AUTH');
  static const Option REQ_OPT_LOGOUT = Option._(2, _omitEnumNames ? '' : 'REQ_OPT_LOGOUT');
  static const Option REQ_SUBSCRIBE_SUB_ALL_PRIVATE = Option._(3, _omitEnumNames ? '' : 'REQ_SUBSCRIBE_SUB_ALL_PRIVATE');
  static const Option REQ_SUBSCRIBE_SUB_PART_PRIVATE = Option._(4, _omitEnumNames ? '' : 'REQ_SUBSCRIBE_SUB_PART_PRIVATE');
  static const Option REQ_SUBSCRIBE_SUB_POSITION_FLOAT = Option._(5, _omitEnumNames ? '' : 'REQ_SUBSCRIBE_SUB_POSITION_FLOAT');
  static const Option REQ_UN_SUBSCRIBE_SUB_POSITION_FLOAT = Option._(6, _omitEnumNames ? '' : 'REQ_UN_SUBSCRIBE_SUB_POSITION_FLOAT');
  static const Option REQ_UN_SUBSCRIBE_SUB_ALL_PRIVATE = Option._(7, _omitEnumNames ? '' : 'REQ_UN_SUBSCRIBE_SUB_ALL_PRIVATE');
  static const Option REQ_SUBSCRIBE_SUB_FUND = Option._(8, _omitEnumNames ? '' : 'REQ_SUBSCRIBE_SUB_FUND');
  static const Option REQ_UN_SUBSCRIBE_SUB_FUND = Option._(9, _omitEnumNames ? '' : 'REQ_UN_SUBSCRIBE_SUB_FUND');
  static const Option ON_ACCOUNT_FORCE_CLOSE = Option._(101, _omitEnumNames ? '' : 'ON_ACCOUNT_FORCE_CLOSE');
  static const Option ON_ACCOUNT_RISK_WARNING = Option._(102, _omitEnumNames ? '' : 'ON_ACCOUNT_RISK_WARNING');
  static const Option ON_ACCOUNT_FUND_UPDATE = Option._(103, _omitEnumNames ? '' : 'ON_ACCOUNT_FUND_UPDATE');
  static const Option ON_ACCOUNT_ORDER_UPDATE = Option._(104, _omitEnumNames ? '' : 'ON_ACCOUNT_ORDER_UPDATE');
  static const Option ON_ACCOUNT_FILL_UPDATE = Option._(105, _omitEnumNames ? '' : 'ON_ACCOUNT_FILL_UPDATE');
  static const Option ON_ACCOUNT_POSITION_UPDATE = Option._(106, _omitEnumNames ? '' : 'ON_ACCOUNT_POSITION_UPDATE');
  static const Option ON_ACCOUNT_POSITION_FLOAT = Option._(107, _omitEnumNames ? '' : 'ON_ACCOUNT_POSITION_FLOAT');
  static const Option ON_ACCOUNT_RATE_UPDATE = Option._(108, _omitEnumNames ? '' : 'ON_ACCOUNT_RATE_UPDATE');
  static const Option ON_ACCOUNT_FORCE_EXIT = Option._(109, _omitEnumNames ? '' : 'ON_ACCOUNT_FORCE_EXIT');

  static const $core.List<Option> values = <Option> [
    REQ_OPT_UNIVERSAL,
    REQ_OPT_AUTH,
    REQ_OPT_LOGOUT,
    REQ_SUBSCRIBE_SUB_ALL_PRIVATE,
    REQ_SUBSCRIBE_SUB_PART_PRIVATE,
    REQ_SUBSCRIBE_SUB_POSITION_FLOAT,
    REQ_UN_SUBSCRIBE_SUB_POSITION_FLOAT,
    REQ_UN_SUBSCRIBE_SUB_ALL_PRIVATE,
    REQ_SUBSCRIBE_SUB_FUND,
    REQ_UN_SUBSCRIBE_SUB_FUND,
    ON_ACCOUNT_FORCE_CLOSE,
    ON_ACCOUNT_RISK_WARNING,
    ON_ACCOUNT_FUND_UPDATE,
    ON_ACCOUNT_ORDER_UPDATE,
    ON_ACCOUNT_FILL_UPDATE,
    ON_ACCOUNT_POSITION_UPDATE,
    ON_ACCOUNT_POSITION_FLOAT,
    ON_ACCOUNT_RATE_UPDATE,
    ON_ACCOUNT_FORCE_EXIT,
  ];

  static final $core.Map<$core.int, Option> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Option? valueOf($core.int value) => _byValue[value];

  const Option._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
