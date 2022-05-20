import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/input/InputDailog.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/sharemovie.dart';
import 'package:pilipili/components/video/YyVideo.dart';
import 'package:pilipili/components/video/video_detail.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/mixin/watchRecordMixin.dart';
import 'package:pilipili/model/videolist.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/store/sharedPreferences.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/crypto.dart';
import 'package:pilipili/utils/download_video.dart';
import 'package:pilipili/utils/http.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/shelf_proxy.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:pilipili/routers.dart';

import '../../utils/privilege.dart';

class SmallVideo extends StatefulWidget {
  SmallVideo({Key key, this.id, this.elementId, this.page = 1, this.videoData})
      : super(key: key);
  final int id;
  final int elementId;
  final int page;
  final dynamic videoData;
  @override
  _SmallVideoState createState() => _SmallVideoState();
}

class _SmallVideoState extends State<SmallVideo> {
  PreloadPageController controller;
  int currentIndex = 0;
  double startMoveY = 0.0;
  int page = 1;
  int topPage = 1;
  bool isAll = false;
  bool loading = false;
  List<VideoItem> videoList = [];
  bool pageLoading = true;
  bool initVideoPage = false;
  List<VideoItem> videoData = [];

  Map<int, VideoPlayerController> vControllerMaps = {};
  getSmallVideolist({int videoPage, bool isCreate = false}) {
    if (widget.videoData != null) return;
    loading = true;
    setState(() {});
    Map _pramas = {
      'page': videoPage == null ? page : videoPage,
      'limit': AppGlobal.smallVideoLimit
    };
    _pramas.addAll(AppGlobal.smallVideoPramas);
    PlatformAwareHttp.post(AppGlobal.smallVideoApi, data: _pramas).then((json) {
      VideoList res = VideoList.fromJson(json.data);
      if (res.status != 0) {
        if (res.data == null) return;
        if (res.data.length < AppGlobal.smallVideoLimit) {
          isAll = true;
          CommonUtils.showText('已为您加载完最后${res.data.length}部视频～');
        }
        loading = false;
        pageLoading = false;
        int cIndex = 0;
        if (!initVideoPage) {
          initVideoPage = true;
          page = videoPage;
          topPage = videoPage;
          videoList.addAll(res.data);
          int videoIndex =
              res.data.indexWhere((item) => item.datumId == widget.id);

          //需要加载上一页
          bool isT = videoIndex <= 5 && topPage > 1;
          //需要加载下一页
          bool isB = videoIndex >= res.data.length - 5 && !isAll;
          if (videoIndex != null) {
            if (isT) {
              topPage--;
              getSmallVideolist(videoPage: topPage, isCreate: true);
            }
            if (isB) {
              page++;
              getSmallVideolist(videoPage: page, isCreate: true);
            }
          }
          if (!isT && !isB) {
            currentIndex = videoIndex;
            setState(() {});
            createController(videoIndex);
          }
        } else {
          if (videoPage < page) {
            videoData.clear();
            videoData.addAll(res.data);
            videoData.addAll(videoList);
            videoList = videoData;
            if (isCreate) {
              cIndex =
                  videoList.indexWhere((item) => item.datumId == widget.id);
              currentIndex = cIndex;
              setState(() {});
              createController(cIndex);
            } else {
              currentIndex = controller.page.toInt();
              controller.jumpToPage(res.data.length + currentIndex);
            }
          } else {
            videoList.addAll(res.data);
            if (isCreate) {
              cIndex =
                  videoList.indexWhere((item) => item.datumId == widget.id);
              currentIndex = cIndex;
              setState(() {});
              createController(cIndex);
            }
          }
        }
        setState(() {});
      } else {
        CommonUtils.showText(res.msg);
      }
    });
  }

