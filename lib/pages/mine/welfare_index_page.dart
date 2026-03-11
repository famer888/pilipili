import 'package:flutter/material.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/pages/mine/app_center.dart';
import 'package:pilipili/pages/mine/app_welfare_center_page.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

class WalfareIndexPage extends StatefulWidget {
  final int index;
  const WalfareIndexPage({Key key, this.index}) : super(key: key);

  @override
  State<WalfareIndexPage> createState() => _WalfareIndexPageState();
}

class _WalfareIndexPageState extends State<WalfareIndexPage> with TickerProviderStateMixin {
  TabController tabController;
  List tabs = <String>['福利中心', '应用推荐'];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: widget.index ?? 0,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  TextStyle _selTextStyle = TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w500);
  TextStyle _norTextStyle =
      TextStyle(color: Colors.white.withOpacity(0.44), fontSize: 16.sp, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            cWidget: TabBar(
              isScrollable: true,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              controller: tabController,
              labelPadding: EdgeInsets.symmetric(horizontal: 18.w),
              labelStyle: _selTextStyle,
              unselectedLabelStyle: _norTextStyle,
              labelColor: _selTextStyle.color,
              unselectedLabelColor: _norTextStyle.color,
              indicator: BoxDecoration(),
              indicatorWeight: 0,
              enableFeedback: true,
              tabs: tabs.asMap().entries.map((entry) {
                final i = entry.key;
                final title = entry.value;
                return Tab(text: title);
              }).toList(),
            ),
          ),
          Expanded(
              child: TabBarView(controller: tabController, children: [
            PageViewMixin(
              child: AppWelfareCenterPage(),
            ),
            PageViewMixin(
              child: AppCenter(),
            ),
          ]))
        ],
      ),
    );
  }
}
