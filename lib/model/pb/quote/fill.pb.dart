//
//  Generated code. Do not modify.
//  source: proto/quote/fill.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class FillData extends $pb.GeneratedMessage {
  factory FillData({
    $core.String? exchangeNo,
    $core.String? commodityType,
    $core.String? commodityNo,
    $core.String? contractNo,
    $core.double? lastPrice,
    $core.double? volume,
    $core.double? filledVolume,
    $core.int? openInterestDeltaForward,
    $core.int? orderForward,
    $core.String? updateTime,
  }) {
    final $result = create();
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
    if (lastPrice != null) {
      $result.lastPrice = lastPrice;
    }
    if (volume != null) {
      $result.volume = volume;
    }
    if (filledVolume != null) {
      $result.filledVolume = filledVolume;
    }
    if (openInterestDeltaForward != null) {
      $result.openInterestDeltaForward = openInterestDeltaForward;
    }
    if (orderForward != null) {
      $result.orderForward = orderForward;
    }
    if (updateTime != null) {
      $result.updateTime = updateTime;
    }
    return $result;
  }
  FillData._() : super();
  factory FillData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FillData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FillData', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ExchangeNo', protoName: 'ExchangeNo')
    ..aOS(2, _omitFieldNames ? '' : 'CommodityType', protoName: 'CommodityType')
    ..aOS(3, _omitFieldNames ? '' : 'CommodityNo', protoName: 'CommodityNo')
    ..aOS(4, _omitFieldNames ? '' : 'ContractNo', protoName: 'ContractNo')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'LastPrice', $pb.PbFieldType.OD, protoName: 'LastPrice')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'Volume', $pb.PbFieldType.OD, protoName: 'Volume')
    ..a<$core.double>(7, _omitFieldNames ? '' : 'FilledVolume', $pb.PbFieldType.OD, protoName: 'FilledVolume')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'OpenInterestDeltaForward', $pb.PbFieldType.OU3, protoName: 'OpenInterestDeltaForward')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'OrderForward', $pb.PbFieldType.OU3, protoName: 'OrderForward')
    ..aOS(10, _omitFieldNames ? '' : 'UpdateTime', protoName: 'UpdateTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FillData clone() => FillData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FillData copyWith(void Function(FillData) updates) => super.copyWith((message) => updates(message as FillData)) as FillData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FillData create() => FillData._();
  FillData createEmptyInstance() => create();
  static $pb.PbList<FillData> createRepeated() => $pb.PbList<FillData>();
  @$core.pragma('dart2js:noInline')
  static FillData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FillData>(create);
  static FillData? _defaultInstance;

  /// 交易所编码
  @$pb.TagNumber(1)
  $core.String get exchangeNo => $_getSZ(0);
  @$pb.TagNumber(1)
  set exchangeNo($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasExchangeNo() => $_has(0);
  @$pb.TagNumber(1)
  void clearExchangeNo() => clearField(1);

  /// 品种类型
  @$pb.TagNumber(2)
  $core.String get commodityType => $_getSZ(1);
  @$pb.TagNumber(2)
  set commodityType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCommodityType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommodityType() => clearField(2);

  /// 品种编号
  @$pb.TagNumber(3)
  $core.String get commodityNo => $_getSZ(2);
  @$pb.TagNumber(3)
  set commodityNo($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCommodityNo() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommodityNo() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get contractNo => $_getSZ(3);
  @$pb.TagNumber(4)
  set contractNo($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasContractNo() => $_has(3);
  @$pb.TagNumber(4)
  void clearContractNo() => clearField(4);

  /// / 成交价
  @$pb.TagNumber(5)
  $core.double get lastPrice => $_getN(4);
  @$pb.TagNumber(5)
  set lastPrice($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLastPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastPrice() => clearField(5);

  /// / 现手
  @$pb.TagNumber(6)
  $core.double get volume => $_getN(5);
  @$pb.TagNumber(6)
  set volume($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasVolume() => $_has(5);
  @$pb.TagNumber(6)
  void clearVolume() => clearField(6);

  /// / 增仓
  @$pb.TagNumber(7)
  $core.double get filledVolume => $_getN(6);
  @$pb.TagNumber(7)
  set filledVolume($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasFilledVolume() => $_has(6);
  @$pb.TagNumber(7)
  void clearFilledVolume() => clearField(7);

  /// / 开平
  @$pb.TagNumber(8)
  $core.int get openInterestDeltaForward => $_getIZ(7);
  @$pb.TagNumber(8)
  set openInterestDeltaForward($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasOpenInterestDeltaForward() => $_has(7);
  @$pb.TagNumber(8)
  void clearOpenInterestDeltaForward() => clearField(8);

  /// / 价格趋势
  @$pb.TagNumber(9)
  $core.int get orderForward => $_getIZ(8);
  @$pb.TagNumber(9)
  set orderForward($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasOrderForward() => $_has(8);
  @$pb.TagNumber(9)
  void clearOrderForward() => clearField(9);

  /// /最后修改时间
  @$pb.TagNumber(10)
  $core.String get updateTime => $_getSZ(9);
  @$pb.TagNumber(10)
  set updateTime($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasUpdateTime() => $_has(9);
  @$pb.TagNumber(10)
  void clearUpdateTime() => clearField(10);
}

class FillDataV2 extends $pb.GeneratedMessage {
  factory FillDataV2({
    $core.String? exchangeNo,
    $core.String? commodityType,
    $core.String? commodityNo,
    $core.String? contractNo,
    $core.double? lastPrice,
    $core.double? upDown,
    $core.double? volume,
    $core.double? open,
    $core.double? close,
    $core.int? tickType,
    $core.int? tickColor,
    $core.String? updateTime,
  }) {
    final $result = create();
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
    if (lastPrice != null) {
      $result.lastPrice = lastPrice;
    }
    if (upDown != null) {
      $result.upDown = upDown;
    }
    if (volume != null) {
      $result.volume = volume;
    }
    if (open != null) {
      $result.open = open;
    }
    if (close != null) {
      $result.close = close;
    }
    if (tickType != null) {
      $result.tickType = tickType;
    }
    if (tickColor != null) {
      $result.tickColor = tickColor;
    }
    if (updateTime != null) {
      $result.updateTime = updateTime;
    }
    return $result;
  }
  FillDataV2._() : super();
  factory FillDataV2.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FillDataV2.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FillDataV2', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ExchangeNo', protoName: 'ExchangeNo')
    ..aOS(2, _omitFieldNames ? '' : 'CommodityType', protoName: 'CommodityType')
    ..aOS(3, _omitFieldNames ? '' : 'CommodityNo', protoName: 'CommodityNo')
    ..aOS(4, _omitFieldNames ? '' : 'ContractNo', protoName: 'ContractNo')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'LastPrice', $pb.PbFieldType.OD, protoName: 'LastPrice')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'UpDown', $pb.PbFieldType.OD, protoName: 'UpDown')
    ..a<$core.double>(7, _omitFieldNames ? '' : 'Volume', $pb.PbFieldType.OD, protoName: 'Volume')
    ..a<$core.double>(8, _omitFieldNames ? '' : 'Open', $pb.PbFieldType.OD, protoName: 'Open')
    ..a<$core.double>(9, _omitFieldNames ? '' : 'Close', $pb.PbFieldType.OD, protoName: 'Close')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'TickType', $pb.PbFieldType.OU3, protoName: 'TickType')
    ..a<$core.int>(11, _omitFieldNames ? '' : 'TickColor', $pb.PbFieldType.OU3, protoName: 'TickColor')
    ..aOS(12, _omitFieldNames ? '' : 'UpdateTime', protoName: 'UpdateTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FillDataV2 clone() => FillDataV2()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FillDataV2 copyWith(void Function(FillDataV2) updates) => super.copyWith((message) => updates(message as FillDataV2)) as FillDataV2;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FillDataV2 create() => FillDataV2._();
  FillDataV2 createEmptyInstance() => create();
  static $pb.PbList<FillDataV2> createRepeated() => $pb.PbList<FillDataV2>();
  @$core.pragma('dart2js:noInline')
  static FillDataV2 getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FillDataV2>(create);
  static FillDataV2? _defaultInstance;

  /// 交易所编码
  @$pb.TagNumber(1)
  $core.String get exchangeNo => $_getSZ(0);
  @$pb.TagNumber(1)
  set exchangeNo($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasExchangeNo() => $_has(0);
  @$pb.TagNumber(1)
  void clearExchangeNo() => clearField(1);

  /// 品种类型
  @$pb.TagNumber(2)
  $core.String get commodityType => $_getSZ(1);
  @$pb.TagNumber(2)
  set commodityType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCommodityType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommodityType() => clearField(2);

  /// 品种编号
  @$pb.TagNumber(3)
  $core.String get commodityNo => $_getSZ(2);
  @$pb.TagNumber(3)
  set commodityNo($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCommodityNo() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommodityNo() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get contractNo => $_getSZ(3);
  @$pb.TagNumber(4)
  set contractNo($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasContractNo() => $_has(3);
  @$pb.TagNumber(4)
  void clearContractNo() => clearField(4);

  /// / 成交价
  @$pb.TagNumber(5)
  $core.double get lastPrice => $_getN(4);
  @$pb.TagNumber(5)
  set lastPrice($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLastPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastPrice() => clearField(5);

  /// / 涨跌
  @$pb.TagNumber(6)
  $core.double get upDown => $_getN(5);
  @$pb.TagNumber(6)
  set upDown($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUpDown() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpDown() => clearField(6);

  /// / 现手
  @$pb.TagNumber(7)
  $core.double get volume => $_getN(6);
  @$pb.TagNumber(7)
  set volume($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasVolume() => $_has(6);
  @$pb.TagNumber(7)
  void clearVolume() => clearField(7);

  /// / 开仓
  @$pb.TagNumber(8)
  $core.double get open => $_getN(7);
  @$pb.TagNumber(8)
  set open($core.double v) { $_setDouble(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasOpen() => $_has(7);
  @$pb.TagNumber(8)
  void clearOpen() => clearField(8);

  /// / 平仓
  @$pb.TagNumber(9)
  $core.double get close => $_getN(8);
  @$pb.TagNumber(9)
  set close($core.double v) { $_setDouble(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasClose() => $_has(8);
  @$pb.TagNumber(9)
  void clearClose() => clearField(9);

  /// / 性质
  @$pb.TagNumber(10)
  $core.int get tickType => $_getIZ(9);
  @$pb.TagNumber(10)
  set tickType($core.int v) { $_setUnsignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasTickType() => $_has(9);
  @$pb.TagNumber(10)
  void clearTickType() => clearField(10);

  /// / 颜色
  @$pb.TagNumber(11)
  $core.int get tickColor => $_getIZ(10);
  @$pb.TagNumber(11)
  set tickColor($core.int v) { $_setUnsignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasTickColor() => $_has(10);
  @$pb.TagNumber(11)
  void clearTickColor() => clearField(11);

  /// /最后修改时间
  @$pb.TagNumber(12)
  $core.String get updateTime => $_getSZ(11);
  @$pb.TagNumber(12)
  set updateTime($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasUpdateTime() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdateTime() => clearField(12);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
