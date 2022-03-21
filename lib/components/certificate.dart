import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class CertificateModel {
  static void showCertificate(BackButtonBehavior backButtonBehavior,
      {VoidCallback cancel,
      VoidCallback confirm,
      String id = 'undefine',
      String code = 'undefine',
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
        CommonUtils.showText('请自行截图保存分享哦～');
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
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(10)),
                          color: Color(0xffFFF4F9),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Positioned(
                                  child: RepaintBoundary(
                                    key: certificateWidgetKey,
                                    child: Container(
                                      child: Stack(
                                        children: [
                                          Positioned(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height:
                                                    ScreenUtil().setHeight(50),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                ScreenUtil()
                                                                    .setWidth(
                                                                        10)),
                                                        topRight:
                                                            Radius.circular(
                                                                ScreenUtil()
                                                                    .setWidth(
                                                                        10))),
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFFFF89AC),
                                                        Color(0xFFFF5B8C)
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                    )),
                                                child: Stack(
                                                  children: [
                                                    Center(
                                                        child: Text("账号凭证",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    ScreenUtil()
                                                                        .setSp(
                                                                            16.5)))),
                                                    Positioned(
                                                      right: ScreenUtil()
                                                          .setWidth(10),
                                                      top: ScreenUtil()
                                                          .setHeight(16),
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: ScreenUtil()
                                                            .setSp(20),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    ScreenUtil().setHeight(10),
                                              ),
                                              Center(
                                                child: Image.asset(
                                                  "assets/images/wode/user_icon.png",
                                                  width:
                                                      ScreenUtil().setWidth(96),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    ScreenUtil().setHeight(5),
                                              ),
                                              Center(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '用户ID：$id',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff646464),
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: ScreenUtil()
                                                              .setSp(16.5)),
                                                    ),
                                                    SizedBox(
                                                      height: ScreenUtil()
                                                          .setHeight(2),
                                                    ),
                                                    Text(
                                                      '邀请码：$code',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff646464),
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: ScreenUtil()
                                                              .setSp(16.5)),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                    ScreenUtil().setWidth(10)),
                                                topRight: Radius.circular(
                                                    ScreenUtil().setWidth(10))),
                                            color: Color(0xffFFF4F9)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height:
                                                  ScreenUtil().setHeight(50),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          10)),
                                                          topRight:
                                                              Radius.circular(
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          10))),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFFFF89AC),
                                                      Color(0xFFFF5B8C)
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  )),
                                              child: Stack(
                                                children: [
                                                  Center(
                                                      child: Text("账号凭证",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          16.5)))),
                                                  Positioned(
                                                      right: ScreenUtil()
                                                          .setWidth(10),
                                                      top: ScreenUtil()
                                                          .setHeight(16),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          cancelFunc();
                                                          cancel?.call();
                                                        },
                                                        child: Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: ScreenUtil()
                                                              .setSp(20),
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  ScreenUtil().setHeight(10),
                                            ),
                                            Center(
                                              child: Image.asset(
                                                "assets/images/wode/user_icon.png",
                                                width:
                                                    ScreenUtil().setWidth(96),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            SizedBox(
                                              height: ScreenUtil().setHeight(5),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: ScreenUtil()
                                                      .setWidth(28)),
                                              child: Text(
                                                '首次安装请先保存此账号信息，可在不慎遗失账号时作为凭证极大提高找回账号的概率 若您遇到账号遗失问题，请直接联系在线客服反馈。',
                                                style: TextStyle(
                                                    color: Color(0xff646464),
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.75,
                                                    fontSize:
                                                        ScreenUtil().setSp(12)),
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  ScreenUtil().setHeight(10),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: ScreenUtil()
                                                      .setWidth(28)),
                                              child: Text(
                                                '建议您尽快注册账号，以免账号丢失。使用账号登录更加安全',
                                                style: TextStyle(
                                                    color: Color(0xff646464),
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.75,
                                                    fontSize:
                                                        ScreenUtil().setSp(12)),
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  ScreenUtil().setHeight(25),
                                            ),
                                            Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '用户ID：$id',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff646464),
                                                        decoration:
                                                            TextDecoration.none,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: ScreenUtil()
                                                            .setSp(16.5)),
                                                  ),
                                                  SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(2),
                                                  ),
                                                  Text(
                                                    '邀请码：$code',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff646464),
                                                        decoration:
                                                            TextDecoration.none,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: ScreenUtil()
                                                            .setSp(16.5)),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ))),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(25),
                            ),
                            GestureDetector(
                              onTap: () {
                                _saveImgShare();
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(28)),
                                width: double.infinity,
                                height: ScreenUtil().setWidth(36),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setWidth(17.5)),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xffFF84A9),
                                        Color(0xffFF9E9E)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )),
                                child: Center(
                                  child: Text(
                                    '立即保存',
                                    style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.normal,
                                        fontSize: ScreenUtil().setSp(15)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(25),
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
