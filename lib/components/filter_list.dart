import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/home_nav_btn.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/mixin/element_mixin.dart';
import 'package:pilipili/model/construct.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

class FilterList extends StatefulWidget {
  FilterList(
      {Key key, this.data, this.id, this.isShow, this.index, this.tabList})
      : super(key: key);
  final dynamic data;
  final int id;
  final bool isShow;
  final int index;
  final List tabList;
  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> with ElementMixin {
  int pageStatus = 0;
  int page = 1;
  bool isAll = false;
  int limit = 30;
  bool networkErr = false;
  bool isShow = false;
  dynamic fixedBanner;
  List filterList;
  ConstructModel cm_data;
  int elementID;
  int dataType;
  int order = 1;
  int cardType;
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
            limit: limit);
        cardType = 1;
        break;
      case 2:
        res = await getChangVideoList(
            type: 2,
            filter: widget.data,
            order: order,
            page: page,
            limit: limit);
        cardType = 7;
        break;
      case 3:
        res = await getChangVideoList(
            type: 1,
            category: 1,
            filter: widget.data,
            order: order,
            page: page,
            limit: limit);
        cardType = 1;
        break;
      default:
        res = await getFilterComics(
            filter: widget.data, order: order, page: page, limit: limit);
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
    isAll = (resData.length < limit);
    setState(() {});
  }

  void getPageData() async {
    getConstructById(id: elementID, page: 1, limit: limit).then((res) {
      if (res == null) {
        networkErr = true;
        setState(() {});
        return;
      }
      cm_data = res;
      cm_data.elements.forEach((item) {
        if (item['type'] == 6) {
          fixedBanner = item;
        }
      });
      getDataList();
    });
  }

  @override
  void didUpdateWidget(covariant FilterList oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && pageStatus == 0) {
      pageStatus = 1;
      getPageData();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
                ? pageStatus == 1
                    ? PageStatus.loading(mounted)
                    : Container()
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
                                        ScreenUtil().setWidth(30)),
                                    topLeft: Radius.circular(
                                        ScreenUtil().setWidth(30))),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(255, 244, 249, 1),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: ScreenUtil().setWidth(16)),
                                ),
                              ),
                            ),
                            flexibleSpace: FlexibleSpaceBar(
                                collapseMode: CollapseMode.parallax,
                                background:
                                    Stack(clipBehavior: Clip.none, children: [
                                  fixedBanner == null ||
                                          fixedBanner['value'].length == 0
                                      ? Image.asset(
                                          'assets/images/demo_bg.png',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
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
                                                      .setWidth(100)),
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
                                            return GestureDetector(
                                              onTap: () {
                                                if (fixedBanner['value'][index]
                                                        ['type'] ==
                                                    1) {
                                                  CommonUtils.launchURL(
                                                      fixedBanner['value']
                                                              [index]['url']
                                                          .trim());
                                                } else if (fixedBanner['value']
                                                        [index]['type'] ==
                                                    2) {
                                                  String linkUrl =
                                                      fixedBanner['value']
                                                          [index]['url'];
                                                  List urlList =
                                                      linkUrl.split('?');
                                                  Map<String, dynamic> pramas =
                                                      {};
                                                  if (urlList.length > 1) {
                                                    urlList[1]
                                                        .split("&")
                                                        .forEach((item) {
                                                      List stringText =
                                                          item.split('=');
                                                      pramas[stringText[0]] =
                                                          stringText.length > 1
                                                              ? stringText[1]
                                                              : null;
                                                    });
                                                  }
                                                  context.push(urlList[0],
                                                      extra: pramas);
                                                } else if (fixedBanner['value']
                                                        [index]['type'] ==
                                                    4) {
                                                  var members =
                                                      Provider.of<HomeConfig>(
                                                              context,
                                                              listen: false)
                                                          .member;
                                                  var aff = members.aff;
                                                  var piliid = members.uuid;
                                                  CommonUtils.launchURL(
                                                      '${fixedBanner['value'][index]['url'].trim()}?aff=$aff&piliid=$piliid');
                                                }
                                              },
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
                                      crossAxisCount: dataType == 2 ? 2 : 3,
                                      crossAxisSpacing:
                                          ScreenUtil().setWidth(7),
                                      childAspectRatio:
                                          dataType == 2 ? 1.3 : 0.62,
                                      children:
                                          filterList.asMap().keys.map((e) {
                                        return dataType == 2
                                            ? Hcard(
                                                maxLines: 1,
                                                width:
                                                    ScreenUtil().setWidth(174),
                                                contentType: cardType,
                                                thumbUrl: CommonUtils.getThumb(
                                                    filterList[e]),
                                                cardData: filterList[e],
                                                showField: 'title',
                                              )
                                            : Vcard(
                                                maxLines: 1,
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
                      topLeft: Radius.circular(ScreenUtil().setWidth(20)),
                      bottomLeft: Radius.circular(ScreenUtil().setWidth(20)))),
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
                            child: Image.asset(
                              "assets/images/icon_love_red2.png",
                              width: ScreenUtil().setWidth(6),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Text(
                            filterNavList[e]['title'],
                            style: TextStyle(
                                color: filterNavList[e]['order'] == order
                                    ? Color(0xffff5b8c)
                                    : Color(0xffc2c2c2),
                                fontSize: ScreenUtil().setSp(15)),
                          )
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
