//
//  Generated code. Do not modify.
//  source: proto/quote/body.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use subInfoDescriptor instead')
const SubInfo$json = {
  '1': 'SubInfo',
  '2': [
    {'1': 'Key', '3': 1, '4': 1, '5': 9, '10': 'Key'},
    {'1': 'Line', '3': 2, '4': 1, '5': 14, '6': '.cmd.Line', '10': 'Line'},
  ],
};

/// Descriptor for `SubInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subInfoDescriptor = $convert.base64Decode(
    'CgdTdWJJbmZvEhAKA0tleRgBIAEoCVIDS2V5Eh0KBExpbmUYAiABKA4yCS5jbWQuTGluZVIETG'
    'luZQ==');

@$core.Deprecated('Use subStatusDescriptor instead')
const SubStatus$json = {
  '1': 'SubStatus',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'SubInfo', '3': 3, '4': 1, '5': 11, '6': '.cmd.SubInfo', '10': 'SubInfo'},
  ],
};

/// Descriptor for `SubStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subStatusDescriptor = $convert.base64Decode(
    'CglTdWJTdGF0dXMSEgoEY29kZRgBIAEoBVIEY29kZRIQCgNtc2cYAiABKAlSA21zZxImCgdTdW'
    'JJbmZvGAMgASgLMgwuY21kLlN1YkluZm9SB1N1YkluZm8=');

@$core.Deprecated('Use authReqDescriptor instead')
const AuthReq$json = {
  '1': 'AuthReq',
  '2': [
    {'1': 'Auth', '3': 1, '4': 1, '5': 9, '10': 'Auth'},
  ],
};

/// Descriptor for `AuthReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authReqDescriptor = $convert.base64Decode(
    'CgdBdXRoUmVxEhIKBEF1dGgYASABKAlSBEF1dGg=');

@$core.Deprecated('Use authRespDescriptor instead')
const AuthResp$json = {
  '1': 'AuthResp',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `AuthResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authRespDescriptor = $convert.base64Decode(
    'CghBdXRoUmVzcBISCgRjb2RlGAEgASgFUgRjb2RlEhAKA21zZxgCIAEoCVIDbXNn');

@$core.Deprecated('Use subReqDescriptor instead')
const SubReq$json = {
  '1': 'SubReq',
  '2': [
    {'1': 'Subs', '3': 1, '4': 3, '5': 11, '6': '.cmd.SubInfo', '10': 'Subs'},
  ],
};

/// Descriptor for `SubReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subReqDescriptor = $convert.base64Decode(
    'CgZTdWJSZXESIAoEU3VicxgBIAMoCzIMLmNtZC5TdWJJbmZvUgRTdWJz');

@$core.Deprecated('Use subRespDescriptor instead')
const SubResp$json = {
  '1': 'SubResp',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'status', '3': 3, '4': 3, '5': 11, '6': '.cmd.SubStatus', '10': 'status'},
  ],
};

/// Descriptor for `SubResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subRespDescriptor = $convert.base64Decode(
    'CgdTdWJSZXNwEhIKBGNvZGUYASABKAVSBGNvZGUSEAoDbXNnGAIgASgJUgNtc2cSJgoGc3RhdH'
    'VzGAMgAygLMg4uY21kLlN1YlN0YXR1c1IGc3RhdHVz');

@$core.Deprecated('Use subFillReqDescriptor instead')
const SubFillReq$json = {
  '1': 'SubFillReq',
  '2': [
    {'1': 'Key', '3': 1, '4': 1, '5': 9, '10': 'Key'},
  ],
};

/// Descriptor for `SubFillReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subFillReqDescriptor = $convert.base64Decode(
    'CgpTdWJGaWxsUmVxEhAKA0tleRgBIAEoCVIDS2V5');

