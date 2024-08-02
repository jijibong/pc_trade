//
//  Generated code. Do not modify.
//  source: proto/trade/cmd.proto
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
    {'1': 'REQ_OPT_UNIVERSAL', '2': 0},
    {'1': 'REQ_OPT_AUTH', '2': 1},
    {'1': 'REQ_OPT_LOGOUT', '2': 2},
    {'1': 'REQ_SUBSCRIBE_SUB_ALL_PRIVATE', '2': 3},
    {'1': 'REQ_SUBSCRIBE_SUB_PART_PRIVATE', '2': 4},
    {'1': 'REQ_SUBSCRIBE_SUB_POSITION_FLOAT', '2': 5},
    {'1': 'REQ_UN_SUBSCRIBE_SUB_POSITION_FLOAT', '2': 6},
    {'1': 'REQ_UN_SUBSCRIBE_SUB_ALL_PRIVATE', '2': 7},
    {'1': 'REQ_SUBSCRIBE_SUB_FUND', '2': 8},
    {'1': 'REQ_UN_SUBSCRIBE_SUB_FUND', '2': 9},
    {'1': 'ON_ACCOUNT_FORCE_CLOSE', '2': 101},
    {'1': 'ON_ACCOUNT_RISK_WARNING', '2': 102},
    {'1': 'ON_ACCOUNT_FUND_UPDATE', '2': 103},
    {'1': 'ON_ACCOUNT_ORDER_UPDATE', '2': 104},
    {'1': 'ON_ACCOUNT_FILL_UPDATE', '2': 105},
    {'1': 'ON_ACCOUNT_POSITION_UPDATE', '2': 106},
    {'1': 'ON_ACCOUNT_POSITION_FLOAT', '2': 107},
    {'1': 'ON_ACCOUNT_RATE_UPDATE', '2': 108},
    {'1': 'ON_ACCOUNT_FORCE_EXIT', '2': 109},
  ],
};

/// Descriptor for `Option`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List optionDescriptor = $convert.base64Decode(
    'CgZPcHRpb24SFQoRUkVRX09QVF9VTklWRVJTQUwQABIQCgxSRVFfT1BUX0FVVEgQARISCg5SRV'
    'FfT1BUX0xPR09VVBACEiEKHVJFUV9TVUJTQ1JJQkVfU1VCX0FMTF9QUklWQVRFEAMSIgoeUkVR'
    'X1NVQlNDUklCRV9TVUJfUEFSVF9QUklWQVRFEAQSJAogUkVRX1NVQlNDUklCRV9TVUJfUE9TSV'
    'RJT05fRkxPQVQQBRInCiNSRVFfVU5fU1VCU0NSSUJFX1NVQl9QT1NJVElPTl9GTE9BVBAGEiQK'
    'IFJFUV9VTl9TVUJTQ1JJQkVfU1VCX0FMTF9QUklWQVRFEAcSGgoWUkVRX1NVQlNDUklCRV9TVU'
    'JfRlVORBAIEh0KGVJFUV9VTl9TVUJTQ1JJQkVfU1VCX0ZVTkQQCRIaChZPTl9BQ0NPVU5UX0ZP'
    'UkNFX0NMT1NFEGUSGwoXT05fQUNDT1VOVF9SSVNLX1dBUk5JTkcQZhIaChZPTl9BQ0NPVU5UX0'
    'ZVTkRfVVBEQVRFEGcSGwoXT05fQUNDT1VOVF9PUkRFUl9VUERBVEUQaBIaChZPTl9BQ0NPVU5U'
    'X0ZJTExfVVBEQVRFEGkSHgoaT05fQUNDT1VOVF9QT1NJVElPTl9VUERBVEUQahIdChlPTl9BQ0'
    'NPVU5UX1BPU0lUSU9OX0ZMT0FUEGsSGgoWT05fQUNDT1VOVF9SQVRFX1VQREFURRBsEhkKFU9O'
    'X0FDQ09VTlRfRk9SQ0VfRVhJVBBt');

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

