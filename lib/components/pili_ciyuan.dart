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
import 'package:youyutv/model/element.dart';

class PiliCiyuan extends StatefulWidget {
  PiliCiyuan({Key key, this.isShow = false}) : super(key: key);
  final bool isShow;
  @override
  _PiliCiyuanState createState() => _PiliCiyuanState();
}

class _PiliCiyuanState extends State<PiliCiyuan> {
  List<LinkModel> navitems;
  int currentIndex = 0;
  List navs = [
    {
      "id": 0,
      "link_url": 'manhua',
      "name": '漫画',
    },
    {
      "id": 0,
      "link_url": 'manhua',
      "name": '漫画',
    },
    {
      "id": 0,
      "link_url": 'manhua',
      "name": '漫画',
    },
    {
      "id": 0,
      "link_url": 'manhua',
      "name": '漫画',
    },
    {
      "id": 0,
      "link_url": 'manhua',
      "name": '漫画',
    },
    {
      "id": 0,
      "link_url": 'manhua',
      "name": '漫画',
    },
    {
      "id": 0,
      "link_url": 'manhua',
      "name": '漫画',
    }
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    navitems = navs.asMap().keys.map((e) {
      return LinkModel.fromJson(navs[e]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scrollnav(
      emitName: 'video_nav',
      navitems: navitems,
      pages: navs.asMap().keys.map((e) => Container()).toList(),
    ));
  }
}
