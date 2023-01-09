import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/input/InputDailog.dart';
import 'package:pilipili/components/yuemei/yuemei_score.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class YuemeiCard extends StatefulWidget {
  YuemeiCard(
      {Key key,
      this.isShowInfo = true,
      this.w,
      this.h,
      this.data,
      this.isBuy = false})
      : super(key: key);
  final bool isShowInfo;
  final double w;
  final double h;
  Map data;
  final bool isBuy;
  @override
  _YuemeiCardState createState() => _YuemeiCardState();
}

class _YuemeiCardState extends State<YuemeiCard> {
  String scoreString = '';
  Widget yuepaoCard({double h, double w}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
            right: -4.w,
            top: 0,
            child: PlatformAwareAssetImage(
              url: 'assets/images/pili_12/yuemei_red.png',
              width: 65.w,
              fit: BoxFit.fitWidth,
            )),
        Container(
          height: h ?? 140.w,
          width: w ?? 118.w,
          decoration: BoxDecoration(
            color: Color(0xffffebd3),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(255, 128, 163, 0.5),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0)
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(78.w),
                bottomRight: Radius.circular(10.w),
                bottomLeft: Radius.circular(38.w)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsets.all(1.8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.w),
                  topRight: Radius.circular(78.w),
                  bottomRight: Radius.circular(10.w),
                  bottomLeft: Radius.circular(38.w)),
              child: PlatformAwareNetworkImage(
                url: widget.data['cover'],
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ],
    );
  }

  publishComment() {
    return YyShowDialog.showdialog(
      context,
      content: (setDialogState) {
        return Text(
          '您已发表过评价了',
          style: TextStyle(
              color: Color(0xff646464),
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(16)),
        );
      },
      btnText: '朕知道了',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(CommonUtils.getRealHash(
            'yuemeiDetail/' + widget.data['id'].toString()));
      },
      child: !widget.isShowInfo
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                yuepaoCard(h: widget.h ?? 145.w, w: widget.w ?? 118.w),
                Positioned(
                    bottom: 0,
                    right: -4.w,
                    child: widget.data['buy_count'] != null &&
                            widget.data['buy_count'] > 10
                        ? PlatformAwareAssetImage(
                            url: 'assets/images/pili_12/yuemei_jingpin.png',
                            width: 54.w,
                            fit: BoxFit.fitWidth,
                          )
                        : Container())
              ],
            )
          : Padding(
              padding: EdgeInsets.only(bottom: 10.w),
              child: Row(
                children: [
                  yuepaoCard(h: widget.h ?? 145.w, w: widget.w ?? 118.w),
                  Expanded(
                      child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.only(top: 20.w, left: 1.w, right: 4.w),
                        decoration: BoxDecoration(
                          color: Color(0xffffebd3),
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(255, 128, 163, 0.5),
                                offset: Offset(0, 2),
                                blurRadius: 3,
                                spreadRadius: 0)
                          ],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.w),
                            bottomRight: Radius.circular(10.w),
                          ),
                        ),
                        height: 112.w,
                        width: double.infinity,
                        padding:
                            EdgeInsets.only(right: 2.w, top: 2.w, bottom: 2.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.w),
                              bottomRight: Radius.circular(10.w),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.data['title'].toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Color(0xff6d6d6d), fontSize: 14.sp),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 4.w),
                                child: Text(
                                  (widget.data['girl_age'] ?? '- -')
                                          .toString() +
                                      '岁/' +
                                      (widget.data['girl_height'] ?? '- -')
                                          .toString() +
                                      'cm/' +
                                      (widget.data['girl_cup'] ?? '- -')
                                          .toString() +
                                      '杯',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xffff5b8c),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              Text(widget.data['girl_tags'].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xff979797),
                                    fontSize: 11.sp,
                                  )),
                              Expanded(child: Container()),
                              widget.isBuy && widget.data['is_comment'] == 0
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(),
                                        GestureDetector(
                                          onTap: () {
                                            if (widget.data['is_comment'] !=
                                                0) {
                                              return publishComment();
                                            }
                                            Map _comment = {};
                                            YyShowDialog.showButtom(context,
                                                title: '体验评价',
                                                height: 380.w, onClose: () {
                                              scoreString = '';
                                            }, content: (setButtom) {
                                              return Container(
                                                width: double.infinity,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 24.w,
                                                          bottom: 24.w),
                                                      padding: EdgeInsets.only(
                                                          left: 16.w,
                                                          right: 16.w,
                                                          bottom: 16.w,
                                                          top: 24.w),
                                                      width: 311.w,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.w),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Color(
                                                                    0XFFffd3e6),
                                                                offset: Offset(
                                                                    0, 2),
                                                                blurRadius: 4,
                                                                spreadRadius: 0)
                                                          ]),
                                                      child: DefaultTextStyle(
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffff5b8c),
                                                              fontSize: 14.sp),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text('服务 ：'),
                                                                  YuemeiScore(
                                                                    scoreFunction:
                                                                        (score) {
                                                                      _comment[
                                                                              'service'] =
                                                                          score;
                                                                    },
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 16.w,
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text('颜值 ：'),
                                                                  YuemeiScore(
                                                                    scoreFunction:
                                                                        (score) {
                                                                      _comment[
                                                                              'face'] =
                                                                          score;
                                                                    },
                                                                  )
                                                                ],
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  InputDialog.show(
                                                                          context,
                                                                          '可以描述下服务过程（选填）',
                                                                          btnText:
                                                                              '完成',
                                                                          value:
                                                                              scoreString)
                                                                      .then(
                                                                          (value) {
                                                                    if (value !=
                                                                            null &&
                                                                        value !=
                                                                            '') {
                                                                      scoreString =
                                                                          value;
                                                                      setButtom(
                                                                          () {});
                                                                    }
                                                                  });
                                                                },
                                                                child: Container(
                                                                    height: 96.w,
                                                                    width: double.infinity,
                                                                    margin: EdgeInsets.only(top: 16.w),
                                                                    decoration: BoxDecoration(color: Color(0xFFffe6eb), borderRadius: BorderRadius.circular(10)),
                                                                    child: Padding(
                                                                        padding: EdgeInsets.all(8.0),
                                                                        child: scoreString == ''
                                                                            ? Text(
                                                                                '可以描述下服务过程（选填）',
                                                                                style: TextStyle(fontSize: 14.sp, color: Color(0xff6d6d6d)),
                                                                              )
                                                                            : SingleChildScrollView(
                                                                                child: Text(
                                                                                  scoreString,
                                                                                  style: TextStyle(
                                                                                    fontSize: 14.w,
                                                                                    color: Color(0xfffe155b),
                                                                                  ),
                                                                                ),
                                                                              ))),
                                                              )
                                                            ],
                                                          )),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (_comment['face'] ==
                                                                null ||
                                                            _comment[
                                                                    'service'] ==
                                                                null) {
                                                          return CommonUtils
                                                              .showText(
                                                                  '请对本次体验进行评分');
                                                        }
                                                        yuepaoComment(
                                                                girlMeetId:
                                                                    widget.data[
                                                                        'id'],
                                                                comment:
                                                                    scoreString,
                                                                face: _comment[
                                                                    'face'],
                                                                service: _comment[
                                                                    'service'])
                                                            .then((res) {
                                                          if (res['status'] !=
                                                              0) {
                                                            widget.data[
                                                                'is_comment'] = 1;
                                                            setState(() {});
                                                            CommonUtils
                                                                .showText(
                                                                    '发表评价成功');
                                                          } else {
                                                            CommonUtils
                                                                .showText(
                                                                    res['msg']);
                                                          }
                                                        });
                                                        context.pop();
                                                      },
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(20
                                                                            .w),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Color.fromRGBO(
                                                                          255,
                                                                          128,
                                                                          163,
                                                                          0.5),
                                                                      offset:
                                                                          Offset(0,
                                                                              2),
                                                                      blurRadius:
                                                                          4,
                                                                      spreadRadius:
                                                                          0)
                                                                ],
                                                                gradient: LinearGradient(
                                                                    begin: Alignment
                                                                        .topCenter,
                                                                    end: Alignment
                                                                        .bottomCenter,
                                                                    colors: [
                                                                      Color(
                                                                          0xffFF9E9E),
                                                                      Color(
                                                                          0xffFF84A9),
                                                                    ])),
                                                        width: 327.w,
                                                        height: 40.w,
                                                        child: Text(
                                                          '发表评价',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16.sp),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        ScreenUtil()
                                                            .setWidth(12)),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Color.fromRGBO(
                                                          255, 128, 163, 0.3),
                                                      offset: Offset(0, 2),
                                                      blurRadius: 4,
                                                      spreadRadius: 0)
                                                ],
                                                gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Color(0xffffe4e4),
                                                      Color(0xffffccdb),
                                                    ])),
                                            width: 90.w,
                                            height: 25.w,
                                            child: Text(
                                              '体验评价', //查看联系方式
                                              style: TextStyle(
                                                  color:
                                                      DefaultStyle.themeColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.sp),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : DefaultTextStyle(
                                      style: TextStyle(
                                          color: Color(0xff979797),
                                          fontSize: 11.sp),
                                      child: Row(
                                        children: [
                                          Row(
                                            children: [
                                              PlatformAwareAssetImage(
                                                url:
                                                    'assets/images/pili_12/icon_location_red.png',
                                                width: 18.w,
                                                fit: BoxFit.fitWidth,
                                              ),
                                              Text((widget.data['cityName'] ??
                                                      '未知')
                                                  .toString())
                                            ],
                                          ),
                                          SizedBox(width: 16.w),
                                          Row(
                                            children: [
                                              PlatformAwareAssetImage(
                                                url:
                                                    'assets/images/pili_12/icon_lock.png',
                                                width: 18.w,
                                                fit: BoxFit.fitWidth,
                                              ),
                                              Text((widget.data['buy_count'] ??
                                                      0)
                                                  .toString())
                                            ],
                                          )
                                        ],
                                      ))
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: -4.w,
                          child: widget.data['buy_count'] != null &&
                                  widget.data['buy_count'] > 10 &&
                                  !widget.isBuy
                              ? PlatformAwareAssetImage(
                                  url:
                                      'assets/images/pili_12/yuemei_jingpin.png',
                                  width: 54.w,
                                  fit: BoxFit.fitWidth,
                                )
                              : Container())
                    ],
                  ))
                ],
              ),
            ),
    );
  }
}
