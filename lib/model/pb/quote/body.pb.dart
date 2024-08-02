//
//  Generated code. Do not modify.
//  source: proto/quote/body.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../quote/line.pbenum.dart' as $0;

class SubInfo extends $pb.GeneratedMessage {
  factory SubInfo({
    $core.String? key,
    $0.Line? line,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (line != null) {
      $result.line = line;
    }
    return $result;
  }
  SubInfo._() : super();
  factory SubInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Key', protoName: 'Key')
    ..e<$0.Line>(2, _omitFieldNames ? '' : 'Line', $pb.PbFieldType.OE, protoName: 'Line', defaultOrMaker: $0.Line.KL1M, valueOf: $0.Line.valueOf, enumValues: $0.Line.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubInfo clone() => SubInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubInfo copyWith(void Function(SubInfo) updates) => super.copyWith((message) => updates(message as SubInfo)) as SubInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubInfo create() => SubInfo._();
  SubInfo createEmptyInstance() => create();
  static $pb.PbList<SubInfo> createRepeated() => $pb.PbList<SubInfo>();
  @$core.pragma('dart2js:noInline')
  static SubInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubInfo>(create);
  static SubInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  @$pb.TagNumber(2)
  $0.Line get line => $_getN(1);
  @$pb.TagNumber(2)
  set line($0.Line v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLine() => $_has(1);
  @$pb.TagNumber(2)
  void clearLine() => clearField(2);
}

class SubStatus extends $pb.GeneratedMessage {
  factory SubStatus({
    $core.int? code,
    $core.String? msg,
    SubInfo? subInfo,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (subInfo != null) {
      $result.subInfo = subInfo;
    }
    return $result;
  }
  SubStatus._() : super();
  factory SubStatus.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubStatus.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubStatus', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOM<SubInfo>(3, _omitFieldNames ? '' : 'SubInfo', protoName: 'SubInfo', subBuilder: SubInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubStatus clone() => SubStatus()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubStatus copyWith(void Function(SubStatus) updates) => super.copyWith((message) => updates(message as SubStatus)) as SubStatus;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubStatus create() => SubStatus._();
  SubStatus createEmptyInstance() => create();
  static $pb.PbList<SubStatus> createRepeated() => $pb.PbList<SubStatus>();
  @$core.pragma('dart2js:noInline')
  static SubStatus getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubStatus>(create);
  static SubStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  SubInfo get subInfo => $_getN(2);
  @$pb.TagNumber(3)
  set subInfo(SubInfo v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSubInfo() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubInfo() => clearField(3);
  @$pb.TagNumber(3)
  SubInfo ensureSubInfo() => $_ensure(2);
}

class AuthReq extends $pb.GeneratedMessage {
  factory AuthReq({
    $core.String? auth,
  }) {
    final $result = create();
    if (auth != null) {
      $result.auth = auth;
    }
    return $result;
  }
  AuthReq._() : super();
  factory AuthReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AuthReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Auth', protoName: 'Auth')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AuthReq clone() => AuthReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AuthReq copyWith(void Function(AuthReq) updates) => super.copyWith((message) => updates(message as AuthReq)) as AuthReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthReq create() => AuthReq._();
  AuthReq createEmptyInstance() => create();
  static $pb.PbList<AuthReq> createRepeated() => $pb.PbList<AuthReq>();
  @$core.pragma('dart2js:noInline')
  static AuthReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthReq>(create);
  static AuthReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get auth => $_getSZ(0);
  @$pb.TagNumber(1)
  set auth($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAuth() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuth() => clearField(1);
}

class AuthResp extends $pb.GeneratedMessage {
  factory AuthResp({
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
  AuthResp._() : super();
  factory AuthResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AuthResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AuthResp clone() => AuthResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AuthResp copyWith(void Function(AuthResp) updates) => super.copyWith((message) => updates(message as AuthResp)) as AuthResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthResp create() => AuthResp._();
  AuthResp createEmptyInstance() => create();
  static $pb.PbList<AuthResp> createRepeated() => $pb.PbList<AuthResp>();
  @$core.pragma('dart2js:noInline')
  static AuthResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthResp>(create);
  static AuthResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class SubReq extends $pb.GeneratedMessage {
  factory SubReq({
    $core.Iterable<SubInfo>? subs,
  }) {
    final $result = create();
    if (subs != null) {
      $result.subs.addAll(subs);
    }
    return $result;
  }
  SubReq._() : super();
  factory SubReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..pc<SubInfo>(1, _omitFieldNames ? '' : 'Subs', $pb.PbFieldType.PM, protoName: 'Subs', subBuilder: SubInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubReq clone() => SubReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubReq copyWith(void Function(SubReq) updates) => super.copyWith((message) => updates(message as SubReq)) as SubReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubReq create() => SubReq._();
  SubReq createEmptyInstance() => create();
  static $pb.PbList<SubReq> createRepeated() => $pb.PbList<SubReq>();
  @$core.pragma('dart2js:noInline')
  static SubReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubReq>(create);
  static SubReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SubInfo> get subs => $_getList(0);
}

class SubResp extends $pb.GeneratedMessage {
  factory SubResp({
    $core.int? code,
    $core.String? msg,
    $core.Iterable<SubStatus>? status,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (status != null) {
      $result.status.addAll(status);
    }
    return $result;
  }
  SubResp._() : super();
  factory SubResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..pc<SubStatus>(3, _omitFieldNames ? '' : 'status', $pb.PbFieldType.PM, subBuilder: SubStatus.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubResp clone() => SubResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubResp copyWith(void Function(SubResp) updates) => super.copyWith((message) => updates(message as SubResp)) as SubResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubResp create() => SubResp._();
  SubResp createEmptyInstance() => create();
  static $pb.PbList<SubResp> createRepeated() => $pb.PbList<SubResp>();
  @$core.pragma('dart2js:noInline')
  static SubResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubResp>(create);
  static SubResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<SubStatus> get status => $_getList(2);
}

class SubFillReq extends $pb.GeneratedMessage {
  factory SubFillReq({
    $core.String? key,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    return $result;
  }
  SubFillReq._() : super();
  factory SubFillReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubFillReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubFillReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Key', protoName: 'Key')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubFillReq clone() => SubFillReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubFillReq copyWith(void Function(SubFillReq) updates) => super.copyWith((message) => updates(message as SubFillReq)) as SubFillReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubFillReq create() => SubFillReq._();
  SubFillReq createEmptyInstance() => create();
  static $pb.PbList<SubFillReq> createRepeated() => $pb.PbList<SubFillReq>();
  @$core.pragma('dart2js:noInline')
  static SubFillReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubFillReq>(create);
  static SubFillReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);
}

class SubFillResp extends $pb.GeneratedMessage {
  factory SubFillResp({
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
  SubFillResp._() : super();
  factory SubFillResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubFillResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubFillResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubFillResp clone() => SubFillResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubFillResp copyWith(void Function(SubFillResp) updates) => super.copyWith((message) => updates(message as SubFillResp)) as SubFillResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubFillResp create() => SubFillResp._();
  SubFillResp createEmptyInstance() => create();
  static $pb.PbList<SubFillResp> createRepeated() => $pb.PbList<SubFillResp>();
  @$core.pragma('dart2js:noInline')
  static SubFillResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubFillResp>(create);
  static SubFillResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class UnSubFillReq extends $pb.GeneratedMessage {
  factory UnSubFillReq({
    $core.String? key,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    return $result;
  }
  UnSubFillReq._() : super();
  factory UnSubFillReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnSubFillReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnSubFillReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Key', protoName: 'Key')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnSubFillReq clone() => UnSubFillReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnSubFillReq copyWith(void Function(UnSubFillReq) updates) => super.copyWith((message) => updates(message as UnSubFillReq)) as UnSubFillReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnSubFillReq create() => UnSubFillReq._();
  UnSubFillReq createEmptyInstance() => create();
  static $pb.PbList<UnSubFillReq> createRepeated() => $pb.PbList<UnSubFillReq>();
  @$core.pragma('dart2js:noInline')
  static UnSubFillReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnSubFillReq>(create);
  static UnSubFillReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);
}

class UnSubFillResp extends $pb.GeneratedMessage {
  factory UnSubFillResp({
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
  UnSubFillResp._() : super();
  factory UnSubFillResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnSubFillResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnSubFillResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnSubFillResp clone() => UnSubFillResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnSubFillResp copyWith(void Function(UnSubFillResp) updates) => super.copyWith((message) => updates(message as UnSubFillResp)) as UnSubFillResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnSubFillResp create() => UnSubFillResp._();
  UnSubFillResp createEmptyInstance() => create();
  static $pb.PbList<UnSubFillResp> createRepeated() => $pb.PbList<UnSubFillResp>();
  @$core.pragma('dart2js:noInline')
  static UnSubFillResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnSubFillResp>(create);
  static UnSubFillResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class SubQuoteReq extends $pb.GeneratedMessage {
  factory SubQuoteReq({
    $core.String? key,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    return $result;
  }
  SubQuoteReq._() : super();
  factory SubQuoteReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubQuoteReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubQuoteReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Key', protoName: 'Key')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubQuoteReq clone() => SubQuoteReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubQuoteReq copyWith(void Function(SubQuoteReq) updates) => super.copyWith((message) => updates(message as SubQuoteReq)) as SubQuoteReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubQuoteReq create() => SubQuoteReq._();
  SubQuoteReq createEmptyInstance() => create();
  static $pb.PbList<SubQuoteReq> createRepeated() => $pb.PbList<SubQuoteReq>();
  @$core.pragma('dart2js:noInline')
  static SubQuoteReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubQuoteReq>(create);
  static SubQuoteReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);
}

class SubQuoteResp extends $pb.GeneratedMessage {
  factory SubQuoteResp({
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
  SubQuoteResp._() : super();
  factory SubQuoteResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubQuoteResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubQuoteResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubQuoteResp clone() => SubQuoteResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubQuoteResp copyWith(void Function(SubQuoteResp) updates) => super.copyWith((message) => updates(message as SubQuoteResp)) as SubQuoteResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubQuoteResp create() => SubQuoteResp._();
  SubQuoteResp createEmptyInstance() => create();
  static $pb.PbList<SubQuoteResp> createRepeated() => $pb.PbList<SubQuoteResp>();
  @$core.pragma('dart2js:noInline')
  static SubQuoteResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubQuoteResp>(create);
  static SubQuoteResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class UnSubQuoteReq extends $pb.GeneratedMessage {
  factory UnSubQuoteReq({
    $core.String? key,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    return $result;
  }
  UnSubQuoteReq._() : super();
  factory UnSubQuoteReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnSubQuoteReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnSubQuoteReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Key', protoName: 'Key')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnSubQuoteReq clone() => UnSubQuoteReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnSubQuoteReq copyWith(void Function(UnSubQuoteReq) updates) => super.copyWith((message) => updates(message as UnSubQuoteReq)) as UnSubQuoteReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnSubQuoteReq create() => UnSubQuoteReq._();
  UnSubQuoteReq createEmptyInstance() => create();
  static $pb.PbList<UnSubQuoteReq> createRepeated() => $pb.PbList<UnSubQuoteReq>();
  @$core.pragma('dart2js:noInline')
  static UnSubQuoteReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnSubQuoteReq>(create);
  static UnSubQuoteReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);
}

class UnSubQuoteResp extends $pb.GeneratedMessage {
  factory UnSubQuoteResp({
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
  UnSubQuoteResp._() : super();
  factory UnSubQuoteResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnSubQuoteResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnSubQuoteResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnSubQuoteResp clone() => UnSubQuoteResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnSubQuoteResp copyWith(void Function(UnSubQuoteResp) updates) => super.copyWith((message) => updates(message as UnSubQuoteResp)) as UnSubQuoteResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnSubQuoteResp create() => UnSubQuoteResp._();
  UnSubQuoteResp createEmptyInstance() => create();
  static $pb.PbList<UnSubQuoteResp> createRepeated() => $pb.PbList<UnSubQuoteResp>();
  @$core.pragma('dart2js:noInline')
  static UnSubQuoteResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnSubQuoteResp>(create);
  static UnSubQuoteResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class SubKlineReq extends $pb.GeneratedMessage {
  factory SubKlineReq({
    $core.String? key,
    $0.Line? line,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (line != null) {
      $result.line = line;
    }
    return $result;
  }
  SubKlineReq._() : super();
  factory SubKlineReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubKlineReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubKlineReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Key', protoName: 'Key')
    ..e<$0.Line>(2, _omitFieldNames ? '' : 'Line', $pb.PbFieldType.OE, protoName: 'Line', defaultOrMaker: $0.Line.KL1M, valueOf: $0.Line.valueOf, enumValues: $0.Line.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubKlineReq clone() => SubKlineReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubKlineReq copyWith(void Function(SubKlineReq) updates) => super.copyWith((message) => updates(message as SubKlineReq)) as SubKlineReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubKlineReq create() => SubKlineReq._();
  SubKlineReq createEmptyInstance() => create();
  static $pb.PbList<SubKlineReq> createRepeated() => $pb.PbList<SubKlineReq>();
  @$core.pragma('dart2js:noInline')
  static SubKlineReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubKlineReq>(create);
  static SubKlineReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  @$pb.TagNumber(2)
  $0.Line get line => $_getN(1);
  @$pb.TagNumber(2)
  set line($0.Line v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLine() => $_has(1);
  @$pb.TagNumber(2)
  void clearLine() => clearField(2);
}

class SubKlineResp extends $pb.GeneratedMessage {
  factory SubKlineResp({
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
  SubKlineResp._() : super();
  factory SubKlineResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubKlineResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubKlineResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubKlineResp clone() => SubKlineResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubKlineResp copyWith(void Function(SubKlineResp) updates) => super.copyWith((message) => updates(message as SubKlineResp)) as SubKlineResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubKlineResp create() => SubKlineResp._();
  SubKlineResp createEmptyInstance() => create();
  static $pb.PbList<SubKlineResp> createRepeated() => $pb.PbList<SubKlineResp>();
  @$core.pragma('dart2js:noInline')
  static SubKlineResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubKlineResp>(create);
  static SubKlineResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class UnSubKlineReq extends $pb.GeneratedMessage {
  factory UnSubKlineReq({
    $core.String? key,
    $0.Line? line,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (line != null) {
      $result.line = line;
    }
    return $result;
  }
  UnSubKlineReq._() : super();
  factory UnSubKlineReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnSubKlineReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnSubKlineReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'Key', protoName: 'Key')
    ..e<$0.Line>(2, _omitFieldNames ? '' : 'Line', $pb.PbFieldType.OE, protoName: 'Line', defaultOrMaker: $0.Line.KL1M, valueOf: $0.Line.valueOf, enumValues: $0.Line.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnSubKlineReq clone() => UnSubKlineReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnSubKlineReq copyWith(void Function(UnSubKlineReq) updates) => super.copyWith((message) => updates(message as UnSubKlineReq)) as UnSubKlineReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnSubKlineReq create() => UnSubKlineReq._();
  UnSubKlineReq createEmptyInstance() => create();
  static $pb.PbList<UnSubKlineReq> createRepeated() => $pb.PbList<UnSubKlineReq>();
  @$core.pragma('dart2js:noInline')
  static UnSubKlineReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnSubKlineReq>(create);
  static UnSubKlineReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  @$pb.TagNumber(2)
  $0.Line get line => $_getN(1);
  @$pb.TagNumber(2)
  set line($0.Line v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLine() => $_has(1);
  @$pb.TagNumber(2)
  void clearLine() => clearField(2);
}

class UnSubKlineResp extends $pb.GeneratedMessage {
  factory UnSubKlineResp({
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
  UnSubKlineResp._() : super();
  factory UnSubKlineResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnSubKlineResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnSubKlineResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnSubKlineResp clone() => UnSubKlineResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnSubKlineResp copyWith(void Function(UnSubKlineResp) updates) => super.copyWith((message) => updates(message as UnSubKlineResp)) as UnSubKlineResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnSubKlineResp create() => UnSubKlineResp._();
  UnSubKlineResp createEmptyInstance() => create();
  static $pb.PbList<UnSubKlineResp> createRepeated() => $pb.PbList<UnSubKlineResp>();
  @$core.pragma('dart2js:noInline')
  static UnSubKlineResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnSubKlineResp>(create);
  static UnSubKlineResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class UnSubAllReq extends $pb.GeneratedMessage {
  factory UnSubAllReq() => create();
  UnSubAllReq._() : super();
  factory UnSubAllReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnSubAllReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnSubAllReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnSubAllReq clone() => UnSubAllReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnSubAllReq copyWith(void Function(UnSubAllReq) updates) => super.copyWith((message) => updates(message as UnSubAllReq)) as UnSubAllReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnSubAllReq create() => UnSubAllReq._();
  UnSubAllReq createEmptyInstance() => create();
  static $pb.PbList<UnSubAllReq> createRepeated() => $pb.PbList<UnSubAllReq>();
  @$core.pragma('dart2js:noInline')
  static UnSubAllReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnSubAllReq>(create);
  static UnSubAllReq? _defaultInstance;
}

class UnSubAllResp extends $pb.GeneratedMessage {
  factory UnSubAllResp({
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
  UnSubAllResp._() : super();
  factory UnSubAllResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnSubAllResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnSubAllResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnSubAllResp clone() => UnSubAllResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnSubAllResp copyWith(void Function(UnSubAllResp) updates) => super.copyWith((message) => updates(message as UnSubAllResp)) as UnSubAllResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnSubAllResp create() => UnSubAllResp._();
  UnSubAllResp createEmptyInstance() => create();
  static $pb.PbList<UnSubAllResp> createRepeated() => $pb.PbList<UnSubAllResp>();
  @$core.pragma('dart2js:noInline')
  static UnSubAllResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnSubAllResp>(create);
  static UnSubAllResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
