import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/utils/networkImage.dart';

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
  List _tabs = ["最新", "推荐", "随机"];
  int currentTab = 0;
  dynamic pagePramas;
  @override
  void initState() {
    super.initState();
    pagePramas = AppGlobal.seconedPagePramas;
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
                                          ),
                                        ),
                                        Text(
                                          _tabs[e],
                                          style: TextStyle(
                                              color: e == currentTab
                                                  ? Color(0xffff5b8c)
                                                  : Color(0xffc2c2c2),
                                              fontSize: ScreenUtil().setSp(15)),
                                        )
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
                children: _tabs
                    .map((e) => Padding(
                          padding: EdgeInsets.all(DefaultStyle.pagePadding),
                          child: GridView(
                            padding: EdgeInsets.all(0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: ScreenUtil().setWidth(12),
                              crossAxisSpacing: ScreenUtil().setWidth(12),
                              childAspectRatio: 1.8,
                            ),
                            children: [111, 1, 1, 1, 1, 1, 1, 1, 1]
                                .map((e) => Container(
                                      color: Colors.red,
                                    ))
                                .toList(),
                          ),
                        ))
                    .toList(),
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
                        child: Image.asset(
                          'assets/images/backarrow.png',
                          width: ScreenUtil().setWidth(20),
                          height: ScreenUtil().setWidth(20),
                        ),
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
