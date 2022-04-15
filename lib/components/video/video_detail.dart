import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/hcard.dart';
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
import 'package:provider/provider.dart';
import '../../components/page_status.dart';
import '../../utils/common.dart';
import '../../utils/privilege.dart';
import 'package:pilipili/routers.dart';

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
  getVideoComment() {
    if (isAll) {
      CommonUtils.showText('已经没有评论啦～');
      return;
    }
    getCommentList(
            contentId: widget.id, contentType: 1, page: page, limit: limit)
        .then((res) {
      if (res['status'] != 0) {
        commentLoadingStatus = 2;
        List resdata = res['data'] == null ? [] : res['data'];
        isAll = resdata.length < limit;
        if (page == 1) {
          commentList = resdata;
        } else {
          commentList.add(resdata);
        }
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  initVideoPage() {
    getVideoDetail(id: widget.id).then((res) {
      CommonUtils.debugPrint(
          "---------视频地址------${res.data.source240}-------------预览视频地址---${res.data.preview}");
      if (res.status != 0) {
        isPreview = res.data.source240 == null;
        videoUrl = res.data.source240 == null
            ? res?.data?.preview
            : res.data.source240;
        isFavorites = res.data.userFavorites == 1;
        tags = res.data.tags == '' || res.data.tags == null
            ? []
            : res.data.tags.split(',');
        likeCount = res.data.favorites;
        videoInfo = res.data;
        setState(() {});
        getDetailRecommendList(
                id: res.data.id, page: 1, limit: 20, tags: res.data.tags)
            .then((recommend) {
          if (recommend['status'] != 0) {
            recommendList = recommend['data'];
          }
          setState(() {});
        });
      } else {
        CommonUtils.showText(res.msg);
        context.pop();
      }
    });
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

  Widget _btnItem({String icon, String name, Color color}) {
    return Container(
      width: ScreenUtil().setWidth(40),
      height: ScreenUtil().setWidth(40),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          color: color == null ? Colors.white : Color(0XFFFF84A9),
          boxShadow: [
            BoxShadow(
              blurRadius: 5.0,
              blurStyle: BlurStyle.outer,
              color: Color.fromRGBO(255, 91, 140, 0.2),
              offset: Offset(0, ScreenUtil().setWidth(3)),
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/detail/$icon.png',
            width: ScreenUtil().setWidth(10),
            fit: BoxFit.fitWidth,
          ),
          SizedBox(
            height: ScreenUtil().setWidth(3),
          ),
          Text(
            name,
            style: TextStyle(
                color: color == null ? Color(0xffFF84A9) : Colors.white,
                fontSize: ScreenUtil().setSp(12)),
          )
        ],
      ),
    );
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
                          height: ScreenUtil().setWidth(210),
                          width: double.infinity,
                          color: Colors.black45,
                          child: videoLoading
                              ? Center(
                                  child: Container(
                                    width: ScreenUtil().setWidth(90),
                                    child: Image.asset(
                                      'assets/images/loading_pink.gif',
                                      fit: BoxFit.fitWidth,
                                    ),
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
                                    offset: Offset(0, ScreenUtil().setWidth(2)),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: DefaultStyle.pagePadding,
                                  vertical: ScreenUtil().setWidth(8)),
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
                                              : ScreenUtil().setWidth(20)),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Opacity(
                                            opacity: currentTab == e ? 1 : 0,
                                            child: Image.asset(
                                              'assets/images/icon_love_red.png',
                                              width: ScreenUtil().setWidth(6),
                                            ),
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
                                                        fontSize: ScreenUtil()
                                                            .setSp(14))
                                                    : TextStyle(
                                                        color:
                                                            Color(0xffC2C2C2),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: ScreenUtil()
                                                            .setSp(14)),
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
                                  cacheExtent: ScreenUtil().screenHeight * 5,
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setWidth(16)),
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
                                                        fontSize: ScreenUtil()
                                                            .setSp(16)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      ScreenUtil().setWidth(17),
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
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '演员：${videoInfo.actors == null || videoInfo.actors == "" ? "--" : videoInfo.actors}',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffFF5B8C),
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              12)),
                                                            ),
                                                            Text(
                                                              '${videoInfo.countPlay}人看过 - ${videoInfo.createdAt.split(' ')[0]}更新',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xff979797),
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              11)),
                                                            )
                                                          ],
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
                                                                        "id":
                                                                            "${videoInfo.id}",
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
                                                                                ? '开通会员才能下载视频哦'
                                                                                : '收费视频需要先购买才能下载哦！',
                                                                            style: TextStyle(
                                                                                color: Color(0xff646464),
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: ScreenUtil().setSp(16)),
                                                                          );
                                                                        },
                                                                        cancelText:
                                                                            '取消',
                                                                        btnText: videoInfo.isfree ==
                                                                                2
                                                                            ? '立即购买'
                                                                            : '立即升级',
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
                                                                            context.push('/${Routes.vip}');
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
                                                              child: _btnItem(
                                                                  icon:
                                                                      'icon_down',
                                                                  name: '下载'),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          20),
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
                                                              child: _btnItem(
                                                                  icon: isFavorites
                                                                      ? 'icon_unlike'
                                                                      : 'icon_like',
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
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          20),
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
                                                                    thumb: videoInfo
                                                                        ?.coverThumbHorizontal,
                                                                    title: videoInfo
                                                                            ?.title ??
                                                                        '--',
                                                                    subtitle:
                                                                        videoInfo?.desc ??
                                                                            '--',
                                                                    url:
                                                                        '${config.share.affUrl}');
                                                              },
                                                              child: _btnItem(
                                                                  icon:
                                                                      'icon_share',
                                                                  name: '分享'),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                                SizedBox(
                                                  height:
                                                      ScreenUtil().setWidth(11),
                                                ),
                                                tags == null || tags.isEmpty
                                                    ? Container()
                                                    : Container(
                                                        color: Colors.white54,
                                                        margin: EdgeInsets.only(
                                                            bottom: ScreenUtil()
                                                                .setWidth(19)),
                                                        height: ScreenUtil()
                                                            .setWidth(0.5),
                                                      ),
                                                tags == null || tags.isEmpty
                                                    ? Container()
                                                    : Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    DefaultStyle
                                                                        .pagePadding),
                                                        child: Container(
                                                            padding: EdgeInsets.only(
                                                                bottom:
                                                                    ScreenUtil()
                                                                        .setWidth(
                                                                            22)),
                                                            child: Wrap(
                                                              spacing:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          4),
                                                              runSpacing:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          14),
                                                              children: tags
                                                                  .asMap()
                                                                  .keys
                                                                  .map((e) {
                                                                return Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      height: ScreenUtil()
                                                                          .setWidth(
                                                                              21),
                                                                      padding:
                                                                          EdgeInsets
                                                                              .symmetric(
                                                                        horizontal:
                                                                            ScreenUtil().setWidth(16.5),
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              color: Colors.white),
                                                                      child:
                                                                          Text(
                                                                        '${tags[e]}',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0xff979797),
                                                                            fontSize: ScreenUtil().setSp(12)),
                                                                      ),
                                                                    )
                                                                  ],
                                                                );
                                                              }).toList(),
                                                            ))),
                                                Container(
                                                  color: Colors.white54,
                                                  height: ScreenUtil()
                                                      .setWidth(0.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setWidth(11),
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
                                          vertical: ScreenUtil().setWidth(11)),
                                      sliver: SliverGrid.count(
                                          crossAxisCount: 2,
                                          crossAxisSpacing:
                                              ScreenUtil().setWidth(7),
                                          childAspectRatio: 1.2,
                                          children: recommendList
                                              .asMap()
                                              .keys
                                              .map((e) => Hcard(
                                                    maxLines: 1,
                                                    replace: true,
                                                    width: ScreenUtil()
                                                        .setWidth(171),
                                                    thumbUrl:
                                                        CommonUtils.getThumb(
                                                            recommendList[e]),
                                                    cardData: recommendList[e],
                                                    showField: 'title',
                                                    contentType: 1,
                                                  ))
                                              .toList()),
                                    )
                                  ],
                                )),
                                commentLoadingStatus != 2
                                    ? commentLoadingStatus == 1
                                        ? PageStatus.loading(mounted)
                                        : Container()
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
                                                      cacheExtent: ScreenUtil()
                                                              .screenHeight *
                                                          5,
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: DefaultStyle
                                                              .pagePadding,
                                                          horizontal:
                                                              DefaultStyle
                                                                  .pagePadding),
                                                      itemCount:
                                                          commentList.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return ConmentItem(
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
                                                              .asMap()
                                                              .keys
                                                              .map<Widget>((f) {
                                                            return ConmentItem(
                                                                souceType: videoInfo
                                                                            .category ==
                                                                        '1'
                                                                    ? RESOURCE_TYPE_CARTOON_VIDEO
                                                                    : RESOURCE_TYPE_LONG_VIDEO,
                                                                id: widget.id,
                                                                data: commentList[
                                                                        index][
                                                                    'child_comment'][f]);
                                                          }).toList(),
                                                        );
                                                      }),
                                            )),
                                            Container(
                                              color: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      ScreenUtil().setWidth(9),
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
                                                      context.push(
                                                          '/${Routes.vip}');
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
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            16)),
                                                              ),
                                                            ],
                                                          ));
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: ScreenUtil()
                                                          .setWidth(16)),
                                                  height:
                                                      ScreenUtil().setWidth(36),
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
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(14)),
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

