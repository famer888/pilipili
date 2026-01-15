import 'dart:async';
import 'package:pilipili/store/search.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/pages/home.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';

class Welcome extends StatefulWidget {
  Welcome({Key key}) : super(key: key);
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  Map yyads;
  int curTime = 6;
  Timer _timer;
  int currenIndex = 0;
  toHome() async {
    currenIndex = 1;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    CommonUtils.checkline(onFailed: () {
      BotToast.showText(
          text: '无法连接服务器，请检查手机网络设置',
          textStyle: TextStyle(fontSize: ScreenUtil().setWidth(15), color: Colors.white),
          align: Alignment(0, 0),
          duration: new Duration(seconds: 5));
    }, onSuccess: () {
      getHomeConfig(context).then((res) {
        // toInvitation(affCode: "aqw92");
        if (res?.data?.ads != null && res?.data?.ads?.imgUrl != null) {
          yyads = {'img': res?.data?.ads?.imgUrl, 'url': res.data.ads.url};
          setState(() {});
          adsCountDown();
        }
        if (yyads == null) {
          toHome();
        }
      });
      context.read<Search>().init();
    });
  }

  void adsCountDown() {
    if (yyads == null) return;
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (curTime <= 0) {
        _timer.cancel();
        toHome();
        return;
      }
      setState(() {
        curTime--;
      });
    });
  }

  DateTime lastPopTime;
  @override
  Widget build(BuildContext context) {
    AppGlobal.appContext = context;
    return WillPopScope(
        onWillPop: () async {
          // 点击返回键的操作
          if (lastPopTime == null || DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
            lastPopTime = DateTime.now();
            BotToast.showText(text: '再按一下退出Pilipili～', align: Alignment(0, 0));
          } else {
            lastPopTime = DateTime.now();
            // 退出app
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
          return;
        },
        child: Scaffold(
          body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus.unfocus();
              }
            },
            behavior: HitTestBehavior.translucent,
            child: IndexedStack(
              index: currenIndex,
              children: [
                yyads != null
                    ? Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (yyads['url'] == '' || yyads['url'] == null) return;
                              CommonUtils.launchURL(yyads['url']);
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: PlatformAwareNetworkImage(
                                url: yyads['img'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: (kIsWeb ? 0 : ScreenUtil().statusBarHeight) + ScreenUtil().setWidth(10),
                            right: ScreenUtil().setWidth(15),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(5), horizontal: ScreenUtil().setWidth(15)),
                              height: ScreenUtil().setWidth(35),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 0, 0, .5),
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(35)),
                              ),
                              child: Center(
                                child: Text(
                                  '广告倒计时: ' + curTime.toString(),
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: ScreenUtil().setSp(15),
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: [
                            Color(0xfffbe7ef),
                            Color(0xffddf4fc),
                            Color(0xfffbe7ef),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [Text('正在检测线路,请稍后～', style: DefaultStyle.black15bold)],
                          ),
                        ),
                      ),
                currenIndex != 1 ? Container() : Home()
              ],
            ),
          ),
        ));
  }
}
