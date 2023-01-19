import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/home_nav_btn.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/mixin/cardMixin.dart';
import 'package:pilipili/mixin/element_mixin.dart';
import 'package:pilipili/model/construct.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';

class Lanmu extends StatefulWidget {
  Lanmu(
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
  _LanmuState createState() => _LanmuState();
}

class _LanmuState extends State<Lanmu> with ElementMixin, CardMixin {
  int pageStatus = 0;
  int page = 1;
  bool isAll = false;
  int limit = 10;
  bool networkErr = false;
  bool isShow = false;
  dynamic fixedBanner;
  dynamic fixedNav;
  ConstructModel cm_data;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EventBus().on('lanmu-init-view', (arg) {
      if (arg['parentName'] == widget.parentName &&
          arg['currentIndex'] == widget.index &&
          pageStatus == 0) {
        pageStatus = 1;
        getPageData();
      }
    });
    if (widget.isShow && pageStatus == 0) {
      pageStatus = 1;
      getPageData();
    }
  }

  void getPageData() async {
    getConstructById(id: widget.id, page: page, limit: limit).then((res) {
      if (res == null) {
        networkErr = true;
        setState(() {});
        return;
      }
      isAll = res.elements.length < limit;
      if (page == 1) {
        cm_data = res;
        cm_data.elements.forEach((item) {
          if (item['type'] == 6) {
            fixedBanner = item;
          } else if (item['type'] == 7) {
            fixedNav = item;
          }
        });
      } else {
        cm_data.elements.addAll(res.elements);
      }
    }).whenComplete(() {
      setState(() {
        pageStatus = 2;
      });
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
    double navHeight = (fixedNav == null || fixedNav.length == 0 ? 24 : 88);
    return RepaintBoundary(
      child: networkErr
          ? PageStatus.noNetWork(onTap: () {
              networkErr = false;
              page = 1;
              setState(() {});
              getPageData();
            })
          : pageStatus != 2
              ? PageStatus.loading(true)
              : PullRefreshList(
                  color: Color.fromRGBO(130, 26, 70, 0.44),
                  offset:
                      DefaultStyle.navbarHegiht + ScreenUtil().statusBarHeight,
                  onRefresh: () {
                    page = 1;
                    getPageData();
                  },
                  onLoading: () {
                    if (isAll) {
                      CommonUtils.showText('数据已经加载完啦～');
                      return;
                    }
                    page++;
                    getPageData();
                  },
                  child: CustomScrollView(
                    cacheExtent: ScreenUtil().screenHeight * 5,
                    controller: _scrollController,
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
                                  topRight: Radius.circular(ScreenUtil()
                                      .setWidth(fixedNav == null ||
                                              fixedNav.length == 0
                                          ? 24
                                          : 30)),
                                  topLeft: Radius.circular(ScreenUtil()
                                      .setWidth(fixedNav == null ||
                                              fixedNav.length == 0
                                          ? 24
                                          : 30))),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 244, 249, 1),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setWidth(
                                        fixedNav == null || fixedNav.length == 0
                                            ? 12
                                            : 16)),
                                child: fixedNav == null ||
                                        fixedNav['value'].length == 0
                                    ? Container()
                                    : Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: ScreenUtil().setWidth(5),
                                        children: fixedNav['value']
                                            .asMap()
                                            .keys
                                            .map<Widget>((e) {
                                          return HomeNavBtn(
                                            contentType:
                                                fixedNav['content_type'],
                                            cardData: fixedNav['value'][e],
                                          );
                                        }).toList(),
                                      ),
                              ),
                            ),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.parallax,
                              background:
                                  Stack(clipBehavior: Clip.none, children: [
                                fixedBanner == null ||
                                        fixedBanner['value'].length == 0
                                    ? PlatformAwareAssetImage(
                                        url: 'assets/images/demo_bg.png',
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.medium)
                                    : Container(
                                        height: ScreenUtil().statusBarHeight +
                                            DefaultStyle.navbarHegiht +
                                            ScreenUtil().setWidth(160) +
                                            ScreenUtil().setWidth(30),
                                        child: RepaintBoundary(
                                          child: Swiper(
                                            autoplayDelay: 3000,
                                            autoplay:
                                                fixedBanner['value'].length > 1,
                                            physics: fixedBanner['value']
                                                        .length >
                                                    1
                                                ? null
                                                : new NeverScrollableScrollPhysics(),
                                            pagination: SwiperPagination(
                                                margin: EdgeInsets.only(
                                                    bottom: ScreenUtil()
                                                        .setWidth(40)),
                                                alignment:
                                                    Alignment.bottomCenter,
                                                builder: SwiperCustomPagination(
                                                    builder:
                                                        (BuildContext context,
                                                            SwiperPluginConfig
                                                                config) {
                                                  return Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children:
                                                        fixedBanner['value']
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
                                                            color: config
                                                                        .activeIndex ==
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
                                                                EdgeInsets.all(
                                                                    0),
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
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
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ))
                                                    ],
                                                  ));
                                            },
                                            itemCount:
                                                fixedBanner['value'].length,
                                          ),
                                        ),
                                      ),
                              ]))),
                      cm_data?.elements == null
                          ? SliverToBoxAdapter()
                          : SliverList(
                              delegate: SliverChildListDelegate(cm_data.elements
                                  .asMap()
                                  .keys
                                  .map(
                                    (e) => RepaintBoundary(
                                      child: getElement(
                                          element: cm_data.elements[e]),
                                    ),
                                  )
                                  .toList())),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: ScreenUtil().bottomBarHeight +
                              ScreenUtil().setWidth(30),
                        ),
                      )
                    ],
                  )),
    );
  }
}
