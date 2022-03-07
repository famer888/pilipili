import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:pilipili/theme/default.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/utils/common.dart';

class SeconedPageDetail extends StatefulWidget {
  SeconedPageDetail({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<SeconedPageDetail> createState() => _SeconedPageDetailState();
}

class _SeconedPageDetailState extends State<SeconedPageDetail>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollController = ScrollController();
  bool isShow = false;
  List _tabs = ["最新", "推荐", "随机"];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController.addListener(() {
      if (_scrollController.offset >= ScreenUtil().setWidth(140) &&
          isShow == false) {
        setState(() {
          isShow = true;
        });
      } else if (_scrollController.offset < ScreenUtil().setWidth(140) &&
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
              child: Image.network(
                "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg",
                width: double.infinity,
                height:
                    ScreenUtil().setWidth(140) + ScreenUtil().statusBarHeight,
                fit: BoxFit.cover,
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
                  widget.title,
                  style: DefaultStyle.white14,
                ),
              )),
          NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    shadowColor: Colors.transparent,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    primary: true,
                    leading: Container(),
                    forceElevated: false,
                    expandedHeight: ScreenUtil().setWidth(140) +
                        ScreenUtil().statusBarHeight,
                    flexibleSpace: FlexibleSpaceBar(
                      // title: Text(
                      //   widget.title,
                      //   style: DefaultStyle.white14,
                      // ),
                      collapseMode: CollapseMode.pin,
                      background: Stack(
                        children: [
                          Image.network(
                            "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg",
                            width: double.infinity,
                            height: ScreenUtil().setWidth(163) +
                                ScreenUtil().statusBarHeight,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(ScreenUtil().setWidth(12)),
                      child: Container(
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
                              horizontal: ScreenUtil().setWidth(6)),
                          controller: _tabController,
                          isScrollable: true,
                          tabs: _tabs
                              .map((e) => Container(
                                    color: Colors.green,
                                    child: Column(
                                      children: [Text(e)],
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
                    .map((e) => GridView(
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
                        ))
                    .toList(),
              )),
          isShow
              ? Positioned(
                  top: -ScreenUtil().setWidth(96),
                  right: 0,
                  left: 0,
                  child: Image.network(
                    "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg",
                    width: double.infinity,
                    height: ScreenUtil().setWidth(140) +
                        ScreenUtil().statusBarHeight,
                    fit: BoxFit.cover,
                  ))
              : Container(),
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
                      widget.title,
                      style: DefaultStyle.white14,
                    ),
                  ))
              : Container()
        ],
      ),
    );
  }
}
