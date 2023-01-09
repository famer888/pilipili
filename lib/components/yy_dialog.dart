import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';

class YyDialog extends StatefulWidget {
  final Widget child; //子Widget
  final Function toPageCallback; //当content为null时会触发该事件（点击直接触发，不弹框）
  final Function callBack; //点击确认时的回调。为null时点击会关闭弹窗
  final String title; //标题
  final Function content; //内容
  final String btnText; //按钮内容
  final Function clickCallBack; //点击立即触发
  final bool isClick; //是否开启点击立即触发；
  final Function changeBtnText;
  final Function cancelBack;
  final bool clear; //关闭是否修改状态
  YyDialog(
      {Key key,
      this.child,
      this.clear = false,
      this.callBack,
      this.title,
      this.content,
      this.btnText,
      this.toPageCallback,
      this.clickCallBack,
      this.isClick,
      this.cancelBack,
      this.changeBtnText})
      : super(key: key);

  @override
  YyDialogState createState() => YyDialogState();
}

class YyDialogState extends State<YyDialog> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.clickCallBack != null && widget.isClick) {
          widget.clickCallBack();
          return;
        }
        if (widget.content == null) {
          if (widget.toPageCallback != null) {
            widget.toPageCallback();
          }
        } else {
          YyShowDialog.showdialog(context,
              title: widget.title,
              clear: widget.clear,
              content: widget.content,
              cancelBack: widget.cancelBack,
              changeBtnText: widget.changeBtnText,
              callBack: widget.callBack,
              btnText: widget.btnText ?? '确定');
        }
      },
      child: widget.child,
    );
  }
}

class YyShowDialog {
  static Future<dynamic> showdialog(BuildContext context,
      {String title,
      Function content,
      bool clear = false,
      Function callBack,
      Function cancelBack,
      String btnText,
      String cancelText,
      Function changeBtnText,
      bool prohibitClose = false}) {
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: prohibitClose ? null : true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          if (changeBtnText != null) {
            btnText = changeBtnText();
          }
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xffFFF4F9),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(10))),
                width: ScreenUtil().setWidth(300),
                padding: new EdgeInsets.only(
                    left: ScreenUtil().setWidth(24.5),
                    right: ScreenUtil().setWidth(24.5),
                    top: ScreenUtil().setWidth(title == null ? 0 : 25),
                    bottom: ScreenUtil().setWidth(24)),
                child: Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          title == null
                              ? Container()
                              : Center(
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color(0xff646464),
                                        fontSize: ScreenUtil().setSp(24),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                          Container(
                              margin: new EdgeInsets.only(
                                  top: ScreenUtil()
                                      .setWidth(title == null ? 32 : 26)),
                              child: content(setDialogState)),
                          Row(
                            children: [
                              cancelText != null
                                  ? Expanded(
                                      child: Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (cancelBack != null) {
                                            cancelBack();
                                          }
                                          context.pop();
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: ScreenUtil().setWidth(5),
                                              right: ScreenUtil().setWidth(5),
                                              top: ScreenUtil().setWidth(32)),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        ScreenUtil()
                                                            .setWidth(18)),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    DefaultStyle.btnThemeColor,
                                                    DefaultStyle
                                                        .btnLinerThemeColor
                                                  ],
                                                  end: Alignment.topCenter,
                                                  begin: Alignment.bottomCenter,
                                                )),
                                            // width: ScreenUtil().setWidth(120),
                                            height: ScreenUtil().setWidth(36),
                                            child: Center(
                                              child: Text(
                                                cancelText,
                                                style: TextStyle(
                                                    color:
                                                        DefaultStyle.themeColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                  : Container(),
                              btnText != null
                                  ? Expanded(
                                      child: Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (callBack == null) {
                                            context.pop();
                                          } else {
                                            context.pop();
                                            callBack();
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: ScreenUtil().setWidth(5),
                                              right: ScreenUtil().setWidth(5),
                                              top: ScreenUtil().setWidth(32)),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        ScreenUtil()
                                                            .setWidth(18)),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    DefaultStyle.themeColor,
                                                    DefaultStyle.linerThemeColor
                                                  ],
                                                  end: Alignment.topCenter,
                                                  begin: Alignment.bottomCenter,
                                                )),
                                            // width: ScreenUtil().setWidth(120),
                                            height: ScreenUtil().setWidth(36),
                                            child: Center(
                                              child: Text(
                                                btnText ?? '确定',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                  : Container()
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ));
        });
      },
    ).then((value) {
      if (cancelBack != null && clear) {
        cancelBack();
      }
    });
  }

  static Future showButtom(context,
      {String title,
      double height,
      Function callback,
      dynamic content,
      Function onClose}) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Stack(
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      color: Color(0xfffff4f9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil().setWidth(12)),
                        topRight: Radius.circular(ScreenUtil().setWidth(12)),
                      )),
                  width: double.infinity,
                  height: height ??
                      370.w + (kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: ScreenUtil().setWidth(64),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                end: Alignment.bottomCenter,
                                begin: Alignment.topCenter,
                                colors: [
                              Color(0XFFFF89AC),
                              Color(0XFFFF5B8C),
                              Color(0XFFFA437A),
                            ])),
                        child: Center(
                          child: Text(
                            title,
                            style: DefaultStyle.white18bold,
                          ),
                        ),
                      ),
                      Expanded(
                          child: content is Widget
                              ? content
                              : content(setBottomSheetState)),
                    ],
                  ),
                ),
                Positioned(
                    top: ScreenUtil().setWidth(19.5),
                    right: ScreenUtil().setWidth(19.5),
                    child: GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: PlatformAwareAssetImage(
                          url: 'assets/images/detail/icon_close.png',
                          width: ScreenUtil().setWidth(24),
                          height: ScreenUtil().setWidth(24),
                          filterQuality: FilterQuality.medium),
                    ))
              ],
            );
          });
        }).then((value) {
      if (onClose != null) {
        onClose();
      }
    });
  }
}
