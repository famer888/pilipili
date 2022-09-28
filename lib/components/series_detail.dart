import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/series_card.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/theme/default.dart';

class SeriesDetail extends StatefulWidget {
  SeriesDetail({Key key, this.id}) : super(key: key);
  final int id;

  @override
  _SeriesDetailState createState() => _SeriesDetailState();
}

class _SeriesDetailState extends State<SeriesDetail> {
  List data = [1, 2, 3, 4, 5];
  ScrollController _scrollController = ScrollController();
  dynamic fixedBanner;
  bool isListView = true;
  bool networkErr = false;
  int pageStatus = 2;
  bool isAll = false;
  int page = 1;
  int limit = 30;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '系列名称',
          ),
          Expanded(
            child: (networkErr || data == null)
                ? PageStatus.noNetWork(onTap: () {
                    networkErr = false;
                    setState(() {});
                    // getPageData();
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
                          // getPageData();
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
                                expandedHeight: 210.w,
                                flexibleSpace: FlexibleSpaceBar(
                                    collapseMode: CollapseMode.parallax,
                                    background: Stack(
                                      children: [
                                        Container(
                                          height: 210.w,
                                          color: Colors.red,
                                          width: double.infinity,
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 12.w,
                                          child: Image.asset(
                                            'assets/images/pili_12/icon_series.png',
                                            width: 113.w,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        )
                                      ],
                                    ))),
                            SliverToBoxAdapter(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color.fromRGBO(
                                              255, 128, 163, 0.5),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                          spreadRadius: 0)
                                    ]),
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  children: [
                                    Text(
                                      '童颜巨乳丽子，想要洗面奶吗，视频标题视频标题，标题两行',
                                      style: TextStyle(
                                        color: Color(0xff404040),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 8.w,
                                    ),
                                    Text(
                                      '简介：简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介',
                                      style: TextStyle(
                                        color: Color(0xff979797),
                                        fontSize: 11.sp,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 16.w),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return GestureDetector(
                                      onTap: () {},
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 8.w),
                                        child: SeriesCard(),
                                      ),
                                    );
                                  },
                                  childCount: data.length,
                                  addSemanticIndexes: false,
                                  addRepaintBoundaries: true,
                                  addAutomaticKeepAlives: true,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: MediaQuery.of(context).padding.bottom +
                                    ScreenUtil().bottomBarHeight,
                              ),
                            )
                          ],
                        ))),
          )
        ],
      ),
    );
  }
}
