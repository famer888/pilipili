import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/scrollnav.dart';
import 'package:pilipili/components/filter_list.dart';
import 'package:pilipili/components/lanmu.dart';
import 'package:pilipili/components/list_page.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/element.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:provider/provider.dart';

class AnwangPage extends StatefulWidget {
  const AnwangPage({Key key}) : super(key: key);
  @override
  State<AnwangPage> createState() => _AnwangPageState();
}

class _AnwangPageState extends State<AnwangPage> {
  List<LinkModel> navitems = [];
  int currentIndex = 0;
  List<Widget> pages = [];
  bool initPage = false;
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPage = true;
    getPageData();
  }

  void getPageData() async {
    ElementModel data = await getFisrtTopNavConfig(213);
    loading = false;
    data.value.asMap().forEach((index, data) {
      LinkModel item = LinkModel.fromJson(data);
      navitems.add(item);
      if (item.redirectType == 3) {
        // 模块化栏目页
        pages.add(PageViewMixin(
          child: Lanmu(
              isShow: currentIndex == index,
              id: int.parse(item.linkUrl),
              parentName: 'anwang',
              index: index),
        ));
      } else if (item.redirectType == 6) {
        //筛选
        pages.add(PageViewMixin(
          child: FilterList(
              parentName: 'anwang',
              isShow: currentIndex == index,
              isDark: 1,
              data: item.linkUrl,
              index: index),
        ));
      } else {
        pages.add(ListPage(
          parentName: 'anwang',
          isDark: 1,
          isShow: currentIndex == index,
          title: item.name,
          id: item.linkUrl,
          index: index,
        ));
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool darkPrivilege =
        Provider.of<HomeConfig>(context, listen: false).darkPrivilege;
    String darkPrivilegeText =
        Provider.of<HomeConfig>(context, listen: false).darkprivilegeTips;
    return Stack(
      children: [
        navitems.isEmpty || loading
            ? PageStatus.loading(true)
            : Scrollnav(
                emitName: 'pili_anwang',
                navitems: navitems,
                onNavIndexChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                  EventBus().emit('lanmu-init-view', {
                    'parentName': 'anwang',
                    'currentIndex': index,
                  });
                },
                pages: pages,
              ),
        darkPrivilege
            ? SizedBox()
            : Positioned.fill(
                child: ClipRect(
                    child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Container(
                    color: Color(0xff6E1D35),
                  ),
                ),
              ))),
        darkPrivilege
            ? SizedBox()
            : Positioned.fill(
                child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25.5.w),
                child: DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          darkPrivilegeText,
                          textAlign: TextAlign.center,
                        ),
                        // SizedBox(
                        //   height: 10.w,
                        // ),
                        // Text('警告：唔承受能力誤入，僅對少量用戶開放'),
                        // Text(
                        //   '禁止傳播與分享',
                        //   style: TextStyle(color: Color(0xffFF5B8C)),
                        // ),
                        SizedBox(
                          height: 10.w,
                        ),
                        Stack(
                          children: [
                            Positioned.fill(
                                child: PlatformAwareAssetImage(
                                    url: 'assets/images/dazhebaobg.png',
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.medium)),
                            Container(
                              width: 311.w,
                              height: 64.w,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '點擊開通',
                                        style: TextStyle(
                                            color: Color(0xffFE155B),
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text('開啟無限觀影',
                                          style: TextStyle(
                                              color: Color(0xffffffff),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 31.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.push('/vip');
                                    },
                                    child: Container(
                                      width: 96.w,
                                      height: 34.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50.w),
                                          gradient:
                                              DefaultStyle.defaluGrandientLine),
                                      child: Text('立即解锁',
                                          style: TextStyle(
                                              color: Color(0xffffffff),
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    )),
              ))
      ],
    );
  }
}
