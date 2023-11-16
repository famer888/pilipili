import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:common_utils/common_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isolated_worker/worker_delegator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/model/systemnotice.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/utils/http.dart';
import 'package:convert/convert.dart';
import 'package:pilipili/utils/logUtilS.dart';
import 'package:universal_html/html.dart' as html;

import 'api.dart';

class CommonUtils {
  static Future<bool> pngLimitSize(XFile file,
      {int size = 5, String tips}) async {
    int length = await file.length();
    if (length / (1024 * 1024) > size) {
      CommonUtils.showText(tips ?? '上传文件最大${size}M');
      return true;
    }
    return false;
  }

  //设置状态栏颜色
  static setStatusBar({bool isLight = false}) {
    if (kIsWeb) {
      return SystemChrome.setSystemUIOverlayStyle(
          isLight ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    } else if (Platform.isAndroid) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //全局设置透明
        statusBarIconBrightness: isLight ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.black,
      );
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    } else if (Platform.isIOS) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      //导航栏状态栏文字颜色
      SystemChrome.setSystemUIOverlayStyle(
          isLight ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    }
  }

  //特殊字符处理
  static Widget getContentSpan(
    String text, {
    bool isCopy = false,
    TextStyle style,
    TextStyle lightStyle,
  }) {
    style = style ??
        TextStyle(color: Color.fromRGBO(30, 30, 30, 1), fontSize: 14.sp);
    lightStyle = lightStyle ??
        TextStyle(
            color: const Color.fromRGBO(25, 103, 210, 1), fontSize: 14.sp);
    List<InlineSpan> _contentList = [];
    RegExp exp = RegExp(
        r'(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?');
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    int index = 0;
    for (var match in matches) {
      /// start 0  end 8
      /// start 10 end 12
      String c = text.substring(match.start, match.end);
      if (match.start == index) {
        index = match.end;
      }
      if (index < match.start) {
        String a = text.substring(index, match.start);
        index = match.end;
        _contentList.add(
          TextSpan(text: a, style: style),
        );
      }
      if (RegexUtil.isURL(c)) {
        _contentList.add(TextSpan(
            text: c,
            style: lightStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                CommonUtils.launchURL(text.substring(match.start, match.end));
              }));
      } else {
        _contentList.add(
          TextSpan(text: c, style: style),
        );
      }
    }
    if (index < text.length) {
      String a = text.substring(index, text.length);
      _contentList.add(
        TextSpan(text: a, style: style),
      );
    }
    if (isCopy) {
      return SelectableText.rich(
        TextSpan(children: _contentList),
        strutStyle:
            const StrutStyle(forceStrutHeight: true, height: 1, leading: 0.5),
      );
    }
    return RichText(
        textAlign: TextAlign.left,
        text: TextSpan(children: _contentList),
        strutStyle:
            const StrutStyle(forceStrutHeight: true, height: 1, leading: 0.5));
  }

  static bool isAndroidWeb() {
    return kIsWeb &&
        (html.window.navigator.userAgent.indexOf('Android') > -1 ||
            html.window.navigator.userAgent.indexOf('Linux') > -1);
  }

  static updateSystemNotice(context) async {
    SystemNotice sysResult = await getSystemNotice();
    CommonUtils.debugPrint('Key${sysResult.toJson()}');
    if (sysResult.status == 1) {
      Provider.of<HomeConfig>(context, listen: false)
          .setSystemNotice(sysResult);
    }
  }

  static showText(String text, {int time}) {
    return BotToast.showText(
        text: text,
        textStyle: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil().setSp(15),
            decoration: TextDecoration.none),
        align: Alignment(0, 0),
        duration: new Duration(seconds: time != null ? time : 3));
  }

  static getHMTime(int time) {
    getTime(int _num) {
      return _num < 10 ? '0' + _num.toString() : _num;
    }

    var times = new DateTime.fromMillisecondsSinceEpoch(time * 1000);
    String cTime = '${getTime(times.hour)}:${getTime(times.minute)}';
    return '$cTime';
  }

  // 检查安装未知安装包
  static checkRequestInstallPackages() async {
    if (Platform.isAndroid) {
      PermissionStatus _status = await Permission.requestInstallPackages.status;
      if (_status == PermissionStatus.granted) {
        return true;
      } else if (_status == PermissionStatus.permanentlyDenied) {
        CommonUtils.showText('您拒绝了安装未知应用权限，所以无法安装，请前往官网下载。');
        return false;
      } else {
        await Permission.requestInstallPackages.request();
        return true;
      }
    }
  }

  ///检查是否有权限
  static checkStoragePermission() async {
    //检查是否已有读写内存权限
    if (Platform.isAndroid) {
      PermissionStatus storageStatus = await Permission.storage.status;
      if (storageStatus == PermissionStatus.granted) {
        return true;
      } else if (storageStatus == PermissionStatus.permanentlyDenied) {
        CommonUtils.showText('您拒绝了存储权限，未避免账号丢失，请前往设置中打开存储权限');
        return false;
      } else {
        await Permission.storage.request();
        return true;
      }
    }
  }

  static renderFixedNumber(double value) {
    var tips;
    if (value >= 10000) {
      var newvalue = (value / 1000) / 10.round();
      tips = formatNum(newvalue, 2) + "W";
    } else if (value >= 1000) {
      var newvalue = (value / 100) / 10.round();
      tips = formatNum(newvalue, 2) + "千";
    } else {
      tips = value.toString().split('.')[0];
    }
    return tips;
  }

  static formatNum(double number, int postion) {
    if ((number.toString().length - number.toString().lastIndexOf(".") - 1) <
        postion) {
      //小数点后有几位小数
      return number
          .toStringAsFixed(postion)
          .substring(0, number.toString().lastIndexOf(".") + postion + 1)
          .toString();
    } else {
      return number
          .toString()
          .substring(0, number.toString().lastIndexOf(".") + postion + 1)
          .toString();
    }
  }

  static launchURL(String url) async {
    try {
      await launch(url, forceSafariVC: false);
    } catch (e) {
      BotToast.showText(text: '网址错误');
    }
  }

  static String getRealHash([String value]) {
    if (kIsWeb) {
      var currentHash = html.window.location.hash.replaceAll('#', '');
      if (value == null) return currentHash;
    } else {
      if (value == null) return AppGlobal.appRouter.location;
    }
    return '/' + value ?? '';
  }

  static void debugPrint(value) {
    const bool inProduction = const bool.fromEnvironment("dart.vm.product");
    if (!inProduction) {
      LogUtilS.d(value);
    }
  }

  static Map<String, int> retryCountMap = {};
  static List<List> tasks = [];
  static List<bool> wdsRuningStatuses =
      List.generate(AppGlobal.decryptProcessLimit, (index) => false);
  static void getRealImage(
      {dynamic url,
      dynamic imgUrl,
      Function setUrl,
      Function retryHandler,
      bool isNovel = false}) {
    if (url == null) return CommonUtils.debugPrint('无封面图');
    void doWork(args, _freeIndex) async {
      if (args[0] != null || args[1] != null || args[0] != '') {
        dynamic decrypted;
        String data;
        decrypted = AppGlobal.imageCacheBox.get(args[0]) ??
            AppGlobal.imageAssetBox.get(args[0]);
        if (decrypted == null) {
          try {
            data = await PlatformAwareHttp.getImage(args[0]);
            if (data != '' && data != null) {
              decrypted =
                  await WorkerDelegator().run('decryptImage$_freeIndex', data);
              if (decrypted != '' && decrypted != null) {
                decrypted = base64Decode(decrypted);
                if (isNovel) {
                  decrypted = utf8.decode(decrypted);
                }
                if (args[0].toString().indexOf('assets/pilipili/') != -1) {
                  AppGlobal.imageAssetBox.put(args[0], decrypted);
                } else {
                  AppGlobal.imageCacheBox.put(args[0], decrypted);
                }
              }
            }
          } catch (err) {
            CommonUtils.debugPrint('图片请求失败' + args[0].toString());
            CommonUtils.debugPrint('图片请求失败$err');
          }
        }
        if (decrypted != null && args[2] != null) {
          args[2](decrypted);
        } else if (args[3] != null) {
          args[3]();
        }
        decrypted = null;
        data = null;
      }
      wdsRuningStatuses[_freeIndex] = false;
      int f = wdsRuningStatuses.indexWhere((element) => !element);
      if (tasks.length > 0 && f != -1) {
        wdsRuningStatuses[f] = true;
        doWork(tasks.removeAt(0), f);
      }
    }

    var tempUrl = url.toString().indexOf('assets/images/') != -1
        ? '${AppGlobal.bannerImgBase}new/$url'
            .replaceAll('images/', 'pilipili/')
        : url;
    // if(url.toString().indexOf('assets/images/') != -1){
    //   print('*****************************$tempUrl');
    // }
    tasks.add([tempUrl, imgUrl, setUrl, retryHandler]);

    int freeIndex = wdsRuningStatuses.indexWhere((element) => !element);
    if (freeIndex != -1 && tasks.length > 0) {
      wdsRuningStatuses[freeIndex] = true;
      doWork(tasks.removeAt(0), freeIndex);
    }
  }

  static String randomId(int range) {
    String str = "";
    List<String> arr = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z",
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    ];
    for (int i = 0; i < range; i++) {
      int pos = new Random().nextInt(arr.length - 1);
      str += arr[pos];
    }
    return str;
  }

  static Widget shadowBtn(String icon,
      {String text = '', bool isActive = false, double size}) {
    return Container(
      margin: EdgeInsets.only(left: 4.w),
      alignment: Alignment.center,
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: isActive ? Color(0xffFF84A9) : Colors.white,
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: Color(0xffA82118).withOpacity(0.26),
                    offset: Offset(0, 2.w),
                    blurRadius: 3.w,
                    spreadRadius: 0)
                : BoxShadow(
                    color: Color(0xffFFD3E6),
                    offset: Offset(0, 2.w),
                    blurRadius: 4.w,
                    spreadRadius: 0)
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          getImage(icon,
              height: size ?? 12.w,
              width: size ?? 12.w,
              fit: BoxFit.contain,
              isAssets: true),
          Text(
            text,
            style: TextStyle(
                color: isActive ? Colors.white : Color(0xffFF84A9),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400),
          )
        ],
      ),
    );
  }

  static Widget vipLevel({String text = '會員等級'}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      height: 18.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9.w),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xffFFD875),
                Color(0XFFFF6915),
              ])),
      child: Text(
        text,
        style: TextStyle(
            color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700),
      ),
    );
  }

  static String getPromotionCountDownTime(DateTime now) {
    int seconds =
        48 * 60 * 60 - now.difference(AppGlobal.firstVisitTime).inSeconds;
    int h = seconds ~/ 60 ~/ 60;
    int m = seconds % (60 * 60) ~/ 60;
    int s = seconds % 60;
    if (h > 0 || m > 0 || s > 0) {
      return '优惠倒计时 ' +
          (h > 9 ? h.toString() : '0' + h.toString()) +
          ':' +
          (m > 9 ? m.toString() : '0' + m.toString()) +
          ':' +
          (s > 9 ? s.toString() : '0' + s.toString());
    } else {
      return '';
    }
  }

  static String getExpireTime(String time, {bool isActivity = true}) {
    int curTime = new DateTime.now().millisecondsSinceEpoch;
    int expireTime = DateTime.parse(time).millisecondsSinceEpoch;
    int timeDiff = ((expireTime - curTime) / 1000).ceil();
    if ((timeDiff ~/ 86400).ceil() > 0) {
      return (timeDiff ~/ 86400).toString() + '天';
    } else if ((timeDiff ~/ 3600).ceil() > 0) {
      return (timeDiff ~/ 3600).toString() + '小时';
    } else if ((timeDiff ~/ 60).ceil() > 0) {
      return (timeDiff ~/ 60).toString() + '分钟';
    } else {
      return isActivity ? PPString.hasExpired : PPString.expired;
    }
  }

  static String gvMD5(String data) {
    var content = Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    var text = hex.encode(digest.bytes);
    return text;
  }

  static String getRandomThumb() {
    int random = new Random().nextInt(29);
    return 'assets/images/random/' + (random + 1).toString() + '.jpg';
  }

  static String gvSha256(String data) {
    var content = Utf8Encoder().convert(data);
    var digest = sha256.convert(content);
    var text = hex.encode(digest.bytes);
    return text;
  }

  static getThumb(dynamic data) {
    if (data['thumb'] != null && data['thumb'] != '') {
      return data['thumb'];
    } else if (data['cover_thumb_vertical'] != null &&
        data['cover_thumb_vertical'] != '') {
      return data['cover_thumb_vertical'];
    } else if (data['cover_thumb_horizontal'] != null &&
        data['cover_thumb_horizontal'] != '') {
      return data['cover_thumb_horizontal'];
    } else if (data['cover_zip_vertical'] != null &&
        data['cover_zip_vertical'] != '') {
      return data['cover_zip_vertical'];
    } else if (data['cover_zip_horizontal'] != null &&
        data['cover_zip_horizontal'] != '') {
      return data['cover_zip_horizontal'];
    } else if (data['cover_original_vertical'] != null &&
        data['cover_original_vertical'] != '') {
      return data['cover_original_vertical'];
    } else {
      return data['cover_original_horizontal'];
    }
  }

  static void checkline({Function onSuccess, Function onFailed}) async {
    int _timeout = 30;
    Box box = AppGlobal.appBox;
    List apiLines = box.get('api_lines') ?? [];
    List<dynamic> unChecklines =
        apiLines.length > 0 ? apiLines : AppGlobal.apiLines;
    List<Map> errorLines = [];
    // int errorCount = 0;
    Function doCheck;
    Function reportErrorLines = () async {
      // 上报错误线路&保存服务端推荐线路到本地
      try {
        Response res = await PlatformAwareHttp.post(
            '/api/home/domainCheckReport',
            data: {'list': errorLines});
        CommonUtils.debugPrint("============reportErrorLines============");
        CommonUtils.debugPrint(res.data['data']);
        List<String> serverLines = [];
        List.from(res.data['data']).forEach((l) {
          serverLines.add(l.toString());
        });
        box.put('api_lines', serverLines);
      } catch (err) {}
    };

    Function handleResult = (String line) async {
      if (line != null) {
        AppGlobal.apiBaseURL = line;
        await reportErrorLines();
        onSuccess();
      } else {
        onFailed();
      }
    };

    doCheck = ({String line, bool isPub}) async {
      dynamic result;
      List<InternetAddress> ip4;
      Uri _uri = Uri.parse(line);
      if (!kIsWeb) {
        ip4 = await InternetAddress.lookup(_uri.host,
            type: InternetAddressType.IPv4);
      }
      if (ip4?.toString() == "") {
        result = 'error';
      } else {
        try {
          result = await new Dio().get('$line/api/callback/checkLine');
        } catch (err) {
          result = 'error';
        }
      }
      if (result == 'error' && !isPub) {
        // errorCount++;
        errorLines.add({'url': line});
        // 备用github线路检测逻辑
        // if (errorCount == unChecklines.length) {
        //   checkBackUpLine();
        // }
      } else if (isPub) {
        if (result.toString() == '200') {
          handleResult(line);
        } else {
          onFailed();
        }
      }
      return result;
    };

    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      Future.any(unChecklines.map((line) {
        return doCheck(line: line.toString(), isPub: false).then((value) {
          if (value.toString() == '200') {
            return line;
          } else {
            return Future.delayed(Duration(seconds: _timeout), () {
              return null;
            });
          }
        });
      })).then((line) {
        handleResult(line);
      });
    } else {
      onFailed();
    }
  }
}

