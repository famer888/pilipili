import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/utils/common.dart';

class VoneBig extends StatefulWidget {
  VoneBig({
    Key key,
    this.title,
    this.cardStyle,
    this.cardSpacing,
    this.id,
    this.data,
    this.contentType,
    this.moreButton,
    this.morePageType,
    this.showField,
    this.element,
  }) : super(key: key);
  final String title;
  final String cardStyle;
  final EdgeInsets cardSpacing;
  final dynamic id;
  final List<dynamic> data;
  final int contentType;
  final bool moreButton;
  final int morePageType;
  final String showField;
  final dynamic element;
  @override
  _VoneBigState createState() => _VoneBigState();
}

class _VoneBigState extends State<VoneBig> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List dataList = widget.data.getRange(1, widget.data.length).toList();
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
          Hcard(
            page: ((1) / AppGlobal.smallVideoLimit).ceil(),
            tagIconType: widget.data[0]['isfree'],
            width: ScreenUtil().setWidth(342),
            contentType: widget.contentType,
            thumbUrl: CommonUtils.getThumb(widget.data[0]),
            cardData: widget.data[0],
            showField: widget.showField,
          ),
          SizedBox(
            height: ScreenUtil().setWidth(16),
          ),
          Wrap(
            spacing: ScreenUtil().setWidth(8),
            runSpacing: ScreenUtil().setWidth(16),
            alignment: WrapAlignment.spaceBetween,
            children: dataList
                .asMap()
                .keys
                .map((e) => Hcard(
                      page: ((e + 2) / AppGlobal.smallVideoLimit).ceil(),
                      tagIconType: dataList[e]['isfree'],
                      contentType: widget.contentType,
                      cardData: dataList[e],
                      showField: widget.showField,
                      width: ScreenUtil().setWidth(167),
                      thumbUrl: CommonUtils.getThumb(dataList[e]),
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}
