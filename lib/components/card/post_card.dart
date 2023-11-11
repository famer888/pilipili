import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class PostCard extends StatefulWidget {
  const PostCard({Key key}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isFollow = false;

  Widget bottomRow(String icon, int _num) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        getImage('assets/images/2023/icon_post_$icon.png',
            width: 16.w, height: 16.w, isAssets: true),
        SizedBox(
          width: 8.w,
        ),
        Text(
          _num.toString(),
          style: TextStyle(
              color: Color(0xffFF84A9),
              fontSize: 12.sp,
              fontWeight: FontWeight.w700),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        context.push('/communityDetail/1');
      },
      child: Container(
      margin: EdgeInsets.symmetric(vertical: 4.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0xffFF80A3).withOpacity(0.5),
              offset: Offset(0, 2.w),
              blurRadius: 4.w,
              spreadRadius: 0)
        ],
        borderRadius: BorderRadius.circular(11.w),
      ),
      child: Column(
        children: [
          Row(
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
              Container(
                margin: EdgeInsets.only(left: 8.w),
                width: 48.w,
                height: 30.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.w),
                    gradient: DefaultStyle.defaluGrandientLine),
                child: Text(
                  '编辑',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700),
                ),
              )
            ],
          ),
          SizedBox(
            height: 8.w,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  alignment: Alignment.center,
                  width: 40.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xffEE86FF), Color(0xff7548D4)]),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.w),
                        topRight: Radius.circular(5.w),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(15.w),
                      )),
                  child: Text(
                    '精華',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  )),
              SizedBox(
                width: 4.w,
              ),
              Expanded(
                  child: Text(
                '我是標題，但好像大家都打很多字？為什麼要打這麼多的字呢我是標題，但好像大家都打很多字？為什麼要打這麼多的字呢',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Color(0xff646464),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700),
              ))
            ],
          ),
          SizedBox(
            height: 8.w,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3.w),
                child: SizedBox(
                  width: 167.w,
                  height: 100.w,
                  child: PlatformAwareNetworkImage(
                    url: '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(3.w),
                child: SizedBox(
                  width: 167.w,
                  height: 100.w,
                  child: PlatformAwareNetworkImage(
                    url: '',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 16.w,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  bottomRow('comment', 122),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    height: 12.w,
                    width: 1.w,
                    decoration: BoxDecoration(
                        color: Color(0xffFF84A9).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5.w)),
                  ),
                  bottomRow('like', 332),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    height: 12.w,
                    width: 1.w,
                    decoration: BoxDecoration(
                        color: Color(0xffFF84A9).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5.w)),
                  ),
                  bottomRow('view', 122),
                ],
              ),
              SizedBox(
                width: 16.w,
              ),
              Text(
                '#破處回憶',
                style: TextStyle(
                    color: Color(0xffFE155B),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp),
              )
            ],
          )
        ],
      ),
    ),
    );
  }
}
