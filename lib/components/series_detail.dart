import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/series_card.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class SeriesDetail extends StatefulWidget {
  SeriesDetail({Key key, this.id, this.type}) : super(key: key);
  final int id;
  final int type; //type  11 视频  12 漫画
  @override
  _SeriesDetailState createState() => _SeriesDetailState();
}

class _SeriesDetailState extends State<SeriesDetail> {
  List data = [1, 2, 3, 4, 5];
  ScrollController _scrollController = ScrollController();
  dynamic fixedBanner;
  bool isListView = true;
  bool networkErr = false;
  int pageStatus = 0;
  bool isAll = false;
  int page = 1;
  int limit = 30;
  Map seriesInfo;
  getPageData() {
    getSeriesDetail(id: widget.id, page: page, limit: limit).then((res) {
      if (res['status'] != 0) {
        pageStatus = 2;
        isAll = res['data']['resource'].length == 0;
        if (page == 1) {
          seriesInfo = res['data'];
        } else {
          seriesInfo['resource'].addAll(res['data']['resource']);
        }
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPageData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: seriesInfo == null ? '' : seriesInfo['title'].toString(),
          ),
          Expanded(
            child: (networkErr)
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
                                expandedHeight: 210.w,
                                flexibleSpace: FlexibleSpaceBar(
                                    collapseMode: CollapseMode.parallax,
                                    background: Stack(
                                      children: [
                                        Container(
                                          height: 210.w,
                                          width: double.infinity,
                                          child: PlatformAwareNetworkImage(
                                            url: seriesInfo['thumb'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 12.w,
                                          child:  PlatformAwareAssetImage(
                                url:
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      seriesInfo['title'].toString(),
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
                                      '简介：' + seriesInfo['desc'].toString(),
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
                              sliver:seriesInfo['resource'].length==0?
                              SliverToBoxAdapter(
                                child: PageStatus.noData(text:'暂无数据'),
                              )
                              : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 8.w),
                                      child: SeriesCard(
                                        data: seriesInfo['resource'][index],
                                        type: seriesInfo['type'],
                                      ),
                                    );
                                  },
                                  childCount: seriesInfo['resource'].length,
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
