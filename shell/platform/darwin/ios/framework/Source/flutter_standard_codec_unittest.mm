// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "flutter/shell/platform/darwin/ios/framework/Headers/FlutterCodecs.h"
#include "gtest/gtest.h"

void checkEncodeDecode(id value, NSData* expectedEncoding) {
  FlutterStandardMessageCodec* codec = [FlutterStandardMessageCodec sharedInstance];
  NSData* encoded = [codec encode:value];
  if (expectedEncoding == nil)
    ASSERT_TRUE(encoded == nil);
  else
    ASSERT_TRUE([encoded isEqual:expectedEncoding]);
  id decoded = [codec decode:encoded];
  if (value == nil || value == [NSNull null])
    ASSERT_TRUE(decoded == nil);
  else
    ASSERT_TRUE([value isEqual:decoded]);
}

void checkEncodeDecode(id value) {
  FlutterStandardMessageCodec* codec = [FlutterStandardMessageCodec sharedInstance];
  NSData* encoded = [codec encode:value];
  id decoded = [codec decode:encoded];
  if (value == nil || value == [NSNull null])
    ASSERT_TRUE(decoded == nil);
  else
    ASSERT_TRUE([value isEqual:decoded]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeNil) {
  checkEncodeDecode(nil, nil);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeNSNull) {
  char bytes[1] = {0x00};
  checkEncodeDecode([NSNull null], [NSData dataWithBytes:bytes length:1]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeYes) {
  char bytes[1] = {0x01};
  checkEncodeDecode(@YES, [NSData dataWithBytes:bytes length:1]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeNo) {
  char bytes[1] = {0x02};
  checkEncodeDecode(@NO, [NSData dataWithBytes:bytes length:1]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeUInt8) {
  char bytes[5] = {0x03, 0xfe, 0x00, 0x00, 0x00};
  UInt8 value = 0xfe;
  checkEncodeDecode(@(value), [NSData dataWithBytes:bytes length:5]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeUInt16) {
  char bytes[5] = {0x03, 0xdc, 0xfe, 0x00, 0x00};
  UInt16 value = 0xfedc;
  checkEncodeDecode(@(value), [NSData dataWithBytes:bytes length:5]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeUInt32) {
  char bytes[9] = {0x04, 0x09, 0xba, 0xdc, 0xfe, 0x00, 0x00, 0x00, 0x00};
  UInt32 value = 0xfedcba09;
  checkEncodeDecode(@(value), [NSData dataWithBytes:bytes length:9]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeUInt64AsHexString) {
  FlutterStandardMessageCodec* codec = [FlutterStandardMessageCodec sharedInstance];
  UInt64 u64 = 0xfffffffffffffffa;
  NSData* encoded = [codec encode:@(u64)];
  FlutterStandardBigInteger* decoded = [codec decode:encoded];
  ASSERT_TRUE([decoded.hex isEqual:@"fffffffffffffffa"]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeSInt8) {
  char bytes[5] = {0x03, 0xfe, 0xff, 0xff, 0xff};
  SInt8 value = 0xfe;
  checkEncodeDecode(@(value), [NSData dataWithBytes:bytes length:5]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeSInt16) {
  char bytes[5] = {0x03, 0xdc, 0xfe, 0xff, 0xff};
  SInt16 value = 0xfedc;
  checkEncodeDecode(@(value), [NSData dataWithBytes:bytes length:5]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeSInt32) {
  char bytes[5] = {0x03, 0x78, 0x56, 0x34, 0x12};
  checkEncodeDecode(@(0x12345678), [NSData dataWithBytes:bytes length:5]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeSInt64) {
  char bytes[9] = {0x04, 0xef, 0xcd, 0xab, 0x90, 0x78, 0x56, 0x34, 0x12};
  checkEncodeDecode(@(0x1234567890abcdef), [NSData dataWithBytes:bytes length:9]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeBigInteger) {
  FlutterStandardBigInteger* value =
      [FlutterStandardBigInteger bigIntegerWithHex:@"-abcdef0123456789abcdef01234567890"];
  checkEncodeDecode(value);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeFloat32) {
  char bytes[16] = {0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0xfb, 0x21, 0x09, 0x40};
  checkEncodeDecode(@3.1415927f, [NSData dataWithBytes:bytes length:16]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeFloat64) {
  char bytes[16] = {0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x2d, 0x44, 0x54, 0xfb, 0x21, 0x09, 0x40};
  checkEncodeDecode(@3.14159265358979311599796346854, [NSData dataWithBytes:bytes length:16]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeString) {
  char bytes[13] = {0x07, 0x0b, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64};
  checkEncodeDecode(@"hello world", [NSData dataWithBytes:bytes length:13]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeStringWithNonAsciiCodePoint) {
  char bytes[7] = {0x07, 0x05, 0x68, 0xe2, 0x98, 0xba, 0x77};
  checkEncodeDecode(@"h\u263Aw", [NSData dataWithBytes:bytes length:7]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeStringWithNonBMPCodePoint) {
  char bytes[8] = {0x07, 0x06, 0x68, 0xf0, 0x9f, 0x98, 0x82, 0x77};
  checkEncodeDecode(@"h\U0001F602w", [NSData dataWithBytes:bytes length:8]);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeArray) {
  NSArray* value = @[ [NSNull null], @"hello", @3.14, @47, @{ @42 : @"nested" } ];
  checkEncodeDecode(value);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeDictionary) {
  NSDictionary* value =
      @{ @"a" : @3.14,
         @"b" : @47,
         [NSNull null] : [NSNull null],
         @3.14 : @[ @"nested" ] };
  checkEncodeDecode(value);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeByteArray) {
  char bytes[4] = {0xBA, 0x5E, 0xBA, 0x11};
  NSData* data = [NSData dataWithBytes:bytes length:4];
  FlutterStandardTypedData* value = [FlutterStandardTypedData typedDataWithBytes:data];
  checkEncodeDecode(value);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeInt32Array) {
  char bytes[8] = {0xBA, 0x5E, 0xBA, 0x11, 0xff, 0xff, 0xff, 0xff};
  NSData* data = [NSData dataWithBytes:bytes length:8];
  FlutterStandardTypedData* value = [FlutterStandardTypedData typedDataWithInt32:data];
  checkEncodeDecode(value);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeInt64Array) {
  char bytes[8] = {0xBA, 0x5E, 0xBA, 0x11, 0xff, 0xff, 0xff, 0xff};
  NSData* data = [NSData dataWithBytes:bytes length:8];
  FlutterStandardTypedData* value = [FlutterStandardTypedData typedDataWithInt64:data];
  checkEncodeDecode(value);
}

TEST(FlutterStandardCodec, CanEncodeAndDecodeFloat64Array) {
  char bytes[16] = {0xBA, 0x5E, 0xBA, 0x11, 0xff, 0xff, 0xff, 0xff,
                    0xBA, 0x5E, 0xBA, 0x11, 0xff, 0xff, 0xff, 0xff};
  NSData* data = [NSData dataWithBytes:bytes length:16];
  FlutterStandardTypedData* value = [FlutterStandardTypedData typedDataWithFloat64:data];
  checkEncodeDecode(value);
}

TEST(FlutterStandardCodec, HandlesMethodCallsWithNilArguments) {
  FlutterStandardMethodCodec* codec = [FlutterStandardMethodCodec sharedInstance];
  FlutterMethodCall* call = [FlutterMethodCall methodCallWithMethodName:@"hello" arguments:nil];
  NSData* encoded = [codec encodeMethodCall:call];
  FlutterMethodCall* decoded = [codec decodeMethodCall:encoded];
  ASSERT_TRUE([decoded isEqual:call]);
}

TEST(FlutterStandardCodec, HandlesMethodCallsWithSingleArgument) {
  FlutterStandardMethodCodec* codec = [FlutterStandardMethodCodec sharedInstance];
  FlutterMethodCall* call = [FlutterMethodCall methodCallWithMethodName:@"hello" arguments:@42];
  NSData* encoded = [codec encodeMethodCall:call];
  FlutterMethodCall* decoded = [codec decodeMethodCall:encoded];
  ASSERT_TRUE([decoded isEqual:call]);
}

TEST(FlutterStandardCodec, HandlesMethodCallsWithArgumentList) {
  FlutterStandardMethodCodec* codec = [FlutterStandardMethodCodec sharedInstance];
  NSArray* arguments = @[ @42, @"world" ];
  FlutterMethodCall* call =
      [FlutterMethodCall methodCallWithMethodName:@"hello" arguments:arguments];
  NSData* encoded = [codec encodeMethodCall:call];
  FlutterMethodCall* decoded = [codec decodeMethodCall:encoded];
  ASSERT_TRUE([decoded isEqual:call]);
}

TEST(FlutterStandardCodec, HandlesSuccessEnvelopesWithNilResult) {
  FlutterStandardMethodCodec* codec = [FlutterStandardMethodCodec sharedInstance];
  NSData* encoded = [codec encodeSuccessEnvelope:nil];
  id decoded = [codec decodeEnvelope:encoded];
  ASSERT_TRUE(decoded == nil);
}

TEST(FlutterStandardCodec, HandlesSuccessEnvelopesWithSingleResult) {
  FlutterStandardMethodCodec* codec = [FlutterStandardMethodCodec sharedInstance];
  NSData* encoded = [codec encodeSuccessEnvelope:@42];
  id decoded = [codec decodeEnvelope:encoded];
  ASSERT_TRUE([decoded isEqual:@42]);
}

TEST(FlutterStandardCodec, HandlesSuccessEnvelopesWithResultMap) {
  FlutterStandardMethodCodec* codec = [FlutterStandardMethodCodec sharedInstance];
  NSDictionary* result = @{ @"a" : @42, @42 : @"a" };
  NSData* encoded = [codec encodeSuccessEnvelope:result];
  id decoded = [codec decodeEnvelope:encoded];
  ASSERT_TRUE([decoded isEqual:result]);
}

TEST(FlutterStandardCodec, HandlesErrorEnvelopes) {
  FlutterStandardMethodCodec* codec = [FlutterStandardMethodCodec sharedInstance];
  NSDictionary* details = @{ @"a" : @42, @42 : @"a" };
  FlutterError* error =
      [FlutterError errorWithCode:@"errorCode" message:@"something failed" details:details];
  NSData* encoded = [codec encodeErrorEnvelope:error];
  id decoded = [codec decodeEnvelope:encoded];
  ASSERT_TRUE([decoded isEqual:error]);
}
