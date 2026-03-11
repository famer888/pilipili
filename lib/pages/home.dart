import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/pages/anwang.dart';
import 'package:pilipili/pages/yuemei_shequ.dart';
import 'package:pilipili/report/report_utils.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/components/dongman.dart';
import 'package:pilipili/components/manhua.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/pili_ciyuan.dart';
import 'package:pilipili/components/updateModel.dart';
import 'package:pilipili/components/wode.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/model/homedata.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:hive/hive.dart';
import 'package:universal_html/html.dart' as html;
import "package:universal_html/js.dart" as js;
import 'package:visibility_detector/visibility_detector.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  bool showUpdateStatus = false;
  bool showAnnouncementStatus = false;
  bool showActivety = false;
  bool initPage = false;
  List adData = [];
  PageController _controller = PageController();
  List<Map> webTypeList = [
    {'w': 428, 'h': 926, 'r': 3}, // iphone13 pro max
    {'w': 390, 'h': 844, 'r': 3}, // iphone 13 and pro
    {'w': 375, 'h': 812, 'r': 3}, //iphoneX、iphoneXs
    {'w': 414, 'h': 896, 'r': 3}, //iphone Xs Max
    {'w': 414, 'h': 896, 'r': 2} //iphone XR
  ];

  List navBarItem = [
    {
      "keepAlive": false,
      "page": PiliCiyuan(
        pos: 318,
      ),
      "title": "pili次元",
      "activeIcon": 'assets/images/2024/bottomTab/pili_active.png',
      "icon": 'assets/images/2024/bottomTab/pili_inactive.png',
      "asset": true,
      "key": "navigation_pili",
    },
    {
      "keepAlive": false,
      "page": Dongman(
        pos: 319,
      ),
      "title": "动漫",
      "activeIcon": 'assets/images/2024/bottomTab/tv_active.png',
      "icon": 'assets/images/2024/bottomTab/tv_inactive.png',
      "asset": true,
      "key": "navigation_dm",
    },
    {
      "keepAlive": false,
      "page": Manhua(
        pos: 320,
      ),
      "title": "漫画",
      "activeIcon": 'assets/images/2024/bottomTab/comic_active.png',
      "icon": 'assets/images/2024/bottomTab/comic_inactive.png',
      "asset": true,
      "key": "navigation_mh",
    },
    {
      "keepAlive": false,
      "page": AnwangPage(
        pos: 321,
      ),
      "title": "暗網",
      "activeIcon": 'assets/images/2024/bottomTab/hacker_active.png',
      "icon": 'assets/images/2024/bottomTab/hacker_inactive.png',
      "asset": true,
      "key": "navigation_aw",
    },
    {
      "keepAlive": false,
      "page": YuemeiShequ(
        pos: 314,
      ),
      "title": "妹圈",
      "activeIcon": 'assets/images/2024/bottomTab/date_active.png',
      "icon": 'assets/images/2024/bottomTab/date_inactive.png',
      "asset": true,
      "key": "navigation_mq",
    },
    {
      "keepAlive": true,
      "page": Wode(),
      "title": "我的",
      "activeIcon": 'assets/images/2024/bottomTab/mine_active.png',
      "icon": 'assets/images/2024/bottomTab/mine_inactive.png',
      "asset": true,
      "key": "navigation_wd",
    },
  ];
  ValueNotifier<int> selectedKey = ValueNotifier(0);
  bool loading = true;

  getWebType(int h, int w, double r) {
    webTypeList.forEach((item) {
      if (item['h'] == h && item['w'] == w && item['r'] == r) {
        AppGlobal.webBottomHeight = 15.w;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    AppGlobal.apInit = true;
    if (!kIsWeb) {
      _initDownloadStastu();
    }
    fetchBeforeEnterApp();
    if (kIsWeb) {
      int _h = html.window.screen.height;
      int _w = html.window.screen.width;
      double _ratio = html.window.devicePixelRatio;
      getWebType(_h, _w, _ratio);
      // webBottomHeight
    }
    getAdForCoin(pos: 315).then((res) {
      adData = res['data'];
      setState(() {});
    });
  }

  // 初始化下载状态
  Future<void> _initDownloadStastu() async {
    Box box = await Hive.openBox('HiveBox');
    setData(String key, List data) {
      if (data.length > 0) {
        data = data.map((element) {
          element["downloading"] = false;
          element["isWaiting"] = false;
          return element;
        }).toList();
        box.put(key, data);
      }
    }

    List videoTasks = box.get('download_video_tasks') ?? [];
    List comicsTasks = box.get('download_comics_tasks') ?? [];
    setData("download_video_tasks", videoTasks);
    setData("download_comics_tasks", comicsTasks);
  }

  void checkUpdateAnnouncement(VersionMsg version, Config config) {
    // "mstatus": 0,    | 系统公告状态 0 没有 1通知 2禁用
    // "must": "0",     | 更新开关 0 不更新  1 强制更新 2 非强制更新
    // "tips": "",      | 更新描述
    // "message": "",   | 公告描述
    var _versionLocal = AppGlobal.appinfo['version'];
    var targetVersion = version.version.replaceAll('.', '');
    var currentVersion = _versionLocal.replaceAll('.', '');
    // 强制更新 线上版本大于当前版本才更新
    CommonUtils.debugPrint(targetVersion);
    CommonUtils.debugPrint(currentVersion);
    CommonUtils.debugPrint(version.toJson());
    var needUpdate = int.parse(targetVersion) > int.parse(currentVersion);
    AppGlobal.isNewVersion = !needUpdate;
    AppGlobal.officeSite = config.officeSite;
    if (AppGlobal.yyShow == false) return;
    if (version.must == 1 && needUpdate) {
      showUpdate(version.version, version.tips, version.apk,
          must: version.must, showAnnouncementDialog: false, official: config.officeSite);
      return;
    }

    // 非强制更新 无公告 (关闭更新后弹出公告)
    if (version.must == 2 && version.mstatus == 0 && needUpdate) {
      showUpdate(version.version, version.tips, version.apk,
          must: version.must,
          message: version.message,
          showAnnouncementDialog: version.mstatus == 0,
          official: config.officeSite);
      return;
    }

    // 非强制更新 有公告 (关闭更新后弹出公告)
    if (version.must == 2 && version.mstatus == 1 && needUpdate) {
      showUpdate(version.version, version.tips, version.apk,
          must: version.must,
          message: version.message,
          showAnnouncementDialog: version.mstatus == 1,
          official: config.officeSite);
      return;
    }
    // 无更新 有公告
    if (version.mstatus == 1) {
      if (AppGlobal.popAppAds.isNotEmpty) {
        UpdateModel.showCompartmentDialog(
          cancel: () {
            showAnnouncement(version.message);
          },
        );
      } else {
        showAnnouncement(version.message);
      }
    }
  }

  void fetchBeforeEnterApp() {
    initDialog();
    loading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isPwa = kIsWeb && html.window.matchMedia('(display-mode: standalone)').matches;
      if (CommonUtils.isAndroidWeb() && !isPwa) {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.black38,
            builder: (BuildContext context) {
              return Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                    top: ScreenUtil().setWidth(15),
                    left: DefaultStyle.pagePadding,
                    right: DefaultStyle.pagePadding,
                    bottom: ScreenUtil().bottomBarHeight + ScreenUtil().setWidth(15)),
                child: Row(
                  children: [
                    PlatformAwareAssetImage(
                        url: 'assets/images/logo2.png',
                        width: ScreenUtil().setWidth(40),
                        height: ScreenUtil().setWidth(40),
                        filterQuality: FilterQuality.medium),
                    SizedBox(
                      width: ScreenUtil().setWidth(15),
                    ),
                    Expanded(
                        child: Text(
                      '打开浏览器[菜单]，选择[添加至主屏幕]或[添加至桌面]或[安装]，将Pilipili添加至手机桌面，以便迅捷访问APP',
                      style: TextStyle(color: Color(0xff333333), fontSize: ScreenUtil().setSp(14)),
                    ))
                  ],
                ),
              );
            });
      }
    });
    setState(() {});
  }

  // 更新提示
  void showUpdate(String version, String tips, String apkurl,
      {int must, String message, bool showAnnouncementDialog, String official}) {
    if (showUpdateStatus == true) return;
    UpdateModel.showUpdateDialog(backButtonBehavior, gowebsite: () {
      CommonUtils.launchURL(official);
    }, cancel: () {
      if (showAnnouncementDialog) {
        showAnnouncement(message);
        AppGlobal.yyShow = false;
      }
    }, confirm: () {
      AppGlobal.yyShow = false;
      if (kIsWeb) {
        //刷新网页
        CommonUtils.launchURL(Provider.of<HomeConfig>(context, listen: false).config.officeSite);
      } else {
        if (Platform.isAndroid) {
          UpdateModel.androidUpdate(backButtonBehavior, version: version, url: apkurl);
        } else {
          CommonUtils.launchURL(apkurl);
        }
      }
    }, version: "Pilipiliv." + version.toString(), mustupdate: must == 1, text: '$tips');

    showUpdateStatus = true;
    setState(() {});
  }

  // ���告提示
  void showAnnouncement(String message) {
    if (showAnnouncementStatus == true) {
      _addMainScreen();
      return;
    }
    bool isSelf = false;
    String maintainTipsStr = Provider.of<HomeConfig>(context, listen: false).message;
    isSelf = Provider.of<HomeConfig>(context, listen: false).member.channel == "self";
    UpdateModel.showAnnouncementDialog(
      backButtonBehavior,
      context: context,
      cancel: () {
        AppGlobal.yyShow = false;
        _addMainScreen();
      },
      confirm: () {
        AppGlobal.yyShow = false;
        _addMainScreen();
      },
      confirmApp: () {
        // _addMainScreen();
      },
      text: "$maintainTipsStr",
      type: isSelf ? "2" : "1",
    );
    setState(() {
      showAnnouncementStatus = true;
    });
  }

  //加载添加到主屏幕功能
  void _addMainScreen() async {
    if (!kIsWeb) return;
    final bool isInstall = (js.context.callMethod("getInstallValue") as String) == "1";
    final bool isSafari = js.context.callMethod("checkSafari") as bool;
    if (!isSafari && !isInstall) {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setBottomSheetState) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: DefaultStyle.pagePadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(5.w), topLeft: Radius.circular(5.w)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20.w),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 20.w, height: 20.w),
                        Text(
                          "添加PiliPili到主屏幕？[如已添加请忽略]",
                          style: TextStyle(color: Color.fromRGBO(30, 30, 30, 1), fontSize: 14.sp),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.close,
                            size: 20.w,
                            color: Color.fromRGBO(30, 30, 30, 1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.w),
                    CommonUtils.getContentSpan(
                      "如无法正常添加到主屏幕，请下载最新版本的Google浏览器https://www.google.cn/intl/zh-CN/chrome，打开Google浏览器，输入本站网址000，点击右上角的【菜单】然后选择【添加到主屏幕】即可完成WEB版APP"
                          .replaceAll("000", html.window.location.href),
                      style: TextStyle(color: const Color.fromRGBO(245, 28, 88, 1).withOpacity(0.5), fontSize: 12.sp),
                      lightStyle: TextStyle(fontSize: 12.sp, color: const Color.fromRGBO(25, 103, 210, 1)),
                    ),
                    SizedBox(height: 20.w),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        final bool isDeferredNotNull = js.context.callMethod("isDeferredNotNull") as bool;
                        if (isDeferredNotNull) {
                          js.context.callMethod("presentAddToHome");
                        } else {
                          CommonUtils.showText("当前浏览器不支持该功能，请使用Google浏览器添加到主屏幕或24小时后再操作", time: 2);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(245, 28, 88, 1),
                            borderRadius: BorderRadius.all(Radius.circular(3.w))),
                        padding: EdgeInsets.symmetric(horizontal: DefaultStyle.pagePadding),
                        height: 32.w,
                        alignment: Alignment.center,
                        child: Text("添加到主屏幕", style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                      ),
                    ),
                    SizedBox(height: 30.w),
                  ],
                ),
              );
            });
          });
    }
  }

  // 活动弹窗
  void showActivetyDialog(Config config, VersionMsg version) {
    int activeLength = AppGlobal.popAds.length - 1;
    int activeIndex = 0;
    showIndexActive(int index) {
      ReportUtils.adVertising(
          eventType: AdEventType.show,
          advertisingKey: AdType.homePopup,
          advertisingId: AppGlobal.popAds[index]['id'],
          adSlotKey: AppGlobal.popAds[index]['advertise_location_code'],
          adSlotName: AppGlobal.popAds[index]['ad_slot_name'],
          adtype: AppGlobal.popAds[index]['ad_type']);
      UpdateModel.showAvtivetysDialog(backButtonBehavior,
          width: AppGlobal.popAds[index]['img_width'].toDouble(),
          height: AppGlobal.popAds[index]['img_height'].toDouble(),
          url: AppGlobal.popAds[index]['img_url'], cancel: () {
        activeIndex++;
        if (activeIndex <= activeLength) {
          showIndexActive(activeIndex);
        } else {
          checkUpdateAnnouncement(version, config);
                }
        ReportUtils.adVertising(
            eventType: AdEventType.close,
            advertisingKey: AdType.homePopup,
            advertisingId: AppGlobal.popAds[index]['id'],
            adSlotKey: AppGlobal.popAds[index]['advertise_location_code'],
            adSlotName: AppGlobal.popAds[index]['ad_slot_name'],
            adtype: AppGlobal.popAds[index]['ad_type']);
      }, confirm: () {
        ReportUtils.adVertising(
            eventType: AdEventType.click,
            advertisingKey: AdType.homePopup,
            advertisingId: AppGlobal.popAds[index]['id'],
            adSlotKey: AppGlobal.popAds[index]['advertise_location_code'],
            adSlotName: AppGlobal.popAds[index]['ad_slot_name'],
            adtype: AppGlobal.popAds[index]['ad_type']);
        CommonUtils.bannerTopath(context,
            url: AppGlobal.popAds[index]['content'], type: AppGlobal.popAds[index]['type']);
        popAdsChick(AppGlobal.popAds[index]['id'].toString());
        activeIndex++;
        if (activeIndex <= activeLength) {
          showIndexActive(activeIndex);
        } else {
          checkUpdateAnnouncement(version, config);
                }
      });
    }

    showIndexActive(activeIndex);
  }

  initDialog() {
    if (!initPage) {
      initPage = true;
      var version = Provider.of<HomeConfig>(context, listen: false).versionMsg;
      var config = Provider.of<HomeConfig>(context, listen: false).config;

      if (AppGlobal.popAds.isNotEmpty) {
        // title 活动图片地址  content 活动跳转地址 type 跳转类型 1 路由 2 内部webview 3 外部
        showActivetyDialog(config, version);
      } else {
        checkUpdateAnnouncement(version, config);
            }
    }
  }

  adVertising(AdEventType eventType, int index) {
    ReportUtils.adVertising(
        eventType: eventType,
        advertisingKey: AdType.homeFloatBanner,
        advertisingId: adData[index]['id'],
        adSlotKey: adData[index]['advertise_location_code'],
        adSlotName: adData[index]['ad_slot_name'],
        adtype: adData[index]['ad_type']);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: loading
          ? PageStatus.loading(mounted)
          : [
              Positioned.fill(
                  child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  selectedKey.value = index;
                },
                itemCount: navBarItem.length,
                itemBuilder: (context, index) {
                  if (navBarItem[index]['keepAlive']) {
                    return PageViewMixin(
                      child: navBarItem[index]['page'],
                    );
                  } else {
                    return ValueListenableBuilder(
                      valueListenable: selectedKey,
                      builder: (context, _value, child) {
                        return _value == index ? child : PageStatus.loading(mounted);
                      },
                      child: navBarItem[index]['page'],
                    );
                  }
                },
              )),
              Positioned(
                  right: 8.w,
                  bottom: DefaultStyle.bottomnavbarHegiht + ScreenUtil().bottomBarHeight + 15.w,
                  child: adData.isEmpty
                      ? SizedBox()
                      : ValueListenableBuilder(
                          valueListenable: selectedKey,
                          builder: (context, _v, child) {
                            return _v <= 2
                                ? SizedBox(
                                    width: 90.w,
                                    height: 90.w,
                                    child: Swiper(
                                      autoplayDelay: 3000,
                                      autoplay: adData.length > 1,
                                      onIndexChanged: (e) {
                                        // CommonUtils.debugPrint('-------------------$e---------------------');
                                      },
                                      itemBuilder: (BuildContext context, int index) {
                                        return VisibilityDetector(
                                            key: Key(
                                                '${ReportUtils.getAdType(AdType.homeFloatBanner)['key']}_FLOATBANNER_${adData[index]['id']}'),
                                            child: GestureDetector(
                                              onTap: () {
                                                adVertising(AdEventType.click, index);
                                                CommonUtils.bannerTopath(context,
                                                    url: adData[index]['url'], type: adData[index]['type']);
                                              },
                                              child: PlatformAwareNetworkImage(
                                                url: adData[index]['img_url'],
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            onVisibilityChanged: (info) {
                                              final visibleFraction = info.visibleFraction;
                                              if (visibleFraction > 0.7) {
                                                adVertising(AdEventType.show, index);
                                              }
                                            });
                                      },
                                      itemCount: adData.length,
                                    ),
                                  )
                                : SizedBox();
                          })),
              Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(255, 91, 140, 0.4), offset: Offset(5, 6), blurRadius: 10, spreadRadius: 5)
                  ]),
                  child: ValueListenableBuilder(
                    valueListenable: selectedKey,
                    builder: (context, _value, child) {
                      return Container(
                        width: 1.sw,
                        height: DefaultStyle.bottomnavbarHegiht + ScreenUtil().bottomBarHeight,
                        padding: EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: navBarItem
                              .asMap()
                              .keys
                              .map((key) => GestureDetector(
                                    onTap: () {
                                      _controller.jumpToPage(key);
                                      ReportUtils.onNavChange(navBarItem[key]['key'], navBarItem[key]['title']);
                                      if (key == 3) {
                                        CommonUtils.updateSystemNotice(context);
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        !loading
                                            ? getImage(
                                                _value == key ? navBarItem[key]['activeIcon'] : navBarItem[key]['icon'],
                                                isAssets: navBarItem[key]['asset'] != null,
                                                width: 25.w,
                                                height: 25.w,
                                                fit: BoxFit.fitWidth,
                                                filterQuality: FilterQuality.high)
                                            : const SizedBox(),
                                        Text(
                                          navBarItem[key]['title'],
                                          style: _value == key ? DefaultStyle.bottomNavStyle : DefaultStyle.lgray12,
                                        )
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.center,
                                    ),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
    );
  }
}
