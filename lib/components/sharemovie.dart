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
                        width: ScreenUtil().setWidth(280),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                cancelFunc();
                                cancel?.call();
                              },
                              child: SizedBox(
                                width: ScreenUtil().setWidth(43),
                                height: ScreenUtil().setWidth(43),
                                child: PlatformAwareAssetImage(
                                    url: 'assets/images/icon_close2.png',
                                    width: double.infinity,
                                    height: double.infinity),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(10),
                            ),
                            Stack(
                              children: [
                                Positioned(
                                  child: RepaintBoundary(
                                    key: certificateWidgetKey,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                            top: 0,
                                            bottom: 0,
                                            right: 0,
                                            left: 0,
                                            child: Image.asset(
                                              'assets/pengke/share_dialog_bg.png',
                                              fit: BoxFit.fill,
                                            )),
                                        Container(
                                          padding: EdgeInsets.all(
                                              ScreenUtil().setWidth(15)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        ScreenUtil()
                                                            .setWidth(5)),
                                                child: SizedBox(
                                                  width: ScreenUtil()
                                                      .setWidth(270),
                                                  height: width == null
                                                      ? ScreenUtil()
                                                          .setWidth(157.5)
                                                      : ScreenUtil().setWidth(
                                                          (270 / width) *
                                                              height),
                                                  child:
                                                      PlatformAwareNetworkImage(
                                                    fit: BoxFit.cover,
                                                    url: '$thumb',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    ScreenUtil().setWidth(18),
                                              ),
                                              Text(
                                                '$title',
                                                style: TextStyle(
                                                    color: Color(0xffffffff),
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize:
                                                        ScreenUtil().setSp(15)),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              SizedBox(
                                                height:
                                                    ScreenUtil().setWidth(11),
                                              ),
                                              Text(
                                                '$subtitle',
                                                style: TextStyle(
                                                    color: Color(0xffd7d7d7),
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize:
                                                        ScreenUtil().setSp(13)),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3,
                                              ),
                                              SizedBox(
                                                height:
                                                    ScreenUtil().setWidth(14),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: ScreenUtil()
                                                        .setWidth(120),
                                                    height: ScreenUtil()
                                                        .setWidth(120),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        //阴影
                                                        BoxShadow(
                                                            color:
                                                                Colors.black12,
                                                            offset:
                                                                Offset(0, 0),
                                                            blurRadius:
                                                                ScreenUtil()
                                                                    .setWidth(
                                                                        6.5))
                                                      ],
                                                    ),
                                                    child: QrImage(
                                                      data: '$url',
                                                      version: 3,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: ScreenUtil()
                                                        .setWidth(15),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      '下载地址：$url',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xffd7d7d7),
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: ScreenUtil()
                                                              .setSp(12)),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  child: Stack(
                                    children: [
                                      Positioned(
                                          top: 0,
                                          bottom: 0,
                                          right: 0,
                                          left: 0,
                                          child: Image.asset(
                                            'assets/pengke/share_dialog_bg.png',
                                            fit: BoxFit.fill,
                                          )),
                                      Container(
                                        padding: EdgeInsets.all(
                                            ScreenUtil().setWidth(15)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      ScreenUtil().setWidth(5)),
                                              child: SizedBox(
                                                width:
                                                    ScreenUtil().setWidth(270),
                                                height: width == null
                                                    ? ScreenUtil()
                                                        .setWidth(157.5)
                                                    : ScreenUtil().setWidth(
                                                        (270 / width) *
                                                            (height > width
                                                                ? width
                                                                : height)),
                                                child:
                                                    PlatformAwareNetworkImage(
                                                  fit: BoxFit.cover,
                                                  url: '$thumb',
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: ScreenUtil().setWidth(18),
                                            ),
                                            Text(
                                              '$title',
                                              style: TextStyle(
                                                  color: Color(0xffffffff),
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize:
                                                      ScreenUtil().setSp(15)),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            SizedBox(
                                              height: ScreenUtil().setWidth(11),
                                            ),
                                            Text(
                                              '$subtitle',
                                              style: TextStyle(
                                                  color: Color(0xffd7d7d7),
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize:
                                                      ScreenUtil().setSp(13)),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                            SizedBox(
                                              height: ScreenUtil().setWidth(14),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: ScreenUtil()
                                                      .setWidth(120),
                                                  height: ScreenUtil()
                                                      .setWidth(120),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      //阴影
                                                      BoxShadow(
                                                          color: Colors.black12,
                                                          offset: Offset(0, 0),
                                                          blurRadius:
                                                              ScreenUtil()
                                                                  .setWidth(
                                                                      6.5))
                                                    ],
                                                  ),
                                                  child: QrImage(
                                                    data: '$url',
                                                    version: 3,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      ScreenUtil().setWidth(15),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '下载地址：$url',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffd7d7d7),
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(12)),
                                                      ),
                                                      SizedBox(
                                                        height: ScreenUtil()
                                                            .setWidth(15),
                                                      ),
                                                      GestureDetector(
                                                        onTap: _copyLinkShare,
                                                        child: Stack(
                                                          children: [
                                                            Positioned(
                                                                top: 0,
                                                                bottom: 0,
                                                                right: 0,
                                                                left: 0,
                                                                child:
                                                                    Image.asset(
                                                                  'assets/pengke/video/video_duan_btn.png',
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                            Container(
                                                              height:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          30),
                                                              child: Center(
                                                                child: Text(
                                                                  '复制下载链接',
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xff62f7ff),
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          ScreenUtil()
                                                                              .setSp(12)),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: ScreenUtil()
                                                            .setWidth(7.5),
                                                      ),
                                                      GestureDetector(
                                                        onTap: _saveImgShare,
                                                        child: Stack(
                                                          children: [
                                                            Positioned(
                                                                top: 0,
                                                                bottom: 0,
                                                                right: 0,
                                                                left: 0,
                                                                child:
                                                                    Image.asset(
                                                                  'assets/pengke/btn_bg.png',
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                            Container(
                                                              height:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          30),
                                                              child: Center(
                                                                child: Text(
                                                                  '保存图片',
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xff62f7ff),
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          ScreenUtil()
                                                                              .setSp(12)),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
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
