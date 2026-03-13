import 'package:flutter/material.dart';
import 'package:pilipili/components/filter_list.dart';
import 'package:pilipili/components/lanmu.dart';
import 'package:pilipili/components/list_page.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/element.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

import '../../components/common/scrollnav.dart';

class NovelPage extends StatefulWidget {
  const NovelPage({Key? key}) : super(key: key);

  @override
  State<NovelPage> createState() => _NovelPageState();
}

class _NovelPageState extends State<NovelPage> {
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
    ElementModel? data = await getFisrtTopNavConfig(289);
    loading = false;
    data?.value!.asMap().forEach((index, data) {
      LinkModel item = LinkModel.fromJson(data);
      navitems.add(item);
      if (item.redirectType == 3) {
        // 模块化栏目页
        pages.add(PageViewMixin(
          child: Lanmu(
              isShow: currentIndex == index,
              id: int.parse(item.linkUrl!),
              parentName: 'novel',
              index: index),
        ));
      } else if (item.redirectType == 6) {
        //筛选
        pages.add(PageViewMixin(
          child: FilterList(
              parentName: 'novel',
              isShow: currentIndex == index,
              data: item.linkUrl,
              index: index),
        ));
      } else {
        pages.add(ListPage(
          parentName: 'novel',
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
    return Scaffold(
      body: navitems.isEmpty || loading
          ? PageStatus.loading(true)
          : Scrollnav(
              emitName: 'pili_novel',
              isBack:true,
              navitems: navitems,
              onNavIndexChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
                EventBus().emit('lanmu-init-view', {
                  'parentName': 'novel',
                  'currentIndex': index,
                });
              },
              pages: pages,
            ),
    );
  }
}
