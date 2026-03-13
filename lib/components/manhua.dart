import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pilipili/components/common/scrollnav.dart';
import 'package:pilipili/components/filter_list.dart';
import 'package:pilipili/components/lanmu.dart';
import 'package:pilipili/components/list_page.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/element.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

import '../utils/api.dart';

class Manhua extends StatefulWidget {
  Manhua({Key? key, this.pos}) : super(key: key);
  final int? pos;
  @override
  _ManhuaState createState() => _ManhuaState();
}

class _ManhuaState extends State<Manhua> {
  List<LinkModel> navitems = [];
  int currentIndex = 0;
  List<Widget> pages = [];
  bool initPage = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPage = true;
    getPageData();
  }

  void getPageData() async {
    ElementModel? data = await getFisrtTopNavConfig(4);
    data?.value!.asMap().forEach((index, data) {
      LinkModel item = LinkModel.fromJson(data);
      navitems.add(item);
      if (item.redirectType == 3) {
        // 模块化栏目页
        pages.add(PageViewMixin(
          child: Lanmu(
              pos: widget.pos,
              isShow: currentIndex == index,
              id: int.parse(item.linkUrl!),
              parentName: 'manhua',
              index: index),
        ));
      } else if (item.redirectType == 6) {
        //筛选
        pages.add(PageViewMixin(
          child: FilterList(
              pos: widget.pos, parentName: 'manhua', isShow: currentIndex == index, data: item.linkUrl, index: index),
        ));
      } else {
        pages.add(ListPage(
          pos: widget.pos,
          parentName: 'manhua',
          isShow: currentIndex == index,
          title: item.name,
          id: item.linkUrl,
          index: index,
        ));
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return navitems.isEmpty
        ? PageStatus.loading(true)
        : Scrollnav(
            emitName: 'manhua',
            navitems: navitems,
            onNavIndexChanged: (index) {
              EventBus().emit('lanmu-init-view', {
                'parentName': 'manhua',
                'currentIndex': index,
              });
              setState(() {
                currentIndex = index;
              });
            },
            pages: pages,
          );
  }
}