class ConmentItem extends StatefulWidget {
  ConmentItem({Key key, this.data, this.id, this.children, this.souceType})
      : super(key: key);
  final List<Widget> children;
  final int souceType;
  final dynamic data;
  final int id;
  @override
  _ConmentItemState createState() => _ConmentItemState();
}

class _ConmentItemState extends State<ConmentItem> {
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
        ? Container()
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
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
                  context.push('/${Routes.vip}');
                }, content: (setDialogState) {
                  return DefaultTextStyle(
                      style: TextStyle(
                          color: Color(0xffFF5B8C),
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil().setSp(16)),
                      child: Text('升级VIP即可发布影评哦～'));
                });
              }
            },
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(7.5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: ScreenUtil().setWidth(0.5),
                                color: Color(0xffffd1df)))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(30),
                          height: ScreenUtil().setWidth(30),
                          margin:
                              EdgeInsets.only(right: ScreenUtil().setWidth(11)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                ScreenUtil().setWidth(15)),
                            child: PlatformAwareNetworkImage(
                                width: ScreenUtil().setWidth(30),
                                height: ScreenUtil().setWidth(30),
                                fit: BoxFit.fill,
                                url: widget.data['userInfo']['thumb']),
                          ),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: ScreenUtil().setWidth(35),
                              child: Row(
                                children: [
                                  Text(
                                    widget.data['userInfo']['nickname'],
                                    style: TextStyle(
                                        color: Color(0xff646464),
                                        fontSize: ScreenUtil().setSp(14),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setWidth(8),
                                  ),
                                  Text(
                                    getCreateTime(),
                                    style: TextStyle(
                                        color: Color(0xffC2C2C2),
                                        fontSize: ScreenUtil().setSp(12)),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: ScreenUtil().setWidth(13)),
                              child: Text(
                                widget.data['reply'],
                                style: TextStyle(
                                    color: Color(0xff646464),
                                    fontSize: ScreenUtil().setSp(12)),
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
                        width: ScreenUtil().setWidth(30),
                        margin:
                            EdgeInsets.only(right: ScreenUtil().setWidth(11)),
                      ),
                      Expanded(
                          child: widget.children == null ||
                                  widget.children.length == 0
                              ? SizedBox()
                              : Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: widget.children,
                                  ),
                                ))
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
