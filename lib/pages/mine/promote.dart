import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/theme/default.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class Promote extends StatefulWidget {
  Promote({Key key}) : super(key: key);

  @override
  _InviteFriendState createState() => _InviteFriendState();
}

class _InviteFriendState extends State<Promote> {
  GlobalKey rootWidgetKey = GlobalKey();
  bool isSaving = false;

  _saveImgShare() async {
    if (kIsWeb) {
      CommonUtils.showText('请自行截图保存分享哦～');
      setState(() {
        isSaving = false;
      });
    } else {
      PermissionStatus storageStatus = await Permission.storage.status;
      if (storageStatus == PermissionStatus.denied) {
        storageStatus = await Permission.storage.request();
        if (storageStatus == PermissionStatus.denied ||
            storageStatus == PermissionStatus.permanentlyDenied) {
          CommonUtils.showText(
            '您拒绝了存储权限，请前往设置中打开权限',
          );
          setState(() {
            isSaving = false;
          });
        } else {
          localStorageImage();
        }
        return;
      } else if (storageStatus == PermissionStatus.permanentlyDenied) {
        CommonUtils.showText(
          '无法保存到相册中，你关闭了存储权限，请前往设置中打开权限',
        );
        setState(() {
          isSaving = false;
        });
        return;
      } else if (storageStatus == PermissionStatus.granted) {
        localStorageImage();
      }
      // localStorageImage();
    }
  }

  localStorageImage() async {
    RenderRepaintBoundary boundary =
        rootWidgetKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    final result = await ImageGallerySaver.saveImage(pngBytes); //这个是核心的保存图片的插件
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
    setState(() {
      isSaving = false;
    });
  }

  //复制链接分享
  void _copyLinkShare() {
    var config = Provider.of<HomeConfig>(context, listen: false).config;

    Clipboard.setData(ClipboardData(text: '${config.share.affUrlCopy.url}'));
    CommonUtils.showText(
      '复制成功,快去分享吧',
    );
  }

