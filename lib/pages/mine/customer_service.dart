import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/feedback.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/http.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:http_parser/http_parser.dart';

class CustomerService extends StatefulWidget {
  CustomerService({Key key}) : super(key: key);

  @override
  _CustomerServiceState createState() => _CustomerServiceState();
}

class _CustomerServiceState extends State<CustomerService>
    with WidgetsBindingObserver {
  bool isInit = true;
  bool fetching = false;
  bool networkErr = false;
  RegExp regExp = new RegExp(
    r"(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?",
    multiLine: true,
  );
  String thumb;
  int page = 1;
  TextEditingController editingController = TextEditingController();
  ScrollController scrollControllerFalse = ScrollController();
  List helpList;
  List msgList;
  bool isAll = false;
  getMsgPath(String msg, int status) {
    var isPath = regExp.hasMatch(msg);
    var pathMsg = msg.replaceAll('http', '[youyu]http');
    var pathList = pathMsg.split('[youyu]');
    var textList = [];
    for (var i = 0; i < pathList.length; i++) {
      if (regExp.hasMatch(pathList[i])) {
        var newMsg = regExp.stringMatch(pathList[i]) == null
            ? pathList[i]
            : pathList[i].replaceAll(regExp.stringMatch(pathList[i]),
                '[youyu]${regExp.stringMatch(pathList[i])}[youyu]');
        textList.addAll(newMsg.split('[youyu]'));
      } else {
        textList.add(pathList[i]);
      }
    }

    return isPath
        ? Text.rich(TextSpan(
            children: textList
                .asMap()
                .keys
                .map((e) => TextSpan(
                      text: textList[e],
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        color: regExp.hasMatch(textList[e])
                            ? Color(0xff7bf7ff)
                            : Color(0xffd7d7d7),
                        decoration: regExp.hasMatch(textList[e])
                            ? TextDecoration.underline
                            : null,
                        height: 1.7,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          CommonUtils.launchURL(textList[e]);
                        },
                    ))
                .toList()))
        : Text(
            msg,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(15),
              color: status == 1 ? Colors.white : Color(0xff6D6D6D),
              height: 1.7,
            ),
            softWrap: true,
          );
  }

  //拉取消息列表
  getFeedback() async {
    setState(() {
      networkErr = false;
    });
    if (fetching) return null;
    fetching = true;
    var feedback = await getFeedbackList(page: page);
    if (page == 1) {
      if (feedback != null && feedback.status != 0) {
        msgList = feedback.data;
        // Datum msgResult = Datum.fromJson({
        //   "messageType": 1,
        //   "status": 0,
        //   "createdAt": null,
        //   "message": "123123",

        //   "thumb": thumb
        // });
        // msgList.insert(0, msgResult);
        setState(() {});
      } else {
        setState(() {
          networkErr = true;
        });
        return;
      }
    } else {
      if (feedback.status != 0 && feedback.data.length > 0) {
        setState(() {
          msgList.addAll(feedback.data);
        });
      } else {
        isAll = true;
      }
    }
    fetching = false;
    page++;
  }

