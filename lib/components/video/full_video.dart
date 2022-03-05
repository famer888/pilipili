import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pilipili/components/video/YyVideo.dart';
import 'package:video_player/video_player.dart';

class FullVideo extends StatefulWidget {
  FullVideo({Key key, this.controller}) : super(key: key);
  final VideoPlayerController controller;
  @override
  _FullVideoState createState() => _FullVideoState();
}

class _FullVideoState extends State<FullVideo> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54,
        body: SafeArea(
          child: YyVideo(
            loop: true,
            controller: widget.controller,
            isFull: true,
          ),
        ));
  }
}
