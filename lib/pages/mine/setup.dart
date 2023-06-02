import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pilipili/components/certificate.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/http.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pilipili/utils/privilege.dart';

class SetupPage extends StatefulWidget {
  SetupPage({Key key}) : super(key: key);

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  final ImagePicker _picker = ImagePicker();
  String fileUrl;
  double progress = 0.0;
  bool avatarLoadding = false;
  html.InputElement uploadInput;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      platformViewRegistry.registerViewFactory('AvatarFileInput', (viewId) {
        uploadInput = html.FileUploadInputElement();
        uploadInput.accept = 'image/*';
        uploadInput.setAttribute(
            'style',
            'width: ' +
                90.w.toString() +
                'px; height: ' +
                120.w.toString() +
                'px; opacity: 0');
        uploadInput.onChange.listen((event) {
          if (uploadInput.files != null) {
            final files = uploadInput.files;
            final file = files[0];
            html.FileReader reader = html.FileReader();
            getBase64(file, (base64) {
              reader.onLoadEnd.listen((_event) {
                upImage(
                    MultipartFile.fromBytes(reader.result,
                        filename: file.name,
                        contentType: MediaType.parse(file.type)),
                    imgfile: base64);
              });
              reader.readAsArrayBuffer(file);
            });
          }
        });
        return uploadInput;
      });
    }
  }

  clearToken() {
    Box box = AppGlobal.appBox;
    box.delete('yy_token');
  }

  Future<void> loadAssets(String type) async {
    if (type == 'camera') {
      _picker.pickImage(source: ImageSource.camera).then((XFile file) {
        upImage(file.path);
      });
    } else {
      XFile photo = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 30);
      if (photo == null) return;
      var formatList = ["heic", "heif", "HEIC", "HEIF"];
      List imgArr = photo.name.split('.');
      String type = imgArr[imgArr.length - 1];
      if (formatList.indexOf(type) == -1) {
        upImage(photo.path);
      } else {
        for (var j = 0; j < formatList.length; j++) {
          if (photo.path.endsWith(formatList[j])) {
            String jpegPath;
            jpegPath = await HeicToJpg.convert(photo.path);
            upImage(jpegPath);
          }
        }
      }
    }
  }

  upImage(dynamic filePath, {dynamic imgfile}) async {
    BotToast.showCustomLoading(toastBuilder: (cancelFunc) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
            SizedBox(
              height: 12.5.w,
            ),
            Text(
              '上传中...',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            )
          ],
        ),
      );
    });
    var result = await PlatformAwareHttp.uploadImage(
      imageUrl: filePath,
    );
    if (result == null) {
      BotToast.closeAllLoading();
      return;
    }

    var convert = jsonDecode(result.data);
    if (convert['code'] == 1) {
      var newImagePath = convert['msg'];
      var result = await updateUserInfo(thumb: newImagePath);
      if (result.status != 0) {
        setState(() {
          fileUrl = kIsWeb ? imgfile : filePath;
        });

        Future.delayed(Duration(seconds: 1), () async {
          var resultUserInfo = await getUserInfo(context);
          if (resultUserInfo.status != 0) {
            Provider.of<HomeConfig>(context, listen: false)
                .setAvatar(resultUserInfo.data.thumb);
          }
        });
      } else {
        CommonUtils.showText(result.msg);
      }
      BotToast.closeAllLoading();
    } else {
      BotToast.showText(text: convert['msg'], align: Alignment(0, 0));
      BotToast.closeAllLoading();
    }
  }

  updataAvatar() async {}

  getBase64(file, Function done) {
    html.FileReader reader = html.FileReader();
    reader.readAsDataUrl(file);
    reader.onLoadEnd.listen((_event) {
      done(reader.result);
    });
  }

  void showUpimg() {
    if (!Privilege.isAllowed(
        context, RESOURCE_TYPE_SYSTEM, PRIVILEGE_TYPE_SETTING)) {
      YyShowDialog.showdialog(
        context,
        content: (setDialogState) {
          return Text(
            '升级会员权限即可修改头像～',
            style: TextStyle(
                color: Color(0xff646464),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold),
          );
        },
        cancelText: '取消',
        btnText: PPString.upgradeNuw,
        callBack: () {
          context.push('/vip');
        },
      );
      return;
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context1, state) {
              return Container(
                height: 110.w + (kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: ScreenUtil().bottomBarHeight,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5)),
                  ),
                  child: Column(children: <Widget>[
                    TextButton(
                        onPressed: () {
                          loadAssets('camera');
                          context.pop();
                        },
                        child: Center(
                            child: Text(
                          '拍照',
                          style: TextStyle(
                              color: Color(0xff333333),
                              fontWeight: FontWeight.w500,
                              fontSize: 15.sp),
                        ))),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Color(0xffeeeeee),
                        width: 1.w,
                      ))),
                    ),
                    TextButton(
                        onPressed: () {
                          loadAssets('gallery');
                          context.pop();
                        },
                        child: Container(
                          height: 49.w,
                          child: Center(
                              child: Text(
                            '从相册选择',
                            style: TextStyle(
                                color: Color(0xff333333),
                                fontWeight: FontWeight.w500,
                                fontSize: 15.sp),
                          )),
                        ))
                  ]),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var members = Provider.of<HomeConfig>(context, listen: false).member;
    var config = Provider.of<HomeConfig>(context, listen: false).config;
    int isSetPassword = members.isSetPassword;
    bool isLogin = false;
    if (['', null, false].contains(AppGlobal.apiToken)) {
      isLogin = false;
    } else {
      isLogin = true;
    }
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleBar(
          paddingTop: ScreenUtil().statusBarHeight,
          title: '账号管理',
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.w),
                child: Center(
                    child: SizedBox(
                  width: 90.w,
                  height: 120.w,
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: showUpimg,
                            child: Container(
                              width: 90.w,
                              height: 90.w,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(45.w),
                                child: fileUrl != null
                                    ? Image.file(
                                        File(fileUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : UserAvatar(),
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: showUpimg,
                                child: PlatformAwareAssetImage(
                                    url: "assets/images/wode/edit_img_icon.png",
                                    width: 30.w,
                                    filterQuality: FilterQuality.medium),
                              ))
                        ],
                      ),
                      kIsWeb &&
                              Privilege.isAllowed(context, RESOURCE_TYPE_SYSTEM,
                                  PRIVILEGE_TYPE_SETTING)
                          ? Positioned(
                              child:
                                  HtmlElementView(viewType: 'AvatarFileInput'),
                            )
                          : Container()
                    ],
                  ),
                )),
              ),
              SetupItem(
                  title: '昵称',
                  rightText: members?.nickname.toString(),
                  isMarginBottom: true,
                  isAllRadius: true,
                  isBorderBottom: false,
                  onTap: () {
                    if (!Privilege.isAllowed(context, RESOURCE_TYPE_SYSTEM,
                        PRIVILEGE_TYPE_SETTING)) {
                      YyShowDialog.showdialog(
                        context,
                        content: (setDialogState) {
                          return Text(
                            '升级会员权限即可修改昵称～',
                            style: TextStyle(
                                color: Color(0xff646464),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          );
                        },
                        cancelText: '取消',
                        btnText: PPString.upgradeNuw,
                        callBack: () {
                          context.push('/vip');
                        },
                      );
                      return;
                    }
                    context.push(CommonUtils.getRealHash('fillcode'),
                        extra: {'type': 0});
                  }),
              Line(),
              SetupItem(
                  isTopRadius: true,
                  title: members?.phone == null
                      ? PPString.bindPhone
                      : PPString.changeBindPhone,
                  rightText: members?.phone == null
                      ? PPString.isnull
                      : members.phone.toString(),
                  onTap: () {
                    context.push(CommonUtils.getRealHash('fillcode'), extra: {
                      'type': members?.phone == null ? 1 : 2,
                      'phone': members?.phone,
                      "phonePrefix": members?.phonePrefix
                    });
                  }),
              AppGlobal.apiToken == '' && AppGlobal.apiToken != null
                  ? Container()
                  : Line(),
              AppGlobal.apiToken == '' && AppGlobal.apiToken != null
                  ? Container()
                  : SetupItem(
                      title: isSetPassword == 0
                          ? PPString.setPassword
                          : PPString.changePassword,
                      isTips: isSetPassword == 0,
                      rightText: isSetPassword == 0
                          ? PPString.phoneAndPasswordLogin
                          : PPString.isnull,
                      onTap: () {
                        context.push(CommonUtils.getRealHash('fillcode'),
                            extra: {'type': isSetPassword == 0 ? 6 : 5});
                      }),
              Line(),
              SetupItem(
                  title: '输入邀请码',
                  rightText:
                      (members?.invitedBy == null ? '' : members.invitedBy)
                          .toString(),
                  onTap: () {
                    if (members?.invitedBy == null) {
                      context.push(CommonUtils.getRealHash('fillcode'),
                          extra: {'type': 4});
                      // context.push(CommonUtils.getRealHash('fillcode'),
                      //     extra: {'title': '邀请码'});
                    }
                  }),
              Line(),
              SetupItem(
                  title: '输入兑换码',
                  onTap: () {
                    context.push(CommonUtils.getRealHash('fillcode'),
                        extra: {'type': 3});
                    // context.push(CommonUtils.getRealHash('fillcode'),
                    //     extra: {'title': '兑换码'});
                  }),
              Line(),
              SetupItem(
                  title: '账号凭证',
                  onTap: () {
                    CertificateModel.showCertificate(backButtonBehavior,
                        id: (members?.aff ?? '0000000').toString(),
                        code: (config?.share?.affCode ?? '0000').toString(),
                        url: (config?.share?.affUrl ?? '').toString());
                  }),
              Line(),
              SetupItem(
                  title: '清除缓存',
                  onTap: () {
                    AppGlobal.imageCacheBox.clear();
                    CommonUtils.showText('已清除缓存,请重启App');
                  }),
              Line(),
              SetupItem(
                  isBottomRadius: true,
                  title: '版本更新',
                  rightText: AppGlobal.isNewVersion
                      ? '已是最新版本(' +
                          AppGlobal.appinfo['version'].toString() +
                          ')'
                      : PPString.isNewVersion,
                  rightStyle: TextStyle(
                      color: Color(0xff979797),
                      decoration: TextDecoration.underline,
                      fontSize: 14.sp),
                  onTap: () {
                    if (AppGlobal.isNewVersion) {
                      CommonUtils.showText('已是最新版本哦～');
                    } else {
                      CommonUtils.launchURL(AppGlobal.officeSite);
                    }
                  }),
              SizedBox(
                height: 20,
              ),
              isLogin
                  ? GestureDetector(
                      onTap: () {
                        AppGlobal.apiToken = '';
                        clearToken();
                        context.pop('quit');
                      },
                      child: Center(
                        child: (Container(
                          height: 35.w,
                          margin: EdgeInsets.only(
                            bottom: ScreenUtil().bottomBarHeight == 0
                                ? 40.h
                                : ScreenUtil().bottomBarHeight + 40.w,
                          ),
                          width: 200.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17.5.w),
                              gradient: LinearGradient(
                                colors: [
                                  DefaultStyle.themeColor,
                                  DefaultStyle.linerThemeColor
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )),
                          child: Center(
                            child: Text(
                              '退出登录',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.sp),
                            ),
                          ),
                        )),
                      ),
                    )
                  : Container(),
            ],
          ),
        )),
      ],
    ));
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeConfig>(builder: (ctx, state, child) {
      return state.member?.thumb == null
          ? PlatformAwareAssetImage(
              url: 'assets/images/wode/setup_avatar.png',
              width: double.infinity,
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.medium)
          : PlatformAwareNetworkImage(
              fit: BoxFit.cover,
              url: state.member.thumb.toString(),
            );
    });
  }
}

