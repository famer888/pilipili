import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:go_router/go_router.dart';

class HscrollWidget extends StatefulWidget {
  HscrollWidget(
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
  _HscrollWidgetState createState() => _HscrollWidgetState();
}

class _HscrollWidgetState extends State<HscrollWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _topC = (ScreenUtil().setWidth(240) / 167) * 100;
    return Container(
      margin: EdgeInsets.only(
          bottom:
              ScreenUtil().setWidth(widget.element['is_margin'] == 1 ? 24 : 5)),
      child: Column(
        children: [
          widget.title != null
              ? WidgetTitleBar(
                  title: widget.title,
                )
              : Container(),
          Container(
            height: ScreenUtil().setWidth(175),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: DefaultStyle.pagePadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: widget.data
                        .asMap()
                        .keys
                        .map((e) => Hcard(
                              tagIconType: widget.data[e]['isfree'],
                              width: ScreenUtil().setWidth(240),
                              id: widget.data[e]['id'],
                              contentType: widget.contentType,
                              cardData: widget.data[e],
                              page:
                                  ((e + 1) / AppGlobal.smallVideoLimit).ceil(),
                              cardMargin: EdgeInsets.only(
                                  right: ScreenUtil().setWidth(10)),
                              thumbUrl: CommonUtils.getThumb(widget.data[e]),
                              showField: widget.showField,
                            ))
                        .toList(),
                  ),
                  !widget.moreButton
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            context.push(
                                '/morePage/${widget.id}/${widget.title}/${widget.morePageType ?? 1}');
                          },
                          child: Container(
                            width: ScreenUtil().setWidth(70),
                            height: ScreenUtil().setWidth(39),
                            margin: EdgeInsets.only(
                                right: ScreenUtil().setWidth(16),
                                top: ((_topC - ScreenUtil().setWidth(39)) / 2)
                                    .roundToDouble()),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromRGBO(255, 128, 163, 0.5),
                                      offset: Offset(0, 2),
                                      blurRadius: 3,
                                      spreadRadius: 0)
                                ],
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil().setWidth(50)),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xffff8b8b),
                                      Color(0xffff7696),
                                      Color(0xffff7299),
                                    ])),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '更多',
                                  style: DefaultStyle.white14,
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(9),
                                ),
                                Image.asset(
                                  'assets/images/icon_more.png',
                                  height: ScreenUtil().setWidth(8),
                                  filterQuality: FilterQuality.medium
                                )
                              ],
                            ),
                          ),
                        )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
