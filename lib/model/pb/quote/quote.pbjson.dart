//
//  Generated code. Do not modify.
//  source: proto/quote/quote.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use commodityInfoDescriptor instead')
const CommodityInfo$json = {
  '1': 'CommodityInfo',
  '2': [
    {'1': 'ExchangeNo', '3': 1, '4': 1, '5': 9, '10': 'ExchangeNo'},
    {'1': 'CommodityType', '3': 2, '4': 1, '5': 9, '10': 'CommodityType'},
    {'1': 'CommodityNo', '3': 3, '4': 1, '5': 9, '10': 'CommodityNo'},
  ],
};

/// Descriptor for `CommodityInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commodityInfoDescriptor = $convert.base64Decode(
    'Cg1Db21tb2RpdHlJbmZvEh4KCkV4Y2hhbmdlTm8YASABKAlSCkV4Y2hhbmdlTm8SJAoNQ29tbW'
    '9kaXR5VHlwZRgCIAEoCVINQ29tbW9kaXR5VHlwZRIgCgtDb21tb2RpdHlObxgDIAEoCVILQ29t'
    'bW9kaXR5Tm8=');

@$core.Deprecated('Use contractInfoDescriptor instead')
const ContractInfo$json = {
  '1': 'ContractInfo',
  '2': [
    {'1': 'Commodity', '3': 1, '4': 1, '5': 11, '6': '.cmd.CommodityInfo', '10': 'Commodity'},
    {'1': 'ContractNo1', '3': 2, '4': 1, '5': 9, '10': 'ContractNo1'},
    {'1': 'StrikePrice1', '3': 3, '4': 1, '5': 9, '10': 'StrikePrice1'},
    {'1': 'CallOrPutFlag1', '3': 4, '4': 1, '5': 9, '10': 'CallOrPutFlag1'},
    {'1': 'ContractNo2', '3': 5, '4': 1, '5': 9, '10': 'ContractNo2'},
    {'1': 'StrikePrice2', '3': 6, '4': 1, '5': 9, '10': 'StrikePrice2'},
    {'1': 'CallOrPutFlag2', '3': 7, '4': 1, '5': 9, '10': 'CallOrPutFlag2'},
  ],
};

/// Descriptor for `ContractInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contractInfoDescriptor = $convert.base64Decode(
    'CgxDb250cmFjdEluZm8SMAoJQ29tbW9kaXR5GAEgASgLMhIuY21kLkNvbW1vZGl0eUluZm9SCU'
    'NvbW1vZGl0eRIgCgtDb250cmFjdE5vMRgCIAEoCVILQ29udHJhY3RObzESIgoMU3RyaWtlUHJp'
    'Y2UxGAMgASgJUgxTdHJpa2VQcmljZTESJgoOQ2FsbE9yUHV0RmxhZzEYBCABKAlSDkNhbGxPcl'
    'B1dEZsYWcxEiAKC0NvbnRyYWN0Tm8yGAUgASgJUgtDb250cmFjdE5vMhIiCgxTdHJpa2VQcmlj'
    'ZTIYBiABKAlSDFN0cmlrZVByaWNlMhImCg5DYWxsT3JQdXRGbGFnMhgHIAEoCVIOQ2FsbE9yUH'
    'V0RmxhZzI=');

@$core.Deprecated('Use applyPriceDescriptor instead')
const ApplyPrice$json = {
  '1': 'ApplyPrice',
  '2': [
    {'1': 'Price', '3': 1, '4': 1, '5': 1, '10': 'Price'},
    {'1': 'Volume', '3': 2, '4': 1, '5': 1, '10': 'Volume'},
  ],
};

/// Descriptor for `ApplyPrice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyPriceDescriptor = $convert.base64Decode(
    'CgpBcHBseVByaWNlEhQKBVByaWNlGAEgASgBUgVQcmljZRIWCgZWb2x1bWUYAiABKAFSBlZvbH'
    'VtZQ==');

