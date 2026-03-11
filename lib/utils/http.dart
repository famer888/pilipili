import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/report/api_timing_interceptor.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pilipili/global.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/crypto.dart';
import 'package:http_parser/http_parser.dart';

// 是否因token失效跳转到登录页
bool isJump = false;
bool _warnJump = false;
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
    if (yytoken != '') {
      AppGlobal.apiToken = yytoken;
    }
    _data.addAll(AppGlobal.appinfo);
    _data.addAll({'token': AppGlobal.apiToken});
    if (options.data != null) {
      _data.addAll(options.data);
    }
    CommonUtils.debugPrint(_data);
    options.data = await PlatformAwareCrypto.encryptReqParams(jsonEncode(_data));

    return handler.next(options);
  }, onResponse: (response, handler) async {
    if (response.requestOptions.path.contains("checkLine")) {
      return handler.next(response);
    }
    if (response.data['data'] != null && !response.data['data'].toString().contains("<!")) {
      Map<dynamic, dynamic> result = Map.from(response.data);
      String sign = result.remove("sign").toString();
      if (PlatformAwareCrypto.makeSign(result, appkey) != sign && !_warnJump) {
        _warnJump = true;
        String officeSite = Provider.of<HomeConfig>(AppGlobal.appContext, listen: false).config.officeSite ?? "";
        YyShowDialog.showdialog(AppGlobal.appContext, title: '温馨提示', btnText: '去官网下载', cancelText: '取消', callBack: () {
          CommonUtils.launchURL(officeSite);
        }, content: (setDialogState) {
          return DefaultTextStyle(
              style: TextStyle(color: Color(0xff646464), fontSize: ScreenUtil().setSp(16), fontWeight: FontWeight.bold),
              child: Text('数据校验失败，请去官网下载最新版本！'));
        });
      }
      String _data = await PlatformAwareCrypto.decryptResData(response.data);
      response.data = jsonDecode(_data);
    }
    if (response.data["msg"] == "token无效" && !isJump && AppGlobal.apInit) {
      CommonUtils.showText("token失效,请重新登录");
      isJump = true;
      AppGlobal.apiToken = '';
      Box box = AppGlobal.appBox;
      box.delete('yy_token');
      if (AppGlobal.routerReplace) {
        AppGlobal.appContext.pop();
      }
      Future.delayed(Duration(seconds: 3), () {
        isJump = false;
      });
    }
    return handler.next(response);
  }, onError: (DioException e, handler) {
    return handler.next(e);
  }))
  ..interceptors.add(ApiTimingInterceptor());

class PlatformAwareHttp {
  static Future getImage(url) {
    if (url.contains('http')) {
      return kIsWeb
          ? html.HttpRequest.request(url, responseType: 'arraybuffer').then((xhr) {
              if (xhr.response != null) {
                return base64Encode(xhr.response.asUint8List());
              }
              return '';
            }).onError((error, stackTrace) => '')
          : _imageDio.get(url).then((res) => base64Encode(res.data)).onError((error, stackTrace) {
              print('error---$url----$error');
              return '';
            });
    } else {
      return url;
    }
  }

