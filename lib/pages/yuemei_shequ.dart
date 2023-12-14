import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/yuemei.dart';
import 'package:pilipili/pages/community_page.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:pilipili/utils/privilege.dart';
import 'package:provider/provider.dart';

class YuemeiShequ extends StatefulWidget {
  const YuemeiShequ({Key key}) : super(key: key);
  @override
  State<YuemeiShequ> createState() => _YuemeiShequState();
}

class _YuemeiShequState extends State<YuemeiShequ> {
  bool loading = true;
  bool init = false;
  ValueNotifier<int> currentPage = ValueNotifier(0);
  PageController pageController = PageController();
  ValueNotifier<bool> navShow = ValueNotifier(true);
  // @override
  // void didUpdateWidget(covariant YuemeiShequ oldWidget) {
  //   // TODO: implement didUpdateWidget
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.isShow && !init) {
  //     init = true;
  //     loading = false;
  //   }
  // }
  @override
  void initState() {
    super.initState();
    init = true;
    loading = false;
  }

  scrollDirection(ScrollDirection direction) {
    if (direction == ScrollDirection.forward && !navShow.value) {
      navShow.value = true;
    } else if (direction == ScrollDirection.reverse && navShow.value) {
      navShow.value = false;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    currentPage.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? PageStatus.loading(mounted)
        : Stack(
            children: [
              PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                children: [
                  CommunityPage(scrollDirection: scrollDirection),
                  YuemeiPage(scrollDirection: scrollDirection),
                ],
              ),
              Positioned(
                  bottom: DefaultStyle.bottomnavbarHegiht +
                      ScreenUtil().bottomBarHeight,
                  left: 8.w,
                  right: 8.w,
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                          valueListenable: currentPage,
                          builder: (context, value, child) {
                            return value != 0
                                ? Container()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          String noPermissionPublishPostTips =
                                              Provider.of<HomeConfig>(context,
                                                      listen: false)
                                                  .noPermissionPublishPostTips;
                                          int allowPublishPost =
                                              Provider.of<HomeConfig>(context,
                                                      listen: false)
                                                  .allowPublishPost;
                                          if (allowPublishPost != 0) {
                                            context.push('/communityPushlish');
                                          } else {
                                            bool isPublish =
                                                Privilege.isAllowed(
                                                    context,
                                                    RESOURCE_TYPE_POST,
                                                    PRIVILEGE_TYPE_POST);
                                            if (isPublish) {
                                              context
                                                  .push('/communityPushlish');
                                            } else {
                                              CommonUtils.showText(
                                                  noPermissionPublishPostTips);
                                            }
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 8.w),
                                          width: 52.w,
                                          height: 52.w,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(26.w),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Color(0xffFF80A3)
                                                        .withOpacity(0.5),
                                                    offset: Offset(0, 2),
                                                    blurRadius: 4,
                                                    spreadRadius: 0)
                                              ]),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '+',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                height: 1,
                                                color: Color(0xffFF84A9),
                                                fontSize: 40.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                          }),
                      ValueListenableBuilder(
                          valueListenable: navShow,
                          builder: (context, isShow, child) {
                            return IgnorePointer(
                              ignoring: !isShow,
                              child: Opacity(
                                  opacity: isShow ? 1 : 0, child: child),
                            );
                          },
                          child: ValueListenableBuilder(
                            valueListenable: currentPage,
                            builder: (context, value, child) {
                              return Container(
                                padding: EdgeInsets.all(8.w),
                                height: 52.w,
                                decoration: BoxDecoration(
                                    color: Color(0xffFF80A3).withOpacity(0.5),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.w),
                                      topRight: Radius.circular(10.w),
                                    )),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        pageController.jumpToPage(0);
                                        currentPage.value = 0;
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            gradient: value == 0
                                                ? DefaultStyle
                                                    .defaluGrandientLine
                                                : DefaultStyle
                                                    .whiteGrandientLine,
                                            borderRadius:
                                                BorderRadius.circular(50.w),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color(0xffFF80A3)
                                                      .withOpacity(value == 0
                                                          ? 0.5
                                                          : 0.3),
                                                  offset: Offset(0, 2),
                                                  blurRadius: 4,
                                                  spreadRadius: 0)
                                            ]),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '社区',
                                          style: TextStyle(
                                              color: value == 0
                                                  ? Colors.white
                                                  : Color(0xffFF84A9),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    )),
                                    SizedBox(
                                      width: 9.w,
                                    ),
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        pageController.jumpToPage(1);
                                        currentPage.value = 1;
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            gradient: value == 1
                                                ? DefaultStyle
                                                    .defaluGrandientLine
                                                : DefaultStyle
                                                    .whiteGrandientLine,
                                            borderRadius:
                                                BorderRadius.circular(50.w),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color(0xffFF80A3)
                                                      .withOpacity(value == 1
                                                          ? 0.5
                                                          : 0.3),
                                                  offset: Offset(0, 2),
                                                  blurRadius: 4,
                                                  spreadRadius: 0)
                                            ]),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '约妹',
                                          style: TextStyle(
                                              color: value == 1
                                                  ? Colors.white
                                                  : Color(0xffFF84A9),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              );
                            },
                          ))
                    ],
                  ))
            ],
          );
  }
}
