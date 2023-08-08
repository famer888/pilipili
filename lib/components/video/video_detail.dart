import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/series_card.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
import 'package:pilipili/components/input/InputDailog.dart';
import 'package:pilipili/components/sharemovie.dart';
import 'package:pilipili/components/video/YyVideo.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/mixin/video_mixin.dart';
import 'package:pilipili/model/animationDetail.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/download_video.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:provider/provider.dart';
import '../../components/page_status.dart';
import '../../utils/common.dart';
import '../../utils/privilege.dart';

class VideoDetail extends StatefulWidget {
  VideoDetail({Key key, this.id}) : super(key: key);
  final dynamic id;
  @override
  _VideoDetailState createState() => _VideoDetailState();
}

class _VideoDetailState extends State<VideoDetail> with VideoMinxin {
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  PageController controller = PageController();
  String videoUrl;
  int currentTab = 0;
  DetailData videoInfo;
  bool isFavorites = false;
  List recommendList = [];
  List commentList = [];
  int commentLoadingStatus = 0;
  ScrollController _scrollController = ScrollController();
  bool commentShow = false;
  bool isPreview = false;
  TextEditingController commentController = TextEditingController();
  List tags = [];
  int page = 1;
  int limit = 15;
  bool isAll = false;
  bool videoLoading = false;
  int likeCount = 0;
  List _banner = [];
  Map seriesList;
  List firstSeriesList = [];
  int spage = 1;
  int slimit = 15;
  bool sisAll = false;
  List tabList = [
    {
      'id': 1,
      'name': '简介',
    },
    {
      'id': 2,
      'name': '评论',
    }
  ];
  Future<void> getVideoComment() async {
    if (isAll) {
      CommonUtils.showText('已经没有评论啦～');
      return;
    }
    var res = await getCommentList(
        contentId: widget.id, contentType: 1, page: page, limit: limit);
    if (res['status'] != 0) {
      commentLoadingStatus = 2;
      List resdata = res['data'] == null ? [] : res['data'];
      isAll = resdata.length < limit;
      if (page == 1) {
        commentList = resdata;
      } else {
        commentList.addAll(resdata);
      }
      setState(() {});
    } else {
      CommonUtils.showText(res['msg']);
    }
  }

  Future<void> getSeriesListVideo({Function setBottomSheetState}) async {
    var res =
        await getSeriesList(id: widget.id, type: 1, page: spage, limit: slimit);

    if (res['status'] != 0) {
      List resdata = res['data'] == null || res['data']['resource'] == null
          ? []
          : res['data']['resource'];
      sisAll = resdata.length < slimit;
      if (spage == 1) {
        seriesList = res['data'];
        if (resdata.length < 6) {
          firstSeriesList = resdata;
        } else {
          firstSeriesList = resdata.sublist(0, 6);
        }
      } else {
        seriesList['resource'].addAll(res['data']['resource']);
      }
      if (setBottomSheetState == null) {
        setState(() {});
      } else {
        setBottomSheetState();
      }
    } else {
      CommonUtils.showText(res['msg']);
    }
  }

  Future<dynamic> getAdCoin() async {
    var adBanner = await getAdForCoin(pos: 701);
    if (adBanner != null &&
        adBanner['data'] != null &&
        adBanner['data'].length > 0) {
      _banner = adBanner['data'];
    }
  }

