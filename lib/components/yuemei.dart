import 'dart:ui';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/yuemei_card.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/mixin/cardMixin.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/store/globle_value.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

class YuemeiPage extends StatefulWidget {
  final bool isShow;
  YuemeiPage({Key key, this.isShow = false}) : super(key: key);

  @override
  _YuemeiPageState createState() => _YuemeiPageState();
}

class _YuemeiPageState extends State<YuemeiPage> with CardMixin {
  List yuepaoList = [];

  ScrollController _scrollController = ScrollController();
  dynamic fixedBanner;
  String location = '全国';
  bool isListView = true;
  bool networkErr = false;
  int pageStatus = 0;
  bool loading = true;
  bool isAll = false;
  int page = 1;
  int limit = 30;
  getPageData(String _city) {
    if (page == 1 && !loading) {
      loading = true;
      _scrollController.jumpTo(0);
      setState(() {});
    }
    getYuepaoList(page, limit, _city).then((res) {
      if (res['status'] != 0) {
        var resData = res['data'] == null ? [] : res['data'];
        if (res['status'] != 0) {
          pageStatus = 2;
          loading = false;
          isAll = resData.length == 0;
          if (page == 1) {
            yuepaoList = resData;
          } else {
            yuepaoList.addAll(resData);
          }
          setState(() {});
        } else {
          CommonUtils.showText(res['msg']);
        }
      }
    });
  }

  void getBanner() async {
    getElementById(id: 139, page: 1, limit: AppGlobal.smallVideoLimit)
        .then((res) {
      if (res == null) {
        networkErr = true;
        setState(() {});
        return;
      }
      fixedBanner = res['data'];
      getPageData(location);
    });
  }

  Widget _listView() {
    return isListView
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return YuemeiCard(
                    w: 118.w,
                    h: 145.w,
                    isShowInfo: true,
                    data: yuepaoList[index]);
              },
              childCount: yuepaoList.length,
              addSemanticIndexes: false,
              addRepaintBoundaries: true,
              addAutomaticKeepAlives: true,
            ),
          )
        : SliverGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 12.w,
            crossAxisSpacing: 12.w,
            childAspectRatio: 0.843,
            children: yuepaoList.asMap().keys.map((e) {
              return YuemeiCard(
                  w: 118.w, h: 145.w, isShowInfo: false, data: yuepaoList[e]);
              ;
            }).toList(),
          );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EventBus().on('change_city', (arg) {
      page = 1;
      _scrollController.jumpTo(0);
      location = arg;
      getPageData(arg);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    EventBus().off('change_city');
  }

  @override
  void didUpdateWidget(covariant YuemeiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && pageStatus == 0) {
      setState(() {
        pageStatus = 1;
      });
      getBanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    // location = Provider.of<GlobleValue>(context, listen: false).yplocation;
    return Stack(
      children: [
        (networkErr || yuepaoList == null)
            ? PageStatus.noNetWork(onTap: () {
                networkErr = false;
                setState(() {});
                getPageData(location);
              })
            : (pageStatus != 2
                ? PageStatus.loading(true)
                : PullRefreshList(
                    color: Color.fromRGBO(130, 26, 70, 0.44),
                    offset: DefaultStyle.navbarHegiht +
                        ScreenUtil().statusBarHeight,
                    onLoading: () {
                      if (isAll) return;
                      page++;
                      getPageData(location);
                    },
                    // },
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
                              preferredSize: Size(
                                  double.infinity, ScreenUtil().setWidth(24)),
                              child: Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 12.w),
                                    margin:
                                        EdgeInsets.only(left: 75.w, top: 20.w),
                                    height: 36.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'C圈嫩妹 制服COS 官方认证',
                                          style: TextStyle(
                                              color: Color(0xffc2c2c2),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp),
                                        ),
                                        Text(' 包赔付',
                                            style: TextStyle(
                                                color: DefaultStyle.themeColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp)),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                      left: 0,
                                      bottom: 0,
                                      child: PlatformAwareAssetImage(
                                        url: 'assets/images/pili_12/gfrz.png',
                                        width: 151.w,
                                        fit: BoxFit.fitWidth,
                                      ))
                                ],
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
                                        )
                                ]))),
                        loading
                            ? SliverToBoxAdapter(
                                child: PageStatus.loading(true),
                              )
                            : (yuepaoList.length == 0
                                ? SliverToBoxAdapter(
                                    child: PageStatus.noData(text: '没有约妹资源哟～'),
                                  )
                                : SliverPadding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 17.w,
                                        horizontal: DefaultStyle.pagePadding),
                                    sliver: _listView(),
                                  )),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: MediaQuery.of(context).padding.bottom +
                                ScreenUtil().bottomBarHeight,
                          ),
                        )
                      ],
                    ))),
        Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
              color: Color.fromRGBO(130, 56, 78, 0.44),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 15.w, vertical: 17.5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DefaultTextStyle(
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.81),
                            fontSize: 16.sp),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.push(
                                    CommonUtils.getRealHash('cityPicker'));
                              },
                              behavior: HitTestBehavior.translucent,
                              child: Row(
                                children: [
                                  PlatformAwareAssetImage(
                                    url:
                                        'assets/images/pili_12/icon_location.png',
                                    width: 24.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Text(location)
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            GestureDetector(
                              onTap: () {
                                isListView = !isListView;
                                _scrollController.jumpTo(0);
                                setState(() {});
                              },
                              behavior: HitTestBehavior.translucent,
                              child: Row(
                                children: [
                                  PlatformAwareAssetImage(
                                    url:
                                        'assets/images/pili_12/icon_filter.png',
                                    width: 24.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Text(isListView ? '检视' : '资料')
                                ],
                              ),
                            )
                          ],
                        )),
                    GestureDetector(
                        onTap: () {
                          // 打开搜索
                          context.push('/search');
                        },
                        child: Container(
                          padding:
                              EdgeInsets.only(left: ScreenUtil().setWidth(6)),
                          child: PlatformAwareAssetImage(
                              url: 'assets/images/icon_search.png',
                              width: ScreenUtil().setWidth(20.5),
                              height: ScreenUtil().setWidth(20.5),
                              filterQuality: FilterQuality.medium),
                        ))
                  ],
                ),
              ),
            ))
      ],
    );
  }
}
