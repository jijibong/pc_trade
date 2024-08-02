//
//  Generated code. Do not modify.
//  source: proto/quote/kdata.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../quote/line.pbenum.dart' as $0;

class KlineData extends $pb.GeneratedMessage {
  factory KlineData({
    $core.String? key,
    $0.Line? line,
    Data? data,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (line != null) {
      $result.line = line;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  KlineData._() : super();
  factory KlineData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KlineData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KlineData', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..e<$0.Line>(2, _omitFieldNames ? '' : 'line', $pb.PbFieldType.OE, defaultOrMaker: $0.Line.KL1M, valueOf: $0.Line.valueOf, enumValues: $0.Line.values)
    ..aOM<Data>(3, _omitFieldNames ? '' : 'Data', protoName: 'Data', subBuilder: Data.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KlineData clone() => KlineData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KlineData copyWith(void Function(KlineData) updates) => super.copyWith((message) => updates(message as KlineData)) as KlineData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KlineData create() => KlineData._();
  KlineData createEmptyInstance() => create();
  static $pb.PbList<KlineData> createRepeated() => $pb.PbList<KlineData>();
  @$core.pragma('dart2js:noInline')
  static KlineData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KlineData>(create);
  static KlineData? _defaultInstance;

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

  @$pb.TagNumber(3)
  Data get data => $_getN(2);
  @$pb.TagNumber(3)
  set data(Data v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);
  @$pb.TagNumber(3)
  Data ensureData() => $_ensure(2);
}

class Data extends $pb.GeneratedMessage {
  factory Data({
    $core.double? open,
    $core.double? high,
    $core.double? low,
    $core.double? close,
    $core.double? volume,
    $core.double? amount,
    $fixnum.Int64? uxTime,
  }) {
    final $result = create();
    if (open != null) {
      $result.open = open;
    }
    if (high != null) {
      $result.high = high;
    }
    if (low != null) {
      $result.low = low;
    }
    if (close != null) {
      $result.close = close;
    }
    if (volume != null) {
      $result.volume = volume;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (uxTime != null) {
      $result.uxTime = uxTime;
    }
    return $result;
  }
  Data._() : super();
  factory Data.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Data.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Data', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'Open', $pb.PbFieldType.OD, protoName: 'Open')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'High', $pb.PbFieldType.OD, protoName: 'High')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'Low', $pb.PbFieldType.OD, protoName: 'Low')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'Close', $pb.PbFieldType.OD, protoName: 'Close')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'Volume', $pb.PbFieldType.OD, protoName: 'Volume')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'Amount', $pb.PbFieldType.OD, protoName: 'Amount')
    ..aInt64(7, _omitFieldNames ? '' : 'UxTime', protoName: 'UxTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Data clone() => Data()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Data copyWith(void Function(Data) updates) => super.copyWith((message) => updates(message as Data)) as Data;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Data create() => Data._();
  Data createEmptyInstance() => create();
  static $pb.PbList<Data> createRepeated() => $pb.PbList<Data>();
  @$core.pragma('dart2js:noInline')
  static Data getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Data>(create);
  static Data? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get open => $_getN(0);
  @$pb.TagNumber(1)
  set open($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOpen() => $_has(0);
  @$pb.TagNumber(1)
  void clearOpen() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get high => $_getN(1);
  @$pb.TagNumber(2)
  set high($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHigh() => $_has(1);
  @$pb.TagNumber(2)
  void clearHigh() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get low => $_getN(2);
  @$pb.TagNumber(3)
  set low($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLow() => $_has(2);
  @$pb.TagNumber(3)
  void clearLow() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get close => $_getN(3);
  @$pb.TagNumber(4)
  set close($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasClose() => $_has(3);
  @$pb.TagNumber(4)
  void clearClose() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get volume => $_getN(4);
  @$pb.TagNumber(5)
  set volume($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVolume() => $_has(4);
  @$pb.TagNumber(5)
  void clearVolume() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get amount => $_getN(5);
  @$pb.TagNumber(6)
  set amount($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmount() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get uxTime => $_getI64(6);
  @$pb.TagNumber(7)
  set uxTime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasUxTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearUxTime() => clearField(7);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
