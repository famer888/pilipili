import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/video/YyVideo.dart';
import 'package:flutter/foundation.dart';

class LocalVideoDetail extends StatefulWidget {
  LocalVideoDetail({Key key, this.videoInfo}) : super(key: key);
  final dynamic videoInfo;
  @override
  _LocalVideoDetailState createState() => _LocalVideoDetailState();
}

class _LocalVideoDetailState extends State<LocalVideoDetail> {
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: ScreenUtil().setWidth(210),
            width: double.infinity,
            color: Colors.black45,
            child: Stack(
              children: [
                YyVideo(videoUrl: widget.videoInfo["url"], isLocal: true, loop: true,),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
