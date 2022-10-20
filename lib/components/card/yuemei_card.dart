import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class YuemeiCard extends StatefulWidget {
  YuemeiCard({Key key, this.isShowInfo = true, this.w, this.h, this.data})
      : super(key: key);
  final bool isShowInfo;
  final double w;
  final double h;
  final Map data;
  @override
  _YuemeiCardState createState() => _YuemeiCardState();
}

class _YuemeiCardState extends State<YuemeiCard> {
  Widget yuepaoCard({double h, double w}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
            right: -4.w,
            top: 0,
            child: Image.asset(
              'assets/images/pili_12/yuemei_red.png',
              width: 65.w,
              fit: BoxFit.fitWidth,
            )),
        Container(
          height: h ?? 140.w,
          width: w ?? 118.w,
          decoration: BoxDecoration(
            color: Color(0xffffebd3),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(255, 128, 163, 0.5),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0)
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(78.w),
                bottomRight: Radius.circular(10.w),
                bottomLeft: Radius.circular(38.w)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsets.all(1.8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.w),
                  topRight: Radius.circular(78.w),
                  bottomRight: Radius.circular(10.w),
                  bottomLeft: Radius.circular(38.w)),
              child: PlatformAwareNetworkImage(
                url: widget.data['cover'],
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(CommonUtils.getRealHash(
            'yuemeiDetail/' + widget.data['id'].toString()));
      },
      child: !widget.isShowInfo
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                yuepaoCard(h: widget.h ?? 145.w, w: widget.w ?? 118.w),
                Positioned(
                    bottom: 0,
                    right: -4.w,
                    child: widget.data['buy_count'] != null &&
                            widget.data['buy_count'] > 10
                        ? Image.asset(
                            'assets/images/pili_12/yuemei_jingpin.png',
                            width: 54.w,
                            fit: BoxFit.fitWidth,
                          )
                        : Container())
              ],
            )
          : Padding(
              padding: EdgeInsets.only(bottom: 10.w),
              child: Row(
                children: [
                  yuepaoCard(h: widget.h ?? 145.w, w: widget.w ?? 118.w),
                  Expanded(
                      child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.only(top: 20.w, left: 1.w, right: 4.w),
                        decoration: BoxDecoration(
                          color: Color(0xffffebd3),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(255, 128, 163, 0.5),
                                offset: Offset(0, 2),
                                blurRadius: 3,
                                spreadRadius: 0)
                          ],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.w),
                            bottomRight: Radius.circular(10.w),
                          ),
                        ),
                        height: 112.w,
                        width: double.infinity,
                        padding:
                            EdgeInsets.only(right: 2.w, top: 2.w, bottom: 2.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.w),
                              bottomRight: Radius.circular(10.w),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.data['title'].toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Color(0xff6d6d6d),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 4.w),
                                child: Text(
                                  (widget.data['girl_age'] ?? '- -')
                                          .toString() +
                                      '岁/' +
                                      (widget.data['girl_height'] ?? '- -')
                                          .toString() +
                                      'cm/' +
                                      (widget.data['girl_cup'] ?? '- -')
                                          .toString() +
                                      '杯',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xffff5b8c),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              Text(widget.data['girl_tags'].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xff979797),
                                    fontSize: 11.sp,
                                  )),
                              Expanded(child: Container()),
                              DefaultTextStyle(
                                  style: TextStyle(
                                      color: Color(0xff979797),
                                      fontSize: 11.sp),
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/pili_12/icon_location_red.png',
                                            width: 18.w,
                                            fit: BoxFit.fitWidth,
                                          ),
                                          Text((widget.data['cityName'] ?? '未知')
                                              .toString())
                                        ],
                                      ),
                                      SizedBox(width: 32.w),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/pili_12/icon_lock.png',
                                            width: 18.w,
                                            fit: BoxFit.fitWidth,
                                          ),
                                          Text((widget.data['buy_count'] ?? 0)
                                              .toString())
                                        ],
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: -4.w,
                          child: widget.data['buy_count'] != null &&
                                  widget.data['buy_count'] > 10
                              ? Image.asset(
                                  'assets/images/pili_12/yuemei_jingpin.png',
                                  width: 54.w,
                                  fit: BoxFit.fitWidth,
                                )
                              : Container())
                    ],
                  ))
                ],
              ),
            ),
    );
  }
}