@$core.Deprecated('Use quoteDataDescriptor instead')
const QuoteData$json = {
  '1': 'QuoteData',
  '2': [
    {'1': 'Contract', '3': 1, '4': 1, '5': 11, '6': '.cmd.ContractInfo', '10': 'Contract'},
    {'1': 'CurrencyNo', '3': 2, '4': 1, '5': 9, '10': 'CurrencyNo'},
    {'1': 'TradingState', '3': 3, '4': 1, '5': 9, '10': 'TradingState'},
    {'1': 'DateTimeStamp', '3': 4, '4': 1, '5': 9, '10': 'DateTimeStamp'},
    {'1': 'QPreClosingPrice', '3': 5, '4': 1, '5': 1, '10': 'QPreClosingPrice'},
    {'1': 'QPreSettlePrice', '3': 6, '4': 1, '5': 1, '10': 'QPreSettlePrice'},
    {'1': 'QPrePositionQty', '3': 7, '4': 1, '5': 1, '10': 'QPrePositionQty'},
    {'1': 'QOpeningPrice', '3': 8, '4': 1, '5': 1, '10': 'QOpeningPrice'},
    {'1': 'QLastPrice', '3': 9, '4': 1, '5': 1, '10': 'QLastPrice'},
    {'1': 'QHighPrice', '3': 10, '4': 1, '5': 1, '10': 'QHighPrice'},
    {'1': 'QLowPrice', '3': 11, '4': 1, '5': 1, '10': 'QLowPrice'},
    {'1': 'QHisHighPrice', '3': 12, '4': 1, '5': 1, '10': 'QHisHighPrice'},
    {'1': 'QHisLowPrice', '3': 13, '4': 1, '5': 1, '10': 'QHisLowPrice'},
    {'1': 'QLimitUpPrice', '3': 14, '4': 1, '5': 1, '10': 'QLimitUpPrice'},
    {'1': 'QLimitDownPrice', '3': 15, '4': 1, '5': 1, '10': 'QLimitDownPrice'},
    {'1': 'QTotalQty', '3': 16, '4': 1, '5': 1, '10': 'QTotalQty'},
    {'1': 'QTotalTurnover', '3': 17, '4': 1, '5': 1, '10': 'QTotalTurnover'},
    {'1': 'QPositionQty', '3': 18, '4': 1, '5': 1, '10': 'QPositionQty'},
    {'1': 'QAveragePrice', '3': 19, '4': 1, '5': 1, '10': 'QAveragePrice'},
    {'1': 'QClosingPrice', '3': 20, '4': 1, '5': 1, '10': 'QClosingPrice'},
    {'1': 'QSettlePrice', '3': 21, '4': 1, '5': 1, '10': 'QSettlePrice'},
    {'1': 'QLastQty', '3': 22, '4': 1, '5': 1, '10': 'QLastQty'},
    {'1': 'AppleBuy', '3': 23, '4': 3, '5': 11, '6': '.cmd.ApplyPrice', '10': 'AppleBuy'},
    {'1': 'AppleSell', '3': 24, '4': 3, '5': 11, '6': '.cmd.ApplyPrice', '10': 'AppleSell'},
    {'1': 'QImpliedBidPrice', '3': 25, '4': 1, '5': 1, '10': 'QImpliedBidPrice'},
    {'1': 'QImpliedBidQty', '3': 26, '4': 1, '5': 1, '10': 'QImpliedBidQty'},
    {'1': 'QImpliedAskPrice', '3': 27, '4': 1, '5': 1, '10': 'QImpliedAskPrice'},
    {'1': 'QImpliedAskQty', '3': 28, '4': 1, '5': 1, '10': 'QImpliedAskQty'},
    {'1': 'QPreDelta', '3': 29, '4': 1, '5': 1, '10': 'QPreDelta'},
    {'1': 'QCurrDelta', '3': 30, '4': 1, '5': 1, '10': 'QCurrDelta'},
    {'1': 'QInsideQty', '3': 31, '4': 1, '5': 1, '10': 'QInsideQty'},
    {'1': 'QOutsideQty', '3': 32, '4': 1, '5': 1, '10': 'QOutsideQty'},
    {'1': 'QTurnoverRate', '3': 33, '4': 1, '5': 1, '10': 'QTurnoverRate'},
    {'1': 'Q5DAvgQty', '3': 34, '4': 1, '5': 1, '10': 'Q5DAvgQty'},
    {'1': 'QPERatio', '3': 35, '4': 1, '5': 1, '10': 'QPERatio'},
    {'1': 'QTotalValue', '3': 36, '4': 1, '5': 1, '10': 'QTotalValue'},
    {'1': 'QNegotiableValue', '3': 37, '4': 1, '5': 1, '10': 'QNegotiableValue'},
    {'1': 'QPositionTrend', '3': 38, '4': 1, '5': 1, '10': 'QPositionTrend'},
    {'1': 'QChangeSpeed', '3': 39, '4': 1, '5': 1, '10': 'QChangeSpeed'},
    {'1': 'QChangeRate', '3': 40, '4': 1, '5': 1, '10': 'QChangeRate'},
    {'1': 'QChangeValue', '3': 41, '4': 1, '5': 1, '10': 'QChangeValue'},
    {'1': 'QSwing', '3': 42, '4': 1, '5': 1, '10': 'QSwing'},
    {'1': 'QTotalBidQty', '3': 43, '4': 1, '5': 1, '10': 'QTotalBidQty'},
    {'1': 'QTotalAskQty', '3': 44, '4': 1, '5': 1, '10': 'QTotalAskQty'},
  ],
};

