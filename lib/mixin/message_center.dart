import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/privilege.dart';

class MessageCenter extends StatefulWidget {
  MessageCenter({Key key}) : super(key: key);

  @override
  _MessageCenterState createState() => _MessageCenterState();
}

class _MessageCenterState extends State<MessageCenter> {
  @override
  void initState() {
    super.initState();
    CommonUtils.updateSystemNotice(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '消息中心',
          ),
          Expanded(
              child: ListView(
            padding: const EdgeInsets.all(1),
            children: [MessageOfSystem(), MessageOfNotice()],
          ))
        ],
      )),
    );
  }
}

class MessageOfSystem extends StatelessWidget {
  const MessageOfSystem({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeConfig>(builder: (ctx, state, child) {
      var times;
      var messages = '暂无消息';
      var noticeCount = 0;
      if (state.systemnotice?.data?.systemNotice != null) {
        times = state.systemnotice.data.systemNotice.createdAt;
        messages = state.systemnotice.data.systemNotice.content == null
            ? '暂无消息'
            : state.systemnotice.data.systemNotice.content;
        noticeCount = state.systemnotice.data.systemNoticeCount;
      }

      return MessageActionItem(
        title: '【通知消息】',
        message: '$messages',
        icon: 'assets/images/wode/official_avatar.png',
        time: times != null ? '$times' : ' ',
        number: '$noticeCount',
        onTap: () {
          context.push(CommonUtils.getRealHash('noticemessage'),
              extra: {'title': '通知消息', 'type': 1});
        },
      );
    });
  }
}

class MessageOfNotice extends StatelessWidget {
  const MessageOfNotice({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeConfig>(builder: (ctx, state, child) {
      var times;
      var messages = '暂无消息';
      var noticeCount = 0;
      if (state.systemnotice?.data?.feed != null) {
        times = state.systemnotice.data.feed.createdAt is String
            ? state.systemnotice.data.feed.createdAt
            : CommonUtils.getHMTime(
                int.parse(state.systemnotice.data.feed.createdAt));
        messages = state.systemnotice.data.feed.question;
        noticeCount = state.systemnotice.data.feedCount;
      }
      return MessageActionItem(
        title: '【客服回复】',
        message: '$messages',
        icon: 'assets/images/wode/customer_avatar.png',
        time: times != null ? '$times' : ' ',
        number: '$noticeCount',
        onTap: () {
          if (Privilege.isAllowed(
              context, RESOURCE_TYPE_SYSTEM, PRIVILEGE_TYPE_FEED)) {
            context.push(CommonUtils.getRealHash('customerService'));
          } else {
            YyShowDialog.showdialog(
              context,
              content: (setDialogState) {
                return Text(
                  '哥哥~开启1V1服务需要会员呢！您好像没有哦~',
                  style: TextStyle(
                      color: Color(0xff646464),
                      fontSize: ScreenUtil().setSp(16),
                      fontWeight: FontWeight.bold),
                );
              },
              cancelText: '取消',
              btnText: '立即升级',
              callBack: () {
                context.push('/${Routes.vip}');
              },
            );
            return;
          }
        },
      );
    });
  }
}

class MessageActionItem extends StatelessWidget {
  final String title;
  final String icon;
  final String message;
  final String time;
  final String number;
  final Function onTap;
  const MessageActionItem(
      {Key key,
      this.title,
      this.icon,
      this.message,
      this.time,
      this.number,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(15)),
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                  width: ScreenUtil().setWidth(0.5),
                  color: Color.fromRGBO(238, 238, 238, 0.3)),
            )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  icon,
                  width: ScreenUtil().setWidth(50),
                  height: ScreenUtil().setWidth(50),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(15),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            color: Color(0xFF404040),
                            fontSize: ScreenUtil().setSp(15),
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(9),
                      ),
                      Text(
                        '  $message',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Color(0xFF979797),
                            fontSize: ScreenUtil().setSp(13)),
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                          color: Color(0xFF979797),
                          fontSize: ScreenUtil().setSp(12)),
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(15),
                    ),
                    Opacity(
                      opacity: number == '0' ? 0 : 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(1),
                            horizontal: ScreenUtil().setWidth(8)),
                        decoration: BoxDecoration(
                            color: Color(0xfffFE155B),
                            borderRadius: BorderRadius.circular(
                                ScreenUtil().setWidth(7.5))),
                        child: Text(
                          number,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(12)),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
