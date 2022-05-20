import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';

import '../../utils/api.dart';
import '../../utils/common.dart';

class YouxuanCard extends StatefulWidget {
  YouxuanCard({Key key, this.isHorizontal = true, this.data}) : super(key: key);
  final bool isHorizontal;
  final dynamic data;
  @override
  _YouxuanCardState createState() => _YouxuanCardState();
}

class _YouxuanCardState extends State<YouxuanCard> {
  bool isBuy = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isBuy = widget.data['userBuy'] == 1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isBuy) return;
        context.push(
            '/packageDetail/${widget.data['id']}/${widget.data['type']}/${widget.data['title']}');
      },
      child: Container(
          margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(23)),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(11))),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(15.5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.data['title'],
                        style: TextStyle(
                            color: Color(0xff646464),
                            fontSize: ScreenUtil().setSp(16),
                            fontWeight: FontWeight.bold),
                      ),
                      Text('总视频：${widget.data['total_num']}部',
                          style: TextStyle(
                              color: Color(0XFFFE155B),
                              fontSize: ScreenUtil().setSp(12)))
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(11.5),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(15.5)),
                    child: Text(widget.data['desc'],
                        style: TextStyle(
                          color: Color(0xff646464),
                          fontSize: ScreenUtil().setSp(14),
                        ))),
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(18),
                      bottom: ScreenUtil().setWidth(22),
                      left: ScreenUtil().setWidth(15.5)),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.data['resource']
                        .asMap()
                        .keys
                        .map<Widget>((e) => GestureDetector(
                              onTap: () {
                                if (widget.data['resource'][e]['isfree'] == 0 ||
                                    isBuy) {
                                  if (!widget.isHorizontal) {
                                    AppGlobal.currentDetailRouteExtra = {
                                      'videoData': widget.data['resource'][e]
                                    };
                                    context.push(CommonUtils.getRealHash(kIsWeb
                                        ? 'webSmallVideo/0'
                                        : 'smallVideo/0'));
                                  } else {
                                    context.push(CommonUtils.getRealHash(
                                        'videoDetail/${widget.data['resource'][e]['id']}'));
                                  }
                                } else {
                                  CommonUtils.showText('购买打折包礼包后即可观看哦～');
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: ScreenUtil().setWidth(5)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil().setWidth(5)),
                                  child: Container(
                                    width: ScreenUtil().setWidth(
                                        widget.isHorizontal ? 140 : 100.5),
                                    height: ScreenUtil().setWidth(
                                        widget.isHorizontal ? 80 : 141.5),
                                    child: Stack(
                                      children: [
                                        PlatformAwareNetworkImage(
                                          url: CommonUtils.getThumb(
                                              widget.data['resource'][e]),
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                            left: 0,
                                            top: 0,
                                            child: widget.data['resource'][e]
                                                            ['isfree'] ==
                                                        0 &&
                                                    !isBuy
                                                ? Container(
                                                    height: ScreenUtil()
                                                        .setWidth(18),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(
                                                            bottomRight:
                                                                Radius.circular(
                                                                    ScreenUtil()
                                                                        .setWidth(
                                                                            5))),
                                                        color:
                                                            Color(0xffff6a4a)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                ScreenUtil()
                                                                    .setWidth(
                                                                        10)),
                                                    child: Text(
                                                      '试看',
                                                      style:
                                                          DefaultStyle.white12,
                                                    ),
                                                  )
                                                : Container())
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(13)),
                  child: isBuy
                      ? Center(
                          child: GestureDetector(
                              onTap: () {
                                context.push(
                                    '/packageDetail/${widget.data['id']}/${widget.data['type']}/${widget.data['title']}');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setWidth(16)),
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xffFF9E9E),
                                          Color(0xffFF84A9),
                                        ])),
                                height: ScreenUtil().setWidth(32),
                                width: ScreenUtil().setWidth(96),
                                child: Center(
                                  child: Text(
                                    '查看合集',
                                    style: DefaultStyle.white12,
                                  ),
                                ),
                              )),
                        )
                      : Stack(
                          children: [
                            Positioned(
                                top: 0,
                                bottom: 0,
                                right: 0,
                                left: 0,
                                child: Image.asset(
                                  'assets/images/dazhebaobg.png',
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.high
                                )),
                            Container(
                              height: ScreenUtil().setWidth(64),
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(32)),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(TextSpan(
                                          text: '折扣价: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xffFE004C),
                                              fontSize: ScreenUtil().setSp(12)),
                                          children: [
                                            TextSpan(
                                              text: '${widget.data['price']}币',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(20)),
                                            ),
                                          ])),
                                      Text(
                                        ' 原价：${widget.data['original_price']}币',
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Color(0xffFE004C),
                                            fontSize: ScreenUtil().setSp(12)),
                                      )
                                    ],
                                  )),
                                  GestureDetector(
                                      onTap: () {
                                        YyShowDialog.showdialog(context,
                                            btnText: '立即购买',
                                            cancelText: '一会再买', callBack: () {
                                          buyPackage(id: widget.data['id'])
                                              .then((res) {
                                            if (res['status'] != 0) {
                                              CommonUtils.showText('购买成功～');
                                              isBuy = true;
                                              setState(() {});
                                            } else {
                                              CommonUtils.showText(res['msg']);
                                            }
                                          });
                                        }, content: (setDialogState) {
                                          return DefaultTextStyle(
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(14),
                                                  color: Color(0xff646464)),
                                              child: Column(
                                                children: [
                                                  Text.rich(TextSpan(children: [
                                                    TextSpan(
                                                      text: '您将支付',
                                                    ),
                                                    TextSpan(
                                                        text:
                                                            '${widget.data['price']}币',
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(16),
                                                          color:
                                                              Color(0xffFF5B8C),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    TextSpan(
                                                      text: '购买',
                                                    ),
                                                  ])),
                                                  Text.rich(TextSpan(children: [
                                                    TextSpan(text: '【'),
                                                    TextSpan(
                                                        text: widget
                                                            .data['title'],
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(16),
                                                          color:
                                                              Color(0xffFF5B8C),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    TextSpan(text: '】'),
                                                  ]))
                                                ],
                                              ));
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil().setWidth(16)),
                                            gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(0xffFF9E9E),
                                                  Color(0xffFF84A9),
                                                ])),
                                        height: ScreenUtil().setWidth(32),
                                        width: ScreenUtil().setWidth(96),
                                        child: Center(
                                          child: Text(
                                            '立即购买合集',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ScreenUtil().setSp(12)),
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                )
              ],
            ),
          )),
    );
  }
}