/// Descriptor for `QuoteData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quoteDataDescriptor = $convert.base64Decode(
    'CglRdW90ZURhdGESLQoIQ29udHJhY3QYASABKAsyES5jbWQuQ29udHJhY3RJbmZvUghDb250cm'
    'FjdBIeCgpDdXJyZW5jeU5vGAIgASgJUgpDdXJyZW5jeU5vEiIKDFRyYWRpbmdTdGF0ZRgDIAEo'
    'CVIMVHJhZGluZ1N0YXRlEiQKDURhdGVUaW1lU3RhbXAYBCABKAlSDURhdGVUaW1lU3RhbXASKg'
    'oQUVByZUNsb3NpbmdQcmljZRgFIAEoAVIQUVByZUNsb3NpbmdQcmljZRIoCg9RUHJlU2V0dGxl'
    'UHJpY2UYBiABKAFSD1FQcmVTZXR0bGVQcmljZRIoCg9RUHJlUG9zaXRpb25RdHkYByABKAFSD1'
    'FQcmVQb3NpdGlvblF0eRIkCg1RT3BlbmluZ1ByaWNlGAggASgBUg1RT3BlbmluZ1ByaWNlEh4K'
    'ClFMYXN0UHJpY2UYCSABKAFSClFMYXN0UHJpY2USHgoKUUhpZ2hQcmljZRgKIAEoAVIKUUhpZ2'
    'hQcmljZRIcCglRTG93UHJpY2UYCyABKAFSCVFMb3dQcmljZRIkCg1RSGlzSGlnaFByaWNlGAwg'
    'ASgBUg1RSGlzSGlnaFByaWNlEiIKDFFIaXNMb3dQcmljZRgNIAEoAVIMUUhpc0xvd1ByaWNlEi'
    'QKDVFMaW1pdFVwUHJpY2UYDiABKAFSDVFMaW1pdFVwUHJpY2USKAoPUUxpbWl0RG93blByaWNl'
    'GA8gASgBUg9RTGltaXREb3duUHJpY2USHAoJUVRvdGFsUXR5GBAgASgBUglRVG90YWxRdHkSJg'
    'oOUVRvdGFsVHVybm92ZXIYESABKAFSDlFUb3RhbFR1cm5vdmVyEiIKDFFQb3NpdGlvblF0eRgS'
    'IAEoAVIMUVBvc2l0aW9uUXR5EiQKDVFBdmVyYWdlUHJpY2UYEyABKAFSDVFBdmVyYWdlUHJpY2'
    'USJAoNUUNsb3NpbmdQcmljZRgUIAEoAVINUUNsb3NpbmdQcmljZRIiCgxRU2V0dGxlUHJpY2UY'
    'FSABKAFSDFFTZXR0bGVQcmljZRIaCghRTGFzdFF0eRgWIAEoAVIIUUxhc3RRdHkSKwoIQXBwbG'
    'VCdXkYFyADKAsyDy5jbWQuQXBwbHlQcmljZVIIQXBwbGVCdXkSLQoJQXBwbGVTZWxsGBggAygL'
    'Mg8uY21kLkFwcGx5UHJpY2VSCUFwcGxlU2VsbBIqChBRSW1wbGllZEJpZFByaWNlGBkgASgBUh'
    'BRSW1wbGllZEJpZFByaWNlEiYKDlFJbXBsaWVkQmlkUXR5GBogASgBUg5RSW1wbGllZEJpZFF0'
    'eRIqChBRSW1wbGllZEFza1ByaWNlGBsgASgBUhBRSW1wbGllZEFza1ByaWNlEiYKDlFJbXBsaW'
    'VkQXNrUXR5GBwgASgBUg5RSW1wbGllZEFza1F0eRIcCglRUHJlRGVsdGEYHSABKAFSCVFQcmVE'
    'ZWx0YRIeCgpRQ3VyckRlbHRhGB4gASgBUgpRQ3VyckRlbHRhEh4KClFJbnNpZGVRdHkYHyABKA'
    'FSClFJbnNpZGVRdHkSIAoLUU91dHNpZGVRdHkYICABKAFSC1FPdXRzaWRlUXR5EiQKDVFUdXJu'
    'b3ZlclJhdGUYISABKAFSDVFUdXJub3ZlclJhdGUSHAoJUTVEQXZnUXR5GCIgASgBUglRNURBdm'
    'dRdHkSGgoIUVBFUmF0aW8YIyABKAFSCFFQRVJhdGlvEiAKC1FUb3RhbFZhbHVlGCQgASgBUgtR'
    'VG90YWxWYWx1ZRIqChBRTmVnb3RpYWJsZVZhbHVlGCUgASgBUhBRTmVnb3RpYWJsZVZhbHVlEi'
    'YKDlFQb3NpdGlvblRyZW5kGCYgASgBUg5RUG9zaXRpb25UcmVuZBIiCgxRQ2hhbmdlU3BlZWQY'
    'JyABKAFSDFFDaGFuZ2VTcGVlZBIgCgtRQ2hhbmdlUmF0ZRgoIAEoAVILUUNoYW5nZVJhdGUSIg'
    'oMUUNoYW5nZVZhbHVlGCkgASgBUgxRQ2hhbmdlVmFsdWUSFgoGUVN3aW5nGCogASgBUgZRU3dp'
    'bmcSIgoMUVRvdGFsQmlkUXR5GCsgASgBUgxRVG90YWxCaWRRdHkSIgoMUVRvdGFsQXNrUXR5GC'
    'wgASgBUgxRVG90YWxBc2tRdHk=');

