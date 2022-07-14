import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/sharemovie.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

mixin VideoMinxin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
  }

  bool isHorizontal() {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    return sW > sH;
  }

  Widget animatedBox(
      {Widget child,
      int time,
      double left = 0,
      double top = 0,
      double right = 0,
      double bottom = 0,
      double opacity = 1}) {
    return AnimatedPositioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      duration: Duration(milliseconds: time == null ? 300 : time),
      child: AnimatedOpacity(
        opacity: opacity,
        duration: Duration(milliseconds: time == null ? 300 : time),
        child: child,
      ),
    );
  }

  Widget head({bool noBack = false, Widget rightWidget}) {
    return Container(
      height: ScreenUtil().setWidth(44),
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.black38, Colors.black12],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: DefaultStyle.pagePadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            noBack
                ? Container()
                : GestureDetector(
                    onTap: () {
                      SystemChrome.setEnabledSystemUIOverlays(
                          SystemUiOverlay.values);
                      SystemChrome.setPreferredOrientations(
                          [DeviceOrientation.portraitUp]);
                      context.pop();
                    },
                    child: PlatformAwareAssetImage(
                        url: 'assets/images/backarrow.png',
                        width: ScreenUtil().setWidth(12),
                        filterQuality: FilterQuality.medium),
                  ),
            rightWidget != null ? rightWidget : Container()
          ],
        ),
      ),
    );
  }

  Future showBuy(data, Function buyFunction) {
    int money = Provider.of<HomeConfig>(context, listen: false).member.money;
    bool isInsufficient = money < data.discountCoins;
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
                  height: ScreenUtil().setWidth(348) +
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
                            '购买视频',
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
                                                data.discountCoins.toString() +
                                                    '币',
                                                style: TextStyle(
                                                    color: Colors.yellow,
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
                                              ),
                                              data.coins == data.discountCoins
                                                  ? Container()
                                                  : Text(
                                                      data.coins.toString() +
                                                          'G',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0XFFFF5B8C),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          fontSize: ScreenUtil()
                                                              .setSp(16)),
                                                    ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text('购买视频',
                                style: TextStyle(
                                    color: Color(0xff646464),
                                    fontSize: ScreenUtil().setSp(14),
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: ScreenUtil().setSp(8),
                            ),
                            Text(data.title,
                                style: TextStyle(
                                    color: Color(0xff646464),
                                    fontSize: ScreenUtil().setSp(14),
                                    overflow: TextOverflow.ellipsis,
                                    decoration: TextDecoration.none)),
                            Expanded(
                                child: Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(
                                  bottom: ScreenUtil().bottomBarHeight +
                                      ScreenUtil().setWidth(20)),
                              child: isVip
                                  ? GestureDetector(
                                      onTap: () {
                                        if (isInsufficient) {
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
                                            isInsufficient
                                                ? PPString.goldInsufficient
                                                : PPString.buyNow,
                                            style: TextStyle(
                                                color: isInsufficient
                                                    ? Color(0xffff84a9)
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ScreenUtil().setSp(16)),
                                          ),
                                        ),
                                      ))
                                  : Row(
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                          onTap: () {
                                            context.pop();
                                            context.push('/${Routes.vip}');
                                          },
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            ScreenUtil()
                                                                .setWidth(20)),
                                                    gradient: SweepGradient(
                                                        //  begin: Alignment.bottomCenter,
                                                        colors: [
                                                          Color(0XFFff84a9),
                                                          Color(0XFFff9e9e),
                                                        ])),
                                                width: double.infinity,
                                                height:
                                                    ScreenUtil().setWidth(40),
                                                child: Center(
                                                  child: Text(
                                                    '升级会员',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: ScreenUtil()
                                                            .setSp(
                                                                isInsufficient
                                                                    ? 14
                                                                    : 16)),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                  top: ScreenUtil()
                                                      .setWidth(-26.4),
                                                  left: ScreenUtil()
                                                      .setWidth(-12),
                                                  child: PlatformAwareAssetImage(
                                                      url:
                                                          'assets/images/detail/vip_zhekou.png',
                                                      height: ScreenUtil()
                                                          .setWidth(26),
                                                      fit: BoxFit.fitHeight,
                                                      filterQuality:
                                                          FilterQuality.medium))
                                            ],
                                          ),
                                        )),
                                        SizedBox(
                                          width: ScreenUtil().setWidth(15),
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () {
                                                  if (isInsufficient) {
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
                                                  height:
                                                      ScreenUtil().setWidth(40),
                                                  child: Center(
                                                    child: Text(
                                                      isInsufficient
                                                          ? PPString
                                                              .goldInsufficient
                                                          : PPString.buyNow,
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

  Widget coinbuy({dynamic data, Function buyFunction}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
            TextSpan(text: '该视频需要花费', style: DefaultStyle.white15, children: [
          TextSpan(
              text: data.discountCoins.toString() + 'GOLD',
              style: DefaultStyle.red16bold)
        ])),
        GestureDetector(
          onTap: () {
            showBuy(data, buyFunction);
          },
          child: Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(22)),
            height: ScreenUtil().setWidth(32),
            width: ScreenUtil().setWidth(118.5),
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
            child: Center(
              child: Text(
                '继续观看',
                style: DefaultStyle.white12,
              ),
            ),
          ),
        )
      ],
    );
  }

  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  Widget nofree({dynamic data}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ScreenUtil().setWidth(225),
          child: Text(
            '您已经没有播放次数，升级会员即可无限观看海量AV',
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtil().setSp(15),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(20),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                var config =
                    Provider.of<HomeConfig>(context, listen: false).config;
                ShareMovieModel.showShareMovie(backButtonBehavior,
                    copyUrl: config.share.affUrlCopy.url,
                    thumb: data?.coverOriginalHorizontal == ''
                        ? data?.coverOriginalVertical
                        : data?.coverOriginalHorizontal,
                    title: data.title,
                    subtitle: data.desc,
                    url: '${config.share.affUrl}');
              },
              child: Container(
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(26)),
                  width: ScreenUtil().setWidth(119),
                  height: ScreenUtil().setWidth(32),
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(16)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff37f4ff),
                          Color(0xffff6a4a),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                  child: Center(
                    child: Text(
                      '分享无限看',
                      style: DefaultStyle.white12,
                    ),
                  )),
            ),
            GestureDetector(
              onTap: () {
                context.push('/${Routes.vip}');
              },
              child: Container(
                  width: ScreenUtil().setWidth(119),
                  height: ScreenUtil().setWidth(32),
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(16)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff37f4ff),
                          Color(0xffff6a4a),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                  child: Center(
                    child: Text(
                      '立即升级会员',
                      style: DefaultStyle.white12,
                    ),
                  )),
            )
          ],
        )
      ],
    );
  }
}
