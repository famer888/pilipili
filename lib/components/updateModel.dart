import 'dart:io';

import 'package:app_installer/app_installer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pilipili/utils/networkImage.dart';

class UpdateModel {
  static void showAnnouncementDialog(BackButtonBehavior backButtonBehavior,
      {VoidCallback cancel,
      VoidCallback confirm,
      VoidCallback confirmApp,
      String text,
      String type = "2"}) {
    var tipSplit = text.split('#');
    tipWidget(String value) {
      return Text(
        value,
        style: TextStyle(
          color: Color(0xFFffffff),
          fontSize: ScreenUtil().setSp(15),
          decoration: TextDecoration.none,
          fontWeight: FontWeight.normal,
        ),
      );
    }

    tipsWidget() {
      return tipSplit.map((value) {
        Widget widget = tipWidget(value);
        return widget;
      }).toList();
    }

    List<Widget> newTipsWidget = tipsWidget();
    newTipsWidget.add(Container(
      width: double.infinity,
    ));
    BotToast.showWidget(
        toastBuilder: (cancelFunc) => Container(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      cancelFunc();
                      cancel?.call();
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black38),
                    ),
                  ),
                  Positioned(
                      child: Center(
                    child: Container(
                      width: ScreenUtil().setWidth(345),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Image.asset(
                                    'assets/pengke/dialog_bg.png',
                                    fit: BoxFit.fill,
                                  )),
                              Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: double.infinity,
                                  height: ScreenUtil().setWidth(360),
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setWidth(20)),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Text('官方公告',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ScreenUtil().setSp(18),
                                                height: 1.5)),
                                      ),
                                      Expanded(
                                          child: SingleChildScrollView(
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                ScreenUtil().setWidth(33.5),
                                            horizontal:
                                                ScreenUtil().setWidth(25)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: newTipsWidget,
                                        ),
                                      )),
                                      Center(
                                        child: GestureDetector(
                                            onTap: () {
                                              cancelFunc();
                                              confirm?.call();
                                              // type == "1"
                                              //     ? confirm?.call()
                                              //     : confirmApp?.call();
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: ScreenUtil()
                                                      .setWidth(21.5)),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                      top: 0,
                                                      bottom: 0,
                                                      left: 0,
                                                      right: 0,
                                                      child: Image.asset(
                                                        'assets/pengke/video/video_duan_btn.png',
                                                        fit: BoxFit.fill,
                                                      )),
                                                  Container(
                                                    width: ScreenUtil()
                                                        .setWidth(190),
                                                    height: ScreenUtil()
                                                        .setWidth(35.5),
                                                    child: Center(
                                                      child: Text(
                                                        '确定',
                                                        style: DefaultStyle
                                                            .zhuti15,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ))
                ],
              ),
            ));
  }

  static void showUpdateDialog(BackButtonBehavior backButtonBehavior,
      {VoidCallback cancel,
      VoidCallback confirm,
      VoidCallback gowebsite,
      String version,
      String text,
      bool mustupdate}) {
    var tipSplit = text.split('#');
    tipWidget(String value) {
      return Text(
        value,
        style: TextStyle(
          color: Color(0xFFffffff),
          fontSize: ScreenUtil().setSp(15),
          decoration: TextDecoration.none,
          fontWeight: FontWeight.normal,
        ),
      );
    }

    tipsWidget() {
      return tipSplit.map((value) {
        Widget widget = tipWidget(value);
        return widget;
      }).toList();
    }

    List<Widget> newTipsWidget = tipsWidget();
    newTipsWidget.add(Container(
      width: double.infinity,
    ));

    BotToast.showWidget(
        toastBuilder: (cancelFunc) => Container(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (mustupdate) return;
                      cancelFunc();
                      cancel?.call();
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black38),
                    ),
                  ),
                  Positioned(
                      child: Center(
                    child: Stack(
                      children: [
                        Positioned(
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Image.asset(
                              'assets/pengke/dialog_bg.png',
                              fit: BoxFit.fill,
                            )),
                        Material(
                            color: Colors.transparent,
                            child: Container(
                              width: ScreenUtil().setWidth(345),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: ScreenUtil().setWidth(360),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  ScreenUtil().setWidth(20)),
                                          child: Text('更新公告',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      ScreenUtil().setSp(18),
                                                  height: 1.5)),
                                        ),
                                        Expanded(
                                            child: SingleChildScrollView(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  DefaultStyle.pagePadding),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: newTipsWidget,
                                          ),
                                        )),
                                        Center(
                                          child: GestureDetector(
                                              onTap: () {
                                                if (!mustupdate) {
                                                  cancelFunc();
                                                } else if (mustupdate &&
                                                    Platform.isAndroid) {
                                                  cancelFunc();
                                                }
                                                confirm?.call();
                                              },
                                              child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: ScreenUtil()
                                                          .setWidth(21.5)),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                          top: 0,
                                                          bottom: 0,
                                                          left: 0,
                                                          right: 0,
                                                          child: Image.asset(
                                                            'assets/pengke/video/video_duan_btn.png',
                                                            fit: BoxFit.fill,
                                                          )),
                                                      Container(
                                                        width: ScreenUtil()
                                                            .setWidth(190),
                                                        height: ScreenUtil()
                                                            .setWidth(35.5),
                                                        child: Center(
                                                          child: Text(
                                                            '立即更新',
                                                            style: DefaultStyle
                                                                .zhuti15,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ))),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                      ],
                    ),
                  ))
                ],
              ),
            ));
  }

  static void androidUpdate(BackButtonBehavior backButtonBehavior,
      {VoidCallback cancel, String url, String version}) {
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => DownloadApk(
        url: url,
        version: version,
        onTap: () {
          cancelFunc();
          cancel?.call();
        },
      ),
    );
  }

  static void showAvtivetysDialog(BackButtonBehavior backButtonBehavior,
      {VoidCallback cancel,
      VoidCallback confirm,
      String url,
      double height,
      double width}) {
    double maxW = ScreenUtil().screenWidth / 3 * 2;
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => GestureDetector(
        onTap: () {
          cancelFunc();
          cancel?.call();
        },
        child: Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().screenHeight,
          ),
          width: ScreenUtil().screenWidth,
          padding: EdgeInsets.only(
              top: kIsWeb ? 0 : ScreenUtil().statusBarHeight,
              bottom: kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
          decoration: BoxDecoration(color: Colors.black38),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      cancelFunc();
                      cancel?.call();
                    },
                    child: PlatformAwareAssetImage(
                        url: "assets/images/accloseicon.png",
                        width: ScreenUtil().setWidth(33),
                        height: ScreenUtil().setWidth(33),
                        alignment: Alignment.center,
                        fit: BoxFit.cover)),
                SizedBox(height: ScreenUtil().setWidth(20)),
                Container(
                    constraints: BoxConstraints(
                        minHeight: ScreenUtil().setWidth(90),
                        maxHeight: ScreenUtil().screenHeight -
                            (kIsWeb ? 0 : ScreenUtil().bottomBarHeight) -
                            (kIsWeb ? 0 : ScreenUtil().statusBarHeight) -
                            ScreenUtil().setWidth(150)),
                    child: GestureDetector(
                        onTap: () {
                          cancelFunc();
                          confirm?.call();
                        },
                        child: Container(
                          width: maxW,
                          height: width == null
                              ? ScreenUtil().setWidth(150)
                              : (maxW / width) * height,
                          child: PlatformAwareNetworkImage(
                            nothumb: true,
                            width: maxW,
                            height: width == null
                                ? ScreenUtil().setWidth(150)
                                : (maxW / width) * height,
                            url: url.contains('http')
                                ? url
                                : AppGlobal.bannerImgBase + url,
                          ),
                        ))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DownloadApk extends StatefulWidget {
  final GestureTapCallback onTap;
  final String url;
  final String version;

  DownloadApk({Key key, this.onTap, this.url, this.version}) : super(key: key);

  @override
  _DownloadApkState createState() => _DownloadApkState();
}

class _DownloadApkState extends State<DownloadApk> {
  int progress = 0;

  Future<Null> _installApk(savePath) async {
    try {
      await CommonUtils.checkRequestInstallPackages();
      await CommonUtils.checkStoragePermission();
      AppInstaller.installApk(savePath)
          .then((result) {})
          .catchError((error) {});
    } on Exception catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    getExternalStorageDirectory().then((documents) {
      String savePath =
          '${documents.path}/youyu.${DateTime.now().millisecondsSinceEpoch}.apk';
      PlatformAwareHttp.download(widget.url, savePath,
          onReceiveProgress: (int count, int total) {
        var tmp = (count / total * 100).toInt();
        if (tmp % 1 == 0) {
          setState(() {
            progress = tmp;
          });
        }
        if (count >= total) {
          _installApk(savePath);
        }
      }).catchError((err) {
        BotToast.cleanAll();
        BotToast.showText(text: '网络不好，新版本下载失败，请稍后重试');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Stack(
        children: [
          Positioned(
              child: Center(
            child: Stack(
              children: [
                Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/pengke/dialog_bg.png',
                      fit: BoxFit.fill,
                    )),
                Container(
                  width: ScreenUtil().setWidth(345),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(15.5),
                            horizontal: ScreenUtil().setWidth(20)),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "正在更新 v.${widget.version}",
                              style: TextStyle(
                                  color: Color(0xFF62f7ff),
                                  fontSize: ScreenUtil().setSp(18),
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(25),
                            ),
                            SizedBox(
                              width: ScreenUtil().setWidth(185),
                              height: ScreenUtil().setWidth(4),
                              child: Stack(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            ScreenUtil().setWidth(2))),
                                    child: Stack(
                                      children: <Widget>[
                                        Opacity(
                                          opacity: 0.3,
                                          child: Container(
                                            width: ScreenUtil().setWidth(185),
                                            height: ScreenUtil().setWidth(4),
                                            decoration: BoxDecoration(
                                                color: Color(0xFF62f7ff)),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    ScreenUtil().setWidth(4))),
                                            child: Container(
                                              width: progress /
                                                  100 *
                                                  ScreenUtil().setWidth(185),
                                              height: ScreenUtil().setWidth(4),
                                              decoration: BoxDecoration(
                                                  color: Color(0xFF62f7ff)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(12),
                            ),
                            Center(
                              child: Text('$progress%',
                                  style: TextStyle(
                                      color: Color(0xFF62f7ff),
                                      fontSize: ScreenUtil().setSp(18),
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
