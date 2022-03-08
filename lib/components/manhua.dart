import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pilipili/components/common/scrollnav.dart';
import 'package:pilipili/components/lanmu.dart';
import 'package:pilipili/model/element.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

import '../utils/api.dart';

class Manhua extends StatefulWidget {
  Manhua({Key key, this.isShow = false}) : super(key: key);
  final bool isShow;
  @override
  _ManhuaState createState() => _ManhuaState();
}

class _ManhuaState extends State<Manhua> {
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
  void didUpdateWidget(Manhua oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && !initPage) {
      initPage = true;
      getPageData();
    }
  }

  void getPageData() async {
    ElementModel data = await getFisrtTopNavConfig();
    if (data == null) {
      // netWorkErr = true;
      setState(() {});
      return;
    }
    setState(() {
      navitems = data.value.asMap().keys.map((e) {
        return LinkModel.fromJson(data.value[e]);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return navitems == null
        ? Container()
        : Scrollnav(
            emitName: 'manhua',
            navitems: navitems,
            onNavIndexChanged: (index) {
              // setState(() {
              //   currentIndex = index;
              // });
            },
            pages: navitems
                .asMap()
                .keys
                .map((e) => PageViewMixin(
                    child: navitems[e].redirectType == 3
                        ? Lanmu(
                            isShow: currentIndex == e,
                            id: int.parse(navitems[e].linkUrl),
                            parentName: 'manhua',
                            tabList: [
                              {"name": '限免', 'type': 1},
                              {"name": '同人漫画', 'type': 2},
                              {"name": '完结长篇', 'type': 2},
                              {"name": '福利套图', 'type': 2},
                            ],
                            index: e)
                        : Container()))
                .toList(),
          );
  }
}
