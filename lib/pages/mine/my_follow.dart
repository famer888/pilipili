import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class MyFollowPage extends StatefulWidget {
  const MyFollowPage({Key key}) : super(key: key);

  @override
  State<MyFollowPage> createState() => _MyFollowPageState();
}

class _MyFollowPageState extends State<MyFollowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '我的關注',
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return _FollowUserItem();
                  }))
        ],
      ),
    );
  }
}

class _FollowUserItem extends StatefulWidget {
  const _FollowUserItem({Key key});

  @override
  State<_FollowUserItem> createState() => __FollowUserItemState();
}

class __FollowUserItemState extends State<_FollowUserItem> {
  bool isFollow = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 16.w),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xffECECEC), width: 0.5.w))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.w),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  child: PlatformAwareNetworkImage(
                    url: '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color(0XFF646464),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 4.w,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        height: 18.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9.w),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xffFFD875),
                                  Color(0XFFFF6915),
                                ])),
                        child: Text(
                          '會員等級',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(
                        width: 4.w,
                      ),
                      Text(
                        '三小时前',
                        style: TextStyle(
                            color: Color(0xff979797),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  )
                ],
              ))
            ],
          )),
          GestureDetector(
            onTap: () {
              isFollow = !isFollow;
              setState(() {});
            },
            child: CommonUtils.shadowBtn(
                'assets/images/2023/icon_${isFollow ? "unfollow" : "follow"}.png',
                text: isFollow ? '已關注' : '關注',
                isActive: isFollow),
          ),
        ],
      ),
    );
  }
}
