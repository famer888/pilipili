import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/video/YyVideo.dart';
import 'package:pilipili/components/video/full_video.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/mixin/video_mixin.dart';
import 'package:pilipili/mixin/watchRecordMixin.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:video_player/video_player.dart';

class VideoController extends StatefulWidget {
  VideoController(
      {Key key,
      this.videoController,
      this.isCardAuto,
      this.hideControl,
      this.initShow = false,
      this.id,
      this.data,
      this.autoPlay,
      this.loop,
      this.noVolume,
      this.noBack,
      this.isFull,
      this.setController,
      this.videoUrl,
      this.setVideoUrl,
      this.isLocal,
      this.uploadVideo,
      this.isPreview,
      this.setPreviewShow,
      this.previewShow})
      : super(key: key);
  final VideoPlayerController videoController;
  final bool isCardAuto;
  final bool hideControl;
  final bool initShow;
  final String id;
  final dynamic data;
  final bool autoPlay;
  final bool loop;
  final bool noVolume;
  final bool noBack;
  final bool isFull;
  final String videoUrl;
  final Function setVideoUrl;
  final Function uploadVideo;
  final bool isLocal;
  final SetControllerCallback setController;
  final bool isPreview;
  final Function setPreviewShow;
  final bool previewShow;
  @override
  _VideoControllerState createState() => _VideoControllerState();
}

