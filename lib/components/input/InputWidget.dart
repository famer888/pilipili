import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';

// 返回的内容去除所有空格

class InputWidget extends StatefulWidget {
  final String tips;
  final int limitingText;
  final TextInputType boardType;
  final String btnText;
  InputWidget(
      {Key key,
      this.tips,
      this.limitingText = 30,
      this.boardType = TextInputType.text,
      this.btnText})
      : super(key: key);

  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  TextEditingController editingController = TextEditingController();
  FocusNode focusNode = new FocusNode();
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      /// WidgetsBinding 它能监听到第一帧绘制完成，第一帧绘制完成标志着已经Build完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ///获取输入框焦点
        Future.delayed(Duration(milliseconds: 300), () {
          FocusScope.of(context).requestFocus(focusNode);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                  onTapDown: (_) => context.pop(),
                  child: Container(
                    color: Colors.black45,
                  )),
            ),
            Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: ScreenUtil().setWidth(15),
                          ),
                          Expanded(
                            child: Container(
                              height: ScreenUtil().setWidth(40),
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              alignment: Alignment.center,
                              child: TextField(
                                focusNode: focusNode,
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    context.pop(value);
                                  } else {
                                    BotToast.showText(
                                        text: widget.tips,
                                        align: Alignment(0, 0));
                                  }
                                },
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ScreenUtil().setSp(14)),
                                keyboardType: widget.boardType,
                                textInputAction: TextInputAction.done,
                                autofocus: true,
                                maxLengthEnforced: true,
                                controller: editingController,
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, right: 10, top: 5, bottom: 5),
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        color: Color(0xff979797),
                                        fontSize: ScreenUtil().setSp(14)),
                                    hintText: widget.tips),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (() {
                              var text = editingController.text?.replaceAll(
                                      new RegExp(r"\s+\b|\b\s"), "") ??
                                  "";
                              if (text.isNotEmpty) {
                                context.pop(text);
                              } else {
                                CommonUtils.showText(widget.tips);
                              }
                            }),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil().setWidth(15)),
                                  gradient: SweepGradient(
                                      //  begin: Alignment.bottomCenter,
                                      colors: [
                                        Color(0XFFff84a9),
                                        Color(0XFFff9e9e),
                                      ])),
                              width: ScreenUtil().setWidth(60),
                              height: ScreenUtil().setWidth(30),
                              alignment: Alignment.center,
                              child: Text(
                                widget.btnText == null ? '提交' : widget.btnText,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(14)),
                              ),
                            ),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(15.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
