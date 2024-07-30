import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class NovelElementCard extends StatelessWidget {
  const NovelElementCard({Key key, this.data}) : super(key: key);
  final Map data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/novelDetail/${data['related_id']}');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3.w),
              child: Stack(
                children: [
                  SizedBox(
                    width: 109.w,
                    height: 152.w,
                    child: PlatformAwareNetworkImage(
                      url: CommonUtils.getThumb(data),
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 16.w,
                        width: 32.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xffFF8B8B).withOpacity(0.8),
                                  Color(0xffFF7696).withOpacity(0.8),
                                  Color(0xffFF7299).withOpacity(0.8)
                                ]),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3.w))),
                        child: Text(
                          data['is_end'] == 1 ? '完结' : '连载',
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.sp),
                        ),
                      ))
                ],
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
                child: SizedBox(
              height: 152.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data['title'] ?? data['name'],
                    style: TextStyle(
                        color: Color(0XFF646464),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 4.w,
                  ),
                  Text(
                    data['description'] ?? data['desc'],
                    style: TextStyle(
                        color: Color(0XFF979797),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            CommonUtils.renderFixedNumber(data['view_count']),
                            style: TextStyle(
                                color: Color(0xff979797),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                      Text(
                        '${data['is_end'] == 1 ? '已完结' : '连载中'} / 最新${data['chapter_count']}章',
                        style: TextStyle(
                            color: Color(0xff979797),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
