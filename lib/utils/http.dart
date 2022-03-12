import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pilipili/global.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/crypto.dart';
import 'package:http_parser/http_parser.dart';

// 是否因token失效跳转到登录页
bool isJump = false;
Dio _imageDio = new Dio(new BaseOptions(
  connectTimeout: 10 * 1000,
  receiveTimeout: 60 * 1000,
  responseType: ResponseType.bytes,
  validateStatus: (status) {
    return status < 500;
  },
));
getToken() {
  Box box = AppGlobal.appBox;
  return box.get('yy_token');
}

Dio _uploadDio = new Dio(new BaseOptions(
  connectTimeout: 60 * 1000,
  receiveTimeout: 300 * 1000,
));

Dio _apiDio = new Dio(new BaseOptions(
    connectTimeout: 60 * 1000,
    receiveTimeout: 300 * 1000,
    validateStatus: (status) {
      return status < 500;
    },
    contentType: Headers.formUrlEncodedContentType))
  ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
    Map _data = {};
    String yytoken = getToken();
    if (yytoken != null && yytoken != '') {
      AppGlobal.apiToken = yytoken;
    }
    _data.addAll(AppGlobal.appinfo);
    _data.addAll({'token': AppGlobal.apiToken});
    if (options.data != null) {
      _data.addAll(options.data);
    }
    // CommonUtils.debugPrint(_data);
    options.data =
        await PlatformAwareCrypto.encryptReqParams(jsonEncode(_data));

    return handler.next(options);
  }, onResponse: (response, handler) async {
    if (response.data['data'] != null) {
      String _data = await PlatformAwareCrypto.decryptResData(response.data);
      response.data = jsonDecode(_data);
    }
    if (response.data["msg"] == "token无效" &&
        !isJump &&
        AppGlobal.appContext != null &&
        AppGlobal.apInit) {
      CommonUtils.showText("token失效,请重新登录");
      isJump = true;
      AppGlobal.apiToken = '';
      Box box = AppGlobal.appBox;
      box.delete('yy_token');
      if (AppGlobal.routerReplace) {
        AppGlobal.appContext.pop();
      }
      // AppGlobal.appContext.go('/${Routes.login}', extra: {'is_expired': true});
      Future.delayed(Duration(seconds: 3), () {
        isJump = false;
      });
    }
    return handler.next(response);
  }, onError: (DioError e, handler) {
    return handler.next(e);
  }));

class PlatformAwareHttp {
  static Future getImage(url) {
    if (url.contains('http')) {
      return kIsWeb
          ? html.HttpRequest.request(url, responseType: 'arraybuffer')
              .then((xhr) {
              if (xhr.response != null) {
                return base64Encode(xhr.response.asUint8List());
              }
              return '';
            }).onError((error, stackTrace) => '')
          : _imageDio
              .get(url)
              .then((res) => base64Encode(res.data))
              .onError((error, stackTrace) {
              print('error---${url}----${error}');
              return '';
            });
    } else {
      return url;
    }
  }

  static Future uploadImage(
      {dynamic imageUrl,
      String id,
      String position = 'head',
      ProgressCallback progressCallback}) async {
    try {
      if (id == null) id = '${DateTime.now().millisecondsSinceEpoch}';
      var imgKey = AppGlobal.uploadImgKey.replaceFirst('head', '');
      var newKey = 'id=$id&position=$position$imgKey';
      var tmpSha256 = CommonUtils.gvSha256(newKey);
      var sign = CommonUtils.gvMD5(tmpSha256);
      var imgUrlSplit = kIsWeb ? '' : imageUrl.split(".");
      var imageType = kIsWeb ? '' : imgUrlSplit.last;
      if (!kIsWeb && imgUrlSplit.length <= 1) {
        imageType = 'png';
      }
      var imageName = CommonUtils.gvMD5(id);
      FormData formData = FormData.fromMap({
        'id': id,
        'position': position,
        'sign': sign,
        'cover': kIsWeb
            ? imageUrl
            : await MultipartFile.fromFile(
                imageUrl,
                filename: '$imageName.$imageType',
                contentType: MediaType.parse('image/$imageType'),
              ),
      });
      Response response = await _uploadDio.post(AppGlobal.uploadImgUrl,
          data: formData,
          onSendProgress: progressCallback,
          options: Options(contentType: 'multipart/form-data'));
      return response;
    } catch (e) {
      return null;
    }

//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       var responseData = response.data;
//       if (responseData == null || responseData == "") return {};
//       // // debugPrint('response data: ${response.data}');
//       var encryptData = jsonDecode(responseData);
//       if ('${encryptData['code']}' == '1') {
//         return encryptData;
//       }
// //    // debugPrint('---------------------------------------------');
//       var strDecryptData =
//           await FlutterEncryptPlugin.getDecryptData(encryptData);
// //      // debugPrint('uploadImage data: $strDecryptData');
//       var decryptData = jsonDecode(strDecryptData);
//       return decryptData;
//     }
  }

  static Future<Response> download(String urlPath, String savePath,
      {ProgressCallback onReceiveProgress}) {
//    if(_dio == null) return;
    return _uploadDio.download(urlPath, savePath,
        onReceiveProgress: onReceiveProgress);
  }

  // cancelToken 用于二级页面销毁时，中断正在进行中的异步请求
  static Future post(String path, {Map data, CancelToken cancelToken}) {
    AppGlobal.apiBaseURL = "https://apiv2.ltsapi.com";
    print(AppGlobal.apiBaseURL + path);
    return _apiDio.post(AppGlobal.apiBaseURL + path,
        data: data, cancelToken: cancelToken);
  }
}
