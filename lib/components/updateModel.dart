import 'dart:io';

import 'package:app_installer/app_installer.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/model/homedata.dart';
import 'package:pilipili/report/report_utils.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

class UpdateModel {
  static void showAnnouncementDialog(BackButtonBehavior backButtonBehavior,
      {VoidCallback? cancel,
      VoidCallback? confirm,
      VoidCallback? confirmApp,
      BuildContext? context,
      String? text,
      String? type}) {
    HtmlUnescape unescape = HtmlUnescape();
    String decodedString = unescape.convert(text ?? '');
    Widget content = Html(
      shrinkWrap: true,
      data: decodedString,
      style: {
        "*": Style(
          color: Color(0xFFf646464),
          lineHeight: LineHeight.rem(1.5),
          margin: Margins.zero,
        ),
        "a": Style(
          color: Color(0xff47b0f8),
          textDecoration: TextDecoration.underline,
        )
      },
      onLinkTap: (url, attributes, element) {
        CommonUtils.launchURL(url ?? "");
      },
    );
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
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          color: Color(0xffFFF4F9), borderRadius: BorderRadius.circular(ScreenUtil().setWidth(15))),
                      width: ScreenUtil().setWidth(345),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: Container(
                              width: double.infinity,
                              height: ScreenUtil().setWidth(360),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                      colors: [Color(0xFFFF89AC), Color(0xFFFF5B8C), Color(0xFFFA437A)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )),
                                    height: ScreenUtil().setWidth(60),
                                    child: Text('官方公告',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(18),
                                            height: 1.5)),
                                  ),
                                  Expanded(
                                      child: SingleChildScrollView(
                                    padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil().setWidth(33.5), horizontal: ScreenUtil().setWidth(25)),
                                    child: content,
                                  )),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(25)),
                                    child: AppGlobal.shouApp
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    cancelFunc();
                                                    context!.push('/walfareIndexPage/1');
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Color.fromRGBO(255, 128, 163, 0.5),
                                                                offset: Offset(0, 2),
                                                                blurRadius: 3,
                                                                spreadRadius: 0)
                                                          ],
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              DefaultStyle.linerThemeColor,
                                                              DefaultStyle.themeColor,
                                                            ],
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(ScreenUtil().setWidth(18))),
                                                      margin:
                                                          EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(21.5)),
                                                      child: Container(
                                                        width: ScreenUtil().setWidth(120),
                                                        height: ScreenUtil().setWidth(36),
                                                        child: Center(
                                                          child: Text(
                                                            '应用中心',
                                                            style: DefaultStyle.white15,
                                                          ),
                                                        ),
                                                      ))),
                                              GestureDetector(
                                                  onTap: () {
                                                    cancelFunc();
                                                    confirm!.call();
                                                    // type == "1"
                                                    //     ? confirm?.call()
                                                    //     : confirmApp?.call();
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Color.fromRGBO(255, 128, 163, 0.5),
                                                                offset: Offset(0, 2),
                                                                blurRadius: 3,
                                                                spreadRadius: 0)
                                                          ],
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              DefaultStyle.linerThemeColor,
                                                              DefaultStyle.themeColor,
                                                            ],
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(ScreenUtil().setWidth(18))),
                                                      margin:
                                                          EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(21.5)),
                                                      child: Container(
                                                        width: ScreenUtil().setWidth(120),
                                                        height: ScreenUtil().setWidth(35),
                                                        child: Center(
                                                          child: Text(
                                                            '确定',
                                                            style: DefaultStyle.white15,
                                                          ),
                                                        ),
                                                      )))
                                            ],
                                          )
                                        : Center(
                                            child: GestureDetector(
                                                onTap: () {
                                                  cancelFunc();
                                                  confirm!.call();
                                                  // type == "1"
                                                  //     ? confirm?.call()
                                                  //     : confirmApp?.call();
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Color.fromRGBO(255, 128, 163, 0.5),
                                                              offset: Offset(0, 2),
                                                              blurRadius: 3,
                                                              spreadRadius: 0)
                                                        ],
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            DefaultStyle.linerThemeColor,
                                                            DefaultStyle.themeColor,
                                                          ],
                                                          begin: Alignment.topCenter,
                                                          end: Alignment.bottomCenter,
                                                        ),
                                                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(18))),
                                                    margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(21.5)),
                                                    child: Container(
                                                      height: ScreenUtil().setWidth(36),
                                                      child: Center(
                                                        child: Text(
                                                          '确定',
                                                          style: DefaultStyle.white15,
                                                        ),
                                                      ),
                                                    ))),
                                          ),
                                  )
                                ],
                              ),
                            ),
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
      {VoidCallback? cancel,
      VoidCallback? confirm,
      VoidCallback? gowebsite,
      String? version,
      String? text,
      bool? mustupdate}) {
    var tipSplit = text!.split('#');
    tipWidget(String value) {
      return Text(
        value,
        style: TextStyle(
          color: Color(0xFF646464),
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
                      if (mustupdate!) return;
                      cancelFunc();
                      cancel?.call();
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black38),
                    ),
                  ),
                  Positioned(
                      child: Center(
                          child: Material(
                              color: Colors.transparent,
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    color: Color(0xffFFF4F9),
                                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(15))),
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
                                            alignment: Alignment.center,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                              colors: [Color(0xFFFF89AC), Color(0xFFFF5B8C), Color(0xFFFA437A)],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            )),
                                            height: ScreenUtil().setWidth(60),
                                            child: Text('更新公告',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: ScreenUtil().setSp(18),
                                                    height: 1.5)),
                                          ),
                                          Expanded(
                                              child: SingleChildScrollView(
                                            padding: EdgeInsets.symmetric(horizontal: DefaultStyle.pagePadding),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: newTipsWidget,
                                            ),
                                          )),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: DefaultStyle.pagePadding + ScreenUtil().setWidth(10)),
                                            child: Center(
                                              child: GestureDetector(
                                                  onTap: () {
                                                    if (!mustupdate!) {
                                                      cancelFunc();
                                                    } else if (mustupdate && Platform.isAndroid!) {
                                                      cancelFunc();
                                                    }
                                                    confirm!.call();
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(21.5)),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Color.fromRGBO(255, 128, 163, 0.5),
                                                                offset: Offset(0, 2),
                                                                blurRadius: 3,
                                                                spreadRadius: 0)
                                                          ],
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              DefaultStyle.linerThemeColor,
                                                              DefaultStyle.themeColor,
                                                            ],
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(ScreenUtil().setWidth(18))),
                                                      height: ScreenUtil().setWidth(36),
                                                      child: Center(
                                                        child: Text(
                                                          '立即更新',
                                                          style: DefaultStyle.white15,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ))))
                ],
              ),
            ));
  }

  static void androidUpdate(BackButtonBehavior backButtonBehavior, {VoidCallback? cancel, String? url, String? version}) {
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
      {VoidCallback? cancel, VoidCallback? confirm, String? url, double? height, double? width}) {
    if (height == 0) {
      height = 1;
    }
    if (width == 0) {
      width = 1;
    }

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
              top: kIsWeb ? 0 : ScreenUtil().statusBarHeight, bottom: kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
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
                        url: "assets/images/detail/icon_close.png",
                        width: ScreenUtil().setWidth(33),
                        height: ScreenUtil().setWidth(33),
                        fit: BoxFit.fill)),
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
                          height: width == null ? ScreenUtil().setWidth(150) : (maxW / width) * height!,
                          child: PlatformAwareNetworkImage(
                            nothumb: true,
                            width: maxW,
                            height: width == null ? ScreenUtil().setWidth(150) : (maxW / width) * height!,
                            url: url!.contains('http') ? url : (AppGlobal.bannerImgBase ?? '') + url!,
                          ),
                        ))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showCompartmentDialog({VoidCallback? cancel, String? url}) {
    if (AppGlobal.popAppAds.isNotEmpty) {
      ReportUtils.adVertising(
          eventType: AdEventType.show,
          advertisingKey: AdType.homePopup,
          advertisingId: AppGlobal.popAppAds.map((e) => e['id']).toList().join(','),
          adSlotKey: AppGlobal.popAppAds.first['advertise_location_code'],
          adSlotName: AppGlobal.popAppAds.first['ad_slot_name'],
          adtype: AppGlobal.popAppAds.first['ad_type']);
    }
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            cancelFunc();
            cancel?.call();
            ReportUtils.adVertising(
                eventType: AdEventType.close,
                advertisingKey: AdType.homePopup,
                advertisingId: AppGlobal.popAppAds.map((e) => e['id']).toList().join(','),
                adSlotKey: AppGlobal.popAppAds.first['advertise_location_code'],
                adSlotName: AppGlobal.popAppAds.first['ad_slot_name'],
                adtype: AppGlobal.popAppAds.first['ad_type']);
          },
          child: Container(
            color: Colors.black45,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      cancelFunc();
                      cancel?.call();
                      ReportUtils.adVertising(
                          eventType: AdEventType.close,
                          advertisingKey: AdType.homePopup,
                          advertisingId: AppGlobal.popAppAds.map((e) => e['id']).toList().join(','),
                          adSlotKey: AppGlobal.popAppAds.first['advertise_location_code'],
                          adSlotName: AppGlobal.popAppAds.first['ad_slot_name'],
                          adtype: AppGlobal.popAppAds.first['ad_type']);
                    },
                    child: PlatformAwareAssetImage(
                        url: "assets/images/detail/icon_close.png",
                        width: ScreenUtil().setWidth(33),
                        height: ScreenUtil().setWidth(33),
                        fit: BoxFit.fill)),
                SizedBox(height: ScreenUtil().setWidth(20)),
                Container(
                  width: 315.w,
                  height: 380.w,
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.w),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: AppGlobal.popAppAds.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 0.75, crossAxisCount: 4, mainAxisSpacing: 15.w, crossAxisSpacing: 15.w),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              ReportUtils.adVertising(
                                  eventType: AdEventType.click,
                                  advertisingKey: AdType.homePopup,
                                  advertisingId: AppGlobal.popAppAds[index]['id'],
                                  adSlotKey: AppGlobal.popAppAds[index]['advertise_location_code'],
                                  adSlotName: AppGlobal.popAppAds[index]['ad_slot_name'],
                                  adtype: AppGlobal.popAppAds[index]['ad_type']);
                              CommonUtils.launchURL(AppGlobal.popAppAds[index]['link_url']);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 60.w,
                                  height: 60.w,
                                  child: PlatformAwareNetworkImage(
                                    url: AppGlobal.popAppAds[index]['img_url'],
                                  ),
                                ),
                                SizedBox(
                                  height: 5.w,
                                ),
                                Text(
                                  AppGlobal.popAppAds[index]['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                )
                              ],
                            ),
                          );
                        }),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DownloadApk extends StatefulWidget {
  final GestureTapCallback? onTap;
  final String? url;
  final String? version;

  DownloadApk({Key? key, this.onTap, this.url, this.version}) : super(key: key);

  @override
  _DownloadApkState createState() => _DownloadApkState();
}

