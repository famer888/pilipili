import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/post_card.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class OthersPostPage extends StatefulWidget {
  const OthersPostPage({Key key, this.aff}) : super(key: key);
  final int aff;
  @override
  State<OthersPostPage> createState() => _OthersPostPageState();
}

class _OthersPostPageState extends State<OthersPostPage> {
  bool isFollow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '作者資訊',
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 16.w),
            decoration: BoxDecoration(
                color: Color(0xffffffff),
                border: Border(
                    bottom:
                        BorderSide(color: Color(0xffECECEC), width: 0.5.w))),
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
                              '關注 333K',
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
                GestureDetector(
                  onTap: () {
                    isFollow = !isFollow;
                    setState(() {});
                  },
                  child: CommonUtils.shadowBtn(
                      'assets/images/2023/${isFollow ? "icon_love" : "icon_post_like"}.png',
                      text: isFollow ? '已點讚' : '點讚',
                      size: 10.w,
                      isActive: isFollow),
                ),
                GestureDetector(
                  onTap: () {
                    isFollow = !isFollow;
                    setState(() {});
                  },
                  child: CommonUtils.shadowBtn(
                      'assets/images/2023/icon_post_share.png',
                      text: '分享',
                      isActive: false),
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return PostCard();
                  }))
        ],
      ),
    );
  }
}
