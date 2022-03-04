import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/theme/default.dart';

// ignore: must_be_immutable
class WidgetTitleBar extends StatefulWidget {
  WidgetTitleBar(
      {Key key,
      this.title,
      this.hasMore = false,
      this.moreOnTap,
      this.contentType,
      this.morePageType})
      : super(key: key);
  String title;
  bool hasMore;
  int contentType;
  Function moreOnTap;
  int morePageType;
  @override
  _WidgetTitleBarState createState() => _WidgetTitleBarState();
}

class _WidgetTitleBarState extends State<WidgetTitleBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: Row(
            children: [
              Expanded(
                  child: Text(
                widget.title,
                style: DefaultStyle.white18bold,
              )),
              widget.hasMore
                  ? GestureDetector(
                      onTap: () {
                        if (widget.morePageType > 2) {
                          context.push(
                              '/updateList/${widget.contentType}/${widget.morePageType}');
                        } else {
                          if (widget.moreOnTap != null) {
                            widget.moreOnTap();
                          }
                        }
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(8)),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(10)),
                              child: Text(
                                '更多',
                                style: DefaultStyle.gray12,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(6.5)),
                              child: Image.asset(
                                'assets/pengke/icon_more.png',
                                width: ScreenUtil().setWidth(12),
                                height: ScreenUtil().setWidth(12),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(3),
        ),
        Image.asset(
          'assets/pengke/img_xian.png',
          fit: BoxFit.fitWidth,
          width: double.infinity,
        ),
        SizedBox(
          height: ScreenUtil().setWidth(7),
        )
      ],
    );
  }
}
