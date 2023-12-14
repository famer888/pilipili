import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/updateNum.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_asset_path.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/model/homedata.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/index.dart';

import '../global.dart';
import 'common/pullrefreshlist.dart';

class Wode extends StatefulWidget {
  Wode({Key key}) : super(key: key);
  @override
  _WodeState createState() => _WodeState();
}

class _WodeState extends State<Wode> {
  bool networkErr = false;
  int pageStatus = 0;

  void initState() {
    super.initState();
    pageStatus = 1;
    initInfo();
    EventBus().on('need-update-login-state', (args) {
      if (args == 'login') {
        setState(() {});
      } else if (args == 'quit') {
        getHomeConfig(context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('need-update-login-state');
  }

  // @override
  // void didUpdateWidget(covariant Wode oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.isShow && pageStatus == 0) {
  //     setState(() {
  //       pageStatus = 1;
  //     });
  //     initInfo();
  //   }
  // }

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

  final List menuList = [
    {'name': "观看记录", 'iconUrl': PPAssetsPath.record, 'router': '/watchhistory'},
    {'name': "我购买的", 'iconUrl': PPAssetsPath.buy, "router": '/buy'},
    {'name': "我的收藏", 'iconUrl': PPAssetsPath.collect, "router": '/collect'},
    {'name': "我的下载", 'iconUrl': PPAssetsPath.download, 'router': '/downPage'},
    {
      'name': "在线客服",
      'iconUrl': PPAssetsPath.customer,
      'router': '/onlineService'
    },
    {
      'name': "联系官方",
      'iconUrl': PPAssetsPath.official,
      'router': '/contactOfficial'
    },
    {'name': "邀请好友", 'iconUrl': PPAssetsPath.invite, 'router': '/invitefriend'},
    {
      'name': "应用推荐",
      'iconUrl': PPAssetsPath.appRecommend,
      'router': '/appCenter'
    },
    {
      'name': "我的帖子",
      'iconUrl': 'assets/images/2023/icon_post.png',
      'assets': true,
      'router': '/myPost'
    },
    {
      'name': "我的关注",
      'iconUrl': 'assets/images/2023/icon_myfollow.png',
      'assets': true,
      'router': '/myFollow'
    },
    {
      'name': "申请原创入驻",
      'iconUrl': 'assets/images/2023/icon_myadd.png',
      'assets': true,
      'router': '/novelPage'
    },
  ];

  @override
  Widget build(BuildContext context) {
    Member members = Provider.of<HomeConfig>(context, listen: false).member;
    bool isLogin = false;
    if (['', null, false].contains(AppGlobal.apiToken)) {
      isLogin = false;
    } else {
      isLogin = true;
    }
    return Column(
      children: [
        pageStatus != 2
            ? Container()
            : Header(
                members: members,
                isLogin: isLogin,
                networkErr: networkErr,
              ),
        Expanded(
            child: PullRefreshList(
          onRefresh: () {
            if (networkErr) {
              networkErr = false;
              setState(() {});
            }
            initInfo();
          },
          child: networkErr
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 23.w,
                      ),
                      child: HandleList(
                        menuList: menuList,
                      ),
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
                        CardList(
                          member: members,
                        ),
                        SizedBox(
                          height: 22.h,
                        ),
                        HandleList(
                          menuList: menuList,
                        )
                      ],
                    ),
        ))
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
          context.push('/messagecenter');
        },
        child: PlatformAwareAssetImage(
            url:
                // 'assets/pengke/wode/Chat_Circle_Dots_active.png',
                (state.systemnotice?.data ?? false) != null &&
                        (state.systemnotice.data.systemNoticeCount != 0 ||
                            state.systemnotice.data.feedCount != 0)
                    ? PPAssetsPath.chatCircleDotsActive
                    : PPAssetsPath.chatCircleDots,
            width: 24.w,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.medium),
      );
    });
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeConfig>(builder: (ctx, state, child) {
      return state.member.thumb == null
          ? PlatformAwareAssetImage(
              url: 'assets/images/wode/avatar.png',
              width: 30.w,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium)
          : PlatformAwareNetworkImage(
              width: 30.w,
              fit: BoxFit.cover,
              url: state.member.thumb.toString(),
            );
    });
  }
}

