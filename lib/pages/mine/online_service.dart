import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/privilege.dart';

import '../../global.dart';

class OnlineService extends StatefulWidget {
  OnlineService({Key key}) : super(key: key);

  @override
  _OnlineServiceState createState() => _OnlineServiceState();
}

class _OnlineServiceState extends State<OnlineService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleBar(
          title: '在线客服',
          paddingTop: ScreenUtil().statusBarHeight,
        ),
        Padding(
          padding: EdgeInsets.only(top: 13.5.h, left: DefaultStyle.pagePadding),
          child: Text(
            "常见问题",
            style: TextStyle(
                color: Color(0xff979797),
                fontSize: ScreenUtil().setSp(14),
                fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: DefaultStyle.pagePadding, vertical: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AppGlobal.helpList
                .asMap()
                .keys
                .map((e) => QuestionItem(data: AppGlobal.helpList[e], index: e))
                .toList(),
          ),
        )),
        Container(
          width: double.infinity,
          height: 72.sp + ScreenUtil().bottomBarHeight,
          padding: EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              //阴影
              BoxShadow(
                  color: Color.fromRGBO(255, 132, 169, 0.2),
                  offset: Offset(0, 0),
                  blurRadius: 10.w)
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   width: ScreenUtil().setWidth(150.5),
              //   height: ScreenUtil().setWidth(35),
              //   decoration: BoxDecoration(
              //       borderRadius:
              //           BorderRadius.circular(ScreenUtil().setWidth(17.5)),
              //       gradient: LinearGradient(
              //           colors: [Color(0xff37f4ff), Color(0xffff6a4a)],
              //           begin: Alignment.topLeft,
              //           end: Alignment.bottomRight)),
              //   child: Center(
              //     child: Text(
              //       '游戏客服通道',
              //       style: DefaultStyle.white12,
              //     ),
              //   ),
              // ),
              Container(
                width: 150.5.w,
                height: 35.w,
                decoration: BoxDecoration(
                  gradient: DefaultStyle.defaluGrandientLine,
                  borderRadius: BorderRadius.circular(50.w),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      primary: Colors.transparent),
                  child: Text(
                    '联系APP客服',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (Privilege.isAllowed(
                        context, RESOURCE_TYPE_SYSTEM, PRIVILEGE_TYPE_FEED)) {
                      context.push(CommonUtils.getRealHash('customerService'));
                    } else {
                      CommonUtils.showText('哥哥~开启1V1服务需要会员呢！您好像没有哦~');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

class QuestionItem extends StatelessWidget {
  const QuestionItem({Key key, this.data, this.index}) : super(key: key);
  final dynamic data;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 32.5.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((index + 1).toString() + "、 " + data['problem'].toString(),
              style: TextStyle(
                  color: Color(0xff404040),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp)),
          SizedBox(
            height: 15.w,
          ),
          Text(
            data['reply'],
            style: TextStyle(
                color: Color(0xff979797), fontSize: 14.sp, height: 1.7.w),
          ),
        ],
      ),
    );
  }
}
