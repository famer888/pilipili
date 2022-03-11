import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/updateNum.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/model/homedata.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/index.dart';

import '../global.dart';
import 'common/pullrefreshlist.dart';

class Wode extends StatefulWidget {
  Wode({Key key, this.isShow = false}) : super(key: key);
  final bool isShow;
  @override
  _WodeState createState() => _WodeState();
}

class _WodeState extends State<Wode> {
  bool networkErr = false;
  int pageStatus = 0;

  void initState() {
    // TODO: implement initState
    super.initState();
    EventBus().on('need-update-login-state', (args) {
      CommonUtils.debugPrint("*********************$args");
      if (args == 'login') {
        setState(() {});
      } else if (args == 'quit') {
        CommonUtils.debugPrint("我执行了");
        getHomeConfig(context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('need-update-login-state');
  }

  @override
  void didUpdateWidget(covariant Wode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && pageStatus == 0) {
      setState(() {
        pageStatus = 1;
      });
      initInfo();
    }
  }

  void initInfo() async {
    UpdateNumModel getUpdateNum = await apiGetUpdateNum();
    if (getUpdateNum == null) {
      CommonUtils.showText('请检查网络后重试～');
      networkErr = true;
      setState(() {});
      return;
    }
    await getHomeConfig(context);
    await CommonUtils.updateSystemNotice(context);
    setState(() {
      pageStatus = 2;
    });
  }

  List MenuList = [
    {'name': "观看记录", 'icon': "record"},
    {'name': "我购买的", 'icon': "buy"},
    {'name': "我的收藏", 'icon': "collect", "router": '/${Routes.collect}'},
    {'name': "我的下载", 'icon': "download", 'router': '/${Routes.down_page}'},
    {'name': "在线客服", 'icon': "customer", 'router': '/${Routes.onlineService}'},
    {
      'name': "联系官方",
      'icon': "official",
      'router': '/${Routes.contactOfficial}'
    },
    {'name': "邀请好友", 'icon': "invite", 'router': '/${Routes.invitefriend}'},
    {'name': "应用推荐", 'icon': "app_recommen"},
  ];

  @override
  Widget build(BuildContext context) {
    Member members = Provider.of<HomeConfig>(context, listen: false).member;
    CommonUtils.debugPrint("******************************${members.username}");
    bool isLogin = false;
    if (['', null, false].contains(AppGlobal.apiToken)) {
      isLogin = false;
    } else {
      isLogin = true;
    }
    return Column(
      children: [
        pageStatus != 2 ? Container() : header(members, isLogin),
        Expanded(
            child: PullRefreshList(
          onLoading: () {
            if (networkErr) {
              networkErr = false;
              setState(() {});
            }
            initInfo();
          },
          onRefresh: () {},
          child: networkErr
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(23),
                      ),
                      child: setHandleList(),
                    ),
                    Center(
                      child: Text(
                        '-请检查网络后下拉刷新-',
                        style: DefaultStyle.red14,
                      ),
                    )
                  ],
                )
              : pageStatus != 2
                  ? pageStatus == 1
                      ? PageStatus.loading(true)
                      : Container()
                  : Column(
                      children: [
                        cardList(),
                        SizedBox(
                          height: ScreenUtil().setHeight(22),
                        ),
                        setHandleList()
                      ],
                    ),
        ))
      ],
    );
  }

  Widget cardList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(14)),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Color(0xFFFFDCE6)),
        ),
      ),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Stack(
            alignment: Alignment.topLeft,
            children: <Widget>[
              Image.asset(
                "assets/images/wode/vip_bg.png",
                width: ScreenUtil().setHeight(156),
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
                GestureDetector(
                  onTap: () {
                    context.push('/${Routes.coinRecharge}');
                  },
                  child: Stack(
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

  Widget setHandleList() {
    Member members = Provider.of<HomeConfig>(context, listen: false).member;
    List<Widget> tempList = [];
    for (var item in MenuList) {
      tempList.add(
        new GestureDetector(
          onTap: () {
            if (item['router'] != null) {
              context.push(item['router']);
            }
          },
          child: Container(
            width: ScreenUtil().screenWidth / 4,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/wode/${item['icon']}.png',
                  fit: BoxFit.fitWidth,
                  width: ScreenUtil().setWidth(25),
                  // height: ScreenUtil().setWidth(45),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(2),
                ),
                Text(
                  item['name'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xff6D6D6D),
                    fontSize: ScreenUtil().setSp(12),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return Wrap(
      spacing: ScreenUtil().setWidth(0),
      runSpacing: ScreenUtil().setWidth(25),
      children: tempList,
    );
  }

  Widget header(Member members, bool isLogin) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: ScreenUtil().setHeight(-10),
          child: Image.asset(
            "assets/images/wode/header_bg.png",
            fit: BoxFit.fill,
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top +
                  ScreenUtil().setHeight(10),
              left: ScreenUtil().setWidth(18),
              right: ScreenUtil().setWidth(16),
              bottom: ScreenUtil().setHeight(18)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // GestureDetector(
                  //   onTap: () {
                  //     context.push('/${Routes.setup}');
                  //   },
                  //   child: Image.asset(
                  //     "assets/images/wode/Chat_Circle_Dots.png",
                  //     width: ScreenUtil().setWidth(24),
                  //     fit: BoxFit.fitWidth,
                  //   ),
                  // ),
                  SystemNoticeIcon(),
                  SizedBox(
                    width: ScreenUtil().setWidth(13),
                  ),
                  GestureDetector(
                      onTap: () {
                        context.push('/${Routes.setup}');
                      },
                      child: Image.asset(
                        "assets/images/wode/Settings.png",
                        width: ScreenUtil().setWidth(24),
                        fit: BoxFit.fitWidth,
                      )),
                ],
              ),
              networkErr
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(
                        top: ScreenUtil().setWidth(15),
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                right: ScreenUtil().setWidth(8)),
                            child: ClipOval(
                              child: Image.asset(
                                  "assets/images/wode/avatar.png",
                                  width: ScreenUtil().setWidth(60)),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  members?.nickname ?? "pilpil用户",
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
                                            horizontal:
                                                ScreenUtil().setWidth(8)),
                                        height: ScreenUtil().setHeight(20),
                                        decoration: new BoxDecoration(
                                          color: Color.fromRGBO(
                                              225, 225, 225, 0.28),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          //设置四周边框
                                        ),
                                        child: Center(
                                          child: Text(
                                            'ID:${members?.aff ?? '0000000'}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    ScreenUtil().setSp(14),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                    Container(
                                        margin: EdgeInsets.only(
                                            top: ScreenUtil().setWidth(5)),
                                        // width: ScreenUtil().setWidth(93),
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                ScreenUtil().setWidth(8)),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          //设置四周边框
                                        ),
                                        child: Center(
                                          child: Text(
                                            "VIP:永久",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    ScreenUtil().setSp(14),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ))
                                  ],
                                )
                              ],
                            ),
                          ),
                          isLogin
                              ? Container()
                              : Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        context.push('/${Routes.login}');
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "注册登录",
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
        )
      ],
    );
  }
}

class SystemNoticeIcon extends StatelessWidget {
  const SystemNoticeIcon({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeConfig>(builder: (ctx, state, child) {
      CommonUtils.debugPrint(state.systemnotice?.data?.systemNoticeCount != 0);
      return GestureDetector(
        onTap: () {
          context.push('/${Routes.messagecenter}');
        },
        child: Image.asset(
          // 'assets/pengke/wode/Chat_Circle_Dots_active.png',
          (state.systemnotice?.data ?? false) != null &&
                  (state.systemnotice.data.systemNoticeCount != 0 ||
                      state.systemnotice.data.feedCount != 0)
              ? 'assets/images/wode/Chat_Circle_Dots_active.png'
              : 'assets/images/wode/Chat_Circle_Dots.png',
          width: ScreenUtil().setWidth(24),
          fit: BoxFit.fitWidth,
        ),
      );
    });
  }
}
