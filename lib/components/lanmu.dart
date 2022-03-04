import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/mixin/element_mixin.dart';
import 'package:pilipili/model/construct.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';

class Lanmu extends StatefulWidget {
  Lanmu({Key key, this.data, this.id, this.isShow, this.parentName, this.index})
      : super(key: key);
  final dynamic data;
  final int id;
  final bool isShow;
  final String parentName;
  final int index;
  @override
  _LanmuState createState() => _LanmuState();
}

class _LanmuState extends State<Lanmu> with ElementMixin {
  List tabList = ['限免', '网黄', 'COS', '精彩活动'];
  int pageStatus = 0;
  int page = 1;
  bool isAll = false;
  int limit = 10;
  bool networkErr = false;
  ConstructModel cm_data;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (pageStatus == 0 && widget.isShow) {
      setState(() {
        pageStatus = 1;
      });
      getPageData();
    }
  }

  void getPageData() async {
    getConstructById(id: widget.id, page: page, limit: limit).then((res) {
      if (res == null) {
        networkErr = true;
        setState(() {});
        return;
      }
      isAll = res.elements.length < limit;
      if (page == 1) {
        cm_data = res;
      } else {
        cm_data.elements.addAll(res.elements);
      }
    }).whenComplete(() {
      setState(() {
        pageStatus = 2;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return networkErr
        ? PageStatus.noNetWork(onTap: () {
            networkErr = false;
            page = 1;
            setState(() {});
            getPageData();
          })
        : pageStatus != 2
            ? pageStatus == 1
                ? PageStatus.loading(mounted)
                : Container()
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
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                        backgroundColor: Colors.transparent,
                        primary: false,
                        leading: Container(),
                        pinned: false,
                        elevation: 0,
                        forceElevated: true,
                        expandedHeight: ScreenUtil().setWidth(340),
                        flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background:
                                Stack(clipBehavior: Clip.none, children: [
                              Swiper(
                                autoplayDelay: 10000,
                                autoplay: true,
                                onIndexChanged: (e) {
                                  // CommonUtils.debugPrint('-------------------$e---------------------');
                                },
                                pagination: SwiperPagination(
                                    margin: EdgeInsets.only(
                                        bottom: ScreenUtil().setWidth(100)),
                                    alignment: Alignment.bottomCenter,
                                    builder: SwiperCustomPagination(builder:
                                        (BuildContext context,
                                            SwiperPluginConfig config) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List(10)
                                            .asMap()
                                            .keys
                                            .map<Widget>((e) {
                                          return AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 250),
                                            width: ScreenUtil().setWidth(6),
                                            height: ScreenUtil().setWidth(6),
                                            margin: EdgeInsets.only(
                                                left:
                                                    ScreenUtil().setWidth(16)),
                                            decoration: BoxDecoration(
                                                color: config.activeIndex == e
                                                    ? Colors.white
                                                    : Colors.white54,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        ScreenUtil()
                                                            .setWidth(3))),
                                          );
                                        }).toList(),
                                      );
                                    })),
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      // if (widget.data[index]['type'] == 1) {
                                      //   CommonUtils.launchURL(
                                      //       widget.data[index]['url'].trim());
                                      // } else if (widget.data[index]['type'] == 2) {
                                      //   String linkUrl = widget.data[index]['url'];
                                      //   List urlList = linkUrl.split('?');
                                      //   Map<String, dynamic> pramas = {};
                                      //   if (urlList.length > 1) {
                                      //     urlList[1].split("&").forEach((item) {
                                      //       List stringText = item.split('=');
                                      //       pramas[stringText[0]] = stringText.length > 1
                                      //           ? stringText[1]
                                      //           : null;
                                      //     });
                                      //   }
                                      //   context.push(urlList[0], extra: pramas);
                                      // } else if (widget.data[index]['type'] == 4) {
                                      //   var members =
                                      //       Provider.of<HomeConfig>(context, listen: false)
                                      //           .member;
                                      //   var aff = members.aff;
                                      //   var yyid = members.uuid;
                                      //   CommonUtils.launchURL(
                                      //       '${widget.data[index]['url'].trim()}?aff=$aff&yyid=$yyid');
                                      // }
                                    },
                                    child: Container(
                                      child: Image.asset(
                                        'assets/images/demo_bg.png',
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  );
                                },
                                itemCount: 10,
                              ),
                              Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(255, 244, 249, 1),
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(
                                                ScreenUtil().setWidth(30)),
                                            topLeft: Radius.circular(
                                                ScreenUtil().setWidth(30)))),
                                    height: ScreenUtil().setWidth(88),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: ScreenUtil().setWidth(5),
                                      children: tabList.asMap().keys.map((e) {
                                        return Stack(
                                          children: [
                                            Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                bottom: 0,
                                                child: Image.asset(
                                                  'assets/images/btn_bg.png',
                                                  fit: BoxFit.fill,
                                                )),
                                            Container(
                                              width: ScreenUtil().setWidth(79),
                                              height: ScreenUtil().setWidth(51),
                                              padding: EdgeInsets.only(
                                                  right:
                                                      ScreenUtil().setWidth(3),
                                                  bottom:
                                                      ScreenUtil().setWidth(3)),
                                              alignment: Alignment.center,
                                              child: Text(
                                                tabList[e],
                                                style: TextStyle(
                                                    color: Color(0xffc8003c),
                                                    fontSize:
                                                        ScreenUtil().setSp(16),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  )),
                            ]))),
                    cm_data?.elements == null
                        ? SliverToBoxAdapter()
                        : SliverList(
                            delegate: SliverChildListDelegate(cm_data.elements
                                .asMap()
                                .keys
                                .map(
                                  (e) =>
                                      getElement(element: cm_data.elements[e]),
                                )
                                .toList()))
                  ],
                ));
  }
}
