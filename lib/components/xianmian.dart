import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:pilipili/theme/default.dart';

class Xianmian extends StatefulWidget {
  Xianmian({Key key}) : super(key: key);

  @override
  State<Xianmian> createState() => _XianmianState();
}

class _XianmianState extends State<Xianmian> {
  Widget card() {
    var rng = new Random();
    double _height =
        rng.nextInt(4) * ScreenUtil().setWidth(30) + ScreenUtil().setWidth(70);
    return Container(
      width: double.infinity,
      height: _height,
      color: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '精彩限免 请你白嫖',
          ),
          Expanded(
              child: PullRefreshList(
            onLoading: () {},
            onRefresh: () {},
            child: WaterfallFlow.builder(
                primary: false,
                padding: EdgeInsets.only(
                    top: DefaultStyle.pagePadding,
                    bottom: MediaQuery.of(context).padding.bottom +
                        ScreenUtil().bottomBarHeight,
                    left: DefaultStyle.pagePadding,
                    right: DefaultStyle.pagePadding),
                itemCount: 20,
                gridDelegate:
                    SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: ScreenUtil().setWidth(10),
                        crossAxisSpacing: DefaultStyle.pagePadding),
                itemBuilder: (BuildContext context, int index) {
                  return card();
                }),
          ))
        ],
      ),
    );
  }
}
