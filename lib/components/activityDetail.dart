import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/sharemovie.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:pilipili/theme/default.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/components/page_status.dart';
import '../utils/api.dart';

class ActivityDetail extends StatefulWidget {
  ActivityDetail({Key key, this.id}) : super(key: key);
  final String id;
  @override
  State<ActivityDetail> createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  bool loading = true;
  dynamic activityInfo;
  @override
  void initState() {
    super.initState();
    getActivityDetail(widget.id).then((res) {
      if (res['status'] != 0) {
        CommonUtils.debugPrint(res['data']);
        activityInfo = res['data'];
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              PageTitleBar(
                  paddingTop: ScreenUtil().statusBarHeight,
                  title: "活动详情",
                  rightWidget: GestureDetector(
                    onTap: () {
                      var config =
                          Provider.of<HomeConfig>(context, listen: false)
                              .config;
                      ShareMovieModel.showShareMovie(backButtonBehavior,
                          copyUrl: config.share.affUrlCopy.url,
                          thumb: activityInfo['resource'][0]['url'],
                          width: activityInfo['resource'][0]['width'] == null
                              ? 1
                              : double.parse(activityInfo['resource'][0]
                                      ['width']
                                  .toString()),
                          height: activityInfo['resource'][0]['height'] == null
                              ? 1
                              : double.parse(activityInfo['resource'][0]
                                      ['height']
                                  .toString()),
                          title: activityInfo['title'] ?? '--',
                          subtitle: activityInfo['desc'] ?? '--',
                          url: '${config.share.affUrl}');
                    },
                    child: Container(
                      child: Image.asset("assets/images/share_white.png",
                          color: Colors.white,
                          width: ScreenUtil().setWidth(20),
                          height: ScreenUtil().setWidth(20)),
                    ),
                  )),
              loading
                  ? PageStatus.loading(true)
                  : Expanded(
                      child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: ScreenUtil().setWidth(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/icon_love_red2.png",
                                  width: ScreenUtil().setWidth(6),
                                  fit: BoxFit.fitWidth,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil().setWidth(6)),
                                  child: Text(
                                    activityInfo['title'],
                                    style: DefaultStyle.black18bold,
                                  ),
                                ),
                                Image.asset(
                                  "assets/images/icon_love_red2.png",
                                  width: ScreenUtil().setWidth(6),
                                  fit: BoxFit.fitWidth,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: ScreenUtil().setWidth(20),
                                left: ScreenUtil().setWidth(20),
                                right: ScreenUtil().setWidth(20)),
                            child: Text(
                              activityInfo['desc'],
                              style: TextStyle(
                                  color: Color(0xff646464),
                                  fontSize: ScreenUtil().setSp(14)),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: activityInfo['resource']
                                .asMap()
                                .keys
                                .map<Widget>((e) => LayoutBuilder(builder:
                                        (BuildContext context,
                                            BoxConstraints box) {
                                      if (e == 0) {
                                        return Container();
                                      }
                                      double _width = activityInfo['resource']
                                                  [e]['width'] ==
                                              null
                                          ? 1
                                          : double.parse(
                                              activityInfo['resource'][e]
                                                      ['width']
                                                  .toString());
                                      double _height = activityInfo['resource']
                                                  [e]['height'] ==
                                              null
                                          ? 1
                                          : double.parse(
                                              activityInfo['resource'][e]
                                                      ['height']
                                                  .toString());
                                      return Container(
                                        margin: EdgeInsets.only(
                                            bottom: ScreenUtil().setWidth(12)),
                                        width: box.maxWidth,
                                        height:
                                            (box.maxWidth / _width) * _height,
                                        child: PlatformAwareNetworkImage(
                                          fit: BoxFit.cover,
                                          url: activityInfo['resource'][e]
                                              ['url'],
                                        ),
                                      );
                                    }))
                                .toList(),
                          ),
                          SizedBox(
                              height: ScreenUtil().setWidth(70) +
                                  ScreenUtil().bottomBarHeight),
                        ],
                      ),
                    ))
            ],
          ),
          activityInfo == null
              ? Container()
              : Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(15),
                        right: ScreenUtil().setWidth(20),
                        left: ScreenUtil().setWidth(20),
                        bottom: ScreenUtil().bottomBarHeight == 0
                            ? ScreenUtil().setWidth(15)
                            : ScreenUtil().bottomBarHeight),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(TextSpan(
                            text: '${activityInfo['join_num']} ',
                            style: TextStyle(
                                color: Color(0xffff5b8c),
                                fontSize: ScreenUtil().setSp(16),
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: '人已参与活动', style: DefaultStyle.black14)
                            ])),
                        activityInfo['status'] != 1
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setWidth(8),
                                    horizontal: ScreenUtil().setWidth(30)),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setWidth(20)),
                                    color: Color(0xffdcdcdc)),
                                child: Text(
                                  '活动已结束',
                                  style: DefaultStyle.white15bold,
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  String linkUrl = activityInfo['link'];
                                  List urlList = linkUrl.split('?');
                                  if (activityInfo['link'].indexOf('http') ==
                                      -1) {
                                    Map<String, dynamic> pramas = {};
                                    if (urlList.length > 1) {
                                      urlList[1].split("&").forEach((item) {
                                        List stringText = item.split('=');
                                        pramas[stringText[0]] =
                                            stringText.length > 1
                                                ? stringText[1]
                                                : null;
                                      });
                                    }
                                    Map<String, dynamic> pramasObj = {};
                                    if (pramas['pramaskey'] != null) {
                                      pramasObj[pramas['pramaskey']] = pramas;
                                    } else {
                                      pramasObj = pramas;
                                    }
                                    context.push(urlList[0].trim(),
                                        extra: pramasObj);
                                  } else {
                                    if (urlList.length > 1 &&
                                        urlList[1].indexOf('userinfo') != -1) {
                                      var members = Provider.of<HomeConfig>(
                                              context,
                                              listen: false)
                                          .member;
                                      var aff = members.aff;
                                      var yyid = members.uuid;
                                      CommonUtils.launchURL(
                                          '${urlList[0]}?aff=$aff&piliid=$yyid');
                                    } else {
                                      CommonUtils.launchURL(
                                          activityInfo['link']);
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: ScreenUtil().setWidth(8),
                                      horizontal: ScreenUtil().setWidth(30)),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          ScreenUtil().setWidth(20)),
                                      gradient: LinearGradient(
                                          colors: [
                                            Color.fromRGBO(255, 174, 198, 1),
                                            Color.fromRGBO(255, 77, 131, 1),
                                            Color.fromRGBO(255, 7, 83, 1)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter)),
                                  child: Text(
                                    '立即参与',
                                    style: DefaultStyle.white15bold,
                                  ),
                                ),
                              )
                      ],
                    ),
                  ))
        ],
      ),
    );
  }
}
