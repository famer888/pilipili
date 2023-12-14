import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/FlexibleBanner.dart';
import 'package:pilipili/components/card/post_card.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key key, this.scrollDirection}) : super(key: key);
  final Function scrollDirection;
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List postList = [];

  ScrollController _scrollController;
  dynamic fixedBanner;
  bool isListView = true;
  bool networkErr = false;
  int pageStatus = 0;
  bool loading = true;
  bool isAll = false;
  int page = 1;
  int limit = 15;
  ValueNotifier<int> selectTab = ValueNotifier(1);
  String type = 'recommend';
  List topics = [];
  ValueNotifier<bool> showTab = ValueNotifier(false);
  List tabList = [
    {'title': '關注', 'id': 0, 'type': 'attention'},
    {'title': '推薦', 'id': 1, 'type': 'recommend'},
    {'title': '最新', 'id': 2, 'type': 'new'},
    {'title': '最熱', 'id': 3, 'type': 'trending'},
    {'title': '精華', 'id': 4, 'type': 'featured'},
    {'title': '視頻', 'id': 5, 'type': 'videos'},
  ];
  getPageData() {
    if (page == 1) {
      showTab.value = false;
      loading = true;
      setState(() {});
    }
    getPostList(page: page, limit: limit, tag: type).then((res) {
      if (res['status'] != 0) {
        var resData = res['data'] ?? [];
        if (res['status'] != 0) {
          pageStatus = 2;
          loading = false;
          isAll = resData.length == 0;
          if (page == 1) {
            postList = resData;
          } else {
            postList.addAll(resData);
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
    });
  }

  getTopics() {
    getHomeTopics().then((value) {
      if (value['status'] != 0) {
        topics = value['data']['list'] ?? [];
        setState(() {});
      }
    });
  }

  Widget _listView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return PostCard(data: postList[index]);
        },
        childCount: postList.length,
        addSemanticIndexes: false,
        addRepaintBoundaries: true,
        addAutomaticKeepAlives: true,
      ),
    );
  }

  scorllAdd() {
    double tH =
        ScreenUtil().statusBarHeight + DefaultStyle.navbarHegiht + 350.w;
    //当前页面的tab
    if (_scrollController.offset >= tH && !showTab.value) {
      showTab.value = true;
    } else if (_scrollController.offset < tH && showTab.value) {
      showTab.value = false;
    }
    widget.scrollDirection(_scrollController.position.userScrollDirection);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageStatus = 1;
    _scrollController = ScrollController();
    _scrollController.addListener(scorllAdd);
    getBanner();
    getTopics();
    getPageData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    showTab.dispose();
    selectTab.dispose();
    _scrollController.removeListener(scorllAdd);
    _scrollController.dispose();
  }

  Widget topBtn(String text, int postNum) {
    return Container(
      padding: EdgeInsets.only(top: 16.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.w),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Color(0xffFFF9FC), Color(0xffFFD3E6)]),
          border: Border.all(
            width: 2.w,
            color: Color(0xffFFEBD3),
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                color: Color(0xffFF6896),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700),
          ),
          Container(
            height: 25.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffFF80A3), Color(0xffFFD6A6)]),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.w),
                  bottom: Radius.circular(12.w),
                )),
            child: Text(
              '$postNum 個帖子',
              style: TextStyle(
                  color: Color(0xffffffff),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }

  Widget _postTab() {
    return ValueListenableBuilder(
        valueListenable: selectTab,
        builder: (context, value, child) {
          return Container(
            width: 343.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.w),
              boxShadow: [
                BoxShadow(
                    color: Color(0xffFF80A3).withOpacity(0.5),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0)
              ],
            ),
            height: 40.w,
            padding: EdgeInsets.only(left: 8.w, right: 8.w),
            child: Row(
                children: tabList.map((e) {
              return Expanded(
                flex: 1,
                child: Center(
                  child: GestureDetector(
                      onTap: () {
                        selectTab.value = e['id'];
                        page = 1;
                        isAll = false;
                        type = e['type'];
                        getPageData();
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Text(
                            e['title'],
                            style: TextStyle(
                                color: value == e['id']
                                    ? Color(0xffFF5B8C)
                                    : Color(0xffC2C2C2),
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp),
                          ),
                          Positioned(
                              left: 0,
                              right: 0,
                              top:-4.w,
                              child: Center(
                                child: Opacity(
                                  opacity: value == e['id'] ? 1 : 0,
                                  child: PlatformAwareAssetImage(
                                    url: 'assets/images/icon_love_red.png',
                                    width: 6.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              )),
                        ],
                      )),
                ),
              );
            }).toList()),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PullRefreshList(
            color: Color.fromRGBO(130, 26, 70, 0.44),
            offset: DefaultStyle.navbarHegiht + ScreenUtil().statusBarHeight,
            onLoading: () {
              if (isAll) return;
              page++;
              getPageData();
            },
            onRefresh: () {
              page = 1;
              isAll = false;
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
                        160.w +
                        24.w,
                    bottom: PreferredSize(
                      preferredSize:
                          Size(double.infinity, ScreenUtil().setWidth(24)),
                      child: Container(
                          height: 16.w,
                          decoration: BoxDecoration(
                              color: Color(0xffFFF4F9),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.w),
                                topRight: Radius.circular(30.w),
                              ))),
                    ),
                    flexibleSpace: HomeTopBanner(fixedBanner: fixedBanner)),
                SliverToBoxAdapter(
                  child: topics.isEmpty
                      ? Container()
                      : SizedBox(
                          height: 150.w,
                          child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              // shrinkWrap: true,
                              // physics: NeverScrollableScrollPhysics(),
                              itemCount: topics.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8.w,
                                mainAxisSpacing: 8.w,
                                childAspectRatio: 71 / 109,
                              ),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    context.push(
                                        '/topicDetail/${topics[index]['id']}',
                                        isNoRepeat: true);
                                  },
                                  child: topBtn(topics[index]['name'],
                                      topics[index]['post_num']),
                                );
                              }),
                        ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(top: 16.w),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: _postTab(),
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      EdgeInsets.symmetric(vertical: 17.w, horizontal: 8.w),
                  sliver: loading
                      ? SliverToBoxAdapter(
                          child: PageStatus.loading(mounted),
                        )
                      : (postList.isEmpty
                          ? SliverToBoxAdapter(
                              child: PageStatus.noData(),
                            )
                          : _listView()),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom +
                        ScreenUtil().bottomBarHeight,
                  ),
                )
              ],
            )),
        Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
              color: Color.fromRGBO(130, 56, 78, 0.44),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        Positioned(
                            top: 0,
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Container(
                              height: double.infinity,
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(13)),
                              decoration: BoxDecoration(
                                  gradient: RadialGradient(colors: [
                                Color.fromRGBO(255, 0, 107, 0.33),
                                Color.fromRGBO(255, 0, 122, 0.0)
                              ], radius: 0.8, center: Alignment.bottomCenter)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  PlatformAwareAssetImage(
                                      url: 'assets/images/icon_love.png',
                                      width: ScreenUtil().setWidth(6.5),
                                      filterQuality: FilterQuality.high),
                                  Container(
                                    color: Color(0xffFFDCE9),
                                    height: ScreenUtil().setWidth(1),
                                    width: ScreenUtil().setWidth(37),
                                  ),
                                ],
                              ),
                            )),
                        Container(
                          height: DefaultStyle.navbarHegiht,
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(13)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(3)),
                                child: Text(
                                  "社區",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
            )),
        Positioned(
            top:
                ScreenUtil().statusBarHeight + DefaultStyle.navbarHegiht + 16.w,
            left: 16.w,
            right: 16.w,
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: showTab,
                builder: (context, value, child) {
                  return IgnorePointer(
                    ignoring: !value,
                    child: AnimatedOpacity(
                      opacity: value ? 1 : 0,
                      duration: Duration(milliseconds: 200),
                      child: child,
                    ),
                  );
                },
                child: _postTab(),
              ),
            ))
      ],
    );
  }
}

class IndexPageHeaderDelegate extends SliverPersistentHeaderDelegate {
  IndexPageHeaderDelegate(this.child,
      {this.minHeight = 50, this.maxHeight = 50});

  Widget child;
  final double minHeight;
  final double maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
