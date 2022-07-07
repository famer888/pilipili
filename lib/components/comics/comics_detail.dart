import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/newComicsCard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
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
import 'package:pilipili/routers.dart';
import 'package:provider/provider.dart';
import '../../model/comicsDetail.dart';
import '../../utils/privilege.dart';
import 'package:pilipili/utils/download_comics.dart';

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
  bool isOpenAll = false; //是否展开全部章节
  int likeCount = 0;
  bool textmore = false;
  double scrollto;
  getPageData() {
    newestSeries.clear();
    getComicDetail(id: widget.id).then((res) {
      // LogUtil.d("漫画数据---------${res.data.toJson()}");
      if (res.status != 0) {
        loading = false;
        AppGlobal.comicThumb = res.data.thumb;
        data = res.data;
        isFavorites = res.data.userFavorites == 1;
        likeCount = res.data.favorites;
        watchLog = data.watchLog;
        newestSeriesNum = res.data.newestSeries;
        for (var i = 0; i < res.data.newestSeries; i++) {
          newestSeries.add(i + 1);
        }
        getRecommendComicsList(
                limit: 27, id: widget.id, category: res.data.categories)
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

  Widget selectItem(int value) {
    return GestureDetector(
        onTap: () {
          AppGlobal.currentReaderRouteExtra = {
            'id': data.dataId,
            'episode': value,
            'title': data.title,
            'allEpisode': data.newestSeries,
            'type': data.finished
          };
          context.push(CommonUtils.getRealHash('comicReader/$value'));
        },
        child: Stack(
          children: [
            Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: PlatformAwareAssetImage(
                    url:
                        'assets/images/comics/${value == watchLog ? 'comic_btn_active' : 'comic_btn'}.png',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium)),
            Container(
              width: ScreenUtil().setWidth(83),
              height: ScreenUtil().setWidth(36),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurStyle: BlurStyle.outer,
                      color: Color.fromRGBO(255, 211, 230, 0.42),
                      offset: Offset(0, 2),
                      blurRadius: 5),
                ],
              ),
              child: Center(
                child: Text(
                  '$value话',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(value == watchLog ? 0xffffffff : 0xff828181),
                      fontSize: ScreenUtil().setSp(14)),
                ),
              ),
            )
          ],
        ));
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
          PlatformAwareAssetImage(
              url: 'assets/images/detail/$icon.png',
              width: ScreenUtil().setWidth(10),
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium),
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

  ScrollController scrollController = ScrollController();
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  @override
  Widget build(BuildContext context) {
    List tags = data == null ? [] : data.tags.split(',');
    List minWestSeries =
        newestSeries.length > 8 ? newestSeries.sublist(0, 8) : newestSeries;
    return Scaffold(
      key: _scaffoldKey,
      // endDrawer: loading || data == null ? Container() : comicDrawer(),
      body: Stack(
        children: [
          Positioned(
            child: Column(
              children: [
                Expanded(
                  child: loading || data == null
                      ? PageStatus.loading(mounted)
                      : CustomScrollView(
                          cacheExtent: ScreenUtil().screenHeight * 5,
                          controller: scrollController,
                          slivers: [
                              SliverAppBar(
                                  automaticallyImplyLeading: false,
                                  actions: <Widget>[Container()],
                                  backgroundColor: Colors.transparent,
                                  primary: false,
                                  leading: Container(),
                                  pinned: false,
                                  elevation: 0,
                                  forceElevated: true,
                                  expandedHeight: ScreenUtil().setWidth(210),
                                  flexibleSpace: FlexibleSpaceBar(
                                      collapseMode: CollapseMode.parallax,
                                      background: Stack(
                                        children: [
                                          Container(
                                            height: ScreenUtil().setWidth(210),
                                            child: PlatformAwareNetworkImage(
                                              url: data.thumb,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        ],
                                      ))),
                              SliverToBoxAdapter(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          blurStyle: BlurStyle.outer,
                                          color:
                                              Color.fromRGBO(255, 91, 140, 0.2),
                                          offset: Offset(
                                              0, ScreenUtil().setWidth(6)),
                                        )
                                      ]),
                                  padding: EdgeInsets.all(
                                    ScreenUtil().setWidth(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.title,
                                        style: TextStyle(
                                            color: Color(0xff404040),
                                            fontSize: ScreenUtil().setSp(16),
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: ScreenUtil().setWidth(8)),
                                        child: Text(
                                          '作者：${data.author == null || data.author == "" ? "--" : data.author}',
                                          style: TextStyle(
                                            color: Color(0xffFF5B8C),
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScreenUtil().setSp(12),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${CommonUtils.renderFixedNumber(double.parse(data.viewsCount.toString()))}人看过 - 更新至$newestSeriesNum话',
                                        style: TextStyle(
                                          color: Color(0xff979797),
                                          fontWeight: FontWeight.w400,
                                          fontSize: ScreenUtil().setSp(11),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: ScreenUtil().setWidth(8)),
                                        child: Wrap(
                                            spacing: ScreenUtil().setWidth(4),
                                            runSpacing:
                                                ScreenUtil().setWidth(8),
                                            children: tags
                                                .asMap()
                                                .keys
                                                .map((e) => Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          alignment:
                                                              Alignment.center,
                                                          height: ScreenUtil()
                                                              .setWidth(21),
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0XFFFFF5F9),
                                                              borderRadius: BorderRadius
                                                                  .circular(ScreenUtil()
                                                                      .setWidth(
                                                                          5))),
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          12)),
                                                          child: Text(
                                                            tags[e],
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xffffadc6),
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          12),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ))
                                                .toList()),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        data.description == null ||
                                                data.description == ''
                                            ? Container()
                                            : Container(
                                                padding: EdgeInsets.only(
                                                    bottom: ScreenUtil()
                                                        .setWidth(16)),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: Color(
                                                                0xffffd1df),
                                                            width: ScreenUtil()
                                                                .setWidth(
                                                                    0.5)))),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('漫画简介',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xff404040),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(
                                                                        14))),
                                                    SizedBox(
                                                      height: ScreenUtil()
                                                          .setWidth(8),
                                                    ),
                                                    Stack(
                                                      children: [
                                                        Text(
                                                          data.description,
                                                          maxLines: textmore
                                                              ? null
                                                              : 2,
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff6d6d6d),
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          14)),
                                                        ),
                                                        Positioned(
                                                            bottom: 0,
                                                            right: 0,
                                                            child: !textmore
                                                                ? GestureDetector(
                                                                    onTap: () {
                                                                      textmore =
                                                                          !textmore;
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    behavior:
                                                                        HitTestBehavior
                                                                            .translucent,
                                                                    child:
                                                                        Container(
                                                                      color: Color(
                                                                          0xfffff5f9),
                                                                      child:
                                                                          PlatformAwareAssetImage(
                                                                        url:
                                                                            'assets/images/comics/comics_more.png',
                                                                        width: ScreenUtil()
                                                                            .setWidth(24),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container())
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  ScreenUtil().setWidth(16)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (kIsWeb) {
                                                        CommonUtils.showText(
                                                            '请下载APP使用下载功能！');
                                                      } else {
                                                        // CommonUtils.showText('漫画下载功能正在开发中，敬请期待！');
                                                        // LogUtil.d('漫画数据---${data.toJson()}');
                                                        // LogUtil.d(
                                                        //     '漫画列表---${recommendList[0].toJson()}');
                                                        LogUtil.d(
                                                            "漫画数据----${data}");
                                                        bool canDownload = Privilege
                                                            .isAllowedWithCount(
                                                                context,
                                                                RESOURCE_TYPE_BOOK,
                                                                PRIVILEGE_TYPE_DOWNLOAD);
                                                        if (canDownload) {
                                                          DownloadComics
                                                              .createDownloadTask({
                                                            'id': widget.id,
                                                            'title': data.title,
                                                            "description": data
                                                                .description,
                                                            "author":
                                                                data.author,
                                                            "tags": data.tags,
                                                            "viewsCount":
                                                                data.viewsCount,
                                                            'thumb': data.thumb,
                                                            'allEpisode': data
                                                                .newestSeries,
                                                            "downloading":
                                                                false,
                                                            "isWaiting": true,
                                                            "sets": []
                                                          });
                                                        } else {
                                                          YyShowDialog
                                                              .showdialog(
                                                            context,
                                                            content:
                                                                (setDialogState) {
                                                              return Text(
                                                                "您没有开启漫画下载权限哦！二次元的天堂等您开启~",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xff646464),
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            16),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              );
                                                            },
                                                            cancelText: '取消',
                                                            btnText: '立即升级',
                                                            callBack: () {
                                                              context.push(
                                                                  '/${Routes.vip}');
                                                            },
                                                          );
                                                        }
                                                      }
                                                    },
                                                    child: _btnItem(
                                                        icon: 'icon_down',
                                                        name: '下载'),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                ScreenUtil()
                                                                    .setWidth(
                                                                        4)),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        userFavorites(
                                                                type: 2,
                                                                id: data.dataId)
                                                            .then((res) {
                                                          if (res != null &&
                                                              res.status != 0) {
                                                            if (isFavorites) {
                                                              likeCount--;
                                                            } else {
                                                              likeCount++;
                                                            }
                                                            isFavorites =
                                                                !isFavorites;
                                                            setState(() {});
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
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      var config = Provider.of<
                                                                  HomeConfig>(
                                                              context,
                                                              listen: false)
                                                          .config;
                                                      ShareMovieModel.showShareMovie(
                                                          backButtonBehavior,
                                                          copyUrl: config.share
                                                              .affUrlCopy.url,
                                                          thumb: data.thumb,
                                                          title: data.title ??
                                                              '--',
                                                          subtitle:
                                                              data.description ??
                                                                  '--',
                                                          url:
                                                              '${config.share.affUrl}');
                                                    },
                                                    child: _btnItem(
                                                        icon: 'icon_share',
                                                        name: '分享'),
                                                  )
                                                ],
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    swichComic(
                                                        data.watchLog == 0
                                                            ? 1
                                                            : data.watchLog);
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          20)),
                                                          gradient:
                                                              SweepGradient(
                                                                  colors: [
                                                                Color(
                                                                    0xffff84a9),
                                                                Color(
                                                                    0xffff9e9e)
                                                              ])),
                                                      height: ScreenUtil()
                                                          .setWidth(40),
                                                      width: ScreenUtil()
                                                          .setWidth(144),
                                                      child: Center(
                                                        child: Text(
                                                          data.watchLog == 0
                                                              ? '开始阅读'
                                                              : '从${data.watchLog}话继续看',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          14),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      )))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: DefaultStyle.pagePadding,
                                      vertical: ScreenUtil().setWidth(16)),
                                  sliver: SliverGrid.count(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: ScreenUtil().setWidth(3),
                                    crossAxisSpacing: ScreenUtil().setWidth(4),
                                    childAspectRatio: 2.3,
                                    children: (isOpenAll
                                            ? newestSeries
                                            : minWestSeries)
                                        .asMap()
                                        .keys
                                        .map((e) => selectItem(newestSeries[e]))
                                        .toList(),
                                  )),
                              SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: DefaultStyle.pagePadding,
                                      vertical: ScreenUtil().setWidth(16)),
                                  sliver: SliverToBoxAdapter(
                                    child: newestSeries.length < 8
                                        ? Container()
                                        : GestureDetector(
                                            onTap: () {
                                              if (!isOpenAll) {
                                                scrollto =
                                                    scrollController.offset.h;
                                              } else {
                                                scrollController.animateTo(
                                                    scrollto,
                                                    duration: Duration(
                                                        milliseconds: 200),
                                                    curve: Curves.easeIn);
                                              }
                                              isOpenAll = !isOpenAll;
                                              setState(() {});
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                top: ScreenUtil().setWidth(16),
                                                bottom:
                                                    ScreenUtil().setWidth(8),
                                              ),
                                              alignment: Alignment.center,
                                              height: ScreenUtil().setWidth(36),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          ScreenUtil()
                                                              .setWidth(18)),
                                                  gradient: SweepGradient(
                                                      center:
                                                          Alignment.topCenter,
                                                      colors: [
                                                        Color(0xffffccdb),
                                                        Color(0xffffe4e4)
                                                      ])),
                                              child: Text(
                                                isOpenAll ? '收起' : '全部章节',
                                                style: TextStyle(
                                                    color: Color(0xffff84a9),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
                                              ),
                                            ),
                                          ),
                                  )),
                              SliverPadding(
                                padding: EdgeInsets.only(
                                    bottom: ScreenUtil().setWidth(16),
                                    top: ScreenUtil().setWidth(16)),
                                sliver: SliverToBoxAdapter(
                                  child: WidgetTitleBar(
                                    title: '为您推荐',
                                  ),
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
                                          bottom: ScreenUtil().setWidth(50.5) +
                                              (kIsWeb
                                                  ? 0
                                                  : ScreenUtil()
                                                      .bottomBarHeight),
                                          right: DefaultStyle.pagePadding,
                                          left: DefaultStyle.pagePadding),
                                      sliver: SliverGrid.count(
                                        crossAxisCount: 3,
                                        crossAxisSpacing:
                                            ScreenUtil().setWidth(7),
                                        childAspectRatio: 0.58,
                                        children:
                                            recommendList.asMap().keys.map((e) {
                                          return NewComicsCard(
                                            width: ScreenUtil().setWidth(109),
                                            relace: true,
                                            cardData: recommendList[e],
                                          );
                                        }).toList(),
                                      ))
                            ]),
                ),
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
                child: PlatformAwareAssetImage(
                    url: 'assets/images/comics_backarrow.png',
                    width: ScreenUtil().setWidth(32),
                    filterQuality: FilterQuality.medium),
              ),
            ],
          ))),
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
              child: GridView.builder(
                  padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
                  itemCount: (allList ?? []).length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: ScreenUtil().setWidth(2.5),
                    crossAxisSpacing: ScreenUtil().setWidth(4),
                    childAspectRatio: 2.64,
                  ),
                  itemBuilder: (context, e) {
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
                              child: PlatformAwareAssetImage(
                                  url:
                                      'assets/pengke/video/${watchLog == e + 1 ? 'comics_btn_active' : 'comics_btn'}.png',
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.medium)),
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
                  }))
        ],
      ),
    );
  }
}
