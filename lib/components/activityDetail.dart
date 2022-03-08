import 'dart:ffi';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/sharemovie.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:pilipili/theme/default.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/utils/common.dart';

class ActivityDetail extends StatefulWidget {
  ActivityDetail({Key key, this.id}) : super(key: key);
  final String id;
  @override
  State<ActivityDetail> createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  bool isEnd = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              PageTitleBar(
                  paddingTop: ScreenUtil().statusBarHeight,
                  title: "活动详情",
                  rightWidget: GestureDetector(
                    onTap: () {
                      var config =
                          Provider.of<HomeConfig>(context, listen: false)
                              .config;
                      ShareMovieModel.showShareMovie(backButtonBehavior,
                          copyUrl: config.share.affUrlCopy.url,
                          thumb:
                              "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg",
                          title: "撒看到过胩是公开的撒" ?? '--',
                          subtitle: "谁看过的卡萨看到过卡啊的撒卡" ?? '--',
                          url: '${config.share.affUrl}');
                    },
                    child: Image.asset(
                      "assets/images/icon_share.png",
                      width: ScreenUtil().setWidth(20),
                      fit: BoxFit.fitWidth,
                    ),
                  )),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/icon_love_red2.png",
                            width: ScreenUtil().setWidth(6),
                            fit: BoxFit.fitWidth,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(6)),
                            child: Text(
                              '活动标题是大手大脚开始',
                              style: DefaultStyle.black18bold,
                            ),
                          ),
                          Image.asset(
                            "assets/images/icon_love_red2.png",
                            width: ScreenUtil().setWidth(6),
                            fit: BoxFit.fitWidth,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: ScreenUtil().setWidth(20),
                          left: ScreenUtil().setWidth(20),
                          right: ScreenUtil().setWidth(20)),
                      child: Text(
                        '啊胩更是生生世世生生世世生生世世生生世世生生世世生生世世生生世世生生世世生生世世生生世世生生世世生生世世广大考生更多快感啊谁看过的苦瓜撒卡',
                        style: TextStyle(
                            color: Color(0xff646464),
                            fontSize: ScreenUtil().setSp(14)),
                      ),
                    ),
                    Image.network(
                      "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg",
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    Image.network(
                      "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg",
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    Image.network(
                      "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg",
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(
                        height: ScreenUtil().setWidth(70) +
                            ScreenUtil().bottomBarHeight),
                  ],
                ),
              ))
            ],
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                    top: ScreenUtil().setWidth(15),
                    right: ScreenUtil().setWidth(20),
                    left: ScreenUtil().setWidth(20),
                    bottom: ScreenUtil().bottomBarHeight == 0
                        ? ScreenUtil().setWidth(15)
                        : ScreenUtil().bottomBarHeight),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(TextSpan(
                        text: '1432432 ',
                        style: TextStyle(
                            color: Color(0xffff5b8c),
                            fontSize: ScreenUtil().setSp(16),
                            fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: '人已参与活动', style: DefaultStyle.black14)
                        ])),
                    isEnd
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isEnd = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(8),
                                  horizontal: ScreenUtil().setWidth(30)),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil().setWidth(20)),
                                  color: Color(0xffdcdcdc)),
                              child: Text(
                                '活动已结束',
                                style: DefaultStyle.white15bold,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() {
                                isEnd = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(8),
                                  horizontal: ScreenUtil().setWidth(30)),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil().setWidth(20)),
                                  gradient: LinearGradient(
                                      colors: [
                                        Color.fromRGBO(255, 174, 198, 1),
                                        Color.fromRGBO(255, 77, 131, 1),
                                        Color.fromRGBO(255, 7, 83, 1)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter)),
                              child: Text(
                                '立即参与',
                                style: DefaultStyle.white15bold,
                              ),
                            ),
                          )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
