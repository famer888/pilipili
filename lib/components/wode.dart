import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:youyutv/components/common/pullrefreshlist.dart';
import 'package:youyutv/components/page_status.dart';
import 'package:youyutv/global.dart';
import 'package:youyutv/model/homedata.dart';
import 'package:youyutv/routers.dart';
import 'package:youyutv/store/homeConfig.dart';
import 'package:youyutv/theme/default.dart';
import 'package:youyutv/utils/index.dart';
import 'package:youyutv/utils/networkImage.dart';

class Wode extends StatefulWidget {
  Wode({Key key, this.isShow = false}) : super(key: key);
  final bool isShow;
  @override
  _WodeState createState() => _WodeState();
}

class _WodeState extends State<Wode> {
  int pageStatus = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    EventBus().off('need-update-login-state');
  }

  @override
  void didUpdateWidget(covariant Wode oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && pageStatus == 0) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_header(), _cardList()],
    );
  }

  Widget _cardList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Stack(
            alignment: Alignment.topLeft,
            children: <Widget>[
              Image.asset(
                "assets/images/wode/vip_bg.png",
                width: ScreenUtil().setHeight(158),
                fit: BoxFit.fill,
              ),
              Positioned(
                top: ScreenUtil().setHeight(62),
                left: ScreenUtil().setWidth(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "xx会员",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(18),
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(5),
                    ),
                    Text(
                      "您有3张会员卡",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(14),
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: ScreenUtil().setHeight(12),
                left: ScreenUtil().setWidth(14),
                child: Text(
                  "立即开通",
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(14),
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                SizedBox(
                  height: ScreenUtil().setHeight(13),
                ),
                Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    Image.asset(
                      "assets/images/wode/glod_bg.png",
                      fit: BoxFit.fill,
                    ),
                    Positioned(
                      left: ScreenUtil().setWidth(14),
                      top: ScreenUtil().setHeight(13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "皮哩币",
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(13),
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "余额:300",
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(11),
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: ScreenUtil().setHeight(5),
                      left: ScreenUtil().setWidth(12),
                      child: Text(
                        "立即充值",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(12),
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    Image.asset(
                      "assets/images/wode/activity_bg.png",
                      fit: BoxFit.fill,
                    ),
                    Positioned(
                      left: ScreenUtil().setWidth(14),
                      top: ScreenUtil().setHeight(11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "领取",
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(12),
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "免费会员",
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(13),
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: ScreenUtil().setHeight(5),
                      left: ScreenUtil().setWidth(12),
                      child: Text(
                        "立即充值",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(12),
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.only(
          top: ScreenUtil().setWidth(10),
          left: ScreenUtil().setWidth(18),
          right: ScreenUtil().setWidth(16),
          bottom: ScreenUtil().setWidth(18)),
      // height: ScreenUtil().setHeight(120),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/wode/header_bg.png"),
              fit: BoxFit.fill)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                "assets/images/wode/Chat_Circle_Dots.png",
                width: ScreenUtil().setWidth(24),
                fit: BoxFit.fitWidth,
              ),
              SizedBox(
                width: ScreenUtil().setWidth(13),
              ),
              Image.asset(
                "assets/images/wode/Settings.png",
                width: ScreenUtil().setWidth(24),
                fit: BoxFit.fitWidth,
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(15),
            ),
            child: Row(
              children: [
                Container(
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
                    width: ScreenUtil().setWidth(60),
                    height: ScreenUtil().setHeight(60),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage('assets/images/wode/avatr.jpg'),
                            fit: BoxFit.cover))),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "名字最长20个字",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(18),
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                              margin: EdgeInsets.only(
                                top: ScreenUtil().setWidth(5),
                                right: ScreenUtil().setWidth(5),
                              ),
                              // width: ScreenUtil().setWidth(93),
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(8)),
                              height: ScreenUtil().setHeight(20),
                              decoration: new BoxDecoration(
                                color: Color.fromRGBO(225, 225, 225, 0.28),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                //设置四周边框
                              ),
                              child: Center(
                                child: Text(
                                  "1231232",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(14),
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                          Container(
                              margin: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(5)),
                              // width: ScreenUtil().setWidth(93),
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(8)),
                              height: ScreenUtil().setHeight(20),
                              decoration: new BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFFD875),
                                    Color(0xFFFF6915)
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                //设置四周边框
                              ),
                              child: Center(
                                child: Text(
                                  "VIP:永久",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(14),
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                        ],
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "注册登陆",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(12),
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: ScreenUtil().setSp(15),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(28),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
