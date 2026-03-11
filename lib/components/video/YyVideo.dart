import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frhooks/frhooks.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/video/video_controller.dart';
import 'package:pilipili/mixin/video_mixin.dart';
import 'package:pilipili/report/app_event_report.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

typedef SetControllerCallback = void Function(VideoPlayerController controller);

class YyVideo extends StatefulWidget {
  YyVideo(
      {Key? key,
      this.id,
      this.videoUrl,
      this.cover,
      this.setVideoUrl, // 改变父组件url
      this.noBack = false,
      this.isCardAuto = false, //是否为卡片形式的自动方法
      this.isFull = false, //在全屏状态
      this.hideControl = false, //是否隐藏控制器
      this.autoPlay = true, //自动播放
      this.loop = false, //循环播放
      this.noVolume = false, //是否静音
      this.controller,
      this.setController, //返回参数是本视频的 controller
      this.data,
      this.isLocal = false, // 是否为本地视频
      this.isPreview = false})
      : super(key: key);
  String? videoUrl;
  final String? id;
  final Function? setVideoUrl;
  final bool isCardAuto;
  final bool noBack;
  final bool isFull;
  final bool hideControl;
  final bool autoPlay;
  final bool loop;
  final bool noVolume;
  final VideoPlayerController? controller;
  final SetControllerCallback? setController;
  final dynamic data;
  final bool isLocal;
  final bool isPreview;
  final String? cover;

  @override
  _YyVideoState createState() => _YyVideoState();
}

class _YyVideoState extends State<YyVideo> with VideoMinxin {
  VideoPlayerController? videoController;
  bool previewShow = false;
  initPageState() {
    videoController = widget.controller;
    AppEventReport.instance.videoControllerInit(videoController!);
    setState(() {});
    }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    initPageState();
  }

  initVideo(dynamic url) {
    videoController = VideoPlayerController.network(url);
    AppEventReport.instance.videoControllerInit(videoController!);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: videoBuild());
  }

  buySmallVideo() {
    int money = Provider.of<HomeConfig>(context, listen: false).member.money!;
    buyVideo(id: widget.data.id, coins: (money - widget.data.discountCoins!).toInt(), context: context).then((res) {
      if (res.status != 0) {
        CommonUtils.showText('购买成功');
        widget.videoUrl = res.data;
        context.pop();
        widget.setVideoUrl!(res.data);
              setState(() {});
        initPageState();
      } else {
        CommonUtils.showText(res.msg!);
      }
    });
  }

  Widget videoBuild() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          (widget.videoUrl == '') && widget.controller == null
              ? Container()
              : Center(
                  child: videoController!.value.isInitialized
                      ? Hero(
                          tag: 'yyplayr',
                          child: Stack(
                            children: [
                              VideoContainer(
                                videoController: videoController,
                              ),
                            ],
                          ))
                      : mounted && !widget.isLocal
                          ? Stack(
                              children: [
                                PlatformAwareNetworkImage(
                                  url: widget.cover ?? widget.data.thumbCover ?? widget.data.coverThumbHorizontal,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                    child: Center(
                                  child: Container(
                                    width: ScreenUtil().setWidth(90),
                                    child: Image.asset('assets/gif/loading_pink.gif',
                                        fit: BoxFit.fitWidth, filterQuality: FilterQuality.medium),
                                  ),
                                ))
                              ],
                            )
                          : Container(),
                ),
          widget.videoUrl == null && widget.controller == null
              ? Container()
              : RepaintBoundary(
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: widget.cover == null ? 0 : ScreenUtil().statusBarHeight,
                          bottom: widget.cover == null ? 0 : ScreenUtil().bottomBarHeight + 30.w),
                      child: VideoController(
                          setPreviewShow: (bool show) {
                            if (show != previewShow) {
                              previewShow = show;
                              setState(() {});
                            }
                          },
                          isPreview: widget.isPreview,
                          videoController: videoController,
                          isCardAuto: widget.isCardAuto,
                          hideControl: widget.hideControl,
                          previewShow: previewShow,
                          initShow: widget.controller == null && widget.videoUrl == null,
                          data: widget.data,
                          autoPlay: widget.autoPlay,
                          id: widget.id,
                          loop: widget.loop,
                          noVolume: widget.noVolume,
                          noBack: widget.noBack,
                          isFull: widget.isFull,
                          setController: widget.setController,
                          videoUrl: widget.videoUrl,
                          setVideoUrl: widget.setVideoUrl,
                          uploadVideo: () {
                            setState(() {});
                          },
                          isLocal: widget.isLocal)),
                ),
          widget.isLocal || widget.videoUrl != null
              ? Container()
              : Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: (widget.videoUrl == '') && widget.controller == null
                      ? Container(
                          color: Colors.black54,
                          child: Center(
                            child: widget.data.isfree == 1
                                ? nofree(data: widget.data)
                                : coinbuy(data: widget.data, buyFunction: buySmallVideo),
                          ),
                        )
                      : Container()),
          Positioned(
              child: (!widget.isPreview || !previewShow)
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        if (widget.data.isfree == 1) {
                          context.push('/vip');
                        } else {
                          showBuy(widget.data, buySmallVideo);
                        }
                      },
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(11)),
                                  gradient: LinearGradient(colors: [
                                    widget.data.isfree == 1
                                        ? Color.fromRGBO(255, 132, 169, 0.7)
                                        : Color.fromRGBO(255, 210, 49, 0.7),
                                    widget.data.isfree == 1
                                        ? Color.fromRGBO(255, 132, 169, 0.7)
                                        : Color.fromRGBO(237, 34, 34, 0.7),
                                  ])),
                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                              height: ScreenUtil().setWidth(22),
                              child: Center(
                                  child: Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: widget.data.isfree == 1
                                        ? PPString.vipNowSeeVideo
                                        : '支付' + widget.data.discountCoins.toString() + '币即可观看完整版',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: ScreenUtil().setSp(12))),
                                // TextSpan(
                                //     text: widget.data.isfree == 1
                                //         ? '升级会员'
                                //         : '${widget.data.discountCoins}GOLD',
                                //     style: TextStyle(
                                //         color: Color(0xff62f7ff),
                                //         fontSize: ScreenUtil().setSp(13))),
                                // TextSpan(
                                //     text: '解锁完整版>>',
                                //     style: TextStyle(
                                //         color: Colors.white,
                                //         fontSize: ScreenUtil().setSp(13)))
                              ]))),
                            )
                          ],
                        ),
                      ),
                    )),
          !videoController!.value.isInitialized
              ? Positioned(
                  child: Padding(
                  padding: EdgeInsets.only(top: widget.cover == null ? 0 : ScreenUtil().statusBarHeight),
                  child: head(),
                ))
              : Container()
        ],
      ),
    );
  }
}

class HooksSet extends HookWidget {
  const HooksSet({this.pramas, this.child, Key? key}) : super(key: key);
  final Widget? child;
  final List? pramas;
  @override
  Widget build(BuildContext context) {
    return useMemo(() {
      return child!;
    }, pramas);
  }
}

class VideoContainer extends HookWidget {
  const VideoContainer({Key? key, this.videoController, this.isSmallVideo = false}) : super(key: key);
  final VideoPlayerController? videoController;
  final bool isSmallVideo;

  @override
  Widget build(BuildContext context) {
    return useMemo(() {
      return kIsWeb
          ? Container(
              width: double.infinity,
              height: double.infinity,
              child: VideoPlayer(videoController!),
            )
          : Center(
              child: AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                child: VideoPlayer(videoController!),
              ),
            );
    }, [videoController]);
  }
}
