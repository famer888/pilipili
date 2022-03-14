import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/utils/api.dart';
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
  List navBarItem = [
    {
      "title": "pili次元",
      "activeIcon": "assets/images/bottomTab/pili_active.png",
      "icon": "assets/images/bottomTab/pili.png",
    },
    {
      "title": "动漫",
      "activeIcon": "assets/images/bottomTab/cartoon_active.png",
      "icon": "assets/images/bottomTab/cartoon.png",
    },
    {
      "title": "漫画",
      "activeIcon": "assets/images/bottomTab/comics_active.png",
      "icon": "assets/images/bottomTab/comics.png",
    },
    {
      "title": "我的",
      "activeIcon": "assets/images/bottomTab/user_active.png",
      "icon": "assets/images/bottomTab/user.png",
    },
  ];
  int selectedKey = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    AppGlobal.apInit = true;
    if (!kIsWeb) {
      // _initDownloadStastu();
    }
    fetchBeforeEnterApp();
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
    List novel_tasks = box.get('download_novel_tasks') ?? [];
    setData("download_video_tasks", video_tasks);
    setData("download_comics_tasks", comics_tasks);
    setData("download_novel_tasks", novel_tasks);
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
    var needUpdate =
        true; //int.parse(targetVersion) > int.parse(currentVersion);
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

  void fetchBeforeEnterApp() async {
    await getHomeConfig(context).then((res) {
      if (res?.data?.ads == null || res?.data?.ads?.imgUrl == null) {
        AppGlobal.appBox.delete('ads');
      } else {
        dynamic ads = AppGlobal.appBox.get('ads');
        if (ads == null ||
            ads['oimg'] == null ||
            ads['oimg'] != res?.data?.ads?.imgUrl) {
          Timer(Duration(minutes: 1), () {
            CommonUtils.getRealImage(
                url: res?.data?.ads?.imgUrl,
                setUrl: (urllink) {
                  AppGlobal.appBox.put('ads', {
                    'oimg': res?.data?.ads?.imgUrl,
                    'image': urllink,
                    'url': res.data.ads.url
                  });
                  CommonUtils.debugPrint('广告加载完成');
                });
          });
        }
      }
    });
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
                    Image.asset(
                      'assets/pengke/logo2.png',
                      width: ScreenUtil().setWidth(40),
                      height: ScreenUtil().setWidth(40),
                    ),
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
    }, version: "Pilipiliv.$version", mustupdate: must == 1, text: '$tips');

    showUpdateStatus = true;
    setState(() {});
  }

  // 公告提示
  void showAnnouncement(String message) {
    if (showAnnouncementStatus == true) return;
    bool isSelf = false;
    isSelf = Provider.of<HomeConfig>(context, listen: false).member.channel ==
        "self";
    UpdateModel.showAnnouncementDialog(
      backButtonBehavior,
      context: context,
      cancel: () {
        AppGlobal.yyShow = false;
      },
      confirm: () {
        AppGlobal.yyShow = false;
      },
      confirmApp: () {},
      text: "$message",
      type: isSelf ? "2" : "1",
    );
    setState(() {
      showAnnouncementStatus = true;
    });
  }

  // 活动弹窗
  void showActivetyDialog(
      String content, String type, String title, double height, double width) {
    if (showActivety == true) return;
    if (AppGlobal.showActivity == false) return;
    UpdateModel.showAvtivetysDialog(backButtonBehavior, url: title, cancel: () {
      AppGlobal.showActivity = false;
    }, confirm: () {
      AppGlobal.showActivity = false;
      _onTapSwiper(type, content);
    }, height: height, width: width);
    setState(() {
      showActivety = true;
    });
  }

  _onTapSwiper(String type, String _adsUrl) {
    var members = Provider.of<HomeConfig>(context, listen: false).member;
    var aff = members.aff;
    var yyid = members.uuid;
    var types = type;
    if (['', null, false].contains(_adsUrl)) {
      BotToast.showText(text: '未配置跳转链接', align: Alignment(0, 0));
      return;
    }

    switch (types) {
      case "1":
        // 内部路由
        String linkUrl = _adsUrl;
        List urlList = linkUrl.split('?');
        Map<String, dynamic> pramas = {};
        if (urlList.length > 1) {
          urlList[1].split("&").forEach((item) {
            List stringText = item.split('=');
            pramas[stringText[0]] =
                stringText.length > 1 ? stringText[1] : null;
          });
        }
        Map<String, dynamic> pramasObj = {};
        if (pramas['pramaskey'] != null) {
          pramasObj[pramas['pramaskey']] = pramas;
        } else {
          pramasObj = pramas;
        }
        context.push(urlList[0], extra: pramasObj);
        break;
      case "3":
        // 外部浏览器
        CommonUtils.launchURL("$_adsUrl?aff=$aff&yyid=$yyid");
        break;
      case "2":
        // 外部浏览器
        CommonUtils.launchURL("$_adsUrl");
        break;
      default:
    }
  }

  initDialog() {
    if (!initPage) {
      initPage = true;
      if (Provider.of<HomeConfig>(context, listen: false).versionMsg != null) {
        var version =
            Provider.of<HomeConfig>(context, listen: false).versionMsg;
        var config = Provider.of<HomeConfig>(context, listen: false).config;
        checkUpdateAnnouncement(version, config);
      }
      if (Provider.of<HomeConfig>(context, listen: false).notice != null ??
          true) {
        var notice = Provider.of<HomeConfig>(context, listen: false).notice;
        // title 活动图片地址  content 活动跳转地址 type 跳转类型 1 路由 2 内部webview 3 外部
        showActivetyDialog(notice.content, notice.type, notice.imgUrl,
            notice.imgHeight, notice.imgWidth);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Column(
            children: [
              Expanded(
                  child: Stack(
                children: loading
                    ? [PageStatus.loading(mounted)]
                    : [
                        Positioned(
                            left: -selectedKey * ScreenUtil().screenWidth,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: ScreenUtil().screenWidth,
                              height: double.infinity,
                              child: PiliCiyuan(
                                isShow: selectedKey == 0,
                              ),
                            )),
                        Positioned(
                            left: (-selectedKey + 1) * ScreenUtil().screenWidth,
                            top: 0,
                            bottom: 0,
                            child: Container(
                                width: ScreenUtil().screenWidth,
                                height: double.infinity,
                                child: Dongman(
                                  isShow: selectedKey == 1,
                                ))),
                        Positioned(
                            left: (-selectedKey + 2) * ScreenUtil().screenWidth,
                            top: 0,
                            bottom: 0,
                            child: Container(
                                width: ScreenUtil().screenWidth,
                                height: double.infinity,
                                child: Manhua(
                                  isShow: selectedKey == 2,
                                ))),
                        Positioned(
                            left: (-selectedKey + 3) * ScreenUtil().screenWidth,
                            top: 0,
                            bottom: 0,
                            child: Container(
                                width: ScreenUtil().screenWidth,
                                height: double.infinity,
                                child: Wode(
                                  isShow: selectedKey == 3,
                                ))),
                        Positioned(
                          right: 0,
                          left: 0,
                          bottom: 0,
                          child: Container(
                            decoration:
                                BoxDecoration(color: Colors.white, boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(255, 91, 140, 0.4),
                                  offset: Offset(5, 6),
                                  blurRadius: 10,
                                  spreadRadius: 5)
                            ]),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: DefaultStyle.bottomnavbarHegiht +
                                      MediaQuery.of(context).padding.bottom,
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .padding
                                          .bottom),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: navBarItem
                                        .asMap()
                                        .keys
                                        .map((key) => GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedKey = key;
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  !loading
                                                      ? Image.asset(
                                                          selectedKey == key
                                                              ? navBarItem[key]
                                                                  ['activeIcon']
                                                              : navBarItem[key]
                                                                  ['icon'],
                                                          width: ScreenUtil()
                                                              .setWidth(30),
                                                          height: ScreenUtil()
                                                              .setWidth(30),
                                                          fit: BoxFit.fitWidth)
                                                      : Container(),
                                                  Text(
                                                    navBarItem[key]['title'],
                                                    style: selectedKey == key
                                                        ? DefaultStyle.zhuti12
                                                        : DefaultStyle.lgray12,
                                                  )
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: double.infinity,
                        )
                      ],
              )),
            ],
          ),
        )
      ],
    );
  }
}
