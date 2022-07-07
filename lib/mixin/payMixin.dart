import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/components/certificate.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/model/basic.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import "package:universal_html/html.dart" as html;

Map payIcons = {
  'alipay': 'assets/images/pment/a.png',
  'visa': 'assets/images/pment/visa.png',
  'wechat': 'assets/images/pment/w.png',
  'bankcard': 'assets/images/pment/u.png',
  'usdt': 'assets/images/pment/usdt.png',
  'agent': 'assets/images/pment/agent.png',
  'money': 'assets/images/wode/icon_coin.png',
};

mixin PayMixin<T extends StatefulWidget> on State<T> {
  html.WindowBase winRef;
  dynamic origin = html.window.location.origin + '/';
  payErr() {
    YyShowDialog.showdialog(context, title: '提示', btnText: '知道啦',
        content: (setDialogState) {
      return DefaultTextStyle(
          style: DefaultStyle.white14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('支付失败,可能有如下原因,请您稍后再尝试。'),
              SizedBox(
                height: ScreenUtil().setWidth(14),
              ),
              Text('1、当前充值人数过多，充值渠道拥挤。'),
              SizedBox(
                height: ScreenUtil().setWidth(14),
              ),
              Text('2、未支付订单过多，请过段时间再尝试。')
            ],
          ));
    });
  }

  showPay(Map product) {
    int currentPay;
    List pays;
    pays = List.from(product['pay']);
    print("pay--------$pays");

    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            bool isLogin = false;
            if (['', null, false].contains(AppGlobal.apiToken)) {
              isLogin = false;
            } else {
              isLogin = true;
            }
            return Stack(
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Color(0xffFFF4F9),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(ScreenUtil().setWidth(10)),
                        topLeft: Radius.circular(ScreenUtil().setWidth(10))),
                  ),
                  width: double.infinity,
                  height: ScreenUtil().setWidth(470),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                              bottom: ScreenUtil().setWidth(16)),
                          padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(18),
                              horizontal: ScreenUtil().setWidth(20)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight:
                                    Radius.circular(ScreenUtil().setWidth(10)),
                                topLeft:
                                    Radius.circular(ScreenUtil().setWidth(10))),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffFF89AC),
                                Color(0xffFF5B8C),
                                Color(0xffFA437A)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: 0,
                                child: PlatformAwareAssetImage(
                                    url: 'assets/images/detail/icon_close.png',
                                    width: ScreenUtil().setWidth(18),
                                    height: ScreenUtil().setWidth(18),
                                    filterQuality: FilterQuality.medium),
                              ),
                              Text(
                                '选择支付方式',
                                style: DefaultStyle.white18bold,
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.pop();
                                },
                                child: PlatformAwareAssetImage(
                                    url: 'assets/images/detail/icon_close.png',
                                    width: ScreenUtil().setWidth(18),
                                    height: ScreenUtil().setWidth(18),
                                    filterQuality: FilterQuality.medium),
                              )
                            ],
                          )),
                      Center(
                        child: Text.rich(TextSpan(
                            text: '支付金额',
                            style: DefaultStyle.black14,
                            children: [
                              TextSpan(
                                  text: '${product['promo_price']}元',
                                  style: TextStyle(
                                      color: Color(0xffFE155B),
                                      fontSize: ScreenUtil().setSp(14)))
                            ])),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(15)),
                        child: Column(
                          children: pays
                              .asMap()
                              .keys
                              .map((e) => GestureDetector(
                                    onTap: () {
                                      setBottomSheetState(() {
                                        currentPay = e;
                                      });
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: ScreenUtil().setWidth(16)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 40.w,
                                                height: 40.w,
                                                child:
                                                    PlatformAwareNetworkImage(
                                                  url: pays[e]['img_url']
                                                              .indexOf(
                                                                  'http') ==
                                                          -1
                                                      ? AppGlobal
                                                              .bannerImgBase +
                                                          pays[e]['img_url']
                                                      : pays[e]['img_url'],
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              SizedBox(
                                                width: ScreenUtil().setSp(10.5),
                                              ),
                                              Text(
                                                pays[e]['name'],
                                                style: DefaultStyle.black15bold,
                                              )
                                            ],
                                          ),
                                          currentPay == e
                                              ? PlatformAwareAssetImage(
                                                  url:
                                                      'assets/images/wode/icon_choosed.png',
                                                  width: ScreenUtil().setSp(16),
                                                  height:
                                                      ScreenUtil().setSp(16),
                                                  filterQuality:
                                                      FilterQuality.medium)
                                              : Container(
                                                  decoration: BoxDecoration(
                                                      color: Color(0xffFFD1DF),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              ScreenUtil()
                                                                  .setSp(10))),
                                                  width: ScreenUtil().setSp(16),
                                                  height:
                                                      ScreenUtil().setSp(16),
                                                )
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      )),
                      GestureDetector(
                          onTap: () {
                            payMoney() async {
                              if (currentPay == null)
                                return BotToast.showText(text: '请选择支付方式！');
                              PageStatus.showLoading(text: '正在请求支付');
                              if (pays[currentPay]['channel'] == 'money') {
                                try {
                                  Basic res = await onOrderExchange(
                                      product_id: product['id']);
                                  if (res.status == 1) {
                                    getUserInfo(context);
                                    BotToast.showText(text: '兑换会员成功');
                                  } else {
                                    BotToast.showText(text: res.msg);
                                  }
                                } catch (err) {
                                  BotToast.showText(text: '兑换会员失败，请稍后重试');
                                }
                              } else {
                                if (kIsWeb) {
                                  winRef = html.window
                                      .open('${origin}waiting.html', "_blank");
                                }
                                try {
                                  Basic res = await onCreatePaying(
                                      pay_type: 'online',
                                      pay_way: pays[currentPay]['channel'],
                                      product_id: product['id']);
                                  if (kIsWeb) {
                                    PageStatus.closeLoading();
                                    context.pop();
                                  }
                                  if (res.data != null &&
                                      res.data['payUrl'] != null) {
                                    if (kIsWeb) {
                                      winRef.location.href = res.data['payUrl'];
                                    } else {
                                      CommonUtils.launchURL(res.data['payUrl']);
                                    }
                                  } else if (res.msg != null) {
                                    if (kIsWeb) {
                                      winRef.close();
                                      payErr();
                                    }
                                    BotToast.showText(text: res.data['msg']);
                                  } else {
                                    if (kIsWeb) {
                                      winRef.close();
                                      payErr();
                                    }
                                    BotToast.showText(text: '创建订单失败，请稍后重试');
                                  }
                                } catch (err) {
                                  if (kIsWeb) {
                                    winRef.close();
                                    payErr();
                                  }
                                  BotToast.showText(text: '创建订单失败，请稍后重试');
                                }
                              }
                              PageStatus.closeLoading();
                            }

                            if (!isLogin) {
                              var members = Provider.of<HomeConfig>(context,
                                      listen: false)
                                  .member;
                              var config = Provider.of<HomeConfig>(context,
                                      listen: false)
                                  .config;
                              YyShowDialog.showdialog(context,
                                  title: '游客账号',
                                  content: (setDialogState) {
                                    return DefaultTextStyle(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(15),
                                            decoration: TextDecoration.none),
                                        child: Column(
                                          children: [
                                            Text(
                                              '您正在使用游客账号，建议您先登录注册再充值，资金安全有保障',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    51, 51, 51, 1),
                                                fontSize:
                                                    ScreenUtil().setSp(15),
                                              ),
                                            ),
                                            SizedBox(
                                              height: ScreenUtil().setWidth(25),
                                            ),
                                            RichText(
                                              text: TextSpan(children: [
                                                TextSpan(
                                                    text: '您也可以先',
                                                    style:
                                                        DefaultStyle.black13),
                                                WidgetSpan(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      CertificateModel.showCertificate(
                                                          BackButtonBehavior
                                                              .none,
                                                          id:
                                                              '${members?.aff ?? '0000000'}',
                                                          code:
                                                              '${config?.share?.affCode ?? '0000'}',
                                                          url:
                                                              '${config?.share?.affUrl ?? ''}');
                                                    },
                                                    child: Text(
                                                      '保存账号凭证',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xffFE155B),
                                                          fontSize: ScreenUtil()
                                                              .setWidth(15),
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                    ),
                                                  ),
                                                ),
                                                TextSpan(
                                                    text: ', 防止账号丢失',
                                                    style:
                                                        DefaultStyle.black13),
                                              ]),
                                            )
                                          ],
                                        ));
                                  },
                                  btnText: '继续支付',
                                  cancelText: '前往注册',
                                  cancelBack: () {
                                    context.push('/login');
                                  },
                                  callBack: () {
                                    payMoney();
                                  });
                            } else {
                              payMoney();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(25.5),
                                vertical: ScreenUtil().setWidth(25.5)),
                            child: Center(
                              child: Container(
                                width: double.infinity,
                                height: ScreenUtil().setWidth(40),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xffFF84A9),
                                        Color(0xffFF9E9E)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setWidth(20))),
                                child: Center(
                                  child: Text(
                                    '立即支付',
                                    style: DefaultStyle.white15bold,
                                  ),
                                ),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }
}
