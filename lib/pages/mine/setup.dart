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
        uploadInput.setAttribute('style',
            'width: ${ScreenUtil().setWidth(90)}px; height: ${ScreenUtil().setWidth(120)}px; opacity: 0');
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

  _setupItem(
      {String title,
      String rightText,
      bool isTips = false,
      Function onTap,
      bool isAllRadius = false,
      bool isTopRadius = false,
      bool isBottomRadius = false,
      bool isMarginBottom = false,
      bool isBorderBottom = true,
      TextStyle rightStyle}) {
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
                  left: ScreenUtil().setWidth(16),
                  right: ScreenUtil().setWidth(16),
                  bottom: ScreenUtil().setWidth(isMarginBottom ? 23 : 0)),
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: isAllRadius
                    ? BorderRadius.all(Radius.circular(10))
                    : BorderRadius.only(
                        bottomLeft: Radius.circular(isBottomRadius ? 10 : 0),
                        bottomRight: Radius.circular(isBottomRadius ? 10 : 0),
                        topLeft: Radius.circular(isTopRadius ? 10 : 0),
                        topRight: Radius.circular(isTopRadius ? 10 : 0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(18),
                    vertical: ScreenUtil().setWidth(18)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isTips
                            ? Container(
                                margin: EdgeInsets.only(
                                    right: ScreenUtil().setWidth(10)),
                                width: ScreenUtil().setWidth(10),
                                height: ScreenUtil().setWidth(10),
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setWidth(5))),
                              )
                            : Container(),
                        Text(
                          title,
                          style: DefaultStyle.black12,
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
                                        color: Color(0xffd7d7d7),
                                        fontSize: ScreenUtil().setSp(14))
                                    : rightStyle,
                              )
                            : Container(),
                        SizedBox(
                          width: ScreenUtil().setWidth(8),
                        ),
                        Image.asset(
                          'assets/images/wode/setup_right.png',
                          width: ScreenUtil().setWidth(16),
                          height: ScreenUtil().setWidth(16),
                        )
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
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(30)),
                      child: Container(
                        height: ScreenUtil().setHeight(0.5),
                        color: Color(0xffECECEC),
                      ),
                    ),
                  )
                : Container(),
          ],
        ));
  }

  _line() {
    return Container(
      width: double.infinity,
      color: Colors.white24,
      height: ScreenUtil().setWidth(0.5),
    );
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
              height: ScreenUtil().setWidth(12.5),
            ),
            Text(
              '上传中...',
              style: TextStyle(
                  color: Colors.white, fontSize: ScreenUtil().setSp(14)),
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
        title: '提示',
        content: (setDialogState) {
          return Text(
            '升级会员权限即可修改头像～',
            style: TextStyle(
                color: Color(0xffFF5B8C),
                fontSize: ScreenUtil().setSp(15),
                decoration: TextDecoration.none),
          );
        },
        cancelText: '取消',
        btnText: '立即升级',
        callBack: () {
          // context.push('/${Routes.vip}');
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
                height: ScreenUtil().setWidth(110) +
                    (kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
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
                              fontSize: ScreenUtil().setSp(15)),
                        ))),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Color(0xffeeeeee),
                        width: ScreenUtil().setWidth(1),
                      ))),
                    ),
                    TextButton(
                        onPressed: () {
                          loadAssets('gallery');
                          context.pop();
                        },
                        child: Container(
                          height: ScreenUtil().setWidth(49),
                          child: Center(
                              child: Text(
                            '从相册选择',
                            style: TextStyle(
                                color: Color(0xff333333),
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenUtil().setSp(15)),
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
    int isSetPassword =
        Provider.of<HomeConfig>(context, listen: false).member.isSetPassword;
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
                padding:
                    EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30)),
                child: Center(
                    child: Container(
                  width: ScreenUtil().setWidth(90),
                  height: ScreenUtil().setWidth(120),
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: showUpimg,
                            child: Container(
                              width: ScreenUtil().setWidth(90),
                              height: ScreenUtil().setWidth(90),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil().setWidth(45)),
                                child: fileUrl != null
                                    ? Image.file(
                                        File(fileUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "assets/images/wode/setup_avatar.png",
                                        fit: BoxFit.fill,
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: showUpimg,
                                child: Image.asset(
                                  "assets/images/wode/edit_img_icon.png",
                                  width: ScreenUtil().setWidth(30),
                                ),
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
              _setupItem(
                  title: '昵称',
                  rightText: '${members?.nickname}',
                  isMarginBottom: true,
                  isAllRadius: true,
                  isBorderBottom: false,
                  onTap: () {
                    if (!Privilege.isAllowed(context, RESOURCE_TYPE_SYSTEM,
                        PRIVILEGE_TYPE_SETTING)) {
                      YyShowDialog.showdialog(
                        context,
                        title: '提示',
                        content: (setDialogState) {
                          return Text(
                            '升级会员权限即可修改昵称～',
                            style: TextStyle(
                                color: Color(0xffFF5B8C),
                                fontSize: ScreenUtil().setSp(15),
                                decoration: TextDecoration.none),
                          );
                        },
                        cancelText: '取消',
                        btnText: '立即升级',
                        callBack: () {
                          // context.push('/${Routes.vip}');
                        },
                      );
                      return;
                    }
                    context.push(CommonUtils.getRealHash('fillcode'),
                        extra: {'type': 0});
                  }),
              _line(),
              _setupItem(
                  isTopRadius: true,
                  title: members?.phone == null ? '绑定手机' : '更换绑定手机',
                  rightText: members?.phone == null ? '' : '${members.phone}',
                  onTap: () {
                    context.push(CommonUtils.getRealHash('fillcode'), extra: {
                      'type': members?.phone == null ? 1 : 2,
                      'phone': members?.phone
                    });
                    // context.push('/${Routes.login}',
                    //     extra: {'type': members?.phone == null ? 5 : 4});
                  }),
              AppGlobal.apiToken == '' && AppGlobal.apiToken != null
                  ? Container()
                  : _line(),
              AppGlobal.apiToken == '' && AppGlobal.apiToken != null
                  ? Container()
                  : _setupItem(
                      title: isSetPassword == 0 ? '设置密码' : '更换密码',
                      isTips: isSetPassword == 0,
                      rightText: isSetPassword == 0 ? '手机号+密码一键登录' : '',
                      onTap: () {
                        context.push('/${Routes.login}',
                            extra: {'type': isSetPassword == 0 ? 6 : 2});
                      }),
              _line(),
              _setupItem(
                  title: '输入邀请码',
                  rightText:
                      '${members?.invitedBy == null ? '' : members.invitedBy}',
                  onTap: () {
                    if (members?.invitedBy == null) {
                      context.push(CommonUtils.getRealHash('fillcode'),
                          extra: {'type': 4});
                      // context.push(CommonUtils.getRealHash('fillcode'),
                      //     extra: {'title': '邀请码'});
                    }
                  }),
              _line(),
              _setupItem(
                  title: '输入兑换码',
                  onTap: () {
                    context.push(CommonUtils.getRealHash('fillcode'),
                        extra: {'type': 3});
                    // context.push(CommonUtils.getRealHash('fillcode'),
                    //     extra: {'title': '兑换码'});
                  }),
              _line(),
              _setupItem(
                  title: '账号凭证',
                  onTap: () {
                    CertificateModel.showCertificate(backButtonBehavior,
                        id: '${members?.aff ?? '0000000'}',
                        code: '${config?.share?.affCode ?? '0000'}',
                        url: '${config?.share?.affUrl ?? ''}');
                  }),
              _line(),
              _setupItem(
                  title: '清除缓存',
                  onTap: () {
                    AppGlobal.imageCacheBox.clear();
                    CommonUtils.showText('已清除缓存,请重启App');
                  }),
              _line(),
              _setupItem(
                  isBottomRadius: true,
                  title: '版本更新',
                  rightText: AppGlobal.isNewVersion
                      ? '已是最新版本(${AppGlobal.appinfo['version']})'
                      : '有新版本,去更新？',
                  rightStyle: TextStyle(
                      color: Color(0xff979797),
                      decoration: TextDecoration.underline,
                      fontSize: ScreenUtil().setSp(14)),
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
                          height: ScreenUtil().setWidth(35),
                          margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).padding.bottom),
                          width: ScreenUtil().setWidth(200),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ScreenUtil().setWidth(17.5)),
                              gradient: LinearGradient(
                                colors: [Color(0xffFF84A9), Color(0xffFF9E9E)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )),
                          child: Center(
                            child: Text(
                              '退出登录',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(15)),
                            ),
                          ),
                        )),
                      ),
                    )
                  : Container()
            ],
          ),
        )),
      ],
    ));
  }
}

// class UserAvatar extends StatelessWidget {
//   const UserAvatar({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeConfig>(builder: (ctx, state, child) {
//       return state.member?.thumb == null
//           ? PlatformAwareAssetImage(
//               url: 'assets/images/wode/avatar.png',
//               width: double.infinity,
//               fit: BoxFit.fitHeight,
//             )
//           : PlatformAwareNetworkImage(
//               fit: BoxFit.cover,
//               url: '${state.member.thumb}',
//             );
//     });
//   }
// }
