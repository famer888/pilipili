import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/model/homedata.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/crypto.dart';
import 'package:universal_html/html.dart' as html;
import 'package:video_player/video_player.dart';
import 'package:pilipili/report/video_analytics_tracker.dart';

class AppEventReport {
  AppEventReport._();
  static final AppEventReport instance = AppEventReport._();

  static int reposrtLength = 1;
  static String apiPath = '';
  List reportedAdIds = [];
  ReportConfig reportConfig; //上报配置
  /// 事件缓存（批量）
  List<Map<String, dynamic>> eventList = [];

  /// 满多少条触发上报
  int eventLength = 10;

  bool isProd = true; //是否正式服
  VideoAnalyticsTracker _tracker;
  Map videoInfo; //视频信息
  Dio _reportDio;
  bool isVip = false;
  bool isInlit = false;

  String channel = ''; //渠道码
  String appId = ''; //应用ID
  String uid = ''; //用户ID
  String sid = ''; //会话id
  int clientTs = 0; //10位时间戳
  String device = ''; //设备类型：Android, iOS, PC
  String deviceId = ''; //设备id
  String userAgent = ''; //User-Agent信息（Web广告时上报，原生可为空）
  String deviceBrand = ''; //设备品牌
  String deviceModel = ''; //设备型号

  static String detectWebDeviceLabel() {
    if (!kIsWeb) {
      return 'Android';
    }
    switch (detectWebDevice()) {
      case WebDeviceType.android:
        return 'Android';
      case WebDeviceType.ios:
        return 'IOS';
      case WebDeviceType.pc:
        return 'PC';
      case WebDeviceType.other:
      default:
        return '';
    }
  }

  //-----------------视频相关操作---start------------------
  initVideoInfo({
    String id,
    String title,
    String typeId,
    String typeName,
    String tagKey,
    String tagName,
  }) {
    videoInfo = {
      'video_id': id,
      'video_title': title,
      'video_type_id': typeId,
      'video_type_name': typeName,
      'video_tag_key': tagKey,
      'video_tag_name': tagName,
    };
  }

  videoControllerInit(VideoPlayerController c) {
    _tracker?.dispose();
    if (videoInfo == null || videoInfo.isEmpty) return;
    _tracker = VideoAnalyticsTracker(
      controller: c,
    )..init();
  }

  videoDispose() {
    videoInfo = {};
    _tracker?.dispose();
  }

  videoShare() {
    _tracker?.trackShare();
  }

  //-----------------视频相关操作---end------------------

