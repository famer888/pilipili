import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/report/report_utils.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/http.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class PublicList extends StatefulWidget {
  @required
  final bool? isShow; //是否展示
  final String? api; //接口地址
  final Map? data; //传递参数
  final int? width;
  final int crossAxisCount;
  final int limit;
  final bool isFlow; //是否瀑布流
  final String? cartType; //  "h" 横向card  "v"竖向card
  final int? contentType; //参照 cardMixin.dart 文件
  final bool noRefresh;
  final bool isSearch;
  final bool isReport;

  PublicList(
      {Key? key,
      this.isShow,
      this.api,
      this.data,
      this.width,
      this.crossAxisCount = 2,
      this.limit = 20,
      this.isFlow = true,
      this.cartType,
      this.contentType,
      this.noRefresh = false,
      this.isSearch = false,
      this.isReport = false})
      : super(key: key);

  @override
  _PublicListState createState() => _PublicListState();
}

class _PublicListState extends State<PublicList> {
  bool isAll = false;
  bool loading = true;
  bool initPage = false;
  Map reqData = {'page': 1, 'limit': 20};
  late List searchData;

  Map getType() {
    Map info = {'key': '', 'name': ''};
    switch (widget.contentType) {
      case 1: //视频
        info = {'key': 'video', 'name': '视频'};
        break;
      case 2: //漫画
        info = {'key': 'comics', 'name': '漫画'};
        break;
      case 3: //小说
        info = {'key': 'novel', 'name': '小说'};
        break;
      case 4: //链接

        break;
      case 5: //有声小说
        info = {'key': 'audiobook', 'name': '有声小说'};
        break;
      case 6: //图集
        info = {'key': 'atlas', 'name': '图集'};
        break;
      case 7: //短视频
        info = {'key': 'smallvideo', 'name': '短视频'};
        break;
      case 10: //动漫
        info = {'key': 'dongman', 'name': '动漫'};
        break;
      default:
    }
    return info;
  }