  createController(int index) {
    controller = PreloadPageController(initialPage: index);
    controller.addListener(() {
      if (controller.page % 1 == 0) {
        currentIndex = controller.page.toInt();
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (AppGlobal.smallVideoApi == null) {
      AppGlobal.smallVideoApi = '/api/mv/getListFromElement';
      AppGlobal.smallVideoPramas = {
        'elementId': widget.elementId,
      };
    }
    Wakelock.enable();
    if (widget.videoData == null) {
      getSmallVideolist(videoPage: widget.page);
    } else {
      getVideoDetail(
              id: widget.videoData['id'] == null
                  ? widget.videoData['related_id']
                  : widget.videoData['id'])
          .then((res) {
        if (res.status != 0) {
          VideoItem videoDetail = VideoItem.fromJson(res.data.toJson());
          videoDetail.coverThumbVertical =
              CommonUtils.getThumb(widget.videoData);
          videoDetail.countLike = res.data.favorites;
          videoList = [videoDetail];
          controller = PreloadPageController();
          initVideoPage = true;
          pageLoading = false;
          setState(() {});
        }
      });
    }
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    }
  }

  @override
  void dispose() {
    super.dispose();
    AppGlobal.smallVideoApi = null;
    AppGlobal.smallVideoPramas = null;
    Wakelock.disable();
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFDFE9),
      body: Stack(
        children: [
          pageLoading || controller == null
              ? mounted
                  ? Center(
                      child: Container(
                        width: ScreenUtil().setWidth(120),
                        child: Image.asset('assets/images/loading_pink.gif',
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.high),
                      ),
                    )
                  : Container()
              : PreloadPageView.builder(
                  controller: controller,
                  itemCount: videoList.length,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    if (vControllerMaps[index - 1] != null) {
                      if (vControllerMaps[index - 1].value.isInitialized &&
                          vControllerMaps[index - 1].value.isPlaying) {
                        vControllerMaps[index - 1].pause();
                      }
                    }
                    if (vControllerMaps[index + 1] != null) {
                      if (vControllerMaps[index + 1].value.isInitialized &&
                          vControllerMaps[index + 1].value.isPlaying) {
                        vControllerMaps[index + 1].pause();
                      }
                    }
                    if (vControllerMaps[index] != null) {
                      if (vControllerMaps[index].value.isInitialized &&
                          !vControllerMaps[index].value.isPlaying &&
                          !kIsWeb) {
                        vControllerMaps[index].play();
                        AppGlobal.videoPageIsActive = true;
                      }
                    }
                    if (!isAll && index == videoList.length - 5) {
                      page++;
                      getSmallVideolist(videoPage: page);
                    }
                    if (topPage > 1 && index == 5) {
                      topPage--;
                      getSmallVideolist(videoPage: topPage);
                    }
                    if (topPage == 1 && index == 0) {
                      CommonUtils.showText('前面已经没有视频啦～');
                      return;
                    }
                    if (isAll && index == videoList.length - 1) {
                      CommonUtils.showText('后面已经没有视频啦～');
                      return;
                    }
                    if (loading && index == videoList.length - 1) {
                      CommonUtils.showText('正在为您加载更多,请稍后～');
                      return;
                    }
                  },
                  preloadPagesCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return SmallVideoPlayer(
                      onVideoControllerInited: (_controller) {
                        vControllerMaps[index] = _controller;
                      },
                      onVideoControllerDisposed: () {
                        vControllerMaps[index] = null;
                      },
                      currentIndex: currentIndex,
                      data: videoList[index],
                      index: index,
                    );
                  },
                ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(15.5),
                    right: ScreenUtil().setWidth(15.5),
                    top: kIsWeb
                        ? ScreenUtil().setWidth(31)
                        : ScreenUtil().statusBarHeight +
                            ScreenUtil().setWidth(15),
                    bottom: ScreenUtil().setWidth(6)),
                color: Color.fromRGBO(130, 56, 78, 0.44),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: ScreenUtil().setWidth(10)),
                            child: Image.asset('assets/images/backarrow.png',
                                width: ScreenUtil().setWidth(12),
                                fit: BoxFit.fitWidth,
                                filterQuality: FilterQuality.high),
                          ),
                        ),
                        loading
                            ? Container(
                                height: ScreenUtil().setWidth(22),
                                width: ScreenUtil().setWidth(22),
                                child: CircularProgressIndicator(
                                  color: Color(0xffFF84A9),
                                ),
                              )
                            : Container()
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
  SmallVideoPlayer(
      {Key key,
      this.onVideoControllerInited,
      this.onVideoControllerDisposed,
      this.currentIndex,
      this.index,
      this.data})
      : super(key: key);
  Function onVideoControllerInited;
  Function onVideoControllerDisposed;
  final int currentIndex;
  final int index;
  final VideoItem data;
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
  bool isNovideo = true;
  bool isLike = false;
  int likeNum = 0;
  bool loading = true;
  bool isShow = false; //是否弹窗
  int page = 1;
  int limit = 15;
  bool isAll = false;
  List commentList = [];
  bool commentLoading = true;
  bool commentShow = false;
  bool usecheck = false;
  bool videoPlayErr = false;
  getVideoComment(Function setBottomSheetState) {
    if (isAll) {
      CommonUtils.showText('已经没有评论啦～');
      return;
    }
    getCommentList(
            contentId: widget.data.datumId,
            contentType: 7,
            page: page,
            limit: limit)
        .then((res) {
      if (res['status'] != 0) {
        CommonUtils.debugPrint('-------------评论：$res');
        commentLoading = false;
        List resdata = res['data'] == null ? [] : res['data'];
        isAll = resdata.length < limit;
        if (page == 1) {
          commentList = resdata;
        } else {
          commentList.add(resdata);
        }
        setBottomSheetState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

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

  Widget _itemContainer(Widget child) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10))),
      width: ScreenUtil().setWidth(56),
      height: ScreenUtil().setWidth(56),
      child: child,
    );
  }

  getTimeStr(double time) {
    int s = (time / 1000 / 60).truncate();
    int h = (time / 1000 - (s * 60)).truncate();
    String timeStr(int numb) {
      return numb < 10 ? '0$numb' : numb.toString();
    }

    return '${timeStr(s)}:${timeStr(h)}';
  }

  buySmallVideo(int money) {
    buyVideo(
            id: widget.data.datumId,
            coins: (money - widget.data.discountCoins),
            context: context)
        .then((res) {
      if (res.status != 0) {
        CommonUtils.showText('购买成功');
        isNovideo = false;
        CommonUtils.debugPrint('购买视频地址:${res.data}');
        widget.data.source240 = res.data;
        setState(() {});
        initVideo(res.data);
      } else {
        CommonUtils.showText(res.msg);
      }
    });
  }

  showBuyVip() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.data.isfree == 2) {
        int money =
            Provider.of<HomeConfig>(context, listen: false).member.money;
        bool isInsufficient = money < widget.data.discountCoins;
        YyShowDialog.showdialog(context,
            btnText: isInsufficient ? 'GOLD不足，前往充值' : '购买观看', callBack: () {
          if (isInsufficient) {
            context.push('/${Routes.coinRecharge}');
          } else {
            buySmallVideo(money);
          }
        }, content: (setDialogState) {
          return DefaultTextStyle(
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff646464),
                  fontSize: ScreenUtil().setSp(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(text: '该视频需要花费', children: [
                    TextSpan(
                        text: '${widget.data.discountCoins}G',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffFF84A9),
                            fontSize: ScreenUtil().setSp(16)))
                  ]))
                ],
              ));
        });
      } else {
        YyShowDialog.showdialog(context,
            btnText: '充值VIP',
            cancelBack: () {
              var config =
                  Provider.of<HomeConfig>(context, listen: false).config;
              ShareMovieModel.showShareMovie(backButtonBehavior,
                  copyUrl: config.share.affUrlCopy.url,
                  thumb: widget.data.coverThumbVertical,
                  title: widget.data.title,
                  subtitle: widget.data.desc,
                  url: '${config.share.affUrl}');
            },
            cancelText: '分享无限看',
            callBack: () {
              context.push('/${Routes.vip}');
            },
            content: (setDialogState) {
              return DefaultTextStyle(
                  style: TextStyle(
                      color: Color(0xff646464),
                      fontSize: ScreenUtil().setSp(16),
                      fontWeight: FontWeight.bold),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('您可以:'),
                      SizedBox(
                        height: ScreenUtil().setWidth(15),
                      ),
                      Text('1、每成功邀请1名好友，赠送2天VIP，无限叠加'),
                      SizedBox(
                        height: ScreenUtil().setWidth(15),
                      ),
                      Text('2、充值VIP，享受海量福利')
                    ],
                  ));
            });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    likeNum = widget.data.favorites;
    isLike = widget.data.userFavorites == 1;
    isNovideo = widget.data.source240 == null;
    EventBus().on('stop-current-play', (arg) {
      if (_controller != null && _controller.value.isPlaying) {
        _controller.pause();
      }
      AppGlobal.videoPageIsActive = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    timerfc?.cancel();
    _controller?.removeListener(setVideovalue);
    _controller?.dispose();
    widget.onVideoControllerDisposed();
    EventBus().off('stop-current-play');
  }

  Future showConment() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            if (!commentShow) {
              commentShow = true;
              getVideoComment(setBottomSheetState);
            }
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: ScreenUtil().setWidth(470),
                  color: Color(0xffFFF4F9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              blurStyle: BlurStyle.outer,
                              color: Color.fromRGBO(255, 91, 140, 0.2),
                              offset: Offset(0, ScreenUtil().setWidth(6)),
                            )
                          ],
                        ),
                        width: double.infinity,
                        height: ScreenUtil().setWidth(40),
                        child: Center(
                          child: Text(
                            '评论',
                            style: TextStyle(
                                color: Color(0xffFF5B8C),
                                fontSize: ScreenUtil().setSp(14),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                          child: commentLoading
                              ? PageStatus.loading(mounted)
                              : PullRefreshList(
                                  onRefresh: () {
                                    page = 1;
                                    isAll = false;
                                    getVideoComment(setBottomSheetState);
                                  },
                                  onLoading: () {
                                    page++;
                                    getVideoComment(setBottomSheetState);
                                  },
                                  child: commentList.length == 0
                                      ? SingleChildScrollView(
                                          child: PageStatus.noData(
                                              text: '还没有任何影评哦～'),
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  DefaultStyle.pagePadding,
                                              horizontal:
                                                  DefaultStyle.pagePadding),
                                          itemCount: commentList.length,
                                          cacheExtent:
                                              ScreenUtil().screenHeight * 5,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return ConmentItem(
                                              souceType:
                                                  RESOURCE_TYPE_SHORT_VIDEO,
                                              id: widget.data.datumId,
                                              data: commentList[index],
                                              children: commentList[index]
                                                      ['child_comment']
                                                  .asMap()
                                                  .keys
                                                  .map<Widget>((f) {
                                                return ConmentItem(
                                                    souceType:
                                                        RESOURCE_TYPE_SHORT_VIDEO,
                                                    id: widget.data.datumId,
                                                    data: commentList[index]
                                                        ['child_comment'][f]);
                                              }).toList(),
                                            );
                                          }),
                                )),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (Privilege.isAllowed(
                              context,
                              RESOURCE_TYPE_SHORT_VIDEO,
                              PRIVILEGE_TYPE_COMMENT)) {
                            InputDialog.show(context, '请输入您的影评～').then((value) {
                              if (value != null && value != '') {
                                publishComment(
                                        contentId: widget.data.datumId,
                                        contentType: 7,
                                        reply: value)
                                    .then((res) {
                                  if (res['status'] != 0) {
                                    CommonUtils.showText('影评发布成功,请刷新查看������');
                                  } else {
                                    CommonUtils.showText(res['msg']);
                                  }
                                });
                              } else {
                                CommonUtils.showText('请输入您的影评');
                              }
                            });
                          } else {
                            YyShowDialog.showdialog(context,
                                btnText: '升级VIP',
                                cancelText: '取消', callBack: () {
                              context.push('/${Routes.vip}');
                            }, content: (setDialogState) {
                              return DefaultTextStyle(
                                  style: TextStyle(
                                      color: Color(0xff646464),
                                      fontSize: ScreenUtil().setSp(16),
                                      fontWeight: FontWeight.bold),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('升级VIP即可发布影评哦～'),
                                    ],
                                  ));
                            });
                          }
                        },
                        child: Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(
                              bottom:
                                  kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                          padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(12),
                              horizontal: DefaultStyle.pagePadding),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(16)),
                            height: ScreenUtil().setWidth(36),
                            child: Row(
                              children: [
                                Text(
                                  Privilege.isAllowed(
                                          context,
                                          RESOURCE_TYPE_SHORT_VIDEO,
                                          PRIVILEGE_TYPE_COMMENT)
                                      ? '能不能火就靠你啦～'
                                      : '升级VIP即可发布影评哦～',
                                  style: TextStyle(
                                      color: Color(0xff999999),
                                      fontSize: ScreenUtil().setSp(14)),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                    top: ScreenUtil().setWidth(8),
                    right: ScreenUtil().setWidth(16),
                    child: GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: Image.asset('assets/images/icon_close_red.png',
                          width: ScreenUtil().setWidth(24),
                          height: ScreenUtil().setWidth(24),
                          filterQuality: FilterQuality.high),
                    ))
              ],
            );
          });
        });
  }

  setVideovalue() {
    if (mounted) {
      var newVelue = _controller.value.position.inMilliseconds.toDouble();
      if (newVelue >= 0 && newVelue <= videoMaxTime) {
        if (!usecheck) {
          videoValue = newVelue;
        }
        if (_controller.value.buffered.isNotEmpty) {
          if (_controller.value.buffered.any((element) =>
              element.start.inSeconds <= _controller.value.position.inSeconds &&
              element.end.inSeconds > _controller.value.position.inSeconds)) {
            loading = false;
          } else {
            loading = true;
          }
        }
        setState(() {});
      } else if (newVelue > videoMaxTime && videoValue != videoMaxTime) {
        if (usecheck) return;
        videoValue = videoMaxTime;
        setState(() {});
      }
    }
  }

  createVideo(url) {
    if (_controller != null) {
      _controller.dispose();
      widget.onVideoControllerDisposed();
    }
    _controller = VideoPlayerController.network(url);
    widget.onVideoControllerInited(_controller);
    _controller.initialize().then((_) {
      handleRecordWatch();
      _controller.setLooping(true);
      videoMaxTime = _controller.value.duration.inMilliseconds.toDouble();
      Timer.periodic(new Duration(seconds: 10), (timer) {
        timer.cancel();
        startWatchRecordTimer(
            AppGlobal.smallVideoWatchRecordBox, widget.data.datumId,
            chapterId: widget.data.datumId,
            offset: videoValue,
            thumb: widget.data.coverThumbVertical ??
                widget.data.coverThumbHorizontal,
            isFree: widget.data.isfree,
            title: widget.data.title);
      });
      if (mounted) {
        setState(() {});
      }
      _controller.addListener(setVideovalue);
      if (widget.currentIndex == widget.index && AppGlobal.videoPageIsActive) {
        if (!kIsWeb) {
          _controller.play();
        }
      }
    }).onError((error, stackTrace) {
      if (mounted && widget.currentIndex == widget.index) {
        videoPlayErr = true;
        setState(() {});
        CommonUtils.debugPrint(url);
        CommonUtils.debugPrint('【播放资源时出错】:$error');
        CommonUtils.showText('视频资源播放错误');
      }
    }).timeout(Duration(seconds: 30), onTimeout: () {
      if (mounted && widget.currentIndex == widget.index) {
        videoPlayErr = true;
        setState(() {});
        CommonUtils.showText('视频资源播放超时');
      }
    });
    ;
  }

  initVideo(url) {
    if (videoPlayErr) {
      videoPlayErr = false;
      setState(() {});
    }
    if (kIsWeb) {
      if (AppGlobal.m3u8_encrypt == '1') {
        new Dio().get(url).then((res) {
          String decrypted = PlatformAwareCrypto.decryptM3U8(res.data);
          final _blob = html.Blob([decrypted], 'application/x-mpegURL');
          final _url = html.Url.createObjectUrl(_blob);
          CommonUtils.debugPrint(_url);
          createVideo(_url);
        });
      } else {
        createVideo(url);
      }
    } else {
      if (AppGlobal.m3u8_encrypt == '1') {
        createServer(url).then((proxyConfig) {
          String proxyurl =
              url.replaceAll(proxyConfig['origin'], proxyConfig['localproxy']);
          createVideo(proxyurl);
        });
      } else {
        createVideo(url);
      }
    }
  }

  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  @override
  Widget build(BuildContext context) {
    if (widget.currentIndex >= widget.index - 1 &&
        widget.currentIndex <= widget.index + 1 &&
        !videoInit &&
        _controller == null) {
      videoInit = true;
      CommonUtils.debugPrint(
          '===============视��地址:${widget.data.source240}==预览视频=${widget.data.preview}================');
      initVideo(isNovideo ? widget.data.preview : widget.data.source240);
    }
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
            AppGlobal.videoPageIsActive = true;
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
                                  child: VideoContainer(
                                      videoController: _controller),
                                ),
                                Positioned(
                                    child: mounted && loading
                                        ? Center(
                                            child: Container(
                                              width: ScreenUtil().setWidth(120),
                                              child: Image.asset(
                                                  'assets/images/loading_pink.gif',
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
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Stack(
                                    children: [
                                      PlatformAwareNetworkImage(
                                          fit: BoxFit.contain,
                                          url: widget.data.coverThumbVertical ??
                                              widget.data.coverThumbHorizontal),
                                      Positioned(
                                          child: Center(
                                        child: Container(
                                          width: ScreenUtil().setWidth(120),
                                          child: Image.asset(
                                              'assets/images/loading_pink.gif',
                                              fit: BoxFit.fitWidth,
                                              filterQuality:
                                                  FilterQuality.high),
                                        ),
                                      ))
                                    ],
                                  ),
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
                            PlatformAwareNetworkImage(
                                fit: BoxFit.contain,
                                url: widget.data.coverThumbVertical ??
                                    widget.data.coverThumbHorizontal),
                            Positioned(
                                child: Center(
                              child: Container(
                                width: ScreenUtil().setWidth(120),
                                child: Image.asset(
                                    'assets/images/loading_pink.gif',
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
                        videoPlayErr
                            ? Positioned(
                                top: 0,
                                left: 0,
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black45,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '视频播放错误,请检查网络后重试',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil().setSp(16)),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            initVideo(isNovideo
                                                ? widget.data.preview
                                                : widget.data.source240);
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setWidth(22)),
                                            height: ScreenUtil().setWidth(32),
                                            width: ScreenUtil().setWidth(118.5),
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xffFF84A9),
                                                    Color(0xffFF9E9E)
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        ScreenUtil()
                                                            .setWidth(16))),
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
                                ),
                              )
                            : Container(),
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
                                          !isNovideo
                                              ? Container()
                                              : GestureDetector(
                                                  onTap: () {
                                                    if (widget.data.isfree ==
                                                        2) {
                                                      int money = Provider.of<
                                                                  HomeConfig>(
                                                              context,
                                                              listen: false)
                                                          .member
                                                          .money;
                                                      bool isInsufficient =
                                                          money <
                                                              widget.data
                                                                  .discountCoins;
                                                      YyShowDialog.showdialog(
                                                          context,
                                                          title: 'GOLD视频',
                                                          btnText: isInsufficient
                                                              ? 'GOLD不足，前往充值'
                                                              : '购买观看',
                                                          callBack: () {
                                                        if (isInsufficient) {
                                                          context.push(
                                                              '/${Routes.coinRecharge}');
                                                        } else {
                                                          buySmallVideo(money);
                                                        }
                                                      }, content:
                                                              (setDialogState) {
                                                        return DefaultTextStyle(
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xff646464),
                                                                fontSize:
                                                                    ScreenUtil()
                                                                        .setSp(
                                                                            14)),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text.rich(TextSpan(
                                                                    text:
                                                                        '该视频需要花费',
                                                                    children: [
                                                                      TextSpan(
                                                                          text:
                                                                              '${widget.data.discountCoins}G',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Color(0xffFF84A9),
                                                                              fontSize: ScreenUtil().setSp(16)))
                                                                    ]))
                                                              ],
                                                            ));
                                                      });
                                                    } else {
                                                      context.push(
                                                          '/${Routes.vip}');
                                                    }
                                                  },
                                                  child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(
                                                                      ScreenUtil()
                                                                          .setWidth(
                                                                              11)),
                                                                  gradient:
                                                                      LinearGradient(
                                                                          colors: [
                                                                        widget.data.isfree ==
                                                                                1
                                                                            ? Color.fromRGBO(
                                                                                255,
                                                                                132,
                                                                                169,
                                                                                0.7)
                                                                            : Color.fromRGBO(
                                                                                255,
                                                                                210,
                                                                                49,
                                                                                0.7),
                                                                        widget.data.isfree ==
                                                                                1
                                                                            ? Color.fromRGBO(
                                                                                255,
                                                                                132,
                                                                                169,
                                                                                0.7)
                                                                            : Color.fromRGBO(
                                                                                237,
                                                                                34,
                                                                                34,
                                                                                0.7),
                                                                      ])),
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          20)),
                                                          height: ScreenUtil()
                                                              .setWidth(22),
                                                          child: Text.rich(
                                                              TextSpan(
                                                                  children: [
                                                                TextSpan(
                                                                    text: widget.data.isfree ==
                                                                            1
                                                                        ? '立即成为VIP解锁全站视频'
                                                                        : '支付${widget.data.discountCoins}币即可观看完整版',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            ScreenUtil().setSp(12))),
                                                              ])),
                                                        )
                                                      ]),
                                                ),
                                          SizedBox(
                                            height: ScreenUtil().setWidth(10),
                                          ),
                                          widget.data.tags != null &&
                                                  widget.data.tags != ''
                                              ? Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: ScreenUtil()
                                                          .setWidth(10)),
                                                  child: Text(
                                                    '#' +
                                                        widget.data.tags
                                                            .replaceAll(
                                                                ',', ' #'),
                                                    style: DefaultStyle.white14,
                                                  ),
                                                )
                                              : Container(),
                                          Text(
                                            widget.data.title,
                                            style: TextStyle(
                                                height: 1.25,
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1),
                                                fontSize:
                                                    ScreenUtil().setSp(16),
                                                decoration:
                                                    TextDecoration.none),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          widget.data.desc == '' ||
                                                  widget.data.desc == null
                                              ? Container()
                                              : SizedBox(
                                                  height:
                                                      ScreenUtil().setWidth(13),
                                                ),
                                          widget.data.desc == '' ||
                                                  widget.data.desc == null
                                              ? Container()
                                              : Text(
                                                  widget.data.desc,
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 1),
                                                      fontSize: ScreenUtil()
                                                          .setSp(14),
                                                      decoration:
                                                          TextDecoration.none),
                                                ),
                                        ],
                                      )),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              PersistentState.getState(
                                                      'small_video')
                                                  .then((value) {
                                                if (value == null) {
                                                  YyShowDialog.showdialog(
                                                      context,
                                                      btnText: '朕知道了', content:
                                                          (setDialogStatus) {
                                                    return Text(
                                                      '点击喜欢后可前往【我的】-【我的收藏】中查看该视频',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xff646464),
                                                          fontSize: ScreenUtil()
                                                              .setSp(14)),
                                                      textAlign:
                                                          TextAlign.center,
                                                    );
                                                  });
                                                  PersistentState.saveState(
                                                      'small_video', 'isshow');
                                                }
                                              });
                                              userFavorites(
                                                      type: 10,
                                                      id: widget.data.datumId)
                                                  .then((res) {
                                                if (res != null &&
                                                    res.status != 0) {
                                                  isLike
                                                      ? likeNum--
                                                      : likeNum++;
                                                  isLike = !isLike;
                                                  setState(() {});
                                                } else {
                                                  CommonUtils.showText(res.msg);
                                                }
                                              });
                                            },
                                            child: _itemContainer(Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                    'assets/images/detail/${isLike ? 'icon_like' : 'icon_unlike'}.png',
                                                    width: ScreenUtil()
                                                        .setWidth(20),
                                                    filterQuality:
                                                        FilterQuality.high),
                                                SizedBox(
                                                  height: ScreenUtil()
                                                      .setWidth(5.5),
                                                ),
                                                Text(likeNum.toString(),
                                                    style: DefaultStyle.white12)
                                              ],
                                            )),
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setWidth(20),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              var config =
                                                  Provider.of<HomeConfig>(
                                                          context,
                                                          listen: false)
                                                      .config;
                                              ShareMovieModel.showShareMovie(
                                                  backButtonBehavior,
                                                  copyUrl: config
                                                      .share.affUrlCopy.url,
                                                  thumb: widget
                                                      .data.coverThumbVertical,
                                                  title:
                                                      widget.data.title ?? '--',
                                                  subtitle:
                                                      widget.data.desc ?? '--',
                                                  url:
                                                      '${config.share.affUrl}');
                                            },
                                            child: _itemContainer(Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                    'assets/images/detail/icon_share_w.png',
                                                    width: ScreenUtil()
                                                        .setWidth(20),
                                                    filterQuality:
                                                        FilterQuality.high),
                                                SizedBox(
                                                  height: ScreenUtil()
                                                      .setWidth(5.5),
                                                ),
                                                Text('分享',
                                                    style: DefaultStyle.white12)
                                              ],
                                            )),
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setWidth(20),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              showConment();
                                            },
                                            child: _itemContainer(Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                    'assets/images/detail/icon_msg_w.png',
                                                    width: ScreenUtil()
                                                        .setWidth(20),
                                                    filterQuality:
                                                        FilterQuality.high),
                                                SizedBox(
                                                  height: ScreenUtil()
                                                      .setWidth(5.5),
                                                ),
                                                Text(
                                                    widget.data.countComment
                                                        .toString(),
                                                    style: DefaultStyle.white11)
                                              ],
                                            )),
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setWidth(20),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (kIsWeb) {
                                                CommonUtils.showText(
                                                    '请下载APP使用下载功能��');
                                              } else {
                                                PageStatus.showLoading();
                                                getDownloadUrl(
                                                        id: widget.data.datumId)
                                                    .then((res) {
                                                  if (res['status'] != 0) {
                                                    Map taskInfo = {
                                                      "id":
                                                          "${widget.data.datumId}",
                                                      "urlPath": res['data']
                                                          ['downloadUrl'],
                                                      "title":
                                                          widget.data.title,
                                                      "desc": widget.data.desc,
                                                      "thumbCover": widget.data
                                                              .coverThumbHorizontal ??
                                                          widget.data
                                                              .coverThumbVertical,
                                                      "tags": widget.data.tags
                                                          .split(",")
                                                          .join("/"),
                                                      "contentType": 7,
                                                      "downloading": false,
                                                      "isWaiting": true
                                                    };
                                                    DownloadUtil
                                                        .createDownloadTask(
                                                            taskInfo);
                                                  } else {
                                                    YyShowDialog.showdialog(
                                                      context,
                                                      content:
                                                          (setDialogState) {
                                                        return Text(
                                                          widget.data.isfree ==
                                                                  2
                                                              ? '您还未购买本视频,缓存完成随心快进到高潮~'
                                                              : '您离下载还差一个VIP！缓存完成随心快进到高潮~',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff646464),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          16)),
                                                        );
                                                      },
                                                      cancelText: '取消',
                                                      btnText:
                                                          widget.data.isfree ==
                                                                  2
                                                              ? '立即购买'
                                                              : '立即升级',
                                                      callBack: () {
                                                        if (widget
                                                                .data.isfree ==
                                                            2) {
                                                          int money = Provider
                                                                  .of<HomeConfig>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                              .member
                                                              .money;
                                                          bool isInsufficient =
                                                              money <
                                                                  widget.data
                                                                      .discountCoins;
                                                          YyShowDialog.showdialog(
                                                              context,
                                                              btnText:
                                                                  isInsufficient
                                                                      ? 'GOLD不足，前往充值'
                                                                      : '购买观看',
                                                              callBack: () {
                                                            if (isInsufficient) {
                                                              context.push(
                                                                  '/${Routes.coinRecharge}');
                                                            } else {
                                                              buySmallVideo(
                                                                  money);
                                                            }
                                                          }, content:
                                                                  (setDialogState) {
                                                            return DefaultTextStyle(
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xff646464),
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            14)),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text.rich(TextSpan(
                                                                        text:
                                                                            '该视频需要花费',
                                                                        children: [
                                                                          TextSpan(
                                                                              text: '${widget.data.discountCoins}G',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffFF84A9), fontSize: ScreenUtil().setSp(16)))
                                                                        ]))
                                                                  ],
                                                                ));
                                                          });
                                                        } else {
                                                          context.push(
                                                              '/${Routes.vip}');
                                                        }
                                                      },
                                                    );
                                                  }
                                                }).whenComplete(() {
                                                  PageStatus.closeLoading();
                                                });
                                              }
                                            },
                                            child: _itemContainer(Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                    'assets/images/detail/icon_down_w.png',
                                                    width: ScreenUtil()
                                                        .setWidth(20),
                                                    filterQuality:
                                                        FilterQuality.high),
                                                SizedBox(
                                                  height: ScreenUtil()
                                                      .setWidth(5.5),
                                                ),
                                                Text("下载",
                                                    style: DefaultStyle.white11)
                                              ],
                                            )),
                                          ),
                                        ],
                                      )
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
                                                          Colors.white,
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
                                                      thumbColor: Colors.white),
                                              child: Slider(
                                                  value:
                                                      videoValue >= videoMaxTime
                                                          ? videoMaxTime
                                                          : videoValue,
                                                  max: videoMaxTime,
                                                  min: 0,
                                                  onChangeStart: (e) {
                                                    usecheck = true;
                                                    changeStartIsPlay =
                                                        _controller
                                                            .value.isPlaying;
                                                    _controller.pause();
                                                  },
                                                  onChangeEnd: (e) {
                                                    if (changeStartIsPlay) {
                                                      _controller.play();
                                                      AppGlobal
                                                              .videoPageIsActive =
                                                          true;
                                                    }
                                                  },
                                                  onChanged: (e) {
                                                    if (_controller
                                                        .value.isInitialized) {
                                                      videoValue = e;
                                                      setState(() {});
                                                      _controller
                                                          .seekTo(Duration(
                                                              milliseconds:
                                                                  videoValue
                                                                      .toInt()))
                                                          .then((value) {
                                                        usecheck = false;
                                                      });
                                                    }
                                                  }))),
                                      Text(
                                        getTimeStr(videoMaxTime),
                                        style: DefaultStyle.white11,
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setWidth(20) +
                                        MediaQuery.of(context).padding.bottom,
                                  ),
                                ],
                              ),
                            )),
                        _controller == null ||
                                (_controller != null &&
                                    !_controller.value.isInitialized)
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
                                        'assets/images/detail/${_controller.value.isPlaying ? 'icon_pause' : 'icon_play'}.png',
                                        width: ScreenUtil().setWidth(80),
                                        height: ScreenUtil().setWidth(80),
                                        filterQuality: FilterQuality.high),
                                  ),
                                )),
                      ],
                    )))
          ],
        ));
  }
}
