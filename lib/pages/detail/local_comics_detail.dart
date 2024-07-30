import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_string.dart';

class LocalComicsDetatl extends StatefulWidget {
  LocalComicsDetatl({Key key, this.comicsInfo}) : super(key: key);
  final Map comicsInfo;

  @override
  _LocalComicsDetatlState createState() => _LocalComicsDetatlState();
}

class _LocalComicsDetatlState extends State<LocalComicsDetatl> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool textmore = false;
  bool isOpenAll = false;
  double scrollto;
  @override
  void initState() {
    super.initState();
  }

  Widget selectItem(int value) {
    return GestureDetector(
        onTap: () {
          context.push(CommonUtils.getRealHash('localComicsReader'),
              extra: {'comicsInfo': widget.comicsInfo, 'episode': value});
        },
        child: Stack(
          children: [
            Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: PlatformAwareAssetImage(
                    url: 'assets/images/comics/comic_btn.png',
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
                  value.toString() + '话',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff828181),
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

  ScrollController scrollController = ScrollController();
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  @override
  Widget build(BuildContext context) {
    List tags = widget.comicsInfo["tags"]?.split(',');
    List newestSeries = List.filled(widget.comicsInfo["allEpisode"], 1);
    List minWestSeries = widget.comicsInfo["allEpisode"] > 8
        ? newestSeries.sublist(0, 8)
        : newestSeries;
    return Scaffold(
      key: _scaffoldKey,
      // endDrawer: comicDrawer(),
      body: Stack(
        children: [
          Positioned(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                      cacheExtent: ScreenUtil().screenHeight * 5,
                      controller: scrollController,
                      slivers: [
                        SliverAppBar(
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
                                        url: widget.comicsInfo["thumb"],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  ],
                                ))),
                        SliverToBoxAdapter(
                          child: Container(
                            decoration:
                                BoxDecoration(color: Colors.white, boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(255, 91, 140, 0.2),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: Offset(0, ScreenUtil().setWidth(6)),
                              )
                            ]),
                            padding: EdgeInsets.all(
                              ScreenUtil().setWidth(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.comicsInfo["title"],
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
                                        (widget.comicsInfo["author"] == null ||
                                                    widget.comicsInfo[
                                                            "author"] ==
                                                        ""
                                                ? "--"
                                                : widget.comicsInfo["author"])
                                            .toString(),
                                    style: TextStyle(
                                      color: Color(0xffFF5B8C),
                                      fontWeight: FontWeight.w500,
                                      fontSize: ScreenUtil().setSp(12),
                                    ),
                                  ),
                                ),
                                Text(
                                  CommonUtils.renderFixedNumber(double.parse(
                                          widget.comicsInfo["viewsCount"]
                                              .toString())) +
                                      '人看过',
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
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                              horizontal: DefaultStyle.pagePadding,
                              vertical: ScreenUtil().setWidth(16)),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  widget.comicsInfo['description'] == null ||
                                          widget.comicsInfo['description'] == ''
                                      ? Container()
                                      : Container(
                                          padding: EdgeInsets.only(
                                              bottom:
                                                  ScreenUtil().setWidth(16)),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: ScreenUtil()
                                                          .setSp(14))),
                                              SizedBox(
                                                height:
                                                    ScreenUtil().setWidth(8),
                                              ),
                                              Stack(
                                                children: [
                                                  Text(
                                                    widget.comicsInfo[
                                                        'description'],
                                                    maxLines:
                                                        textmore ? null : 2,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff6d6d6d),
                                                        fontSize: ScreenUtil()
                                                            .setSp(14)),
                                                  ),
                                                  Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: !textmore
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                textmore =
                                                                    !textmore;
                                                                setState(() {});
                                                              },
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .translucent,
                                                              child: Container(
                                                                color: Color(
                                                                    0xfffff5f9),
                                                                child: PlatformAwareAssetImage(
                                                                    url:
                                                                        'assets/images/comics/comics_more.png',
                                                                    width: ScreenUtil()
                                                                        .setWidth(
                                                                            24),
                                                                    filterQuality:
                                                                        FilterQuality
                                                                            .high),
                                                              ),
                                                            )
                                                          : Container())
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil().setWidth(16)),
                                    child: GestureDetector(
                                        onTap: () {
                                          swichComic(1);
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        ScreenUtil()
                                                            .setWidth(20)),
                                                gradient: SweepGradient(
                                                    colors: [
                                                      DefaultStyle.themeColor,
                                                      Color(0xffff9e9e)
                                                    ])),
                                            height: ScreenUtil().setWidth(40),
                                            width: ScreenUtil().setWidth(144),
                                            child: Center(
                                              child: Text(
                                                PPString.startReading,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        ScreenUtil().setSp(14),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ))),
                                  ),
                                  Wrap(
                                    spacing: ScreenUtil().setWidth(3),
                                    runSpacing: ScreenUtil().setWidth(4),
                                    children: (isOpenAll
                                            ? newestSeries
                                            : minWestSeries)
                                        .asMap()
                                        .keys
                                        .map((e) => selectItem(e + 1))
                                        .toList(),
                                  ),
                                  newestSeries.length < 8
                                      ? Container()
                                      : GestureDetector(
                                          onTap: () {
                                            if (!isOpenAll) {
                                              scrollto =
                                                  scrollController.offset.h;
                                            } else {
                                              scrollController.jumpTo(scrollto);
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
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        ScreenUtil()
                                                            .setWidth(18)),
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
                                                  color:
                                                      DefaultStyle.themeColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      ScreenUtil().setSp(14)),
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            ),
                          ),
                        ),
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
    context.push(CommonUtils.getRealHash('localComicsReader'),
        extra: {'comicsInfo': widget.comicsInfo, 'episode': episode});
  }

  //阅读器目录
  Widget comicDrawer() {
    List allList = List.filled(widget.comicsInfo["allEpisode"], 1);
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
                Text('共' + widget.comicsInfo["allEpisode"].toString() + '话',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(18),
                        fontWeight: FontWeight.w700)),
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
                          child: PlatformAwareAssetImage(
                              url: 'assets/images/comics/comic_btn.png',
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.medium)),
                      Container(
                        width: ScreenUtil().setWidth(84.5),
                        height: ScreenUtil().setWidth(32),
                        child: Center(
                            child: Text(
                          (e + 1).toString(),
                          style: TextStyle(
                              color: Colors.white,
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
