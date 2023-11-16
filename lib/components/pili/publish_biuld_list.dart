import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/http.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

typedef BuildWidgetData = Function(BuildContext context, int index,
    dynamic data, int page, int limit, Function getListData);

class PublicBuildList extends StatefulWidget {
  final bool isShow; //是否展示
  final BuildWidgetData itemBuild;
  final String api; //接口地址
  final Map data; //传递参数
  final int limit;
  final bool isFlow; //是否瀑布流
  final int row;
  final bool noRefresh;
  final double bottomPadding;
  final double aspectRatio;
  final String nullText;
  final bool isController;
  final double paddingTop;
  final double paddingLeft;
  final double paddingRight;
  final Widget head;
  PublicBuildList({
    Key key,
    this.isShow,
    @required this.api,
    this.data,
    this.limit = 20,
    this.isFlow = false,
    this.noRefresh = false,
    this.bottomPadding = 0,
    @required this.itemBuild,
    this.aspectRatio = 1.5,
    this.row = 1,
    this.nullText,
    this.isController = true,
    this.paddingTop = 0,
    this.paddingLeft = 0,
    this.paddingRight = 0,
    this.head,
  }) : super(key: key);

  @override
  _PublicBuildListState createState() => _PublicBuildListState();
}

class _PublicBuildListState extends State<PublicBuildList> {
  ScrollController _controller = ScrollController();
  bool isAll = false;
  bool loading = true;
  bool networkErr = false;
  bool initPage = false;
  Map reqData = {'page': 1, 'limit': 20};
  List searchData;
  Future getSearchResult() async {
    if (networkErr) {
      reqData = {'page': 1, 'limit': 20};
      networkErr = false;
      isAll = false;
      loading = true;
      setState(() {});
    }
    try {
      Response<dynamic> res =
          await PlatformAwareHttp.post(widget.api, data: reqData);
      List resdata;
      CommonUtils.debugPrint("--${widget.api}------请求的返回${res.data}");
      if (res.data['status'] != 0) {
        if (res.data['data'] != null && res.data['data'] is List) {
          resdata = (res.data['data'] == null ? [] : res.data['data']);
        } else {
          resdata =
              (res.data['data'] != null && res.data['data']['list'] != null
                  ? res.data['data']['list']
                  : []);
        }

        if (widget.api.indexOf('dynamic/myDynamic') != -1 &&
            resdata.length > 0 &&
            resdata[0]['aff'] == null) {
          resdata.removeAt(0);
        }
        isAll = resdata.length < reqData['limit'];
        if (reqData['page'] == 1) {
          searchData = resdata;
        } else {
          searchData.addAll(resdata);
        }
        loading = false;
        setState(() {});
      } else {
        if (res.data['msg'] == "token无效") {
          getSearchResult();
        }
        CommonUtils.showText(res.data['msg']);
      }
      CommonUtils.debugPrint(searchData);
    } catch (e) {
      networkErr = true;
      setState(() {});
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
  void didUpdateWidget(PublicBuildList oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool isSame = true;
    widget.data.forEach((key, value) {
      if (widget.data[key] != oldWidget.data[key]) {
        isSame = false;
      }
    });
    if (!isSame && initPage) {
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

  childListBuild() {
    return searchData.isEmpty
        ? PageStatus.noData(text: widget.nullText)
        : widget.row == 1
            ? ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: widget.paddingTop,
                  left: widget.paddingLeft,
                  right: widget.paddingRight,
                  bottom: MediaQuery.of(context).padding.bottom +
                      AppGlobal.webBottomHeight,
                ),
                shrinkWrap: true,
                cacheExtent: 10.sh,
                controller: widget.isController ? _controller : null,
                itemCount: searchData.length,
                itemBuilder: (context, index) {
                  return widget.itemBuild(context, index, searchData[index],
                      reqData['page'], reqData['limit'], () {
                    return searchData;
                  });
                })
            : (widget.isFlow
                ? WaterfallFlow.builder(
                    shrinkWrap: true,
                    controller: widget.isController ? _controller : null,
                    cacheExtent: 5.sh,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                        top: 10.w,
                        bottom: MediaQuery.of(context).padding.bottom +
                            AppGlobal.webBottomHeight +
                            widget.bottomPadding,
                        left: 10.w,
                        right: 10.w),
                    itemCount: searchData.length,
                    gridDelegate:
                        SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                            crossAxisCount: widget.row,
                            mainAxisSpacing: ScreenUtil().setWidth(10),
                            crossAxisSpacing: ScreenUtil().setWidth(10)),
                    itemBuilder: (BuildContext context, int index) {
                      return widget.itemBuild(context, index, searchData[index],
                          reqData['page'], reqData['limit'], () {
                        return searchData;
                      });
                    })
                : GridView.builder(
                    controller: widget.isController ? _controller : null,
                    cacheExtent: 5.sh,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                        left: 10.w,
                        right: 10.w,
                        bottom: MediaQuery.of(context).padding.bottom +
                            AppGlobal.webBottomHeight +
                            widget.bottomPadding,
                        top: 20.w),
                    itemCount: searchData.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.row,
                      mainAxisSpacing: ScreenUtil().setWidth(7),
                      crossAxisSpacing: ScreenUtil().setWidth(7),
                      childAspectRatio: widget.aspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      return widget.itemBuild(context, index, searchData[index],
                          reqData['page'], reqData['limit'], () {
                        return searchData;
                      });
                    }));
  }

  @override
  Widget build(BuildContext context) {
    return networkErr
        ? PageStatus.noNetWork(onTap: () {
            reqData['page'] = 1;
            isAll = false;
            getSearchResult();
          })
        : loading
            ? PageStatus.loading(true)
            : PullRefreshList(
                onLoading: () {
                  if (isAll) {
                    return;
                  }
                  reqData['page']++;
                  getSearchResult();
                },
                onRefresh: () {
                  loading = true;
                  reqData['page'] = 1;
                  isAll = false;
                  setState(() {});
                  getSearchResult();
                },
                child: widget.head != null
                    ? NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverToBoxAdapter(
                              child: widget.head,
                            )
                          ];
                        },
                        body: childListBuild())
                    : childListBuild(),
              );
  }
}
