//
//  Generated code. Do not modify.
//  source: proto/quote/fill.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use fillDataDescriptor instead')
const FillData$json = {
  '1': 'FillData',
  '2': [
    {'1': 'ExchangeNo', '3': 1, '4': 1, '5': 9, '10': 'ExchangeNo'},
    {'1': 'CommodityType', '3': 2, '4': 1, '5': 9, '10': 'CommodityType'},
    {'1': 'CommodityNo', '3': 3, '4': 1, '5': 9, '10': 'CommodityNo'},
    {'1': 'ContractNo', '3': 4, '4': 1, '5': 9, '10': 'ContractNo'},
    {'1': 'LastPrice', '3': 5, '4': 1, '5': 1, '10': 'LastPrice'},
    {'1': 'Volume', '3': 6, '4': 1, '5': 1, '10': 'Volume'},
    {'1': 'FilledVolume', '3': 7, '4': 1, '5': 1, '10': 'FilledVolume'},
    {'1': 'OpenInterestDeltaForward', '3': 8, '4': 1, '5': 13, '10': 'OpenInterestDeltaForward'},
    {'1': 'OrderForward', '3': 9, '4': 1, '5': 13, '10': 'OrderForward'},
    {'1': 'UpdateTime', '3': 10, '4': 1, '5': 9, '10': 'UpdateTime'},
  ],
};

/// Descriptor for `FillData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fillDataDescriptor = $convert.base64Decode(
    'CghGaWxsRGF0YRIeCgpFeGNoYW5nZU5vGAEgASgJUgpFeGNoYW5nZU5vEiQKDUNvbW1vZGl0eV'
    'R5cGUYAiABKAlSDUNvbW1vZGl0eVR5cGUSIAoLQ29tbW9kaXR5Tm8YAyABKAlSC0NvbW1vZGl0'
    'eU5vEh4KCkNvbnRyYWN0Tm8YBCABKAlSCkNvbnRyYWN0Tm8SHAoJTGFzdFByaWNlGAUgASgBUg'
    'lMYXN0UHJpY2USFgoGVm9sdW1lGAYgASgBUgZWb2x1bWUSIgoMRmlsbGVkVm9sdW1lGAcgASgB'
    'UgxGaWxsZWRWb2x1bWUSOgoYT3BlbkludGVyZXN0RGVsdGFGb3J3YXJkGAggASgNUhhPcGVuSW'
    '50ZXJlc3REZWx0YUZvcndhcmQSIgoMT3JkZXJGb3J3YXJkGAkgASgNUgxPcmRlckZvcndhcmQS'
    'HgoKVXBkYXRlVGltZRgKIAEoCVIKVXBkYXRlVGltZQ==');

@$core.Deprecated('Use fillDataV2Descriptor instead')
const FillDataV2$json = {
  '1': 'FillDataV2',
  '2': [
    {'1': 'ExchangeNo', '3': 1, '4': 1, '5': 9, '10': 'ExchangeNo'},
    {'1': 'CommodityType', '3': 2, '4': 1, '5': 9, '10': 'CommodityType'},
    {'1': 'CommodityNo', '3': 3, '4': 1, '5': 9, '10': 'CommodityNo'},
    {'1': 'ContractNo', '3': 4, '4': 1, '5': 9, '10': 'ContractNo'},
    {'1': 'LastPrice', '3': 5, '4': 1, '5': 1, '10': 'LastPrice'},
    {'1': 'UpDown', '3': 6, '4': 1, '5': 1, '10': 'UpDown'},
    {'1': 'Volume', '3': 7, '4': 1, '5': 1, '10': 'Volume'},
    {'1': 'Open', '3': 8, '4': 1, '5': 1, '10': 'Open'},
    {'1': 'Close', '3': 9, '4': 1, '5': 1, '10': 'Close'},
    {'1': 'TickType', '3': 10, '4': 1, '5': 13, '10': 'TickType'},
    {'1': 'TickColor', '3': 11, '4': 1, '5': 13, '10': 'TickColor'},
    {'1': 'UpdateTime', '3': 12, '4': 1, '5': 9, '10': 'UpdateTime'},
  ],
};

/// Descriptor for `FillDataV2`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fillDataV2Descriptor = $convert.base64Decode(
    'CgpGaWxsRGF0YVYyEh4KCkV4Y2hhbmdlTm8YASABKAlSCkV4Y2hhbmdlTm8SJAoNQ29tbW9kaX'
    'R5VHlwZRgCIAEoCVINQ29tbW9kaXR5VHlwZRIgCgtDb21tb2RpdHlObxgDIAEoCVILQ29tbW9k'
    'aXR5Tm8SHgoKQ29udHJhY3RObxgEIAEoCVIKQ29udHJhY3RObxIcCglMYXN0UHJpY2UYBSABKA'
    'FSCUxhc3RQcmljZRIWCgZVcERvd24YBiABKAFSBlVwRG93bhIWCgZWb2x1bWUYByABKAFSBlZv'
    'bHVtZRISCgRPcGVuGAggASgBUgRPcGVuEhQKBUNsb3NlGAkgASgBUgVDbG9zZRIaCghUaWNrVH'
    'lwZRgKIAEoDVIIVGlja1R5cGUSHAoJVGlja0NvbG9yGAsgASgNUglUaWNrQ29sb3ISHgoKVXBk'
    'YXRlVGltZRgMIAEoCVIKVXBkYXRlVGltZQ==');

