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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'proto.pbenum.dart';

export 'proto.pbenum.dart';

/// REQ_OPT_AUTH message
class CDFYReqUserAuthField extends $pb.GeneratedMessage {
  factory CDFYReqUserAuthField({
    $core.String? token,
  }) {
    final $result = create();
    if (token != null) {
      $result.token = token;
    }
    return $result;
  }
  CDFYReqUserAuthField._() : super();
  factory CDFYReqUserAuthField.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYReqUserAuthField.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYReqUserAuthField', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Token', protoName: 'Token')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYReqUserAuthField clone() => CDFYReqUserAuthField()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYReqUserAuthField copyWith(void Function(CDFYReqUserAuthField) updates) => super.copyWith((message) => updates(message as CDFYReqUserAuthField)) as CDFYReqUserAuthField;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYReqUserAuthField create() => CDFYReqUserAuthField._();
  CDFYReqUserAuthField createEmptyInstance() => create();
  static $pb.PbList<CDFYReqUserAuthField> createRepeated() => $pb.PbList<CDFYReqUserAuthField>();
  @$core.pragma('dart2js:noInline')
  static CDFYReqUserAuthField getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYReqUserAuthField>(create);
  static CDFYReqUserAuthField? _defaultInstance;

  /// token
  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => clearField(1);
}

