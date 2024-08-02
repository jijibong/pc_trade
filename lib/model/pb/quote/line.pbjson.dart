//
//  Generated code. Do not modify.
//  source: proto/quote/line.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use lineDescriptor instead')
const Line$json = {
  '1': 'Line',
  '2': [
    {'1': 'KL1M', '2': 0},
    {'1': 'KL5M', '2': 1},
    {'1': 'KL10M', '2': 2},
    {'1': 'KL15M', '2': 3},
    {'1': 'KL30M', '2': 4},
    {'1': 'KL1H', '2': 5},
    {'1': 'KL1D', '2': 6},
    {'1': 'KL3M', '2': 7},
  ],
};

/// Descriptor for `Line`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List lineDescriptor = $convert.base64Decode(
    'CgRMaW5lEggKBEtMMU0QABIICgRLTDVNEAESCQoFS0wxME0QAhIJCgVLTDE1TRADEgkKBUtMMz'
    'BNEAQSCAoES0wxSBAFEggKBEtMMUQQBhIICgRLTDNNEAc=');

