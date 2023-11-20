import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/http.dart';
import 'package:pilipili/utils/networkImage.dart';

class FileUploadItem extends StatefulWidget {
  const FileUploadItem({Key key, this.index, this.type = 1, this.data})
      : super(key: key);
  final int index;
  final Map data;
  final int type;
  @override
  State<FileUploadItem> createState() => FileUploadItemState();
}

class FileUploadItemState extends State<FileUploadItem> {
  Map dataInfo = {};
  CancelToken cancelToken = CancelToken();
  ValueNotifier<int> progress = ValueNotifier(0);
  ValueNotifier<bool> showLoad = ValueNotifier(false);
  Uint8List filePath;
  bool showWidget = true;
  bool isFile = false;
  getFilepath() async {
    filePath = await widget.data['file'].readAsBytes();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.data['file'] != null) {
      isFile = true;
      getFilepath();
      widget.type == 1
          ? uploadFileImg(widget.data['file'])
          : uploadVideo(widget.data['file']);
    } else {
      dataInfo = {
        'media_url': widget.data['media_url'],
        'cover': widget.data['cover'],
        'type': widget.data['type'],
        'w': widget.data['w'],
        'h': widget.data['h'],
      };
    }
  }

  closeWidget() {
    showWidget = false;
    showLoad.value = false;
    if (isFile) {
      cancelToken.cancel();
    }
    setState(() {});
  }

  void uploadFileImg(XFile file) async {
    var data;
    showLoad.value = true;
    Uint8List bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes.toList());
    int imageWidth = image.width;
    int imageHeight = image.height;
    if (kIsWeb) {
      data = await PlatformAwareHttp.xfileHtmlUploadImage(
          file: file, position: 'upload');
    } else {
      data = await PlatformAwareHttp.xfileUploadImage(
          file: file, position: 'upload');
    }
    if (data['code'] == 1) {
      String orgURL = data['msg'] ?? '';
      dataInfo = {
        'media_url': orgURL,
        'cover': AppGlobal.bannerImgBase + orgURL,
        'type': 1,
        'w': imageWidth,
        'h': imageHeight
      };
    } else {
      CommonUtils.showText(data['msg'] ?? "failed");
    }
    showLoad.value = false;
  }

  void uploadVideo(XFile file) async {
    showLoad.value = true;
    if (kIsWeb) {
      var res = await PlatformAwareHttp.xfileBytesUploadMp4(
        cancelToken: cancelToken,
        file: file,
        position: 'upload',
        progressCallback: (count, total) {
          CommonUtils.debugPrint("---$count--$total");
          var tmp = (count / total * 100).toInt();
          progress.value = tmp;
        },
      );
      if (res == null) {
        CommonUtils.showText('上传失败');
        showWidget = false;
        setState(() {});
        return;
      } else {
        Map data = jsonDecode(res);
        if (data['status'] != 0) {
          dataInfo = {
            'media_url': data['msg'],
            'cover': '',
            'type': 1,
            'w': 0,
            'h': 0
          };
        } else {
          CommonUtils.showText(res['msg'] ?? '上传失败');
          showWidget = false;
          setState(() {});
        }
      }
    } else {
      var res = await PlatformAwareHttp.xfileUploadMp4(
        cancelToken: cancelToken,
        file: file,
        position: 'upload',
        progressCallback: (count, total) {
          CommonUtils.debugPrint("---$count--$total");
          var tmp = (count / total * 100).toInt();
          progress.value = tmp;
        },
      );
      if (res == null) {
        CommonUtils.showText('上传失败');
        showWidget = false;
        setState(() {});
        return;
      } else {
        Map data = jsonDecode(res);
        if (data['status'] != 0) {
          dataInfo = {
            'media_url': data['msg'],
            'cover': '',
            'type': 1,
            'w': 0,
            'h': 0
          };
        } else {
          CommonUtils.showText(res['msg'] ?? '上传失败');
          showWidget = false;
          setState(() {});
        }
      }
    }
    showLoad.value = false;
  }

  @override
  void dispose() {
    progress.dispose();
    super.dispose();
  }

  getProgress() {
    return Positioned.fill(
        child: Container(
      color: Color(0xff790024).withOpacity(0.4),
      alignment: Alignment.center,
      child: ValueListenableBuilder(
          valueListenable: progress,
          builder: (context, value, child) {
            return SizedBox(
              width: 88.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$value%',
                    style: TextStyle(color: Colors.white, fontSize: 11.sp),
                  ),
                  Stack(
                    children: [
                      Container(
                        height: 3.w,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.w),
                            color: Colors.white.withOpacity(0.4)),
                      ),
                      Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 88.w * (value / 100),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    gradient: LinearGradient(
                                        colors: [
                                          Color.fromRGBO(255, 174, 198, 1),
                                          Color.fromRGBO(255, 77, 131, 1),
                                          Color.fromRGBO(255, 7, 83, 1)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)),
                              ),
                              Positioned(
                                  right: -4.w,
                                  top: -3.5,
                                  child: getImage(
                                      'assets/images/2023/vector.png',
                                      width: 10.w,
                                      fit: BoxFit.fitWidth,
                                      isAssets: true))
                            ],
                          ))
                    ],
                  )
                ],
              ),
            );
          }),
    ));
  }

  getFileWidget() {
    if (widget.type == 1) {
      return Stack(
        children: [
          isFile
              ? (filePath == null
                  ? PlatformAwareNetworkImage(
                      url: '',
                    )
                  : Image.memory(
                      filePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ))
              : PlatformAwareNetworkImage(
                  url: widget.data['cover'],
                  fit: BoxFit.cover,
                ),
          ValueListenableBuilder(
            valueListenable: showLoad,
            builder: (context, value, child) {
              return value ? child : SizedBox();
            },
            child: getProgress(),
          )
        ],
      );
    } else {
      return Stack(
        children: [
          getImage(
            'assets/images/2023/upload_video_bg.png',
            fit: BoxFit.cover,
            isAssets: true,
          ),
          ValueListenableBuilder(
            valueListenable: showLoad,
            builder: (context, value, child) {
              return value ? child : SizedBox();
            },
            child: getProgress(),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!showWidget) {
      return SizedBox();
    }
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.w),
          boxShadow: [
            BoxShadow(
                color: Color(0xffFFD3E6),
                offset: Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0)
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.w),
        child: Stack(
          children: [
            SizedBox(
              width: 120.w,
              height: 80.w,
              child: getFileWidget(),
            ),
            Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: closeWidget,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15.w)),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xffFF8B8B).withOpacity(0.8),
                              Color(0xffFF7696).withOpacity(0.8),
                              Color(0xffFF7299).withOpacity(0.8)
                            ])),
                    child: getImage('assets/images/2023/icon_close.png',
                        width: 12.w, height: 12.w, isAssets: true),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
