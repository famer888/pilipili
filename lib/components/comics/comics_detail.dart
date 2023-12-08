import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/newComicsCard.dart';
import 'package:pilipili/components/card/series_card.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/sharemovie.dart';
import 'package:pilipili/components/widget/my_button.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/utils/pp_asset_path.dart';
import 'package:pilipili/utils/pp_string.dart';
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

  Map seriesList;
  List firstSeriesList = [];
  int spage = 1;
  int slimit = 15;
  bool sisAll = false;
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

  getSeriesListVideo({Function setBottomSheetState}) {
    getSeriesList(id: widget.id, type: 2, page: spage, limit: slimit)
        .then((res) {
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
    });
  }

  _download() {
    if (kIsWeb) {
      CommonUtils.showText('请下载APP使用下载功能！');
    } else {
      bool canDownload = Privilege.isAllowedWithCount(
          context, RESOURCE_TYPE_BOOK, PRIVILEGE_TYPE_DOWNLOAD);
      if (canDownload) {
        DownloadComics.createDownloadTask({
          'id': widget.id,
          'title': data.title,
          "description": data.description,
          "author": data.author,
          "tags": data.tags,
          "viewsCount": data.viewsCount,
          'thumb': data.thumb,
          'allEpisode': data.newestSeries,
          "downloading": false,
          "isWaiting": true,
          "sets": []
        });
      } else {
        YyShowDialog.showdialog(
          context,
          content: (setDialogState) {
            return Text(
              "您没有开启漫画下载权限哦！二次元的天堂等您开启~",
              style: TextStyle(
                  color: Color(0xff646464),
                  fontSize: ScreenUtil().setSp(16),
                  fontWeight: FontWeight.bold),
            );
          },
          cancelText: '取消',
          btnText: PPString.upgradeNuw,
          callBack: () {
            context.push('/vip');
          },
        );
      }
    }
  }

  _useFavorite() {
    userFavorites(type: 2, id: data.dataId).then((res) {
      if (res != null && res.status != 0) {
        if (isFavorites) {
          likeCount--;
        } else {
          likeCount++;
        }
        isFavorites = !isFavorites;
        setState(() {});
      } else {
        CommonUtils.showText(res.msg);
      }
    });
  }

  _share() {
    var config = Provider.of<HomeConfig>(context, listen: false).config;
    ShareMovieModel.showShareMovie(backButtonBehavior,
        copyUrl: config.share.affUrlCopy.url,
        thumb: data.thumb,
        title: data.title ?? '--',
        subtitle: data.description ?? '--',
        url: config.share.affUrl.toString());
  }

  @override
  void initState() {
    super.initState();
    getSeriesListVideo();
    getPageData();
  }

  void _selectedItemOnClick(int value) {
    AppGlobal.currentReaderRouteExtra = {
      'id': data.dataId,
      'episode': value,
      'title': data.title,
      'allEpisode': data.newestSeries,
      'type': data.finished
    };
    context.push(CommonUtils.getRealHash('comicReader/' + value.toString()));
  }

  Widget selectItem(int value) {
    return MyButton.text(
      onTap: () => _selectedItemOnClick(value),
      text: "$value话",
      activate: value == watchLog,
    );
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
              url: 'assets/images/detail/' + icon.toString() + '.png',
              width: ScreenUtil().setWidth(10),
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium),
          SizedBox(
            height: ScreenUtil().setWidth(3),
          ),
          Text(
            name,
            style: TextStyle(
                color: color == null ? DefaultStyle.themeColor : Colors.white,
                fontSize: ScreenUtil().setSp(12)),
          )
        ],
      ),
    );
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
                    height: ScreenUtil().setWidth(40),
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
                              }))),
                ],
              ),
            );
          });
        });
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
          Container(
              padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
              width: 1.sw,
              height: 1.sh,
              child: loading || data == null
                  ? PageStatus.loading(mounted)
                  : NestedScrollView(
                      controller: scrollController,
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return [
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
                                  )))
                        ];
                      },
                      body: ListView(
                        padding: EdgeInsets.all(0),
                        children: [
                          Container(
                            decoration:
                                BoxDecoration(color: Colors.white, boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(255, 91, 140, 0.2),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: Offset(0, 1.w),
                              )
                            ]),
                            padding: EdgeInsets.all(
                              ScreenUtil().setWidth(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
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
                                    '作者：' +
                                        (data.author == null ||
                                                    data.author ==
                                                        PPString.isnull
                                                ? "--"
                                                : data.author)
                                            .toString(),
                                    style: TextStyle(
                                      color: Color(0xffFF5B8C),
                                      fontWeight: FontWeight.w500,
                                      fontSize: ScreenUtil().setSp(12),
                                    ),
                                  ),
                                ),
                                Text(
                                  (CommonUtils.renderFixedNumber(double.parse(
                                          data.viewsCount.toString()))) +
                                      '人看过 - 更新至' +
                                      newestSeriesNum.toString() +
                                      '话',
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
                                      runSpacing: ScreenUtil().setWidth(8),
                                      children: tags
                                          .asMap()
                                          .keys
                                          .map((e) => Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    height: ScreenUtil()
                                                        .setWidth(21),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0XFFFFF5F9),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                ScreenUtil()
                                                                    .setWidth(
                                                                        5))),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                ScreenUtil()
                                                                    .setWidth(
                                                                        12)),
                                                    child: Text(
                                                      tags[e],
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xffffadc6),
                                                        fontSize: ScreenUtil()
                                                            .setSp(12),
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
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: DefaultStyle.pagePadding,
                                vertical: ScreenUtil().setWidth(16)),
                            child: data.description == null ||
                                    data.description == ''
                                ? Container()
                                : Container(
                                    padding: EdgeInsets.only(
                                        bottom: ScreenUtil().setWidth(16)),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Color(0xffffd1df),
                                                width: ScreenUtil()
                                                    .setWidth(0.5)))),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('漫画简介',
                                            style: TextStyle(
                                                color: Color(0xff404040),
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ScreenUtil().setSp(14))),
                                        SizedBox(
                                          height: ScreenUtil().setWidth(8),
                                        ),
                                        Stack(
                                          children: [
                                            Text(
                                              data.description,
                                              maxLines: textmore ? null : 2,
                                              style: TextStyle(
                                                  color: Color(0xff6d6d6d),
                                                  fontSize:
                                                      ScreenUtil().setSp(14)),
                                            ),
                                            Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: !textmore
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          textmore = !textmore;
                                                          setState(() {});
                                                        },
                                                        behavior:
                                                            HitTestBehavior
                                                                .translucent,
                                                        child: Container(
                                                          color:
                                                              Color(0xfffff5f9),
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
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MyButton.topIcon(
                                      onTap: _download,
                                      icon: 'icon_down',
                                      text: '下载',
                                      activate: false,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                ScreenUtil().setWidth(4)),
                                        child: MyButton.topIcon(
                                            onTap: _useFavorite,
                                            icon: isFavorites
                                                ? PPString.iconunLike
                                                : PPString.iconLike,
                                            text: CommonUtils.renderFixedNumber(
                                                likeCount.toDouble()),
                                            activate: isFavorites)),
                                    MyButton.topIcon(
                                        onTap: _share,
                                        icon: 'icon_share',
                                        text: '分享',
                                        activate: false)
                                  ],
                                ),
                                GestureDetector(
                                    onTap: () {
                                      swichComic(data.watchLog == 0
                                          ? 1
                                          : data.watchLog);
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil().setWidth(20)),
                                            gradient: LinearGradient(
                                                colors: [
                                                  Color(0xffff84a9),
                                                  Color(0xffff9e9e),
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight)),
                                        height: ScreenUtil().setWidth(40),
                                        width: ScreenUtil().setWidth(144),
                                        alignment: Alignment.center,
                                        child: Text(
                                          data.watchLog == 0
                                              ? PPString.startReading
                                              : '从' +
                                                  data.watchLog.toString() +
                                                  '话继续看',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil().setSp(14),
                                              fontWeight: FontWeight.bold),
                                        )))
                              ],
                            ),
                          ),
                          GridView.count(
                            padding: EdgeInsets.all(15.w),
                            physics: new NeverScrollableScrollPhysics(),
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            mainAxisSpacing: ScreenUtil().setWidth(3),
                            crossAxisSpacing: ScreenUtil().setWidth(4),
                            childAspectRatio: 2.3,
                            children: (isOpenAll ? newestSeries : minWestSeries)
                                .asMap()
                                .keys
                                .map((e) => selectItem(newestSeries[e]))
                                .toList(),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: DefaultStyle.pagePadding,
                                vertical: ScreenUtil().setWidth(
                                    newestSeries.length < 8 ? 0 : 16)),
                            child: newestSeries.length < 8
                                ? Container()
                                : GestureDetector(
                                    onTap: () {
                                      if (!isOpenAll) {
                                        scrollto = scrollController.offset.h;
                                      } else {
                                        scrollController.animateTo(scrollto,
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.easeIn);
                                      }
                                      isOpenAll = !isOpenAll;
                                      setState(() {});
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        top: ScreenUtil().setWidth(16),
                                        bottom: ScreenUtil().setWidth(8),
                                      ),
                                      alignment: Alignment.center,
                                      height: ScreenUtil().setWidth(36),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              ScreenUtil().setWidth(18)),
                                          gradient: SweepGradient(
                                              center: Alignment.topCenter,
                                              colors: [
                                                Color(0xffffccdb),
                                                Color(0xffffe4e4)
                                              ])),
                                      child: Text(
                                        isOpenAll
                                            ? PPString.putAway
                                            : PPString.allChapters,
                                        style: TextStyle(
                                            color: DefaultStyle.themeColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(14)),
                                      ),
                                    ),
                                  ),
                          ),
                          Container(
                            height: 0.5.w,
                            width: double.infinity,
                            margin: EdgeInsets.only(
                                left: 16.w, right: 16.w, bottom: 16.w),
                            color: Color(0xffffd1df),
                          ),
                          firstSeriesList.length == 0
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.only(left: 18.w),
                                  child: WidgetTitleBar(
                                    title: '系列详情',
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    style: TextStyle(
                                        color: Color(0xffff5b8c),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                          firstSeriesList.length == 0
                              ? Container()
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: DefaultStyle.pagePadding),
                                  child: Row(
                                    children: [
                                      Row(
                                        children: firstSeriesList
                                            .asMap()
                                            .keys
                                            .map((e) {
                                          return GestureDetector(
                                              onTap: () {
                                                context.push(
                                                    CommonUtils.getRealHash()
                                                        .replaceAll(
                                                            RegExp(
                                                                "${PPString.test}comicsdetail/.*"),
                                                            'comicsdetail/' +
                                                                firstSeriesList[
                                                                        e]['id']
                                                                    .toString()),
                                                    replace: true);
                                              },
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(right: 8.w),
                                                width: 85.w,
                                                child: Column(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3.w),
                                                      child: Container(
                                                        width: double.infinity,
                                                        height: 125.w,
                                                        child:
                                                            PlatformAwareNetworkImage(
                                                          url:
                                                              firstSeriesList[e]
                                                                  ['thumb'],
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 8.w,
                                                    ),
                                                    Text(
                                                      firstSeriesList[e]
                                                          ['title'],
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff646464),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  ],
                                                ),
                                              ));
                                        }).toList(),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showButtom();
                                          // context.push(
                                          //     '/morePage/'+widget.id.toString()+'/'+widget.title.toString()+'/'+(widget.morePageType ?? 1).toString());
                                        },
                                        child: Container(
                                          width: ScreenUtil().setWidth(70),
                                          height: ScreenUtil().setWidth(39),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Color.fromRGBO(
                                                        255, 128, 163, 0.5),
                                                    offset: Offset(0, 2),
                                                    blurRadius: 3,
                                                    spreadRadius: 0)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      ScreenUtil()
                                                          .setWidth(50)),
                                              gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xffff8b8b),
                                                    Color(0xffff7696),
                                                    Color(0xffff7299),
                                                  ])),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '更多',
                                                style: DefaultStyle.white14,
                                              ),
                                              SizedBox(
                                                width: ScreenUtil().setWidth(9),
                                              ),
                                              PlatformAwareAssetImage(
                                                  url:
                                                      'assets/images/icon_more.png',
                                                  height:
                                                      ScreenUtil().setWidth(8),
                                                  filterQuality:
                                                      FilterQuality.medium)
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                          WidgetTitleBar(
                            title: '为您推荐',
                          ),
                          recommendList.length == 0
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    bottom: ScreenUtil().setWidth(150),
                                  ),
                                  child: PageStatus.noData(text: '没有推荐漫画哟～'),
                                )
                              : Padding(
                                  padding: EdgeInsets.only(
                                      bottom: ScreenUtil().setWidth(50.5) +
                                          (kIsWeb
                                              ? 0
                                              : ScreenUtil().bottomBarHeight),
                                      right: DefaultStyle.pagePadding,
                                      left: DefaultStyle.pagePadding),
                                  child: GridView.count(
                                    physics: new NeverScrollableScrollPhysics(),
                                    crossAxisCount: 3,
                                    shrinkWrap: true,
                                    crossAxisSpacing: ScreenUtil().setWidth(7),
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
                        ],
                      ),
                    )),
          Positioned(
              top: ScreenUtil().statusBarHeight,
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: PlatformAwareAssetImage(
                    url: 'assets/images/comics_backarrow.png',
                    width: ScreenUtil().setWidth(32),
                    filterQuality: FilterQuality.medium),
              )),
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
    context.push(CommonUtils.getRealHash('comicReader/' + episode.toString()));
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
                Text(
                    data.finished == 0 ? PPString.serialize : PPString.finished,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(18),
                        fontWeight: FontWeight.w700)),
                SizedBox(width: ScreenUtil().setWidth(10.5)),
                Text('更新至' + data.newestSeries.toString() + '话',
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
                                  url: watchLog == e + 1
                                      ? PPAssetsPath.videoComicBtnAactive
                                      : PPAssetsPath.videoComicBtn,
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
