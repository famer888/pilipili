import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pilipili/utils/common.dart';

final key = Key.fromUtf8("NQYT3eSsXG52WPDS");
final iv = IV.fromUtf8("KIxEQJNeXG715zkh");
final appkey = "NaojbMJVDK1V82QG49dt6tiXQxAsZTQF";

final mediaKey = Key.fromUtf8("f5d965df75336270");
final mediaIv = IV.fromUtf8("97b60394abc2fbe1");

String pliDecry(encrypted) {
  try {
    final encrypter = Encrypter(AES(mediaKey, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt16(encrypted, iv: mediaIv);
    return decrypted;
  } catch (err) {
    CommonUtils.debugPrint("aes decode error:$err");
    return encrypted;
  }
}

String pliEncry(plainText) {
  try {
    final encrypter = Encrypter(AES(mediaKey, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: mediaIv);
    return encrypted.base16;
  } catch (err) {
    CommonUtils.debugPrint("aes encode error:$err");
    return plainText;
  }
}

String getSign(Map obj) {
  String md5Text;
  List keyValues = [];
  keyValues.add("client=" + obj['client'].toString());
  keyValues.add("data=" + obj['data'].toString());
  keyValues.add("timestamp=" + obj['timestamp'].toString());
  String text = keyValues.join('&') + appkey;
  Digest _digest = sha256.convert(utf8.encode(text));
  md5Text = md5.convert(utf8.encode(_digest.toString())).toString();
  return md5Text;
}

class PlatformAwareCrypto {
  static Future<dynamic> encryptReqParams(String word) async {
    Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    Encrypted encrypted = encrypter.encryptBytes(utf8.encode(word), iv: iv);
    String data = utf8.decode(encrypted.base64.codeUnits);
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String sign = getSign({"client": "pwa", "data": data, "timestamp": timestamp});
    return "client=pwa&timestamp=$timestamp&data=$data&sign=$sign";
  }

  static Future<String> decryptResData(dynamic data) async {
    Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    Encrypted encrypted = Encrypted.fromBase64(data['data']);
    String decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

  static dynamic decryptImage(data) {
    try {
      Encrypter encrypter = Encrypter(AES(mediaKey, mode: AESMode.cbc));
      Encrypted encrypted = Encrypted.fromBase64(data);
      final stopwatch = Stopwatch()..start();
      List<int> decrypted = encrypter.decryptBytes(encrypted, iv: mediaIv);
      // CommonUtils.debugPrint('decode() executed in ${stopwatch.elapsed}');
      return base64Encode(decrypted);
    } catch (err) {
      CommonUtils.debugPrint(err);
      return null;
    }
  }

  static dynamic decryptM3U8(data) {
    try {
      Encrypter encrypter = Encrypter(AES(mediaKey, mode: AESMode.cbc));
      Encrypted encrypted = Encrypted.fromBase64(data);
      final stopwatch = Stopwatch()..start();
      String decrypted = encrypter.decrypt(encrypted, iv: mediaIv);
      CommonUtils.debugPrint('decode() executed in ${stopwatch.elapsed}');
      return decrypted;
    } catch (err) {
      return null;
    }
  }

  //新增上报加解密

  static String getReportSign(Map obj, {String signKey = ''}) {
    final keyValues = [];
    keyValues.add("client=${obj['client']}");
    keyValues.add("data=${obj['data']}");
    keyValues.add("timestamp=${obj['timestamp']}");

    final text = '${keyValues.join('&')}$signKey';
    final digest = sha256.convert(utf8.encode(text));
    final md5Text = md5.convert(utf8.encode(digest.toString())).toString();
    return md5Text;
  }

  static dynamic encryptReportParams(Object value, {String keyString = '', String ivString = '', String signKey = ''}) {
    final word = jsonEncode(value);
    final encrypter = Encrypter(AES(Key.fromUtf8(keyString), mode: AESMode.cbc));
    final encrypted = encrypter.encryptBytes(utf8.encode(word), iv: IV.fromUtf8(ivString));
    final data = utf8.decode(encrypted.base64.codeUnits);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final sign = getReportSign({'client': 'pwa', 'data': data, 'timestamp': timestamp}, signKey: signKey);
    return 'client=pwa&timestamp=$timestamp&data=$data&sign=$sign';
  }

  static String encryptSecret(String key) {
    final serect = key.split('_').first;
    final interval = int.tryParse(key.split('_').last) ?? 3600;
    final ct = (DateTime.now().millisecondsSinceEpoch / 1000 / interval).floor();
    final cal = (sha1.convert(utf8.encode(serect + ct.toString()))).toString();
    final sha = sha1.convert(utf8.encode(serect + cal));
    final str = md5.convert(utf8.encode(sha.toString())).toString();
    return str.substring(0, 16);
  }
}
