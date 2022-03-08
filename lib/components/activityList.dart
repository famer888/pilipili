import 'dart:ffi';

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

class ActivityList extends StatefulWidget {
  ActivityList({Key key}) : super(key: key);
  @override
  State<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  List data = [
    {
      'date': "2022.02.14-2022.02.19",
      'url':
          "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg"
    },
    {
      'date': "2022.02.14-2022.02.19",
      'url':
          "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg"
    },
    {
      'date': "2022.02.14-2022.02.19",
      'url':
          "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg"
    },
    {
      'date': "2022.02.14-2022.02.19",
      'url':
          "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg"
    },
  ];
  Widget renderItem(Map _data) {
    return GestureDetector(
      onTap: () {
        context.push(CommonUtils.getRealHash('ActivityDetail/${1}'));
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(255, 91, 140, 0.2),
                  offset: Offset(0, 2),
                  blurRadius: 3,
                  spreadRadius: 0)
            ],
            borderRadius:
                BorderRadius.all(Radius.circular(ScreenUtil().setWidth(5)))),
        margin: EdgeInsets.only(bottom: DefaultStyle.pagePadding),
        child: Stack(
          children: [
            Column(
              children: [
                Image.network(
                  _data["url"],
                  width: double.infinity,
                  height: ScreenUtil().setWidth(127),
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(6),
                      horizontal: ScreenUtil().setWidth(6)),
                  child: Text(
                    _data['date'],
                    style: TextStyle(
                      color: Color(0xff979797),
                      fontSize: ScreenUtil().setSp(12),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/icon_ing.png",
                  width: ScreenUtil().setWidth(50),
                  fit: BoxFit.fitWidth,
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
            title: "精彩活动",
          ),
          Expanded(
              child: SingleChildScrollView(
            padding: EdgeInsets.all(DefaultStyle.pagePadding),
            child: Column(
              children: data.map((e) => renderItem(e)).toList(),
            ),
          ))
        ],
      ),
    );
  }
}
