import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';

class VscrollWidget extends StatefulWidget {
  VscrollWidget(
      {Key key,
      this.data,
      this.title,
      this.moreButton,
      this.morePageType,
      this.contentType,
      this.showField,
      this.id,
      this.element})
      : super(
          key: key,
        );
  final List<dynamic> data;
  final String title;
  final bool moreButton;
  final int morePageType;
  final String showField;
  final int contentType;
  final dynamic id;
  final dynamic element;
  @override
  _VscrollWidgetState createState() => _VscrollWidgetState();
}

class _VscrollWidgetState extends State<VscrollWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          bottom:
              ScreenUtil().setWidth(widget.element['is_margin'] == 1 ? 20 : 5)),
      child: Column(
        children: [
          widget.title != null
              ? WidgetTitleBar(
                  title: widget.title,
                )
              : Container(),
          Container(
            height: ScreenUtil().setWidth(250),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: DefaultStyle.pagePadding),
              child: Row(
                children: widget.data
                    .asMap()
                    .keys
                    .map((e) => Vcard(
                          tagIconType: widget.data[e]['isfree'],
                          width: ScreenUtil().setWidth(145),
                          id: widget.data[e]['id'],
                          contentType: widget.contentType,
                          cardData: widget.data[e],
                          page: ((e + 1) / AppGlobal.smallVideoLimit).ceil(),
                          cardMargin:
                              EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                          thumbUrl: CommonUtils.getThumb(widget.data[e]),
                          showField: widget.showField,
                        ))
                    .toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
