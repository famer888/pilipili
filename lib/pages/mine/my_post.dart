import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/post_card.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:provider/provider.dart';

class MyPostPage extends StatefulWidget {
  const MyPostPage({Key? key}) : super(key: key);

  @override
  State<MyPostPage> createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int currentTab = 0;
  int limit = 24;
  List tabList = [
    {'name': '已发布', 'cate': 'pass', 'is_private': 0},
    {'name': '待审核', 'cate': 'wait', 'is_private': 0},
    {'name': '不通过', 'cate': 'unpass', 'is_private': 0},
    {'name': '私密帖子', 'cate': 'all', 'is_private': 1}
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo(context);

    /// 选项卡控制器
    _tabController = TabController(
      length: tabList.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.index.toDouble() == _tabController.animation!.value) {
        setState(() {
          currentTab = _tabController.index;
        });
      }
    });
  }

  headInfo() {
    int postMoney = Provider.of<HomeConfig>(context, listen: false).postMoney;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8.w),
        child: Stack(
          children: [
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                top: 41.w,
                child: Container(
                    decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Color(0xffFF80A3).withOpacity(0.15),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0)
                ]))),
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: getImage('assets/images/2023/my_post_bg.png',
                    height: 100.w, width: double.infinity, isAssets: true)),
            Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: getImage('assets/images/2023/my_post_bg_right.png',
                    height: double.infinity,
                    fit: BoxFit.fitHeight,
                    isAssets: true)),
            Container(
              height: 100.w,
              padding: EdgeInsets.only(left: 24.w, right: 16.w),
              margin: EdgeInsets.only(top: 41.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '可提現收益',
                        style: TextStyle(
                            color: Color(0xff979797),
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp),
                      ),
                      Text(postMoney.toString(),
                          style: TextStyle(
                              color: Color(0xffFE155B),
                              fontWeight: FontWeight.w700,
                              fontSize: 32.sp))
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push('/withdrawalsPage');
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 88.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.w),
                                gradient: DefaultStyle.defaluGrandientLine),
                            child: Text(
                              '立即提现',
                              style: TextStyle(
                                  color: Color(0XFFFFFFFF),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 18.w,
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push('/incomeDetail');
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 88.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.w),
                                gradient: DefaultStyle.defaluGrandientLine),
                            child: Text(
                              '收益明细',
                              style: TextStyle(
                                  color: Color(0XFFFFFFFF),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '我的帖子',
          ),
          Container(
            height: ScreenUtil().setWidth(44),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
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
              tabs: tabList
                  .asMap()
                  .keys
                  .map((e) => Container(
                        height: ScreenUtil().setWidth(44),
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: e == currentTab ? 1 : 0,
                              child: PlatformAwareAssetImage(
                                  url: "assets/images/icon_love_red2.png",
                                  width: ScreenUtil().setWidth(6),
                                  fit: BoxFit.fitWidth,
                                  filterQuality: FilterQuality.medium),
                            ),
                            Text(
                              tabList[e]['name'],
                              style: currentTab == e
                                  ? DefaultStyle.pink14bold
                                  : DefaultStyle.lgray14Bold,
                            ),
                            Opacity(
                              opacity: 0,
                              child: PlatformAwareAssetImage(
                                  url: "assets/images/icon_love_red2.png",
                                  width: ScreenUtil().setWidth(6),
                                  fit: BoxFit.fitWidth,
                                  filterQuality: FilterQuality.medium),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
                controller: _tabController,
                children: tabList.asMap().keys.map<Widget>((e) {
                  return PageViewMixin(
                    child: PublicBuildList(
                        head: tabList[e]['cate'] == 'pass'
                            ? headInfo()
                            : SizedBox(),
                        paddingLeft: 8.w,
                        paddingTop: 8.w,
                        paddingRight: 8.w,
                        api: '/api/community/list_my',
                        isShow: true,
                        data: {
                          'cate': tabList[e]['cate'],
                          'is_private': tabList[e]['is_private']
                        },
                        itemBuild:
                            (context, index, data, page, limit, getListData) {
                          return PostCard(
                            data: data,
                            showFollow: false,
                            showLike: false,
                            showEdit: true,
                          );
                        }),
                  );
                }).toList()),
          )
        ],
      ),
    );
  }
}
