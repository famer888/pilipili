import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ShareMovieModel {
  static void showShareMovie(BackButtonBehavior backButtonBehavior,
      {VoidCallback cancel,
      VoidCallback confirm,
      String thumb = 'undefine',
      String title = 'undefine',
      double width,
      double height,
      String copyUrl = '',
      String subtitle = 'undefine',
      String url = 'undefine'}) {
    GlobalKey certificateWidgetKey = GlobalKey();

    localStorageImage() async {
      RenderRepaintBoundary boundary =
          certificateWidgetKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final result =
          await ImageGallerySaver.saveImage(pngBytes); //这个是核心的保存图片的插件
      if (result['isSuccess']) {
        CommonUtils.showText(
          '信息保存成功,请勿丢失～',
        );
      } else if (Platform.isAndroid) {
        if (result.length > 0) {
          CommonUtils.showText(
            '信息保存成功,请勿丢失～',
          );
        }
      }
    }

    _saveImgShare() async {
      if (kIsWeb) {
        CommonUtils.showText('请自行截图保存分享哦～');
        // RenderRepaintBoundary boundary =
        //     certificateWidgetKey.currentContext.findRenderObject();
        // ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        // ByteData byteData =
        //     await image.toByteData(format: ui.ImageByteFormat.png);
        // final base64Data = base64Encode(byteData.buffer.asUint8List());
        // final downElement =
        //     html.AnchorElement(href: 'data:image/png;base64,$base64Data');
        // downElement.download = 'download.png';
        // downElement.click();
        // downElement.remove();
      } else {
        BotToast.showLoading();
        PermissionStatus storageStatus = await Permission.camera.status;
        if (storageStatus == PermissionStatus.denied) {
          storageStatus = await Permission.camera.request();
          if (storageStatus == PermissionStatus.denied ||
              storageStatus == PermissionStatus.permanentlyDenied) {
            CommonUtils.showText(
              '您拒绝了存储权限，请前往设置中打开权限',
            );
          } else {
            localStorageImage();
          }
          BotToast.closeAllLoading();
          return;
        } else if (storageStatus == PermissionStatus.permanentlyDenied) {
          BotToast.closeAllLoading();
          CommonUtils.showText(
            '无法保存到相册中，你关闭了存储权限，请前往设置中打开权限',
          );
          return;
        }
        localStorageImage();
        BotToast.closeAllLoading();
      }
    }

    //复制链接分享
    void _copyLinkShare() {
      Clipboard.setData(ClipboardData(text: '$copyUrl'));
      CommonUtils.showText(
        '复制成功,快去分享吧',
      );
    }

    Widget _header() {
      return Container(
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(20), right: ScreenUtil().setWidth(100)),
        height: ScreenUtil().setWidth(80),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromRGBO(255, 134, 172, 1),
          Color.fromRGBO(255, 91, 140, 1),
          Color.fromRGBO(250, 67, 122, 1)
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title',
              style: TextStyle(
                  color: Color(0xffffffff),
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(18)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              '$subtitle',
              style: TextStyle(
                  color: Color(0xffffffff),
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                  fontSize: ScreenUtil().setSp(14)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          ],
        ),
      );
    }

    Widget _body() {
      return Container(
        padding: EdgeInsets.all(DefaultStyle.pagePadding),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(5)),
              child: SizedBox(
                width: double.infinity,
                height: width == 1 || height == 1
                    ? ScreenUtil().setWidth(111)
                    : height /
                        width *
                        (ScreenUtil().screenWidth - ScreenUtil().setWidth(65)),
                child: PlatformAwareNetworkImage(
                  fit: BoxFit.cover,
                  url: '$thumb',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(10),
                  right: ScreenUtil().setWidth(10),
                  top: DefaultStyle.pagePadding),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: DefaultStyle.pagePadding),
                    width: ScreenUtil().setWidth(80),
                    height: ScreenUtil().setWidth(80),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        //阴影
                        BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, 0),
                            blurRadius: ScreenUtil().setWidth(6.5))
                      ],
                    ),
                    child: QrImage(
                        data: '$url', version: 3, padding: EdgeInsets.all(7)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '扫码下载APP',
                                style: TextStyle(
                                    color: Color(0xff646464),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                    fontSize: ScreenUtil().setSp(14)),
                              ),
                              Text(
                                '立即观看pilipili视频！',
                                style: TextStyle(
                                    color: Color(0xff646464),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                    fontSize: ScreenUtil().setSp(14)),
                              )
                            ],
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: ScreenUtil().setWidth(5)),
                            child: Image.asset(
                              "assets/images/icon_logo.png",
                              width: ScreenUtil().setWidth(50),
                              fit: BoxFit.fitWidth,
                            ),
                          )
                        ],
                      ),
                      Container(
                        width: ScreenUtil().screenWidth -
                            DefaultStyle.pagePadding * 5 -
                            ScreenUtil().setWidth(115),
                        padding: EdgeInsets.only(top: ScreenUtil().setWidth(0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "若二维码无法打开，请输入以下网址",
                              style: TextStyle(
                                  color: Color(0xff646464),
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                  fontSize: ScreenUtil().setSp(11)),
                            ),
                            Text(
                              "${url}",
                              style: TextStyle(
                                  color: Color(0xff646464),
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                  fontSize: ScreenUtil().setSp(11)),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(60))
          ],
        ),
      );
    }

    Widget _footer() {
      return Positioned(
          right: 0,
          bottom: 0,
          left: 0,
          child: Container(
            // color: Colors.red,
            height: ScreenUtil().setWidth(70),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _saveImgShare,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(10)),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(18),
                        vertical: ScreenUtil().setWidth(8)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          //阴影
                          BoxShadow(
                              color: Color.fromRGBO(255, 128, 163, 0.5),
                              offset: Offset(0, 0),
                              blurRadius: ScreenUtil().setWidth(4))
                        ],
                        gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(255, 132, 169, 1),
                              Color.fromRGBO(255, 158, 158, 1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                    child: Text(
                      '保存图片分享',
                      style: DefaultStyle.white15bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _copyLinkShare,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(10)),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(18),
                        vertical: ScreenUtil().setWidth(8)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          //阴影
                          BoxShadow(
                              color: Color.fromRGBO(255, 128, 163, 0.5),
                              offset: Offset(0, 0),
                              blurRadius: ScreenUtil().setWidth(4))
                        ],
                        gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(255, 132, 169, 1),
                              Color.fromRGBO(255, 158, 158, 1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                    child: Text(
                      '复制分享链接',
                      style: DefaultStyle.white15bold,
                    ),
                  ),
                )
              ],
            ),
          ));
    }

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
                      decoration: BoxDecoration(color: Colors.black54),
                    ),
                  ),
                  Positioned(
                    child: Center(
                      child: Container(
                        width: ScreenUtil().screenWidth -
                            ScreenUtil().setWidth(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Positioned(
                                  child: RepaintBoundary(
                                    key: certificateWidgetKey,
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                                height:
                                                    ScreenUtil().setWidth(60)),
                                            Container(
                                              width: double.infinity,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                  color: Color(0xfffff4f9),
                                                  borderRadius: BorderRadius
                                                      .all(Radius.circular(
                                                          ScreenUtil()
                                                              .setWidth(10)))),
                                              child: Column(
                                                children: [_header(), _body()],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Image.asset(
                                              "assets/images/share_bg.png",
                                              height:
                                                  ScreenUtil().setWidth(140),
                                              fit: BoxFit.fitHeight,
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                                _footer()
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ));
  }
}
