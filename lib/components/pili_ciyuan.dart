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
import 'package:youyutv/components/common/scrollnav.dart';
import 'package:youyutv/components/lanmu.dart';
import 'package:youyutv/model/element.dart';
import 'package:youyutv/utils/pageviewmixin.dart';

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
    return Scrollnav(
      emitName: 'pili_ciyuan',
      navitems: navitems,
      onNavIndexChanged: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      pages: navitems
          .asMap()
          .keys
          .map((e) => PageViewMixin(
              child: navitems[e].redirectType == 3
                  ? Lanmu(
                      isShow: currentIndex == e,
                      id: int.parse(navitems[e].linkUrl),
                      parentName: 'jingxuan',
                      index: e)
                  : Container()))
          .toList(),
    );
  }
}