class Header extends StatelessWidget {
  const Header({Key key, this.members, this.isLogin, this.networkErr})
      : super(key: key);
  final Member members;
  final bool isLogin;
  final bool networkErr;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: -10.h,
          child: PlatformAwareAssetImage(
              url: "assets/images/wode/header_bg.png",
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium),
        ),
        Container(
          padding: EdgeInsets.only(
              top: ScreenUtil().statusBarHeight + 10.h,
              left: 18.w,
              right: 16.w,
              bottom: 18.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SystemNoticeIcon(),
                  SizedBox(
                    width: 13.w,
                  ),
                  GestureDetector(
                      onTap: () {
                        context.push('/setup');
                      },
                      child: PlatformAwareAssetImage(
                          url: "assets/images/wode/Settings.png",
                          width: 24.w,
                          fit: BoxFit.fitWidth,
                          filterQuality: FilterQuality.medium)),
                ],
              ),
              networkErr
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(
                        top: 15.w,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            child: Center(
                              child: Container(
                                margin: EdgeInsets.only(right: 8.w),
                                width: 60.w,
                                height: 60.w,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    37.25.w,
                                  ),
                                  child: UserAvatar(),
                                ),
                              ),
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
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(
                                          top: 5.w,
                                          right: 5.w,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w),
                                        height: 20.h,
                                        decoration: new BoxDecoration(
                                          color: Color.fromRGBO(
                                              225, 225, 225, 0.28),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          //设置四周边框
                                        ),
                                        child: Center(
                                          child: Text(
                                            'ID:' +
                                                (members?.aff ?? '0000000')
                                                    .toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
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
                                        context.push('/login');
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            PPString.registerLogin,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          Center(
                                            child: Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                              size: 15.sp,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 28.h,
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

class HandleList extends StatelessWidget {
  const HandleList({Key key, this.menuList}) : super(key: key);
  final List menuList;
  @override
  Widget build(BuildContext context) {
    List<Widget> tempList = [];
    for (var item in menuList) {
      tempList.add(
        GestureDetector(
          onTap: () {
            if (item['router'] != null) {
              context.push(item['router']);
            }
          },
          child: Container(
            width: 1.sw / 4,
            child: Column(
              children: [
                getImage(item['iconUrl'],
                    isAssets: item['assets'] != null,
                    width: 32.w,
                    fit: BoxFit.fitWidth,
                    filterQuality: FilterQuality.medium),
                SizedBox(
                  height: 2.h,
                ),
                Text(
                  item['name'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xff6D6D6D),
                    fontSize: 12.sp,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return Wrap(
      runSpacing: 25.w,
      children: tempList,
    );
  }
}

class CardList extends StatelessWidget {
  const CardList({Key key, this.member}) : super(key: key);
  final Member member;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5.w, right: 10.w),
      padding: EdgeInsets.only(bottom: 14.h),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Color(0xFFFFDCE6)),
        ),
      ),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              context.push('/vip');
            },
            child: Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                PlatformAwareAssetImage(
                    url: "assets/images/wode/vip_bg.png",
                    width: 190.w,
                    // height: ScreenUtil().setWidth(164),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium),
                Positioned(
                  top: 85.w,
                  left: 20.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "VIP充值",
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        "您有" + (member.level ?? 0).toString() + "张会员卡",
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                // Positioned(
                //   bottom: ScreenUtil().setWidth(15),
                //   left: ScreenUtil().setWidth(20),
                //   child: Text(
                //     "立即开通",
                //     style: TextStyle(
                //         fontSize: ScreenUtil().setSp(15),
                //         color: Colors.white,
                //         fontWeight: FontWeight.bold),
                //   ),
                // )
              ],
            ),
          ),
          // SizedBox(
          //   width: ScreenUtil().setWidth(2),
          // ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                SizedBox(
                  height: 19.h,
                ),
                GestureDetector(
                  onTap: () {
                    context.push('/coinRecharge');
                  },
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: <Widget>[
                      PlatformAwareAssetImage(
                          url: "assets/images/wode/glod_bg.png",
                          // height: ScreenUtil().setHeight(68),
                          width: double.infinity,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.medium),
                      Positioned(
                        left: 20.w,
                        top: 15.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "皮哩币",
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "余额:" + (member.money ?? 0).toString(),
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      // Positioned(
                      //   bottom: ScreenUtil().setWidth(6),
                      //   left: ScreenUtil().setWidth(12),
                      //   child: Text(
                      //     "立即充值",
                      //     style: TextStyle(
                      //         fontSize: ScreenUtil().setSp(12),
                      //         color: Colors.white,
                      //         fontWeight: FontWeight.bold),
                      //   ),
                      // )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.push('/invitefriend');
                  },
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: <Widget>[
                      PlatformAwareAssetImage(
                          url: "assets/images/wode/activity_bg.png",
                          width: double.infinity,
                          // height: ScreenUtil().setHeight(68),
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.medium),
                      Positioned(
                        left: 20.w,
                        top: 15.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "领取",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "免费会员",
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    ;
  }
}
