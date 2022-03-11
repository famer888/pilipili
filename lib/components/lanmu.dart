import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:pilipili/components/card/home_nav_btn.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/mixin/element_mixin.dart';
import 'package:pilipili/model/construct.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/routers.dart';
import 'package:provider/provider.dart';

class Lanmu extends StatefulWidget {
  Lanmu(
      {Key key,
      this.data,
      this.id,
      this.isShow,
      this.parentName,
      this.index,
      this.tabList})
      : super(key: key);
  final dynamic data;
  final int id;
  final bool isShow;
  final String parentName;
  final int index;
  final List tabList;
  @override
  _LanmuState createState() => _LanmuState();
}

class _LanmuState extends State<Lanmu> with ElementMixin {
  int pageStatus = 0;
  int page = 1;
  bool isAll = false;
  int limit = 10;
  bool networkErr = false;
  bool isShow = false;
  dynamic fixedBanner;
  dynamic fixedNav;
  ConstructModel cm_data;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (pageStatus == 0) {
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
      fixedBanner =
          cm_data.elements.firstWhere((element) => fixedNav['type'] == 6);
      fixedNav =
          cm_data.elements.firstWhere((element) => fixedNav['type'] == 7);
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
    double navHeight = (fixedNav == null || fixedNav.length == 0 ? 32 : 88);
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
                offset:
                    DefaultStyle.navbarHegiht + ScreenUtil().statusBarHeight,
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
                        expandedHeight: ScreenUtil().statusBarHeight +
                            DefaultStyle.navbarHegiht +
                            ScreenUtil().setWidth(160) +
                            ScreenUtil().setWidth(navHeight),
                        bottom: PreferredSize(
                          preferredSize: Size(double.infinity,
                              ScreenUtil().setWidth(navHeight)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topRight:
                                    Radius.circular(ScreenUtil().setWidth(30)),
                                topLeft:
                                    Radius.circular(ScreenUtil().setWidth(30))),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 244, 249, 1),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(16)),
                              child: fixedNav == null ||
                                      fixedNav['value'].length == 0
                                  ? Container()
                                  : Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: ScreenUtil().setWidth(5),
                                      children: fixedNav['value']
                                          .asMap()
                                          .keys
                                          .map((e) {
                                        return HomeNavBtn(
                                          cardData: fixedNav['value'][e],
                                        );
                                      }).toList(),
                                    ),
                            ),
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background:
                                Stack(clipBehavior: Clip.none, children: [
                              fixedBanner == null ||
                                      fixedBanner['value'].length == 0
                                  ? Image.asset(
                                      'assets/images/demo_bg.png',
                                      fit: BoxFit.fill,
                                    )
                                  : Swiper(
                                      autoplayDelay: 3000,
                                      autoplay: fixedBanner['value'].length > 1,
                                      onIndexChanged: (e) {
                                        // CommonUtils.debugPrint('-------------------$e---------------------');
                                      },
                                      pagination: SwiperPagination(
                                          margin: EdgeInsets.only(
                                              bottom:
                                                  ScreenUtil().setWidth(100)),
                                          alignment: Alignment.bottomCenter,
                                          builder: SwiperCustomPagination(
                                              builder: (BuildContext context,
                                                  SwiperPluginConfig config) {
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: fixedBanner['value']
                                                  .asMap()
                                                  .keys
                                                  .map<Widget>((e) {
                                                return AnimatedContainer(
                                                  duration: Duration(
                                                      milliseconds: 250),
                                                  width:
                                                      ScreenUtil().setWidth(6),
                                                  height:
                                                      ScreenUtil().setWidth(6),
                                                  margin: EdgeInsets.only(
                                                      left: ScreenUtil()
                                                          .setWidth(16)),
                                                  decoration: BoxDecoration(
                                                      color:
                                                          config.activeIndex ==
                                                                  e
                                                              ? Colors.white
                                                              : Colors.white54,
                                                      borderRadius: BorderRadius
                                                          .circular(ScreenUtil()
                                                              .setWidth(3))),
                                                );
                                              }).toList(),
                                            );
                                          })),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            if (fixedBanner['value'][index]
                                                    ['type'] ==
                                                1) {
                                              CommonUtils.launchURL(
                                                  fixedBanner['value'][index]
                                                          ['url']
                                                      .trim());
                                            } else if (fixedBanner['value']
                                                    [index]['type'] ==
                                                2) {
                                              String linkUrl =
                                                  fixedBanner['value'][index]
                                                      ['url'];
                                              List urlList = linkUrl.split('?');
                                              Map<String, dynamic> pramas = {};
                                              if (urlList.length > 1) {
                                                urlList[1]
                                                    .split("&")
                                                    .forEach((item) {
                                                  List stringText =
                                                      item.split('=');
                                                  pramas[stringText[0]] =
                                                      stringText.length > 1
                                                          ? stringText[1]
                                                          : null;
                                                });
                                              }
                                              context.push(urlList[0],
                                                  extra: pramas);
                                            } else if (widget.data[index]
                                                    ['type'] ==
                                                4) {
                                              var members =
                                                  Provider.of<HomeConfig>(
                                                          context,
                                                          listen: false)
                                                      .member;
                                              var aff = members.aff;
                                              var yyid = members.uuid;
                                              CommonUtils.launchURL(
                                                  '${widget.data[index]['url'].trim()}?aff=$aff&yyid=$yyid');
                                            }
                                          },
                                          child: Container(
                                            clipBehavior: Clip.hardEdge,
                                            padding: EdgeInsets.only(
                                                bottom: ScreenUtil()
                                                    .setWidth(navHeight - 32)),
                                            decoration: ShapeDecoration(
                                                shape:
                                                    BeveledRectangleBorder()),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  right: 0,
                                                  left: 0,
                                                  bottom: 0,
                                                  top: 0,
                                                  child: Stack(
                                                    children: [
                                                      Opacity(
                                                        opacity: 0.7,
                                                        child: Image.asset(
                                                          'assets/images/demo_bg.png',
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 15,
                                                                sigmaY: 15),
                                                        child: Container(
                                                          color: Colors.black38,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: ScreenUtil()
                                                          .setWidth(260) +
                                                      ScreenUtil()
                                                          .statusBarHeight,
                                                ),
                                                Positioned(
                                                    top: 0,
                                                    bottom: 0,
                                                    right: 0,
                                                    left: 0,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: ScreenUtil()
                                                                  .statusBarHeight +
                                                              DefaultStyle
                                                                  .navbarHegiht),
                                                      child: Container(
                                                        width: double.infinity,
                                                        child: Image.asset(
                                                          'assets/images/demo_bg.png',
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: 10,
                                    ),
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
                                .toList())),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: ScreenUtil().setWidth(30),
                      ),
                    )
                  ],
                ));
  }
}
