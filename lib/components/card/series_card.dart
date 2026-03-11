import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_string.dart';

class SeriesCard extends StatefulWidget {
  final Map data;
  final int type; //1视频  2 漫画
  final bool replace;
  final Function onTap;
  SeriesCard({Key key, this.data, this.type, this.replace = false, this.onTap})
      : super(key: key);

  @override
  _SeriesCardState createState() => _SeriesCardState();
}

class _SeriesCardState extends State<SeriesCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
              context.push(
            widget.replace
                ? (widget.type == 1
                    ? CommonUtils.getRealHash().replaceAll(
                        RegExp("${PPString.test}videoDetail/.*"),
                        'videoDetail/' + widget.data['id'].toString())
                    : CommonUtils.getRealHash().replaceAll(
                        RegExp("${PPString.test}comicsdetail/.*"),
                        'comicsdetail/' + widget.data['id'].toString()))
                : (CommonUtils.getRealHash(widget.type == 1
                    ? 'videoDetail/' + widget.data['id'].toString()
                    : 'comicsdetail/' + widget.data['id'].toString())),
            replace: widget.replace);
      },
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2.2.w),
              child: Container(
                width: widget.type == 1 ? 167.w : 80.w,
                height: widget.type == 1 ? 100.w : 110.w,
                child: PlatformAwareNetworkImage(
                  url: CommonUtils.getThumb(widget.data),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: 8.w,
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
                        widget.data['title'].toString(),
                        style: TextStyle(
                            color: Color(0XFF646464),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8.w,
                      ),
                      Text(
                        (widget.data['second_title'] ?? '') +
                            '/' +
                            (widget.data['tags'] ?? '').replaceAll(',', '#'),
                        style: TextStyle(
                          color: Color(0xff979797),
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (widget.data['count_play'] ?? 0).toString() + '人看过',
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
                              CommonUtils.renderFixedNumber(double.parse(
                                  (widget.data['favorites'] ?? 0).toString())),
                              style: TextStyle(
                                  color: DefaultStyle.themeColor,
                                  fontSize: 12.sp),
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
      ),
    );
  }
}