  Future getSearchResult() async {
    try {
      Response<dynamic> res = await PlatformAwareHttp.post(widget.api!, data: reqData);
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
      CommonUtils.debugPrint('错误:' + e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    reqData.addAll(widget.data!);
    reqData['limit'] = widget.limit;
    if (widget.isShow == true && !initPage) {
      initPage = true;
      getSearchResult();
    }
  }

  @override
  void didUpdateWidget(PublicList oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool isSame = true;
    widget.data!.forEach((key, value) {
      if (widget.data![key] != oldWidget.data![key]) {
        isSame = false;
      }
    });
    if (!isSame && initPage) {
      loading = true;
      reqData['page'] = 1;
      isAll = false;
      initPage = false;
      setState(() {});
      reqData.addAll(widget.data!);
      if (widget.isShow!) {
        initPage = true;
        getSearchResult();
      }
    }
    if (widget.isShow == true && !initPage!) {
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
                onRefresh: widget.noRefresh
                    ? null
                    : () {
                        reqData['page'] = 1;
                        isAll = false;
                        getSearchResult();
                      },
                child: widget.isFlow
                    ? WaterfallFlow.builder(
                        cacheExtent: ScreenUtil().screenHeight * 5,
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.only(
                            top: DefaultStyle.pagePadding,
                            bottom: MediaQuery.of(context).padding.bottom + ScreenUtil().bottomBarHeight,
                            left: DefaultStyle.pagePadding,
                            right: DefaultStyle.pagePadding),
                        itemCount: searchData.length,
                        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                            crossAxisCount: widget.crossAxisCount,
                            mainAxisSpacing: ScreenUtil().setWidth(10),
                            crossAxisSpacing: ScreenUtil().setWidth(10)),
                        itemBuilder: (BuildContext context, int index) {
                          return searchData[index]['mv_type'] == 1
                              ? Hcard(
                                      isSearch: widget.isSearch,
                                      maxLines: 1,
                                      width: ScreenUtil().setWidth(widget.width ?? 175),
                                      tagIconType: searchData[index]['isfree'],
                                      thumbUrl: CommonUtils.getThumb(searchData[index]),
                                      contentType: searchData[index]['mv_type'] == null
                                          ? widget.contentType
                                          : (searchData[index]['mv_type'] == 1 ? 1 : 7),
                                      cardData: searchData[index],
                                      showField: 'title')
                                  .withSearchReport(widget.isReport, {
                                  'keyword': widget.data!['word'],
                                  'click_item_id': searchData[index]['related_id'] ?? searchData[index]['id'],
                                  'click_item_type_key': 'search_${getType()['key']}',
                                  'click_item_type_name': getType()['name'],
                                  'click_position': index
                                })
                              : Vcard(
                                      isSearch: widget.isSearch,
                                      maxLines: 1,
                                      width: ScreenUtil().setWidth(widget.width ?? 175),
                                      tagIconType: searchData[index]['isfree'],
                                      thumbUrl: CommonUtils.getThumb(searchData[index]),
                                      contentType: searchData[index]['mv_type'] == null
                                          ? widget.contentType
                                          : (searchData[index]['mv_type'] == 1 ? 1 : 7),
                                      cardData: searchData[index],
                                      showField: 'title')
                                  .withSearchReport(widget.isReport, {
                                  'keyword': widget.data!['word'],
                                  'click_item_id': searchData[index]['related_id'] ?? searchData[index]['id'],
                                  'click_item_type_key': 'search_${getType()['key']}',
                                  'click_item_type_name': getType()['name'],
                                  'click_position': index
                                });
                        })
                    : GridView.builder(
                        cacheExtent: ScreenUtil().screenHeight * 5,
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: DefaultStyle.pagePadding, vertical: ScreenUtil().setWidth(20)),
                        itemCount: searchData.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: widget.crossAxisCount,
                          mainAxisSpacing: ScreenUtil().setWidth(7),
                          crossAxisSpacing: ScreenUtil().setWidth(7),
                          childAspectRatio: (widget.cartType ?? 'h') == 'h' ? 1.2 : 0.61,
                        ),
                        itemBuilder: (context, index) {
                          return (widget.cartType ?? 'h') == 'h'
                              ? Hcard(
                                      isSearch: widget.isSearch,
                                      maxLines: 1,
                                      width: ScreenUtil().setWidth(widget.width ?? 175),
                                      tagIconType: searchData[index]['isfree'],
                                      thumbUrl: CommonUtils.getThumb(searchData[index]),
                                      contentType: searchData[index]['mv_type'] == null
                                          ? widget.contentType
                                          : (searchData[index]['mv_type'] == 1 ? 1 : 7),
                                      cardData: searchData[index],
                                      showField: 'title')
                                  .withSearchReport(widget.isReport, {
                                  'keyword': widget.data!['word'],
                                  'click_item_id': searchData[index]['related_id'] ?? searchData[index]['id'],
                                  'click_item_type_key': 'search_${getType()['key']}',
                                  'click_item_type_name': getType()['name'],
                                  'click_position': index
                                })
                              : Vcard(
                                      isSearch: widget.isSearch,
                                      maxLines: 1,
                                      width: ScreenUtil().setWidth(widget.width ?? 175),
                                      tagIconType: searchData[index]['isfree'],
                                      thumbUrl: CommonUtils.getThumb(searchData[index]),
                                      contentType: searchData[index]['mv_type'] == null
                                          ? widget.contentType
                                          : (searchData[index]['mv_type'] == 1 ? 1 : 7),
                                      cardData: searchData[index],
                                      showField: 'title')
                                  .withSearchReport(widget.isReport, {
                                  'keyword': widget.data!['word'],
                                  'click_item_id': searchData[index]['related_id'] ?? searchData[index]['id'],
                                  'click_item_type_key': 'search_${getType()['key']}',
                                  'click_item_type_name': getType()['name'],
                                  'click_position': index
                                });
                        }),
              );
  }
}
