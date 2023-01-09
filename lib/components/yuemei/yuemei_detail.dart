import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
import 'package:pilipili/components/input/InputDailog.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/video/YyVideo.dart';
import 'package:pilipili/components/yuemei/yuemei_score.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:pilipili/utils/privilege.dart';
import 'package:provider/provider.dart';

class YuemeiDetail extends StatefulWidget {
  YuemeiDetail({Key key, this.id}) : super(key: key);
  final int id;
  @override
  _YuemeiDetailState createState() => _YuemeiDetailState();
}

class _YuemeiDetailState extends State<YuemeiDetail> {
  TextEditingController scoreText = TextEditingController();
  ScrollController _scrollController = ScrollController();
  Map girlInfo;
  String scoreString = '';
  bool loading = true;
  bool isListView = true;
  bool networkErr = false;
  bool isAll = false;
  int page = 1;
  List commentList = [];
  int limit = 30;
  bool isFavorites = false;
  bool onFavorites = false; //点击收藏
  int currentIndex = 0;
  int freeCount = 0;
  num money = 0;
  String unlimited = '无限解锁';
  String jstext = '解锁联系方式';
  String ljtext = '立即解锁';
  getPageData() {
    getYuepaoDetail(widget.id).then((res) {
      if (res == null) {
        return CommonUtils.showText('出现错误,请稍后再试');
      }
      if (res['status'] != 0) {
        loading = false;
        girlInfo = res['data'];
        isFavorites = res['data']['userFavorites'] == 1;
        setState(() {});
        getComment();
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  getComment() {
    getYuepaoComment(widget.id, page, limit).then((res) {
      if (res == null) {
        return CommonUtils.showText('获取评价失败');
      }
      if (res['status'] != 0) {
        List _comment = res['data'] == null ? [] : res['data'];
        isAll = _comment.length == 0;
        if (page == 1) {
          commentList = _comment;
        } else {
          commentList.addAll(_comment);
        }
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  showGirlInfo() {
    Map connectMap = {};
    List _connect = girlInfo['phone'].split('|');
    _connect.forEach((item) {
      var _p = item.split(':');
      if (_p.length == 2) {
        connectMap[_p[0]] = _p[1];
      }
    });
    YyShowDialog.showButtom(context,
        title: '联系方式',
        height: 354.w,
        content: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 24.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                width: 311.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.w),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0XFFffd3e6),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: 0)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoItem(title: '解锁信息', text: girlInfo['title']),
                    connectMap.length == 0
                        ? infoItem(title: '联系方式', text: girlInfo['phone'])
                        : Container(),
                    connectMap['wechat'] != null
                        ? infoItem(title: '微信', text: connectMap['wechat'])
                        : Container(),
                    connectMap['qq'] != null
                        ? infoItem(title: 'QQ', text: connectMap['qq'])
                        : Container(),
                    connectMap['phone'] != null
                        ? infoItem(title: '电话', text: connectMap['phone'])
                        : Container(),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 24.w),
                alignment: Alignment.center,
                child: Text(
                  '因行业特殊，联系方式可能更改，请尽快联系对方',
                  style: TextStyle(
                    color: Color(0xfffe155b),
                    fontSize: 12.w,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.w),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(255, 128, 163, 0.5),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0)
                      ],
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            DefaultStyle.linerThemeColor,
                            DefaultStyle.themeColor,
                          ])),
                  width: 327.w,
                  height: 40.w,
                  child: Text(
                    '确定',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget serverItem({String title, String text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 8.w,
          ),
          Text(
            title ?? '',
            style: TextStyle(
                color: Color(0xff6d6d6d),
                fontSize: 14.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 5.w,
          ),
          Flexible(
              child: Text(
            text ?? '--',
            style: TextStyle(
              color: Color(0xff6d6d6d),
              fontSize: 14.sp,
            ),
          )),
        ],
      ),
    );
  }

  publishComment() {
    return YyShowDialog.showdialog(
      context,
      content: (setDialogState) {
        return Text(
          '您已发表过评价了',
          style: TextStyle(
              color: Color(0xff646464),
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(16)),
        );
      },
      btnText: '朕知道了',
    );
  }

  infoItem({String title, String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title + '：',
            style: TextStyle(
                color: Color(0xff6d6d6d),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold),
          ),
          Flexible(
              child: Text(
            text,
            style: TextStyle(color: Color(0xff6d6d6d), fontSize: 16.sp),
          )),
        ],
      ),
    );
  }

  payUnlock() {
    yuepaoUnlock(widget.id).then((res) {
      if (res['status'] != 0) {
        if (freeCount > 0) {
          Map _privilege =
              Provider.of<HomeConfig>(context, listen: false).privilege;
          _privilege['data'][RESOURCE_TYPE_GIRL.toString()]
              [PRIVILEGE_TYPE_UNLOCK.toString()]['value'] = (freeCount - 1);
          Provider.of<HomeConfig>(context, listen: false)
              .setPrivilege(_privilege);
        } else {
          Provider.of<HomeConfig>(context, listen: false)
              .setMoney(money - girlInfo['buy_price']);
        }
        getPageData();
      } else {
        CommonUtils.showText(res['msg']);
      }
      context.pop();
    });
  }

  Future showBuy(Function buyFunction) {
    money = Provider.of<HomeConfig>(context, listen: false).member.money;
    bool isInsufficient = money < girlInfo['buy_price'];
    bool isVip = AppGlobal.vipLevel > 0;
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Stack(
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      color: Color(0xfffff4f9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil().setWidth(12)),
                        topRight: Radius.circular(ScreenUtil().setWidth(12)),
                      )),
                  width: double.infinity,
                  height: ScreenUtil().setWidth(370) +
                      (kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: ScreenUtil().setWidth(64),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                end: Alignment.bottomCenter,
                                begin: Alignment.topCenter,
                                colors: [
                              Color(0XFFFF89AC),
                              Color(0XFFFF5B8C),
                              Color(0XFFFA437A),
                            ])),
                        child: Center(
                          child: Text(
                            '解锁联系方式',
                            style: DefaultStyle.white18bold,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(24)),
                              child: Stack(
                                children: [
                                  Positioned(
                                      top: 0,
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: PlatformAwareAssetImage(
                                          url:
                                              'assets/images/detail/video_buy_bg.png',
                                          fit: BoxFit.fill,
                                          filterQuality: FilterQuality.medium)),
                                  Container(
                                    height: ScreenUtil().setWidth(100),
                                    width: double.infinity,
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right:
                                                    ScreenUtil().setWidth(24)),
                                            child: PlatformAwareAssetImage(
                                                url:
                                                    'assets/images/detail/video_buy_coin.png',
                                                width:
                                                    ScreenUtil().setWidth(64),
                                                filterQuality:
                                                    FilterQuality.medium),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                freeCount > 0
                                                    ? '免费解锁'
                                                    : (girlInfo['buy_price']
                                                            .toString() +
                                                        '币'),
                                                style: TextStyle(
                                                    color: Color(0xffFFCD6B),
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                        offset: Offset(
                                                            ScreenUtil()
                                                                .setWidth(1),
                                                            ScreenUtil()
                                                                .setWidth(1)),
                                                        blurRadius: 3.0,
                                                        color:
                                                            Color(0xffB96A11),
                                                      ),
                                                    ],
                                                    fontSize:
                                                        ScreenUtil().setSp(32),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text('解锁信息',
                                style: TextStyle(
                                    color: Color(0xff646464),
                                    fontSize: ScreenUtil().setSp(14),
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: ScreenUtil().setSp(8),
                            ),
                            Text(girlInfo['title'],
                                style: TextStyle(
                                    color: Color(0xff646464),
                                    fontSize: ScreenUtil().setSp(14),
                                    overflow: TextOverflow.ellipsis,
                                    decoration: TextDecoration.none)),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16.w),
                              alignment: Alignment.center,
                              child: Text(
                                '因行业特殊，联系方式可能更改，请尽快联系对方',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xfffe155b),
                                    fontSize: 12.w),
                              ),
                            ),
                            Expanded(
                                child: Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(
                                  bottom: ScreenUtil().bottomBarHeight +
                                      ScreenUtil().setWidth(20)),
                              child: isVip
                                  ? GestureDetector(
                                      onTap: () {
                                        if (isInsufficient && freeCount <= 0) {
                                          context.pop();
                                          context
                                              .push('/${Routes.coinRecharge}');
                                        } else {
                                          buyFunction();
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil().setWidth(20)),
                                            gradient: SweepGradient(
                                                //  begin: Alignment.bottomCenter,
                                                colors: [
                                                  Color(isInsufficient
                                                      ? 0xffffccdb
                                                      : 0XFFff84a9),
                                                  Color(isInsufficient
                                                      ? 0xffffe4e4
                                                      : 0XFFff9e9e),
                                                ])),
                                        width: double.infinity,
                                        height: ScreenUtil().setWidth(40),
                                        child: Center(
                                          child: Text(
                                            freeCount > 9999
                                                ? unlimited
                                                : (freeCount > 0
                                                    ? '立即免费解锁(剩余$freeCount次)'
                                                    : (isInsufficient
                                                        ? PPString
                                                            .goldInsufficient
                                                        : PPString.buyNow)),
                                            style: TextStyle(
                                                color: isInsufficient
                                                    ? DefaultStyle.themeColor
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ScreenUtil().setSp(16)),
                                          ),
                                        ),
                                      ))
                                  : Row(
                                      children: [
                                        // Expanded(
                                        //     child: GestureDetector(
                                        //   onTap: () {
                                        //     context.pop();
                                        //     context.push('/${Routes.vip}');
                                        //   },
                                        //   child: Stack(
                                        //     clipBehavior: Clip.none,
                                        //     children: [
                                        //       Container(
                                        //         decoration: BoxDecoration(
                                        //             borderRadius:
                                        //                 BorderRadius.circular(
                                        //                     ScreenUtil()
                                        //                         .setWidth(20)),
                                        //             gradient: LinearGradient(
                                        //                 begin:
                                        //                     Alignment.topLeft,
                                        //                 end: Alignment
                                        //                     .bottomRight,
                                        //                 colors: [
                                        //                   Color(0XFFff84a9),
                                        //                   Color(0XFFff9e9e),
                                        //                 ])),
                                        //         width: double.infinity,
                                        //         height:
                                        //             ScreenUtil().setWidth(40),
                                        //         child: Center(
                                        //           child: Text(
                                        //             '升级会员',
                                        //             style: TextStyle(
                                        //                 color: Colors.white,
                                        //                 fontWeight:
                                        //                     FontWeight.bold,
                                        //                 fontSize: ScreenUtil()
                                        //                     .setSp(
                                        //                         isInsufficient
                                        //                             ? 14
                                        //                             : 16)),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //       // Positioned(
                                        //       //     top: ScreenUtil()
                                        //       //         .setWidth(-26.4),
                                        //       //     left: ScreenUtil()
                                        //       //         .setWidth(-12),
                                        //       //     child: PlatformAwareAssetImage(
                                        //       //         url:
                                        //       //             'assets/images/detail/vip_zhekou.png',
                                        //       //         height: ScreenUtil()
                                        //       //             .setWidth(26),
                                        //       //         fit: BoxFit.fitHeight,
                                        //       //         filterQuality:
                                        //       //             FilterQuality.medium))
                                        //     ],
                                        //   ),
                                        // )),
                                        // SizedBox(
                                        //   width: ScreenUtil().setWidth(15),
                                        // ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () {
                                                  if (isInsufficient &&
                                                      freeCount <= 0) {
                                                    context.pop();
                                                    context.push(
                                                        '/${Routes.coinRecharge}');
                                                  } else {
                                                    buyFunction();
                                                  }
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .circular(ScreenUtil()
                                                              .setWidth(20)),
                                                      gradient: LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Color(isInsufficient
                                                                ? 0xffffccdb
                                                                : 0XFFff84a9),
                                                            Color(isInsufficient
                                                                ? 0xffffe4e4
                                                                : 0XFFff9e9e),
                                                          ])),
                                                  width: double.infinity,
                                                  height:
                                                      ScreenUtil().setWidth(40),
                                                  child: Center(
                                                    child: Text(
                                                      freeCount > 9999
                                                          ? unlimited
                                                          : (freeCount > 0
                                                              ? '立即免费解锁(剩余$freeCount次)'
                                                              : (isInsufficient
                                                                  ? PPString
                                                                      .goldInsufficient
                                                                  : PPString
                                                                      .buyNow)),
                                                      style: TextStyle(
                                                          color: isInsufficient
                                                              ? Color(
                                                                  0xffff84a9)
                                                              : Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: ScreenUtil()
                                                              .setSp(
                                                                  isInsufficient
                                                                      ? 14
                                                                      : 16)),
                                                    ),
                                                  ),
                                                )))
                                      ],
                                    ),
                            ))
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                Positioned(
                    top: ScreenUtil().setWidth(19.5),
                    right: ScreenUtil().setWidth(19.5),
                    child: GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: PlatformAwareAssetImage(
                          url: 'assets/images/detail/icon_close.png',
                          width: ScreenUtil().setWidth(24),
                          height: ScreenUtil().setWidth(24),
                          filterQuality: FilterQuality.medium),
                    ))
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    freeCount =
        Privilege.getCount(context, RESOURCE_TYPE_GIRL, PRIVILEGE_TYPE_UNLOCK);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              networkErr
                  ? PageStatus.noNetWork(onTap: () {
                      networkErr = false;
                      setState(() {});
                      getPageData();
                    })
                  : (loading || girlInfo == null
                      ? PageStatus.loading(true)
                      : PullRefreshList(
                          color: Color.fromRGBO(130, 26, 70, 0.44),
                          offset: DefaultStyle.navbarHegiht +
                              ScreenUtil().statusBarHeight,
                          onLoading: () {
                            if (isAll) return;
                            page++;
                            getComment();
                          },
                          child: CustomScrollView(
                            controller: _scrollController,
                            cacheExtent: ScreenUtil().screenHeight * 5,
                            slivers: [
                              SliverAppBar(
                                  backgroundColor: Colors.transparent,
                                  primary: false,
                                  leading: Container(),
                                  pinned: false,
                                  elevation: 0,
                                  forceElevated: true,
                                  expandedHeight: 500.w,
                                  bottom: PreferredSize(
                                    preferredSize: Size(double.infinity,
                                        ScreenUtil().setWidth(24)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(
                                              ScreenUtil().setWidth(15)),
                                          topLeft: Radius.circular(
                                              ScreenUtil().setWidth(15))),
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(255, 244, 249, 1),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                ScreenUtil().setWidth(12)),
                                      ),
                                    ),
                                  ),
                                  flexibleSpace: FlexibleSpaceBar(
                                      collapseMode: CollapseMode.parallax,
                                      background: StatefulBuilder(
                                          builder: (contex, setSwiperState) {
                                        return Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              girlInfo['resource'] == null ||
                                                      girlInfo['resource']
                                                              .length ==
                                                          0
                                                  ? Container(
                                                      height: double.infinity,
                                                      child: PlatformAwareAssetImage(
                                                          url:
                                                              'assets/images/demo_bg.png',
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .medium),
                                                    )
                                                  : Swiper(
                                                      // autoplayDelay: 3000,
                                                      // loop: true,
                                                      // autoplay:
                                                      //     girlInfo['resource']
                                                      //             .length >
                                                      //         1,
                                                      physics: girlInfo[
                                                                      'resource']
                                                                  .length >
                                                              1
                                                          ? null
                                                          : new NeverScrollableScrollPhysics(),
                                                      onIndexChanged: (e) {
                                                        currentIndex = e;
                                                        setSwiperState(() {});
                                                      },
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        List picList = girlInfo[
                                                                'resource']
                                                            .where((item) =>
                                                                item['type'] ==
                                                                1)
                                                            .toList();
                                                        return Container(
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          decoration:
                                                              ShapeDecoration(
                                                                  shape:
                                                                      BeveledRectangleBorder()),
                                                          child: PageViewMixin(
                                                            child: Stack(
                                                              children: [
                                                                Container(
                                                                  height: 500.w,
                                                                ),
                                                                Positioned(
                                                                    top: 0,
                                                                    bottom: 0,
                                                                    right: 0,
                                                                    left: 0,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        child: girlInfo['resource'][index]['type'] ==
                                                                                1
                                                                            ? PlatformAwareNetworkImage(
                                                                                alignment: Alignment.center,
                                                                                noVisibilityDetector: true,
                                                                                url: girlInfo['resource'][index]['url'],
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                            : Center(
                                                                                child: YyVideo(
                                                                                  loop: true,
                                                                                  noBack: true,
                                                                                  videoUrl: girlInfo['resource'][index]['url'],
                                                                                ),
                                                                              ),
                                                                      ),
                                                                    ))
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      itemCount:
                                                          girlInfo['resource']
                                                              .length,
                                                    ),
                                              Positioned(
                                                  right: 12.w,
                                                  bottom: 27.w,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            255, 203, 219, 0.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    15.w)),
                                                    alignment: Alignment.center,
                                                    height: 28.w,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8.w),
                                                    child: Text(
                                                      (currentIndex + 1)
                                                              .toString() +
                                                          '/' +
                                                          girlInfo['resource']
                                                              .length
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14.sp,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ))
                                            ]);
                                      }))),
                              SliverToBoxAdapter(
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 16.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11.w),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color.fromRGBO(
                                              255, 128, 163, 0.5),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                          spreadRadius: 0)
                                    ],
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                      child: Text(
                                                    girlInfo['title'] ?? '',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff6d6d6d),
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                                  SizedBox(
                                                    width: 4.w,
                                                  ),
                                                  girlInfo['buy_count'] !=
                                                              null &&
                                                          girlInfo[
                                                                  'buy_count'] >
                                                              10
                                                      ? PlatformAwareAssetImage(
                                                          url:
                                                              'assets/images/pili_12/yuemei_jingpin.png',
                                                          width: 54.w,
                                                          fit: BoxFit.fitWidth,
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                              SizedBox(height: 8.w),
                                              DefaultTextStyle(
                                                  style: TextStyle(
                                                      color: Color(0xff979797),
                                                      fontSize: 11.sp),
                                                  child: Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          PlatformAwareAssetImage(
                                                            url:
                                                                'assets/images/pili_12/icon_location_red.png',
                                                            width: 18.w,
                                                            fit:
                                                                BoxFit.fitWidth,
                                                          ),
                                                          Text(girlInfo[
                                                                  'cityName'] ??
                                                              '未知')
                                                        ],
                                                      ),
                                                      SizedBox(width: 32.w),
                                                      Row(
                                                        children: [
                                                          PlatformAwareAssetImage(
                                                            url:
                                                                'assets/images/pili_12/icon_lock.png',
                                                            width: 18.w,
                                                            fit:
                                                                BoxFit.fitWidth,
                                                          ),
                                                          Text((girlInfo[
                                                                      'buy_count'] ??
                                                                  '0')
                                                              .toString())
                                                        ],
                                                      )
                                                    ],
                                                  ))
                                            ],
                                          )),
                                          GestureDetector(
                                            onTap: () {
                                              if (onFavorites) return;
                                              onFavorites = true;
                                              userFavorites(
                                                      type: 9, id: widget.id)
                                                  .then((res) {
                                                if (res != null &&
                                                    res.status != 0) {
                                                  isFavorites = !isFavorites;
                                                  setState(() {});
                                                } else {
                                                  CommonUtils.showText(res.msg);
                                                }
                                                onFavorites = false;
                                              });
                                            },
                                            child: Container(
                                              width: 40.w,
                                              height: 40.w,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5.5.w),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.w),
                                                  color: isFavorites
                                                      ? DefaultStyle.themeColor
                                                      : Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 5.0,
                                                      blurStyle:
                                                          BlurStyle.outer,
                                                      color: Color.fromRGBO(
                                                          255, 91, 140, 0.2),
                                                      offset: Offset(0, 3.w),
                                                    )
                                                  ]),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  PlatformAwareAssetImage(
                                                    url:
                                                        'assets/images/detail/' +
                                                            (isFavorites
                                                                ? 'icon_unlike'
                                                                : 'icon_like') +
                                                            '.png',
                                                    width: 12.w,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                  Text(
                                                    isFavorites ? '已收藏' : '收藏',
                                                    style: TextStyle(
                                                        color: isFavorites
                                                            ? Colors.white
                                                            : DefaultStyle
                                                                .themeColor,
                                                        fontSize: 12.sp),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Container(
                                        height: 0.5,
                                        width: double.infinity,
                                        color: Color(0xffffdae4),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 12.w),
                                      ),
                                      serverItem(
                                          title: '服务: ',
                                          text: girlInfo['girl_service_type'] ??
                                              '--'),
                                      serverItem(
                                          title: '资料: ',
                                          text: (girlInfo['girl_age'] ?? '--')
                                                  .toString() +
                                              '岁/' +
                                              (girlInfo['girl_height'] ?? '--')
                                                  .toString() +
                                              'cm/' +
                                              (girlInfo['girl_cup'] ?? '--')
                                                  .toString() +
                                              '杯'),
                                      serverItem(
                                          title: '价格: ',
                                          text: girlInfo['girl_price'] ?? '--'),
                                      serverItem(
                                          title: '简介: ',
                                          text: girlInfo['desc'] ?? '--'),
                                      Stack(
                                        children: [
                                          Positioned(
                                              top: 0,
                                              bottom: 0,
                                              right: 0,
                                              left: 0,
                                              child: PlatformAwareAssetImage(
                                                  url:
                                                      'assets/images/dazhebaobg.png',
                                                  fit: BoxFit.fill,
                                                  filterQuality:
                                                      FilterQuality.medium)),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15.w),
                                            width: double.infinity,
                                            height: 64.w,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                girlInfo['userBuy'] == 0
                                                    ? Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            girlInfo['buy_price']
                                                                    .toString() +
                                                                '皮哩币',
                                                            style: TextStyle(
                                                                height: 1,
                                                                color: Color(
                                                                    0xfffe155b),
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text('解锁联系方式',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffff5b8c),
                                                                  fontSize:
                                                                      14.sp,
                                                                  height: 1,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))
                                                        ],
                                                      )
                                                    : Text('解锁成功!',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xfffe155b),
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (girlInfo['userBuy'] ==
                                                        0) {
                                                      showBuy(payUnlock);
                                                    } else {
                                                      showGirlInfo();
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20.w),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(17.w),
                                                        gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter,
                                                            colors: [
                                                              DefaultStyle
                                                                  .linerThemeColor,
                                                              DefaultStyle
                                                                  .themeColor,
                                                            ])),
                                                    height: 34.w,
                                                    child: Text(
                                                      girlInfo['userBuy'] == 0
                                                          ? (freeCount > 9999
                                                              ? unlimited
                                                              : (freeCount > 0
                                                                  ? '免费解锁(剩余$freeCount次)'
                                                                  : ljtext))
                                                          : '查看联系方式',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.sp),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 24.w),
                                  child: WidgetTitleBar(
                                    title: (girlInfo['comment_count'] ?? '0')
                                            .toString() +
                                        '人评价',
                                    bottom: 12.w,
                                  ),
                                ),
                              ),
                              commentList.length == 0
                                  ? SliverToBoxAdapter(
                                      child: PageStatus.noData(text: '没有找到评价～'),
                                    )
                                  : SliverPadding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 17.w,
                                          horizontal: DefaultStyle.pagePadding),
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.w)),
                                              padding: EdgeInsets.all(16.w),
                                              margin:
                                                  EdgeInsets.only(bottom: 12.5),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.w),
                                                        child: Container(
                                                          width: 40.w,
                                                          height: 40.w,
                                                          child:
                                                              PlatformAwareNetworkImage(
                                                            url: commentList[
                                                                index]['thumb'],
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 8.w,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            commentList[index][
                                                                    'nickname'] ??
                                                                '--',
                                                            style: TextStyle(
                                                                height: 1,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xff646464),
                                                                fontSize: 14.w),
                                                          ),
                                                          SizedBox(
                                                            height: 8.w,
                                                          ),
                                                          Text(
                                                            '体验时间：' +
                                                                    commentList[
                                                                            index]
                                                                        [
                                                                        'updated_at'] ??
                                                                '--',
                                                            style: TextStyle(
                                                                height: 1,
                                                                fontSize: 14.w,
                                                                color: Color(
                                                                    0xff979797)),
                                                          ),
                                                          SizedBox(
                                                            height: 8.w,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '服务 : ',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xffff5b8c),
                                                                    fontSize:
                                                                        14.w),
                                                              ),
                                                              YuemeiScore(
                                                                isSet: false,
                                                                defaultScore:
                                                                    commentList[
                                                                            index]
                                                                        [
                                                                        'service'],
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 8.w,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '颜值 : ',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xffff5b8c),
                                                                    fontSize:
                                                                        14.w),
                                                              ),
                                                              YuemeiScore(
                                                                isSet: false,
                                                                defaultScore:
                                                                    commentList[
                                                                            index]
                                                                        [
                                                                        'face'],
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 12.w),
                                                    width: double.infinity,
                                                    height: 0.5.w,
                                                    color: Color(0XFFffdae4),
                                                  ),
                                                  Text(
                                                    commentList[index]
                                                            ['comment'] ??
                                                        '--',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff6d6d6d),
                                                        fontSize: 14.w),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                          childCount: commentList.length,
                                          addSemanticIndexes: false,
                                          addRepaintBoundaries: true,
                                          addAutomaticKeepAlives: true,
                                        ),
                                      ),
                                    ),
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                          ScreenUtil().bottomBarHeight,
                                ),
                              ),
                            ],
                          ))),
              Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: PageTitleBar(
                      paddingTop: ScreenUtil().statusBarHeight,
                      title: '约妹详情',
                      bgColor: Color.fromRGBO(130, 56, 78, 0.44)))
            ],
          )),
          girlInfo == null
              ? Container()
              : Container(
                  color: Colors.white,
                  height: 48.w + ScreenUtil().bottomBarHeight,
                  padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: ScreenUtil().bottomBarHeight),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      girlInfo['userBuy'] == 0
                          ? Row(
                              children: [
                                PlatformAwareAssetImage(
                                  url:
                                      'assets/images/pili_12/icon_big_lock.png',
                                  width: 16.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                SizedBox(
                                  width: 12.w,
                                ),
                                Text(
                                  '联系方式已隐藏',
                                  style: TextStyle(
                                      color: Color(0xff979797),
                                      fontSize: 14.sp),
                                )
                              ],
                            )
                          : GestureDetector(
                              onTap: () {
                                if (girlInfo['userBuy'] == 2) {
                                  return publishComment();
                                }
                                Map _comment = {};
                                YyShowDialog.showButtom(context,
                                    title: '体验评价', height: 380.w, onClose: () {
                                  scoreString = '';
                                }, content: (setButtom) {
                                  return Container(
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 24.w, bottom: 24.w),
                                          padding: EdgeInsets.only(
                                              left: 16.w,
                                              right: 16.w,
                                              bottom: 16.w,
                                              top: 24.w),
                                          width: 311.w,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.w),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Color(0XFFffd3e6),
                                                    offset: Offset(0, 2),
                                                    blurRadius: 4,
                                                    spreadRadius: 0)
                                              ]),
                                          child: DefaultTextStyle(
                                              style: TextStyle(
                                                  color: Color(0xffff5b8c),
                                                  fontSize: 14.sp),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text('服务 ：'),
                                                      YuemeiScore(
                                                        scoreFunction: (score) {
                                                          _comment['service'] =
                                                              score;
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 16.w,
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text('颜值 ：'),
                                                      YuemeiScore(
                                                        scoreFunction: (score) {
                                                          _comment['face'] =
                                                              score;
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      InputDialog.show(context,
                                                              '可以描述下服务过程（选填）',
                                                              btnText: '完成',
                                                              value:
                                                                  scoreString)
                                                          .then((value) {
                                                        if (value != null &&
                                                            value != '') {
                                                          scoreString = value;
                                                          setButtom(() {});
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                        height: 96.w,
                                                        width: double.infinity,
                                                        margin: EdgeInsets.only(
                                                            top: 16.w),
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                0xFFffe6eb),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: scoreString ==
                                                                    ''
                                                                ? Text(
                                                                    '可以描述下服务过程（选填）',
                                                                    style: TextStyle(
                                                                        fontSize: 14
                                                                            .sp,
                                                                        color: Color(
                                                                            0xff6d6d6d)),
                                                                  )
                                                                : SingleChildScrollView(
                                                                    child: Text(
                                                                      scoreString,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14.w,
                                                                        color: Color(
                                                                            0xfffe155b),
                                                                      ),
                                                                    ),
                                                                  ))),
                                                  )
                                                ],
                                              )),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (_comment['face'] == null ||
                                                _comment['service'] == null) {
                                              return CommonUtils.showText(
                                                  '请对本次体验进行评分');
                                            }
                                            yuepaoComment(
                                                    girlMeetId: girlInfo['id'],
                                                    comment: scoreString,
                                                    face: _comment['face'],
                                                    service:
                                                        _comment['service'])
                                                .then((res) {
                                              if (res['status'] != 0) {
                                                getPageData();
                                                CommonUtils.showText('发表评价成功');
                                              } else {
                                                CommonUtils.showText(
                                                    res['msg']);
                                              }
                                            });
                                            context.pop();
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.w),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Color.fromRGBO(
                                                          255, 128, 163, 0.5),
                                                      offset: Offset(0, 2),
                                                      blurRadius: 4,
                                                      spreadRadius: 0)
                                                ],
                                                gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      DefaultStyle
                                                          .linerThemeColor,
                                                      DefaultStyle.themeColor,
                                                    ])),
                                            width: 327.w,
                                            height: 40.w,
                                            child: Text(
                                              '发表评价',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setWidth(15)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color.fromRGBO(
                                              255, 128, 163, 0.3),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                          spreadRadius: 0)
                                    ],
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xffffe4e4),
                                          Color(0xffffccdb),
                                        ])),
                                width: 102.w,
                                height: 30.w,
                                child: Text(
                                  '体验评价', //查看联系方式
                                  style: TextStyle(
                                      color: DefaultStyle.themeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp),
                                ),
                              ),
                            ),
                      GestureDetector(
                        onTap: () {
                          if (girlInfo['userBuy'] == 0) {
                            showBuy(payUnlock);
                          } else {
                            showGirlInfo();
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ScreenUtil().setWidth(15)),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(255, 128, 163, 0.5),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0)
                              ],
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    DefaultStyle.linerThemeColor,
                                    DefaultStyle.themeColor,
                                  ])),
                          height: 30.w,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            girlInfo['userBuy'] == 0
                                ? freeCount > 9999
                                    ? unlimited
                                    : (freeCount > 0
                                        ? '免费解锁(剩余$freeCount次)'
                                        : jstext)
                                : '查看联系方式', //查看联系方式
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp),
                          ),
                        ),
                      )
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