//发送消息
  _sendMsg() async {
    var text = editingController.text?.trim() ?? "";
    setState(() {
      editingController.text = '';
    });
    if (text.isNotEmpty) {
      var msg = await sendFeeding(text, 1, 0);
      if (msg != null && msg.status != 0) {
        setState(() {
          Datum msgResult = Datum.fromJson({
            "messageType": 1,
            "status": 1,
            "createdAt": null,
            "message": text,
            "thumb": thumb
          });
          msgList.insert(0, msgResult);
        });
      } else {
        CommonUtils.showText('网络不佳,请重新尝试～');
      }
    }
  }

  getBase64(file, Function done) {
    html.FileReader reader = html.FileReader();
    reader.readAsDataUrl(file);
    reader.onLoadEnd.listen((_event) {
      done(reader.result);
    });
  }

  html.InputElement uploadInput;
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addObserver(this);
    }
    getFeedback();
    if (kIsWeb) {
      platformViewRegistry.registerViewFactory('FileInput', (viewId) {
        uploadInput = html.FileUploadInputElement();
        uploadInput.accept = 'image/*';
        uploadInput.setAttribute('style',
            'width: ${ScreenUtil().setWidth(25)}px; height: ${ScreenUtil().setWidth(23)}px; opacity: 0');
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

  FocusNode _commentFocus = FocusNode();
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
          _commentFocus.unfocus();
        }
      });
    }
  }

  Future<void> loadAssets(String type) async {
    ImagePicker _picker = ImagePicker();
    if (type == 'camera') {
      _picker.pickImage(source: ImageSource.camera).then((XFile file) {
        upImage(file.path);
      });
    } else {
      XFile photo = await _picker.pickImage(source: ImageSource.gallery);
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
        imageUrl: filePath, position: 'upload');
    var res = jsonDecode(result.data);
    if (res['code'] == 1) {
      var msg = await sendFeeding(res['msg'], 2, 0);
      if (msg.status != 0) {
        Datum msgResult = Datum.fromJson({
          "messageType": 2,
          "status": 1,
          "isLocal": 1,
          "createdAt": null,
          "message": kIsWeb ? imgfile : filePath,
          "thumb": thumb
        });
        setState(() {
          msgList.insert(0, msgResult);
        });
        BotToast.closeAllLoading();
      } else {
        BotToast.showText(text: '图片发送失败，请重试～', align: Alignment(0, 0));
        BotToast.closeAllLoading();
      }
    } else {
      BotToast.showText(text: res['msg'], align: Alignment(0, 0));
      BotToast.closeAllLoading();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (kIsWeb) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  void showUpimg() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context1, state) {
              return Container(
                height: ScreenUtil().setWidth(100) +
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
                    Container(
                      height: ScreenUtil().setWidth(49),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Color(0xffeeeeee),
                        width: ScreenUtil().setWidth(2),
                      ))),
                      child: FlatButton(
                          onPressed: () {
                            // _enableCamera();
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
                    ),
                    FlatButton(
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

  _serviceDialog(item, index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: item.createdAt != null
              ? Text(
                  item.createdAt,
                  style: TextStyle(
                      color: Color(0xffb4b4b4),
                      fontSize: ScreenUtil().setSp(13)),
                )
              : Container(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/wode/customer_avatar.png',
                  width: ScreenUtil().setWidth(40),
                  height: ScreenUtil().setWidth(40),
                  filterQuality: FilterQuality.high),
              SizedBox(
                width: ScreenUtil().setWidth(5),
              ),
              Flexible(
                  child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: ScreenUtil().setHeight(5),
                    child: Image.asset(
                        "assets/images/wode/send_message_left.png",
                        width: ScreenUtil().setWidth(10),
                        fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.high),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: ScreenUtil().setWidth(0.5),
                            color: Color(0xffffffff)),
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(10.5),
                        vertical: ScreenUtil().setWidth(6.5)),
                    child: item.messageType == 1
                        ? getMsgPath(item.message, item.status)
                        : (item.isLocal != null
                            ? Image.file(
                                new File(item.message),
                                fit: BoxFit.contain,
                                width: ScreenUtil().setHeight(150),
                                height: ScreenUtil().setHeight(150),
                              )
                            : Container(
                                width: ScreenUtil().setHeight(150),
                                height: ScreenUtil().setHeight(150),
                                child: PlatformAwareNetworkImage(
                                    url: item.message),
                              )),
                  )
                ],
              ))
            ],
          ),
        )
      ],
    );
  }

  _useDialog(item, index) {
    var image;
    if (!kIsWeb) {
      image = Image.file(
        new File(item.message),
        fit: BoxFit.contain,
        width: ScreenUtil().setHeight(150),
        height: ScreenUtil().setHeight(150),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: item.createdAt != null
              ? Text(
                  item.createdAt,
                  style: TextStyle(
                      color: Color(0xffb4b4b4),
                      fontSize: ScreenUtil().setSp(13)),
                )
              : Container(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                  child: Stack(
                children: [
                  Container(
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(9)),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: ScreenUtil().setWidth(0.5),
                              color: Color(0xffFF84A9)),
                          color: Color(0xffFF84A9),
                          borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10.5),
                          vertical: ScreenUtil().setWidth(6.5)),
                      child: item.messageType == 1
                          ? getMsgPath(item.message, item.status)
                          : (item.isLocal != null
                              ? kIsWeb
                                  ? Image.memory(
                                      base64.decode(item.message.split(',')[1]),
                                      fit: BoxFit.contain,
                                      width: ScreenUtil().setHeight(150),
                                      height: ScreenUtil().setHeight(150),
                                      gaplessPlayback: true,
                                    )
                                  : image
                              : Container(
                                  width: ScreenUtil().setHeight(150),
                                  height: ScreenUtil().setHeight(150),
                                  child: PlatformAwareNetworkImage(
                                      url: item.message),
                                ))),
                  Positioned(
                      bottom: ScreenUtil().setHeight(2),
                      right: 0,
                      child: Image.asset(
                          "assets/images/wode/send_message_right.png",
                          width: ScreenUtil().setWidth(10),
                          fit: BoxFit.fitWidth,
                          filterQuality: FilterQuality.high)),
                ],
              )),
              SizedBox(
                width: ScreenUtil().setWidth(9.5),
              ),
              // PlatformAwareAssetImage(
              //   url: 'assets/images/mine/service_i.png',
              //   width: ScreenUtil().setWidth(50),
              //   height: ScreenUtil().setWidth(50),
              // ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _commentFocus.unfocus();
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleBar(
              paddingTop: ScreenUtil().statusBarHeight,
              title: '客服',
            ),
            msgList == null
                ? Center(
                    child: PageStatus.loading(mounted),
                  )
                : Expanded(
                    child: msgList.length == 0
                        ? SingleChildScrollView(
                            child: Center(
                              child: PageStatus.noData(),
                            ),
                          )
                        : ListView.builder(
                            cacheExtent: ScreenUtil().screenHeight * 5,
                            itemCount: msgList.length,
                            reverse: true,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                                horizontal: DefaultStyle.pagePadding,
                                vertical: ScreenUtil().setWidth(30)),
                            itemBuilder: (BuildContext context, int index) {
                              return msgList[index].status == 1
                                  ? _useDialog(msgList[index], index)
                                  : _serviceDialog(msgList[index], index);
                            })),
            msgList == null
                ? Container()
                : Container(
                    // padding: EdgeInsets.only(
                    //     bottom: MediaQuery.of(context).padding.bottom),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        //阴影
                        BoxShadow(
                            color: Color.fromRGBO(255, 132, 169, 0.2),
                            offset: Offset(0, 0),
                            blurRadius: ScreenUtil().setWidth(10))
                      ],
                    ),
                    padding: EdgeInsets.only(
                        left: DefaultStyle.pagePadding,
                        right: DefaultStyle.pagePadding,
                        bottom: MediaQuery.of(context).padding.bottom),
                    // height: ScreenUtil().setWidth(50),
                    child: Row(
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(30),
                          height: ScreenUtil().setWidth(30),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: kIsWeb ? null : showUpimg,
                                child: Image.asset(
                                    'assets/images/wode/send_img_icon.png',
                                    width: ScreenUtil().setWidth(30),
                                    height: ScreenUtil().setWidth(30),
                                    filterQuality: FilterQuality.high),
                              ),
                              kIsWeb
                                  ? Positioned(
                                      child: HtmlElementView(
                                          viewType: 'FileInput'),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setHeight(8),
                              horizontal: ScreenUtil().setWidth(15)),
                          child: TextField(
                              autofocus: !kIsWeb,
                              // onSubmitted: _onSubmit,
                              focusNode: _commentFocus,
                              controller: editingController,
                              style: TextStyle(
                                color: Color(0xff979797),
                                fontSize: ScreenUtil().setSp(14),
                              ),
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                  hintText: '输入回复内容',
                                  hintStyle:
                                      TextStyle(color: Color(0xff979797)),
                                  contentPadding: EdgeInsets.zero,
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 0)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 0)))),
                        )),
                        GestureDetector(
                            onTap: _sendMsg,
                            child: Stack(children: [
                              Container(
                                width: ScreenUtil().setWidth(64),
                                height: ScreenUtil().setHeight(30),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xffFF84A9),
                                        Color(0xffFF9E9E)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setWidth(50))),
                                child: Center(
                                  child: Text(
                                    '发送',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(12),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ]))
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
