import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/mixin/cardMixin.dart';
import 'package:pilipili/mixin/element_mixin.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

class FilterList extends StatefulWidget {
  FilterList(
      {Key key,
      this.data,
      this.id,
      this.isShow,
      this.index,
      this.tabList,
      this.parentName})
      : super(key: key);
  final dynamic data;
  final int id;
  final bool isShow;
  final int index;
  final List tabList;
  final String parentName;
  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> with ElementMixin, CardMixin {
  int pageStatus = 0;
  int page = 1;
  bool isAll = false;
  bool networkErr = false;
  bool isShow = false;
  dynamic fixedBanner;
  List filterList;
  int elementID;
  int dataType;
  int order = 1;
  int cardType;
  ScrollController _scrollController = ScrollController();
  bool navShow = true;
  List filterNavList = [
    {'title': '最新', 'order': 1},
    {'title': '推荐', 'order': 2},
    {'title': '随机', 'order': 3}
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String _prams = widget.data; // type 1长视频 2短视频 3漫画
    List _pramsString = _prams.split(',');
    Map _pramsMap = {};
    _pramsString.forEach((item) {
      List _map = item.split(':');
      if (_map.length >= 2) {
        _pramsMap[_map[0]] = _map[1];
      }
    });
    try {
      elementID = int.parse(_pramsMap['element_id']);
    } catch (e) {
      CommonUtils.showText('element_id必须是数字');
    }
    try {
      dataType = int.parse(_pramsMap['type']);
    } catch (e) {
      CommonUtils.showText('type 必须是数字');
    }
    if (widget.isShow && pageStatus == 0) {
      pageStatus = 1;
      getPageData();
    }
    EventBus().on('lanmu-init-view', (arg) async {
      if (arg['parentName'] == widget.parentName &&
          arg['currentIndex'] == widget.index &&
          pageStatus == 0) {
        pageStatus = 1;
        await getPageData();
      }
    });
  }

  getDataList() async {
    var res;
    switch (dataType) {
      case 1:
        res = await getChangVideoList(
            type: 1,
            filter: widget.data,
            order: order,
            page: page,
            limit: AppGlobal.smallVideoLimit);
        cardType = 1;
        break;
      case 2:
        res = await getChangVideoList(
            type: 2,
            filter: widget.data,
            order: order,
            page: page,
            limit: AppGlobal.smallVideoLimit);
        cardType = 7;
        break;
      case 3:
        res = await getChangVideoList(
            type: 1,
            category: 1,
            filter: widget.data,
            order: order,
            page: page,
            limit: AppGlobal.smallVideoLimit);
        cardType = 1;
        break;
      default:
        res = await getFilterComics(
            filter: widget.data,
            order: order,
            page: page,
            limit: AppGlobal.smallVideoLimit);
        cardType = 2;
    }
    if (res == null) {
      networkErr = true;
      setState(() {});
      return;
    }
    if (res == null || res['data'] == null) return;
    List resData = res['data'];
    if (page == 1) {
      filterList = resData;
    } else {
      filterList.addAll(resData);
    }
    pageStatus = 2;
    isAll = (resData.length < AppGlobal.smallVideoLimit);
    setState(() {});
  }

  Future<void> getPageData() async {
    await getElementById(
            id: elementID, page: 1, limit: AppGlobal.smallVideoLimit)
        .then((res) {
      if (res == null) {
        networkErr = true;
        setState(() {});
        return;
      }
      fixedBanner = res['data'];
      getDataList();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    EventBus().off('lanmu-init-view');
  }

  @override
  Widget build(BuildContext context) {
    double navHeight = 32;
    return Stack(
      children: [
        networkErr
            ? PageStatus.noNetWork(onTap: () {
                networkErr = false;
                page = 1;
                setState(() {});
                getPageData();
              })
            : pageStatus != 2
                ? PageStatus.loading(true)
                : PullRefreshList(
                    onLoading: () {
                      if (isAll) {
                        CommonUtils.showText('数据已经加载完啦～');
                        return;
                      }
                      page++;
                      getDataList();
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      cacheExtent: ScreenUtil().screenHeight * 5,
                      physics: ClampingScrollPhysics(),
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
                                ScreenUtil().setWidth(navHeight),
                            bottom: PreferredSize(
                              preferredSize: Size(double.infinity,
                                  ScreenUtil().setWidth(navHeight)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(
                                        ScreenUtil().setWidth(24)),
                                    topLeft: Radius.circular(
                                        ScreenUtil().setWidth(24))),
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
                                          autoplay:
                                              fixedBanner['value'].length > 1,
                                          physics: fixedBanner['value'].length >
                                                  1
                                              ? null
                                              : new NeverScrollableScrollPhysics(),
                                          onIndexChanged: (e) {
                                            // CommonUtils.debugPrint('-------------------$e---------------------');
                                          },
                                          pagination: SwiperPagination(
                                              margin: EdgeInsets.only(
                                                  bottom: ScreenUtil()
                                                      .setWidth(40)),
                                              alignment: Alignment.bottomCenter,
                                              builder: SwiperCustomPagination(
                                                  builder:
                                                      (BuildContext context,
                                                          SwiperPluginConfig
                                                              config) {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: fixedBanner['value']
                                                      .asMap()
                                                      .keys
                                                      .map<Widget>((e) {
                                                    return AnimatedContainer(
                                                      duration: Duration(
                                                          milliseconds: 250),
                                                      width: ScreenUtil()
                                                          .setWidth(6),
                                                      height: ScreenUtil()
                                                          .setWidth(6),
                                                      margin: EdgeInsets.only(
                                                          left: ScreenUtil()
                                                              .setWidth(16)),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              config.activeIndex ==
                                                                      e
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .white54,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          3))),
                                                    );
                                                  }).toList(),
                                                );
                                              })),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return callDetail(
                                              cardData: fixedBanner['value']
                                                  [index],
                                              contentType: 4,
                                              child: Container(
                                                clipBehavior: Clip.hardEdge,
                                                padding: EdgeInsets.only(
                                                    bottom: ScreenUtil()
                                                        .setWidth(
                                                            navHeight - 32)),
                                                decoration: ShapeDecoration(
                                                    shape:
                                                        BeveledRectangleBorder()),
                                                child: Stack(
                                                  children: [
                                                    // Positioned(
                                                    //   right: 0,
                                                    //   left: 0,
                                                    //   bottom: 0,
                                                    //   top: 0,
                                                    //   child: Stack(
                                                    //     children: [
                                                    //       Opacity(
                                                    //         opacity: 0.7,
                                                    //         child:
                                                    //             PlatformAwareNetworkImage(
                                                    //           noVisibilityDetector:
                                                    //               true,
                                                    //           url: fixedBanner[
                                                    //                       'value']
                                                    //                   [index]
                                                    //               ['resource_url'],
                                                    //           fit: BoxFit.fill,
                                                    //         ),
                                                    //       ),
                                                    //       BackdropFilter(
                                                    //         filter:
                                                    //             ImageFilter.blur(
                                                    //                 sigmaX: 15,
                                                    //                 sigmaY: 15),
                                                    //         child: Container(
                                                    //           color: Colors.black38,
                                                    //         ),
                                                    //       )
                                                    //     ],
                                                    //   ),
                                                    // ),
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
                                                          // EdgeInsets.only(
                                                          //     top: ScreenUtil()
                                                          //             .statusBarHeight +
                                                          //         DefaultStyle
                                                          //             .navbarHegiht
                                                          //             ),
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                PlatformAwareNetworkImage(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              noVisibilityDetector:
                                                                  true,
                                                              url: fixedBanner[
                                                                          'value']
                                                                      [index][
                                                                  'resource_url'],
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount:
                                              fixedBanner['value'].length,
                                        ),
                                ]))),
                        filterList == null
                            ? SliverToBoxAdapter(
                                child: PageStatus.loading(true),
                              )
                            : filterList.isEmpty
                                ? SliverToBoxAdapter(
                                    child: PageStatus.noData(),
                                  )
                                : SliverPadding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: DefaultStyle.pagePadding),
                                    sliver: SliverGrid.count(
                                      crossAxisCount:
                                          dataType == 1 || cardType == 3
                                              ? 2
                                              : 3,
                                      crossAxisSpacing:
                                          ScreenUtil().setWidth(7),
                                      childAspectRatio:
                                          dataType == 1 || cardType == 3
                                              ? 1.2
                                              : 0.61,
                                      children:
                                          filterList.asMap().keys.map((e) {
                                        return dataType == 1 || cardType == 3
                                            ? Hcard(
                                                onTap: () {
                                                  AppGlobal.smallVideoApi =
                                                      '/api/mv/getList';
                                                  AppGlobal.smallVideoPramas = {
                                                    'type': 2,
                                                    'filter': widget.data,
                                                    'order': order
                                                  };
                                                },
                                                maxLines: 1,
                                                width:
                                                    ScreenUtil().setWidth(174),
                                                contentType: cardType,
                                                page: ((e + 1) /
                                                        AppGlobal
                                                            .smallVideoLimit)
                                                    .ceil(),
                                                thumbUrl: CommonUtils.getThumb(
                                                    filterList[e]),
                                                cardData: filterList[e],
                                                showField: 'title',
                                              )
                                            : Vcard(
                                                onTap: () {
                                                  AppGlobal.smallVideoApi =
                                                      '/api/mv/getList';
                                                  AppGlobal.smallVideoPramas = {
                                                    'type': 2,
                                                    'filter': widget.data,
                                                    'order': order
                                                  };
                                                },
                                                maxLines: 1,
                                                page: ((e + 1) /
                                                        AppGlobal
                                                            .smallVideoLimit)
                                                    .ceil(),
                                                width:
                                                    ScreenUtil().setWidth(110),
                                                contentType: cardType,
                                                thumbUrl: CommonUtils.getThumb(
                                                    filterList[e]),
                                                cardData: filterList[e],
                                                showField: 'title',
                                              );
                                      }).toList(),
                                    ),
                                  ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: ScreenUtil().bottomBarHeight +
                                ScreenUtil().setWidth(30),
                          ),
                        )
                      ],
                    ),
                  ),
        AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            top: DefaultStyle.navbarHegiht +
                ScreenUtil().statusBarHeight +
                ScreenUtil().setWidth(24),
            right: navShow
                ? 0
                : -((filterNavList.length - 1) * ScreenUtil().setWidth(60)),
            child: Container(
              height: ScreenUtil().setWidth(40),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(255, 91, 140, 0.2),
                        offset: Offset(0, 2),
                        blurRadius: 3,
                        spreadRadius: 0)
                  ],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil().setWidth(12)),
                      bottomLeft: Radius.circular(ScreenUtil().setWidth(12)))),
              child: Row(
                children: filterNavList.asMap().keys.map((e) {
                  return GestureDetector(
                    onTap: () {
                      navShow = !navShow;
                      if (order != filterNavList[e]['order']) {
                        order = filterNavList[e]['order'];
                        var currenNav = filterNavList[e];
                        filterNavList.removeAt(e);
                        filterNavList.insert(0, currenNav);
                        page = 1;
                        isAll = false;
                        getDataList();
                      }
                      setState(() {});
                    },
                    child: Container(
                      width: ScreenUtil().setWidth(60),
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: filterNavList[e]['order'] == order ? 1 : 0,
                            child: PlatformAwareAssetImage(
                                url: "assets/images/icon_love_red2.png",
                                width: ScreenUtil().setWidth(6),
                                fit: BoxFit.fitWidth,
                                filterQuality: FilterQuality.medium),
                          ),
                          Text(
                            filterNavList[e]['title'],
                            style: TextStyle(
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: filterNavList[e]['order'] == order
                                    ? Color(0xffff5b8c)
                                    : Color(0xffc2c2c2),
                                fontSize: ScreenUtil().setSp(14)),
                          ),
                          Opacity(
                            opacity: 0,
                            child: PlatformAwareAssetImage(
                                url: "assets/images/icon_love_red2.png",
                                width: ScreenUtil().setWidth(6),
                                fit: BoxFit.fitWidth,
                                filterQuality: FilterQuality.medium),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ))
      ],
    );
  }
}
