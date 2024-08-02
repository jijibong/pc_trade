//
//  Generated code. Do not modify.
//  source: proto/quote/cmd.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use optionDescriptor instead')
const Option$json = {
  '1': 'Option',
  '2': [
    {'1': 'OPT_start', '2': 0},
    {'1': 'OPT_Auth', '2': 1},
    {'1': 'OPT_Sub', '2': 2},
    {'1': 'OPT_SubFill', '2': 3},
    {'1': 'OPT_UnSubFill', '2': 4},
    {'1': 'OPT_SubQuote', '2': 5},
    {'1': 'OPT_UnSubQuote', '2': 6},
    {'1': 'OPT_SubKline', '2': 7},
    {'1': 'OPT_UnSubKline', '2': 8},
    {'1': 'OPT_RtnFill', '2': 9},
    {'1': 'OPT_RtnQuote', '2': 10},
    {'1': 'OPT_RtnKline', '2': 11},
    {'1': 'OPT_UnSubAll', '2': 20},
  ],
};

/// Descriptor for `Option`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List optionDescriptor = $convert.base64Decode(
    'CgZPcHRpb24SDQoJT1BUX3N0YXJ0EAASDAoIT1BUX0F1dGgQARILCgdPUFRfU3ViEAISDwoLT1'
    'BUX1N1YkZpbGwQAxIRCg1PUFRfVW5TdWJGaWxsEAQSEAoMT1BUX1N1YlF1b3RlEAUSEgoOT1BU'
    'X1VuU3ViUXVvdGUQBhIQCgxPUFRfU3ViS2xpbmUQBxISCg5PUFRfVW5TdWJLbGluZRAIEg8KC0'
    '9QVF9SdG5GaWxsEAkSEAoMT1BUX1J0blF1b3RlEAoSEAoMT1BUX1J0bktsaW5lEAsSEAoMT1BU'
    'X1VuU3ViQWxsEBQ=');

@$core.Deprecated('Use cmdDescriptor instead')
const cmd$json = {
  '1': 'cmd',
  '2': [
    {'1': 'Option', '3': 1, '4': 1, '5': 14, '6': '.cmd.Option', '10': 'Option'},
    {'1': 'ReqId', '3': 2, '4': 1, '5': 3, '10': 'ReqId'},
    {'1': 'DateTime', '3': 3, '4': 1, '5': 3, '10': 'DateTime'},
    {'1': 'Data', '3': 4, '4': 1, '5': 12, '10': 'Data'},
  ],
};

/// Descriptor for `cmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cmdDescriptor = $convert.base64Decode(
    'CgNjbWQSIwoGT3B0aW9uGAEgASgOMgsuY21kLk9wdGlvblIGT3B0aW9uEhQKBVJlcUlkGAIgAS'
    'gDUgVSZXFJZBIaCghEYXRlVGltZRgDIAEoA1IIRGF0ZVRpbWUSEgoERGF0YRgEIAEoDFIERGF0'
    'YQ==');

