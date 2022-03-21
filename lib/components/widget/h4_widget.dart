import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';

class H4Column extends StatefulWidget {
  H4Column(
      {Key key,
      this.data,
      this.title,
      this.moreButton,
      this.morePageType,
      this.contentType,
      this.showField,
      this.limit,
      this.id,
      this.element})
      : super(key: key);
  final List<dynamic> data;
  final String title;
  final bool moreButton;
  final int morePageType;
  final String showField;
  final int contentType;
  final int limit;
  final dynamic id;
  final dynamic element;
  @override
  _H4ColumnState createState() => _H4ColumnState();
}

class _H4ColumnState extends State<H4Column> {
  List<dynamic> dataList;
  int page = 1;
  bool isAll = false;
  bool loading = false;
  @override
  void initState() {
    dataList = widget.data;
    setState(() {});
    super.initState();
  }

  changeElement() {
    loading = true;
    setState(() {});
    if (dataList != null && isAll) {
      page = 1;
    } else {
      page++;
    }
    getElementById(id: widget.id, limit: widget.limit, page: page).then((res) {
      if (res['status'] != 0) {
        if (res['data']['value'].length == widget.limit) {
          dataList = res['data']['value'];
        }
        isAll = res['data']['value'].length < widget.limit;
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res.msg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          loading
              ? PageStatus.loading(mounted)
              : Wrap(
                  spacing: ScreenUtil().setWidth(7),
                  runSpacing: ScreenUtil().setWidth(10),
                  alignment: WrapAlignment.spaceBetween,
                  children: dataList
                      .asMap()
                      .keys
                      .map((e) => Hcard(
                            isSubtitle: true,
                            page: ((page * widget.element['max_num']) /
                                    AppGlobal.smallVideoLimit)
                                .ceil(),
                            tagIconType: dataList[e]['isfree'],
                            contentType: widget.contentType,
                            cardData: dataList[e],
                            showField: widget.showField,
                            width: ScreenUtil().setWidth(167),
                            thumbUrl: CommonUtils.getThumb(dataList[e]),
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
                    width: ScreenUtil().setWidth(240),
                    height: ScreenUtil().setWidth(39),
                    margin: EdgeInsets.only(top: ScreenUtil().setWidth(16)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(255, 128, 163, 0.5),
                              offset: Offset(0, 2),
                              blurRadius: 3,
                              spreadRadius: 0)
                        ],
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().setWidth(50)),
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
                          '查看更多',
                          style: DefaultStyle.white14,
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
