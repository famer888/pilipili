import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isolated_worker/worker_delegator.dart';
import 'package:pilipili/store/globle_value.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/routers.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/crypto.dart';

void main() async {
  // 初始化数据库，必须放在最前面
  await Hive.initFlutter();
  AppGlobal.appBox = await Hive.openBox('HiveBox'); // 用于存储一些简单的键值对
  // 强制竖屏
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  AppGlobal.imageCacheBox = await Hive.openBox('HiveBox_ImageCache'); //图片缓存
  AppGlobal.imageAssetBox = await Hive.openBox('HiveBox_ImageAsset'); //UI图片缓存
  AppGlobal.videoWatchRecordBox =
      await Hive.openBox('HiveBox_VideoWatchRecord');
  AppGlobal.manhuaWatchRecordBox =
      await Hive.openBox('HiveBox_ManhuaWatchRecord');
  AppGlobal.bookWatchRecordBox = await Hive.openBox('HiveBox_BookWatchRecord');
  AppGlobal.smallVideoWatchRecordBox =
      await Hive.openBox('HiveBox_smallVideoWatchRecord');
  // 注册图片加载线程
  DefaultDelegate<dynamic, dynamic> fooDelegate =
      DefaultDelegate(callback: PlatformAwareCrypto.decryptImage);
  JsDelegate fooJsDelegate = JsDelegate(callback: 'decryptImage');
  List<WorkerDelegate<dynamic, dynamic>> wds = List.generate(
      AppGlobal.decryptProcessLimit,
      (index) => WorkerDelegate(
            key: 'decryptImage' + index.toString(),
            defaultDelegate: fooDelegate,
            jsDelegate: fooJsDelegate,
          ));
  WorkerDelegator().addAllDelegates(wds);
  await WorkerDelegator().importScripts(
      const <String>['js/aware.js?v=2', 'js/crypto-js.min.js?v=3']);

  // 禁用图片缓存
  PaintingBinding.instance.imageCache.maximumSize = 0;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 0;

  // 搭建m3u8代理服务器
  // if (!kIsWeb) {
  //   var handler =
  //       const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);
  //   var server = await shelf_io.serve(handler, 'localhost', 8888);
  //   server.autoCompress = true;
  //   CommonUtils.debugPrint(
  //       'Serving at http://${server.address.host}:${server.port}');
  // }
  // 初始化全局路由
  // 初始化APP基础信息
  AppGlobal.apiToken = AppGlobal.appBox.get('apiToken') ?? "";
  AppGlobal.firstVisitTime =
      AppGlobal.appBox.get('firstVisitTime') ?? DateTime.now();
  AppGlobal.appBox.put('firstVisitTime', DateTime.now());
  AppGlobal.appinfo = {
    "oauth_id": AppGlobal.appBox.get('oauth_id') ??
        CommonUtils.randomId(16).toString() +
            '_' +
            DateTime.now().millisecondsSinceEpoch.toString().toString(),
    "bundleId": "com.pwa.pilipili",
    "version": "2.0.2",
    "oauth_type": CommonUtils.isAndroidWeb() ? PPString.aWeb : PPString.web,
    "language": 'zh',
    "via": 'pwa',
  };
  if (!kIsWeb) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      AppGlobal.appinfo = {
        "oauth_id": androidInfo.androidId,
        "bundleId": packageInfo.packageName,
        "version": packageInfo.version,
        "oauth_type": "android",
      };
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      AppGlobal.appinfo = {
        "oauth_id": iosInfo.identifierForVendor,
        "bundleId": packageInfo.packageName,
        "version": "2.0.2",
        "oauth_type": "ios",
      };
    }
  } else {
    AppGlobal.appBox.put('oauth_id', AppGlobal.appinfo['oauth_id']);
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HomeConfig()),
      ChangeNotifierProvider(create: (_) => GlobleValue())
    ],
    child: pilipili(),
  ));
}

final _router = AppGlobal.appRouter = Routes.init();

class pilipili extends StatefulWidget {
  pilipili({Key key}) : super(key: key);
  @override
  _pilipiliState createState() => _pilipiliState();
}

class _pilipiliState extends State<pilipili> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return ScreenUtilInit(
      designSize: Size(375, 667),
      builder: () => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: 'pilipili',
        builder: (context, widget) {
          widget = botToastBuilder(context, widget);
          widget = MediaQuery(
            //设置文字大小不随系统设置改变
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: widget,
          );
          return widget;
        },
        // home: Welcome(),
        // navigatorObservers: [BotToastNavigatorObserver()],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: Color(0xfffff4f9)),
      ),
    );
  }
}