  Future<void> initVideoPage() async {
    await getSeriesListVideo();
    await getAdCoin();
    AnimationDetail res = await getVideoDetail(id: widget.id);
    if (res.status != 0) {
      CommonUtils.debugPrint(
          "---------视频地址------${res.data.source240}-------------预览视频地址---${res.data?.preview}");
      isPreview = res.data.source240 == null;
      videoUrl = res.data.source240 ??= res.data.preview;
      isFavorites = res.data.userFavorites == 1;
      tags = res.data.tags == '' || res.data.tags == null
          ? []
          : res.data.tags.split(',');
      likeCount = res.data.favorites;
      videoInfo = res.data;
      var recommend = await getDetailRecommendList(
          id: res.data.id, page: 1, limit: 20, tags: res.data.tags);
      if (recommend['status'] != 0) {
        recommendList = recommend['data'];
      }
    } else {
      CommonUtils.showText(res.msg);
      context.pop();
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initVideoPage();
  }

  @override
  void dispose() {
    controller?.dispose();
    commentController?.dispose();
    super.dispose();
  }

  _onTapSwiper(int index) {
    if (_banner.length == 0) return;
    var item = _banner[index];
    var type = item['type'];
    var _adsUrl = item['url'];
    if (['', null, false].contains(_adsUrl)) {
      BotToast.showText(text: '未配置跳转链接', align: Alignment(0, 0));
      return;
    }
    switch (type) {
      case 1:
        // 外部浏览器
        CommonUtils.launchURL("$_adsUrl");
        break;
      case 3:
        // 外部浏览器
        CommonUtils.launchURL("$_adsUrl");
        break;
      case 4:
        // 外部浏览器
        var members = Provider.of<HomeConfig>(context, listen: false).member;
        var aff = members.aff;
        var piliid = members.uuid;
        CommonUtils.launchURL(_adsUrl + '?aff=$aff&piliid=$piliid');
        break;
        break;
      default:
    }
  }

  Future showButtom() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(color: Color(0xfffff4f9)),
              width: double.infinity,
              height: 452.w + (kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40.w,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                          color: Color(0XFFffd3e6),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: 0)
                    ]),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24.w,
                        ),
                        Expanded(
                            child: Center(
                          child: Text(
                            seriesList['title'],
                            style: TextStyle(
                                color: Color(0xffff5b8c),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                        GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          behavior: HitTestBehavior.translucent,
                          child: PlatformAwareAssetImage(
                            url: 'assets/images/pili_12/icon_close_red.png',
                            width: 24.w,
                            fit: BoxFit.fitWidth,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: PullRefreshList(
                    onLoading: () {
                      if (sisAll) return;
                      spage++;
                      getSeriesListVideo(
                          setBottomSheetState: setBottomSheetState);
                    },
                    child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.w),
                        itemCount: seriesList['resource'].length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.w),
                            child: SeriesCard(
                              data: seriesList['resource'][index],
                              type: seriesList['type'],
                              replace: true,
                              onTap: () {
                                context.pop();
                              },
                            ),
                          );
                        }),
                  )),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    int money = Provider.of<HomeConfig>(context, listen: false).member.money;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
              child: videoInfo == null
                  ? Column(
                      children: [
                        PageTitleBar(
                          title: '视频详情',
                        ),
                        Expanded(
                            child: Center(
                          child: PageStatus.loading(mounted),
                        ))
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 210.w,
                          width: double.infinity,
                          color: Colors.black45,
                          child: videoLoading
                              ? Center(
                                  child: Container(
                                    width: 90.w,
                                    child: Image.asset(
                                        'assets/gif/loading_pink.gif',
                                        fit: BoxFit.fitWidth,
                                        filterQuality: FilterQuality.medium),
                                  ),
                                )
                              : YyVideo(
                                  isPreview: isPreview,
                                  id: videoInfo.id.toString(),
                                  data: videoInfo,
                                  videoUrl: videoUrl,
                                  loop: true,
                                  setVideoUrl: (url) {
                                    isPreview = false;
                                    videoLoading = true;
                                    videoUrl = url;
                                    setState(() {});
                                    Future.delayed(Duration(milliseconds: 300),
                                        () {
                                      videoLoading = false;
                                      setState(() {});
                                    });
                                  },
                                ),
                        ),
                        Expanded(
                            child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 0.5,
                                    blurStyle: BlurStyle.outer,
                                    color: Color.fromRGBO(255, 91, 140, 0.2),
                                    offset: Offset(0, 2.w),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: DefaultStyle.pagePadding,
                                  vertical: 8.w),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: tabList.asMap().keys.map((e) {
                                  return GestureDetector(
                                    onTap: () {
                                      controller.jumpToPage(e);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: e == tabList.length - 1
                                              ? 0
                                              : 20.w),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Opacity(
                                            opacity: currentTab == e ? 1 : 0,
                                            child: PlatformAwareAssetImage(
                                                url:
                                                    'assets/images/icon_love_red.png',
                                                width: 6.w,
                                                filterQuality:
                                                    FilterQuality.medium),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                tabList[e]['name'],
                                                style: currentTab == e
                                                    ? TextStyle(
                                                        color:
                                                            Color(0xffFF5B8C),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14.sp)
                                                    : TextStyle(
                                                        color:
                                                            Color(0xffC2C2C2),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14.sp),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Expanded(
                                child: PageView(
                              controller: controller,
                              onPageChanged: (e) {
                                if (e == 1 && !commentShow) {
                                  commentShow = true;
                                  setState(() {
                                    commentLoadingStatus = 1;
                                  });
                                  getVideoComment();
                                }
                                currentTab = e;
                                setState(() {});
                              },
                              children: [
                                PageViewMixin(
                                    child: CustomScrollView(
                                  controller: _scrollController,
                                  cacheExtent: 1.sh * 5,
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.only(top: 16.w),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: DefaultStyle
                                                          .pagePadding),
                                                  child: Text(
                                                    videoInfo.title,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff404040),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.sp),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 17.w,
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: DefaultStyle
                                                            .pagePadding),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          height: 40.w,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '演员：' +
                                                                    (videoInfo.actors == null ||
                                                                                videoInfo.actors == ""
                                                                            ? "--"
                                                                            : videoInfo.actors)
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xffFF5B8C),
                                                                    fontSize:
                                                                        12.sp),
                                                              ),
                                                              Text(
                                                                "${videoInfo.countPlay}人看过 - ${videoInfo.createdAt.split(' ')[0]}更新",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xff979797),
                                                                    fontSize:
                                                                        11.sp),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () async {
                                                                if (kIsWeb) {
                                                                  CommonUtils
                                                                      .showText(
                                                                          '请下载APP使用下载功能！');
                                                                } else {
                                                                  PageStatus
                                                                      .showLoading();
                                                                  getDownloadUrl(
                                                                          id: videoInfo
                                                                              .id)
                                                                      .then(
                                                                          (res) {
                                                                    if (res['status'] !=
                                                                        0) {
                                                                      Map taskInfo =
                                                                          {
                                                                        "id": videoInfo
                                                                            .id
                                                                            .toString(),
                                                                        "urlPath":
                                                                            res['data']['downloadUrl'],
                                                                        "title":
                                                                            videoInfo.title,
                                                                        "thumbCover":
                                                                            videoInfo.thumbCover ??
                                                                                videoInfo.coverThumbHorizontal,
                                                                        "tags":
                                                                            tags.join('/'),
                                                                        "contentType":
                                                                            1,
                                                                        "downloading":
                                                                            false,
                                                                        "isWaiting":
                                                                            true
                                                                      };
                                                                      DownloadUtil
                                                                          .createDownloadTask(
                                                                              taskInfo);
                                                                    } else {
                                                                      YyShowDialog
                                                                          .showdialog(
                                                                        context,
                                                                        content:
                                                                            (setDialogState) {
                                                                          return Text(
                                                                            videoInfo.isfree == 2
                                                                                ? PPString.noBuySeeVideoHint
                                                                                : PPString.noVipSeeVideoHint,
                                                                            style: TextStyle(
                                                                                color: Color(0xff646464),
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 16.sp),
                                                                          );
                                                                        },
                                                                        cancelText:
                                                                            '取消',
                                                                        btnText: videoInfo.isfree ==
                                                                                2
                                                                            ? PPString.buyNow
                                                                            : PPString.upgradeNuw,
                                                                        callBack:
                                                                            () {
                                                                          if (videoInfo.isfree ==
                                                                              2) {
                                                                            showBuy(videoInfo,
                                                                                () {
                                                                              buyVideo(id: videoInfo.id, coins: (money - videoInfo.discountCoins), context: context).then((res) {
                                                                                if (res.status != 0) {
                                                                                  CommonUtils.showText('购买成功');
                                                                                  videoUrl = res.data;
                                                                                  context.pop();
                                                                                  isPreview = false;
                                                                                  videoLoading = true;
                                                                                  setState(() {});
                                                                                  Future.delayed(Duration(milliseconds: 300), () {
                                                                                    videoLoading = false;
                                                                                    setState(() {});
                                                                                  });
                                                                                } else {
                                                                                  CommonUtils.showText(res.msg);
                                                                                }
                                                                              });
                                                                            });
                                                                          } else {
                                                                            context.push('/vip');
                                                                          }
                                                                        },
                                                                      );
                                                                    }
                                                                  }).whenComplete(
                                                                          () {
                                                                    PageStatus
                                                                        .closeLoading();
                                                                  });
                                                                }
                                                              },
                                                              child: ButtonItem(
                                                                  icon:
                                                                      'icon_down',
                                                                  name: '下载'),
                                                            ),
                                                            SizedBox(
                                                              width: 20.w,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                userFavorites(
                                                                        type: 1,
                                                                        id: videoInfo
                                                                            .id)
                                                                    .then(
                                                                        (res) {
                                                                  if (res !=
                                                                          null &&
                                                                      res.status !=
                                                                          0) {
                                                                    if (isFavorites) {
                                                                      likeCount--;
                                                                    } else {
                                                                      likeCount++;
                                                                    }
                                                                    isFavorites =
                                                                        !isFavorites;
                                                                    setState(
                                                                        () {});
                                                                  } else {
                                                                    CommonUtils
                                                                        .showText(
                                                                            res.msg);
                                                                  }
                                                                });
                                                              },
                                                              child: ButtonItem(
                                                                  icon: isFavorites
                                                                      ? PPString
                                                                          .iconunLike
                                                                      : PPString
                                                                          .iconLike,
                                                                  name: CommonUtils
                                                                      .renderFixedNumber(
                                                                          likeCount
                                                                              .toDouble()),
                                                                  color: isFavorites
                                                                      ? Color(
                                                                          0xffFF84A9)
                                                                      : null),
                                                            ),
                                                            SizedBox(
                                                              width: 20.w,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                var config = Provider.of<
                                                                            HomeConfig>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .config;
                                                                ShareMovieModel.showShareMovie(
                                                                    backButtonBehavior,
                                                                    copyUrl: config
                                                                        .share
                                                                        .affUrlCopy
                                                                        .url,
                                                                    thumb: videoInfo?.coverOriginalHorizontal ==
                                                                            ''
                                                                        ? videoInfo
                                                                            ?.coverOriginalVertical
                                                                        : videoInfo
                                                                            ?.coverOriginalHorizontal,
                                                                    title: videoInfo
                                                                            ?.title ??
                                                                        '--',
                                                                    subtitle:
                                                                        videoInfo?.desc ??
                                                                            '--',
                                                                    url: config
                                                                        .share
                                                                        .affUrl
                                                                        .toString());
                                                              },
                                                              child: ButtonItem(
                                                                  icon:
                                                                      'icon_share',
                                                                  name: '分享'),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                                tags == null || tags.isEmpty
                                                    ? SizedBox(
                                                        height: 10.w,
                                                      )
                                                    : Container(
                                                        color: Colors.white54,
                                                        margin: EdgeInsets.only(
                                                            bottom: 8.w),
                                                        height: 0.5.w,
                                                      ),
                                                tags == null || tags.isEmpty
                                                    ? const SizedBox()
                                                    : Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    DefaultStyle
                                                                        .pagePadding),
                                                        child: Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        18.w),
                                                            child: Wrap(
                                                              spacing: 4.w,
                                                              runSpacing: 4.w,
                                                              children: tags
                                                                  .map((tag) {
                                                                return Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      height:
                                                                          21.w,
                                                                      padding:
                                                                          EdgeInsets
                                                                              .symmetric(
                                                                        horizontal:
                                                                            16.5.w,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(5
                                                                              .w),
                                                                          color:
                                                                              Colors.white),
                                                                      child:
                                                                          Text(
                                                                        "$tag",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xff979797),
                                                                          fontSize:
                                                                              12.sp,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              }).toList(),
                                                            ))),
                                                Container(
                                                  color: Colors.white54,
                                                  height: 0.5.w,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Center(
                                              child: _banner.length > 1
                                                  ? SizedBox(
                                                      height: 160.w,
                                                      width: 343.w,
                                                      child: Swiper(
                                                        onTap: (index) {
                                                          _onTapSwiper(index);
                                                        },
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return PageViewMixin(
                                                            child: Container(
                                                              height: 126.w,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.w),
                                                                child: PlatformAwareNetworkImage(
                                                                    url: _banner[
                                                                            index]
                                                                        [
                                                                        'img_url'],
                                                                    noVisibilityDetector:
                                                                        true),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        itemCount:
                                                            _banner.length,
                                                        autoplay:
                                                            _banner.length > 1,
                                                      ))
                                                  : SizedBox(
                                                      height:
                                                          _banner.length == 1
                                                              ? 126.w
                                                              : 0,
                                                      width: 343.w,
                                                      child: _banner.length == 1
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                _onTapSwiper(0);
                                                              },
                                                              child:
                                                                  PlatformAwareNetworkImage(
                                                                url: _banner[0]
                                                                    ['img_url'],
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    )),
                                          Container(
                                            height: 0.5.w,
                                            width: double.infinity,
                                            margin: EdgeInsets.only(
                                                left: 16.w,
                                                right: 16.w,
                                                bottom: 16.w),
                                            color: Color(0xffffd1df),
                                          ),
                                          firstSeriesList.length == 0
                                              ? const SizedBox()
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 18.w),
                                                  child: WidgetTitleBar(
                                                    title: '系列详情',
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xffff5b8c),
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                          firstSeriesList.length == 0
                                              ? const SizedBox()
                                              : SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: DefaultStyle
                                                          .pagePadding),
                                                  child: Row(
                                                    children: [
                                                      Row(
                                                        children:
                                                            firstSeriesList
                                                                .map((e) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              context.push(
                                                                  CommonUtils.getRealHash().replaceAll(
                                                                      RegExp(
                                                                          "${PPString.test}videoDetail/.*"),
                                                                      'videoDetail/' +
                                                                          e['id']
                                                                              .toString()),
                                                                  replace:
                                                                      true);
                                                            },
                                                            child: Container(
                                                              width: 160.w,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          8.w),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(3
                                                                              .w),
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            90.w,
                                                                        child:
                                                                            PlatformAwareNetworkImage(
                                                                          url: e[
                                                                              'thumb'],
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      )),
                                                                  SizedBox(
                                                                    height: 8.w,
                                                                  ),
                                                                  Text(
                                                                    e['title'],
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xff646464),
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          showButtom();
                                                        },
                                                        child: Container(
                                                          width: 70.w,
                                                          height: 39.w,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                                  boxShadow: [
                                                                BoxShadow(
                                                                    color:
                                                                        Color.fromRGBO(
                                                                            255,
                                                                            128,
                                                                            163,
                                                                            0.5),
                                                                    offset:
                                                                        Offset(0,
                                                                            2),
                                                                    blurRadius:
                                                                        3,
                                                                    spreadRadius:
                                                                        0)
                                                              ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(50
                                                                              .w),
                                                                  gradient: LinearGradient(
                                                                      begin: Alignment
                                                                          .topLeft,
                                                                      end: Alignment
                                                                          .bottomRight,
                                                                      colors: [
                                                                        Color(
                                                                            0xffff8b8b),
                                                                        Color(
                                                                            0xffff7696),
                                                                        Color(
                                                                            0xffff7299),
                                                                      ])),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                '更多',
                                                                style:
                                                                    DefaultStyle
                                                                        .white14,
                                                              ),
                                                              SizedBox(
                                                                width: 9.w,
                                                              ),
                                                              PlatformAwareAssetImage(
                                                                  url:
                                                                      'assets/images/icon_more.png',
                                                                  height: 8.w,
                                                                  filterQuality:
                                                                      FilterQuality
                                                                          .medium)
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                          SizedBox(
                                            height: 11.w,
                                          ),
                                          WidgetTitleBar(
                                            title: '为您推荐',
                                          )
                                        ],
                                      ),
                                    ),
                                    SliverPadding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: DefaultStyle.pagePadding,
                                          vertical: 11.w),
                                      sliver: SliverGrid.count(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 7.w,
                                          childAspectRatio: 1.2,
                                          children: recommendList
                                              .map((e) => Hcard(
                                                    maxLines: 1,
                                                    replace: true,
                                                    width: 171.w,
                                                    thumbUrl:
                                                        CommonUtils.getThumb(e),
                                                    cardData: e,
                                                    showField: 'title',
                                                    contentType: 1,
                                                  ))
                                              .toList()),
                                    )
                                  ],
                                )),
                                commentLoadingStatus != 2 &&
                                        commentLoadingStatus == 1
                                    ? PageStatus.loading(mounted)
                                    : PageViewMixin(
                                        child: Container(
                                        child: Column(
                                          children: [
                                            Expanded(
                                                child: PullRefreshList(
                                              onRefresh: () {
                                                page = 1;
                                                isAll = false;
                                                getVideoComment();
                                              },
                                              onLoading: () {
                                                page++;
                                                getVideoComment();
                                              },
                                              child: commentList.length == 0
                                                  ? CustomScrollView(
                                                      slivers: [
                                                        SliverToBoxAdapter(
                                                          child: PageStatus.noData(
                                                              text:
                                                                  '还没有任何影评哦～'),
                                                        )
                                                      ],
                                                    )
                                                  : ListView.builder(
                                                      cacheExtent: 1.sh * 5,
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: DefaultStyle
                                                              .pagePadding),
                                                      itemCount:
                                                          commentList.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return CommentItem(
                                                          souceType: videoInfo
                                                                      .category ==
                                                                  '1'
                                                              ? RESOURCE_TYPE_CARTOON_VIDEO
                                                              : RESOURCE_TYPE_LONG_VIDEO,
                                                          id: widget.id,
                                                          data: commentList[
                                                              index],
                                                          children: commentList[
                                                                      index][
                                                                  'child_comment']
                                                              .map<Widget>(
                                                                  (childComment) {
                                                            return CommentItem(
                                                                souceType: videoInfo
                                                                            .category ==
                                                                        '1'
                                                                    ? RESOURCE_TYPE_CARTOON_VIDEO
                                                                    : RESOURCE_TYPE_LONG_VIDEO,
                                                                id: widget.id,
                                                                data:
                                                                    childComment);
                                                          }).toList(),
                                                        );
                                                      }),
                                            )),
                                            Container(
                                              color: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 9.w,
                                                  horizontal:
                                                      DefaultStyle.pagePadding),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (Privilege.isAllowed(
                                                      context,
                                                      videoInfo.category == '1'
                                                          ? RESOURCE_TYPE_CARTOON_VIDEO
                                                          : RESOURCE_TYPE_LONG_VIDEO,
                                                      PRIVILEGE_TYPE_COMMENT)) {
                                                    InputDialog.show(
                                                            context, '请输入您的影评～')
                                                        .then((value) {
                                                      if (value != null &&
                                                          value != '') {
                                                        publishComment(
                                                                contentId:
                                                                    widget.id,
                                                                contentType: 1,
                                                                reply: value)
                                                            .then((res) {
                                                          if (res['status'] !=
                                                              0) {
                                                            CommonUtils.showText(
                                                                '影评发布成功,请刷新查看～');
                                                          } else {
                                                            CommonUtils
                                                                .showText(
                                                                    res['msg']);
                                                          }
                                                        });
                                                      } else {
                                                        CommonUtils.showText(
                                                            '请输入您的影评');
                                                      }
                                                    });
                                                  } else {
                                                    YyShowDialog.showdialog(
                                                        context,
                                                        btnText: '升级VIP',
                                                        cancelText: '取消',
                                                        callBack: () {
                                                      context.push('/vip');
                                                    }, content:
                                                            (setDialogState) {
                                                      return DefaultTextStyle(
                                                          style: DefaultStyle
                                                              .black14,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '升级VIP即可发布影评哦～',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xffFF5B8C),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16.sp),
                                                              ),
                                                            ],
                                                          ));
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16.w),
                                                  height: 36.w,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        Privilege.isAllowed(
                                                                context,
                                                                videoInfo.category ==
                                                                        '1'
                                                                    ? RESOURCE_TYPE_CARTOON_VIDEO
                                                                    : RESOURCE_TYPE_LONG_VIDEO,
                                                                PRIVILEGE_TYPE_COMMENT)
                                                            ? '能不能火就靠你啦～'
                                                            : '升级VIP即可发布影评哦～',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xff979797),
                                                            fontSize: 14.sp),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                              ],
                            ))
                          ],
                        ))
                      ],
                    ))
        ],
      ),
    );
  }
}