class SetupItem extends StatelessWidget {
  const SetupItem(
      {Key key,
      this.title,
      this.rightText,
      this.isTips = false,
      this.onTap,
      this.isAllRadius = false,
      this.isTopRadius = false,
      this.isBottomRadius = false,
      this.isMarginBottom = false,
      this.isBorderBottom = true,
      this.rightStyle})
      : super(key: key);

  final String title;
  final String rightText;
  final bool isTips;
  final Function onTap;
  final bool isAllRadius;
  final bool isTopRadius;
  final bool isBottomRadius;
  final bool isMarginBottom;
  final bool isBorderBottom;
  final TextStyle rightStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                  left: 16.w, right: 16.w, bottom: (isMarginBottom ? 23 : 0).w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: isAllRadius
                    ? BorderRadius.all(Radius.circular(10))
                    : BorderRadius.only(
                        bottomLeft: Radius.circular(isBottomRadius ? 10.w : 0),
                        bottomRight: Radius.circular(isBottomRadius ? 10.w : 0),
                        topLeft: Radius.circular(isTopRadius ? 10.w : 0),
                        topRight: Radius.circular(isTopRadius ? 10.w : 0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isTips
                            ? Container(
                                margin: EdgeInsets.only(right: 10.w),
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5.w)),
                              )
                            : Container(),
                        Text(
                          title,
                          style: TextStyle(
                              color: Color(0xff6d6d6d),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.none),
                        )
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        rightText != null
                            ? Text(
                                rightText,
                                style: rightStyle == null
                                    ? TextStyle(
                                        color: Color(0xff979797),
                                        fontSize: 14.sp)
                                    : rightStyle,
                              )
                            : Container(),
                        SizedBox(
                          width: 8.w,
                        ),
                        PlatformAwareAssetImage(
                            url: 'assets/images/wode/setup_right.png',
                            width: 16.w,
                            height: 16.w,
                            filterQuality: FilterQuality.medium)
                      ],
                    )
                  ],
                ),
              ),
            ),
            isBorderBottom
                ? Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Container(
                        height: 0.5.h,
                        color: Color(0xffECECEC),
                      ),
                    ),
                  )
                : Container(),
          ],
        ));
  }
}

class Line extends StatelessWidget {
  const Line({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.white24,
      height: 0.5.w,
    );
  }
}
