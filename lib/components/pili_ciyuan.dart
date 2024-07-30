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
  PiliCiyuan({Key key}) : super(key: key);
  @override
  _PiliCiyuanState createState() => _PiliCiyuanState();
}

class _PiliCiyuanState extends State<PiliCiyuan> {
  List<LinkModel> navitems = [];
  int currentIndex = 0;
  List<Widget> pages = [];
  bool initPage = false;
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPage = true;
    getPageData();
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

    data.value.asMap().forEach((index, data) {
      LinkModel item = LinkModel.fromJson(data);
      navitems.add(item);
      if (item.redirectType == 3) {
        // 模块化栏目页
        pages.add(PageViewMixin(
          child: Lanmu(
              isShow: currentIndex == index,
              id: int.parse(item.linkUrl),
              parentName: 'ciyuan',
              index: index),
        ));
      } else if (item.redirectType == 6) {
        //筛选
        pages.add(PageViewMixin(
          child: FilterList(
              parentName: 'ciyuan',
              isShow: currentIndex == index,
              data: item.linkUrl,
              index: index),
        ));
      } else {
        pages.add(ListPage(
          parentName: 'ciyuan',
          isShow: currentIndex == index,
          title: item.name,
          id: item.linkUrl,
          index: index,
        ));
      }
    });
    AppGlobal.navList = navitems;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return navitems.isEmpty || loading
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
