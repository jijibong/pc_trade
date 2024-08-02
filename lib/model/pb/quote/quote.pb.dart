//
//  Generated code. Do not modify.
//  source: proto/quote/quote.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class CommodityInfo extends $pb.GeneratedMessage {
  factory CommodityInfo({
    $core.String? exchangeNo,
    $core.String? commodityType,
    $core.String? commodityNo,
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
    return $result;
  }
  CommodityInfo._() : super();
  factory CommodityInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CommodityInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommodityInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ExchangeNo', protoName: 'ExchangeNo')
    ..aOS(2, _omitFieldNames ? '' : 'CommodityType', protoName: 'CommodityType')
    ..aOS(3, _omitFieldNames ? '' : 'CommodityNo', protoName: 'CommodityNo')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CommodityInfo clone() => CommodityInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CommodityInfo copyWith(void Function(CommodityInfo) updates) => super.copyWith((message) => updates(message as CommodityInfo)) as CommodityInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommodityInfo create() => CommodityInfo._();
  CommodityInfo createEmptyInstance() => create();
  static $pb.PbList<CommodityInfo> createRepeated() => $pb.PbList<CommodityInfo>();
  @$core.pragma('dart2js:noInline')
  static CommodityInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommodityInfo>(create);
  static CommodityInfo? _defaultInstance;

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
}

class ContractInfo extends $pb.GeneratedMessage {
  factory ContractInfo({
    CommodityInfo? commodity,
    $core.String? contractNo1,
    $core.String? strikePrice1,
    $core.String? callOrPutFlag1,
    $core.String? contractNo2,
    $core.String? strikePrice2,
    $core.String? callOrPutFlag2,
  }) {
    final $result = create();
    if (commodity != null) {
      $result.commodity = commodity;
    }
    if (contractNo1 != null) {
      $result.contractNo1 = contractNo1;
    }
    if (strikePrice1 != null) {
      $result.strikePrice1 = strikePrice1;
    }
    if (callOrPutFlag1 != null) {
      $result.callOrPutFlag1 = callOrPutFlag1;
    }
    if (contractNo2 != null) {
      $result.contractNo2 = contractNo2;
    }
    if (strikePrice2 != null) {
      $result.strikePrice2 = strikePrice2;
    }
    if (callOrPutFlag2 != null) {
      $result.callOrPutFlag2 = callOrPutFlag2;
    }
    return $result;
  }
  ContractInfo._() : super();
  factory ContractInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContractInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContractInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOM<CommodityInfo>(1, _omitFieldNames ? '' : 'Commodity', protoName: 'Commodity', subBuilder: CommodityInfo.create)
    ..aOS(2, _omitFieldNames ? '' : 'ContractNo1', protoName: 'ContractNo1')
    ..aOS(3, _omitFieldNames ? '' : 'StrikePrice1', protoName: 'StrikePrice1')
    ..aOS(4, _omitFieldNames ? '' : 'CallOrPutFlag1', protoName: 'CallOrPutFlag1')
    ..aOS(5, _omitFieldNames ? '' : 'ContractNo2', protoName: 'ContractNo2')
    ..aOS(6, _omitFieldNames ? '' : 'StrikePrice2', protoName: 'StrikePrice2')
    ..aOS(7, _omitFieldNames ? '' : 'CallOrPutFlag2', protoName: 'CallOrPutFlag2')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContractInfo clone() => ContractInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContractInfo copyWith(void Function(ContractInfo) updates) => super.copyWith((message) => updates(message as ContractInfo)) as ContractInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContractInfo create() => ContractInfo._();
  ContractInfo createEmptyInstance() => create();
  static $pb.PbList<ContractInfo> createRepeated() => $pb.PbList<ContractInfo>();
  @$core.pragma('dart2js:noInline')
  static ContractInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContractInfo>(create);
  static ContractInfo? _defaultInstance;

