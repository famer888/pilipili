/*
 * @Author: Tom
 * @Date: 2021-12-21 11:51:44
 * @LastEditTime: 2021-12-27 15:15:12
 * @LastEditors: Tom
 * @Description: 
 * @FilePath: /flutter2021/lib/components/PiliCiyuan.dart
 */
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pilipili/components/common/scrollnav.dart';
import 'package:pilipili/components/filter_list.dart';
import 'package:pilipili/components/lanmu.dart';
import 'package:pilipili/components/list_page.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/model/element.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

import '../utils/api.dart';

class PiliCiyuan extends StatefulWidget {
  PiliCiyuan({Key key, this.isShow = false}) : super(key: key);
  final bool isShow;
  @override
  _PiliCiyuanState createState() => _PiliCiyuanState();
}

class _PiliCiyuanState extends State<PiliCiyuan> {
  List<LinkModel> navitems;
  int currentIndex = 0;
  List pages = [];
  bool initPage = false;
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isShow && !initPage) {
      initPage = true;
      getPageData();
    }
  }

  void getPageData() async {
    ElementModel data = await getFisrtTopNavConfig(2);
    loading = false;
    // data.value.insert(0, {
    //   'id': 123,
    //   'related_id': 0,
    //   'element_id': 123,
    //   'link_url': 'type:tansuo',
    //   'resource_url': '',
    //   'redirect_type': 2,
    //   'name': '探索',
    //   'desc': '',
    //   'sort': 999
    // });
    navitems = data.value.asMap().keys.map((e) {
      return LinkModel.fromJson(data.value[e]);
    }).toList();

    AppGlobal.navList = navitems;
    pages = data.value.asMap().keys.map((e) {
      LinkModel _link = LinkModel.fromJson(data.value[e]);
      if (_link.redirectType == 3) {
        // 模块化栏目页
        return PageViewMixin(
          child: Lanmu(
              isShow: currentIndex == e,
              id: int.parse(navitems[e].linkUrl),
              parentName: 'ciyuan',
              index: e),
        );
      } else if (_link.redirectType == 6) {
        //筛选
        return PageViewMixin(
          child: FilterList(
              parentName: 'ciyuan',
              isShow: currentIndex == e,
              data: navitems[e].linkUrl,
              index: e),
        );
      } else {
        return ListPage(
          parentName: 'ciyuan',
          isShow: currentIndex == e,
          title: navitems[e].name,
          id: navitems[e].linkUrl,
          index: e,
        );
      }
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return navitems == null || loading
        ? PageStatus.loading(true)
        : Scrollnav(
            emitName: 'pili_ciyuan',
            navitems: navitems,
            onNavIndexChanged: (index) {
              setState(() {
                currentIndex = index;
              });
              EventBus().emit('lanmu-init-view', {
                'parentName': 'ciyuan',
                'currentIndex': index,
              });
            },
            pages: pages,
          );
  }
}
