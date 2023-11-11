import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/http.dart';

class XFileProgressToast extends StatefulWidget {
  const XFileProgressToast(
      {@required this.file, @required this.response, this.cancel})
      : super();
  final XFile file;
  final Function(Map) response;
  final Function() cancel;

  @override
  State<XFileProgressToast> createState() => _XFileProgressToastState();
}

class _XFileProgressToastState extends State<XFileProgressToast> {
  ValueNotifier<String> progress = ValueNotifier('上传中...');
  CancelToken cancelToken = CancelToken();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _upData();
  }

  @override
  void dispose() {
    progress.dispose();
    super.dispose();
  }

  _upData() async {
    if (kIsWeb) {
      var res = await PlatformAwareHttp.xfileBytesUploadMp4(
        cancelToken: cancelToken,
        file: widget.file,
        position: 'upload',
        progressCallback: (count, total) {
          CommonUtils.debugPrint("---$count--$total");
          var tmp = (count / total * 100).toInt();
          progress.value = "上传进度: $tmp%";
        },
      );
      widget.response(res == null ? {} : jsonDecode(res));
    } else {
      var res = await PlatformAwareHttp.xfileUploadMp4(
        cancelToken: cancelToken,
        file: widget.file,
        position: 'upload',
        progressCallback: (count, total) {
          CommonUtils.debugPrint("---$count--$total");
          var tmp = (count / total * 100).toInt();
          progress.value = "上传进度: $tmp%";
        },
      );
      print(res);
      widget.response(res == null ? {} : jsonDecode(res));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          color: Colors.transparent,
          height: 110.w,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30.w,
                width: 30.w,
                child: CircularProgressIndicator(
                  color: DefaultStyle.themeColor,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(height: 12.w),
              ValueListenableBuilder(
                  valueListenable: progress,
                  builder: (context, text, child) {
                    return Text(text, style: DefaultStyle.white14);
                  })
            ],
          ),
        ),
        SizedBox(height: 20.w),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            cancelToken.cancel();
            widget.cancel?.call();
          },
          child: Container(
            height: 30.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
                gradient: DefaultStyle.defaluGrandientLine,
                borderRadius: BorderRadius.all(Radius.circular(3.w))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('取消上传', style: DefaultStyle.white16)],
            ),
          ),
        )
      ],
    );
  }
}
