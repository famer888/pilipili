import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/pili/public_list.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

class SeconedPageDetail extends StatefulWidget {
  SeconedPageDetail({Key key}) : super(key: key);
  @override
  State<SeconedPageDetail> createState() => _SeconedPageDetailState();
}

class _SeconedPageDetailState extends State<SeconedPageDetail>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollController = ScrollController();
  bool isShow = false;
  String cartType = 'h';
  List _tabs = [
    {
      'title': "最新",
      'data': {'order': 1, 'filter': AppGlobal.seconedPagePramas['link_url']}
    },
    {
      'title': "推荐",
      'data': {'order': 2, 'filter': AppGlobal.seconedPagePramas['link_url']}
    },
    {
      'title': "随机",
      'data': {'order': 3, 'filter': AppGlobal.seconedPagePramas['link_url']}
    },
  ];
  // AppGlobal.seconedPagePramas
  int currentTab = 0;
  dynamic pagePramas;
  @override
  void initState() {
    super.initState();
    pagePramas = AppGlobal.seconedPagePramas;
    String _prams = pagePramas['link_url'];
    List _pramsString = _prams.split(',');

    Map _pramsMap = {};

    _pramsString.forEach((item) {
      List _map = item.split(':');
      if (_map.length >= 2) {
        _pramsMap[_map[0]] = _map[1];
      }
    });
    try {
      if (int.parse(_pramsMap['type']) == 2) {
        cartType = 'v';
      }
    } catch (e) {
      CommonUtils.showText('Type值应为数字');
    }
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index.toDouble() == _tabController.animation.value) {
        setState(() {
          currentTab = _tabController.index;
        });
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.offset >= ScreenUtil().setWidth(110) &&
          isShow == false) {
        setState(() {
          isShow = true;
        });
      } else if (_scrollController.offset < ScreenUtil().setWidth(110) &&
          isShow == true) {
        setState(() {
          isShow = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: -ScreenUtil().setWidth(96),
              right: 0,
              left: 0,
              child: Container(
                height:
                    ScreenUtil().setWidth(140) + ScreenUtil().statusBarHeight,
                child: PlatformAwareNetworkImage(
                  url: pagePramas['resource_url'],
                  alignment: Alignment.bottomCenter,
                  width: double.infinity,
                  height:
                      ScreenUtil().setWidth(140) + ScreenUtil().statusBarHeight,
                  fit: BoxFit.cover,
                ),
              )),
          Positioned(
              top: ScreenUtil().statusBarHeight,
              right: 0,
              left: 0,
              child: Container(
                height: ScreenUtil().setWidth(44),
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60)),
                alignment: Alignment.center,
                child: Text(
                  pagePramas['name'],
                  style: DefaultStyle.white14,
                ),
              )),
          NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    collapsedHeight: ScreenUtil().setWidth(44),
                    toolbarHeight: 0,
                    shadowColor: Colors.transparent,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    primary: true,
                    leading: Container(),
                    forceElevated: false,
                    expandedHeight: ScreenUtil().setWidth(140) +
                        ScreenUtil().statusBarHeight,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Stack(
                        children: [
                          PlatformAwareNetworkImage(
                            url: pagePramas['resource_url'],
                            width: double.infinity,
                            height: ScreenUtil().setWidth(163) +
                                ScreenUtil().statusBarHeight,
                            fit: BoxFit.cover,
                          ),
                          // Positioned(
                          //     top: 0,
                          //     right: 0,
                          //     left: 0,
                          //     bottom: 0,
                          //     child: Container(
                          //       padding: EdgeInsets.symmetric(
                          //           horizontal: ScreenUtil().setWidth(60)),
                          //       alignment: Alignment.center,
                          //       child: Text(
                          //         pagePramas['name'],
                          //         style: DefaultStyle.white15bold,
                          //       ),
                          //     )),
                        ],
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(ScreenUtil().setWidth(44)),
                      child: Container(
                        height: ScreenUtil().setWidth(44),
                        alignment: Alignment.centerLeft,
                        decoration:
                            BoxDecoration(color: Colors.white, boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(255, 91, 140, 0.1),
                              offset: Offset(0, 10),
                              blurRadius: 10,
                              spreadRadius: 0)
                        ]),
                        child: TabBar(
                          indicatorColor: Colors.transparent,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.transparent,
                          labelPadding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(0),
                              horizontal: ScreenUtil().setWidth(3)),
                          controller: _tabController,
                          isScrollable: true,
                          tabs: _tabs
                              .asMap()
                              .keys
                              .map((e) => Container(
                                    height: ScreenUtil().setWidth(44),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil().setWidth(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Opacity(
                                          opacity: e == currentTab ? 1 : 0,
                                          child: Image.asset(
                                              "assets/images/icon_love_red2.png",
                                              width: ScreenUtil().setWidth(6),
                                              fit: BoxFit.fitWidth,
                                              filterQuality:
                                                  FilterQuality.medium),
                                        ),
                                        Text(
                                          _tabs[e]['title'],
                                          style: TextStyle(
                                              color: e == currentTab
                                                  ? Color(0xffff5b8c)
                                                  : Color(0xffc2c2c2),
                                              fontSize: ScreenUtil().setSp(15)),
                                        ),
                                        Opacity(
                                          opacity: 0,
                                          child: Image.asset(
                                              "assets/images/icon_love_red2.png",
                                              width: ScreenUtil().setWidth(6),
                                              fit: BoxFit.fitWidth,
                                              filterQuality:
                                                  FilterQuality.medium),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: _tabs.asMap().keys.map((e) {
                  return PageViewMixin(
                    child: PublicList(
                      isFlow: false,
                      contentType: cartType == 'v' ? 7 : 1,
                      cartType: cartType,
                      data: _tabs[e]['data'],
                      api: '/api/mv/getList',
                      isShow: e == currentTab,
                    ),
                  );
                }).toList(),
              )),
          Positioned(
              top: -ScreenUtil().setWidth(96),
              right: 0,
              left: 0,
              child: Opacity(
                opacity: isShow ? 1 : 0,
                child: Container(
                  height:
                      ScreenUtil().setWidth(140) + ScreenUtil().statusBarHeight,
                  child: PlatformAwareNetworkImage(
                    url: pagePramas['resource_url'],
                    alignment: Alignment.bottomCenter,
                    width: double.infinity,
                    height: ScreenUtil().setWidth(140) +
                        ScreenUtil().statusBarHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          Positioned(
              top: ScreenUtil().statusBarHeight,
              right: 0,
              left: 0,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: DefaultStyle.pagePadding),
                child: Container(
                  height: ScreenUtil().setWidth(44),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.pop();
                        },
                        child: Image.asset('assets/images/backarrow.png',
                            width: ScreenUtil().setWidth(20),
                            height: ScreenUtil().setWidth(20),
                            filterQuality: FilterQuality.medium),
                      ),
                      Container()
                    ],
                  ),
                ),
              )),
          isShow
              ? Positioned(
                  top: ScreenUtil().statusBarHeight,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: ScreenUtil().setWidth(44),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(60)),
                    alignment: Alignment.center,
                    child: Text(
                      pagePramas['name'],
                      style: DefaultStyle.white14,
                    ),
                  ))
              : Container()
        ],
      ),
    );
  }
}
