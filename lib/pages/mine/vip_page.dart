import 'dart:async';
import 'dart:ui';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/model/basic.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/mixin/payMixin.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:pilipili/utils/privilege.dart';

class VipPage extends StatefulWidget {
  VipPage({Key key}) : super(key: key);

  @override
  _VipPageState createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> with PayMixin {
  PageController tabController;

  String _assetsPath(String name) {
    return 'assets/images/pment/$name.png';
  }

  List tabList = [
    {
      'id': 1,
      'name': 'VIP会员',
    },
    {
      'id': 2,
      'name': '更多会员',
    },
    {
      'id': 3,
      'name': '我的会员卡',
    }
  ];
  List qyList = [
    {'logo': 'vip_icon_quanyi_1', 'title': '会员专享资源', 'text': '会员独有资源随心看'},
    {'logo': 'vip_icon_quanyi_2', 'title': '购买就打折', 'text': '会员专享资源购买折扣价'},
    {'logo': 'vip_icon_quanyi_3', 'title': '福利社群', 'text': '可加入官方福利社群'},
    {'logo': 'vip_icon_quanyi_4', 'title': '看小说', 'text': '海量小说等你读'},
    {'logo': 'vip_icon_quanyi_5', 'title': '观看漫画', 'text': '色色漫画资源'},
    {'logo': 'vip_icon_quanyi_6', 'title': '看色图', 'text': '会员可看高清大图，还能下载保存哦'},
    {'logo': 'vip_icon_quanyi_7', 'title': '性福约炮', 'text': '会员可使用约炮和裸聊功能'},
    {'logo': 'vip_icon_quanyi_8', 'title': '下载加速', 'text': '会员专用通道高速下载资源'},
    {'logo': 'vip_icon_quanyi_9', 'title': '编辑昵称', 'text': '可修改昵称'},
    {'logo': 'vip_icon_quanyi_10', 'title': '编辑头像', 'text': '可修改头像'},
    {'logo': 'vip_icon_quanyi_11', 'title': '提交建议', 'text': '可在[我的]提交改进建议'},
    {'logo': 'vip_icon_quanyi_12', 'title': '专线客服', 'text': '一对一专线客服服务'}
  ];
  int currentTab = 0;
  String pageStatus = 'loading';
  List products;
  List channel;
  int currentPrice = 0;
  int promoPrice = 0;
  int swiperIndex = 0;
  bool networkErr = false;
  List rightsList = [];

  @override
  void initState() {
    super.initState();
    currentTab = AppGlobal.initVipTab;
    tabController = PageController(initialPage: AppGlobal.initVipTab);
    AppGlobal.initVipTab = 0;
    _initPage();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  _initPage() async {
    try {
      Basic res = await getProductOfVIP(showMore: 1);
      if (res == null) {
        networkErr = true;
        setState(() {});
      }
      if (res.status != 0) {
        CommonUtils.debugPrint(res.data['product']);
        products = List.from(res.data['product']);
        channel = List.from(res.data['channel']);
        if (products.length > 0) {
          var firse = products[0];
          currentPrice = double.parse(firse['promo_price']).toInt();
          promoPrice = double.parse(firse['price']).toInt();
          if (firse['right'] != null) {
            rightsList.addAll(firse['right']);
          }
        }
        setState(() {
          pageStatus = 'ready';
        });
      } else {
        CommonUtils.showText(res.msg);
      }
    } catch (err) {
      setState(() {
        pageStatus = 'error';
      });
    }
  }

  // Widget _vipHead() {
  //   return Container(
  //     height: ScreenUtil().setWidth(44),
  //     width: double.infinity,
  //     child: Stack(
  //       children: [
  //         Center(
  //           child: Text(
  //             'VIP充值',
  //             style: DefaultStyle.white18bold,
  //           ),
  //         ),
  //         Positioned(
  //             top: 0,
  //             bottom: 0,
  //             right: 0,
  //             left: 0,
  //             child: Padding(
  //               padding:
  //                   EdgeInsets.symmetric(horizontal: DefaultStyle.pagePadding),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   GestureDetector(
  //                     onTap: () {
  //                       context.pop();
  //                     },
  //                     child: Image.asset(
  //                       'assets/pengke/backarrow.png',
  //                       width: ScreenUtil().setWidth(20),
  //                       height: ScreenUtil().setWidth(20),
  //                     ),
  //                   ),
  //                   GestureDetector(
  //                     onTap: () {
  //                       context
  //                           .push(CommonUtils.getRealHash('RechargeRecord/1'));
  //                     },
  //                     child: Text(
  //                       '充值记录',
  //                       style: DefaultStyle.white15,
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ))
  //       ],
  //     ),
  //   );
  // }

