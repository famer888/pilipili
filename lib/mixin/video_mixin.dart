import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/sharemovie.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

mixin VideoMinxin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
  }

  double setVideoWidth(value) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    // if (sW > sH) {
    //   return ScreenUtil().setWidth(value * (sH / sW));
    // } else {
    //   return ScreenUtil().setWidth(value);
    // }
       return ScreenUtil().setWidth(value);
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
      height: setVideoWidth(44),
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
                    child: Image.asset(
                      'assets/pengke/backarrow.png',
                      width: setVideoWidth(22),
                      fit: BoxFit.fitWidth,
                    ),
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
                Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/pengke/bottomsheet_bg.png',
                      fit: BoxFit.fill,
                    )),
                Container(
                  width: double.infinity,
                  height: setVideoWidth(221) +
                      (kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                            top: setVideoWidth(24.5),
                            bottom: setVideoWidth(19.5)),
                        child: Center(
                          child: Text(
                            '购买视频',
                            style: DefaultStyle.white18bold,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Column(
                        children: [
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${data.discountCoins}G',
                                  style: TextStyle(
                                      color: Color(0XFF62f7ff),
                                      fontSize: ScreenUtil().setSp(24),
                                      fontWeight: FontWeight.bold),
                                ),
                                data.coins == data.discountCoins
                                    ? Container()
                                    : Text(
                                        '${data.coins}G',
                                        style: TextStyle(
                                            color: Color(0XFF6a6a6a),
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: ScreenUtil().setSp(14)),
                                      ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: setVideoWidth(30)),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('购买视频',
                                    style: TextStyle(
                                        color: Color(0xffd7d7d7),
                                        fontSize: ScreenUtil().setSp(14),
                                        decoration: TextDecoration.none)),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: setVideoWidth(20)),
                                    child: Text(data.title,
                                        style: TextStyle(
                                            color: Color(0xffd7d7d7),
                                            fontSize: ScreenUtil().setSp(14),
                                            overflow: TextOverflow.ellipsis,
                                            decoration: TextDecoration.none)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isVip
                              ? GestureDetector(
                                  onTap: () {
                                    if (isInsufficient) {
                                      context.pop();
                                      // context.push('/${Routes.coinRecharge}');
                                    } else {
                                      buyFunction();
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned(
                                          top: 0,
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Image.asset(
                                            'assets/pengke/video/video_chang_btn.png',
                                            fit: BoxFit.fill,
                                          )),
                                      Container(
                                        width: double.infinity,
                                        height: setVideoWidth(34),
                                        child: Center(
                                          child: Text(
                                            isInsufficient
                                                ? 'GOLD不足，前往充值'
                                                : '立即购买',
                                            style: DefaultStyle.zhuti12,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        context.pop();
                                        // context.push('/${Routes.vip}');
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Stack(
                                            children: [
                                              Positioned(
                                                  top: 0,
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: Image.asset(
                                                    'assets/pengke/video/video_duan_btn.png',
                                                    fit: BoxFit.fill,
                                                  )),
                                              Container(
                                                width: double.infinity,
                                                height: setVideoWidth(34),
                                                child: Center(
                                                  child: Text(
                                                    '升级会员',
                                                    style: DefaultStyle.zhuti12,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          Positioned(
                                              top: setVideoWidth(-7),
                                              left: setVideoWidth(0),
                                              child: PlatformAwareAssetImage(
                                                url:
                                                    'assets/images/vie_zhekou.png',
                                                height: setVideoWidth(15),
                                                fit: BoxFit.fitHeight,
                                              ))
                                        ],
                                      ),
                                    )),
                                    SizedBox(
                                      width: setVideoWidth(15),
                                    ),
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        if (isInsufficient) {
                                          context.pop();
                                          // context
                                              // .push('/${Routes.coinRecharge}');
                                        } else {
                                          buyFunction();
                                        }
                                      },
                                      child: Stack(
                                        children: [
                                          Positioned(
                                              top: 0,
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Image.asset(
                                                'assets/pengke/video/video_chang_btn.png',
                                                fit: BoxFit.fill,
                                              )),
                                          Container(
                                            width: double.infinity,
                                            height: setVideoWidth(34),
                                            child: Center(
                                              child: Text(
                                                isInsufficient
                                                    ? 'GOLD不足，前往充值'
                                                    : '立即购买',
                                                style: DefaultStyle.zhuti12,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ))
                                  ],
                                )
                        ],
                      )),
                    ],
                  ),
                ),
                Positioned(
                    top: setVideoWidth(19.5),
                    right: setVideoWidth(19.5),
                    child: GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: PlatformAwareAssetImage(
                        url: 'assets/images/pment/icon_close.png',
                        width: setVideoWidth(14),
                        height: setVideoWidth(14),
                      ),
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
        Text.rich(TextSpan(
            text: '该视频需要花费',
            style: DefaultStyle.white15,
            children: [
              TextSpan(
                  text: '${data.discountCoins}GOLD',
                  style: DefaultStyle.red16bold)
            ])),
        GestureDetector(
          onTap: () {
            showBuy(data, buyFunction);
          },
          child: Container(
            margin: EdgeInsets.only(top: setVideoWidth(22)),
            height: setVideoWidth(32),
            width: setVideoWidth(118.5),
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(setVideoWidth(16))),
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
          width: setVideoWidth(225),
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
          height: setVideoWidth(20),
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
                    thumb: data.coverThumbHorizontal,
                    title: data.title,
                    subtitle: data.desc,
                    url: '${config.share.affUrl}');
              },
              child: Container(
                  margin: EdgeInsets.only(right: setVideoWidth(26)),
                  width: setVideoWidth(119),
                  height: setVideoWidth(32),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(setVideoWidth(16)),
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
                // context.push('/${Routes.vip}');
              },
              child: Container(
                  width: setVideoWidth(119),
                  height: setVideoWidth(32),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(setVideoWidth(16)),
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
