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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'cmd.pbenum.dart';

export 'cmd.pbenum.dart';

class cmd extends $pb.GeneratedMessage {
  factory cmd({
    Option? option,
    $fixnum.Int64? reqId,
    $fixnum.Int64? dateTime,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (option != null) {
      $result.option = option;
    }
    if (reqId != null) {
      $result.reqId = reqId;
    }
    if (dateTime != null) {
      $result.dateTime = dateTime;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  cmd._() : super();
  factory cmd.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory cmd.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'cmd', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..e<Option>(1, _omitFieldNames ? '' : 'Option', $pb.PbFieldType.OE, protoName: 'Option', defaultOrMaker: Option.REQ_OPT_UNIVERSAL, valueOf: Option.valueOf, enumValues: Option.values)
    ..aInt64(2, _omitFieldNames ? '' : 'ReqId', protoName: 'ReqId')
    ..aInt64(3, _omitFieldNames ? '' : 'DateTime', protoName: 'DateTime')
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'Data', $pb.PbFieldType.OY, protoName: 'Data')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  cmd clone() => cmd()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  cmd copyWith(void Function(cmd) updates) => super.copyWith((message) => updates(message as cmd)) as cmd;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static cmd create() => cmd._();
  cmd createEmptyInstance() => create();
  static $pb.PbList<cmd> createRepeated() => $pb.PbList<cmd>();
  @$core.pragma('dart2js:noInline')
  static cmd getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<cmd>(create);
  static cmd? _defaultInstance;

  @$pb.TagNumber(1)
  Option get option => $_getN(0);
  @$pb.TagNumber(1)
  set option(Option v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasOption() => $_has(0);
  @$pb.TagNumber(1)
  void clearOption() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get reqId => $_getI64(1);
  @$pb.TagNumber(2)
  set reqId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReqId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReqId() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get dateTime => $_getI64(2);
  @$pb.TagNumber(3)
  set dateTime($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDateTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearDateTime() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get data => $_getN(3);
  @$pb.TagNumber(4)
  set data($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasData() => $_has(3);
  @$pb.TagNumber(4)
  void clearData() => clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
