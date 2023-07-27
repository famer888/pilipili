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

class Dongman extends StatefulWidget {
  Dongman({Key key, this.isShow = false}) : super(key: key);
  final bool isShow;
  @override
  _DongmanState createState() => _DongmanState();
}

class _DongmanState extends State<Dongman> {
  List<LinkModel> navitems;
  int currentIndex = 0;
  List pages = [];
  bool initPage = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isShow && !initPage) {
      initPage = true;
      getPageData();
    }
  }

  @override
  void didUpdateWidget(Dongman oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && !initPage) {
      initPage = true;
      getPageData();
    }
  }

  void getPageData() async {
    ElementModel data = await getFisrtTopNavConfig(3);
    if (data == null) {
      // netWorkErr = true;
      setState(() {});
      return;
    }
    navitems = data.value.asMap().keys.map((e) {
      return LinkModel.fromJson(data.value[e]);
    }).toList();
    pages = data.value.asMap().keys.map((e) {
      LinkModel _link = LinkModel.fromJson(data.value[e]);
      if (_link.redirectType == 3) {
        // 模块化栏目页
        return PageViewMixin(
          child: Lanmu(
              isShow: currentIndex == e,
              id: int.parse(navitems[e].linkUrl),
              parentName: 'dongman',
              index: e),
        );
      } else if (_link.redirectType == 6) {
        //筛选
        return PageViewMixin(
          child: FilterList(
              parentName: 'dongman',
              isShow: currentIndex == e,
              data: navitems[e].linkUrl,
              index: e),
        );
      } else {
        return ListPage(
          parentName: 'dongman',
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
    return navitems == null
        ? PageStatus.loading(true)
        : Scrollnav(
            emitName: 'dongman',
            navitems: navitems,
            onNavIndexChanged: (index) {
              EventBus().emit('lanmu-init-view', {
                'parentName': 'dongman',
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