  @override
  Widget build(BuildContext context) {
    var config = Provider.of<HomeConfig>(context, listen: false).config;

    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: ScreenUtil().setWidth(327),
          // height: ScreenUtil().setWidth(335),
          child: RepaintBoundary(
              key: rootWidgetKey,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(327),
                      child: PlatformAwareAssetImage(
                          url:
                              "assets/images/wode/invite_friends_header_bg.png",
                          fit: BoxFit.fitWidth,
                          filterQuality: FilterQuality.medium),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft:
                                Radius.circular(ScreenUtil().setWidth(10)),
                            bottomRight:
                                Radius.circular(ScreenUtil().setWidth(10))),
                      ),
                      padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
                      width: ScreenUtil().setWidth(327),
                      child: Column(
                        children: [
                          ClipRRect(
                            //剪裁为圆角矩形
                            borderRadius: BorderRadius.circular(5.0),
                            child: PlatformAwareAssetImage(
                                url:
                                    "assets/images/wode/invite_friends_content_bg.png",
                                width: double.infinity,
                                fit: BoxFit.fitWidth,
                                filterQuality: FilterQuality.medium),
                          ),
                          SizedBox(
                            height: ScreenUtil().setWidth(10),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: ScreenUtil().setWidth(96),
                                height: ScreenUtil().setWidth(96),
                                color: Colors.white,
                                child: QrImage(
                                  data: '${config.share.affUrl}',
                                  padding:
                                      EdgeInsets.all(ScreenUtil().setWidth(10)),
                                  version: QrVersions.auto,
                                ),
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(12),
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: ScreenUtil().setWidth(3),
                                  ),
                                  Text('扫码下载APP 立即观看pilipli视频！',
                                      style: TextStyle(
                                          color: Color(0xff646464),
                                          decoration: TextDecoration.none,
                                          fontSize: ScreenUtil().setSp(14),
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: ScreenUtil().setWidth(8)),
                                  Text('推广码:${config.share.affCode}',
                                      style: TextStyle(
                                          color: Color(0xff646464),
                                          decoration: TextDecoration.none,
                                          fontSize: ScreenUtil().setSp(11),
                                          fontWeight: FontWeight.w400)),
                                  Text('下载地址',
                                      style: TextStyle(
                                          color: Color(0xff646464),
                                          decoration: TextDecoration.none,
                                          fontSize: ScreenUtil().setSp(11),
                                          fontWeight: FontWeight.w400)),
                                  Text('${config.officeSite}',
                                      style: TextStyle(
                                          color: Color(0xff646464),
                                          decoration: TextDecoration.none,
                                          fontSize: ScreenUtil().setSp(11),
                                          fontWeight: FontWeight.w400))
                                ],
                              )),
                              PlatformAwareAssetImage(
                                  url: "assets/images/icon_logo.png",
                                  width: ScreenUtil().setWidth(50),
                                  // height: ScreenUtil().setWidth(40),
                                  fit: BoxFit.fitWidth,
                                  filterQuality: FilterQuality.medium),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ),
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: Container(
            width: double.infinity,
            color: Color.fromRGBO(255, 94, 67, 1),
          ),
        ),
        Container(
            margin: EdgeInsets.only(
                top: ScreenUtil().statusBarHeight + DefaultStyle.navbarHegiht),
            child: PlatformAwareAssetImage(
                url: 'assets/images/wode/invite_header.png',
                width: double.infinity,
                height: ScreenUtil().setWidth(575),
                fit: BoxFit.fitHeight,
                filterQuality: FilterQuality.medium)),
        Scaffold(
            body: Column(
              children: [
                PageTitleBar(
                    paddingTop: ScreenUtil().statusBarHeight,
                    title: '邀请好友',
                    rightWidget: GestureDetector(
                      onTap: () {
                        context.push(CommonUtils.getRealHash('inviterecored'));
                      },
                      child: Text(
                        "邀请记录",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(14)),
                      ),
                    )),
                Expanded(
                    child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(140),
                                  left: ScreenUtil().setWidth(16),
                                  right: ScreenUtil().setWidth(16)),
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(20),
                                  horizontal: ScreenUtil().setWidth(21)),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil().setWidth(15)),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromRGBO(255, 255, 255, 0.77),
                                      Color(0xFFFFE1C5)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("邀请好友 得免费VIP",
                                      style: TextStyle(
                                          color: Color(0xffAF5A0C),
                                          fontSize: ScreenUtil().setSp(16),
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(8),
                                  ),
                                  Text('成功邀请一人，就送2天免费会员哦！',
                                      style: TextStyle(
                                          color: Color(0xff9C8484),
                                          fontSize: ScreenUtil().setSp(15),
                                          fontWeight: FontWeight.w400)),
                                  SizedBox(
                                    height: ScreenUtil().setWidth(16),
                                  ),
                                  Container(
                                    // padding: EdgeInsets.symmetric(
                                    //     vertical: ScreenUtil().setWidth(10)),
                                    width: ScreenUtil().setWidth(350),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: ScreenUtil().setWidth(134.5),
                                          height: ScreenUtil().setWidth(134.5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              //阴影
                                              BoxShadow(
                                                  color: Colors.black12,
                                                  offset: Offset(0, 0),
                                                  blurRadius:
                                                      ScreenUtil().setWidth(20))
                                            ],
                                          ),
                                          child: QrImage(
                                            size: ScreenUtil().setWidth(134.5),
                                            data: '${config.share.affUrl}',
                                            padding: EdgeInsets.all(
                                                ScreenUtil().setWidth(10)),
                                            version: QrVersions.auto,
                                          ),
                                        ),
                                        SizedBox(
                                          height: ScreenUtil().setWidth(16),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '我的推广码',
                                              style: TextStyle(
                                                  color: Color(0xffAF5A0C),
                                                  fontSize:
                                                      ScreenUtil().setSp(18),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: ScreenUtil().setWidth(8),
                                            ),
                                            Text(
                                              '${config.share.affCode}',
                                              style: TextStyle(
                                                  color: Color(0xff7A3C04),
                                                  fontSize:
                                                      ScreenUtil().setSp(25.2),
                                                  fontWeight: FontWeight.w700),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: ScreenUtil().setWidth(24),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ActionShareButton(
                                              text: '保存图片分享',
                                              onTap: isSaving
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        isSaving = true;
                                                      });
                                                      SchedulerBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        _saveImgShare();
                                                      });
                                                    },
                                              isLoadding: isSaving,
                                            ),
                                            // ActionShareButton(
                                            //   text: '复制邀请连接',
                                            //   onTap: _copyLinkShare,
                                            //   isLoadding: false,
                                            // ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(35)),
                              child: GestureDetector(
                                  onTap: () {
                                    context.push(CommonUtils.getRealHash(
                                        'promoteActionList'));
                                  },
                                  child: Container(
                                      width: ScreenUtil().setWidth(200),
                                      height: ScreenUtil().setWidth(36),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              ScreenUtil().setWidth(20)),
                                          gradient: LinearGradient(
                                            colors: [
                                              Color.fromRGBO(
                                                  255, 255, 255, 0.68),
                                              Color.fromRGBO(
                                                  255, 255, 255, 0.374),
                                              Color.fromRGBO(
                                                  255, 255, 255, 0.4869),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )),
                                      child: Center(
                                        child: Text(
                                          '不会推广？点我',
                                          style: TextStyle(
                                            // decoration: TextDecoration.underline,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(15),
                                          ),
                                        ),
                                      ))),
                            )
                          ],
                        ))),
              ],
            ),
            backgroundColor: Colors.transparent),
      ],
    );
  }
}

class PromoteActionList extends StatefulWidget {
  PromoteActionList({Key key}) : super(key: key);

  @override
  _PromoteActionListState createState() => _PromoteActionListState();
}

class _PromoteActionListState extends State<PromoteActionList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('推广方法', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Color(0xff171222),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
          child:
              PlatformAwareAssetImage(url: 'assets/images/mine/promete_de.png'),
        ),
      ),
    );
  }
}

class ActionShareButton extends StatelessWidget {
  final String text;
  final GestureTapCallback onTap;
  final bool isLoadding;
  const ActionShareButton({Key key, this.text, this.onTap, this.isLoadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: ScreenUtil().setWidth(120),
            height: ScreenUtil().setWidth(36),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                gradient: LinearGradient(
                  colors: [
                    Color(0xffFFC2AE),
                    Color(0xffFF8C68),
                    Color(0xFFFF7D54)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
            child: Center(
              child: isLoadding
                  ? SizedBox(
                      width: ScreenUtil().setWidth(23),
                      height: ScreenUtil().setWidth(23),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        // color: Color(0xff62f7ff),
                      ))
                  : Text(
                      text,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(14)),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
