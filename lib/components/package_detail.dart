import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
class PackageDetail extends StatefulWidget {
  PackageDetail({Key? key, this.id, this.contentType, this.title})
      : super(key: key);
  final int? id;
  final int? contentType;
  final String? title;
  @override
  _PackageDetailState createState() => _PackageDetailState();
}

class _PackageDetailState extends State<PackageDetail>
    with AutomaticKeepAliveClientMixin {
  bool loading = true;
  int page = 1;
  int limit = 14;
  bool isAll = false;
  late List data;

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  @override
  bool get wantKeepAlive => true;

  getPageData() async {
    await getPackageDetail(id: widget.id, page: page, limit: limit).then((res) {
      if (res['status'] != 0) {
        loading = false;
        isAll = res['data'].length < limit;
        if (page == 1) {
          data = res['data'];
        } else {
          data.addAll(res['data']);
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
            title: widget.title,
            paddingTop: ScreenUtil().statusBarHeight,
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
                          padding: EdgeInsets.only(
                              top: ScreenUtil().setWidth(20),
                              bottom: ScreenUtil().bottomBarHeight +
                                  ScreenUtil().setWidth(20)),
                          cacheExtent: ScreenUtil().screenHeight * 5,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: ScreenUtil().setWidth(7),
                                  childAspectRatio:
                                      widget.contentType == 1 ? 1.25 : 0.65),
                          children: data
                              .asMap()
                              .keys
                              .map((e) => widget.contentType == 1
                                  ? Hcard(
                                      maxLines: 1,
                                      page:
                                          ((e + 1) / AppGlobal.smallVideoLimit)
                                              .ceil(),
                                      width: ScreenUtil().setWidth(171),
                                      contentType: 1,
                                      thumbUrl: CommonUtils.getThumb(data[e]),
                                      cardData: data[e],
                                      showField: 'title',
                                    )
                                  : Vcard(
                                      maxLines: 1,
                                      page:
                                          ((e + 1) / AppGlobal.smallVideoLimit)
                                              .ceil(),
                                      width: ScreenUtil().setWidth(171),
                                      contentType: 7,
                                      thumbUrl: CommonUtils.getThumb(data[e]),
                                      cardData: data[e],
                                      isSearch: true,
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
