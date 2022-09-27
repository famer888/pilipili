import 'dart:ui';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/cityPickers.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/mixin/cardMixin.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';

class YuemeiPage extends StatefulWidget {
  final bool isShow;
  YuemeiPage({Key key, this.isShow}) : super(key: key);

  @override
  _YuemeiPageState createState() => _YuemeiPageState();
}

class _YuemeiPageState extends State<YuemeiPage> with CardMixin {
  List data = [1, 2, 3, 4, 5];
  ScrollController _scrollController = ScrollController();
  dynamic fixedBanner;
  bool isListView = true;
  bool networkErr = false;
  int pageStatus = 2;
  bool isAll = false;
  String cityName = '全国';
  int page = 1;
  int limit = 30;
  getPageData() {}
  void getBanner() async {
    getElementById(id: 137, page: 1, limit: AppGlobal.smallVideoLimit)
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

  Widget yuepaoCard({double h, double w}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
            right: -4.w,
            top: 0,
            child: Image.asset(
              'assets/images/pili_12/yuemei_red.png',
              width: 65.w,
              fit: BoxFit.fitWidth,
            )),
        Container(
          height: h ?? 140.w,
          width: w ?? 118.w,
          decoration: BoxDecoration(
            color: Color(0xffffebd3),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(255, 128, 163, 0.5),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0)
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(78.w),
                bottomRight: Radius.circular(10.w),
                bottomLeft: Radius.circular(38.w)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsets.all(1.8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.w),
                  topRight: Radius.circular(78.w),
                  bottomRight: Radius.circular(10.w),
                  bottomLeft: Radius.circular(38.w)),
              child: Image.network(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDgYIIBTmgiykVmVA6KjNFumB8WHcm9Mu_0Ftsi5GcSo-Xbz4af6H_dwmhmjjiNBRQXb4&usqp=CAU',
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _listView() {
    return isListView
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return GestureDetector(
                  onTap: () {
                    context.push(CommonUtils.getRealHash('yuemeiDetail/14'));
                  },
                  child: Padding(
                  padding: EdgeInsets.only(bottom: 10.w),
                  child: Row(
                    children: [
                      yuepaoCard(h: 145.w, w: 118.w),
                      Expanded(
                          child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                top: 20.w, left: 1.w, right: 4.w),
                            decoration: BoxDecoration(
                              color: Color(0xffffebd3),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(255, 128, 163, 0.5),
                                    offset: Offset(0, 2),
                                    blurRadius: 3,
                                    spreadRadius: 0)
                              ],
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.w),
                                bottomRight: Radius.circular(10.w),
                              ),
                            ),
                            height: 112.w,
                            width: double.infinity,
                            padding: EdgeInsets.only(
                                right: 2.w, top: 2.w, bottom: 2.w),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10.w),
                                  bottomRight: Radius.circular(10.w),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'C圈小萌妹',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Color(0xff6d6d6d),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 4.w),
                                    child: Text(
                                      '19岁/158cm/C杯',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xffff5b8c),
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                  Text(
                                      ',萌音，雷姆cos服，护士服，黑丝OL口萌音，雷姆cos服，护士服，黑丝OL口',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xff979797),
                                        fontSize: 11.sp,
                                      )),
                                  Expanded(child: Container()),
                                  DefaultTextStyle(
                                      style: TextStyle(
                                          color: Color(0xff979797),
                                          fontSize: 11.sp),
                                      child: Row(
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/pili_12/icon_location_red.png',
                                                width: 18.w,
                                                fit: BoxFit.fitWidth,
                                              ),
                                              Text('南京')
                                            ],
                                          ),
                                          SizedBox(width: 32.w),
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/pili_12/icon_lock.png',
                                                width: 18.w,
                                                fit: BoxFit.fitWidth,
                                              ),
                                              Text('2999')
                                            ],
                                          )
                                        ],
                                      ))
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              right: -4.w,
                              child: Image.asset(
                                'assets/images/pili_12/yuemei_jingpin.png',
                                width: 54.w,
                                fit: BoxFit.fitWidth,
                              ))
                        ],
                      ))
                    ],
                  ),
                ),
                );
              },
              childCount: data.length,
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
            children: data.asMap().keys.map((e) {
              return yuepaoCard();
            }).toList(),
          );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBanner();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        (networkErr || data == null)
            ? PageStatus.noNetWork(onTap: () {
                networkErr = false;
                setState(() {});
                getPageData();
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
                      getPageData();
                    },
                    // onRefresh: () async {
                    //   page = 1;
                    //   isAll = false;
                    //   networkErr = false;
                    //   page = 1;
                    //   getPageData();
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
                                              fontSize: 14.sp),
                                        ),
                                        Text(' 包赔付',
                                            style: TextStyle(
                                                color: Color(0xffff84a9),
                                                fontSize: 14.sp)),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                      left: 0,
                                      bottom: 0,
                                      child: Image.asset(
                                        'assets/images/pili_12/gfrz.png',
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
                        data.length == 0
                            ? SliverToBoxAdapter(
                                child: PageStatus.noData(text: '没有约妹资源哟～'),
                              )
                            : SliverPadding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 17.w,
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
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CityPicker()))
                                    .then((value) {
                                  if (value != null) {
                                    EventBus().emit(
                                        'loufeng_select_city', value.name);
                                    cityName = value.name;
                                    setState(() {});
                                  }
                                });
                              },
                              behavior: HitTestBehavior.translucent,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/pili_12/icon_location.png',
                                    width: 24.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Text('全国')
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            GestureDetector(
                              onTap: () {
                                isListView = !isListView;
                                setState(() {});
                              },
                              behavior: HitTestBehavior.translucent,
                              child: Row(
                                children: [
                                  Image.asset(
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
                          context.push('/${Routes.search}');
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