  static Future uploadImage(
      {dynamic imageUrl, String id, String position = 'head', ProgressCallback progressCallback}) async {
    try {
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
          data: formData, onSendProgress: progressCallback, options: Options(contentType: 'multipart/form-data'));
      return response;
    } catch (e) {
      return null;
    }
  }

  static Future xfileUploadImage({
    XFile file,
    String id,
    String position = 'head',
    ProgressCallback progressCallback,
  }) async {
    try {
      id ??= DateTime.now().millisecondsSinceEpoch.toString();
      var imgKey = AppGlobal.uploadImgKey.replaceFirst('head', '');
      var newKey = 'id=$id&position=$position$imgKey';
      var tmpSha256 = CommonUtils.gvSha256(newKey);
      var sign = CommonUtils.gvMD5(tmpSha256);
      var ext = file.name.split(".").last;

      FormData formData = FormData.fromMap({
        'id': id,
        'position': position,
        'sign': sign,
        'cover': await MultipartFile.fromFile(
          file.path ?? "",
          filename: file.name ?? "",
          contentType: MediaType.parse('image/$ext'),
        ),
      });
      Response response = await _uploadDio.post(
        AppGlobal.uploadImgUrl,
        data: formData,
        onSendProgress: progressCallback,
        options: Options(contentType: 'multipart/form-data'),
      );
      return jsonDecode(response.data);
    } catch (e) {
      CommonUtils.debugPrint(e);
      return null;
    }
  }

  static Future xfileHtmlUploadImage(
      {XFile file, String id, String position = 'head', Function(html.ProgressEvent) progressCallback}) async {
    try {
      id ??= DateTime.now().millisecondsSinceEpoch.toString();
      var imgKey = AppGlobal.uploadImgKey.replaceFirst('head', '');
      var newKey = 'id=$id&position=$position$imgKey';
      var tmpSha256 = CommonUtils.gvSha256(newKey);
      var sign = CommonUtils.gvMD5(tmpSha256);
      var ext = file.name.split(".").last;

      html.Blob blob = html.Blob([await file.readAsBytes()], "image/$ext");
      String url = html.Url.createObjectUrl(blob);
      final html.FormData formData = html.FormData()
        ..append('id', id)
        ..append('position', position)
        ..append('sign', sign)
        ..appendBlob(
          "cover",
          blob,
        );

      html.HttpRequest httpRequest = await html.HttpRequest.request(AppGlobal.uploadImgUrl,
          method: "POST", mimeType: "image/$ext", sendData: formData, onProgress: progressCallback);
      html.Url.revokeObjectUrl(url);
      return jsonDecode(httpRequest.response);
    } catch (e) {
      CommonUtils.debugPrint(e);
      return null;
    }
  }

  static Future xfileBytesUploadMp4(
      {XFile file, String position = 'head', CancelToken cancelToken, ProgressCallback progressCallback}) async {
    try {
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var videoKey = AppGlobal.uploadMp4Key.replaceFirst('head', '');
      var newKey = '$timeStamp$videoKey';
      var sign = CommonUtils.gvMD5(newKey);

      FormData formData = FormData.fromMap({
        'timestamp': timeStamp,
        'uuid': AppGlobal.uuid,
        'sign': sign,
        'video': MultipartFile.fromBytes(
          await file.readAsBytes() ?? [],
          filename: file.name,
          contentType: MediaType.parse('video/mp4'),
        ),
      });

      Response response = await _uploadDio.post(
        AppGlobal.uploadMp4Url,
        data: formData,
        onSendProgress: progressCallback,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      CommonUtils.debugPrint(e);
      return null;
    }
  }

  static Future xfileUploadMp4(
      {XFile file, String position = 'head', CancelToken cancelToken, ProgressCallback progressCallback}) async {
    try {
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var videoKey = AppGlobal.uploadMp4Key.replaceFirst('head', '');
      var newKey = '$timeStamp$videoKey';
      var sign = CommonUtils.gvMD5(newKey);
      var imageName = CommonUtils.gvMD5(timeStamp);

      var filename = '$imageName.mp4';
      FormData formData = FormData.fromMap({
        'timestamp': timeStamp,
        'uuid': AppGlobal.uuid,
        'sign': sign,
        'video': await MultipartFile.fromFile(
          file.path ?? "",
          filename: filename,
          contentType: MediaType.parse('video/mp4'),
        ),
      });
      Response response = await _uploadDio.post(AppGlobal.uploadMp4Url,
          data: formData,
          onSendProgress: progressCallback,
          cancelToken: cancelToken,
          options: Options(contentType: 'multipart/form-data'));
      return response.data;
    } catch (e) {
      CommonUtils.debugPrint(e);
      return null;
    }
  }

  static Future<Response> download(String urlPath, String savePath, {ProgressCallback onReceiveProgress}) {
//    if(_dio == null) return;
    return _uploadDio.download(urlPath, savePath, onReceiveProgress: onReceiveProgress);
  }

  // cancelToken 用于二级页面销毁时，中断正在进行中的异步请求
  static Future post(String path, {Map data, CancelToken cancelToken}) {
    // AppGlobal.apiBaseURL = 'https://pili.yesebo.net/api.php';
    return _apiDio.post(AppGlobal.apiBaseURL + path, data: data, cancelToken: cancelToken);
  }
}
