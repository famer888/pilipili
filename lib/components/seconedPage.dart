import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/model/construct.dart';
import 'package:pilipili/model/element.dart';
import 'package:pilipili/theme/default.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class SeconedPage extends StatefulWidget {
  SeconedPage({Key key, this.title, this.id}) : super(key: key);
  final String title;
  final int id;
  @override
  State<SeconedPage> createState() => _SeconedPageState();
}

class _SeconedPageState extends State<SeconedPage> {
  bool loading = true;
  int page = 1;
  bool isAll = false;
  int limit = 10;
  bool networkErr = false;
  bool isShow = false;
  ConstructModel cm_data;
  void getPageData() async {
    getConstructById(id: widget.id, page: page, limit: limit).then((res) {
      isAll = res.elements.length < limit;
      if (page == 1) {
        cm_data = res;
      } else {
        cm_data.elements.addAll(res.elements);
      }
    }).whenComplete(() {
      loading = false;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  Widget renderItem(dynamic itemData) {
    return GestureDetector(
      onTap: () {
        if (itemData['redirect_type'] == 1) {
          if (itemData['link_url'] == '' || itemData['link_url'] == null)
            return;
          context.push(CommonUtils.getRealHash(itemData['link_url']));
        } else if (itemData['redirect_type'] == 5) {
          if (itemData['link_url'] == '' || itemData['link_url'] == null)
            return;
          AppGlobal.seconedPagePramas = itemData;
          context.push(CommonUtils.getRealHash('seconedPageDetail'));
        }
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        height: ScreenUtil().setWidth(140),
        decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //       color: Color.fromRGBO(255, 91, 140, 0.4),
            //       blurRadius:15,
            //       spreadRadius:ScreenUtil().setWidth(5)
            //       )
            // ],
            borderRadius:
                BorderRadius.all(Radius.circular(ScreenUtil().setWidth(5)))),
        margin: EdgeInsets.only(bottom: DefaultStyle.pagePadding),
        child: PlatformAwareNetworkImage(
          url: itemData['resource_url'],
          fit: BoxFit.fill,
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
          loading
              ? Container()
              : Expanded(
                  child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: DefaultStyle.pagePadding),
                  child: cm_data.elements.isEmpty
                      ? PageStatus.noData()
                      : PullRefreshList(
                          onRefresh: () {
                            page = 1;
                            getPageData();
                          },
                          onLoading: () {
                            if (isAll) {
                              CommonUtils.showText('数据已经加载完啦～');
                              return;
                            }
                            page++;
                            getPageData();
                          },
                          child: ListView.builder(
                              cacheExtent: ScreenUtil().screenHeight * 5,
                              padding: EdgeInsets.only(
                                top: DefaultStyle.pagePadding,
                                bottom: ScreenUtil().bottomBarHeight +
                                    ScreenUtil().setWidth(20),
                              ),
                              itemCount: cm_data.elements.length,
                              itemBuilder: (BuildContext context, int index) {
                                List itemCard =
                                    cm_data.elements[index]['value'] == null
                                        ? []
                                        : cm_data.elements[index]['value'];
                                return itemCard.isEmpty
                                    ? Container()
                                    : renderItem(itemCard[0]);
                              }),
                        ),
                ))
        ],
      ),
    );
  }
}
