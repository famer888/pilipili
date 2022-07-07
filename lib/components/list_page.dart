import 'dart:ui';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/card/youxuan_card.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/mixin/cardMixin.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class ListPage extends StatefulWidget {
  ListPage(
      {Key key,
      this.title = '列表页',
      this.id,
      this.isShow,
      this.index,
      this.parentName})
      : super(key: key);
  final String title;
  final String id;
  final bool isShow;
  final int index;
  final String parentName;
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with CardMixin {
  int pageStatus = 0;
  bool isAll = false;
  bool networkErr = false;
  int cardType; //1 视频 2漫画 3小说 4链接 5有声小说  6图集 7短视频；
  int page = 1;
  int limit = 24;
  List data = [];
  ScrollController _scrollController = ScrollController();
  bool isHorizontal = false;
  bool isListView = false;
  bool isActivity = false;
  bool isFall = false;
  dynamic fixedBanner;
  int elementID;
  String listType;
  @override
  void initState() {
    super.initState();
    String _prams = widget.id; // type 1长视频 2短视频 3漫画
    List _pramsString = _prams.split(',');
    Map _pramsMap = {};
    _pramsString.forEach((item) {
      List _map = item.split(':');
      if (_map.length >= 2) {
        _pramsMap[_map[0]] = _map[1];
      }
    });
    listType = _pramsMap['type'];
    try {
      elementID = int.parse(_pramsMap['element_id']);
    } catch (e) {
      CommonUtils.showText('element_id必须是数字');
    }
    if (widget.isShow && pageStatus == 0) {
      pageStatus = 1;
      getBanner();
    }
    EventBus().on('lanmu-init-view', (arg) {
      if (arg['parentName'] == widget.parentName &&
          arg['currentIndex'] == widget.index &&
          pageStatus == 0) {
        pageStatus = 1;
        getPageData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('lanmu-init-view');
  }

  void getBanner() async {
    getElementById(id: elementID, page: 1, limit: AppGlobal.smallVideoLimit)
        .then((res) {
      if (res == null) {
        networkErr = true;
        setState(() {});
        return;
      }
      fixedBanner = res['data'];
      getPageData();
    });
  }

  getPageData() async {
    var res;
    switch (listType) {
      case 'manhua':
        res = await getComicsList(type: 3, limit: limit, page: page);
        isHorizontal = false;
        cardType = 2;
        break;
      case 'image':
        res = await getPicList(limit: limit, page: page);
        isHorizontal = false;
        cardType = 6;
        break;
      case 'gold':
        res = await getChangVideoList(limit: limit, page: page, isfree: 2);
        isHorizontal = true;
        isFall = true;
        cardType = 1;
        break;
      case 'vip':
        res = await getChangVideoList(limit: limit, page: page, isfree: 1);
        isHorizontal = true;
        isFall = true;
        cardType = 1;
        break;
      case 'new':
        res = await getChangVideoList(limit: limit, page: page);
        isHorizontal = true;
        isFall = true;
        cardType = 1;
        break;
      case 'dongman':
        res = await getChangVideoList(
            type: 1, limit: limit, page: page, category: 1);
        isHorizontal = true;
        cardType = 1;
        break;
      case 'dazhebao':
        res = await getPackageList(limit: limit, page: page);
        isListView = true;
        break;
      case 'huodong':
        res = await activityList();
        isListView = true;
        isActivity = true;
        break;
      default:
    }

    if (res == null) {
      networkErr = true;
      setState(() {});
      return;
    }
    if (res == null || res['data'] == null) return;
    List resData = res['data'];
    if (page == 1) {
      data = resData;
    } else {
      data.addAll(resData);
    }
    pageStatus = 2;
    isAll = (resData.length < limit);
    setState(() {});
  }

  Widget _listView() {
    return isListView
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return isActivity
                    ? GestureDetector(
                        onTap: () {
                          context.push(CommonUtils.getRealHash(
                              'activeDetail/${data[index]['id']}'));
                        },
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Container(
                              width: constraints.minWidth,
                              height: constraints.minWidth * 0.3,
                              margin: EdgeInsets.only(
                                  bottom: ScreenUtil().setWidth(15)),
                              decoration: BoxDecoration(),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil().setWidth(10)),
                                child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(),
                                    child: Stack(
                                      children: [
                                        PlatformAwareNetworkImage(
                                          url: data[index]['resource'][0]
                                              ['url'],
                                          fit: BoxFit.cover,
                                        ),
                                        BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 5.0, sigmaY: 5.0),
                                          child: Opacity(
                                            opacity: 0.7,
                                            child: Container(),
                                          ),
                                        ),
                                        Positioned(
                                            child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  ScreenUtil().setWidth(15)),
                                          child: Center(
                                            child: Text(
                                              data[index]['title'],
                                              style: DefaultStyle.white20bold,
                                            ),
                                          ),
                                        ))
                                      ],
                                    )),
                              ));
                        }),
                      )
                    : YouxuanCard(
                        data: data[index],
                        isHorizontal: data[index]['type'] == 1);
              },
              childCount: data.length,
              addSemanticIndexes: false,
              addRepaintBoundaries: true,
              addAutomaticKeepAlives: true,
            ),
          )
        : (isFall
            ? SliverWaterfallFlow(
                gridDelegate:
                    SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: ScreenUtil().setWidth(10),
                        crossAxisSpacing: ScreenUtil().setWidth(10)),
                delegate:
                    SliverChildBuilderDelegate((BuildContext c, int index) {
                  return data[index]['mv_type'] == 1
                      ? Hcard(
                          width: ScreenUtil().setWidth(175),
                          tagIconType: data[index]['isfree'],
                          thumbUrl: CommonUtils.getThumb(data[index]),
                          contentType: 1,
                          cardData: data[index],
                          showField: 'title')
                      : Vcard(
                          width: ScreenUtil().setWidth(175),
                          isSearch: true,
                          tagIconType: data[index]['isfree'],
                          thumbUrl: CommonUtils.getThumb(data[index]),
                          contentType: 7,
                          cardData: data[index],
                          showField: 'title');
                }))
            : SliverGrid.count(
                crossAxisCount: isHorizontal ? 2 : 3,
                crossAxisSpacing: ScreenUtil().setWidth(7),
                childAspectRatio: isHorizontal ? 1.2 : 0.61,
                children: data.asMap().keys.map((e) {
                  return isHorizontal
                      ? Hcard(
                          maxLines: 1,
                          width: ScreenUtil().setWidth(174),
                          contentType: cardType,
                          thumbUrl: CommonUtils.getThumb(data[e]),
                          cardData: data[e],
                          showField: 'title',
                        )
                      : Vcard(
                          maxLines: 1,
                          width: ScreenUtil().setWidth(110),
                          contentType: cardType,
                          thumbUrl: CommonUtils.getThumb(data[e]),
                          cardData: data[e],
                          showField: 'title',
                        );
                }).toList(),
              ));
  }

  @override
  Widget build(BuildContext context) {
    double navHeight = 24;
    return (networkErr || data == null)
        ? PageStatus.noNetWork(onTap: () {
            networkErr = false;
            setState(() {});
            getPageData();
          })
        : (pageStatus != 2
            ? PageStatus.loading(true)
            : PullRefreshList(
                color: Color.fromRGBO(130, 26, 70, 0.44),
                offset:
                    DefaultStyle.navbarHegiht + ScreenUtil().statusBarHeight,
                onLoading: () {
                  if (isAll) return;
                  page++;
                  getPageData();
                },
                onRefresh: () async {
                  page = 1;
                  isAll = false;
                  networkErr = false;
                  page = 1;
                  getPageData();
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  cacheExtent: ScreenUtil().screenHeight * 5,
                  slivers: [
                    SliverAppBar(
                        backgroundColor: Colors.transparent,
                        primary: false,
                        leading: Container(),
                        pinned: false,
                        elevation: 0,
                        forceElevated: true,
                        expandedHeight: ScreenUtil().statusBarHeight +
                            DefaultStyle.navbarHegiht +
                            ScreenUtil().setWidth(160) +
                            ScreenUtil().setWidth(24),
                        bottom: PreferredSize(
                          preferredSize:
                              Size(double.infinity, ScreenUtil().setWidth(24)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topRight:
                                    Radius.circular(ScreenUtil().setWidth(24)),
                                topLeft:
                                    Radius.circular(ScreenUtil().setWidth(24))),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 244, 249, 1),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(12)),
                            ),
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background:
                                Stack(clipBehavior: Clip.none, children: [
                              fixedBanner == null ||
                                      !(fixedBanner is Map) ||
                                      fixedBanner['value'].length == 0
                                  ? PlatformAwareAssetImage(
                                      url: 'assets/images/demo_bg.png',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.medium)
                                  : Swiper(
                                      autoplayDelay: 3000,
                                      autoplay: fixedBanner['value'].length > 1,
                                      physics: fixedBanner['value'].length > 1
                                          ? null
                                          : new NeverScrollableScrollPhysics(),
                                      onIndexChanged: (e) {
                                        // CommonUtils.debugPrint('-------------------$e---------------------');
                                      },
                                      pagination: SwiperPagination(
                                          margin: EdgeInsets.only(
                                              bottom:
                                                  ScreenUtil().setWidth(40)),
                                          alignment: Alignment.bottomCenter,
                                          builder: SwiperCustomPagination(
                                              builder: (BuildContext context,
                                                  SwiperPluginConfig config) {
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: fixedBanner['value']
                                                  .asMap()
                                                  .keys
                                                  .map<Widget>((e) {
                                                return AnimatedContainer(
                                                  duration: Duration(
                                                      milliseconds: 250),
                                                  width:
                                                      ScreenUtil().setWidth(6),
                                                  height:
                                                      ScreenUtil().setWidth(6),
                                                  margin: EdgeInsets.only(
                                                      left: ScreenUtil()
                                                          .setWidth(16)),
                                                  decoration: BoxDecoration(
                                                      color:
                                                          config.activeIndex ==
                                                                  e
                                                              ? Colors.white
                                                              : Colors.white54,
                                                      borderRadius: BorderRadius
                                                          .circular(ScreenUtil()
                                                              .setWidth(3))),
                                                );
                                              }).toList(),
                                            );
                                          })),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return callDetail(
                                          cardData: fixedBanner['value'][index],
                                          contentType: 4,
                                          child: Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: ShapeDecoration(
                                                shape:
                                                    BeveledRectangleBorder()),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: ScreenUtil()
                                                          .setWidth(260) +
                                                      ScreenUtil()
                                                          .statusBarHeight,
                                                ),
                                                Positioned(
                                                    top: 0,
                                                    bottom: 0,
                                                    right: 0,
                                                    left: 0,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      child: Container(
                                                        width: double.infinity,
                                                        child:
                                                            PlatformAwareNetworkImage(
                                                          alignment:
                                                              Alignment.center,
                                                          noVisibilityDetector:
                                                              true,
                                                          url: fixedBanner[
                                                                      'value']
                                                                  [index]
                                                              ['resource_url'],
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: fixedBanner['value'].length,
                                    )
                            ]))),
                    data.length == 0
                        ? SliverToBoxAdapter(
                            child: PageStatus.noData(
                                text: '还没有“${widget.title}”的数据哦～'),
                          )
                        : SliverPadding(
                            padding: EdgeInsets.symmetric(
                                horizontal: DefaultStyle.pagePadding),
                            sliver: _listView(),
                          ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).padding.bottom +
                            ScreenUtil().bottomBarHeight,
                      ),
                    )
                  ],
                )));
  }
}