  /// 品种
  @$pb.TagNumber(1)
  CommodityInfo get commodity => $_getN(0);
  @$pb.TagNumber(1)
  set commodity(CommodityInfo v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCommodity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommodity() => clearField(1);
  @$pb.TagNumber(1)
  CommodityInfo ensureCommodity() => $_ensure(0);

  /// 合约代码1
  @$pb.TagNumber(2)
  $core.String get contractNo1 => $_getSZ(1);
  @$pb.TagNumber(2)
  set contractNo1($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasContractNo1() => $_has(1);
  @$pb.TagNumber(2)
  void clearContractNo1() => clearField(2);

  /// 执行价1
  @$pb.TagNumber(3)
  $core.String get strikePrice1 => $_getSZ(2);
  @$pb.TagNumber(3)
  set strikePrice1($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStrikePrice1() => $_has(2);
  @$pb.TagNumber(3)
  void clearStrikePrice1() => clearField(3);

  /// 看涨看跌标示1
  @$pb.TagNumber(4)
  $core.String get callOrPutFlag1 => $_getSZ(3);
  @$pb.TagNumber(4)
  set callOrPutFlag1($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCallOrPutFlag1() => $_has(3);
  @$pb.TagNumber(4)
  void clearCallOrPutFlag1() => clearField(4);

  /// 合约代码2
  @$pb.TagNumber(5)
  $core.String get contractNo2 => $_getSZ(4);
  @$pb.TagNumber(5)
  set contractNo2($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasContractNo2() => $_has(4);
  @$pb.TagNumber(5)
  void clearContractNo2() => clearField(5);

  /// 执行价2
  @$pb.TagNumber(6)
  $core.String get strikePrice2 => $_getSZ(5);
  @$pb.TagNumber(6)
  set strikePrice2($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasStrikePrice2() => $_has(5);
  @$pb.TagNumber(6)
  void clearStrikePrice2() => clearField(6);

  /// 看涨看跌标示2
  @$pb.TagNumber(7)
  $core.String get callOrPutFlag2 => $_getSZ(6);
  @$pb.TagNumber(7)
  set callOrPutFlag2($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCallOrPutFlag2() => $_has(6);
  @$pb.TagNumber(7)
  void clearCallOrPutFlag2() => clearField(7);
}

class ApplyPrice extends $pb.GeneratedMessage {
  factory ApplyPrice({
    $core.double? price,
    $core.double? volume,
  }) {
    final $result = create();
    if (price != null) {
      $result.price = price;
    }
    if (volume != null) {
      $result.volume = volume;
    }
    return $result;
  }
  ApplyPrice._() : super();
  factory ApplyPrice.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ApplyPrice.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ApplyPrice', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'Price', $pb.PbFieldType.OD, protoName: 'Price')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'Volume', $pb.PbFieldType.OD, protoName: 'Volume')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ApplyPrice clone() => ApplyPrice()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ApplyPrice copyWith(void Function(ApplyPrice) updates) => super.copyWith((message) => updates(message as ApplyPrice)) as ApplyPrice;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplyPrice create() => ApplyPrice._();
  ApplyPrice createEmptyInstance() => create();
  static $pb.PbList<ApplyPrice> createRepeated() => $pb.PbList<ApplyPrice>();
  @$core.pragma('dart2js:noInline')
  static ApplyPrice getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApplyPrice>(create);
  static ApplyPrice? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get price => $_getN(0);
  @$pb.TagNumber(1)
  set price($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPrice() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrice() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get volume => $_getN(1);
  @$pb.TagNumber(2)
  set volume($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVolume() => $_has(1);
  @$pb.TagNumber(2)
  void clearVolume() => clearField(2);
}

/// 请求
class QuoteData extends $pb.GeneratedMessage {
  factory QuoteData({
    ContractInfo? contract,
    $core.String? currencyNo,
    $core.String? tradingState,
    $core.String? dateTimeStamp,
    $core.double? qPreClosingPrice,
    $core.double? qPreSettlePrice,
    $core.double? qPrePositionQty,
    $core.double? qOpeningPrice,
    $core.double? qLastPrice,
    $core.double? qHighPrice,
    $core.double? qLowPrice,
    $core.double? qHisHighPrice,
    $core.double? qHisLowPrice,
    $core.double? qLimitUpPrice,
    $core.double? qLimitDownPrice,
    $core.double? qTotalQty,
    $core.double? qTotalTurnover,
    $core.double? qPositionQty,
    $core.double? qAveragePrice,
    $core.double? qClosingPrice,
    $core.double? qSettlePrice,
    $core.double? qLastQty,
    $core.Iterable<ApplyPrice>? appleBuy,
    $core.Iterable<ApplyPrice>? appleSell,
    $core.double? qImpliedBidPrice,
    $core.double? qImpliedBidQty,
    $core.double? qImpliedAskPrice,
    $core.double? qImpliedAskQty,
    $core.double? qPreDelta,
    $core.double? qCurrDelta,
    $core.double? qInsideQty,
    $core.double? qOutsideQty,
    $core.double? qTurnoverRate,
    $core.double? q5DAvgQty,
    $core.double? qPERatio,
    $core.double? qTotalValue,
    $core.double? qNegotiableValue,
    $core.double? qPositionTrend,
    $core.double? qChangeSpeed,
    $core.double? qChangeRate,
    $core.double? qChangeValue,
    $core.double? qSwing,
    $core.double? qTotalBidQty,
    $core.double? qTotalAskQty,
  }) {
    final $result = create();
    if (contract != null) {
      $result.contract = contract;
    }
    if (currencyNo != null) {
      $result.currencyNo = currencyNo;
    }
    if (tradingState != null) {
      $result.tradingState = tradingState;
    }
    if (dateTimeStamp != null) {
      $result.dateTimeStamp = dateTimeStamp;
    }
    if (qPreClosingPrice != null) {
      $result.qPreClosingPrice = qPreClosingPrice;
    }
    if (qPreSettlePrice != null) {
      $result.qPreSettlePrice = qPreSettlePrice;
    }
    if (qPrePositionQty != null) {
      $result.qPrePositionQty = qPrePositionQty;
    }
    if (qOpeningPrice != null) {
      $result.qOpeningPrice = qOpeningPrice;
    }
    if (qLastPrice != null) {
      $result.qLastPrice = qLastPrice;
    }
    if (qHighPrice != null) {
      $result.qHighPrice = qHighPrice;
    }
    if (qLowPrice != null) {
      $result.qLowPrice = qLowPrice;
    }
    if (qHisHighPrice != null) {
      $result.qHisHighPrice = qHisHighPrice;
    }
    if (qHisLowPrice != null) {
      $result.qHisLowPrice = qHisLowPrice;
    }
    if (qLimitUpPrice != null) {
      $result.qLimitUpPrice = qLimitUpPrice;
    }
    if (qLimitDownPrice != null) {
      $result.qLimitDownPrice = qLimitDownPrice;
    }
    if (qTotalQty != null) {
      $result.qTotalQty = qTotalQty;
    }
    if (qTotalTurnover != null) {
      $result.qTotalTurnover = qTotalTurnover;
    }
    if (qPositionQty != null) {
      $result.qPositionQty = qPositionQty;
    }
    if (qAveragePrice != null) {
      $result.qAveragePrice = qAveragePrice;
    }
    if (qClosingPrice != null) {
      $result.qClosingPrice = qClosingPrice;
    }
    if (qSettlePrice != null) {
      $result.qSettlePrice = qSettlePrice;
    }
    if (qLastQty != null) {
      $result.qLastQty = qLastQty;
    }
    if (appleBuy != null) {
      $result.appleBuy.addAll(appleBuy);
    }
    if (appleSell != null) {
      $result.appleSell.addAll(appleSell);
    }
    if (qImpliedBidPrice != null) {
      $result.qImpliedBidPrice = qImpliedBidPrice;
    }
    if (qImpliedBidQty != null) {
      $result.qImpliedBidQty = qImpliedBidQty;
    }
    if (qImpliedAskPrice != null) {
      $result.qImpliedAskPrice = qImpliedAskPrice;
    }
    if (qImpliedAskQty != null) {
      $result.qImpliedAskQty = qImpliedAskQty;
    }
    if (qPreDelta != null) {
      $result.qPreDelta = qPreDelta;
    }
    if (qCurrDelta != null) {
      $result.qCurrDelta = qCurrDelta;
    }
    if (qInsideQty != null) {
      $result.qInsideQty = qInsideQty;
    }
    if (qOutsideQty != null) {
      $result.qOutsideQty = qOutsideQty;
    }
    if (qTurnoverRate != null) {
      $result.qTurnoverRate = qTurnoverRate;
    }
    if (q5DAvgQty != null) {
      $result.q5DAvgQty = q5DAvgQty;
    }
    if (qPERatio != null) {
      $result.qPERatio = qPERatio;
    }
    if (qTotalValue != null) {
      $result.qTotalValue = qTotalValue;
    }
    if (qNegotiableValue != null) {
      $result.qNegotiableValue = qNegotiableValue;
    }
    if (qPositionTrend != null) {
      $result.qPositionTrend = qPositionTrend;
    }
    if (qChangeSpeed != null) {
      $result.qChangeSpeed = qChangeSpeed;
    }
    if (qChangeRate != null) {
      $result.qChangeRate = qChangeRate;
    }
    if (qChangeValue != null) {
      $result.qChangeValue = qChangeValue;
    }
    if (qSwing != null) {
      $result.qSwing = qSwing;
    }
    if (qTotalBidQty != null) {
      $result.qTotalBidQty = qTotalBidQty;
    }
    if (qTotalAskQty != null) {
      $result.qTotalAskQty = qTotalAskQty;
    }
    return $result;
  }
  QuoteData._() : super();
  factory QuoteData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QuoteData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'QuoteData', package: const $pb.PackageName(_omitMessageNames ? '' : 'cmd'), createEmptyInstance: create)
    ..aOM<ContractInfo>(1, _omitFieldNames ? '' : 'Contract', protoName: 'Contract', subBuilder: ContractInfo.create)
    ..aOS(2, _omitFieldNames ? '' : 'CurrencyNo', protoName: 'CurrencyNo')
    ..aOS(3, _omitFieldNames ? '' : 'TradingState', protoName: 'TradingState')
    ..aOS(4, _omitFieldNames ? '' : 'DateTimeStamp', protoName: 'DateTimeStamp')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'QPreClosingPrice', $pb.PbFieldType.OD, protoName: 'QPreClosingPrice')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'QPreSettlePrice', $pb.PbFieldType.OD, protoName: 'QPreSettlePrice')
    ..a<$core.double>(7, _omitFieldNames ? '' : 'QPrePositionQty', $pb.PbFieldType.OD, protoName: 'QPrePositionQty')
    ..a<$core.double>(8, _omitFieldNames ? '' : 'QOpeningPrice', $pb.PbFieldType.OD, protoName: 'QOpeningPrice')
    ..a<$core.double>(9, _omitFieldNames ? '' : 'QLastPrice', $pb.PbFieldType.OD, protoName: 'QLastPrice')
    ..a<$core.double>(10, _omitFieldNames ? '' : 'QHighPrice', $pb.PbFieldType.OD, protoName: 'QHighPrice')
    ..a<$core.double>(11, _omitFieldNames ? '' : 'QLowPrice', $pb.PbFieldType.OD, protoName: 'QLowPrice')
    ..a<$core.double>(12, _omitFieldNames ? '' : 'QHisHighPrice', $pb.PbFieldType.OD, protoName: 'QHisHighPrice')
    ..a<$core.double>(13, _omitFieldNames ? '' : 'QHisLowPrice', $pb.PbFieldType.OD, protoName: 'QHisLowPrice')
    ..a<$core.double>(14, _omitFieldNames ? '' : 'QLimitUpPrice', $pb.PbFieldType.OD, protoName: 'QLimitUpPrice')
    ..a<$core.double>(15, _omitFieldNames ? '' : 'QLimitDownPrice', $pb.PbFieldType.OD, protoName: 'QLimitDownPrice')
    ..a<$core.double>(16, _omitFieldNames ? '' : 'QTotalQty', $pb.PbFieldType.OD, protoName: 'QTotalQty')
    ..a<$core.double>(17, _omitFieldNames ? '' : 'QTotalTurnover', $pb.PbFieldType.OD, protoName: 'QTotalTurnover')
    ..a<$core.double>(18, _omitFieldNames ? '' : 'QPositionQty', $pb.PbFieldType.OD, protoName: 'QPositionQty')
    ..a<$core.double>(19, _omitFieldNames ? '' : 'QAveragePrice', $pb.PbFieldType.OD, protoName: 'QAveragePrice')
    ..a<$core.double>(20, _omitFieldNames ? '' : 'QClosingPrice', $pb.PbFieldType.OD, protoName: 'QClosingPrice')
    ..a<$core.double>(21, _omitFieldNames ? '' : 'QSettlePrice', $pb.PbFieldType.OD, protoName: 'QSettlePrice')
    ..a<$core.double>(22, _omitFieldNames ? '' : 'QLastQty', $pb.PbFieldType.OD, protoName: 'QLastQty')
    ..pc<ApplyPrice>(23, _omitFieldNames ? '' : 'AppleBuy', $pb.PbFieldType.PM, protoName: 'AppleBuy', subBuilder: ApplyPrice.create)
    ..pc<ApplyPrice>(24, _omitFieldNames ? '' : 'AppleSell', $pb.PbFieldType.PM, protoName: 'AppleSell', subBuilder: ApplyPrice.create)
    ..a<$core.double>(25, _omitFieldNames ? '' : 'QImpliedBidPrice', $pb.PbFieldType.OD, protoName: 'QImpliedBidPrice')
    ..a<$core.double>(26, _omitFieldNames ? '' : 'QImpliedBidQty', $pb.PbFieldType.OD, protoName: 'QImpliedBidQty')
    ..a<$core.double>(27, _omitFieldNames ? '' : 'QImpliedAskPrice', $pb.PbFieldType.OD, protoName: 'QImpliedAskPrice')
    ..a<$core.double>(28, _omitFieldNames ? '' : 'QImpliedAskQty', $pb.PbFieldType.OD, protoName: 'QImpliedAskQty')
    ..a<$core.double>(29, _omitFieldNames ? '' : 'QPreDelta', $pb.PbFieldType.OD, protoName: 'QPreDelta')
    ..a<$core.double>(30, _omitFieldNames ? '' : 'QCurrDelta', $pb.PbFieldType.OD, protoName: 'QCurrDelta')
    ..a<$core.double>(31, _omitFieldNames ? '' : 'QInsideQty', $pb.PbFieldType.OD, protoName: 'QInsideQty')
    ..a<$core.double>(32, _omitFieldNames ? '' : 'QOutsideQty', $pb.PbFieldType.OD, protoName: 'QOutsideQty')
    ..a<$core.double>(33, _omitFieldNames ? '' : 'QTurnoverRate', $pb.PbFieldType.OD, protoName: 'QTurnoverRate')
    ..a<$core.double>(34, _omitFieldNames ? '' : 'Q5DAvgQty', $pb.PbFieldType.OD, protoName: 'Q5DAvgQty')
    ..a<$core.double>(35, _omitFieldNames ? '' : 'QPERatio', $pb.PbFieldType.OD, protoName: 'QPERatio')
    ..a<$core.double>(36, _omitFieldNames ? '' : 'QTotalValue', $pb.PbFieldType.OD, protoName: 'QTotalValue')
    ..a<$core.double>(37, _omitFieldNames ? '' : 'QNegotiableValue', $pb.PbFieldType.OD, protoName: 'QNegotiableValue')
    ..a<$core.double>(38, _omitFieldNames ? '' : 'QPositionTrend', $pb.PbFieldType.OD, protoName: 'QPositionTrend')
    ..a<$core.double>(39, _omitFieldNames ? '' : 'QChangeSpeed', $pb.PbFieldType.OD, protoName: 'QChangeSpeed')
    ..a<$core.double>(40, _omitFieldNames ? '' : 'QChangeRate', $pb.PbFieldType.OD, protoName: 'QChangeRate')
    ..a<$core.double>(41, _omitFieldNames ? '' : 'QChangeValue', $pb.PbFieldType.OD, protoName: 'QChangeValue')
    ..a<$core.double>(42, _omitFieldNames ? '' : 'QSwing', $pb.PbFieldType.OD, protoName: 'QSwing')
    ..a<$core.double>(43, _omitFieldNames ? '' : 'QTotalBidQty', $pb.PbFieldType.OD, protoName: 'QTotalBidQty')
    ..a<$core.double>(44, _omitFieldNames ? '' : 'QTotalAskQty', $pb.PbFieldType.OD, protoName: 'QTotalAskQty')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QuoteData clone() => QuoteData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QuoteData copyWith(void Function(QuoteData) updates) => super.copyWith((message) => updates(message as QuoteData)) as QuoteData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuoteData create() => QuoteData._();
  QuoteData createEmptyInstance() => create();
  static $pb.PbList<QuoteData> createRepeated() => $pb.PbList<QuoteData>();
  @$core.pragma('dart2js:noInline')
  static QuoteData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuoteData>(create);
  static QuoteData? _defaultInstance;

  /// 合约
  @$pb.TagNumber(1)
  ContractInfo get contract => $_getN(0);
  @$pb.TagNumber(1)
  set contract(ContractInfo v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContract() => $_has(0);
  @$pb.TagNumber(1)
  void clearContract() => clearField(1);
  @$pb.TagNumber(1)
  ContractInfo ensureContract() => $_ensure(0);

  /// 币种编号
  @$pb.TagNumber(2)
  $core.String get currencyNo => $_getSZ(1);
  @$pb.TagNumber(2)
  set currencyNo($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCurrencyNo() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrencyNo() => clearField(2);

  /// 交易状态。1,集合竞价;2,集合竞价撮合;3,连续交易;4,交易暂停;5,闭市
  @$pb.TagNumber(3)
  $core.String get tradingState => $_getSZ(2);
  @$pb.TagNumber(3)
  set tradingState($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTradingState() => $_has(2);
  @$pb.TagNumber(3)
  void clearTradingState() => clearField(3);

  /// 时间戳
  @$pb.TagNumber(4)
  $core.String get dateTimeStamp => $_getSZ(3);
  @$pb.TagNumber(4)
  set dateTimeStamp($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDateTimeStamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearDateTimeStamp() => clearField(4);

  /// 昨收盘价
  @$pb.TagNumber(5)
  $core.double get qPreClosingPrice => $_getN(4);
  @$pb.TagNumber(5)
  set qPreClosingPrice($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasQPreClosingPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearQPreClosingPrice() => clearField(5);

  /// 昨结算价
  @$pb.TagNumber(6)
  $core.double get qPreSettlePrice => $_getN(5);
  @$pb.TagNumber(6)
  set qPreSettlePrice($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasQPreSettlePrice() => $_has(5);
  @$pb.TagNumber(6)
  void clearQPreSettlePrice() => clearField(6);

  /// 昨持仓量
  @$pb.TagNumber(7)
  $core.double get qPrePositionQty => $_getN(6);
  @$pb.TagNumber(7)
  set qPrePositionQty($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasQPrePositionQty() => $_has(6);
  @$pb.TagNumber(7)
  void clearQPrePositionQty() => clearField(7);

  /// 开盘价
  @$pb.TagNumber(8)
  $core.double get qOpeningPrice => $_getN(7);
  @$pb.TagNumber(8)
  set qOpeningPrice($core.double v) { $_setDouble(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasQOpeningPrice() => $_has(7);
  @$pb.TagNumber(8)
  void clearQOpeningPrice() => clearField(8);

  /// 最新价
  @$pb.TagNumber(9)
  $core.double get qLastPrice => $_getN(8);
  @$pb.TagNumber(9)
  set qLastPrice($core.double v) { $_setDouble(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasQLastPrice() => $_has(8);
  @$pb.TagNumber(9)
  void clearQLastPrice() => clearField(9);

  /// 最高价
  @$pb.TagNumber(10)
  $core.double get qHighPrice => $_getN(9);
  @$pb.TagNumber(10)
  set qHighPrice($core.double v) { $_setDouble(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasQHighPrice() => $_has(9);
  @$pb.TagNumber(10)
  void clearQHighPrice() => clearField(10);

  /// 最低价
  @$pb.TagNumber(11)
  $core.double get qLowPrice => $_getN(10);
  @$pb.TagNumber(11)
  set qLowPrice($core.double v) { $_setDouble(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasQLowPrice() => $_has(10);
  @$pb.TagNumber(11)
  void clearQLowPrice() => clearField(11);

  /// 历史最高价
  @$pb.TagNumber(12)
  $core.double get qHisHighPrice => $_getN(11);
  @$pb.TagNumber(12)
  set qHisHighPrice($core.double v) { $_setDouble(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasQHisHighPrice() => $_has(11);
  @$pb.TagNumber(12)
  void clearQHisHighPrice() => clearField(12);

  /// 历史最低价
  @$pb.TagNumber(13)
  $core.double get qHisLowPrice => $_getN(12);
  @$pb.TagNumber(13)
  set qHisLowPrice($core.double v) { $_setDouble(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasQHisLowPrice() => $_has(12);
  @$pb.TagNumber(13)
  void clearQHisLowPrice() => clearField(13);

  /// 涨停价
  @$pb.TagNumber(14)
  $core.double get qLimitUpPrice => $_getN(13);
  @$pb.TagNumber(14)
  set qLimitUpPrice($core.double v) { $_setDouble(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasQLimitUpPrice() => $_has(13);
  @$pb.TagNumber(14)
  void clearQLimitUpPrice() => clearField(14);

  /// 跌停价
  @$pb.TagNumber(15)
  $core.double get qLimitDownPrice => $_getN(14);
  @$pb.TagNumber(15)
  set qLimitDownPrice($core.double v) { $_setDouble(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasQLimitDownPrice() => $_has(14);
  @$pb.TagNumber(15)
  void clearQLimitDownPrice() => clearField(15);

  /// 当日总成交量
  @$pb.TagNumber(16)
  $core.double get qTotalQty => $_getN(15);
  @$pb.TagNumber(16)
  set qTotalQty($core.double v) { $_setDouble(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasQTotalQty() => $_has(15);
  @$pb.TagNumber(16)
  void clearQTotalQty() => clearField(16);

  /// 当日成交金额
  @$pb.TagNumber(17)
  $core.double get qTotalTurnover => $_getN(16);
  @$pb.TagNumber(17)
  set qTotalTurnover($core.double v) { $_setDouble(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasQTotalTurnover() => $_has(16);
  @$pb.TagNumber(17)
  void clearQTotalTurnover() => clearField(17);

  /// 持仓量
  @$pb.TagNumber(18)
  $core.double get qPositionQty => $_getN(17);
  @$pb.TagNumber(18)
  set qPositionQty($core.double v) { $_setDouble(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasQPositionQty() => $_has(17);
  @$pb.TagNumber(18)
  void clearQPositionQty() => clearField(18);

  /// 均价
  @$pb.TagNumber(19)
  $core.double get qAveragePrice => $_getN(18);
  @$pb.TagNumber(19)
  set qAveragePrice($core.double v) { $_setDouble(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasQAveragePrice() => $_has(18);
  @$pb.TagNumber(19)
  void clearQAveragePrice() => clearField(19);

  /// 收盘价
  @$pb.TagNumber(20)
  $core.double get qClosingPrice => $_getN(19);
  @$pb.TagNumber(20)
  set qClosingPrice($core.double v) { $_setDouble(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasQClosingPrice() => $_has(19);
  @$pb.TagNumber(20)
  void clearQClosingPrice() => clearField(20);

  /// 结算价
  @$pb.TagNumber(21)
  $core.double get qSettlePrice => $_getN(20);
  @$pb.TagNumber(21)
  set qSettlePrice($core.double v) { $_setDouble(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasQSettlePrice() => $_has(20);
  @$pb.TagNumber(21)
  void clearQSettlePrice() => clearField(21);

  /// 最新成交量
  @$pb.TagNumber(22)
  $core.double get qLastQty => $_getN(21);
  @$pb.TagNumber(22)
  set qLastQty($core.double v) { $_setDouble(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasQLastQty() => $_has(21);
  @$pb.TagNumber(22)
  void clearQLastQty() => clearField(22);

  /// 申报买20
  @$pb.TagNumber(23)
  $core.List<ApplyPrice> get appleBuy => $_getList(22);

  /// 申报卖20
  @$pb.TagNumber(24)
  $core.List<ApplyPrice> get appleSell => $_getList(23);

  /// 隐含买价
  @$pb.TagNumber(25)
  $core.double get qImpliedBidPrice => $_getN(24);
  @$pb.TagNumber(25)
  set qImpliedBidPrice($core.double v) { $_setDouble(24, v); }
  @$pb.TagNumber(25)
  $core.bool hasQImpliedBidPrice() => $_has(24);
  @$pb.TagNumber(25)
  void clearQImpliedBidPrice() => clearField(25);

  /// 隐含买量
  @$pb.TagNumber(26)
  $core.double get qImpliedBidQty => $_getN(25);
  @$pb.TagNumber(26)
  set qImpliedBidQty($core.double v) { $_setDouble(25, v); }
  @$pb.TagNumber(26)
  $core.bool hasQImpliedBidQty() => $_has(25);
  @$pb.TagNumber(26)
  void clearQImpliedBidQty() => clearField(26);

  /// 隐含卖价
  @$pb.TagNumber(27)
  $core.double get qImpliedAskPrice => $_getN(26);
  @$pb.TagNumber(27)
  set qImpliedAskPrice($core.double v) { $_setDouble(26, v); }
  @$pb.TagNumber(27)
  $core.bool hasQImpliedAskPrice() => $_has(26);
  @$pb.TagNumber(27)
  void clearQImpliedAskPrice() => clearField(27);

  /// 隐含卖量
  @$pb.TagNumber(28)
  $core.double get qImpliedAskQty => $_getN(27);
  @$pb.TagNumber(28)
  set qImpliedAskQty($core.double v) { $_setDouble(27, v); }
  @$pb.TagNumber(28)
  $core.bool hasQImpliedAskQty() => $_has(27);
  @$pb.TagNumber(28)
  void clearQImpliedAskQty() => clearField(28);

  /// 昨虚实度
  @$pb.TagNumber(29)
  $core.double get qPreDelta => $_getN(28);
  @$pb.TagNumber(29)
  set qPreDelta($core.double v) { $_setDouble(28, v); }
  @$pb.TagNumber(29)
  $core.bool hasQPreDelta() => $_has(28);
  @$pb.TagNumber(29)
  void clearQPreDelta() => clearField(29);

  /// 今虚实度
  @$pb.TagNumber(30)
  $core.double get qCurrDelta => $_getN(29);
  @$pb.TagNumber(30)
  set qCurrDelta($core.double v) { $_setDouble(29, v); }
  @$pb.TagNumber(30)
  $core.bool hasQCurrDelta() => $_has(29);
  @$pb.TagNumber(30)
  void clearQCurrDelta() => clearField(30);

  /// 内盘量
  @$pb.TagNumber(31)
  $core.double get qInsideQty => $_getN(30);
  @$pb.TagNumber(31)
  set qInsideQty($core.double v) { $_setDouble(30, v); }
  @$pb.TagNumber(31)
  $core.bool hasQInsideQty() => $_has(30);
  @$pb.TagNumber(31)
  void clearQInsideQty() => clearField(31);

  /// 外盘量
  @$pb.TagNumber(32)
  $core.double get qOutsideQty => $_getN(31);
  @$pb.TagNumber(32)
  set qOutsideQty($core.double v) { $_setDouble(31, v); }
  @$pb.TagNumber(32)
  $core.bool hasQOutsideQty() => $_has(31);
  @$pb.TagNumber(32)
  void clearQOutsideQty() => clearField(32);

  /// 换手率
  @$pb.TagNumber(33)
  $core.double get qTurnoverRate => $_getN(32);
  @$pb.TagNumber(33)
  set qTurnoverRate($core.double v) { $_setDouble(32, v); }
  @$pb.TagNumber(33)
  $core.bool hasQTurnoverRate() => $_has(32);
  @$pb.TagNumber(33)
  void clearQTurnoverRate() => clearField(33);

  /// 五日均量
  @$pb.TagNumber(34)
  $core.double get q5DAvgQty => $_getN(33);
  @$pb.TagNumber(34)
  set q5DAvgQty($core.double v) { $_setDouble(33, v); }
  @$pb.TagNumber(34)
  $core.bool hasQ5DAvgQty() => $_has(33);
  @$pb.TagNumber(34)
  void clearQ5DAvgQty() => clearField(34);

  /// 市盈率
  @$pb.TagNumber(35)
  $core.double get qPERatio => $_getN(34);
  @$pb.TagNumber(35)
  set qPERatio($core.double v) { $_setDouble(34, v); }
  @$pb.TagNumber(35)
  $core.bool hasQPERatio() => $_has(34);
  @$pb.TagNumber(35)
  void clearQPERatio() => clearField(35);

  /// 总市值
  @$pb.TagNumber(36)
  $core.double get qTotalValue => $_getN(35);
  @$pb.TagNumber(36)
  set qTotalValue($core.double v) { $_setDouble(35, v); }
  @$pb.TagNumber(36)
  $core.bool hasQTotalValue() => $_has(35);
  @$pb.TagNumber(36)
  void clearQTotalValue() => clearField(36);

  /// 流通市值
  @$pb.TagNumber(37)
  $core.double get qNegotiableValue => $_getN(36);
  @$pb.TagNumber(37)
  set qNegotiableValue($core.double v) { $_setDouble(36, v); }
  @$pb.TagNumber(37)
  $core.bool hasQNegotiableValue() => $_has(36);
  @$pb.TagNumber(37)
  void clearQNegotiableValue() => clearField(37);

  /// 持仓走势
  @$pb.TagNumber(38)
  $core.double get qPositionTrend => $_getN(37);
  @$pb.TagNumber(38)
  set qPositionTrend($core.double v) { $_setDouble(37, v); }
  @$pb.TagNumber(38)
  $core.bool hasQPositionTrend() => $_has(37);
  @$pb.TagNumber(38)
  void clearQPositionTrend() => clearField(38);

  /// 涨速
  @$pb.TagNumber(39)
  $core.double get qChangeSpeed => $_getN(38);
  @$pb.TagNumber(39)
  set qChangeSpeed($core.double v) { $_setDouble(38, v); }
  @$pb.TagNumber(39)
  $core.bool hasQChangeSpeed() => $_has(38);
  @$pb.TagNumber(39)
  void clearQChangeSpeed() => clearField(39);

  /// 涨幅
  @$pb.TagNumber(40)
  $core.double get qChangeRate => $_getN(39);
  @$pb.TagNumber(40)
  set qChangeRate($core.double v) { $_setDouble(39, v); }
  @$pb.TagNumber(40)
  $core.bool hasQChangeRate() => $_has(39);
  @$pb.TagNumber(40)
  void clearQChangeRate() => clearField(40);

  /// 涨跌值
  @$pb.TagNumber(41)
  $core.double get qChangeValue => $_getN(40);
  @$pb.TagNumber(41)
  set qChangeValue($core.double v) { $_setDouble(40, v); }
  @$pb.TagNumber(41)
  $core.bool hasQChangeValue() => $_has(40);
  @$pb.TagNumber(41)
  void clearQChangeValue() => clearField(41);

  /// 振幅
  @$pb.TagNumber(42)
  $core.double get qSwing => $_getN(41);
  @$pb.TagNumber(42)
  set qSwing($core.double v) { $_setDouble(41, v); }
  @$pb.TagNumber(42)
  $core.bool hasQSwing() => $_has(41);
  @$pb.TagNumber(42)
  void clearQSwing() => clearField(42);

  /// 委买总量
  @$pb.TagNumber(43)
  $core.double get qTotalBidQty => $_getN(42);
  @$pb.TagNumber(43)
  set qTotalBidQty($core.double v) { $_setDouble(42, v); }
  @$pb.TagNumber(43)
  $core.bool hasQTotalBidQty() => $_has(42);
  @$pb.TagNumber(43)
  void clearQTotalBidQty() => clearField(43);

  /// 委卖总量
  @$pb.TagNumber(44)
  $core.double get qTotalAskQty => $_getN(43);
  @$pb.TagNumber(44)
  set qTotalAskQty($core.double v) { $_setDouble(43, v); }
  @$pb.TagNumber(44)
  $core.bool hasQTotalAskQty() => $_has(43);
  @$pb.TagNumber(44)
  void clearQTotalAskQty() => clearField(44);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
