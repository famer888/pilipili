import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/http.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class PublicList extends StatefulWidget {
  @required
  final bool isShow; //是否展示
  final String api; //接口地址
  final Map data; //传递参数
  final int limit;
  final bool isFlow; //是否瀑布流
  final String cartType; //  "h" 横向card  "v"竖向card
  final int contentType; //参照 cardMixin.dart 文件
  PublicList(
      {Key key,
      this.isShow,
      this.api,
      this.data,
      this.limit = 20,
      this.isFlow = true,
      this.cartType = 'h',
      this.contentType})
      : super(key: key);

  @override
  _PublicListState createState() => _PublicListState();
}

class _PublicListState extends State<PublicList> {
  bool isAll = false;
  bool loading = true;
  bool initPage = false;
  Map reqData = {'page': 1, 'limit': 20};
  List searchData;
  Future getSearchResult() async {
    if (widget.api == null) {
      CommonUtils.showText('请传入接口路径');
      return;
    }
    try {
      Response<dynamic> res =
          await PlatformAwareHttp.post(widget.api, data: reqData);
      if (res.data['status'] != 0) {
        List resdata = res.data['data'] == null ? [] : res.data['data'];
        isAll = resdata.length < reqData['limit'];
        if (reqData['page'] == 1) {
          searchData = resdata;
        } else {
          searchData.addAll(resdata);
        }
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res.data['msg']);
      }
    } catch (e) {
      CommonUtils.debugPrint('错误:$e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.data is Map) {
      reqData.addAll(widget.data);
    }
    reqData['limit'] = widget.limit;
    if (widget.isShow && !initPage) {
      initPage = true;
      getSearchResult();
    }
  }

  @override
  void didUpdateWidget(PublicList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data && initPage) {
      loading = true;
      reqData['page'] = 1;
      isAll = false;
      initPage = false;
      setState(() {});
      if (widget.data != null) {
        reqData.addAll(widget.data);
      } else {
        reqData = {'page': 1, 'limit': widget.limit};
      }
      if (widget.isShow) {
        initPage = true;
        getSearchResult();
      }
    }
    if (widget.isShow && !initPage) {
      initPage = true;
      getSearchResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? PageStatus.loading(true)
        : searchData.isEmpty
            ? PageStatus.noData()
            : PullRefreshList(
                onLoading: () {
                  if (isAll) {
                    CommonUtils.showText('已为您加载完所有数据～');
                    return;
                  }
                  reqData['page']++;
                  getSearchResult();
                },
                onRefresh: () {
                  reqData['page'] = 1;
                  isAll = false;
                  getSearchResult();
                },
                child: widget.isFlow
                    ? WaterfallFlow.builder(
                        primary: false,
                        padding: EdgeInsets.only(
                            top: DefaultStyle.pagePadding,
                            bottom: MediaQuery.of(context).padding.bottom +
                                ScreenUtil().bottomBarHeight,
                            left: DefaultStyle.pagePadding,
                            right: DefaultStyle.pagePadding),
                        itemCount: searchData.length,
                        gridDelegate:
                            SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: ScreenUtil().setWidth(10),
                                crossAxisSpacing: ScreenUtil().setWidth(10)),
                        itemBuilder: (BuildContext context, int index) {
                          return searchData[index]['mv_type'] == 1
                              ? Hcard(
                                  width: ScreenUtil().setWidth(175),
                                  tagIconType: searchData[index]['isfree'],
                                  thumbUrl:
                                      CommonUtils.getThumb(searchData[index]),
                                  contentType: widget.contentType ?? 1,
                                  cardData: searchData[index],
                                  showField: 'title')
                              : Vcard(
                                  width: ScreenUtil().setWidth(175),
                                  isSearch: true,
                                  tagIconType: searchData[index]['isfree'],
                                  thumbUrl:
                                      CommonUtils.getThumb(searchData[index]),
                                  contentType: widget.contentType ?? 7,
                                  cardData: searchData[index],
                                  showField: 'title');
                          ;
                        })
                    : GridView.builder(
                        cacheExtent: ScreenUtil().screenHeight * 5,
                        padding: EdgeInsets.symmetric(
                            horizontal: DefaultStyle.pagePadding,
                            vertical: ScreenUtil().setWidth(20)),
                        itemCount: searchData.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: ScreenUtil().setWidth(7),
                          crossAxisSpacing: ScreenUtil().setWidth(7),
                          childAspectRatio: 1.11,
                        ),
                        itemBuilder: (context, index) {
                          return widget.cartType == 'h'
                              ? Hcard(
                                  width: ScreenUtil().setWidth(175),
                                  tagIconType: searchData[index]['isfree'],
                                  thumbUrl:
                                      CommonUtils.getThumb(searchData[index]),
                                  contentType: widget.contentType ?? 1,
                                  cardData: searchData[index],
                                  showField: 'title')
                              : Vcard(
                                  width: ScreenUtil().setWidth(175),
                                  tagIconType: searchData[index]['isfree'],
                                  thumbUrl:
                                      CommonUtils.getThumb(searchData[index]),
                                  contentType: widget.contentType ?? 1,
                                  cardData: searchData[index],
                                  showField: 'title');
                        }),
              );
  }
}
