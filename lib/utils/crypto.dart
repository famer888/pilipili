import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:youyutv/utils/common.dart';

final key = Key.fromUtf8("NQYT3eSsXG52WPDS");
final iv = IV.fromUtf8("KIxEQJNeXG715zkh");
final appkey = "NaojbMJVDK1V82QG49dt6tiXQxAsZTQF";

final mediaKey = Key.fromUtf8("f5d965df75336270");
final mediaIv = IV.fromUtf8("97b60394abc2fbe1");

String getSign(Map obj) {
  String md5Text;
  List keyValues = [];
  keyValues.add("client=${obj['client']}");
  keyValues.add("data=${obj['data']}");
  keyValues.add("timestamp=${obj['timestamp']}");
  String text = '${keyValues.join('&')}$appkey';
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
        getSign({"client": "pwa", "data": data, "timestamp": timestamp});
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
}
