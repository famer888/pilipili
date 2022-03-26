/*
 * @Author: Tom
 * @Date: 2021-12-29 16:03:08
 * @LastEditTime: 2021-12-29 16:03:28
 * @LastEditors: Tom
 * @Description: 
 * @FilePath: /flutter2021/lib/global.dart
 */
// 应用级全局变量
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import 'model/element.dart';

class AppGlobal {
  // 全局路由实例
  static String comicThumb; //避免传参，用来记录漫画封面
  static Map appinfo;
  static String apiBaseURL = "";
  static int smallVideoLimit = 18;
  static List<String> apiLines = [
    'https://apiv2.hichatapi.me',
    'https://apiv2.hichatapi.net',
    'https://apiv2.hichatapi.org'
  ];
  static Widget bannerWidget;
  static String uploadImgUrl;
  static String uploadImgKey;
  static String bannerImgBase;
  static String apiToken;
  static int visibilityDetectorIndex = 0;
  static bool yyShow = true;
  static bool showActivity = true;
  static Box appBox;
  static Box imageCacheBox;
  static Box imageAssetBox;
  static Box videoWatchRecordBox;
  static Box manhuaWatchRecordBox;
  static Box bookWatchRecordBox;
  static Box smallVideoWatchRecordBox;
  static List helpList = [];
  static int isSetPassword = 0;
  static int vipLevel = 0;
  static BuildContext appContext;
  static bool apInit = false;
  static bool routerReplace = false;
  static bool videoPageIsActive = true;
  static Map<String, dynamic> currentDetailRouteExtra;
  static Map<String, dynamic> currentReaderRouteExtra;
  static GoRouter appRouter;
  static String m3u8_encrypt;
  static bool isNewVersion = true;
  static String officeSite = '';
  static DateTime firstVisitTime;
  static List<LinkModel> navList = [];
  static dynamic currenClickData;
  static int initVipTab = 0;
  static int decryptProcessLimit = 20;
  static bool shouApp = false;
  static Map xianmianPramas; //限免页面参数
  static Map seconedPagePramas; //页面参数
  static String smallVideoApi;
  static Map smallVideoPramas;
}