class RelativeDateFormat {
  static final num oneMinute = 60000;
  static final num oneHour = 3600000;
  static final num oneDay = 86400000;
  static final num oneWeek = 604800000;

  static final String oneSecondAgo = "秒前";
  static final String oneMinuteAgo = "分钟前";
  static final String oneHourAgo = "小时前";
  static final String oneDayAgo = "天前";
  static final String oneMonthAgo = "月前";
  static final String oneYearAgo = "年前";

//时间转换
  static String format(DateTime date) {
    num delta =
        DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;

    if (delta < 1 * oneMinute) {
      num seconds = toSeconds(delta);
      return (seconds <= 0 ? 1 : seconds).toInt().toString() + oneSecondAgo;
    }
    if (delta < 60 * oneMinute) {
      num minutes = toMinutes(delta);
      return (minutes <= 0 ? 1 : minutes).toInt().toString() + oneMinuteAgo;
    }
    if (delta < 24 * oneHour) {
      num hours = toHours(delta);
      return (hours <= 0 ? 1 : hours).toInt().toString() + oneHourAgo;
    }
    if (delta < 48 * oneHour) {
      return "昨天";
    }
    if (delta < 30 * oneDay) {
      num days = toDays(delta);
      return (days <= 0 ? 1 : days).toInt().toString() + oneDayAgo;
    }
    if (delta < 12 * 4 * oneWeek) {
      num months = toMonths(delta);
      return (months <= 0 ? 1 : months).toInt().toString() + oneMonthAgo;
    } else {
      num years = toYears(delta);
      return (years <= 0 ? 1 : years).toInt().toString() + oneYearAgo;
    }
  }

  static num toSeconds(num date) {
    return date / 1000;
  }

  static num toMinutes(num date) {
    return toSeconds(date) / 60;
  }

  static num toHours(num date) {
    return toMinutes(date) / 60;
  }

  static num toDays(num date) {
    return toHours(date) / 24;
  }

  static num toMonths(num date) {
    return toDays(date) / 30;
  }

  static num toYears(num date) {
    return toMonths(date) / 12;
  }
}