  Future<void> init(
      {String channelStr, //渠道码
      String appIdStr, //应用id
      String uidStr, //用户id
      String sidStr, //用户uuid
      bool vip, //用户是否是会员
      String api, //api地址（prod 时传批量上报路径）
      ReportConfig config}) async {
    if (isInlit) return;
    isInlit = true;
    reportConfig = config;
    channel = channelStr;
    uid = uidStr;
    apiPath = api;
    appId = appIdStr;
    sid = sidStr;
    deviceId = sid;
    isVip = vip;

    if (kIsWeb) {
      userAgent = html.window.navigator.userAgent;
    } else {
      final plugin = DeviceInfoPlugin();
      final info = await plugin.androidInfo;
      deviceBrand = info.brand ?? '';
      deviceModel = info.model ?? '';
    }

    device = detectWebDeviceLabel();

    _reportDio = Dio(
      BaseOptions(
        connectTimeout: 60 * 1000,
        receiveTimeout: 300 * 1000,
        validateStatus: (status) {
          return status != null && status >= 200 && status < 300;
        },
        // 批量接口要求 application/json
        contentType: Headers.jsonContentType,
      ),
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            if (options.data is List) {
              String traceId = AppGlobal.appBox?.get('trace_id') ?? "";
              final List list = options.data as List;

              final List<Map<String, dynamic>> finalBatch = [];

              for (int i = 0; i < list.length; i++) {
                Map<String, dynamic> ev = Map<String, dynamic>.from(list[i]);
                final String eventName = ev['event'] ?? '';
                final int ts = ev['client_ts'] ?? 0;
                Map<String, dynamic> base = {
                  'device_id': AppGlobal.appinfo['device_id'],
                  'trace_id': traceId,
                  'event': eventName,
                  'channel': channel,
                  'sid': sid,
                  'uid': uid,
                  'app_id': appId,
                  'client_ts': ts,
                  'device': device,
                  'user_agent': userAgent,
                  'device_brand': deviceBrand,
                  'device_model': deviceModel,
                };

                // payload 放到字段里
                if (ev.containsKey('payload')) {
                  base['payload'] = ev['payload'];
                }

                final List<String> md5List = [];
                base.forEach((key, value) {
                  final v = value?.toString() ?? '';
                  final valueMd5 = CommonUtils.gvMD5(v);
                  md5List.add(valueMd5);
                });
                final concat = md5List.join('');
                final eventId = CommonUtils.gvMD5(concat);
                base['event_id'] = eventId;
                finalBatch.add(base);
              }
              CommonUtils.debugPrint('批量上报数据: $finalBatch');
              options.data = finalBatch;
            }

            return handler.next(options);
          },
          onResponse: (response, handler) async {
            return handler.next(response);
          },
          onError: (DioError e, handler) async {
            CommonUtils.debugPrint(e);
            return handler.next(e);
          },
        ),
      );
    if (reportConfig.isEncryption == 1) {
      final secretValue =
          PlatformAwareCrypto.encryptSecret('${reportConfig.authenticationKey}_${reportConfig.authenticationTime}');
      _reportDio.options.headers = {'Content-Type': 'application/x-www-form-urlencoded', 'Cf-Ray-Xf': secretValue};

      _reportDio.interceptors.add(
        InterceptorsWrapper(onRequest: (options, handler) {
          if (options.data != null) {
            final dynamic data = options.data;
            print('上报 加密前 参数 = ${options.data}');
            options.data = PlatformAwareCrypto.encryptReportParams(data,
                keyString: reportConfig.encryptionKey,
                ivString: reportConfig.encryptionIv,
                signKey: reportConfig.signKey);
          }
          handler.next(options);
        }),
      );
    }
  }

  /// 事件上报
  void track(String event, Map data) {
    if (_reportDio == null) return;

    CommonUtils.debugPrint("上报地址: $apiPath");
    final int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    eventList.add({
      'event': event,
      'payload': data,
      'client_ts': ts,
    });

    if (eventList.length >= eventLength) {
      final List<Map<String, dynamic>> batch = List<Map<String, dynamic>>.from(eventList);
      eventList.clear();

      _reportDio
          .post(
        apiPath,
        data: batch,
      )
          .then(
        (res) {
          CommonUtils.debugPrint('批量上报成功: ${res.data}');
        },
        onError: (e, stack) {
          CommonUtils.debugPrint('批量上报失败: $e');

          // 出错了把数据塞回去，避免丢数据
          eventList.insertAll(0, batch);
        },
      );
    }
  }
}

enum WebDeviceType { android, ios, pc, other }

WebDeviceType detectWebDevice() {
  final nav = html.window.navigator;

  try {
    final dynamic uaData = (nav as dynamic).userAgentData;
    final String platform = (uaData?.platform as String)?.toLowerCase() ?? '';
    final bool isMobile = uaData?.mobile == true;

    if (platform.isNotEmpty) {
      if (platform.contains('android')) return WebDeviceType.android;
      if (platform.contains('ios') || platform.contains('iphone') || platform.contains('ipad')) {
        return WebDeviceType.ios;
      }
      if (platform.contains('mac') ||
          platform.contains('win') ||
          platform.contains('linux') ||
          platform.contains('chrome os')) {
        return WebDeviceType.pc;
      }
    }

    if (isMobile) {
      final ua = (nav.userAgent ?? '').toLowerCase();
      if (ua.contains('android')) return WebDeviceType.android;
      if (ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod')) {
        return WebDeviceType.ios;
      }
    }
  } catch (_) {}

  final ua = (nav.userAgent ?? '').toLowerCase();
  final plat = (nav.platform ?? '').toLowerCase();
  final isIpadOS = plat == 'macintel' && (nav.maxTouchPoints ?? 0) > 1;

  final bool uaLikeAndroid =
      ua.contains('android') && !ua.contains('windows') && !ua.contains('macintosh') && !ua.contains('cros');

  if (uaLikeAndroid) return WebDeviceType.android;

  if (ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod') || isIpadOS) {
    return WebDeviceType.ios;
  }

  return WebDeviceType.pc;
}
