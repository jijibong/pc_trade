import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '../../config/sign_param.dart';
import '../../model/client/client.dart';
import '../utils/utils.dart';

class SignData {
  ///数据加密
  Future<String> signData(String json, String url) async {
    ClientData client = ClientData();

    if (json != "") {
      String EncryptedKey = Utils.generateLenString(32);
      String Iv = Utils.generateLenString(16);

      List<int> tmp = utf8.encode(EncryptedKey);
      String AesKey = utf8.decode(tmp.take(16).toList());

      List<int> HmacKey = tmp.skip(16).take(tmp.length - 16).toList();
      final encrypter = Encrypter(AES(Key.fromUtf8(AesKey), mode: AESMode.cbc, padding: 'PKCS7'));

      //AES加密原始报文
      Encrypted Ciphertext = encrypter.encrypt(json, iv: IV.fromUtf8(Iv));
      String CiphertextString = Ciphertext.base16.toUpperCase();

      //hmacsha6生成报文信息摘要
      var hmacSha256 = Hmac(sha256, HmacKey);
      var digest = hmacSha256.convert(CiphertextString.codeUnits);
      String AuthTag = digest.toString().toUpperCase();

      //RSA加密秘钥字符串
      String publicPem = await rootBundle.loadString("assets/key/public.pem");
      RSAPublicKey publicKey = RSAKeyParser().parse(publicPem) as RSAPublicKey;
      final rsaEncrypter = Encrypter(RSA(publicKey: publicKey));
      EncryptedKey = rsaEncrypter.encrypt(EncryptedKey).base16.toUpperCase();

      EncryptedKey = base64UrlSafeEncode(EncryptedKey);
      Iv = base64UrlSafeEncode(Iv);
      CiphertextString = base64UrlSafeEncode(CiphertextString);
      AuthTag = base64UrlSafeEncode(AuthTag);

      client.encryptedKey = EncryptedKey;
      client.iV = Iv;
      client.ciphertext = CiphertextString;
      client.authTag = AuthTag;

      // logger.d("base64UrlEncode加密后：EncryptedKey：$EncryptedKey");
      // logger.d("base64UrlEncode加密后：Iv：$Iv");
      // logger.d("base64UrlEncode加密后：Ciphertext：$Ciphertext");
      // logger.d("base64UrlEncode加密后：AuthTag：$AuthTag");
    }

    int TimeStamp = DateTime.now().microsecondsSinceEpoch;
    //生成时间的MD5
    String NonceStr = Utils.generateLenString(32);
    String newStr = "$NonceStr$url${TimeStamp.toStringAsFixed(0)}";
    Digest digest = md5.convert(utf8.encode(newStr));

    String TimeSign = digest.toString().toUpperCase();
    String AuthCode = SignParam.AuthCode;
    AuthCode = base64UrlSafeEncode(AuthCode);
    NonceStr = base64UrlSafeEncode(NonceStr);
    TimeSign = base64UrlSafeEncode(TimeSign);

    client.appId = AuthCode;
    client.timeStamp = TimeStamp;
    client.nonceStr = NonceStr;
    client.timeSign = TimeSign;

    json = jsonEncode(client);

    // log("HTTP加密结果：$json");
    return json;
  }

  String base64UrlSafeEncode(String input) {
    return base64UrlEncode(utf8.encode(input));
  }
}
