import 'package:flutter/material.dart';

import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/model/basic.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:pilipili/mixin/payMixin.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/routers.dart';

class Coinrecharge extends StatefulWidget {
  const Coinrecharge({Key key}) : super(key: key);

  @override
  _CoinrechargeState createState() => _CoinrechargeState();
}

class _CoinrechargeState extends State<Coinrecharge> with PayMixin {
  String pageStatus = 'loading';
  Map spcard;
  List products;
  Map cardStatus;
  bool networkErr = false;
  @override
  void initState() {
    super.initState();
    _initPage();
    getUserInfo(context);
  }

  getCardStatus() {
    getProductOfGold(5).then((product) {
      if (product.status != 0) {
        if (product.data['product'] != null &&
            product.data['product'].length > 0) {
          spcard = product.data['product'][0];
          getCoinCardStatus().then((res) {
            if (res['status'] != 0) {
              cardStatus = res['data'];
              setState(() {});
            } else {
              CommonUtils.showText(res['msg']);
            }
          });
        }
      } else {
        CommonUtils.showText(product.msg);
      }
    });
  }

  _initPage() async {
    Basic res = await getProductOfGold(2);
    if (res == null) {
      networkErr = true;
      setState(() {});
      return;
    }
    if (res.status != 0) {
      products = List.from(res.data['product']);
      pageStatus = 'ready';
      setState(() {});
      getCardStatus();
    } else {
      CommonUtils.showText(res.msg);
    }
  }

