import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pilipili/utils/common.dart';
import 'package:flutter/foundation.dart' as platform;

final key = Key.fromUtf8(platform.kIsWeb ? "tpPmmU6PGq7HXeRI" : "boYKnvXMkj3lkhjp");
final iv = IV.fromUtf8(platform.kIsWeb ? "kScjUo8FzUTIxeCy" : "fhE0omBgjlnihR8A");
final appkey = platform.kIsWeb ? "AKmg68AZLnOKxvU0GGFbD65KBKzwm5Gr" : "tQdNCz4OY9iR1ystwAThyHbhBOnTGmNT";

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
  keyValues.add("_ver=" + obj['_ver'].toString());
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
    String sign =
        getSign({"client": platform.kIsWeb ? 'pwa' : 'and', "data": data, "timestamp": timestamp, "_ver": "v1"});
    return "client=${platform.kIsWeb ? 'pwa' : 'and'}&timestamp=$timestamp&data=$data&sign=$sign&_ver=v1";
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

  //验证签名
  static String makeSign(Map<dynamic, dynamic> params, String signKey) {
    if (params == null || params.isEmpty) {
      return '';
    }
    // 1. ksort（按 key 排序）
    final sortedKeys = params.keys.toList()..sort();
    // 2. 拼接 key=value
    final List<String> arrTemp = [];
    for (final key in sortedKeys) {
      var value = params[key]?.toString() ?? '';
      if (key == 'data') {
        value = value.replaceAll(' ', '+');
      }
      arrTemp.add('$key=$value');
    }
    // 3. 用 & 连接
    final string = arrTemp.join('&') + signKey;
    // 4. 先 sha256，再 md5
    final sha256Str = sha256.convert(utf8.encode(string)).toString();
    final md5Str = md5.convert(utf8.encode(sha256Str)).toString();

    return md5Str;
  }
}
