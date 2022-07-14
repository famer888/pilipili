import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/routers.dart';
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
  Widget _questionItem(data, int index) {
    return Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(32.5)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((index + 1).toString()+"、 "+data['problem'].toString(),
              style: TextStyle(
                  color: Color(0xff404040),
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(16))),
          SizedBox(
            height: ScreenUtil().setWidth(15),
          ),
          Text(
            data['reply'],
            style: TextStyle(
                color: Color(0xff979797),
                fontSize: ScreenUtil().setSp(14),
                height: 1.7),
          ),
        ],
      ),
    );
  }

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
        Container(
          padding: EdgeInsets.only(
              // bottom: ScreenUtil().setHeight(13.5),
              top: ScreenUtil().setHeight(13.5),
              left: DefaultStyle.pagePadding),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AppGlobal.helpList
                .asMap()
                .keys
                .map((e) => _questionItem(AppGlobal.helpList[e], e))
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
                  blurRadius: ScreenUtil().setWidth(10))
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
              GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (Privilege.isAllowed(
                        context, RESOURCE_TYPE_SYSTEM, PRIVILEGE_TYPE_FEED)) {
                      context.push(CommonUtils.getRealHash('customerService'));
                    } else {
                      CommonUtils.showText('哥哥~开启1V1服务需要会员呢！您好像没有哦~');
                    }
                  },
                  child: Stack(
                    children: [
                      // Positioned(
                      //     top: 0,
                      //     bottom: 0,
                      //     left: 0,
                      //     right: 0,
                      //     child: PlatformAwareAssetImage(
                      // url:
                      //       'assets/pengke/video/video_duan_btn.png',
                      //       fit: BoxFit.fill,
                      //     )),
                      Container(
                        width: ScreenUtil().setWidth(150.5),
                        height: ScreenUtil().setWidth(35),
                        decoration: BoxDecoration(
                          gradient: DefaultStyle.defaluGrandientLine,
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(50)),
                        ),
                        child: Center(
                          child: Text(
                            '联系APP客服',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ],
    ));
  }
}
