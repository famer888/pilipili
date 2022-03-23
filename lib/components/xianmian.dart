import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:pilipili/theme/default.dart';

class Xianmian extends StatefulWidget {
  Xianmian({Key key}) : super(key: key);

  @override
  State<Xianmian> createState() => _XianmianState();
}

class _XianmianState extends State<Xianmian> {
  int pageStatus = 0;
  bool isAll = false;
  bool networkErr = false;
  int cardType; //1 视频 2漫画 3小说 4链接 5有声小说  6图集 7短视频；
  int page = 1;
  int limit = 24;
  List data = [];
  bool isHorizontal = false;
  bool isListView = false;
  bool isActivity = false;
  bool isFall = false;
  ScrollController _controller;

  getPageData() async {
    var res = await getChangVideoList(limit: limit, page: page, isfree: 0);
    if (res == null) {
      networkErr = true;
      setState(() {});
      return;
    }
    CommonUtils.debugPrint(res);
    if (res == null || res['data'] == null) return;
    List resData = res['data'];
    if (page == 1) {
      data = resData;
    } else {
      data.addAll(resData);
    }
    pageStatus = 2;
    isAll = (resData.length < limit);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getPageData();
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
          (networkErr || data == null)
              ? PageStatus.noNetWork(onTap: () {
                  networkErr = false;
                  setState(() {});
                  getPageData();
                })
              : Expanded(
                  child: pageStatus != 2
                      ? PageStatus.loading(mounted)
                      : PullRefreshList(
                          onLoading: () {
                            if (isAll) return;
                            page++;
                            getPageData();
                          },
                          onRefresh: () async {
                            page = 1;
                            isAll = false;
                            networkErr = false;
                            page = 1;
                            getPageData();
                          },
                          child: data.length == 0
                              ? SingleChildScrollView(
                                  child: PageStatus.noData(text: '还没有白嫖资源哦～'),
                                )
                              : WaterfallFlow.builder(
                                  primary: false,
                                  padding: EdgeInsets.only(
                                      top: DefaultStyle.pagePadding,
                                      bottom: MediaQuery.of(context)
                                              .padding
                                              .bottom +
                                          ScreenUtil().bottomBarHeight,
                                      left: DefaultStyle.pagePadding,
                                      right: DefaultStyle.pagePadding),
                                  itemCount: data.length,
                                  gridDelegate:
                                      SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing:
                                              ScreenUtil().setWidth(10),
                                          crossAxisSpacing:
                                              ScreenUtil().setWidth(10)),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return data[index]['mv_type'] == 1
                                        ? Hcard(
                                            width: ScreenUtil().setWidth(175),
                                            tagIconType: data[index]['isfree'],
                                            thumbUrl: CommonUtils.getThumb(
                                                data[index]),
                                            contentType: 1,
                                            cardData: data[index],
                                            showField: 'title')
                                        : Vcard(
                                            width: ScreenUtil().setWidth(175),
                                            isSearch: true,
                                            tagIconType: data[index]['isfree'],
                                            thumbUrl: CommonUtils.getThumb(
                                                data[index]),
                                            contentType: 7,
                                            cardData: data[index],
                                            showField: 'title');
                                  }),
                        ))
        ],
      ),
    );
  }
}