@$core.Deprecated('Use subFillRespDescriptor instead')
const SubFillResp$json = {
  '1': 'SubFillResp',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `SubFillResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subFillRespDescriptor = $convert.base64Decode(
    'CgtTdWJGaWxsUmVzcBISCgRjb2RlGAEgASgFUgRjb2RlEhAKA21zZxgCIAEoCVIDbXNn');

@$core.Deprecated('Use unSubFillReqDescriptor instead')
const UnSubFillReq$json = {
  '1': 'UnSubFillReq',
  '2': [
    {'1': 'Key', '3': 1, '4': 1, '5': 9, '10': 'Key'},
  ],
};

/// Descriptor for `UnSubFillReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unSubFillReqDescriptor = $convert.base64Decode(
    'CgxVblN1YkZpbGxSZXESEAoDS2V5GAEgASgJUgNLZXk=');

@$core.Deprecated('Use unSubFillRespDescriptor instead')
const UnSubFillResp$json = {
  '1': 'UnSubFillResp',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `UnSubFillResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unSubFillRespDescriptor = $convert.base64Decode(
    'Cg1VblN1YkZpbGxSZXNwEhIKBGNvZGUYASABKAVSBGNvZGUSEAoDbXNnGAIgASgJUgNtc2c=');

@$core.Deprecated('Use subQuoteReqDescriptor instead')
const SubQuoteReq$json = {
  '1': 'SubQuoteReq',
  '2': [
    {'1': 'Key', '3': 1, '4': 1, '5': 9, '10': 'Key'},
  ],
};

/// Descriptor for `SubQuoteReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subQuoteReqDescriptor = $convert.base64Decode(
    'CgtTdWJRdW90ZVJlcRIQCgNLZXkYASABKAlSA0tleQ==');

@$core.Deprecated('Use subQuoteRespDescriptor instead')
const SubQuoteResp$json = {
  '1': 'SubQuoteResp',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `SubQuoteResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subQuoteRespDescriptor = $convert.base64Decode(
    'CgxTdWJRdW90ZVJlc3ASEgoEY29kZRgBIAEoBVIEY29kZRIQCgNtc2cYAiABKAlSA21zZw==');

@$core.Deprecated('Use unSubQuoteReqDescriptor instead')
const UnSubQuoteReq$json = {
  '1': 'UnSubQuoteReq',
  '2': [
    {'1': 'Key', '3': 1, '4': 1, '5': 9, '10': 'Key'},
  ],
};

/// Descriptor for `UnSubQuoteReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unSubQuoteReqDescriptor = $convert.base64Decode(
    'Cg1VblN1YlF1b3RlUmVxEhAKA0tleRgBIAEoCVIDS2V5');

@$core.Deprecated('Use unSubQuoteRespDescriptor instead')
const UnSubQuoteResp$json = {
  '1': 'UnSubQuoteResp',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `UnSubQuoteResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unSubQuoteRespDescriptor = $convert.base64Decode(
    'Cg5VblN1YlF1b3RlUmVzcBISCgRjb2RlGAEgASgFUgRjb2RlEhAKA21zZxgCIAEoCVIDbXNn');

@$core.Deprecated('Use subKlineReqDescriptor instead')
const SubKlineReq$json = {
  '1': 'SubKlineReq',
  '2': [
    {'1': 'Key', '3': 1, '4': 1, '5': 9, '10': 'Key'},
    {'1': 'Line', '3': 2, '4': 1, '5': 14, '6': '.cmd.Line', '10': 'Line'},
  ],
};

/// Descriptor for `SubKlineReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subKlineReqDescriptor = $convert.base64Decode(
    'CgtTdWJLbGluZVJlcRIQCgNLZXkYASABKAlSA0tleRIdCgRMaW5lGAIgASgOMgkuY21kLkxpbm'
    'VSBExpbmU=');

@$core.Deprecated('Use subKlineRespDescriptor instead')
const SubKlineResp$json = {
  '1': 'SubKlineResp',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `SubKlineResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subKlineRespDescriptor = $convert.base64Decode(
    'CgxTdWJLbGluZVJlc3ASEgoEY29kZRgBIAEoBVIEY29kZRIQCgNtc2cYAiABKAlSA21zZw==');

@$core.Deprecated('Use unSubKlineReqDescriptor instead')
const UnSubKlineReq$json = {
  '1': 'UnSubKlineReq',
  '2': [
    {'1': 'Key', '3': 1, '4': 1, '5': 9, '10': 'Key'},
    {'1': 'Line', '3': 2, '4': 1, '5': 14, '6': '.cmd.Line', '10': 'Line'},
  ],
};

/// Descriptor for `UnSubKlineReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unSubKlineReqDescriptor = $convert.base64Decode(
    'Cg1VblN1YktsaW5lUmVxEhAKA0tleRgBIAEoCVIDS2V5Eh0KBExpbmUYAiABKA4yCS5jbWQuTG'
    'luZVIETGluZQ==');

@$core.Deprecated('Use unSubKlineRespDescriptor instead')
const UnSubKlineResp$json = {
  '1': 'UnSubKlineResp',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `UnSubKlineResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unSubKlineRespDescriptor = $convert.base64Decode(
    'Cg5VblN1YktsaW5lUmVzcBISCgRjb2RlGAEgASgFUgRjb2RlEhAKA21zZxgCIAEoCVIDbXNn');

@$core.Deprecated('Use unSubAllReqDescriptor instead')
const UnSubAllReq$json = {
  '1': 'UnSubAllReq',
};

/// Descriptor for `UnSubAllReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unSubAllReqDescriptor = $convert.base64Decode(
    'CgtVblN1YkFsbFJlcQ==');

@$core.Deprecated('Use unSubAllRespDescriptor instead')
const UnSubAllResp$json = {
  '1': 'UnSubAllResp',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `UnSubAllResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unSubAllRespDescriptor = $convert.base64Decode(
    'CgxVblN1YkFsbFJlc3ASEgoEY29kZRgBIAEoBVIEY29kZRIQCgNtc2cYAiABKAlSA21zZw==');