class _VideoControllerState extends State<VideoController>
    with WatchRecordMixin, VideoMinxin {
  bool showControl = false; //控制器展示
  bool isLock = false; //锁定状态
  Timer timerfc; //播放暂停按钮的隐藏定时器
  double videoValue = 0.0; //当前视频播放时间
  double videoMaxTime = 0.0; //视频总播放时间
  bool changeStartIsPlay = false; //拖动进度条时视频是否处于播放状态
  bool videoPageIsActive = true;
  bool loading = true;
  bool seekHistory = false;
  double panStart = 0;
  bool showUpTime = false;
  double upValue = 0;
  bool usecheck = false;
  bool videoPlayErr = false;
  dynamic bytes;
  @override
  void initState() {
    super.initState();
    if (widget.initShow) {
      showControl = true;
    }
    EventBus().on('stop-current-play', (arg) {
      if (widget.videoController != null &&
          widget.videoController.value.isPlaying) {
        widget.videoController.pause();
      }
      videoPageIsActive = false;
    });
    if (widget.videoController?.value.isInitialized) {
      videoMaxTime =
          widget.videoController.value.duration.inMilliseconds.toDouble();
      videoValue =
          widget.videoController.value.position.inMilliseconds.toDouble();
      setState(() {});
      widget.videoController.addListener(setVideoValue);
    } else {
      initVideo();
    }
  }

  initVideo() {
    if (videoPlayErr) {
      videoPlayErr = false;
      setState(() {});
    }
    widget.videoController
      ..initialize().then((value) {
        widget.uploadVideo();
        widget.videoController.addListener(setVideoValue);
        if (widget.setController != null) {
          widget.setController(widget.videoController);
        }
        widget.videoController.setLooping(widget.loop);
        widget.videoController.setVolume(widget.noVolume ? 0 : 1);
        if (widget.autoPlay &&
            !kIsWeb &&
            videoPageIsActive &&
            !widget.videoController.value.isPlaying) {
          if (!widget.hideControl) {
            hideControl();
          }
          widget.videoController.play();
        }
        if (widget.data != null && !widget.isLocal) {
          watchRcordTimer = Timer.periodic(new Duration(seconds: 10), (timer) {
            startWatchRecordTimer(AppGlobal.videoWatchRecordBox, widget.data.id,
                chapterId: widget.data.id,
                offset: videoValue,
                thumb: widget.data.coverOriginalVertical ??
                    widget.data.coverOriginalHorizontal,
                isFree: widget.data.isfree,
                title: widget.data.title);
          });
        }
      }).onError((error, stackTrace) {
        if (mounted) {
          videoPlayErr = true;
          setState(() {});
          CommonUtils.debugPrint(widget.videoUrl);
          CommonUtils.debugPrint('【播放资源时出错】:$error');
          CommonUtils.showText('视频资源播放错误');
        }
      }).timeout(Duration(seconds: 30), onTimeout: () {
        if (mounted) {
          videoPlayErr = true;
          setState(() {});
          CommonUtils.showText('视频资源播放超时');
        }
      });
  }

  @override
  void dispose() {
    widget.videoController?.removeListener(setVideoValue);
    if (!widget.isFull) {
      widget.videoController?.dispose();
      EventBus().off('stop-current-play');
    }
    timerfc?.cancel();
    super.dispose();
  }

  getTimeStr(double time) {
    int s = (time / 1000 / 60).truncate();
    int h = (time / 1000 - (s * 60)).truncate();
    String timeStr(int numb) {
      return numb < 10 ? '0$numb' : numb.toString();
    }

    return '${timeStr(s)}:${timeStr(h)}';
  }

  Future<void> changeFull() async {
    if (widget.isFull) {
      kIsWeb
          ? widget.videoController.exitFullScreen()
          : SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      Navigator.pop(context);
    } else {
      if (widget.videoController.value.isInitialized) {
        kIsWeb
            ? widget.videoController.requestFullScreen()
            : Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 0), //动画时间为500毫秒
                  pageBuilder: (BuildContext context, Animation animation,
                      Animation secondaryAnimation) {
                    return FadeTransition(
                      //使用渐隐渐入过渡,
                      opacity: animation,
                      child: FullVideo(
                        controller: widget.videoController,
                      ), //路由B
                    );
                  },
                ),
              );
      } else {
        CommonUtils.showText('视频正在加载中...');
      }
    }
  }

  setVideoValue() {
    if (widget.videoController.value.hasError) {
      CommonUtils.debugPrint(widget.videoController.value.errorDescription);
    }
    if (widget.isPreview && widget.setPreviewShow != null) {
      widget.setPreviewShow(widget.videoController.value.isPlaying);
    }
    if (!widget.videoController.value.isPlaying) {
      if (!showControl) {
        showControl = true;
        setState(() {});
      }
    }
    if (widget.data != null &&
        widget.videoController.value.isPlaying &&
        !seekHistory) {
      var boxData = AppGlobal.videoWatchRecordBox.get(widget.data.id);
      if (boxData != null) {
        setState(() {
          seekHistory = true;
          videoValue = boxData[widget.data.id].toDouble();
        });
        widget.videoController
            ?.seekTo(Duration(milliseconds: boxData[widget.data.id].toInt()));
      }
    }
    videoMaxTime =
        widget.videoController.value.duration.inMilliseconds.toDouble();
    if (!usecheck) {
      videoValue =
          widget.videoController.value.position.inMilliseconds.toDouble();
    }
    if (widget.videoController.value.buffered.isNotEmpty) {
      if (widget.videoController.value.buffered.any((element) =>
          element.start.inSeconds <=
              widget.videoController.value.position.inSeconds &&
          element.end.inSeconds >
              widget.videoController.value.position.inSeconds)) {
        loading = false;
      } else {
        loading = true;
      }
    }
    setState(() {});
  }

  hideControl() {
    if (widget.hideControl) return;
    if (!showControl) {
      showControl = true;
      setState(() {});
    }
    if (widget.videoController == null) return;
    if (timerfc != null) {
      timerfc.cancel();
      timerfc = Timer.periodic(Duration(seconds: 2), (time) {
        if (widget.videoController.value.isPlaying) {
          showControl = false;
          setState(() {});
        }
        time.cancel();
      });
    } else {
      timerfc = Timer.periodic(Duration(seconds: 2), (time) {
        if (widget.videoController.value.isPlaying) {
          showControl = false;
          setState(() {});
        }
        time.cancel();
      });
    }
  }

  Widget controlShow() {
    if (bytes == null) {
      CommonUtils.getRealImage(
          url: 'assets/images/card_video_shadow.png',
          imgUrl: bytes,
          setUrl: (e) {
            if (!mounted) return;
            bytes = e;
            setState(() {});
          });
    }
    return Stack(
      children: [
        Positioned(
            child: (mounted &&
                        loading &&
                        widget.videoController.value.isPlaying) ||
                    !widget.videoController.value.isInitialized
                ? Center(
                    child: Container(
                      width: ScreenUtil().setWidth(90),
                      child: Image.asset('assets/images/loading_pink.gif',
                          fit: BoxFit.fitWidth,
                          filterQuality: FilterQuality.medium),
                    ),
                  )
                : Container()),
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          child: (widget.isCardAuto ||
                  widget.videoController == null ||
                  !widget.videoController.value.isInitialized ||
                  widget.previewShow)
              ? Container()
              : Container(
                  color: Colors.transparent,
                  child: AnimatedOpacity(
                    opacity: showControl && !isLock ? 1 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Center(
                      child: widget.videoController.value.isInitialized
                          ? GestureDetector(
                              onTap: () {
                                if (isLock) return;
                                if (widget.videoController.value.isPlaying) {
                                  widget.videoController.pause();
                                  hideControl();
                                } else {
                                  widget.videoController.play();
                                  videoPageIsActive = true;
                                  hideControl();
                                }
                              },
                              child: Image.asset(
                                  'assets/images/detail/${widget.videoController.value.isPlaying ? 'icon_pause' : 'icon_play'}.png',
                                  width: ScreenUtil().setWidth(50),
                                  fit: BoxFit.fitWidth,
                                  filterQuality: FilterQuality.medium),
                            )
                          : Container(),
                    ),
                  ),
                ),
        ),
        widget.isCardAuto
            ? Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  height: ScreenUtil().setWidth(38),
                  width: double.infinity,
                  decoration: bytes != null
                      ? BoxDecoration(
                          image: DecorationImage(
                              image: MemoryImage(bytes), fit: BoxFit.fill))
                      : null,
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (widget.videoController.value.volume > 0) {
                            widget.videoController.setVolume(0);
                          } else {
                            widget.videoController.setVolume(1);
                          }
                        },
                        child: PlatformAwareAssetImage(
                          url:
                              'assets/images/volume-icon${widget.videoController.value.volume > 0 ? '-on' : ''}.png',
                          width: ScreenUtil().setWidth(15),
                          fit: BoxFit.fitWidth,
                        ),
                      )
                    ],
                  ),
                ))
            : animatedBox(
                top: null,
                bottom: showControl && !isLock && !widget.isPreview
                    ? 0
                    : ScreenUtil().setWidth(-44),
                opacity: showControl && !isLock && !widget.isPreview ? 1 : 0,
                child: widget.videoController == null ||
                        !widget.videoController.value.isInitialized ||
                        widget.isPreview
                    ? Container()
                    : Container(
                        padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(5)),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: [Colors.black26, Colors.black45],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: DefaultStyle.pagePadding),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (widget.videoController.value.isPlaying) {
                                    widget.videoController.pause();
                                    hideControl();
                                  } else {
                                    widget.videoController.play();
                                    videoPageIsActive = true;
                                    hideControl();
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: ScreenUtil().setWidth(15)),
                                  child: Icon(
                                    widget.videoController.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: ScreenUtil().setWidth(22),
                                  ),
                                ),
                              ),
                              Text(
                                getTimeStr(videoValue),
                                style: DefaultStyle.white11,
                              ),
                              Expanded(
                                  child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                          trackHeight: ScreenUtil().setWidth(2),
                                          inactiveTrackColor: Colors.white24,
                                          activeTrackColor: Color(0xffff84a9),
                                          overlayColor: Colors.white54,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius:
                                                  ScreenUtil().setWidth(5)),
                                          overlayShape: RoundSliderOverlayShape(
                                            overlayRadius:
                                                ScreenUtil().setWidth(9),
                                          ),
                                          thumbColor: Color(0xffff84a9)),
                                      child: Slider(
                                          value: videoValue > videoMaxTime
                                              ? videoMaxTime
                                              : videoValue,
                                          max: videoMaxTime,
                                          min: 0,
                                          onChangeStart: (e) {
                                            usecheck = true;
                                            changeStartIsPlay = widget
                                                .videoController
                                                .value
                                                .isPlaying;
                                            widget.videoController.pause();
                                          },
                                          onChangeEnd: (e) {
                                            if (changeStartIsPlay) {
                                              widget.videoController.play();
                                              hideControl();
                                              videoPageIsActive = true;
                                            }
                                          },
                                          onChanged: (e) {
                                            try {
                                              if (widget.videoController.value
                                                  .isInitialized) {
                                                videoValue = e;
                                                setState(() {});
                                                widget.videoController
                                                    .seekTo(Duration(
                                                        milliseconds:
                                                            videoValue.toInt()))
                                                    .then((value) {
                                                  usecheck = false;
                                                });
                                              }
                                            } catch (e) {
                                              return null;
                                            }
                                          }))),
                              Text(
                                getTimeStr(videoMaxTime),
                                style: DefaultStyle.white11,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (widget.videoController.value.volume > 0) {
                                    widget.videoController.setVolume(0);
                                  } else {
                                    widget.videoController.setVolume(1);
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(15)),
                                  child: Icon(
                                    widget.videoController.value.volume > 0
                                        ? Icons.volume_up
                                        : Icons.volume_off,
                                    color: Colors.white,
                                    size: ScreenUtil().setWidth(22),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
        animatedBox(
            right: null,
            left: showControl ? 0 : ScreenUtil().setWidth(-100),
            child: widget.videoController != null &&
                    widget.videoController.value.isInitialized &&
                    !widget.isPreview
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(DefaultStyle.pagePadding),
                      child: GestureDetector(
                        onTap: () {
                          isLock = !isLock;
                          setState(() {});
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Icon(
                          isLock ? Icons.lock : Icons.lock_open,
                          color: Colors.white,
                          size: ScreenUtil().setWidth(30),
                        ),
                      ),
                    ),
                  )
                : Container()),
        Positioned(
            child: !showUpTime || widget.isPreview
                ? Container()
                : Center(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(10))),
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(15),
                          vertical: ScreenUtil().setWidth(10)),
                      child: Text(getTimeStr(videoValue),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(isHorizontal() ? 50 : 18))),
                    ),
                  )),
        animatedBox(
            top: showControl && !isLock || widget.isPreview
                ? 0
                : ScreenUtil().setWidth(-44),
            bottom: null,
            opacity: showControl && !isLock ? 1 : 0,
            child: widget.isCardAuto
                ? Container()
                : head(
                    noBack: widget.noBack,
                    rightWidget: widget.videoController != null &&
                            widget.videoController.value.isInitialized &&
                            !widget.isPreview
                        ? GestureDetector(
                            onTap: changeFull,
                            child: Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(15)),
                              child: Icon(
                                widget.isFull
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                color: Colors.white,
                                size: ScreenUtil().setWidth(22),
                              ),
                            ),
                          )
                        : Container())),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isCardAuto
        ? controlShow()
        : (videoPlayErr
            ? Container(
                color: Color(0xfffff4f9),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '视频播放错误,请检查网络后重试',
                        style: TextStyle(
                            color: Color(0xff646464),
                            fontSize: ScreenUtil().setSp(16)),
                      ),
                      GestureDetector(
                        onTap: () {
                          initVideo();
                        },
                        child: Container(
                          margin:
                              EdgeInsets.only(top: ScreenUtil().setWidth(22)),
                          height: ScreenUtil().setWidth(32),
                          width: ScreenUtil().setWidth(118.5),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xffFF84A9), Color(0xffFF9E9E)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(
                                  ScreenUtil().setWidth(16))),
                          child: Center(
                            child: Text(
                              '重新加载',
                              style: DefaultStyle.white14,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (DragStartDetails e) {
                  if (isLock ||
                      widget.isPreview ||
                      widget.videoController == null ||
                      !widget.videoController.value.isInitialized) return;
                  CommonUtils.debugPrint('panStart:${e.localPosition.dx}');
                  usecheck = true;
                  showControl = false;
                  showUpTime = true;
                  setState(() {});
                  changeStartIsPlay = widget.videoController.value.isPlaying;
                  widget.videoController.pause();
                  panStart = e.localPosition.dx;
                },
                onPanUpdate: (DragUpdateDetails e) {
                  if (isLock ||
                      widget.isPreview ||
                      !widget.videoController.value.isInitialized) return;
                  upValue = videoValue + (e.localPosition.dx - panStart) * 10;
                  if (upValue > videoMaxTime) return;
                  if (upValue > 0 && upValue < videoMaxTime) {
                    videoValue = upValue;
                  }
                  setState(() {});
                },
                onPanEnd: (DragEndDetails e) {
                  if (isLock ||
                      widget.isPreview ||
                      !widget.videoController.value.isInitialized) return;
                  CommonUtils.debugPrint('panEnd:结束');
                  if (changeStartIsPlay) {
                    widget.videoController.play();
                    videoPageIsActive = true;
                  }
                  widget.videoController
                      .seekTo(Duration(milliseconds: videoValue.toInt()))
                      .then((value) {
                    usecheck = false;
                  });
                  upValue = 0;
                  showUpTime = false;
                  setState(() {});
                },
                onTap: () {
                  hideControl();
                },
                child: controlShow()));
  }
}