  Widget _qyItem({String logo, String title, String text}) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ScreenUtil().setWidth(30),
            height: ScreenUtil().setWidth(30),
            child: PlatformAwareNetworkImage(
              nothumb: true,
              url: logo,
              fit: BoxFit.fitHeight,
            ),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(10.5),
          ),
          Container(
            width: ScreenUtil().setWidth(95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                      color: Color(0xff404040),
                      fontSize: ScreenUtil().setSp(13),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: ScreenUtil().setSp(3),
                ),
                Text(title,
                    style: TextStyle(
                      color: Color(0xff979797),
                      fontSize: ScreenUtil().setSp(10),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

  void onIndexChanged(e) {
    swiperIndex = e;
    var firse = products[e];
    currentPrice = double.parse(firse['promo_price']).toInt();
    promoPrice = double.parse(firse['price']).toInt();
    rightsList = firse['right'] != null ? firse['right'] : [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // dynamic bytes;
    // CommonUtils.getRealImage(
    //     url: 'assets/images/pment/vip_btn_bg.png',
    //     imgUrl: bytes,
    //     setUrl: (e) {
    //       if (!mounted) return;
    //       bytes = e;
    //       setState(() {});
    //     });
    double _width = ScreenUtil().screenWidth - 18 * 2;
    return Scaffold(
      // backgroundColor: Color(0xff171222),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _vipHead(),
              PageTitleBar(
                  paddingTop: ScreenUtil().statusBarHeight, title: 'VIP会员'),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(255, 158, 164, 0.25),
                      blurRadius: ScreenUtil().setWidth(5),
                    )
                  ],
                ),
                padding: EdgeInsets.only(
                    left: DefaultStyle.pagePadding,
                    right: DefaultStyle.pagePadding,
                    top: ScreenUtil().setWidth(8),
                    bottom: ScreenUtil().setWidth(10)),
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(11)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: tabList.asMap().keys.map((e) {
                    return GestureDetector(
                      onTap: () {
                        tabController.jumpToPage(e);
                      },
                      child: Container(
                        margin:
                            EdgeInsets.only(right: ScreenUtil().setWidth(32)),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Opacity(
                              opacity: currentTab == e ? 1 : 0,
                              child: Positioned(
                                top: 0,
                                child: Image.asset(
                                  'assets/images/vip_table_active.png',
                                  fit: BoxFit.fitHeight,
                                  height: ScreenUtil().setWidth(7),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(8)),
                              child: Text(
                                tabList[e]['name'],
                                style: currentTab == e
                                    ? DefaultStyle.pink14bold
                                    : DefaultStyle.lgray14Bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              networkErr
                  ? Expanded(
                      child: Container(
                      width: double.infinity,
                      child: PageStatus.noNetWork(onTap: () {
                        networkErr = false;
                        setState(() {});
                        _initPage();
                      }),
                    ))
                  : pageStatus == 'loading'
                      ? PageStatus.loading(true)
                      : pageStatus == 'error'
                          ? PageStatus.noData()
                          : Expanded(
                              child: PageView(
                              controller: tabController,
                              onPageChanged: (e) {
                                currentTab = e;
                                setState(() {});
                              },
                              children: [
                                products.length == 0
                                    ? PageStatus.noData()
                                    : Column(
                                        children: [
                                          Container(
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Container(
                                                  height: ScreenUtil()
                                                      .setWidth(187),
                                                  child: Swiper(
                                                    onIndexChanged:
                                                        onIndexChanged,
                                                    itemCount: products.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return PageViewMixin(
                                                        child: VIPItemContainer(
                                                            product: products
                                                                .elementAt(
                                                                    index),
                                                            currentPrice:
                                                                currentPrice,
                                                            promoPrice:
                                                                promoPrice),
                                                      );
                                                    },
                                                    viewportFraction: 0.8,
                                                    scale: 0.9,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                              height: ScreenUtil().setWidth(80),
                                              width: double.infinity,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: ScreenUtil()
                                                        .setWidth(16)),
                                                child: Image.asset(
                                                  "assets/images/wode/vip_icon_header.png",
                                                  fit: BoxFit.fill,
                                                ),
                                              )),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color.fromRGBO(
                                                        255, 158, 164, 0.25),
                                                    blurRadius: ScreenUtil()
                                                        .setWidth(5),
                                                  )
                                                ],
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft: Radius.circular(
                                                        ScreenUtil()
                                                            .setWidth(10)),
                                                    bottomRight:
                                                        Radius.circular(
                                                            ScreenUtil()
                                                                .setWidth(10))),
                                              ),
                                              padding: EdgeInsets.only(
                                                  top:
                                                      ScreenUtil().setWidth(8)),
                                              margin: EdgeInsets.only(
                                                left: ScreenUtil().setWidth(16),
                                                right:
                                                    ScreenUtil().setWidth(16),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Center(
                                                  child: Wrap(
                                                    spacing: 0,
                                                    runSpacing: ScreenUtil()
                                                        .setWidth(29),
                                                    children: rightsList
                                                        .asMap()
                                                        .keys
                                                        .map((e) => Container(
                                                              width: _width / 2,
                                                              child: Center(
                                                                child: _qyItem(
                                                                    logo: rightsList[
                                                                            e]
                                                                        ['img'],
                                                                    text: rightsList[
                                                                            e][
                                                                        'name'],
                                                                    title: rightsList[
                                                                            e][
                                                                        'desc']),
                                                              ),
                                                            ))
                                                        .toList(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  ScreenUtil().setWidth(17),
                                              vertical:
                                                  ScreenUtil().setWidth(23),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      if (Privilege.isAllowed(
                                                          context,
                                                          RESOURCE_TYPE_SYSTEM,
                                                          PRIVILEGE_TYPE_FEED)) {
                                                        context.push(CommonUtils
                                                            .getRealHash(
                                                                'customerService'));
                                                      } else {
                                                        CommonUtils.showText(
                                                            '哥哥~开启1V1服务需要会员呢！您好像没有哦~');
                                                      }
                                                    },
                                                    child: Container(
                                                        margin: EdgeInsets.only(
                                                          left: ScreenUtil()
                                                              .setWidth(5),
                                                          // right: ScreenUtil()
                                                          //     .setWidth(16),
                                                        ),
                                                        width: ScreenUtil()
                                                            .setWidth(56),
                                                        height: ScreenUtil()
                                                            .setWidth(56),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      255,
                                                                      158,
                                                                      164,
                                                                      0.25),
                                                              blurRadius:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          5),
                                                            )
                                                          ],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          12)),
                                                        ),
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Image.asset(
                                                                  'assets/images/wode/vip_kefu.png',
                                                                  width: ScreenUtil()
                                                                      .setWidth(
                                                                          24),
                                                                  height: ScreenUtil()
                                                                      .setWidth(
                                                                          24),
                                                                  fit: BoxFit
                                                                      .fill),
                                                              Text('客服',
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xffFF84A9),
                                                                      fontSize:
                                                                          ScreenUtil()
                                                                              .setSp(12)))
                                                            ],
                                                          ),
                                                        ))),
                                                GestureDetector(
                                                  onTap: () {
                                                    showPay(
                                                        products[swiperIndex]);
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          50),
                                                                ),
                                                                gradient:
                                                                    DefaultStyle
                                                                        .defaluGrandientLine),
                                                        width: ScreenUtil()
                                                            .setWidth(239),
                                                        height: ScreenUtil()
                                                            .setWidth(40),
                                                        child: Stack(
                                                          clipBehavior:
                                                              Clip.none,
                                                          children: [
                                                            Center(
                                                              child: Text.rich(
                                                                TextSpan(
                                                                    text:
                                                                        '¥$currentPrice',
                                                                    style: DefaultStyle
                                                                        .white18bold,
                                                                    children: [
                                                                      TextSpan(
                                                                          text:
                                                                              '  ¥$promoPrice',
                                                                          style: TextStyle(
                                                                              color: Colors.white54,
                                                                              fontSize: ScreenUtil().setSp(12),
                                                                              decoration: TextDecoration.lineThrough))
                                                                    ]),
                                                              ),
                                                            ),
                                                            Positioned(
                                                                left: 0,
                                                                top: ScreenUtil()
                                                                    .setWidth(
                                                                        -3.5),
                                                                child:
                                                                    PlatformAwareAssetImage(
                                                                  url:
                                                                      'assets/images/pment/icon_youhui.png',
                                                                  width: ScreenUtil()
                                                                      .setWidth(
                                                                          89.5),
                                                                  height: ScreenUtil()
                                                                      .setWidth(
                                                                          19),
                                                                )),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                PageViewMixin(
                                  child: MoreVipContainer(
                                      isShow: currentTab == 1,
                                      showPay: showPay),
                                ),
                                PageViewMixin(
                                  child: MyVip(isShow: currentTab == 2),
                                )
                              ],
                            )),
            ],
          )
        ],
      ),
    );
  }
}

