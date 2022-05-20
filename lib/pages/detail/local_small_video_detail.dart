/*
 * @Author: Tom
 * @Date: 2021-12-21 16:16:22
 * @LastEditTime: 2021-12-27 17:03:31
 * @LastEditors: Tom
 * @Description: 
 * @FilePath: /flutter2021/lib/pages/details/local_small_video_detail.dart
 */
import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:pilipili/mixin/watchRecordMixin.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/shelf_proxy.dart';

class LocalSmallVideo extends StatefulWidget {
  LocalSmallVideo({Key key, this.videoInfo}) : super(key: key);
  final Map videoInfo;
  @override
  _LocalSmallVideoState createState() => _LocalSmallVideoState();
}

class _LocalSmallVideoState extends State<LocalSmallVideo> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff333333),
      body: Stack(
        children: [
          SmallVideoPlayer(
            data: widget.videoInfo,
          ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: ScreenUtil().setWidth(115.5),
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(15.5),
                    right: ScreenUtil().setWidth(15.5),
                    top: kIsWeb
                        ? ScreenUtil().setWidth(31)
                        : ScreenUtil().statusBarHeight +
                            ScreenUtil().setWidth(15),
                    bottom: ScreenUtil().setWidth(31)),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color.fromRGBO(0, 0, 0, 0.8),
                  Color.fromRGBO(0, 0, 0, 0)
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          child: Image.asset('assets/pengke/backarrow.png',
                              width: ScreenUtil().setWidth(22),
                              fit: BoxFit.fitWidth,
                              filterQuality: FilterQuality.high),
                        ),
                      ],
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class SmallVideoPlayer extends StatefulWidget {
  SmallVideoPlayer({Key key, this.data}) : super(key: key);
  final Map data;
  @override
  _SmallVideoPlayerState createState() => _SmallVideoPlayerState();
}

