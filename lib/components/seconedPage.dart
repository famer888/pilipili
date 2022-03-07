import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:pilipili/theme/default.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/utils/common.dart';

class SeconedPage extends StatefulWidget {
  SeconedPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<SeconedPage> createState() => _SeconedPageState();
}

class _SeconedPageState extends State<SeconedPage> {
  List data = [
    {
      'name': "萨克胩是看不到卡上看到挥洒的撒刘德华拉萨喝多了哈撒了电话",
      'url':
          "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg"
    },
    {
      'name': "萨克胩是看不到卡上看到挥洒的撒刘德华拉萨喝多了哈撒了电话",
      'url':
          "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg"
    },
    {
      'name': "萨克胩是看不到卡上看到挥洒的撒刘德华拉萨喝多了哈撒了电话",
      'url':
          "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg"
    },
    {
      'name': "萨克胩是看不到卡上看到挥洒的撒刘德华拉萨喝多了哈撒了电话",
      'url':
          "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg"
    },
  ];
  Widget renderItem(String name, String url) {
    return GestureDetector(
      onTap: () {
        context.push(CommonUtils.getRealHash('seconedPageDetail/${name}'));
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(ScreenUtil().setWidth(5)))),
        margin: EdgeInsets.only(bottom: DefaultStyle.pagePadding),
        child: Stack(
          children: [
            Image.network(
              url,
              width: double.infinity,
              height: ScreenUtil().setWidth(140),
              fit: BoxFit.cover,
            ),
            Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(25)),
                  child: Text(
                    name,
                    style: DefaultStyle.white15,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: widget.title,
          ),
          Expanded(
              child: SingleChildScrollView(
            padding: EdgeInsets.all(DefaultStyle.pagePadding),
            child: Column(
              children:
                  data.map((e) => renderItem(e['name'], e['url'])).toList(),
            ),
          ))
        ],
      ),
    );
  }
}
