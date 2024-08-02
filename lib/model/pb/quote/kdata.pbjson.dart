//
//  Generated code. Do not modify.
//  source: proto/quote/kdata.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use klineDataDescriptor instead')
const KlineData$json = {
  '1': 'KlineData',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'line', '3': 2, '4': 1, '5': 14, '6': '.cmd.Line', '10': 'line'},
    {'1': 'Data', '3': 3, '4': 1, '5': 11, '6': '.cmd.Data', '10': 'Data'},
  ],
};

/// Descriptor for `KlineData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List klineDataDescriptor = $convert.base64Decode(
    'CglLbGluZURhdGESEAoDa2V5GAEgASgJUgNrZXkSHQoEbGluZRgCIAEoDjIJLmNtZC5MaW5lUg'
    'RsaW5lEh0KBERhdGEYAyABKAsyCS5jbWQuRGF0YVIERGF0YQ==');

@$core.Deprecated('Use dataDescriptor instead')
const Data$json = {
  '1': 'Data',
  '2': [
    {'1': 'Open', '3': 1, '4': 1, '5': 1, '10': 'Open'},
    {'1': 'High', '3': 2, '4': 1, '5': 1, '10': 'High'},
    {'1': 'Low', '3': 3, '4': 1, '5': 1, '10': 'Low'},
    {'1': 'Close', '3': 4, '4': 1, '5': 1, '10': 'Close'},
    {'1': 'Volume', '3': 5, '4': 1, '5': 1, '10': 'Volume'},
    {'1': 'Amount', '3': 6, '4': 1, '5': 1, '10': 'Amount'},
    {'1': 'UxTime', '3': 7, '4': 1, '5': 3, '10': 'UxTime'},
  ],
};

/// Descriptor for `Data`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dataDescriptor = $convert.base64Decode(
    'CgREYXRhEhIKBE9wZW4YASABKAFSBE9wZW4SEgoESGlnaBgCIAEoAVIESGlnaBIQCgNMb3cYAy'
    'ABKAFSA0xvdxIUCgVDbG9zZRgEIAEoAVIFQ2xvc2USFgoGVm9sdW1lGAUgASgBUgZWb2x1bWUS'
    'FgoGQW1vdW50GAYgASgBUgZBbW91bnQSFgoGVXhUaW1lGAcgASgDUgZVeFRpbWU=');

