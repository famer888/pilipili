import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/systemnoticelist.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';

class NoticeMessage extends StatefulWidget {
  final Map args;

  NoticeMessage({Key key, this.args}) : super(key: key);

  @override
  _MessageCenterState createState() => _MessageCenterState();
}

class _MessageCenterState extends State<NoticeMessage> {
  int page = 1;
  int limit = 15;
  List messageList = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    initMessageList();
  }

  void initMessageList() async {
    SystemNoticeList result =
        await getSystemNoticeList(page: page, limit: limit);
    if (result?.status == 1) {
      if (page == 1) {
        messageList = result.data;
      } else {
        messageList.addAll(result.data);
      }
      loading = false;
      setState(() {});
    } else {
      CommonUtils.showText(result.msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        PageTitleBar(
          paddingTop: ScreenUtil().statusBarHeight,
          title: widget?.args['title'],
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
          child: loading
              ? PageStatus.loading(true)
              : PullRefreshList(
                  onRefresh: () {
                    page = 1;
                    initMessageList();
                  },
                  onLoading: () {
                    page++;
                    initMessageList();
                  },
                  child: ListView.builder(
                      //     itemCount: 10,
                      //     itemBuilder: (context, index) => NoticeItem(
                      //           title: "123213",
                      //           time: "2017-01-1",
                      //           content: "我是你爹",
                      //         )),

                      itemCount:
                          messageList.length == 0 ? 1 : messageList.length,
                      itemBuilder: (context, index) {
                        if (messageList.length == 0) {
                          return PageStatus.noData(text: '暂无通知消息～');
                        } else {
                          return NoticeItem(
                            title: messageList[index].title,
                            content: messageList[index].content,
                            time: messageList[index].createdAt,
                          );
                        }
                      }),
                ),
        ))
      ],
    ));
  }
}

class NoticeItem extends StatelessWidget {
  final String title;
  final String content;
  final String time;
  const NoticeItem({Key key, this.title, this.content, this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(15),
            right: ScreenUtil().setWidth(15),
            top: ScreenUtil().setWidth(15)),
        child: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  "assets/images/wode/official_avatar.png",
                  width: ScreenUtil().setWidth(40),
                  fit: BoxFit.fill,
                )),
            Positioned(
                top: ScreenUtil().setWidth(8),
                left: ScreenUtil().setWidth(43),
                child: Image.asset(
                  "assets/images/wode/official_message_left.png",
                  width: ScreenUtil().setWidth(13),
                  fit: BoxFit.fill,
                )),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(55)),
                  width: double.infinity,
                  padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: ScreenUtil().setWidth(0.5),
                          color: Colors.white54),
                      color: Color(0xffFFFFFF),
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(5))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: Color(0xff6D6D6D),
                              fontSize: ScreenUtil().setSp(15))),
                      Text(content,
                          style: TextStyle(
                              color: Color(0xff6D6D6D),
                              fontSize: ScreenUtil().setSp(12))),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: SizedBox(
                      width: double.infinity,
                    )),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil().setWidth(10),
                        top: ScreenUtil().setWidth(10),
                        right: ScreenUtil().setWidth(10),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(13),
                            color: Color(0xffd7d7d7)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