class _DownloadApkState extends State<DownloadApk> {
  int progress = 0;

  Future<Null> _installApk(savePath) async {
    try {
      await CommonUtils.checkRequestInstallPackages();
      await CommonUtils.checkStoragePermission();
      AppInstaller.installApk(savePath).then((result) {}).catchError((error) {});
    } on Exception catch (_) {}
  }

  Future<bool> md5ApkFile(File apkFile) async {
    final digest = await sha256.bind(apkFile.openRead()).first;
    VersionMsg cf = Provider.of<HomeConfig>(context, listen: false).versionMsg;
    return cf.sha256 == digest.toString();
  }

  @override
  void initState() {
    super.initState();
    getExternalStorageDirectory().then((documents) {
      String savePath = '${documents!.path}/youyu.${DateTime.now().millisecondsSinceEpoch}.apk';
      PlatformAwareHttp.download(widget.url!, savePath, onReceiveProgress: (int count, int total) async {
        var tmp = (count / total * 100).toInt();
        if (tmp % 1 == 0) {
          setState(() {
            progress = tmp;
          });
        }
        if (count >= total) {
          if (await md5ApkFile(File(savePath))) {
            _installApk(savePath);
          } else {
            //关闭升级弹窗
            widget.onTap!.call();
            //弹出告警提示
            String officeSite = Provider.of<HomeConfig>(AppGlobal.appContext!, listen: false).config.officeSite ?? "";
            YyShowDialog.showdialog(AppGlobal.appContext!, title: '温馨提示', btnText: '去官网下载', cancelText: '取消',
                callBack: () {
              CommonUtils.launchURL(officeSite);
            }, content: (setDialogState) {
              return DefaultTextStyle(
                  style: TextStyle(
                      color: Color(0xff646464), fontSize: ScreenUtil().setSp(16), fontWeight: FontWeight.bold),
                  child: Text('数据校验失败，请去官网下载最新版本！'));
            });
          }
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
                  child: Container(
            width: ScreenUtil().setWidth(345),
            clipBehavior: Clip.hardEdge,
            decoration:
                BoxDecoration(color: Color(0xffFFF4F9), borderRadius: BorderRadius.circular(ScreenUtil().setWidth(15))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(15.5), horizontal: ScreenUtil().setWidth(20)),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "正在更新 v." + widget.version.toString(),
                        style: TextStyle(
                            color: Color(0xFF646464),
                            fontSize: ScreenUtil().setSp(18),
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(25),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(38))),
                        child: Stack(
                          children: <Widget>[
                            Image.asset('assets/gif/loading_1.gif',
                                width: ScreenUtil().setWidth(76),
                                height: ScreenUtil().setWidth(76),
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.medium),
                            Positioned(
                                top: 0,
                                bottom: 0,
                                right: 0,
                                left: 0,
                                child: CircularProgressIndicator(
                                  strokeWidth: ScreenUtil().setWidth(12),
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation(Color(0xffFF5B8C)),
                                  value: progress / 100,
                                ))
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   width: ScreenUtil().setWidth(185),
                      //   height: ScreenUtil().setWidth(4),
                      //   child: Stack(
                      //     children: <Widget>[
                      //       ClipRRect(
                      //         borderRadius: BorderRadius.all(
                      //             Radius.circular(ScreenUtil().setWidth(38))),
                      //         child: Stack(
                      //           children: <Widget>[
                      //             Opacity(
                      //               opacity: 0.3,
                      //               child: Container(
                      //                 width: ScreenUtil().setWidth(185),
                      //                 height: ScreenUtil().setWidth(4),
                      //                 decoration: BoxDecoration(
                      //                     color: Color(0xFFAB3854)),
                      //               ),
                      //             ),
                      //             Positioned(
                      //               left: 0,
                      //               child: ClipRRect(
                      //                 borderRadius: BorderRadius.all(
                      //                     Radius.circular(
                      //                         ScreenUtil().setWidth(4))),
                      //                 child: Container(
                      //                   width: progress /
                      //                       100 *
                      //                       ScreenUtil().setWidth(185),
                      //                   height: ScreenUtil().setWidth(4),
                      //                   decoration: BoxDecoration(
                      //                       color: Color(0xFFFF5B8C)),
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      SizedBox(
                        height: ScreenUtil().setWidth(12),
                      ),
                      Center(
                        child: Text('$progress%',
                            style: TextStyle(
                                color: Color(0xFF646464),
                                fontSize: ScreenUtil().setSp(18),
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
          )))
        ],
      ),
    );
  }
}