/// RSP_OPT_LOGIN message
class CDFYRspUserAuthField extends $pb.GeneratedMessage {
  factory CDFYRspUserAuthField({
    $core.int? code,
    $core.String? msg,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  CDFYRspUserAuthField._() : super();
  factory CDFYRspUserAuthField.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYRspUserAuthField.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYRspUserAuthField', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'Msg', protoName: 'Msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYRspUserAuthField clone() => CDFYRspUserAuthField()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYRspUserAuthField copyWith(void Function(CDFYRspUserAuthField) updates) => super.copyWith((message) => updates(message as CDFYRspUserAuthField)) as CDFYRspUserAuthField;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYRspUserAuthField create() => CDFYRspUserAuthField._();
  CDFYRspUserAuthField createEmptyInstance() => create();
  static $pb.PbList<CDFYRspUserAuthField> createRepeated() => $pb.PbList<CDFYRspUserAuthField>();
  @$core.pragma('dart2js:noInline')
  static CDFYRspUserAuthField getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYRspUserAuthField>(create);
  static CDFYRspUserAuthField? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// 消息
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

/// DEF message
class LoginOutReq extends $pb.GeneratedMessage {
  factory LoginOutReq() => create();
  LoginOutReq._() : super();
  factory LoginOutReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoginOutReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginOutReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoginOutReq clone() => LoginOutReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoginOutReq copyWith(void Function(LoginOutReq) updates) => super.copyWith((message) => updates(message as LoginOutReq)) as LoginOutReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginOutReq create() => LoginOutReq._();
  LoginOutReq createEmptyInstance() => create();
  static $pb.PbList<LoginOutReq> createRepeated() => $pb.PbList<LoginOutReq>();
  @$core.pragma('dart2js:noInline')
  static LoginOutReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginOutReq>(create);
  static LoginOutReq? _defaultInstance;
}

class LoginOutResp extends $pb.GeneratedMessage {
  factory LoginOutResp({
    $core.int? code,
    $core.String? msg,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  LoginOutResp._() : super();
  factory LoginOutResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoginOutResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginOutResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'Msg', protoName: 'Msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoginOutResp clone() => LoginOutResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoginOutResp copyWith(void Function(LoginOutResp) updates) => super.copyWith((message) => updates(message as LoginOutResp)) as LoginOutResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginOutResp create() => LoginOutResp._();
  LoginOutResp createEmptyInstance() => create();
  static $pb.PbList<LoginOutResp> createRepeated() => $pb.PbList<LoginOutResp>();
  @$core.pragma('dart2js:noInline')
  static LoginOutResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginOutResp>(create);
  static LoginOutResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// 消息
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class SubscribeSubPartPrivateReq extends $pb.GeneratedMessage {
  factory SubscribeSubPartPrivateReq() => create();
  SubscribeSubPartPrivateReq._() : super();
  factory SubscribeSubPartPrivateReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeSubPartPrivateReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeSubPartPrivateReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeSubPartPrivateReq clone() => SubscribeSubPartPrivateReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeSubPartPrivateReq copyWith(void Function(SubscribeSubPartPrivateReq) updates) => super.copyWith((message) => updates(message as SubscribeSubPartPrivateReq)) as SubscribeSubPartPrivateReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeSubPartPrivateReq create() => SubscribeSubPartPrivateReq._();
  SubscribeSubPartPrivateReq createEmptyInstance() => create();
  static $pb.PbList<SubscribeSubPartPrivateReq> createRepeated() => $pb.PbList<SubscribeSubPartPrivateReq>();
  @$core.pragma('dart2js:noInline')
  static SubscribeSubPartPrivateReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeSubPartPrivateReq>(create);
  static SubscribeSubPartPrivateReq? _defaultInstance;
}

class SSubscribeSubPartPrivateResp extends $pb.GeneratedMessage {
  factory SSubscribeSubPartPrivateResp({
    $core.int? code,
    $core.String? msg,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  SSubscribeSubPartPrivateResp._() : super();
  factory SSubscribeSubPartPrivateResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SSubscribeSubPartPrivateResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SSubscribeSubPartPrivateResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'Msg', protoName: 'Msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SSubscribeSubPartPrivateResp clone() => SSubscribeSubPartPrivateResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SSubscribeSubPartPrivateResp copyWith(void Function(SSubscribeSubPartPrivateResp) updates) => super.copyWith((message) => updates(message as SSubscribeSubPartPrivateResp)) as SSubscribeSubPartPrivateResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SSubscribeSubPartPrivateResp create() => SSubscribeSubPartPrivateResp._();
  SSubscribeSubPartPrivateResp createEmptyInstance() => create();
  static $pb.PbList<SSubscribeSubPartPrivateResp> createRepeated() => $pb.PbList<SSubscribeSubPartPrivateResp>();
  @$core.pragma('dart2js:noInline')
  static SSubscribeSubPartPrivateResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SSubscribeSubPartPrivateResp>(create);
  static SSubscribeSubPartPrivateResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// 消息
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class ReqSubscribeSubAllPrivateReq extends $pb.GeneratedMessage {
  factory ReqSubscribeSubAllPrivateReq() => create();
  ReqSubscribeSubAllPrivateReq._() : super();
  factory ReqSubscribeSubAllPrivateReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqSubscribeSubAllPrivateReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqSubscribeSubAllPrivateReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqSubscribeSubAllPrivateReq clone() => ReqSubscribeSubAllPrivateReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqSubscribeSubAllPrivateReq copyWith(void Function(ReqSubscribeSubAllPrivateReq) updates) => super.copyWith((message) => updates(message as ReqSubscribeSubAllPrivateReq)) as ReqSubscribeSubAllPrivateReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqSubscribeSubAllPrivateReq create() => ReqSubscribeSubAllPrivateReq._();
  ReqSubscribeSubAllPrivateReq createEmptyInstance() => create();
  static $pb.PbList<ReqSubscribeSubAllPrivateReq> createRepeated() => $pb.PbList<ReqSubscribeSubAllPrivateReq>();
  @$core.pragma('dart2js:noInline')
  static ReqSubscribeSubAllPrivateReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqSubscribeSubAllPrivateReq>(create);
  static ReqSubscribeSubAllPrivateReq? _defaultInstance;
}

class ReqSubscribeSubAllPrivateResp extends $pb.GeneratedMessage {
  factory ReqSubscribeSubAllPrivateResp({
    $core.int? code,
    $core.String? msg,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  ReqSubscribeSubAllPrivateResp._() : super();
  factory ReqSubscribeSubAllPrivateResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqSubscribeSubAllPrivateResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqSubscribeSubAllPrivateResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'Msg', protoName: 'Msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqSubscribeSubAllPrivateResp clone() => ReqSubscribeSubAllPrivateResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqSubscribeSubAllPrivateResp copyWith(void Function(ReqSubscribeSubAllPrivateResp) updates) => super.copyWith((message) => updates(message as ReqSubscribeSubAllPrivateResp)) as ReqSubscribeSubAllPrivateResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqSubscribeSubAllPrivateResp create() => ReqSubscribeSubAllPrivateResp._();
  ReqSubscribeSubAllPrivateResp createEmptyInstance() => create();
  static $pb.PbList<ReqSubscribeSubAllPrivateResp> createRepeated() => $pb.PbList<ReqSubscribeSubAllPrivateResp>();
  @$core.pragma('dart2js:noInline')
  static ReqSubscribeSubAllPrivateResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqSubscribeSubAllPrivateResp>(create);
  static ReqSubscribeSubAllPrivateResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// 消息
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class ReqSubscribeSubPrivateFloatReq extends $pb.GeneratedMessage {
  factory ReqSubscribeSubPrivateFloatReq() => create();
  ReqSubscribeSubPrivateFloatReq._() : super();
  factory ReqSubscribeSubPrivateFloatReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqSubscribeSubPrivateFloatReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqSubscribeSubPrivateFloatReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqSubscribeSubPrivateFloatReq clone() => ReqSubscribeSubPrivateFloatReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqSubscribeSubPrivateFloatReq copyWith(void Function(ReqSubscribeSubPrivateFloatReq) updates) => super.copyWith((message) => updates(message as ReqSubscribeSubPrivateFloatReq)) as ReqSubscribeSubPrivateFloatReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqSubscribeSubPrivateFloatReq create() => ReqSubscribeSubPrivateFloatReq._();
  ReqSubscribeSubPrivateFloatReq createEmptyInstance() => create();
  static $pb.PbList<ReqSubscribeSubPrivateFloatReq> createRepeated() => $pb.PbList<ReqSubscribeSubPrivateFloatReq>();
  @$core.pragma('dart2js:noInline')
  static ReqSubscribeSubPrivateFloatReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqSubscribeSubPrivateFloatReq>(create);
  static ReqSubscribeSubPrivateFloatReq? _defaultInstance;
}

class ReqSubscribeSubPrivateFloatResp extends $pb.GeneratedMessage {
  factory ReqSubscribeSubPrivateFloatResp({
    $core.int? code,
    $core.String? msg,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  ReqSubscribeSubPrivateFloatResp._() : super();
  factory ReqSubscribeSubPrivateFloatResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqSubscribeSubPrivateFloatResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqSubscribeSubPrivateFloatResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'Msg', protoName: 'Msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqSubscribeSubPrivateFloatResp clone() => ReqSubscribeSubPrivateFloatResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqSubscribeSubPrivateFloatResp copyWith(void Function(ReqSubscribeSubPrivateFloatResp) updates) => super.copyWith((message) => updates(message as ReqSubscribeSubPrivateFloatResp)) as ReqSubscribeSubPrivateFloatResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqSubscribeSubPrivateFloatResp create() => ReqSubscribeSubPrivateFloatResp._();
  ReqSubscribeSubPrivateFloatResp createEmptyInstance() => create();
  static $pb.PbList<ReqSubscribeSubPrivateFloatResp> createRepeated() => $pb.PbList<ReqSubscribeSubPrivateFloatResp>();
  @$core.pragma('dart2js:noInline')
  static ReqSubscribeSubPrivateFloatResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqSubscribeSubPrivateFloatResp>(create);
  static ReqSubscribeSubPrivateFloatResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// 消息
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class ReqUnsubscribeAllReq extends $pb.GeneratedMessage {
  factory ReqUnsubscribeAllReq() => create();
  ReqUnsubscribeAllReq._() : super();
  factory ReqUnsubscribeAllReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqUnsubscribeAllReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqUnsubscribeAllReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeAllReq clone() => ReqUnsubscribeAllReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeAllReq copyWith(void Function(ReqUnsubscribeAllReq) updates) => super.copyWith((message) => updates(message as ReqUnsubscribeAllReq)) as ReqUnsubscribeAllReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeAllReq create() => ReqUnsubscribeAllReq._();
  ReqUnsubscribeAllReq createEmptyInstance() => create();
  static $pb.PbList<ReqUnsubscribeAllReq> createRepeated() => $pb.PbList<ReqUnsubscribeAllReq>();
  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeAllReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqUnsubscribeAllReq>(create);
  static ReqUnsubscribeAllReq? _defaultInstance;
}

class ReqUnsubscribeAllResp extends $pb.GeneratedMessage {
  factory ReqUnsubscribeAllResp({
    $core.int? code,
    $core.String? msg,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  ReqUnsubscribeAllResp._() : super();
  factory ReqUnsubscribeAllResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqUnsubscribeAllResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqUnsubscribeAllResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'Msg', protoName: 'Msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeAllResp clone() => ReqUnsubscribeAllResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeAllResp copyWith(void Function(ReqUnsubscribeAllResp) updates) => super.copyWith((message) => updates(message as ReqUnsubscribeAllResp)) as ReqUnsubscribeAllResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeAllResp create() => ReqUnsubscribeAllResp._();
  ReqUnsubscribeAllResp createEmptyInstance() => create();
  static $pb.PbList<ReqUnsubscribeAllResp> createRepeated() => $pb.PbList<ReqUnsubscribeAllResp>();
  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeAllResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqUnsubscribeAllResp>(create);
  static ReqUnsubscribeAllResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// 消息
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class ReqUnsubscribeFloatReq extends $pb.GeneratedMessage {
  factory ReqUnsubscribeFloatReq() => create();
  ReqUnsubscribeFloatReq._() : super();
  factory ReqUnsubscribeFloatReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqUnsubscribeFloatReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqUnsubscribeFloatReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeFloatReq clone() => ReqUnsubscribeFloatReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeFloatReq copyWith(void Function(ReqUnsubscribeFloatReq) updates) => super.copyWith((message) => updates(message as ReqUnsubscribeFloatReq)) as ReqUnsubscribeFloatReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeFloatReq create() => ReqUnsubscribeFloatReq._();
  ReqUnsubscribeFloatReq createEmptyInstance() => create();
  static $pb.PbList<ReqUnsubscribeFloatReq> createRepeated() => $pb.PbList<ReqUnsubscribeFloatReq>();
  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeFloatReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqUnsubscribeFloatReq>(create);
  static ReqUnsubscribeFloatReq? _defaultInstance;
}

class ReqUnsubscribeFloatResp extends $pb.GeneratedMessage {
  factory ReqUnsubscribeFloatResp({
    $core.int? code,
    $core.String? msg,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  ReqUnsubscribeFloatResp._() : super();
  factory ReqUnsubscribeFloatResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqUnsubscribeFloatResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqUnsubscribeFloatResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'Msg', protoName: 'Msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeFloatResp clone() => ReqUnsubscribeFloatResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeFloatResp copyWith(void Function(ReqUnsubscribeFloatResp) updates) => super.copyWith((message) => updates(message as ReqUnsubscribeFloatResp)) as ReqUnsubscribeFloatResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeFloatResp create() => ReqUnsubscribeFloatResp._();
  ReqUnsubscribeFloatResp createEmptyInstance() => create();
  static $pb.PbList<ReqUnsubscribeFloatResp> createRepeated() => $pb.PbList<ReqUnsubscribeFloatResp>();
  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeFloatResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqUnsubscribeFloatResp>(create);
  static ReqUnsubscribeFloatResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// 消息
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class ReqSubscribeFundReq extends $pb.GeneratedMessage {
  factory ReqSubscribeFundReq() => create();
  ReqSubscribeFundReq._() : super();
  factory ReqSubscribeFundReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqSubscribeFundReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqSubscribeFundReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqSubscribeFundReq clone() => ReqSubscribeFundReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqSubscribeFundReq copyWith(void Function(ReqSubscribeFundReq) updates) => super.copyWith((message) => updates(message as ReqSubscribeFundReq)) as ReqSubscribeFundReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqSubscribeFundReq create() => ReqSubscribeFundReq._();
  ReqSubscribeFundReq createEmptyInstance() => create();
  static $pb.PbList<ReqSubscribeFundReq> createRepeated() => $pb.PbList<ReqSubscribeFundReq>();
  @$core.pragma('dart2js:noInline')
  static ReqSubscribeFundReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqSubscribeFundReq>(create);
  static ReqSubscribeFundReq? _defaultInstance;
}

class ReqSubscribeFundResp extends $pb.GeneratedMessage {
  factory ReqSubscribeFundResp({
    $core.int? code,
    $core.String? msg,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  ReqSubscribeFundResp._() : super();
  factory ReqSubscribeFundResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqSubscribeFundResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqSubscribeFundResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'Msg', protoName: 'Msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqSubscribeFundResp clone() => ReqSubscribeFundResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqSubscribeFundResp copyWith(void Function(ReqSubscribeFundResp) updates) => super.copyWith((message) => updates(message as ReqSubscribeFundResp)) as ReqSubscribeFundResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqSubscribeFundResp create() => ReqSubscribeFundResp._();
  ReqSubscribeFundResp createEmptyInstance() => create();
  static $pb.PbList<ReqSubscribeFundResp> createRepeated() => $pb.PbList<ReqSubscribeFundResp>();
  @$core.pragma('dart2js:noInline')
  static ReqSubscribeFundResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqSubscribeFundResp>(create);
  static ReqSubscribeFundResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// 消息
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class ReqUnsubscribeFundReq extends $pb.GeneratedMessage {
  factory ReqUnsubscribeFundReq() => create();
  ReqUnsubscribeFundReq._() : super();
  factory ReqUnsubscribeFundReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqUnsubscribeFundReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqUnsubscribeFundReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeFundReq clone() => ReqUnsubscribeFundReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeFundReq copyWith(void Function(ReqUnsubscribeFundReq) updates) => super.copyWith((message) => updates(message as ReqUnsubscribeFundReq)) as ReqUnsubscribeFundReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeFundReq create() => ReqUnsubscribeFundReq._();
  ReqUnsubscribeFundReq createEmptyInstance() => create();
  static $pb.PbList<ReqUnsubscribeFundReq> createRepeated() => $pb.PbList<ReqUnsubscribeFundReq>();
  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeFundReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqUnsubscribeFundReq>(create);
  static ReqUnsubscribeFundReq? _defaultInstance;
}

class ReqUnsubscribeFundResp extends $pb.GeneratedMessage {
  factory ReqUnsubscribeFundResp({
    $core.int? code,
    $core.String? msg,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  ReqUnsubscribeFundResp._() : super();
  factory ReqUnsubscribeFundResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReqUnsubscribeFundResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReqUnsubscribeFundResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'Msg', protoName: 'Msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeFundResp clone() => ReqUnsubscribeFundResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReqUnsubscribeFundResp copyWith(void Function(ReqUnsubscribeFundResp) updates) => super.copyWith((message) => updates(message as ReqUnsubscribeFundResp)) as ReqUnsubscribeFundResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeFundResp create() => ReqUnsubscribeFundResp._();
  ReqUnsubscribeFundResp createEmptyInstance() => create();
  static $pb.PbList<ReqUnsubscribeFundResp> createRepeated() => $pb.PbList<ReqUnsubscribeFundResp>();
  @$core.pragma('dart2js:noInline')
  static ReqUnsubscribeFundResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReqUnsubscribeFundResp>(create);
  static ReqUnsubscribeFundResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// 消息
  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

/// RSP_OPT_LOGOUT message
class CDFYRspUserLogOutField extends $pb.GeneratedMessage {
  factory CDFYRspUserLogOutField({
    CDFYRspUserLogOutField_LogoutType? lType,
    $core.String? message,
    $core.String? time,
  }) {
    final $result = create();
    if (lType != null) {
      $result.lType = lType;
    }
    if (message != null) {
      $result.message = message;
    }
    if (time != null) {
      $result.time = time;
    }
    return $result;
  }
  CDFYRspUserLogOutField._() : super();
  factory CDFYRspUserLogOutField.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYRspUserLogOutField.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYRspUserLogOutField', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..e<CDFYRspUserLogOutField_LogoutType>(1, _omitFieldNames ? '' : 'LType', $pb.PbFieldType.OE, protoName: 'LType', defaultOrMaker: CDFYRspUserLogOutField_LogoutType.UNIVERSAL, valueOf: CDFYRspUserLogOutField_LogoutType.valueOf, enumValues: CDFYRspUserLogOutField_LogoutType.values)
    ..aOS(2, _omitFieldNames ? '' : 'Message', protoName: 'Message')
    ..aOS(3, _omitFieldNames ? '' : 'Time', protoName: 'Time')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYRspUserLogOutField clone() => CDFYRspUserLogOutField()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYRspUserLogOutField copyWith(void Function(CDFYRspUserLogOutField) updates) => super.copyWith((message) => updates(message as CDFYRspUserLogOutField)) as CDFYRspUserLogOutField;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYRspUserLogOutField create() => CDFYRspUserLogOutField._();
  CDFYRspUserLogOutField createEmptyInstance() => create();
  static $pb.PbList<CDFYRspUserLogOutField> createRepeated() => $pb.PbList<CDFYRspUserLogOutField>();
  @$core.pragma('dart2js:noInline')
  static CDFYRspUserLogOutField getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYRspUserLogOutField>(create);
  static CDFYRspUserLogOutField? _defaultInstance;

  /// 类型
  @$pb.TagNumber(1)
  CDFYRspUserLogOutField_LogoutType get lType => $_getN(0);
  @$pb.TagNumber(1)
  set lType(CDFYRspUserLogOutField_LogoutType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasLType() => $_has(0);
  @$pb.TagNumber(1)
  void clearLType() => clearField(1);

  /// 消息
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  /// 时间
  @$pb.TagNumber(3)
  $core.String get time => $_getSZ(2);
  @$pb.TagNumber(3)
  set time($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => clearField(3);
}

class CDFYRspOnAccountForceClose extends $pb.GeneratedMessage {
  factory CDFYRspOnAccountForceClose({
    $fixnum.Int64? warningId,
    $fixnum.Int64? accountId,
    $core.String? accountNo,
    $core.String? userName,
    $core.String? topic,
    $core.String? info,
  }) {
    final $result = create();
    if (warningId != null) {
      $result.warningId = warningId;
    }
    if (accountId != null) {
      $result.accountId = accountId;
    }
    if (accountNo != null) {
      $result.accountNo = accountNo;
    }
    if (userName != null) {
      $result.userName = userName;
    }
    if (topic != null) {
      $result.topic = topic;
    }
    if (info != null) {
      $result.info = info;
    }
    return $result;
  }
  CDFYRspOnAccountForceClose._() : super();
  factory CDFYRspOnAccountForceClose.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYRspOnAccountForceClose.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYRspOnAccountForceClose', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'WarningId', protoName: 'WarningId')
    ..aInt64(2, _omitFieldNames ? '' : 'AccountId', protoName: 'AccountId')
    ..aOS(3, _omitFieldNames ? '' : 'AccountNo', protoName: 'AccountNo')
    ..aOS(4, _omitFieldNames ? '' : 'UserName', protoName: 'UserName')
    ..aOS(5, _omitFieldNames ? '' : 'topic')
    ..aOS(6, _omitFieldNames ? '' : 'info')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYRspOnAccountForceClose clone() => CDFYRspOnAccountForceClose()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYRspOnAccountForceClose copyWith(void Function(CDFYRspOnAccountForceClose) updates) => super.copyWith((message) => updates(message as CDFYRspOnAccountForceClose)) as CDFYRspOnAccountForceClose;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYRspOnAccountForceClose create() => CDFYRspOnAccountForceClose._();
  CDFYRspOnAccountForceClose createEmptyInstance() => create();
  static $pb.PbList<CDFYRspOnAccountForceClose> createRepeated() => $pb.PbList<CDFYRspOnAccountForceClose>();
  @$core.pragma('dart2js:noInline')
  static CDFYRspOnAccountForceClose getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYRspOnAccountForceClose>(create);
  static CDFYRspOnAccountForceClose? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get warningId => $_getI64(0);
  @$pb.TagNumber(1)
  set warningId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWarningId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWarningId() => clearField(1);

  /// 账户id
  @$pb.TagNumber(2)
  $fixnum.Int64 get accountId => $_getI64(1);
  @$pb.TagNumber(2)
  set accountId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountId() => clearField(2);

  /// 账号
  @$pb.TagNumber(3)
  $core.String get accountNo => $_getSZ(2);
  @$pb.TagNumber(3)
  set accountNo($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAccountNo() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccountNo() => clearField(3);

  /// 名称
  @$pb.TagNumber(4)
  $core.String get userName => $_getSZ(3);
  @$pb.TagNumber(4)
  set userName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUserName() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserName() => clearField(4);

  /// 标题
  @$pb.TagNumber(5)
  $core.String get topic => $_getSZ(4);
  @$pb.TagNumber(5)
  set topic($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTopic() => $_has(4);
  @$pb.TagNumber(5)
  void clearTopic() => clearField(5);

  /// 报警内容
  @$pb.TagNumber(6)
  $core.String get info => $_getSZ(5);
  @$pb.TagNumber(6)
  set info($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasInfo() => $_has(5);
  @$pb.TagNumber(6)
  void clearInfo() => clearField(6);
}

class CDFYRspOnAccountRiskWarning extends $pb.GeneratedMessage {
  factory CDFYRspOnAccountRiskWarning({
    $fixnum.Int64? warningId,
    $fixnum.Int64? accountId,
    $core.String? accountNo,
    $core.String? userName,
    CDFYRspOnAccountRiskWarning_AODType? type,
    $core.String? info,
  }) {
    final $result = create();
    if (warningId != null) {
      $result.warningId = warningId;
    }
    if (accountId != null) {
      $result.accountId = accountId;
    }
    if (accountNo != null) {
      $result.accountNo = accountNo;
    }
    if (userName != null) {
      $result.userName = userName;
    }
    if (type != null) {
      $result.type = type;
    }
    if (info != null) {
      $result.info = info;
    }
    return $result;
  }
  CDFYRspOnAccountRiskWarning._() : super();
  factory CDFYRspOnAccountRiskWarning.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYRspOnAccountRiskWarning.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYRspOnAccountRiskWarning', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'WarningId', protoName: 'WarningId')
    ..aInt64(2, _omitFieldNames ? '' : 'AccountId', protoName: 'AccountId')
    ..aOS(3, _omitFieldNames ? '' : 'AccountNo', protoName: 'AccountNo')
    ..aOS(4, _omitFieldNames ? '' : 'UserName', protoName: 'UserName')
    ..e<CDFYRspOnAccountRiskWarning_AODType>(5, _omitFieldNames ? '' : 'Type', $pb.PbFieldType.OE, protoName: 'Type', defaultOrMaker: CDFYRspOnAccountRiskWarning_AODType.UNIVERSAL, valueOf: CDFYRspOnAccountRiskWarning_AODType.valueOf, enumValues: CDFYRspOnAccountRiskWarning_AODType.values)
    ..aOS(6, _omitFieldNames ? '' : 'info')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYRspOnAccountRiskWarning clone() => CDFYRspOnAccountRiskWarning()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYRspOnAccountRiskWarning copyWith(void Function(CDFYRspOnAccountRiskWarning) updates) => super.copyWith((message) => updates(message as CDFYRspOnAccountRiskWarning)) as CDFYRspOnAccountRiskWarning;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYRspOnAccountRiskWarning create() => CDFYRspOnAccountRiskWarning._();
  CDFYRspOnAccountRiskWarning createEmptyInstance() => create();
  static $pb.PbList<CDFYRspOnAccountRiskWarning> createRepeated() => $pb.PbList<CDFYRspOnAccountRiskWarning>();
  @$core.pragma('dart2js:noInline')
  static CDFYRspOnAccountRiskWarning getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYRspOnAccountRiskWarning>(create);
  static CDFYRspOnAccountRiskWarning? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get warningId => $_getI64(0);
  @$pb.TagNumber(1)
  set warningId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWarningId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWarningId() => clearField(1);

  /// 账户id
  @$pb.TagNumber(2)
  $fixnum.Int64 get accountId => $_getI64(1);
  @$pb.TagNumber(2)
  set accountId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountId() => clearField(2);

  /// 账号
  @$pb.TagNumber(3)
  $core.String get accountNo => $_getSZ(2);
  @$pb.TagNumber(3)
  set accountNo($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAccountNo() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccountNo() => clearField(3);

  /// 名称
  @$pb.TagNumber(4)
  $core.String get userName => $_getSZ(3);
  @$pb.TagNumber(4)
  set userName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUserName() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserName() => clearField(4);

  @$pb.TagNumber(5)
  CDFYRspOnAccountRiskWarning_AODType get type => $_getN(4);
  @$pb.TagNumber(5)
  set type(CDFYRspOnAccountRiskWarning_AODType v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => clearField(5);

  /// 报警内容
  @$pb.TagNumber(6)
  $core.String get info => $_getSZ(5);
  @$pb.TagNumber(6)
  set info($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasInfo() => $_has(5);
  @$pb.TagNumber(6)
  void clearInfo() => clearField(6);
}

class CDFYRspAccountFund extends $pb.GeneratedMessage {
  factory CDFYRspAccountFund({
    $core.String? currency,
    $core.double? preEquity,
    $core.double? frozenDeposit,
    $core.double? fee,
    $core.double? occupyDeposit,
    $core.double? termInitial,
    $core.double? cashInValue,
    $core.double? cashOutValue,
    $core.double? closeProfit,
    $core.double? risk,
    $core.double? available,
    $core.double? equity,
    $core.double? floatProfit,
  }) {
    final $result = create();
    if (currency != null) {
      $result.currency = currency;
    }
    if (preEquity != null) {
      $result.preEquity = preEquity;
    }
    if (frozenDeposit != null) {
      $result.frozenDeposit = frozenDeposit;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (occupyDeposit != null) {
      $result.occupyDeposit = occupyDeposit;
    }
    if (termInitial != null) {
      $result.termInitial = termInitial;
    }
    if (cashInValue != null) {
      $result.cashInValue = cashInValue;
    }
    if (cashOutValue != null) {
      $result.cashOutValue = cashOutValue;
    }
    if (closeProfit != null) {
      $result.closeProfit = closeProfit;
    }
    if (risk != null) {
      $result.risk = risk;
    }
    if (available != null) {
      $result.available = available;
    }
    if (equity != null) {
      $result.equity = equity;
    }
    if (floatProfit != null) {
      $result.floatProfit = floatProfit;
    }
    return $result;
  }
  CDFYRspAccountFund._() : super();
  factory CDFYRspAccountFund.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYRspAccountFund.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYRspAccountFund', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Currency', protoName: 'Currency')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'PreEquity', $pb.PbFieldType.OD, protoName: 'PreEquity')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'FrozenDeposit', $pb.PbFieldType.OD, protoName: 'FrozenDeposit')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'Fee', $pb.PbFieldType.OD, protoName: 'Fee')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'OccupyDeposit', $pb.PbFieldType.OD, protoName: 'OccupyDeposit')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'TermInitial', $pb.PbFieldType.OD, protoName: 'TermInitial')
    ..a<$core.double>(7, _omitFieldNames ? '' : 'CashInValue', $pb.PbFieldType.OD, protoName: 'CashInValue')
    ..a<$core.double>(8, _omitFieldNames ? '' : 'CashOutValue', $pb.PbFieldType.OD, protoName: 'CashOutValue')
    ..a<$core.double>(9, _omitFieldNames ? '' : 'CloseProfit', $pb.PbFieldType.OD, protoName: 'CloseProfit')
    ..a<$core.double>(10, _omitFieldNames ? '' : 'Risk', $pb.PbFieldType.OD, protoName: 'Risk')
    ..a<$core.double>(11, _omitFieldNames ? '' : 'Available', $pb.PbFieldType.OD, protoName: 'Available')
    ..a<$core.double>(12, _omitFieldNames ? '' : 'Equity', $pb.PbFieldType.OD, protoName: 'Equity')
    ..a<$core.double>(13, _omitFieldNames ? '' : 'FloatProfit', $pb.PbFieldType.OD, protoName: 'FloatProfit')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYRspAccountFund clone() => CDFYRspAccountFund()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYRspAccountFund copyWith(void Function(CDFYRspAccountFund) updates) => super.copyWith((message) => updates(message as CDFYRspAccountFund)) as CDFYRspAccountFund;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYRspAccountFund create() => CDFYRspAccountFund._();
  CDFYRspAccountFund createEmptyInstance() => create();
  static $pb.PbList<CDFYRspAccountFund> createRepeated() => $pb.PbList<CDFYRspAccountFund>();
  @$core.pragma('dart2js:noInline')
  static CDFYRspAccountFund getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYRspAccountFund>(create);
  static CDFYRspAccountFund? _defaultInstance;

  /// 币种
  @$pb.TagNumber(1)
  $core.String get currency => $_getSZ(0);
  @$pb.TagNumber(1)
  set currency($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCurrency() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrency() => clearField(1);

  /// 上日权益
  @$pb.TagNumber(2)
  $core.double get preEquity => $_getN(1);
  @$pb.TagNumber(2)
  set preEquity($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPreEquity() => $_has(1);
  @$pb.TagNumber(2)
  void clearPreEquity() => clearField(2);

  /// 冻结保证金
  @$pb.TagNumber(3)
  $core.double get frozenDeposit => $_getN(2);
  @$pb.TagNumber(3)
  set frozenDeposit($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFrozenDeposit() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrozenDeposit() => clearField(3);

  /// 手续费
  @$pb.TagNumber(4)
  $core.double get fee => $_getN(3);
  @$pb.TagNumber(4)
  set fee($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFee() => $_has(3);
  @$pb.TagNumber(4)
  void clearFee() => clearField(4);

  /// 占用保证金
  @$pb.TagNumber(5)
  $core.double get occupyDeposit => $_getN(4);
  @$pb.TagNumber(5)
  set occupyDeposit($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOccupyDeposit() => $_has(4);
  @$pb.TagNumber(5)
  void clearOccupyDeposit() => clearField(5);

  /// 期初结存
  @$pb.TagNumber(6)
  $core.double get termInitial => $_getN(5);
  @$pb.TagNumber(6)
  set termInitial($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTermInitial() => $_has(5);
  @$pb.TagNumber(6)
  void clearTermInitial() => clearField(6);

  /// 入金
  @$pb.TagNumber(7)
  $core.double get cashInValue => $_getN(6);
  @$pb.TagNumber(7)
  set cashInValue($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCashInValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearCashInValue() => clearField(7);

  /// 出金
  @$pb.TagNumber(8)
  $core.double get cashOutValue => $_getN(7);
  @$pb.TagNumber(8)
  set cashOutValue($core.double v) { $_setDouble(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCashOutValue() => $_has(7);
  @$pb.TagNumber(8)
  void clearCashOutValue() => clearField(8);

  /// 平仓盈亏
  @$pb.TagNumber(9)
  $core.double get closeProfit => $_getN(8);
  @$pb.TagNumber(9)
  set closeProfit($core.double v) { $_setDouble(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasCloseProfit() => $_has(8);
  @$pb.TagNumber(9)
  void clearCloseProfit() => clearField(9);

  /// 风险度
  @$pb.TagNumber(10)
  $core.double get risk => $_getN(9);
  @$pb.TagNumber(10)
  set risk($core.double v) { $_setDouble(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasRisk() => $_has(9);
  @$pb.TagNumber(10)
  void clearRisk() => clearField(10);

  /// 可用资金
  @$pb.TagNumber(11)
  $core.double get available => $_getN(10);
  @$pb.TagNumber(11)
  set available($core.double v) { $_setDouble(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasAvailable() => $_has(10);
  @$pb.TagNumber(11)
  void clearAvailable() => clearField(11);

  /// 用户权益
  @$pb.TagNumber(12)
  $core.double get equity => $_getN(11);
  @$pb.TagNumber(12)
  set equity($core.double v) { $_setDouble(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasEquity() => $_has(11);
  @$pb.TagNumber(12)
  void clearEquity() => clearField(12);

  /// 持仓盈亏
  @$pb.TagNumber(13)
  $core.double get floatProfit => $_getN(12);
  @$pb.TagNumber(13)
  set floatProfit($core.double v) { $_setDouble(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasFloatProfit() => $_has(12);
  @$pb.TagNumber(13)
  void clearFloatProfit() => clearField(13);
}

class CDFYRspOnAccountFund extends $pb.GeneratedMessage {
  factory CDFYRspOnAccountFund({
    $fixnum.Int64? accountId,
    $core.String? accountNo,
    $core.String? userName,
    CDFYRspAccountFund? fund,
  }) {
    final $result = create();
    if (accountId != null) {
      $result.accountId = accountId;
    }
    if (accountNo != null) {
      $result.accountNo = accountNo;
    }
    if (userName != null) {
      $result.userName = userName;
    }
    if (fund != null) {
      $result.fund = fund;
    }
    return $result;
  }
  CDFYRspOnAccountFund._() : super();
  factory CDFYRspOnAccountFund.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYRspOnAccountFund.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYRspOnAccountFund', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'AccountId', protoName: 'AccountId')
    ..aOS(2, _omitFieldNames ? '' : 'AccountNo', protoName: 'AccountNo')
    ..aOS(3, _omitFieldNames ? '' : 'UserName', protoName: 'UserName')
    ..aOM<CDFYRspAccountFund>(4, _omitFieldNames ? '' : 'Fund', protoName: 'Fund', subBuilder: CDFYRspAccountFund.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYRspOnAccountFund clone() => CDFYRspOnAccountFund()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYRspOnAccountFund copyWith(void Function(CDFYRspOnAccountFund) updates) => super.copyWith((message) => updates(message as CDFYRspOnAccountFund)) as CDFYRspOnAccountFund;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYRspOnAccountFund create() => CDFYRspOnAccountFund._();
  CDFYRspOnAccountFund createEmptyInstance() => create();
  static $pb.PbList<CDFYRspOnAccountFund> createRepeated() => $pb.PbList<CDFYRspOnAccountFund>();
  @$core.pragma('dart2js:noInline')
  static CDFYRspOnAccountFund getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYRspOnAccountFund>(create);
  static CDFYRspOnAccountFund? _defaultInstance;

  /// 通知类型
  ///  账户id
  @$pb.TagNumber(1)
  $fixnum.Int64 get accountId => $_getI64(0);
  @$pb.TagNumber(1)
  set accountId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => clearField(1);

  /// 账号
  @$pb.TagNumber(2)
  $core.String get accountNo => $_getSZ(1);
  @$pb.TagNumber(2)
  set accountNo($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAccountNo() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountNo() => clearField(2);

  /// 名称
  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => clearField(3);

  /// 账号
  @$pb.TagNumber(4)
  CDFYRspAccountFund get fund => $_getN(3);
  @$pb.TagNumber(4)
  set fund(CDFYRspAccountFund v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasFund() => $_has(3);
  @$pb.TagNumber(4)
  void clearFund() => clearField(4);
  @$pb.TagNumber(4)
  CDFYRspAccountFund ensureFund() => $_ensure(3);
}

class CDFYRspOrderDetail extends $pb.GeneratedMessage {
  factory CDFYRspOrderDetail({
    $fixnum.Int64? accountId,
    $core.String? accountNo,
    $core.String? userName,
    $core.String? orderId,
    $core.String? exchangeNo,
    $core.int? commodityType,
    $core.String? commodityNo,
    $core.String? contractNo,
    $core.String? contractName,
    $core.int? orderType,
    $core.int? orderOpType,
    $core.int? timeInForce,
    $core.String? expireTime,
    $core.int? orderSide,
    $core.int? positionEffect,
    $core.double? orderPrice,
    $core.double? stopPrice,
    $core.int? orderQty,
    $core.int? matchQty,
    $core.String? tradeCurrency,
    $core.int? orderState,
    $core.int? errorCode,
    $core.String? errorText,
    $core.String? createTime,
    $core.String? orderLocalID,
    $core.String? orderRef,
    $core.int? requestID,
    $core.int? orderSource,
    $core.double? contractSize,
    $core.double? commodityTickSize,
    $core.String? updateTime,
  }) {
    final $result = create();
    if (accountId != null) {
      $result.accountId = accountId;
    }
    if (accountNo != null) {
      $result.accountNo = accountNo;
    }
    if (userName != null) {
      $result.userName = userName;
    }
    if (orderId != null) {
      $result.orderId = orderId;
    }
    if (exchangeNo != null) {
      $result.exchangeNo = exchangeNo;
    }
    if (commodityType != null) {
      $result.commodityType = commodityType;
    }
    if (commodityNo != null) {
      $result.commodityNo = commodityNo;
    }
    if (contractNo != null) {
      $result.contractNo = contractNo;
    }
    if (contractName != null) {
      $result.contractName = contractName;
    }
    if (orderType != null) {
      $result.orderType = orderType;
    }
    if (orderOpType != null) {
      $result.orderOpType = orderOpType;
    }
    if (timeInForce != null) {
      $result.timeInForce = timeInForce;
    }
    if (expireTime != null) {
      $result.expireTime = expireTime;
    }
    if (orderSide != null) {
      $result.orderSide = orderSide;
    }
    if (positionEffect != null) {
      $result.positionEffect = positionEffect;
    }
    if (orderPrice != null) {
      $result.orderPrice = orderPrice;
    }
    if (stopPrice != null) {
      $result.stopPrice = stopPrice;
    }
    if (orderQty != null) {
      $result.orderQty = orderQty;
    }
    if (matchQty != null) {
      $result.matchQty = matchQty;
    }
    if (tradeCurrency != null) {
      $result.tradeCurrency = tradeCurrency;
    }
    if (orderState != null) {
      $result.orderState = orderState;
    }
    if (errorCode != null) {
      $result.errorCode = errorCode;
    }
    if (errorText != null) {
      $result.errorText = errorText;
    }
    if (createTime != null) {
      $result.createTime = createTime;
    }
    if (orderLocalID != null) {
      $result.orderLocalID = orderLocalID;
    }
    if (orderRef != null) {
      $result.orderRef = orderRef;
    }
    if (requestID != null) {
      $result.requestID = requestID;
    }
    if (orderSource != null) {
      $result.orderSource = orderSource;
    }
    if (contractSize != null) {
      $result.contractSize = contractSize;
    }
    if (commodityTickSize != null) {
      $result.commodityTickSize = commodityTickSize;
    }
    if (updateTime != null) {
      $result.updateTime = updateTime;
    }
    return $result;
  }
  CDFYRspOrderDetail._() : super();
  factory CDFYRspOrderDetail.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYRspOrderDetail.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYRspOrderDetail', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'AccountId', protoName: 'AccountId')
    ..aOS(2, _omitFieldNames ? '' : 'AccountNo', protoName: 'AccountNo')
    ..aOS(3, _omitFieldNames ? '' : 'UserName', protoName: 'UserName')
    ..aOS(4, _omitFieldNames ? '' : 'OrderId', protoName: 'OrderId')
    ..aOS(5, _omitFieldNames ? '' : 'ExchangeNo', protoName: 'ExchangeNo')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'CommodityType', $pb.PbFieldType.O3, protoName: 'CommodityType')
    ..aOS(7, _omitFieldNames ? '' : 'CommodityNo', protoName: 'CommodityNo')
    ..aOS(8, _omitFieldNames ? '' : 'ContractNo', protoName: 'ContractNo')
    ..aOS(9, _omitFieldNames ? '' : 'ContractName', protoName: 'ContractName')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'OrderType', $pb.PbFieldType.O3, protoName: 'OrderType')
    ..a<$core.int>(11, _omitFieldNames ? '' : 'OrderOpType', $pb.PbFieldType.O3, protoName: 'OrderOpType')
    ..a<$core.int>(12, _omitFieldNames ? '' : 'TimeInForce', $pb.PbFieldType.O3, protoName: 'TimeInForce')
    ..aOS(13, _omitFieldNames ? '' : 'ExpireTime', protoName: 'ExpireTime')
    ..a<$core.int>(14, _omitFieldNames ? '' : 'OrderSide', $pb.PbFieldType.O3, protoName: 'OrderSide')
    ..a<$core.int>(15, _omitFieldNames ? '' : 'PositionEffect', $pb.PbFieldType.O3, protoName: 'PositionEffect')
    ..a<$core.double>(16, _omitFieldNames ? '' : 'OrderPrice', $pb.PbFieldType.OD, protoName: 'OrderPrice')
    ..a<$core.double>(17, _omitFieldNames ? '' : 'StopPrice', $pb.PbFieldType.OD, protoName: 'StopPrice')
    ..a<$core.int>(18, _omitFieldNames ? '' : 'OrderQty', $pb.PbFieldType.O3, protoName: 'OrderQty')
    ..a<$core.int>(19, _omitFieldNames ? '' : 'MatchQty', $pb.PbFieldType.O3, protoName: 'MatchQty')
    ..aOS(20, _omitFieldNames ? '' : 'TradeCurrency', protoName: 'TradeCurrency')
    ..a<$core.int>(21, _omitFieldNames ? '' : 'OrderState', $pb.PbFieldType.O3, protoName: 'OrderState')
    ..a<$core.int>(22, _omitFieldNames ? '' : 'ErrorCode', $pb.PbFieldType.O3, protoName: 'ErrorCode')
    ..aOS(23, _omitFieldNames ? '' : 'ErrorText', protoName: 'ErrorText')
    ..aOS(24, _omitFieldNames ? '' : 'CreateTime', protoName: 'CreateTime')
    ..aOS(25, _omitFieldNames ? '' : 'OrderLocalID', protoName: 'OrderLocalID')
    ..aOS(26, _omitFieldNames ? '' : 'OrderRef', protoName: 'OrderRef')
    ..a<$core.int>(27, _omitFieldNames ? '' : 'RequestID', $pb.PbFieldType.O3, protoName: 'RequestID')
    ..a<$core.int>(28, _omitFieldNames ? '' : 'OrderSource', $pb.PbFieldType.O3, protoName: 'OrderSource')
    ..a<$core.double>(29, _omitFieldNames ? '' : 'ContractSize', $pb.PbFieldType.OD, protoName: 'ContractSize')
    ..a<$core.double>(30, _omitFieldNames ? '' : 'CommodityTickSize', $pb.PbFieldType.OD, protoName: 'CommodityTickSize')
    ..aOS(31, _omitFieldNames ? '' : 'UpdateTime', protoName: 'UpdateTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYRspOrderDetail clone() => CDFYRspOrderDetail()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYRspOrderDetail copyWith(void Function(CDFYRspOrderDetail) updates) => super.copyWith((message) => updates(message as CDFYRspOrderDetail)) as CDFYRspOrderDetail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYRspOrderDetail create() => CDFYRspOrderDetail._();
  CDFYRspOrderDetail createEmptyInstance() => create();
  static $pb.PbList<CDFYRspOrderDetail> createRepeated() => $pb.PbList<CDFYRspOrderDetail>();
  @$core.pragma('dart2js:noInline')
  static CDFYRspOrderDetail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYRspOrderDetail>(create);
  static CDFYRspOrderDetail? _defaultInstance;

  /// 账户id
  @$pb.TagNumber(1)
  $fixnum.Int64 get accountId => $_getI64(0);
  @$pb.TagNumber(1)
  set accountId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => clearField(1);

  /// 账号
  @$pb.TagNumber(2)
  $core.String get accountNo => $_getSZ(1);
  @$pb.TagNumber(2)
  set accountNo($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAccountNo() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountNo() => clearField(2);

  /// 名称
  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => clearField(3);

  /// 订单委托编号
  @$pb.TagNumber(4)
  $core.String get orderId => $_getSZ(3);
  @$pb.TagNumber(4)
  set orderId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOrderId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrderId() => clearField(4);

  /// 交易所代码
  @$pb.TagNumber(5)
  $core.String get exchangeNo => $_getSZ(4);
  @$pb.TagNumber(5)
  set exchangeNo($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExchangeNo() => $_has(4);
  @$pb.TagNumber(5)
  void clearExchangeNo() => clearField(5);

  /// 品种代码
  @$pb.TagNumber(6)
  $core.int get commodityType => $_getIZ(5);
  @$pb.TagNumber(6)
  set commodityType($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCommodityType() => $_has(5);
  @$pb.TagNumber(6)
  void clearCommodityType() => clearField(6);

  /// 品种类型
  @$pb.TagNumber(7)
  $core.String get commodityNo => $_getSZ(6);
  @$pb.TagNumber(7)
  set commodityNo($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCommodityNo() => $_has(6);
  @$pb.TagNumber(7)
  void clearCommodityNo() => clearField(7);

  /// 合约代码
  @$pb.TagNumber(8)
  $core.String get contractNo => $_getSZ(7);
  @$pb.TagNumber(8)
  set contractNo($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasContractNo() => $_has(7);
  @$pb.TagNumber(8)
  void clearContractNo() => clearField(8);

  /// 名称
  @$pb.TagNumber(9)
  $core.String get contractName => $_getSZ(8);
  @$pb.TagNumber(9)
  set contractName($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasContractName() => $_has(8);
  @$pb.TagNumber(9)
  void clearContractName() => clearField(9);

  /// 委托类型
  @$pb.TagNumber(10)
  $core.int get orderType => $_getIZ(9);
  @$pb.TagNumber(10)
  set orderType($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasOrderType() => $_has(9);
  @$pb.TagNumber(10)
  void clearOrderType() => clearField(10);

  /// 操作类型
  @$pb.TagNumber(11)
  $core.int get orderOpType => $_getIZ(10);
  @$pb.TagNumber(11)
  set orderOpType($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasOrderOpType() => $_has(10);
  @$pb.TagNumber(11)
  void clearOrderOpType() => clearField(11);

  /// 有效类型
  @$pb.TagNumber(12)
  $core.int get timeInForce => $_getIZ(11);
  @$pb.TagNumber(12)
  set timeInForce($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasTimeInForce() => $_has(11);
  @$pb.TagNumber(12)
  void clearTimeInForce() => clearField(12);

  /// 有效日期
  @$pb.TagNumber(13)
  $core.String get expireTime => $_getSZ(12);
  @$pb.TagNumber(13)
  set expireTime($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasExpireTime() => $_has(12);
  @$pb.TagNumber(13)
  void clearExpireTime() => clearField(13);

  /// 买入卖出
  @$pb.TagNumber(14)
  $core.int get orderSide => $_getIZ(13);
  @$pb.TagNumber(14)
  set orderSide($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasOrderSide() => $_has(13);
  @$pb.TagNumber(14)
  void clearOrderSide() => clearField(14);

  /// 开平标志
  @$pb.TagNumber(15)
  $core.int get positionEffect => $_getIZ(14);
  @$pb.TagNumber(15)
  set positionEffect($core.int v) { $_setSignedInt32(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasPositionEffect() => $_has(14);
  @$pb.TagNumber(15)
  void clearPositionEffect() => clearField(15);

  /// 委托价格
  @$pb.TagNumber(16)
  $core.double get orderPrice => $_getN(15);
  @$pb.TagNumber(16)
  set orderPrice($core.double v) { $_setDouble(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasOrderPrice() => $_has(15);
  @$pb.TagNumber(16)
  void clearOrderPrice() => clearField(16);

  /// 触发价格
  @$pb.TagNumber(17)
  $core.double get stopPrice => $_getN(16);
  @$pb.TagNumber(17)
  set stopPrice($core.double v) { $_setDouble(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasStopPrice() => $_has(16);
  @$pb.TagNumber(17)
  void clearStopPrice() => clearField(17);

  /// 下单数量
  @$pb.TagNumber(18)
  $core.int get orderQty => $_getIZ(17);
  @$pb.TagNumber(18)
  set orderQty($core.int v) { $_setSignedInt32(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasOrderQty() => $_has(17);
  @$pb.TagNumber(18)
  void clearOrderQty() => clearField(18);

  /// 成交量
  @$pb.TagNumber(19)
  $core.int get matchQty => $_getIZ(18);
  @$pb.TagNumber(19)
  set matchQty($core.int v) { $_setSignedInt32(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasMatchQty() => $_has(18);
  @$pb.TagNumber(19)
  void clearMatchQty() => clearField(19);

  /// 交易币种
  @$pb.TagNumber(20)
  $core.String get tradeCurrency => $_getSZ(19);
  @$pb.TagNumber(20)
  set tradeCurrency($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasTradeCurrency() => $_has(19);
  @$pb.TagNumber(20)
  void clearTradeCurrency() => clearField(20);

  /// 订单状态
  @$pb.TagNumber(21)
  $core.int get orderState => $_getIZ(20);
  @$pb.TagNumber(21)
  set orderState($core.int v) { $_setSignedInt32(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasOrderState() => $_has(20);
  @$pb.TagNumber(21)
  void clearOrderState() => clearField(21);

  /// 错误代码
  @$pb.TagNumber(22)
  $core.int get errorCode => $_getIZ(21);
  @$pb.TagNumber(22)
  set errorCode($core.int v) { $_setSignedInt32(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasErrorCode() => $_has(21);
  @$pb.TagNumber(22)
  void clearErrorCode() => clearField(22);

  /// 错误信息
  @$pb.TagNumber(23)
  $core.String get errorText => $_getSZ(22);
  @$pb.TagNumber(23)
  set errorText($core.String v) { $_setString(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasErrorText() => $_has(22);
  @$pb.TagNumber(23)
  void clearErrorText() => clearField(23);

  /// 时间
  @$pb.TagNumber(24)
  $core.String get createTime => $_getSZ(23);
  @$pb.TagNumber(24)
  set createTime($core.String v) { $_setString(23, v); }
  @$pb.TagNumber(24)
  $core.bool hasCreateTime() => $_has(23);
  @$pb.TagNumber(24)
  void clearCreateTime() => clearField(24);

  /// 本地编号
  @$pb.TagNumber(25)
  $core.String get orderLocalID => $_getSZ(24);
  @$pb.TagNumber(25)
  set orderLocalID($core.String v) { $_setString(24, v); }
  @$pb.TagNumber(25)
  $core.bool hasOrderLocalID() => $_has(24);
  @$pb.TagNumber(25)
  void clearOrderLocalID() => clearField(25);

  /// ref
  @$pb.TagNumber(26)
  $core.String get orderRef => $_getSZ(25);
  @$pb.TagNumber(26)
  set orderRef($core.String v) { $_setString(25, v); }
  @$pb.TagNumber(26)
  $core.bool hasOrderRef() => $_has(25);
  @$pb.TagNumber(26)
  void clearOrderRef() => clearField(26);

  /// RequestID
  @$pb.TagNumber(27)
  $core.int get requestID => $_getIZ(26);
  @$pb.TagNumber(27)
  set requestID($core.int v) { $_setSignedInt32(26, v); }
  @$pb.TagNumber(27)
  $core.bool hasRequestID() => $_has(26);
  @$pb.TagNumber(27)
  void clearRequestID() => clearField(27);

  /// 委托来源
  @$pb.TagNumber(28)
  $core.int get orderSource => $_getIZ(27);
  @$pb.TagNumber(28)
  set orderSource($core.int v) { $_setSignedInt32(27, v); }
  @$pb.TagNumber(28)
  $core.bool hasOrderSource() => $_has(27);
  @$pb.TagNumber(28)
  void clearOrderSource() => clearField(28);

  /// 合约乘数
  @$pb.TagNumber(29)
  $core.double get contractSize => $_getN(28);
  @$pb.TagNumber(29)
  set contractSize($core.double v) { $_setDouble(28, v); }
  @$pb.TagNumber(29)
  $core.bool hasContractSize() => $_has(28);
  @$pb.TagNumber(29)
  void clearContractSize() => clearField(29);

  /// 最小变动价格
  @$pb.TagNumber(30)
  $core.double get commodityTickSize => $_getN(29);
  @$pb.TagNumber(30)
  set commodityTickSize($core.double v) { $_setDouble(29, v); }
  @$pb.TagNumber(30)
  $core.bool hasCommodityTickSize() => $_has(29);
  @$pb.TagNumber(30)
  void clearCommodityTickSize() => clearField(30);

  /// 更新时间
  @$pb.TagNumber(31)
  $core.String get updateTime => $_getSZ(30);
  @$pb.TagNumber(31)
  set updateTime($core.String v) { $_setString(30, v); }
  @$pb.TagNumber(31)
  $core.bool hasUpdateTime() => $_has(30);
  @$pb.TagNumber(31)
  void clearUpdateTime() => clearField(31);
}

class CDFYRspFillDetail extends $pb.GeneratedMessage {
  factory CDFYRspFillDetail({
    $fixnum.Int64? accountId,
    $core.String? accountNo,
    $core.String? userName,
    $core.String? matchNo,
    $core.String? exchangeNo,
    $core.int? commodityType,
    $core.String? commodityNo,
    $core.String? contractNo,
    $core.String? contractName,
    $core.int? matchSide,
    $core.double? matchPrice,
    $core.int? matchQty,
    $core.int? positionEffect,
    $core.String? feeCurrency,
    $core.double? feeValue,
    $core.double? fee,
    $core.String? exchangeOrderNo,
    $core.String? createTime,
    $core.String? orderId,
    $core.String? orderLocalID,
    $core.String? orderRef,
    $core.int? orderSource,
    $core.double? contractSize,
    $core.double? commodityTickSize,
  }) {
    final $result = create();
    if (accountId != null) {
      $result.accountId = accountId;
    }
    if (accountNo != null) {
      $result.accountNo = accountNo;
    }
    if (userName != null) {
      $result.userName = userName;
    }
    if (matchNo != null) {
      $result.matchNo = matchNo;
    }
    if (exchangeNo != null) {
      $result.exchangeNo = exchangeNo;
    }
    if (commodityType != null) {
      $result.commodityType = commodityType;
    }
    if (commodityNo != null) {
      $result.commodityNo = commodityNo;
    }
    if (contractNo != null) {
      $result.contractNo = contractNo;
    }
    if (contractName != null) {
      $result.contractName = contractName;
    }
    if (matchSide != null) {
      $result.matchSide = matchSide;
    }
    if (matchPrice != null) {
      $result.matchPrice = matchPrice;
    }
    if (matchQty != null) {
      $result.matchQty = matchQty;
    }
    if (positionEffect != null) {
      $result.positionEffect = positionEffect;
    }
    if (feeCurrency != null) {
      $result.feeCurrency = feeCurrency;
    }
    if (feeValue != null) {
      $result.feeValue = feeValue;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (exchangeOrderNo != null) {
      $result.exchangeOrderNo = exchangeOrderNo;
    }
    if (createTime != null) {
      $result.createTime = createTime;
    }
    if (orderId != null) {
      $result.orderId = orderId;
    }
    if (orderLocalID != null) {
      $result.orderLocalID = orderLocalID;
    }
    if (orderRef != null) {
      $result.orderRef = orderRef;
    }
    if (orderSource != null) {
      $result.orderSource = orderSource;
    }
    if (contractSize != null) {
      $result.contractSize = contractSize;
    }
    if (commodityTickSize != null) {
      $result.commodityTickSize = commodityTickSize;
    }
    return $result;
  }
  CDFYRspFillDetail._() : super();
  factory CDFYRspFillDetail.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYRspFillDetail.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYRspFillDetail', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'AccountId', protoName: 'AccountId')
    ..aOS(2, _omitFieldNames ? '' : 'AccountNo', protoName: 'AccountNo')
    ..aOS(3, _omitFieldNames ? '' : 'UserName', protoName: 'UserName')
    ..aOS(4, _omitFieldNames ? '' : 'MatchNo', protoName: 'MatchNo')
    ..aOS(5, _omitFieldNames ? '' : 'ExchangeNo', protoName: 'ExchangeNo')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'CommodityType', $pb.PbFieldType.O3, protoName: 'CommodityType')
    ..aOS(7, _omitFieldNames ? '' : 'CommodityNo', protoName: 'CommodityNo')
    ..aOS(8, _omitFieldNames ? '' : 'ContractNo', protoName: 'ContractNo')
    ..aOS(9, _omitFieldNames ? '' : 'ContractName', protoName: 'ContractName')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'MatchSide', $pb.PbFieldType.O3, protoName: 'MatchSide')
    ..a<$core.double>(11, _omitFieldNames ? '' : 'MatchPrice', $pb.PbFieldType.OD, protoName: 'MatchPrice')
    ..a<$core.int>(12, _omitFieldNames ? '' : 'MatchQty', $pb.PbFieldType.O3, protoName: 'MatchQty')
    ..a<$core.int>(13, _omitFieldNames ? '' : 'PositionEffect', $pb.PbFieldType.O3, protoName: 'PositionEffect')
    ..aOS(14, _omitFieldNames ? '' : 'FeeCurrency', protoName: 'FeeCurrency')
    ..a<$core.double>(15, _omitFieldNames ? '' : 'FeeValue', $pb.PbFieldType.OF, protoName: 'FeeValue')
    ..a<$core.double>(16, _omitFieldNames ? '' : 'Fee', $pb.PbFieldType.OF, protoName: 'Fee')
    ..aOS(17, _omitFieldNames ? '' : 'ExchangeOrderNo', protoName: 'ExchangeOrderNo')
    ..aOS(18, _omitFieldNames ? '' : 'CreateTime', protoName: 'CreateTime')
    ..aOS(19, _omitFieldNames ? '' : 'OrderId', protoName: 'OrderId')
    ..aOS(20, _omitFieldNames ? '' : 'OrderLocalID', protoName: 'OrderLocalID')
    ..aOS(21, _omitFieldNames ? '' : 'OrderRef', protoName: 'OrderRef')
    ..a<$core.int>(22, _omitFieldNames ? '' : 'OrderSource', $pb.PbFieldType.O3, protoName: 'OrderSource')
    ..a<$core.double>(23, _omitFieldNames ? '' : 'ContractSize', $pb.PbFieldType.OD, protoName: 'ContractSize')
    ..a<$core.double>(24, _omitFieldNames ? '' : 'CommodityTickSize', $pb.PbFieldType.OD, protoName: 'CommodityTickSize')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYRspFillDetail clone() => CDFYRspFillDetail()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYRspFillDetail copyWith(void Function(CDFYRspFillDetail) updates) => super.copyWith((message) => updates(message as CDFYRspFillDetail)) as CDFYRspFillDetail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYRspFillDetail create() => CDFYRspFillDetail._();
  CDFYRspFillDetail createEmptyInstance() => create();
  static $pb.PbList<CDFYRspFillDetail> createRepeated() => $pb.PbList<CDFYRspFillDetail>();
  @$core.pragma('dart2js:noInline')
  static CDFYRspFillDetail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYRspFillDetail>(create);
  static CDFYRspFillDetail? _defaultInstance;

  /// 账户id
  @$pb.TagNumber(1)
  $fixnum.Int64 get accountId => $_getI64(0);
  @$pb.TagNumber(1)
  set accountId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => clearField(1);

  /// 账号
  @$pb.TagNumber(2)
  $core.String get accountNo => $_getSZ(1);
  @$pb.TagNumber(2)
  set accountNo($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAccountNo() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountNo() => clearField(2);

  /// 名称
  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => clearField(3);

  /// 成交编号
  @$pb.TagNumber(4)
  $core.String get matchNo => $_getSZ(3);
  @$pb.TagNumber(4)
  set matchNo($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMatchNo() => $_has(3);
  @$pb.TagNumber(4)
  void clearMatchNo() => clearField(4);

  /// 交易所代码
  @$pb.TagNumber(5)
  $core.String get exchangeNo => $_getSZ(4);
  @$pb.TagNumber(5)
  set exchangeNo($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExchangeNo() => $_has(4);
  @$pb.TagNumber(5)
  void clearExchangeNo() => clearField(5);

  /// 品种代码
  @$pb.TagNumber(6)
  $core.int get commodityType => $_getIZ(5);
  @$pb.TagNumber(6)
  set commodityType($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCommodityType() => $_has(5);
  @$pb.TagNumber(6)
  void clearCommodityType() => clearField(6);

  /// 品种类型
  @$pb.TagNumber(7)
  $core.String get commodityNo => $_getSZ(6);
  @$pb.TagNumber(7)
  set commodityNo($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCommodityNo() => $_has(6);
  @$pb.TagNumber(7)
  void clearCommodityNo() => clearField(7);

  /// 合约代码
  @$pb.TagNumber(8)
  $core.String get contractNo => $_getSZ(7);
  @$pb.TagNumber(8)
  set contractNo($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasContractNo() => $_has(7);
  @$pb.TagNumber(8)
  void clearContractNo() => clearField(8);

  /// 名称
  @$pb.TagNumber(9)
  $core.String get contractName => $_getSZ(8);
  @$pb.TagNumber(9)
  set contractName($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasContractName() => $_has(8);
  @$pb.TagNumber(9)
  void clearContractName() => clearField(9);

  /// 买入卖出
  @$pb.TagNumber(10)
  $core.int get matchSide => $_getIZ(9);
  @$pb.TagNumber(10)
  set matchSide($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasMatchSide() => $_has(9);
  @$pb.TagNumber(10)
  void clearMatchSide() => clearField(10);

  /// 平均成交价
  @$pb.TagNumber(11)
  $core.double get matchPrice => $_getN(10);
  @$pb.TagNumber(11)
  set matchPrice($core.double v) { $_setDouble(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasMatchPrice() => $_has(10);
  @$pb.TagNumber(11)
  void clearMatchPrice() => clearField(11);

  /// 总成交量
  @$pb.TagNumber(12)
  $core.int get matchQty => $_getIZ(11);
  @$pb.TagNumber(12)
  set matchQty($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasMatchQty() => $_has(11);
  @$pb.TagNumber(12)
  void clearMatchQty() => clearField(12);

  /// 开平标志
  @$pb.TagNumber(13)
  $core.int get positionEffect => $_getIZ(12);
  @$pb.TagNumber(13)
  set positionEffect($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasPositionEffect() => $_has(12);
  @$pb.TagNumber(13)
  void clearPositionEffect() => clearField(13);

  /// 手续费币种
  @$pb.TagNumber(14)
  $core.String get feeCurrency => $_getSZ(13);
  @$pb.TagNumber(14)
  set feeCurrency($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasFeeCurrency() => $_has(13);
  @$pb.TagNumber(14)
  void clearFeeCurrency() => clearField(14);

  /// 单笔手续费
  @$pb.TagNumber(15)
  $core.double get feeValue => $_getN(14);
  @$pb.TagNumber(15)
  set feeValue($core.double v) { $_setFloat(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasFeeValue() => $_has(14);
  @$pb.TagNumber(15)
  void clearFeeValue() => clearField(15);

  /// 总手续费
  @$pb.TagNumber(16)
  $core.double get fee => $_getN(15);
  @$pb.TagNumber(16)
  set fee($core.double v) { $_setFloat(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasFee() => $_has(15);
  @$pb.TagNumber(16)
  void clearFee() => clearField(16);

  /// 交易成交编号
  @$pb.TagNumber(17)
  $core.String get exchangeOrderNo => $_getSZ(16);
  @$pb.TagNumber(17)
  set exchangeOrderNo($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasExchangeOrderNo() => $_has(16);
  @$pb.TagNumber(17)
  void clearExchangeOrderNo() => clearField(17);

  /// 时间
  @$pb.TagNumber(18)
  $core.String get createTime => $_getSZ(17);
  @$pb.TagNumber(18)
  set createTime($core.String v) { $_setString(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasCreateTime() => $_has(17);
  @$pb.TagNumber(18)
  void clearCreateTime() => clearField(18);

  /// 订单委托编号
  @$pb.TagNumber(19)
  $core.String get orderId => $_getSZ(18);
  @$pb.TagNumber(19)
  set orderId($core.String v) { $_setString(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasOrderId() => $_has(18);
  @$pb.TagNumber(19)
  void clearOrderId() => clearField(19);

  /// 本地编号
  @$pb.TagNumber(20)
  $core.String get orderLocalID => $_getSZ(19);
  @$pb.TagNumber(20)
  set orderLocalID($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasOrderLocalID() => $_has(19);
  @$pb.TagNumber(20)
  void clearOrderLocalID() => clearField(20);

  /// ref
  @$pb.TagNumber(21)
  $core.String get orderRef => $_getSZ(20);
  @$pb.TagNumber(21)
  set orderRef($core.String v) { $_setString(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasOrderRef() => $_has(20);
  @$pb.TagNumber(21)
  void clearOrderRef() => clearField(21);

  /// 委托来源
  @$pb.TagNumber(22)
  $core.int get orderSource => $_getIZ(21);
  @$pb.TagNumber(22)
  set orderSource($core.int v) { $_setSignedInt32(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasOrderSource() => $_has(21);
  @$pb.TagNumber(22)
  void clearOrderSource() => clearField(22);

  /// 合约乘数
  @$pb.TagNumber(23)
  $core.double get contractSize => $_getN(22);
  @$pb.TagNumber(23)
  set contractSize($core.double v) { $_setDouble(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasContractSize() => $_has(22);
  @$pb.TagNumber(23)
  void clearContractSize() => clearField(23);

  /// 最小变动价格
  @$pb.TagNumber(24)
  $core.double get commodityTickSize => $_getN(23);
  @$pb.TagNumber(24)
  set commodityTickSize($core.double v) { $_setDouble(23, v); }
  @$pb.TagNumber(24)
  $core.bool hasCommodityTickSize() => $_has(23);
  @$pb.TagNumber(24)
  void clearCommodityTickSize() => clearField(24);
}

class CDFYRspPositionDetail extends $pb.GeneratedMessage {
  factory CDFYRspPositionDetail({
    $fixnum.Int64? accountId,
    $core.String? accountNo,
    $core.String? userName,
    $core.String? positionNo,
    $core.String? exchangeNo,
    $core.int? commodityType,
    $core.String? commodityNo,
    $core.String? contractNo,
    $core.String? contractName,
    $core.int? side,
    $core.double? positionPrice,
    $core.int? positionQty,
    $core.int? availableQty,
    $core.double? calculatePrice,
    $core.double? positionFloat,
    $core.String? createTime,
    $core.String? tradeCurrency,
    $core.double? contractSize,
    $core.double? commodityTickSize,
    $core.double? deposit,
  }) {
    final $result = create();
    if (accountId != null) {
      $result.accountId = accountId;
    }
    if (accountNo != null) {
      $result.accountNo = accountNo;
    }
    if (userName != null) {
      $result.userName = userName;
    }
    if (positionNo != null) {
      $result.positionNo = positionNo;
    }
    if (exchangeNo != null) {
      $result.exchangeNo = exchangeNo;
    }
    if (commodityType != null) {
      $result.commodityType = commodityType;
    }
    if (commodityNo != null) {
      $result.commodityNo = commodityNo;
    }
    if (contractNo != null) {
      $result.contractNo = contractNo;
    }
    if (contractName != null) {
      $result.contractName = contractName;
    }
    if (side != null) {
      $result.side = side;
    }
    if (positionPrice != null) {
      $result.positionPrice = positionPrice;
    }
    if (positionQty != null) {
      $result.positionQty = positionQty;
    }
    if (availableQty != null) {
      $result.availableQty = availableQty;
    }
    if (calculatePrice != null) {
      $result.calculatePrice = calculatePrice;
    }
    if (positionFloat != null) {
      $result.positionFloat = positionFloat;
    }
    if (createTime != null) {
      $result.createTime = createTime;
    }
    if (tradeCurrency != null) {
      $result.tradeCurrency = tradeCurrency;
    }
    if (contractSize != null) {
      $result.contractSize = contractSize;
    }
    if (commodityTickSize != null) {
      $result.commodityTickSize = commodityTickSize;
    }
    if (deposit != null) {
      $result.deposit = deposit;
    }
    return $result;
  }
  CDFYRspPositionDetail._() : super();
  factory CDFYRspPositionDetail.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYRspPositionDetail.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYRspPositionDetail', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'AccountId', protoName: 'AccountId')
    ..aOS(2, _omitFieldNames ? '' : 'AccountNo', protoName: 'AccountNo')
    ..aOS(3, _omitFieldNames ? '' : 'UserName', protoName: 'UserName')
    ..aOS(4, _omitFieldNames ? '' : 'PositionNo', protoName: 'PositionNo')
    ..aOS(5, _omitFieldNames ? '' : 'ExchangeNo', protoName: 'ExchangeNo')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'CommodityType', $pb.PbFieldType.O3, protoName: 'CommodityType')
    ..aOS(7, _omitFieldNames ? '' : 'CommodityNo', protoName: 'CommodityNo')
    ..aOS(8, _omitFieldNames ? '' : 'ContractNo', protoName: 'ContractNo')
    ..aOS(9, _omitFieldNames ? '' : 'ContractName', protoName: 'ContractName')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'Side', $pb.PbFieldType.O3, protoName: 'Side')
    ..a<$core.double>(11, _omitFieldNames ? '' : 'PositionPrice', $pb.PbFieldType.OD, protoName: 'PositionPrice')
    ..a<$core.int>(12, _omitFieldNames ? '' : 'PositionQty', $pb.PbFieldType.O3, protoName: 'PositionQty')
    ..a<$core.int>(13, _omitFieldNames ? '' : 'AvailableQty', $pb.PbFieldType.O3, protoName: 'AvailableQty')
    ..a<$core.double>(14, _omitFieldNames ? '' : 'CalculatePrice', $pb.PbFieldType.OD, protoName: 'CalculatePrice')
    ..a<$core.double>(15, _omitFieldNames ? '' : 'PositionFloat', $pb.PbFieldType.OD, protoName: 'PositionFloat')
    ..aOS(16, _omitFieldNames ? '' : 'CreateTime', protoName: 'CreateTime')
    ..aOS(17, _omitFieldNames ? '' : 'TradeCurrency', protoName: 'TradeCurrency')
    ..a<$core.double>(18, _omitFieldNames ? '' : 'ContractSize', $pb.PbFieldType.OD, protoName: 'ContractSize')
    ..a<$core.double>(19, _omitFieldNames ? '' : 'CommodityTickSize', $pb.PbFieldType.OD, protoName: 'CommodityTickSize')
    ..a<$core.double>(20, _omitFieldNames ? '' : 'Deposit', $pb.PbFieldType.OD, protoName: 'Deposit')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYRspPositionDetail clone() => CDFYRspPositionDetail()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYRspPositionDetail copyWith(void Function(CDFYRspPositionDetail) updates) => super.copyWith((message) => updates(message as CDFYRspPositionDetail)) as CDFYRspPositionDetail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYRspPositionDetail create() => CDFYRspPositionDetail._();
  CDFYRspPositionDetail createEmptyInstance() => create();
  static $pb.PbList<CDFYRspPositionDetail> createRepeated() => $pb.PbList<CDFYRspPositionDetail>();
  @$core.pragma('dart2js:noInline')
  static CDFYRspPositionDetail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYRspPositionDetail>(create);
  static CDFYRspPositionDetail? _defaultInstance;

  /// 账户id
  @$pb.TagNumber(1)
  $fixnum.Int64 get accountId => $_getI64(0);
  @$pb.TagNumber(1)
  set accountId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => clearField(1);

  /// 账号
  @$pb.TagNumber(2)
  $core.String get accountNo => $_getSZ(1);
  @$pb.TagNumber(2)
  set accountNo($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAccountNo() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountNo() => clearField(2);

  /// 名称
  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => clearField(3);

  /// 持仓编号
  @$pb.TagNumber(4)
  $core.String get positionNo => $_getSZ(3);
  @$pb.TagNumber(4)
  set positionNo($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPositionNo() => $_has(3);
  @$pb.TagNumber(4)
  void clearPositionNo() => clearField(4);

  /// 交易所代码
  @$pb.TagNumber(5)
  $core.String get exchangeNo => $_getSZ(4);
  @$pb.TagNumber(5)
  set exchangeNo($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExchangeNo() => $_has(4);
  @$pb.TagNumber(5)
  void clearExchangeNo() => clearField(5);

  /// 品种代码
  @$pb.TagNumber(6)
  $core.int get commodityType => $_getIZ(5);
  @$pb.TagNumber(6)
  set commodityType($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCommodityType() => $_has(5);
  @$pb.TagNumber(6)
  void clearCommodityType() => clearField(6);

  /// 品种类型
  @$pb.TagNumber(7)
  $core.String get commodityNo => $_getSZ(6);
  @$pb.TagNumber(7)
  set commodityNo($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCommodityNo() => $_has(6);
  @$pb.TagNumber(7)
  void clearCommodityNo() => clearField(7);

  /// 合约代码
  @$pb.TagNumber(8)
  $core.String get contractNo => $_getSZ(7);
  @$pb.TagNumber(8)
  set contractNo($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasContractNo() => $_has(7);
  @$pb.TagNumber(8)
  void clearContractNo() => clearField(8);

  /// 名称
  @$pb.TagNumber(9)
  $core.String get contractName => $_getSZ(8);
  @$pb.TagNumber(9)
  set contractName($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasContractName() => $_has(8);
  @$pb.TagNumber(9)
  void clearContractName() => clearField(9);

  /// 方向
  @$pb.TagNumber(10)
  $core.int get side => $_getIZ(9);
  @$pb.TagNumber(10)
  set side($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasSide() => $_has(9);
  @$pb.TagNumber(10)
  void clearSide() => clearField(10);

  /// 持仓价格
  @$pb.TagNumber(11)
  $core.double get positionPrice => $_getN(10);
  @$pb.TagNumber(11)
  set positionPrice($core.double v) { $_setDouble(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasPositionPrice() => $_has(10);
  @$pb.TagNumber(11)
  void clearPositionPrice() => clearField(11);

  /// 持仓量
  @$pb.TagNumber(12)
  $core.int get positionQty => $_getIZ(11);
  @$pb.TagNumber(12)
  set positionQty($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasPositionQty() => $_has(11);
  @$pb.TagNumber(12)
  void clearPositionQty() => clearField(12);

  /// 可平
  @$pb.TagNumber(13)
  $core.int get availableQty => $_getIZ(12);
  @$pb.TagNumber(13)
  set availableQty($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasAvailableQty() => $_has(12);
  @$pb.TagNumber(13)
  void clearAvailableQty() => clearField(13);

  /// 计算价格
  @$pb.TagNumber(14)
  $core.double get calculatePrice => $_getN(13);
  @$pb.TagNumber(14)
  set calculatePrice($core.double v) { $_setDouble(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasCalculatePrice() => $_has(13);
  @$pb.TagNumber(14)
  void clearCalculatePrice() => clearField(14);

  /// 浮动盈亏
  @$pb.TagNumber(15)
  $core.double get positionFloat => $_getN(14);
  @$pb.TagNumber(15)
  set positionFloat($core.double v) { $_setDouble(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasPositionFloat() => $_has(14);
  @$pb.TagNumber(15)
  void clearPositionFloat() => clearField(15);

  /// 成交时间
  @$pb.TagNumber(16)
  $core.String get createTime => $_getSZ(15);
  @$pb.TagNumber(16)
  set createTime($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasCreateTime() => $_has(15);
  @$pb.TagNumber(16)
  void clearCreateTime() => clearField(16);

  /// 币种
  @$pb.TagNumber(17)
  $core.String get tradeCurrency => $_getSZ(16);
  @$pb.TagNumber(17)
  set tradeCurrency($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasTradeCurrency() => $_has(16);
  @$pb.TagNumber(17)
  void clearTradeCurrency() => clearField(17);

  /// 合约乘数
  @$pb.TagNumber(18)
  $core.double get contractSize => $_getN(17);
  @$pb.TagNumber(18)
  set contractSize($core.double v) { $_setDouble(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasContractSize() => $_has(17);
  @$pb.TagNumber(18)
  void clearContractSize() => clearField(18);

  /// 最小变动价格
  @$pb.TagNumber(19)
  $core.double get commodityTickSize => $_getN(18);
  @$pb.TagNumber(19)
  set commodityTickSize($core.double v) { $_setDouble(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasCommodityTickSize() => $_has(18);
  @$pb.TagNumber(19)
  void clearCommodityTickSize() => clearField(19);

  /// 单笔保证金
  @$pb.TagNumber(20)
  $core.double get deposit => $_getN(19);
  @$pb.TagNumber(20)
  set deposit($core.double v) { $_setDouble(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasDeposit() => $_has(19);
  @$pb.TagNumber(20)
  void clearDeposit() => clearField(20);
}

class CDFYRspOnAccountPositionFloat extends $pb.GeneratedMessage {
  factory CDFYRspOnAccountPositionFloat({
    $fixnum.Int64? accountId,
    $core.String? accountNo,
    $core.String? userName,
    $core.String? positionId,
    $core.String? positionNo,
    $core.double? calculatePrice,
    $core.double? positionProfit,
    $core.String? updateTime,
  }) {
    final $result = create();
    if (accountId != null) {
      $result.accountId = accountId;
    }
    if (accountNo != null) {
      $result.accountNo = accountNo;
    }
    if (userName != null) {
      $result.userName = userName;
    }
    if (positionId != null) {
      $result.positionId = positionId;
    }
    if (positionNo != null) {
      $result.positionNo = positionNo;
    }
    if (calculatePrice != null) {
      $result.calculatePrice = calculatePrice;
    }
    if (positionProfit != null) {
      $result.positionProfit = positionProfit;
    }
    if (updateTime != null) {
      $result.updateTime = updateTime;
    }
    return $result;
  }
  CDFYRspOnAccountPositionFloat._() : super();
  factory CDFYRspOnAccountPositionFloat.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYRspOnAccountPositionFloat.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYRspOnAccountPositionFloat', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'AccountId', protoName: 'AccountId')
    ..aOS(2, _omitFieldNames ? '' : 'AccountNo', protoName: 'AccountNo')
    ..aOS(3, _omitFieldNames ? '' : 'UserName', protoName: 'UserName')
    ..aOS(4, _omitFieldNames ? '' : 'PositionId', protoName: 'PositionId')
    ..aOS(5, _omitFieldNames ? '' : 'PositionNo', protoName: 'PositionNo')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'CalculatePrice', $pb.PbFieldType.OD, protoName: 'CalculatePrice')
    ..a<$core.double>(7, _omitFieldNames ? '' : 'PositionProfit', $pb.PbFieldType.OD, protoName: 'PositionProfit')
    ..aOS(8, _omitFieldNames ? '' : 'UpdateTime', protoName: 'UpdateTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYRspOnAccountPositionFloat clone() => CDFYRspOnAccountPositionFloat()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYRspOnAccountPositionFloat copyWith(void Function(CDFYRspOnAccountPositionFloat) updates) => super.copyWith((message) => updates(message as CDFYRspOnAccountPositionFloat)) as CDFYRspOnAccountPositionFloat;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYRspOnAccountPositionFloat create() => CDFYRspOnAccountPositionFloat._();
  CDFYRspOnAccountPositionFloat createEmptyInstance() => create();
  static $pb.PbList<CDFYRspOnAccountPositionFloat> createRepeated() => $pb.PbList<CDFYRspOnAccountPositionFloat>();
  @$core.pragma('dart2js:noInline')
  static CDFYRspOnAccountPositionFloat getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYRspOnAccountPositionFloat>(create);
  static CDFYRspOnAccountPositionFloat? _defaultInstance;

  /// 账户id
  @$pb.TagNumber(1)
  $fixnum.Int64 get accountId => $_getI64(0);
  @$pb.TagNumber(1)
  set accountId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => clearField(1);

  /// 账号
  @$pb.TagNumber(2)
  $core.String get accountNo => $_getSZ(1);
  @$pb.TagNumber(2)
  set accountNo($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAccountNo() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountNo() => clearField(2);

  /// 名称
  @$pb.TagNumber(3)
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => clearField(3);

  /// 持仓id
  @$pb.TagNumber(4)
  $core.String get positionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set positionId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPositionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearPositionId() => clearField(4);

  /// 持仓编号
  @$pb.TagNumber(5)
  $core.String get positionNo => $_getSZ(4);
  @$pb.TagNumber(5)
  set positionNo($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPositionNo() => $_has(4);
  @$pb.TagNumber(5)
  void clearPositionNo() => clearField(5);

  /// 计算价格
  @$pb.TagNumber(6)
  $core.double get calculatePrice => $_getN(5);
  @$pb.TagNumber(6)
  set calculatePrice($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCalculatePrice() => $_has(5);
  @$pb.TagNumber(6)
  void clearCalculatePrice() => clearField(6);

  /// 逐笔持仓浮盈
  @$pb.TagNumber(7)
  $core.double get positionProfit => $_getN(6);
  @$pb.TagNumber(7)
  set positionProfit($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasPositionProfit() => $_has(6);
  @$pb.TagNumber(7)
  void clearPositionProfit() => clearField(7);

  /// 更新时间
  @$pb.TagNumber(8)
  $core.String get updateTime => $_getSZ(7);
  @$pb.TagNumber(8)
  set updateTime($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasUpdateTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdateTime() => clearField(8);
}

class CDFYOnRateInfo extends $pb.GeneratedMessage {
  factory CDFYOnRateInfo({
    $core.double? uSD,
    $core.double? hKD,
    $core.double? eUR,
    $core.double? jPY,
    $core.double? gBP,
    $core.double? cNH,
  }) {
    final $result = create();
    if (uSD != null) {
      $result.uSD = uSD;
    }
    if (hKD != null) {
      $result.hKD = hKD;
    }
    if (eUR != null) {
      $result.eUR = eUR;
    }
    if (jPY != null) {
      $result.jPY = jPY;
    }
    if (gBP != null) {
      $result.gBP = gBP;
    }
    if (cNH != null) {
      $result.cNH = cNH;
    }
    return $result;
  }
  CDFYOnRateInfo._() : super();
  factory CDFYOnRateInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYOnRateInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYOnRateInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'USD', $pb.PbFieldType.OD, protoName: 'USD')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'HKD', $pb.PbFieldType.OD, protoName: 'HKD')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'EUR', $pb.PbFieldType.OD, protoName: 'EUR')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'JPY', $pb.PbFieldType.OD, protoName: 'JPY')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'GBP', $pb.PbFieldType.OD, protoName: 'GBP')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'CNH', $pb.PbFieldType.OD, protoName: 'CNH')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYOnRateInfo clone() => CDFYOnRateInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYOnRateInfo copyWith(void Function(CDFYOnRateInfo) updates) => super.copyWith((message) => updates(message as CDFYOnRateInfo)) as CDFYOnRateInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYOnRateInfo create() => CDFYOnRateInfo._();
  CDFYOnRateInfo createEmptyInstance() => create();
  static $pb.PbList<CDFYOnRateInfo> createRepeated() => $pb.PbList<CDFYOnRateInfo>();
  @$core.pragma('dart2js:noInline')
  static CDFYOnRateInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYOnRateInfo>(create);
  static CDFYOnRateInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get uSD => $_getN(0);
  @$pb.TagNumber(1)
  set uSD($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUSD() => $_has(0);
  @$pb.TagNumber(1)
  void clearUSD() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get hKD => $_getN(1);
  @$pb.TagNumber(2)
  set hKD($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHKD() => $_has(1);
  @$pb.TagNumber(2)
  void clearHKD() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get eUR => $_getN(2);
  @$pb.TagNumber(3)
  set eUR($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEUR() => $_has(2);
  @$pb.TagNumber(3)
  void clearEUR() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get jPY => $_getN(3);
  @$pb.TagNumber(4)
  set jPY($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasJPY() => $_has(3);
  @$pb.TagNumber(4)
  void clearJPY() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get gBP => $_getN(4);
  @$pb.TagNumber(5)
  set gBP($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasGBP() => $_has(4);
  @$pb.TagNumber(5)
  void clearGBP() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get cNH => $_getN(5);
  @$pb.TagNumber(6)
  set cNH($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCNH() => $_has(5);
  @$pb.TagNumber(6)
  void clearCNH() => clearField(6);
}

/// REP_OPT_LOGIN message
class CDFYOnRateUpdate extends $pb.GeneratedMessage {
  factory CDFYOnRateUpdate({
    $fixnum.Int64? id,
    $core.String? name,
    CDFYOnRateInfo? info,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (info != null) {
      $result.info = info;
    }
    return $result;
  }
  CDFYOnRateUpdate._() : super();
  factory CDFYOnRateUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CDFYOnRateUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CDFYOnRateUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'Id', protoName: 'Id')
    ..aOS(2, _omitFieldNames ? '' : 'Name', protoName: 'Name')
    ..aOM<CDFYOnRateInfo>(3, _omitFieldNames ? '' : 'info', subBuilder: CDFYOnRateInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CDFYOnRateUpdate clone() => CDFYOnRateUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CDFYOnRateUpdate copyWith(void Function(CDFYOnRateUpdate) updates) => super.copyWith((message) => updates(message as CDFYOnRateUpdate)) as CDFYOnRateUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CDFYOnRateUpdate create() => CDFYOnRateUpdate._();
  CDFYOnRateUpdate createEmptyInstance() => create();
  static $pb.PbList<CDFYOnRateUpdate> createRepeated() => $pb.PbList<CDFYOnRateUpdate>();
  @$core.pragma('dart2js:noInline')
  static CDFYOnRateUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CDFYOnRateUpdate>(create);
  static CDFYOnRateUpdate? _defaultInstance;

  /// 模板编号
  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// 模板名称
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  /// 币种汇率
  @$pb.TagNumber(3)
  CDFYOnRateInfo get info => $_getN(2);
  @$pb.TagNumber(3)
  set info(CDFYOnRateInfo v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasInfo() => $_has(2);
  @$pb.TagNumber(3)
  void clearInfo() => clearField(3);
  @$pb.TagNumber(3)
  CDFYOnRateInfo ensureInfo() => $_ensure(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
