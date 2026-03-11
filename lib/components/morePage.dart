import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';

// ignore: must_be_immutable
class MorePage extends StatefulWidget {
  MorePage(
      {Key? key,
      this.title,
      this.filterOptions,
      this.crossAxisCount,
      this.morePageType,
      this.id})
      : super(key: key);
  String? title;
  List? filterOptions; // 筛选项
  int? crossAxisCount; // 列表是几列的
  int? morePageType; // 使用什么类型的卡片
  dynamic id;
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage>
    with AutomaticKeepAliveClientMixin {
  bool loading = true;
  int page = 1;
  int limit = 18;
  bool isAll = false;
  late int contentType;
  late List data;

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  @override
  bool get wantKeepAlive => true;

  getPageData() async {
    await getElementByIdSecondPage(id: widget.id, page: page, limit: limit)
        .then((res) {
      if (res['status'] != 0) {
        if (res['data']['value'] == null) {
          context.pop();
          CommonUtils.showText('数据结构出现错误');
          return;
        }
        // LogUtil.d('数据-----${res['data']}');
        contentType = res['data']['content_type'];
        loading = false;
        isAll = res['data']['value'].length < limit;
        if (page == 1) {
          data = res['data']['value'];
        } else {
          data.addAll(res['data']['value']);
        }
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: widget.title != null ? widget.title! : '',
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: DefaultStyle.pagePadding),
            child: loading
                ? PageStatus.loading(mounted)
                : data.length == 0
                    ? PageStatus.noData()
                    : PullRefreshList(
                        onLoading: () {
                          if (isAll) {
                            CommonUtils.showText('已经没有数据啦～');
                            return;
                          }
                          page++;
                          getPageData();
                        },
                        onRefresh: () async {
                          page = 1;
                          isAll = false;
                          await getPageData();
                        },
                        child: GridView(
                          cacheExtent: ScreenUtil().screenHeight * 5,
                          padding: EdgeInsets.only(
                              top: ScreenUtil().setWidth(16),
                              bottom: ScreenUtil().bottomBarHeight +
                                  ScreenUtil().setWidth(16)),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      widget.morePageType == 1 ? 2 : 3,
                                  crossAxisSpacing: ScreenUtil().setWidth(7),
                                  childAspectRatio:
                                      widget.morePageType == 1 ? 1.25 : 0.55),
                          children: data
                              .asMap()
                              .keys
                              .map((e) => widget.morePageType == 1
                                  ? Hcard(
                                      page:
                                          ((e + 1) / AppGlobal.smallVideoLimit)
                                              .ceil(),
                                      width: ScreenUtil().setWidth(171),
                                      contentType: contentType,
                                      thumbUrl: CommonUtils.getThumb(data[e]),
                                      cardData: data[e],
                                      showField: 'title',
                                    )
                                  : Vcard(
                                      page:
                                          ((e + 1) / AppGlobal.smallVideoLimit)
                                              .ceil(),
                                      width: ScreenUtil().setWidth(121),
                                      contentType: contentType,
                                      thumbUrl: CommonUtils.getThumb(data[e]),
                                      cardData: data[e],
                                      showField: 'title',
                                    ))
                              .toList(),
                        ),
                      ),
          ))
        ],
      ),
    );
  }
}