class CommentItem extends StatefulWidget {
  CommentItem({Key key, this.data, this.id, this.children, this.souceType})
      : super(key: key);
  final List<Widget> children;
  final int souceType;
  final dynamic data;
  final int id;
  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  String inputText = '';
  String getCreateTime() {
    DateTime timeint = DateTime.parse(widget.data['created_at']);
    var beforeText = RelativeDateFormat.format(timeint);
    return beforeText;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.data['userInfo'] == null
        ? const SizedBox()
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              if (widget.children == null) return;
              if (Privilege.isAllowed(
                  context, widget.souceType, PRIVILEGE_TYPE_COMMENT)) {
                InputDialog.show(context, '请输入您的影评～', limitingText: 16)
                    .then((value) {
                  if (value != null && value != '') {
                    publishComment(
                            commentId: widget.data['id'],
                            contentId: widget.id,
                            contentType: 1,
                            reply: value)
                        .then((res) {
                      if (res['status'] != 0) {
                        CommonUtils.showText('影评发布成功,请刷新查看～');
                      } else {
                        CommonUtils.showText(res['msg']);
                      }
                    });
                  }
                });
              } else {
                YyShowDialog.showdialog(context,
                    btnText: '升级VIP', cancelText: '取消', callBack: () {
                  context.push('/vip');
                }, content: (setDialogState) {
                  return DefaultTextStyle(
                      style: TextStyle(
                          color: Color(0xffFF5B8C),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp),
                      child: Text('升级VIP即可发布影评哦～'));
                });
              }
            },
            child: Padding(
              padding: EdgeInsets.only(top: 7.5.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.children == null
                            ? 0
                            : DefaultStyle.pagePadding),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 0.5.w, color: Color(0xffffd1df)))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30.w,
                          height: 30.w,
                          margin: EdgeInsets.only(right: 11.w),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.w),
                            child: PlatformAwareNetworkImage(
                                width: 30.w,
                                height: 30.w,
                                fit: BoxFit.fill,
                                url: widget.data['userInfo']['thumb']),
                          ),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 35.w,
                              child: Row(
                                children: [
                                  Text(
                                    widget.data['userInfo']['nickname'],
                                    style: TextStyle(
                                        color: Color(0xff646464),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  Text(
                                    getCreateTime(),
                                    style: TextStyle(
                                        color: Color(0xffC2C2C2),
                                        fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 13.w),
                              child: Text(
                                widget.data['reply'],
                                style: TextStyle(
                                    color: Color(0xff646464), fontSize: 12.sp),
                              ),
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 30.w,
                        margin: EdgeInsets.only(right: 11.w),
                      ),
                      Expanded(
                          child: widget.children == null ||
                                  widget.children.length == 0
                              ? const SizedBox()
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.children,
                                ))
                    ],
                  )
                ],
              ),
            ),
          );
  }
}

class ButtonItem extends StatelessWidget {
  const ButtonItem({Key key, this.name, this.icon, this.color})
      : super(key: key);
  final String name;
  final String icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: color == null ? Colors.white : Color(0XFFFF84A9),
          boxShadow: [
            BoxShadow(
              blurRadius: 5.0,
              blurStyle: BlurStyle.outer,
              color: Color.fromRGBO(255, 91, 140, 0.2),
              offset: Offset(0, 3.w),
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlatformAwareAssetImage(
              url: "assets/images/detail/$icon.png",
              width: 10.w,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium),
          SizedBox(
            height: 3.w,
          ),
          Text(
            name,
            style: TextStyle(
                color: color == null ? DefaultStyle.themeColor : Colors.white,
                fontSize: 12.sp),
          )
        ],
      ),
    );
  }
}