class _SmallVideoPlayerState extends State<SmallVideoPlayer>
    with WatchRecordMixin {
  VideoPlayerController _controller;
  bool videoInit = false; //视频是否初始化
  double videoValue = 0.0; //当前视频播放时间
  double videoMaxTime = 0.0; //视频总播放时间
  bool showControl = false; //中间播放暂停按钮的展示
  Timer timerfc; //播放暂停按钮的隐藏定时器
  bool changeStartIsPlay = false; //拖动进度条时视频是否处于播放状态
  bool loading = true;

  hideControl() {
    if (!showControl) {
      showControl = true;
      setState(() {});
    }

    if (timerfc != null) {
      timerfc.cancel();
      timerfc = Timer.periodic(Duration(seconds: 2), (time) {
        showControl = false;
        setState(() {});
        time.cancel();
      });
    } else {
      timerfc = Timer.periodic(Duration(seconds: 2), (time) {
        showControl = false;
        setState(() {});
        time.cancel();
      });
    }
  }

  getTimeStr(double time) {
    int s = (time / 1000 / 60).truncate();
    int h = (time / 1000 - (s * 60)).truncate();
    String timeStr(int numb) {
      return numb < 10 ? '0$numb' : numb.toString();
    }

    return '${timeStr(s)}:${timeStr(h)}';
  }

  @override
  void initState() {
    super.initState();
    initVideo(widget.data["url"]);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.removeListener(setVideovalue);
    if (timerfc != null && timerfc.isActive) {
      timerfc.cancel();
    }
    _controller?.dispose();
  }

  setVideovalue() {
    if (mounted) {
      try {
        var newVelue = _controller.value.position.inMilliseconds.toDouble();
        if (newVelue >= 0 && newVelue <= videoMaxTime) {
          videoValue = newVelue;
          if (_controller.value.buffered.isNotEmpty) {
            if (_controller.value.buffered.any((element) =>
                element.start.inSeconds <=
                    _controller.value.position.inSeconds &&
                element.end.inSeconds > _controller.value.position.inSeconds)) {
              loading = false;
            } else {
              loading = true;
            }
          }

          setState(() {});
        }
      } catch (e) {
        _controller.pause();
        CommonUtils.debugPrint('视频资源出现问题～');
        CommonUtils.debugPrint('************************************$e');
      }
    }
  }

  createVideo(url) {
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        _controller.setLooping(true);
        videoMaxTime = _controller.value.duration.inMilliseconds.toDouble();
        Timer.periodic(new Duration(seconds: 10), (timer) {
          timer.cancel();
        });
        if (mounted) {
          setState(() {});
        }
        _controller.addListener(setVideovalue);
        _controller.play();
      });
  }

  initVideo(url) {
    CommonUtils.debugPrint('===============视频地址:$url===================');
    // 创建本地播放服务
    createStaticServer(widget.data["url"]).then((url) => createVideo(url));
  }

  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_controller == null || !_controller.value.isInitialized) {
            return;
          }
          if (_controller.value.isPlaying) {
            showControl = true;
            setState(() {});
            _controller.pause();
          } else {
            hideControl();
            _controller.play();
          }
        },
        child: Stack(
          children: [
            _controller != null
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: _controller.value.isInitialized
                          ? Stack(
                              children: [
                                Center(
                                  child: AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: VideoPlayer(_controller),
                                  ),
                                ),
                                Positioned(
                                    child: mounted && loading
                                        ? Center(
                                            child: Container(
                                              width:
                                                  ScreenUtil().screenWidth / 5,
                                              child: Image.asset(
                                                  'assets/pengke/loading.gif',
                                                  fit: BoxFit.fitWidth,
                                                  filterQuality:
                                                      FilterQuality.high),
                                            ),
                                          )
                                        : Container())
                              ],
                            )
                          : mounted
                              ? Container(
                                  width: ScreenUtil().screenWidth / 5,
                                  child: Image.asset(
                                      'assets/pengke/loading.gif',
                                      fit: BoxFit.fitWidth,
                                      filterQuality: FilterQuality.high),
                                )
                              : Container(),
                    ),
                  )
                : mounted
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          children: [
                            Positioned(
                                child: Center(
                              child: Container(
                                width: ScreenUtil().screenWidth / 5,
                                child: Image.asset('assets/pengke/loading.gif',
                                    fit: BoxFit.fitWidth,
                                    filterQuality: FilterQuality.high),
                              ),
                            ))
                          ],
                        ),
                      )
                    : Container(),
            Positioned(
                child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          bottom: 0,
                          right: 0,
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(0, 0, 0, 0),
                                  Color.fromRGBO(0, 0, 0, 0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )),
                              padding: EdgeInsets.only(
                                  right: ScreenUtil().setWidth(18),
                                  left: ScreenUtil().setWidth(15.5),
                                  bottom: kIsWeb
                                      ? ScreenUtil().setWidth(18)
                                      : ScreenUtil().setWidth(18) +
                                          ScreenUtil().bottomBarHeight),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          widget.data["tags"] != null &&
                                                  widget.data["tags"].length > 0
                                              ? Text(
                                                  '#' +
                                                      widget.data["tags"]
                                                          .split("/")
                                                          .join("#"),
                                                  style: DefaultStyle.white14,
                                                )
                                              : Container(),
                                          SizedBox(
                                            height: ScreenUtil().setWidth(18.5),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.data["title"],
                                                style: DefaultStyle.white18bold,
                                              ),
                                              SizedBox(
                                                height:
                                                    ScreenUtil().setWidth(13),
                                              ),
                                              widget.data["desc"] != null &&
                                                      widget.data["desc"] != ''
                                                  ? Text(
                                                      widget.data["desc"],
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              255, 255, 255, 1),
                                                          fontSize: ScreenUtil()
                                                              .setSp(14),
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                    )
                                                  : Container(),
                                            ],
                                          )
                                        ],
                                      )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setWidth(18.5),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        getTimeStr(videoValue),
                                        style: DefaultStyle.white11,
                                      ),
                                      Expanded(
                                          child: SliderTheme(
                                              data: SliderTheme.of(context)
                                                  .copyWith(
                                                      trackHeight: ScreenUtil()
                                                          .setWidth(2),
                                                      inactiveTrackColor:
                                                          Colors.white24,
                                                      activeTrackColor:
                                                          Color(0xff37f4ff),
                                                      overlayColor:
                                                          Colors.white54,
                                                      thumbShape:
                                                          RoundSliderThumbShape(
                                                              enabledThumbRadius:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          5)),
                                                      overlayShape:
                                                          RoundSliderOverlayShape(
                                                        overlayRadius:
                                                            ScreenUtil()
                                                                .setWidth(9),
                                                      ),
                                                      thumbColor:
                                                          Color(0xff37f4ff)),
                                              child: Slider(
                                                  value:
                                                      videoValue >= videoMaxTime
                                                          ? videoMaxTime
                                                          : videoValue,
                                                  max: videoMaxTime,
                                                  min: 0,
                                                  onChangeStart: (e) {
                                                    changeStartIsPlay =
                                                        _controller
                                                            .value.isPlaying;
                                                    _controller.pause();
                                                  },
                                                  onChangeEnd: (e) {
                                                    if (changeStartIsPlay) {
                                                      _controller.play();
                                                    }
                                                  },
                                                  onChanged: (e) {
                                                    if (_controller
                                                        .value.isInitialized) {
                                                      videoValue = e;
                                                      setState(() {});
                                                      _controller.seekTo(
                                                          Duration(
                                                              milliseconds:
                                                                  videoValue
                                                                      .toInt()));
                                                    }
                                                  }))),
                                      Text(
                                        getTimeStr(videoMaxTime),
                                        style: DefaultStyle.white11,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )),
                        _controller == null
                            ? Container()
                            : Positioned(
                                top: 0,
                                left: 0,
                                bottom: 0,
                                right: 0,
                                child: AnimatedOpacity(
                                  opacity: showControl ||
                                          !_controller.value.isPlaying
                                      ? 1
                                      : 0,
                                  duration: Duration(milliseconds: 300),
                                  child: Center(
                                    child: Image.asset(
                                        'assets/pengke/video/${_controller.value.isPlaying ? 'stop-icon' : 'play-icon'}.png',
                                        width: ScreenUtil().setWidth(80),
                                        height: ScreenUtil().setWidth(80),
                                        filterQuality: FilterQuality.high),
                                  ),
                                ))
                      ],
                    )))
          ],
        ));
  }
}
