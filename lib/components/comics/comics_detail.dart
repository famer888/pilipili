import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/sharemovie.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/logUtil.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';
import '../../model/comicsDetail.dart';
import '../../utils/privilege.dart';

class ComicsDetatl extends StatefulWidget {
  ComicsDetatl({Key key, this.id}) : super(key: key);
  final int id;

  @override
  _ComicsDetatlState createState() => _ComicsDetatlState();
}

class _ComicsDetatlState extends State<ComicsDetatl> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool loading = true;
  int watchLog;
  Data data;
  List newestSeries = [];
  int newestSeriesNum = 0;
  List recommendList = [];
  bool isFavorites = false;
  getPageData() {
    newestSeries.clear();
    getComicDetail(id: widget.id).then((res) {
      // LogUtil.d("漫画数据---------${res.data.toJson()}");
      if (res.status != 0) {
        loading = false;
        AppGlobal.comicThumb = res.data.thumb;
        data = res.data;
        isFavorites = res.data.userFavorites == 1;
        watchLog = data.watchLog;
        newestSeriesNum = res.data.newestSeries;
        for (var i = 0; i < res.data.newestSeries; i++) {
          if (res.data.newestSeries <= 8) {
            newestSeries.add(i + 1);
          } else if (i <= 3 || i >= res.data.newestSeries - 4) {
            newestSeries.add(i + 1);
          }
        }
        getRecommendComicsList(
                limit: 10, id: widget.id, category: res.data.categories)
            .then((res) {
          recommendList = res.data;
          setState(() {});
        });
        setState(() {});
      } else {
        CommonUtils.showText(res.msg);
        context.pop();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  Widget selectItem(int value, int length, List selectList) {
    String text = '';
    bool more;
    if (length >= 8 && value == selectList[4]) {
      text = '...';
      more = true;
    } else {
      text = value.toString();
      more = false;
    }
    return GestureDetector(
      onTap: () {
        if (!more) {
          AppGlobal.currentReaderRouteExtra = {
            'id': data.dataId,
            'episode': value,
            'title': data.title,
            'allEpisode': data.newestSeries,
            'type': data.finished
          };
          context.push(CommonUtils.getRealHash('comicReader/$value'));
        } else {
          _scaffoldKey.currentState.openEndDrawer();
        }
      },
      child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/pengke/video/${value == watchLog ? 'comics_btn_active' : (value <= 4 ? 'comics_btn' : 'comics_btn_un')}.png',
                fit: BoxFit.fill,
              )),
          Container(
            width: ScreenUtil().setWidth(84),
            height: ScreenUtil().setWidth(34),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                    color: Color(value == watchLog
                        ? 0xff62f7ff
                        : (value <= 4 ? 0xffd7d7d7 : 0xff6a6a6a)),
                    fontSize: ScreenUtil().setSp(16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _btnItem({String icon, String name, Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/pengke/video/$icon.png',
          width: ScreenUtil().setWidth(25),
          fit: BoxFit.fitWidth,
        ),
        SizedBox(
          width: ScreenUtil().setWidth(7),
        ),
        Text(
          name,
          style: TextStyle(
              color: color != null ? color : Color(0xffffffff),
              fontSize: ScreenUtil().setSp(14)),
        )
      ],
    );
  }

  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  @override
  Widget build(BuildContext context) {
    List tags = data == null ? [] : data.tags.split(',');
    tags = tags.length > 3 ? tags.getRange(0, 2).toList() : tags;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xfff7f6fb),
      endDrawer: loading || data == null ? Container() : comicDrawer(),
      body: Stack(
        children: [
          Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(),
              child: Stack(
                children: [
                  data == null
                      ? Container()
                      : Opacity(
                          opacity: 0.7,
                          child: PlatformAwareNetworkImage(
                            url: data.thumb,
                            fit: BoxFit.cover,
                          ),
                        ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: Color.fromRGBO(0, 0, 0, 0.8),
                    ),
                  ),
                ],
              )),
          Positioned(
            child: Column(
              children: [
                Expanded(
                    child: loading || data == null
                        ? PageStatus.loading(mounted)
                        : Padding(
                            padding: EdgeInsets.only(
                                bottom: ScreenUtil().setWidth(50.5) +
                                    (kIsWeb
                                        ? 0
                                        : ScreenUtil().bottomBarHeight)),
                            child: CustomScrollView(slivers: [
                              SliverAppBar(
                                  backgroundColor: Colors.transparent,
                                  primary: false,
                                  leading: Container(),
                                  pinned: false,
                                  elevation: 0,
                                  forceElevated: true,
                                  expandedHeight: ScreenUtil().setWidth(320),
                                  flexibleSpace: FlexibleSpaceBar(
                                      collapseMode: CollapseMode.parallax,
                                      background: Stack(
                                        children: [
                                          Container(
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(),
                                              child: Stack(
                                                children: [
                                                  data == null
                                                      ? Container()
                                                      : Container(
                                                          child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: ScreenUtil()
                                                              .setWidth(215),
                                                          color:
                                                              Color(0xffffa500),
                                                          child:
                                                              PlatformAwareNetworkImage(
                                                                  url: data
                                                                      .thumb,
                                                                  fit: BoxFit
                                                                      .fill),
                                                        )),
                                                  BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 15, sigmaY: 15),
                                                    child: Container(
                                                      color: Colors.black38,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          Positioned(
                                              left: 0,
                                              right: 0,
                                              top: ScreenUtil().setWidth(120),
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: ScreenUtil()
                                                        .setWidth(14.5)),
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                        top: 0,
                                                        left: 0,
                                                        bottom: 0,
                                                        right: 0,
                                                        child: Image.asset(
                                                          'assets/pengke/video/comics_card_bg.png',
                                                          fit: BoxFit.fill,
                                                        )),
                                                    Container(
                                                      padding: EdgeInsets.all(
                                                          ScreenUtil()
                                                              .setWidth(13.5)),
                                                      height: ScreenUtil()
                                                          .setWidth(185.5),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            margin: EdgeInsets.only(
                                                                right: ScreenUtil()
                                                                    .setWidth(
                                                                        15)),
                                                            height: ScreenUtil()
                                                                .setWidth(
                                                                    155.5),
                                                            width: ScreenUtil()
                                                                .setWidth(110),
                                                            child:
                                                                PlatformAwareNetworkImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    url: data
                                                                        .thumb),
                                                          ),
                                                          Expanded(
                                                              child: Container(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  data.title,
                                                                  style: DefaultStyle
                                                                      .white18bold,
                                                                ),
                                                                Text(
                                                                  '作者：${data.author == null || data.author == "" ? "--" : data.author}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xff62f7ff),
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            12),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${CommonUtils.renderFixedNumber(double.parse(data.viewsCount.toString()))}次观看',
                                                                  style: DefaultStyle
                                                                      .lgray13,
                                                                ),
                                                                Container(
                                                                  child: Row(
                                                                      children: tags
                                                                          .asMap()
                                                                          .keys
                                                                          .map((e) => e <= 1
                                                                              ? Padding(
                                                                                  padding: EdgeInsets.only(right: ScreenUtil().setWidth(8.5)),
                                                                                  child: Text(
                                                                                    '#${tags[e]}',
                                                                                    style: DefaultStyle.white10,
                                                                                  ),
                                                                                )
                                                                              : Container())
                                                                          .toList()),
                                                                ),
                                                                data.description ==
                                                                            null ||
                                                                        data.description ==
                                                                            ''
                                                                    ? Container()
                                                                    : Text(
                                                                        data.description,
                                                                        style: TextStyle(
                                                                            height:
                                                                                1.7,
                                                                            fontSize:
                                                                                ScreenUtil().setSp(12),
                                                                            color: Color(0xff666666)),
                                                                        maxLines:
                                                                            3,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                              ],
                                                            ),
                                                          ))
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ))
                                        ],
                                      ))),
                              SliverPadding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: DefaultStyle.pagePadding,
                                    vertical: ScreenUtil().setWidth(16)),
                                sliver: SliverToBoxAdapter(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '连载',
                                            style: DefaultStyle.white18bold,
                                          ),
                                          SizedBox(
                                            width: ScreenUtil().setWidth(8.5),
                                          ),
                                          Text(
                                            '更新至$newestSeriesNum话',
                                            style: DefaultStyle.lgray13,
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _scaffoldKey.currentState
                                              .openEndDrawer();
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '全部',
                                              style: DefaultStyle.gray12,
                                            ),
                                            SizedBox(
                                              width: ScreenUtil().setWidth(8.5),
                                            ),
                                            Image.asset(
                                              'assets/pengke/icon_more.png',
                                              width: ScreenUtil().setWidth(12),
                                              height: ScreenUtil().setWidth(12),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: DefaultStyle.pagePadding,
                                    vertical: ScreenUtil().setWidth(16)),
                                sliver: SliverToBoxAdapter(
                                  child: Wrap(
                                    spacing: ScreenUtil().setWidth(3),
                                    runSpacing: ScreenUtil().setWidth(4),
                                    children: newestSeries
                                        .asMap()
                                        .keys
                                        .map((e) => selectItem(newestSeries[e],
                                            newestSeriesNum, newestSeries))
                                        .toList(),
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.only(
                                    right: DefaultStyle.pagePadding,
                                    left: DefaultStyle.pagePadding,
                                    top: ScreenUtil().setWidth(24)),
                                sliver: SliverToBoxAdapter(
                                  child: Text(
                                    '相关推荐',
                                    style: DefaultStyle.white18bold,
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Image.asset(
                                  'assets/pengke/img_xian.png',
                                  fit: BoxFit.fitWidth,
                                  width: double.infinity,
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: ScreenUtil().setWidth(7),
                                ),
                              ),
                              recommendList.length == 0
                                  ? SliverToBoxAdapter(
                                      child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: ScreenUtil().setWidth(150),
                                      ),
                                      child:
                                          PageStatus.noData(text: '没有推荐漫画哟～'),
                                    ))
                                  : SliverPadding(
                                      padding: EdgeInsets.only(
                                          right: DefaultStyle.pagePadding,
                                          left: DefaultStyle.pagePadding),
                                      sliver: SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                        (context, index) => Vcard(
                                          // relace: true,
                                          cardData: recommendList[index],
                                        ),
                                        childCount: recommendList.length,
                                      )))
                            ]),
                          )),
              ],
            ),
          ),
          Positioned(
              child: SafeArea(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: DefaultStyle.pagePadding),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, ScreenUtil().setWidth(1)),
                            blurRadius: ScreenUtil().setWidth(5))
                      ],
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white70),
                  width: ScreenUtil().setWidth(30),
                  height: ScreenUtil().setWidth(30),
                  child: Center(
                    child: Image.asset(
                      'assets/pengke/backarrow.png',
                      width: ScreenUtil().setWidth(20),
                      height: ScreenUtil().setWidth(20),
                    ),
                  ),
                ),
              ),
            ],
          ))),
          Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: loading || data == null
                  ? Container()
                  : Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            left: 0,
                            bottom: 0,
                            top: 0,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                color: Colors.black38,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Image.asset(
                              'assets/pengke/video/fot_bg.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: DefaultStyle.pagePadding,
                                bottom:
                                    kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                            height: ScreenUtil().setWidth(50.5) +
                                (kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    userFavorites(type: 2, id: data.dataId)
                                        .then((res) {
                                      if (res != null && res.status != 0) {
                                        isFavorites = !isFavorites;
                                        setState(() {});
                                      } else {
                                        CommonUtils.showText(res.msg);
                                      }
                                    });
                                  },
                                  child: _btnItem(
                                      icon: isFavorites
                                          ? 'icon_like'
                                          : 'icon_unlike',
                                      name: '收藏',
                                      color: isFavorites
                                          ? Color(0xff62f7ff)
                                          : null),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (kIsWeb) {
                                      CommonUtils.showText('请下载APP使用下载功能！');
                                    } else {
                                      // CommonUtils.showText('漫画下载功能正在开发中，敬请期待！');
                                      // LogUtil.d('漫画数据---${data.toJson()}');
                                      // LogUtil.d(
                                      //     '漫画列表---${recommendList[0].toJson()}');
                                      LogUtil.d("漫画数据----${data}");
                                      bool canDownload =
                                          Privilege.isAllowedWithCount(
                                              context,
                                              RESOURCE_TYPE_BOOK,
                                              PRIVILEGE_TYPE_DOWNLOAD);
                                      if (canDownload) {
                                        // DownloadComics.createDownloadTask({
                                        //   'id': widget.id,
                                        //   'title': data.title,
                                        //   "description": data.description,
                                        //   "author": data.author,
                                        //   "tags": data.tags,
                                        //   "viewsCount": data.viewsCount,
                                        //   'thumb': data.thumb,
                                        //   'allEpisode': data.newestSeries,
                                        //   "downloading": false,
                                        //   "isWaiting": true,
                                        //   "sets": []
                                        // });
                                      } else {
                                        YyShowDialog.showdialog(
                                          context,
                                          title: '提示',
                                          content: (setDialogState) {
                                            return Text(
                                              "您没有开启漫画下载权限哦！二次元的天堂等您开启~",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      ScreenUtil().setSp(15),
                                                  decoration:
                                                      TextDecoration.none),
                                            );
                                          },
                                          cancelText: '取消',
                                          btnText: '立即升级',
                                          callBack: () {
                                            // context.push('/${Routes.vip}');
                                          },
                                        );
                                      }
                                    }
                                  },
                                  child:
                                      _btnItem(icon: 'icon_down', name: '下载'),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    var config = Provider.of<HomeConfig>(
                                            context,
                                            listen: false)
                                        .config;
                                    ShareMovieModel.showShareMovie(
                                        backButtonBehavior,
                                        copyUrl: config.share.affUrlCopy.url,
                                        thumb: data.thumb,
                                        title: data.title ?? '--',
                                        subtitle: data.description ?? '--',
                                        url: '${config.share.affUrl}');
                                  },
                                  child:
                                      _btnItem(icon: 'icon_share', name: '分享'),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    swichComic(
                                        data.watchLog == 0 ? 1 : data.watchLog);
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned(
                                          top: 0,
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Image.asset(
                                            'assets/pengke/video/video_duan_btn.png',
                                            fit: BoxFit.fill,
                                          )),
                                      Container(
                                          height: ScreenUtil().setWidth(34),
                                          width: ScreenUtil().setWidth(128),
                                          child: Center(
                                            child: Text(
                                              data.watchLog == 0
                                                  ? '开始阅读'
                                                  : '继续阅读  第${data.watchLog}话',
                                              style: DefaultStyle.zhuti15,
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(12),
                                )
                              ],
                            ),
                          )
                        ],
                      )))
        ],
      ),
    );
  }

  swichComic(int episode) {
    AppGlobal.currentReaderRouteExtra = {
      'id': widget.id,
      'title': data.title,
      'allEpisode': data.newestSeries,
      'type': data.finished,
      'episode': episode
    };
    context.push(CommonUtils.getRealHash('comicReader/$episode'));
  }

  //阅读器目录
  Widget comicDrawer() {
    List allList = List.filled(data.newestSeries, 1);
    return Container(
      height: ScreenUtil().screenHeight,
      width: ScreenUtil().setWidth(286.5),
      color: Color(0xff161423),
      child: Column(
        children: [
          SizedBox(
            height: ScreenUtil().statusBarHeight,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(19),
                horizontal: ScreenUtil().setWidth(14)),
            child: Row(
              children: [
                Text(data.finished == 0 ? '连载' : '已完结',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(18),
                        fontWeight: FontWeight.w700)),
                SizedBox(width: ScreenUtil().setWidth(10.5)),
                Text('更新至${data.newestSeries}话',
                    style: TextStyle(
                        color: Color(0xff999999),
                        fontSize: ScreenUtil().setSp(13))),
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
            child: Wrap(
              spacing: ScreenUtil().setWidth(2.5),
              runSpacing: ScreenUtil().setWidth(4),
              children: allList.asMap().keys.map((e) {
                return GestureDetector(
                  onTap: () {
                    context.pop();
                    swichComic(e + 1);
                  },
                  child: Stack(
                    children: [
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Image.asset(
                            'assets/pengke/video/${watchLog == e + 1 ? 'comics_btn_active' : 'comics_btn'}.png',
                            fit: BoxFit.fill,
                          )),
                      Container(
                        width: ScreenUtil().setWidth(84.5),
                        height: ScreenUtil().setWidth(32),
                        child: Center(
                            child: Text(
                          (e + 1).toString(),
                          style: TextStyle(
                              color: watchLog == e + 1
                                  ? Color(0xff62f7ff)
                                  : Colors.white,
                              fontSize: ScreenUtil().setSp(15)),
                        )),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ))
        ],
      ),
    );
  }
}
