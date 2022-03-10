import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/theme/default.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/myinvitation.dart';
import 'package:pilipili/model/myreward.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class InviteFriend extends StatefulWidget {
  InviteFriend({Key key}) : super(key: key);

  @override
  _InviteFriendState createState() => _InviteFriendState();
}

class _InviteFriendState extends State<InviteFriend> {
  ScrollController _scrollController = ScrollController();
  List incomeList = [];
  bool isLoading = true;
  Data myInvition;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        var list2 = [1, 1, 1, 1, 1, 1];
        setState(() {
          incomeList.addAll(list2);
        });
      }
    });
    initData();
  }

  initData() async {
    MyInvitationModel result = await myInvitation();
    MyRewardModel reward = await getMyReward();
    if (result != null && result.data != null) {
      setState(() {
        myInvition = result.data;
        isLoading = false;
      });
    }
    if (reward != null && reward.data != null) {
      setState(() {
        incomeList.addAll(reward.data);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  AppBar appBar = AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
  );

  Widget build(BuildContext context) {
    String channel =
        Provider.of<HomeConfig>(context, listen: false).member.channel;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Color.fromRGBO(255, 94, 67, 1)),
        ),
        channel != 'self'
            ? Container()
            : Container(
                margin: EdgeInsets.only(
                    top: ScreenUtil().statusBarHeight +
                        DefaultStyle.navbarHegiht),
                child: Image.asset(
                  'assets/images/wode/invite_header.png',
                  width: double.infinity,
                  height: ScreenUtil().setWidth(575),
                  fit: BoxFit.fitHeight,
                ),
              ),
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              PageTitleBar(
                  title: '联系官方', paddingTop: ScreenUtil().statusBarHeight),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: ScreenUtil()
                            .setWidth((channel != 'self' ? 163 : 163)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(20)),
                        child: Container(
                          width: double.infinity,
                          height: isLoading
                              ? ScreenUtil().setWidth(250)
                              : ScreenUtil().setWidth(184),
                          padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(16),
                              horizontal: ScreenUtil().setWidth(21)),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ScreenUtil().setWidth(10)),
                              color: Colors.white),
                          child: isLoading
                              ? PageStatus.loading(mounted)
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                          text: '我的邀请',
                                          style: TextStyle(
                                              color: Color(0xff1a1a1a),
                                              fontSize: ScreenUtil().setSp(16),
                                              fontWeight: FontWeight.w400),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: ' 好友绑定手机后，才是有效的注册哦！',
                                                style: TextStyle(
                                                  color: Color(0xff999999),
                                                  fontSize:
                                                      ScreenUtil().setSp(12),
                                                ))
                                          ]),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        MyInviteNumber(
                                            number: '${myInvition?.allNum}',
                                            label: '成功邀请数'),
                                        MyInviteNumber(
                                            number: '${myInvition?.regNum}',
                                            label: '注册用户数'),
                                        MyInviteNumber(
                                            number: '${myInvition?.moneyNum}',
                                            label: '累积收入'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ActionImage(
                                          url:
                                              'assets/images/mine/invite_recore_icon.png',
                                          onTap: () {
                                            context.push(
                                                CommonUtils.getRealHash(
                                                    'inviterecored'));
                                          },
                                        ),
                                        ActionImage(
                                          url:
                                              'assets/images/mine/promote_icon.png',
                                          onTap: () {
                                            context.push(
                                                CommonUtils.getRealHash(
                                                    'promote'));
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(20)),
                        child: Container(
                          width: double.infinity,
                          margin:
                              EdgeInsets.only(top: ScreenUtil().setWidth(24.5)),
                          padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ScreenUtil().setWidth(10)),
                              color: Colors.white),
                          child: isLoading
                              ? PageStatus.loading(mounted)
                              : incomeList.length == 0
                                  ? PageStatus.noData(text: '暂无收益记录')
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            '收益明细',
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(16),
                                                color: Color(0xff1a1a1a)),
                                          ),
                                        ),
                                        ListView.builder(
                                          cacheExtent:
                                              ScreenUtil().screenHeight * 5,
                                          shrinkWrap: true,
                                          physics: BouncingScrollPhysics(),
                                          controller: _scrollController,
                                          itemCount: incomeList.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return IncomeItem(
                                              incomeListItem: incomeList[index],
                                            );
                                          },
                                        )
                                      ],
                                    ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }
}

class IncomeItem extends StatelessWidget {
  final Datum incomeListItem;
  const IncomeItem({Key key, this.incomeListItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12.5)),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 1, color: Color(0xffeeeeee)))),
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${incomeListItem?.nickname}',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(16),
                      color: Color(0xff333333))),
              Text('${incomeListItem?.createdAt}',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(12),
                      color: Color(0xff999999))),
            ],
          )),
          Text('+20G',
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(24), color: Color(0xff333333))),
        ],
      ),
    );
  }
}

class MyInviteNumber extends StatelessWidget {
  final String number;
  final String label;
  const MyInviteNumber({Key key, this.number, this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(number,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(24), color: Color(0xff333333))),
        Text(label,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(11), color: Color(0xff999999))),
      ],
    );
  }
}

class ActionImage extends StatelessWidget {
  final String url;
  final GestureTapCallback onTap;
  const ActionImage({Key key, this.url, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PlatformAwareAssetImage(
          url: url,
          width: ScreenUtil().setWidth(125),
          height: ScreenUtil().setWidth(42)),
    );
  }
}