  Widget balancePart() {
    int money = Provider.of<HomeConfig>(context).member.money ?? 0;
    return Container(
      width: ScreenUtil().screenWidth - DefaultStyle.pagePadding * 2,
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Color(0xFFFFD1DF), width: 0.4))),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Positioned(
              bottom: 0,
              child: Container(
                width: ScreenUtil().screenWidth - DefaultStyle.pagePadding * 2,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(255, 128, 163, 0.15),
                          offset: Offset(0, 2),
                          blurRadius: 8,
                          spreadRadius: 0)
                    ],
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(10)))),
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/images/wode/balance_bg.png",
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    Positioned(
                        top: 0,
                        bottom: 0,
                        left: ScreenUtil().setWidth(24),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '皮哩币余额',
                                style: TextStyle(
                                    color: Color(0xff979797),
                                    fontSize: ScreenUtil().setSp(14)),
                              ),
                              Text(money.toString(),
                                  style: TextStyle(
                                      color: Color(0xffFE155B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(30),
                                      fontFamily: 'NumberFont')),
                            ],
                          ),
                        ))
                  ],
                ),
              )),
          Image.asset(
            "assets/images/wode/balance_tag.png",
            height: ScreenUtil().setWidth(
                (ScreenUtil().screenWidth - DefaultStyle.pagePadding * 2) *
                    (300 / 1029) *
                    1.39),
            fit: BoxFit.fitHeight,
          ),
          Positioned(
              right: ScreenUtil().setWidth(16),
              bottom: ScreenUtil().setWidth(16),
              child: GestureDetector(
                onTap: () {
                  context.push(CommonUtils.getRealHash('coinDetail'));
                },
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Color(0xffFF9E9E),
                            Color(0xffFF84A9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(20))),
                  padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(4),
                      horizontal: ScreenUtil().setWidth(16)),
                  child: Text(
                    '皮哩币明细',
                    style: DefaultStyle.white15,
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget rechargePart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(13)),
          child: Text(
            '充值皮哩币',
            style: TextStyle(
                color: Color(0xff404040),
                fontSize: ScreenUtil().setSp(23),
                fontWeight: FontWeight.bold),
          ),
        ),
        spcard == null
            ? Container()
            : GestureDetector(
                onTap: () {
                  showPay(spcard);
                },
                child: Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(255, 211, 230, 1),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0)
                      ],
                      borderRadius: BorderRadius.all(
                          Radius.circular(ScreenUtil().setWidth(10)))),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/wode/product_bg_special.png',
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          left: 0,
                          child: Container(
                            padding: EdgeInsets.only(
                                left: DefaultStyle.pagePadding,
                                right: DefaultStyle.pagePadding,
                                top: cardStatus != null &&
                                        cardStatus['isBuy'] == 1
                                    ? ScreenUtil().setWidth(14)
                                    : ScreenUtil().setWidth(14),
                                bottom: ScreenUtil().setWidth(8)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          spcard['pname'],
                                          style: TextStyle(
                                              color: Color(0xff6D3B03),
                                              fontWeight: FontWeight.bold,
                                              height: 1,
                                              fontSize: ScreenUtil().setSp(18)),
                                        ),
                                        SizedBox(
                                          height: ScreenUtil().setWidth(3),
                                        ),
                                        Text(
                                          cardStatus != null &&
                                                  cardStatus['isBuy'] == 1
                                              ? '已领取${cardStatus['days']}天,获得${cardStatus['coins']}币'
                                              : "每人限购一次",
                                          style: TextStyle(
                                              color: Color(0xffA08A72),
                                              fontSize: ScreenUtil().setSp(13)),
                                        )
                                      ],
                                    ),
                                    cardStatus != null &&
                                            cardStatus['isBuy'] == 1
                                        ? Container()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: ScreenUtil()
                                                            .setWidth(4),
                                                        right: ScreenUtil()
                                                            .setWidth(4)),
                                                    child: Image.asset(
                                                      "assets/images/wode/icon_coin.png",
                                                      width: ScreenUtil()
                                                          .setWidth(24),
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  ),
                                                  Text(
                                                    '3000币',
                                                    style: TextStyle(
                                                        shadows: [
                                                          BoxShadow(
                                                              color: Color(
                                                                  0xffB96A11),
                                                              offset:
                                                                  Offset(1, 1),
                                                              blurRadius: 0,
                                                              spreadRadius: 0)
                                                        ],
                                                        color:
                                                            Color(0xffFFCD6B),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: ScreenUtil()
                                                            .setSp(24),
                                                        height: 1,
                                                        fontFamily:
                                                            'NumberFont'),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height:
                                                    ScreenUtil().setWidth(4),
                                              ),
                                              Text(
                                                '¥${double.parse(spcard['promo_price']).toStringAsFixed(0)}',
                                                style: TextStyle(
                                                    color: Color(0xff6D3B03),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        ScreenUtil().setSp(20),
                                                    height: 1,
                                                    fontFamily: 'NumberFont'),
                                              )
                                            ],
                                          ),
                                  ],
                                ),
                                Text(
                                  cardStatus != null && cardStatus['isBuy'] == 1
                                      ? "到期时间：${cardStatus['valid_date']}"
                                      : spcard['description'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffB96A11),
                                      fontSize: ScreenUtil().setSp(12)),
                                )
                              ],
                            ),
                          )),
                      cardStatus != null && cardStatus['isBuy'] == 1
                          ? Positioned(
                              top: ScreenUtil().setWidth(16),
                              right: ScreenUtil().setWidth(16),
                              bottom: ScreenUtil().setWidth(16),
                              child: GestureDetector(
                                onTap: () {
                                  if (cardStatus['isGet'] == 1) {
                                    return;
                                  }
                                  getCoinFromCoinCard().then((res) {
                                    if (res['status'] != 0) {
                                      getUserInfo(context);
                                      getCoinCardStatus().then((cardstatus) {
                                        if (cardstatus['status'] != 0) {
                                          CommonUtils.debugPrint(spcard);
                                          cardStatus = cardstatus['data'];
                                          setState(() {});
                                        } else {
                                          CommonUtils.showText(
                                              cardstatus['msg']);
                                        }
                                      });
                                      CommonUtils.showText('购买成功～');
                                    } else {
                                      CommonUtils.showText(res['msg']);
                                    }
                                  });
                                },
                                child: Container(
                                  width: (ScreenUtil().screenWidth -
                                              DefaultStyle.pagePadding * 2) *
                                          (327 / 1032) -
                                      ScreenUtil().setWidth(26),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: cardStatus['isGet'] == 1
                                              ? [
                                                  Color.fromRGBO(
                                                      194, 194, 194, 0.5),
                                                  Color.fromRGBO(
                                                      194, 194, 194, 0.5),
                                                ]
                                              : [
                                                  Color(0xffFF9E9E),
                                                  Color(0xffFF84A9),
                                                ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter),
                                      boxShadow: cardStatus['isGet'] == 1
                                          ? [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      78, 78, 78, 0.26),
                                                  offset: Offset(0, 2),
                                                  blurRadius: 3,
                                                  spreadRadius: 0)
                                            ]
                                          : [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      255, 194, 194, 0.4),
                                                  offset: Offset(2, 2),
                                                  blurRadius: 6,
                                                  spreadRadius: 0),
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      149, 0, 0, 0.1),
                                                  offset: Offset(-4, -4),
                                                  blurRadius: 7,
                                                  spreadRadius: 0)
                                            ],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              ScreenUtil().setWidth(10)))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        cardStatus['isGet'] == 1
                                            ? "今日"
                                            : '${spcard['coins']}币',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(20),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NumberFont'),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setWidth(5),
                                      ),
                                      Text(
                                        cardStatus['isGet'] == 1
                                            ? "已领取"
                                            : '立即领取',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(12),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          : Container()
                    ],
                  ),
                ),
              ),
        products == null || products.length == 0
            ? PageStatus.noData()
            : Padding(
                padding: EdgeInsets.only(
                    top: ScreenUtil().setWidth(8),
                    bottom: ScreenUtil().setWidth(16)),
                child: Wrap(
                  spacing: ScreenUtil().setWidth(8),
                  runSpacing: ScreenUtil().setWidth(8),
                  children: products.map((e) => productItem(e)).toList(),
                ),
              )
      ],
    );
  }

  Widget productItem(Map product) {
    double _width = (ScreenUtil().screenWidth -
            DefaultStyle.pagePadding * 2 -
            ScreenUtil().setWidth(16)) /
        3;
    List<Widget> textList = [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: ScreenUtil().setWidth(4)),
            child: Image.asset(
              "assets/images/wode/icon_coin.png",
              width: ScreenUtil().setWidth(20),
              fit: BoxFit.fitWidth,
            ),
          ),
          Text(
            product['pname'],
            style: TextStyle(
                shadows: [
                  BoxShadow(
                      color: Color(0xffB96A11),
                      offset: Offset(1, 1),
                      blurRadius: 0,
                      spreadRadius: 0)
                ],
                color: Color(0xffFFCD6B),
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setSp(20),
                fontFamily: 'NumberFont'),
          )
        ],
      ),
      Text(
        '¥${double.parse(product['promo_price']).toStringAsFixed(2)}',
        style: TextStyle(
            color: Color(0xff6D3B03),
            fontWeight: FontWeight.bold,
            fontSize: ScreenUtil().setSp(20),
            fontFamily: 'NumberFont'),
      ),
    ];
    if (product['free_coins'] != 0) {
      textList.add(Text(
        '额外送${product['free_coins'].toString()}币',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xffB96A11),
            fontSize: ScreenUtil().setSp(12),
            fontFamily: 'NumberFont'),
      ));
    }
    return GestureDetector(
      onTap: () {
        showPay(product);
      },
      child: Container(
        width: _width,
        height: _width * 0.85,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(255, 211, 230, 1),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0)
            ],
            borderRadius:
                BorderRadius.all(Radius.circular(ScreenUtil().setWidth(10)))),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/wode/product_bg.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                top: ScreenUtil().setWidth(8),
                bottom: ScreenUtil().setWidth(8),
                right: 0,
                left: 0,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: textList,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget footer() {
    return Container(
      margin: EdgeInsets.only(
          bottom: ScreenUtil().bottomBarHeight, top: ScreenUtil().setWidth(0)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10))),
      child: Image.network(
        "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg",
        width: double.infinity,
        height: ScreenUtil().setWidth(126),
        fit: BoxFit.cover,
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
              title: '皮哩币充值',
              rightWidget: GestureDetector(
                child: Text(
                  '充值记录',
                  style: DefaultStyle.white13,
                ),
              )),
          Expanded(
              child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: DefaultStyle.pagePadding),
            child: networkErr
                ? Container(
                    width: double.infinity,
                    child: PageStatus.noNetWork(onTap: () {
                      networkErr = false;
                      setState(() {});
                      _initPage();
                    }),
                  )
                : pageStatus == 'loading'
                    ? PageStatus.loading(mounted)
                    : Column(
                        children: [balancePart(), rechargePart(), footer()],
                      ),
          ))
        ],
      ),
    );
  }
}
