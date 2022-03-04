import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';

class ThreeVColumn extends StatefulWidget {
  ThreeVColumn(
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
  _ThreeVColumnState createState() => _ThreeVColumnState();
}

class _ThreeVColumnState extends State<ThreeVColumn> {
  List<dynamic> dataList;
  int page = 1;
  bool loading = false;
  bool isAll = false;
  @override
  void initState() {
    dataList = widget.data;
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
      } else {
        CommonUtils.showText(res.msg);
      }
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
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
              ? WidgetTitleBar(title: widget.title)
              : Container(),
          Wrap(
            spacing: ScreenUtil().setWidth(8),
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
                      id: dataList[e]['id'],
                      contentType: widget.contentType,
                      cardData: dataList[e],
                      width: ScreenUtil().setWidth(109),
                      thumbUrl: CommonUtils.getThumb(dataList[e]),
                      tagIconType: dataList[e]['isfree'],
                      showField: widget.showField,
                    ))
                .toList(),
          ),
            GestureDetector(
                    child: Container(
                      width: ScreenUtil().setWidth(240),
                      height: ScreenUtil().setWidth(39),
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(16)),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(50)),
                          gradient: LinearGradient(colors: [
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
                          ),
                          Image.asset(
                            'assets/images/icon_more.png',
                            height: ScreenUtil().setWidth(8),
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
