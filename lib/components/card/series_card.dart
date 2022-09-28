import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/utils/networkImage.dart';

class SeriesCard extends StatefulWidget {
  SeriesCard({Key key}) : super(key: key);

  @override
  _SeriesCardState createState() => _SeriesCardState();
}

class _SeriesCardState extends State<SeriesCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 80.w,
            height: 110.w,
            color: Colors.red,
            margin: EdgeInsets.only(right: 8.w),
          ),
          Expanded(
              child: Container(
            height: 110.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '第一集',
                      style: TextStyle(
                          color: Color(0XFF646464),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.w,
                    ),
                    Text(
                      '副标题/#标签#标签/信息',
                      style:
                          TextStyle(color: Color(0xff979797), fontSize: 11.sp),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '4512人看过',
                      style: TextStyle(
                        color: Color(0xff979797),
                        fontSize: 11.w,
                      ),
                    ),
                    Container(
                      width: 60.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xffffffff),
                                Color(0xfffff3f8),
                                Color(0xffffd3e6),
                              ]),
                          borderRadius: BorderRadius.circular(8.w),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xffffd3e6),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                spreadRadius: 0)
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PlatformAwareAssetImage(
                              url: 'assets/images/detail/icon_like.png',
                              width: 12.w,
                              fit: BoxFit.fitWidth,
                              filterQuality: FilterQuality.medium),
                          SizedBox(
                            width: 4.w,
                          ),
                          Text(
                            '1.2W',
                            style: TextStyle(
                                color: Color(0xffff84a9), fontSize: 12.sp),
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
