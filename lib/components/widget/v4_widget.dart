import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class V4Column extends StatefulWidget {
  V4Column(
      {Key key,
      this.data,
      this.title,
      this.moreButton,
      this.morePageType,
      this.contentType,
      this.showField,
      this.changeButton,
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
  final bool changeButton;
  final int limit;
  final dynamic id;
  final dynamic element;
  @override
  _V4ColumnState createState() => _V4ColumnState();
}

class _V4ColumnState extends State<V4Column> {
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
              ScreenUtil().setWidth(widget.element['is_margin'] == 1 ? 20 : 5)),
      child: Column(
        children: [
          widget.title != null
              ? WidgetTitleBar(
                  morePageType: widget.morePageType,
                  title: widget.title,
                  contentType: widget.contentType,
                  hasMore: widget.moreButton,
                  moreOnTap: () {
                    context.push(
                        '/list/${widget.id}/${widget.title}/${widget.morePageType ?? 1}');
                  })
              : Container(),
          loading
              ? PageStatus.loading(mounted)
              : Wrap(
                  spacing: ScreenUtil().setWidth(7),
                  runSpacing: ScreenUtil().setWidth(16),
                  alignment: WrapAlignment.spaceBetween,
                  children: dataList
                      .asMap()
                      .keys
                      .map((e) => Vcard(
                            isSubtitle: true,
                            page: ((page * widget.element['max_num']) /
                                    AppGlobal.smallVideoLimit)
                                .ceil(),
                            tagIconType: dataList[e]['isfree'],
                            contentType: widget.contentType,
                            cardData: dataList[e],
                            showField: widget.showField,
                            width: ScreenUtil().setWidth(171),
                            thumbUrl: CommonUtils.getThumb(dataList[e]),
                          ))
                      .toList(),
                ),
          widget.changeButton
              ? InkWell(
                  onTap: changeElement,
                  child: Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setWidth(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              right: ScreenUtil().setWidth(8.5)),
                          child: PlatformAwareAssetImage(
                              url: 'assets/images/change-icon.png',
                              width: ScreenUtil().setWidth(20),
                              height: ScreenUtil().setWidth(20)),
                        ),
                        Text('换一下', style: DefaultStyle.gray13)
                      ],
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
