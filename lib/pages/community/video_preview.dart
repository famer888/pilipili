import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/video/YyVideo.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({Key key, this.url, this.cover}) : super(key: key);
  final String url;
  final String cover;
  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YyVideo(
        videoUrl: widget.url,
        cover: widget.cover,
        loop: true,
      ),
    );
  }
}