class MyVip extends StatefulWidget {
  MyVip({Key key, this.isShow = false}) : super(key: key);
  final bool isShow;
  @override
  _MyVipState createState() => _MyVipState();
}

class _MyVipState extends State<MyVip> {
  List vipList;
  bool isInitPage = false;
  bool loading = true;
  int limit = 15;
  int page = 1;
  bool isAll = false;
  @override
  void initState() {
    super.initState();
    initpage();
  }

  initpage() {
    if (!isInitPage) {
      isInitPage = true;
      getUserProductList(page: page, limit: limit).then((res) {
        if (res['status'] != 0) {
          List _data = res['data'] == null ? [] : res['data'];
          if (page == 1) {
            vipList = _data;
          } else {
            vipList.addAll(_data);
          }
          isAll = _data.length < limit;
          loading = false;
          setState(() {});
        } else {
          CommonUtils.showText(res['msg']);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant MyVip oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow) {
      initpage();
    }
  }

  Color _vipColors(String pname, int showMore) {
    switch (pname) {
      case "年卡":
        return Color(0xffffe0a3);
        break;
      case "全能年卡":
        return Color(0xffffe0a3);
        break;
      default:
        return showMore == 1 ? Color(0XFF23140d) : Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? PageStatus.loading(true)
        : vipList.length == 0
            ? PageStatus.noData()
            : PullRefreshList(
                onLoading: () {
                  if (isAll) {
                    CommonUtils.showText('已为您加载全部数据哦～');
                  } else {
                    page++;
                    initpage();
                  }
                },
                child: ListView.builder(
                    cacheExtent: ScreenUtil().screenHeight * 5,
                    itemCount: vipList.length,
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(31.5)),
                    itemBuilder: (BuildContext context, int index) => Container(
                          margin: EdgeInsets.only(
                              bottom: ScreenUtil().setWidth(18.5)),
                          child: Stack(
                            children: [
                              Container(
                                width: ScreenUtil().setWidth(300),
                                height: ScreenUtil().setHeight(165),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setWidth(15))),
                              ),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  bottom: 0,
                                  left: 0,
                                  child: PlatformAwareNetworkImage(
                                    nothumb: true,
                                    url: vipList[index]['img'],
                                    fit: BoxFit.fill,
                                  )),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    padding: EdgeInsets.all(
                                        ScreenUtil().setWidth(15)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  vipList[index]['pname'],
                                                  style: TextStyle(
                                                      color: Colors.transparent,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: ScreenUtil()
                                                          .setSp(24)),
                                                ),
                                                Text(
                                                  '剩余时间:' +
                                                      (vipList[index]['expired_time'] ==
                                                                  null ||
                                                              vipList[index][
                                                                      'expired_time'] ==
                                                                  ''
                                                          ? '--'
                                                          : CommonUtils
                                                              .getExpireTime(
                                                                  vipList[index]
                                                                      [
                                                                      'expired_time'],
                                                                  isActivity:
                                                                      false)),
                                                  style: TextStyle(
                                                      color: _vipColors(
                                                          vipList[index]
                                                              ['pname'],
                                                          vipList[index]
                                                              ['show_more']),
                                                      fontSize: ScreenUtil()
                                                          .setSp(12)),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: ScreenUtil().setWidth(18),
                                            ),
                                            Text(
                                              vipList[index]['description'],
                                              style: TextStyle(
                                                  color: _vipColors(
                                                      vipList[index]['pname'],
                                                      vipList[index]
                                                          ['show_more']),
                                                  fontSize:
                                                      ScreenUtil().setSp(13),
                                                  height: 1.2),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        )));
  }
}

class MoreVipContainer extends StatefulWidget {
  final bool isShow;
  final Function showPay;
  MoreVipContainer({Key key, this.isShow = false, this.showPay})
      : super(key: key);

  @override
  _MoreVipContainerState createState() => _MoreVipContainerState();
}

class _MoreVipContainerState extends State<MoreVipContainer> {
  List moreProducts;
  bool isInitPage = false;
  bool loading = true;
  DateTime now = DateTime.now();
  Timer t1;
  @override
  void initState() {
    super.initState();
    t1 = Timer.periodic(new Duration(seconds: 1), (timer) {
      now = DateTime.now();
      setState(() {});
    });
    initpage();
  }

  @override
  void dispose() {
    t1.cancel();
    super.dispose();
  }

  initpage() {
    if (!isInitPage) {
      isInitPage = true;
      getProductOfVIP(showMore: 0).then((res) {
        if (res.status != 0) {
          moreProducts =
              res.data['product'] == null ? [] : List.from(res.data['product']);
          loading = false;
          setState(() {});
        } else {
          CommonUtils.showText(res.msg);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant MoreVipContainer oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow) {
      initpage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? PageStatus.loading(true)
        : moreProducts.length == 0
            ? PageStatus.noData()
            : ListView.builder(
                cacheExtent: ScreenUtil().screenHeight * 5,
                itemCount: moreProducts.length,
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(31.5)),
                itemBuilder: (BuildContext context, int index) =>
                    GestureDetector(
                      onTap: () {
                        widget.showPay(moreProducts[index]);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            bottom: ScreenUtil().setWidth(18.5)),
                        child: Stack(
                          children: [
                            Container(
                              width: ScreenUtil().setWidth(300),
                              height: ScreenUtil().setHeight(165),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil().setWidth(15))),
                            ),
                            Positioned(
                                top: 0,
                                right: 0,
                                bottom: 0,
                                left: 0,
                                child: PlatformAwareNetworkImage(
                                  nothumb: true,
                                  url: moreProducts[index]['img_url'],
                                  fit: BoxFit.fill,
                                )),
                            Positioned(
                                top: 0,
                                right: 0,
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  padding:
                                      EdgeInsets.all(ScreenUtil().setWidth(15)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                moreProducts[index]['pname'],
                                                style: TextStyle(
                                                    color: Colors.transparent,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        ScreenUtil().setSp(24)),
                                              ),
                                              Text(
                                                (moreProducts[index][
                                                                'promo_expire_time'] ==
                                                            null ||
                                                        moreProducts[index][
                                                                'promo_expire_time'] ==
                                                            ''
                                                    ? ''
                                                    : CommonUtils
                                                        .getPromotionCountDownTime(
                                                            now)),
                                                style: DefaultStyle.white13,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setWidth(18),
                                          ),
                                          Text(
                                            moreProducts[index]['description'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    ScreenUtil().setSp(13),
                                                height: 1.2),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '¥${double.parse(moreProducts[index]['promo_price']).toInt()}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    ScreenUtil().setSp(28.8),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: ScreenUtil().setWidth(12.5),
                                          ),
                                          Text(
                                              '¥${double.parse(moreProducts[index]['price']).toInt()}',
                                              style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize:
                                                      ScreenUtil().setSp(19.8),
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      )
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ));
  }
}

class VIPItemContainer extends StatefulWidget {
  final Map product;
  final int currentPrice;
  final int promoPrice;
  VIPItemContainer({Key key, this.product, this.currentPrice, this.promoPrice})
      : super(key: key);

  @override
  _VIPItemContainerState createState() => _VIPItemContainerState();
}

class _VIPItemContainerState extends State<VIPItemContainer> with PayMixin {
  // Color _vipColors(String pname) {
  //   switch (pname) {
  //     case "年卡":
  //       return Color(0xffffe0a3);
  //       break;
  //     case "全能年卡":
  //       return Color(0xffffe0a3);
  //       break;
  //     default:
  //       return Color(0XFF23140d);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: ScreenUtil().setWidth(301),
          height: ScreenUtil().setWidth(172),
          color: Colors.black,
          // child: PlatformAwareNetworkImage(
          //   noVisibilityDetector: true,
          //   url: widget.product['img_url'],
          //   fit: BoxFit.fill,
          // ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(15),
              vertical: ScreenUtil().setWidth(18)),
          width: ScreenUtil().setWidth(301),
          height: ScreenUtil().setWidth(187),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  '${widget.product['valid_date']}天特权时间',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Color(
                          0xffffffff), //_vipColors(widget.product['pname']),
                      fontSize: ScreenUtil().setSp(13)),
                ),
              ),
              SizedBox(
                height: ScreenUtil().setWidth(10),
              ),
              Expanded(
                  child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30)),
                child: Text(
                  '${widget.product['description']}',
                  style: TextStyle(
                      height: 1.5,
                      color: Color(
                          0xffffffff), //_vipColors(widget.product['pname']),
                      fontSize: ScreenUtil().setSp(13)),
                ),
              )),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(),
                  ),
                  // Row(
                  //   mainAxisSize: MainAxisSize.max,
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       '¥${widget.promoPrice}',
                  //       style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: ScreenUtil().setSp(28.8),
                  //           fontWeight: FontWeight.bold),
                  //     ),
                  //     SizedBox(
                  //       width: ScreenUtil().setWidth(12.5),
                  //     ),
                  //     Text('¥${widget.currentPrice}',
                  //         style: TextStyle(
                  //             color: Colors.white54,
                  //             fontSize: ScreenUtil().setSp(19.8),
                  //             decoration: TextDecoration.lineThrough,
                  //             fontWeight: FontWeight.bold))
                  //   ],
                  // )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
