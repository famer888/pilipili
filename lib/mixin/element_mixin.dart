import 'package:flutter/material.dart';
import 'package:pilipili/components/widget/h_scroll_widget.dart';
import 'package:pilipili/components/widget/three_v_column.dart';
import 'package:pilipili/components/widget/v4_widget.dart';
import 'package:pilipili/components/widget/v_onebig.dart';
import 'package:pilipili/components/widget/v_scroll_widget.dart';
import 'package:pilipili/utils/common.dart';

mixin ElementMixin<T extends StatefulWidget> on State<T> {
  Widget getElement({dynamic element}) {
    List elementValue; //元素的列表
    if (element['value'].length <= element['max_num']) {
      elementValue = element['value'];
    } else {
      elementValue = element['value'].sublist(0, element['max_num'] - 1);
    }
    Widget yyElement;
    CommonUtils.debugPrint(
        '-----------------${element['title']}----------------组件类型:${element['type']}---是否有magin:${element['is_margin'] == 1}');
    switch (element['type']) {
      case 1:
        yyElement = V4Column(
          data: elementValue,
          contentType: element['content_type'],
          title: element['title'] == null || element['title'] == ''
              ? null
              : element['title'],
          id: element['id'],
          moreButton: element['more_button'] == 1,
          morePageType: element['more_page_show_type'],
          limit: element['max_num'],
          showField: element['show_field'],
          element: element,
        );
        break;
      case 2:
        yyElement = VscrollWidget(
          data: elementValue,
          contentType: element['content_type'],
          title: element['title'] == null || element['title'] == ''
              ? null
              : element['title'],
          id: element['id'],
          moreButton: element['more_button'] == 1,
          morePageType: element['more_page_show_type'],
          showField: element['show_field'],
          element: element,
        );
        break;
      case 3:
        yyElement = VoneBig(
          data: elementValue,
          contentType: element['content_type'],
          title: element['title'] == null || element['title'] == ''
              ? null
              : element['title'],
          id: element['id'],
          moreButton: element['more_button'] == 1,
          morePageType: element['more_page_show_type'],
          showField: element['show_field'],
          element: element,
        );
        break;
      case 4:
        yyElement = ThreeVColumn(
          data: elementValue,
          contentType: element['content_type'],
          title: element['title'] == null || element['title'] == ''
              ? null
              : element['title'],
          id: element['id'],
          moreButton: element['more_button'] == 1,
          morePageType: element['more_page_show_type'],
          showField: element['show_field'],
          element: element,
        );
        break;
      case 5:
        yyElement = HscrollWidget(
          data: elementValue,
          contentType: element['content_type'],
          title: element['title'] == null || element['title'] == ''
              ? null
              : element['title'],
          id: element['id'],
          moreButton: element['more_button'] == 1,
          morePageType: element['more_page_show_type'],
          showField: element['show_field'],
          element: element,
        );
        break;
      case 6: //固定第一行banner
        yyElement = Container();
        break;
      case 7: //固定第二行导航
        yyElement = Container();
        break;
      default:
        yyElement = Container();
      //  yyElement = Padding(
      //     padding: EdgeInsets.symmetric(
      //       vertical: ScreenUtil().setWidth(16),
      //       horizontal: DefaultStyle.pagePadding),
      //     child: Text(
      //       '当前模块不可见,或下载最新版本',
      //       style: DefaultStyle.red13,
      //     ),
      //   );
    }

    if (element['value'] == null || element['value'].length == 0) {
      return Container();
    } else {
      return yyElement;
    }
  }
}
