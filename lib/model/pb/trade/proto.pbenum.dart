//
//  Generated code. Do not modify.
//  source: proto/trade/proto.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 通知类型
class CDFYRspUserLogOutField_LogoutType extends $pb.ProtobufEnum {
  static const CDFYRspUserLogOutField_LogoutType UNIVERSAL = CDFYRspUserLogOutField_LogoutType._(0, _omitEnumNames ? '' : 'UNIVERSAL');
  static const CDFYRspUserLogOutField_LogoutType INITIATIVE = CDFYRspUserLogOutField_LogoutType._(1, _omitEnumNames ? '' : 'INITIATIVE');
  static const CDFYRspUserLogOutField_LogoutType PASSIVE = CDFYRspUserLogOutField_LogoutType._(2, _omitEnumNames ? '' : 'PASSIVE');

  static const $core.List<CDFYRspUserLogOutField_LogoutType> values = <CDFYRspUserLogOutField_LogoutType> [
    UNIVERSAL,
    INITIATIVE,
    PASSIVE,
  ];

  static final $core.Map<$core.int, CDFYRspUserLogOutField_LogoutType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CDFYRspUserLogOutField_LogoutType? valueOf($core.int value) => _byValue[value];

  const CDFYRspUserLogOutField_LogoutType._($core.int v, $core.String n) : super(v, n);
}

/// 通知类型
class CDFYRspOnAccountRiskWarning_AODType extends $pb.ProtobufEnum {
  static const CDFYRspOnAccountRiskWarning_AODType UNIVERSAL = CDFYRspOnAccountRiskWarning_AODType._(0, _omitEnumNames ? '' : 'UNIVERSAL');
  static const CDFYRspOnAccountRiskWarning_AODType Add = CDFYRspOnAccountRiskWarning_AODType._(1, _omitEnumNames ? '' : 'Add');
  static const CDFYRspOnAccountRiskWarning_AODType Del = CDFYRspOnAccountRiskWarning_AODType._(2, _omitEnumNames ? '' : 'Del');

  static const $core.List<CDFYRspOnAccountRiskWarning_AODType> values = <CDFYRspOnAccountRiskWarning_AODType> [
    UNIVERSAL,
    Add,
    Del,
  ];

  static final $core.Map<$core.int, CDFYRspOnAccountRiskWarning_AODType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CDFYRspOnAccountRiskWarning_AODType? valueOf($core.int value) => _byValue[value];

  const CDFYRspOnAccountRiskWarning_AODType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
