import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:isolated_worker/worker_delegator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/utils/http.dart';
import 'package:convert/convert.dart';
import 'package:pilipili/utils/logUtil.dart';
import 'package:universal_html/html.dart' as html;

class CommonUtils {
  static bool isAndroidWeb() {
    return kIsWeb &&
        (html.window.navigator.userAgent.indexOf('Android') > -1 ||
            html.window.navigator.userAgent.indexOf('Linux') > -1);
  }

  static showText(String text, {int time}) {
    return BotToast.showText(
        text: text,
        textStyle: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 1),
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
      tips = formatNum(newvalue, 2) + "万";
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
      if (currentHash.lastIndexOf('/') == currentHash.length - 1) {
        return '$currentHash$value';
      } else {
        return '$currentHash/$value';
      }
    } else {
      var location = '${AppGlobal.appRouter.location}/$value';
      if (value == null) return AppGlobal.appRouter.location;
      if (location.contains('//')) {
        var current = location.replaceAll('//', '/');
        return current;
      } else {
        return location;
      }
    }
  }

  static void debugPrint(value) {
    const bool inProduction = const bool.fromEnvironment("dart.vm.product");
    if (!inProduction) {
      LogUtil.d(value);
    }
  }

  static Map<String, int> retryCountMap = {};
  static List<List> tasks = [];
  static List<bool> wdsRuningStatuses = List.generate(AppGlobal.decryptProcessLimit, (index) => false);
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
                if (args[0].toString().indexOf('assets/yy/') != -1) {
                  AppGlobal.imageAssetBox.put(args[0], decrypted);
                } else {
                  AppGlobal.imageCacheBox.put(args[0], decrypted);
                }
              }
            }
          } catch (err) {
            CommonUtils.debugPrint('图片请求失败${args[0]}');
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
        ? '${AppGlobal.bannerImgBase}new/$url'.replaceAll('images/', 'yy/')
        : url;

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

  static String getPromotionCountDownTime(DateTime now) {
    int seconds =
        48 * 60 * 60 - now.difference(AppGlobal.firstVisitTime).inSeconds;
    int h = seconds ~/ 60 ~/ 60;
    int m = seconds % (60 * 60) ~/ 60;
    int s = seconds % 60;
    if (h > 0 || m > 0 || s > 0) {
      return '优惠倒计时 ${h > 9 ? h : '0$h'}:${m > 9 ? m : '0$m'}:${s > 9 ? s : '0$s'}';
    } else {
      return '';
    }
  }

  static String getExpireTime(String time, {bool isActivity = true}) {
    int curTime = new DateTime.now().millisecondsSinceEpoch;
    int expireTime = DateTime.parse(time).millisecondsSinceEpoch;
    int timeDiff = ((expireTime - curTime) / 1000).ceil();
    if ((timeDiff ~/ 86400).ceil() > 0) {
      return '${timeDiff ~/ 86400}天';
    } else if ((timeDiff ~/ 3600).ceil() > 0) {
      return '${timeDiff ~/ 3600}小时';
    } else if ((timeDiff ~/ 60).ceil() > 0) {
      return '${timeDiff ~/ 60}分钟';
    } else {
      return isActivity ? '已截止' : '已过期';
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
    return 'assets/images/random/${random + 1}.jpg';
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
    List<String> unChecklines = box.get('api_lines') ?? AppGlobal.apiLines;
    List<Map> errorLines = [];
    // int errorCount = 0;
    Function doCheck;
    Function reportErrorLines = () async {
      // 上报错误线路&保存服务端推荐线路到本地
      dynamic res = await PlatformAwareHttp.post('/api/home/domainCheckReport',
          data: {'list': errorLines});
      // List<String> serverLines = [];
      // res.data.forEach((l) {
      //   serverLines.add(l.toString());
      // });
      // box.put('api_lines', serverLines);
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
        return doCheck(line: line, isPub: false).then((value) {
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
