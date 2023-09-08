import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/components/yuemei.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_asset_path.dart';
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
  List<Map> webTypeList = [
    {'w': 428, 'h': 926, 'r': 3}, // iphone13 pro max
    {'w': 390, 'h': 844, 'r': 3}, // iphone 13 and pro
    {'w': 375, 'h': 812, 'r': 3}, //iphoneX、iphoneXs
    {'w': 414, 'h': 896, 'r': 3}, //iphone Xs Max
    {'w': 414, 'h': 896, 'r': 2} //iphone XR
  ];
  List navBarItem = [
    {
      "title": "pili次元",
      "activeIcon": PPAssetsPath.piliActive,
      "icon": PPAssetsPath.pili,
    },
    {
      "title": "动漫",
      "activeIcon": PPAssetsPath.cartoonActive,
      "icon": PPAssetsPath.cartoon,
    },
    {
      "title": "漫画",
      "activeIcon": PPAssetsPath.comicsActive,
      "icon": PPAssetsPath.comics,
    },
    {
      "title": "约妹",
      "activeIcon": PPAssetsPath.yuemeiActive,
      "icon": PPAssetsPath.yuemei,
    },
    {
      "title": "我的",
      "activeIcon": PPAssetsPath.userActive,
      "icon": PPAssetsPath.user
    },
  ];
  int selectedKey = 0;
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

    List video_tasks = box.get('download_video_tasks') ?? [];
    List comics_tasks = box.get('download_comics_tasks') ?? [];
    setData("download_video_tasks", video_tasks);
    setData("download_comics_tasks", comics_tasks);
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
          must: version.must,
          showAnnouncementDialog: false,
          official: config.officeSite);
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
      showAnnouncement(version.message);
    }
  }

  void fetchBeforeEnterApp() {
    initDialog();
    loading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isPwa = kIsWeb &&
          html.window.matchMedia('(display-mode: standalone)').matches;
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
                    bottom: ScreenUtil().bottomBarHeight +
                        ScreenUtil().setWidth(15)),
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
                      style: TextStyle(
                          color: Color(0xff333333),
                          fontSize: ScreenUtil().setSp(14)),
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
      {int must,
      String message,
      bool showAnnouncementDialog,
      String official}) {
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
        CommonUtils.launchURL(
            Provider.of<HomeConfig>(context, listen: false).config.officeSite);
      } else {
        if (Platform.isAndroid) {
          UpdateModel.androidUpdate(backButtonBehavior,
              version: version, url: apkurl);
        } else {
          CommonUtils.launchURL(apkurl);
        }
      }
    },
        version: "Pilipiliv." + version.toString(),
        mustupdate: must == 1,
        text: '$tips');

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
    isSelf = Provider.of<HomeConfig>(context, listen: false).member.channel ==
        "self";
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
      text: "$message",
      type: isSelf ? "2" : "1",
    );
    setState(() {
      showAnnouncementStatus = true;
    });
  }


  //加载添加到主屏幕功能
  void _addMainScreen() async {
    if (!kIsWeb) return;
    final bool isInstall =
        (js.context.callMethod("getInstallValue") as String) == "1";
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
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.w),
                      topLeft: Radius.circular(5.w)),
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
                      lightStyle: TextStyle(
                          fontSize: 12.sp,
                          color: const Color.fromRGBO(25, 103, 210, 1)),
                    ),
                    SizedBox(height: 20.w),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        final bool isDeferredNotNull =
                            js.context.callMethod("isDeferredNotNull") as bool;
                        if (isDeferredNotNull) {
                          js.context.callMethod("presentAddToHome");
                        } else {
                          CommonUtils.showText("当前浏览器不支持该功能，请使用Google浏览器添加到主屏幕或24小时后再操作", time: 2);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(245, 28, 88, 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(3.w))),
                        padding:
                            EdgeInsets.symmetric(horizontal: DefaultStyle.pagePadding),
                        height: 32.w,
                        alignment: Alignment.center,
                        child: Text("添加到主屏幕",
                            style: TextStyle(color: Colors.white, fontSize: 13.sp)),
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
      UpdateModel.showAvtivetysDialog(backButtonBehavior,
          width: AppGlobal.popAds[index]['img_width'].toDouble(),
          height: AppGlobal.popAds[index]['img_height'].toDouble(),
          url: AppGlobal.popAds[index]['img_url'], cancel: () {
        activeIndex++;
        if (activeIndex <= activeLength) {
          showIndexActive(activeIndex);
        } else {
          if (version != null) {
            checkUpdateAnnouncement(version, config);
          }
        }
      }, confirm: () {
        _onTapSwiper(AppGlobal.popAds[index]['type'],
            AppGlobal.popAds[index]['content']);
        popAdsChick(AppGlobal.popAds[index]['id'].toString());
        activeIndex++;
        if (activeIndex <= activeLength) {
          showIndexActive(activeIndex);
        } else {
          if (version != null) {
            checkUpdateAnnouncement(version, config);
          }
        }
      });
    }

    showIndexActive(activeIndex);
  }

  _onTapSwiper(String type, String _adsUrl) {
    var members = Provider.of<HomeConfig>(context, listen: false).member;
    var aff = members.aff;
    var piliid = members.uuid;
    var types = type;
    if (['', null, false].contains(_adsUrl)) {
      BotToast.showText(text: '未配置跳转链接', align: Alignment(0, 0));
      return;
    }
    if (types == '1') {
      // 内部路由
      String linkUrl = _adsUrl;
      List urlList = linkUrl.split('?');
      Map<String, dynamic> pramas = {};
      if (urlList.length > 1) {
        urlList[1].split("&").forEach((item) {
          List stringText = item.split('=');
          pramas[stringText[0]] = stringText.length > 1 ? stringText[1] : null;
        });
      }
      Map<String, dynamic> pramasObj = {};
      if (pramas['pramaskey'] != null) {
        pramasObj[pramas['pramaskey']] = pramas;
      } else {
        pramasObj = pramas;
      }
      context.push(urlList[0], extra: pramasObj);
    } else if (types == "3") {
      CommonUtils.launchURL("$_adsUrl?aff=$aff&piliid=$piliid");
    } else if (types == "2") {
      CommonUtils.launchURL("$_adsUrl");
    }
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
        if (version != null) {
          checkUpdateAnnouncement(version, config);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: loading
          ? PageStatus.loading(mounted)
          : [
              Positioned(
                  left: -selectedKey * 1.sw,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 1.sw,
                    height: 1.sh,
                    child: PiliCiyuan(
                      isShow: selectedKey == 0,
                    ),
                  )),
              Positioned(
                  left: (-selectedKey + 1) * 1.sw,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 1.sw,
                    height: 1.sh,
                    child: Dongman(
                      isShow: selectedKey == 1,
                    ),
                  )),
              Positioned(
                  left: (-selectedKey + 2) * 1.sw,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                      width: 1.sw,
                      height: 1.sh,
                      child: Manhua(
                        isShow: selectedKey == 2,
                      ))),
              Positioned(
                  left: (-selectedKey + 3) * 1.sw,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 1.sw,
                    height: 1.sh,
                    child: YuemeiPage(
                      isShow: selectedKey == 3,
                    ),
                  )),
              Positioned(
                  left: (-selectedKey + 4) * 1.sw,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 1.sw,
                    height: 1.sh,
                    child: Wode(
                      isShow: selectedKey == 4,
                    ),
                  )),
              Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(255, 91, 140, 0.4),
                        offset: Offset(5, 6),
                        blurRadius: 10,
                        spreadRadius: 5)
                  ]),
                  child: Container(
                    width: 1.sw,
                    height: DefaultStyle.bottomnavbarHegiht +
                        ScreenUtil().bottomBarHeight,
                    padding:
                        EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: navBarItem
                          .asMap()
                          .keys
                          .map((key) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedKey = key;
                                  });

                                  if (key == 3) {
                                    CommonUtils.updateSystemNotice(context);
                                  }
                                },
                                child: Column(
                                  children: [
                                    !loading
                                        ? getImage(
                                            selectedKey == key
                                                ? navBarItem[key]['activeIcon']
                                                : navBarItem[key]['icon'],
                                            width: 25.w,
                                            height: 25.w,
                                            fit: BoxFit.fitWidth,
                                            filterQuality: FilterQuality.high)
                                        : const SizedBox(),
                                    Text(
                                      navBarItem[key]['title'],
                                      style: selectedKey == key
                                          ? DefaultStyle.bottomNavStyle
                                          : DefaultStyle.lgray12,
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
    );
  }
}
