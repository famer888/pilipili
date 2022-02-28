import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:youyutv/theme/default.dart';
import 'package:youyutv/utils/networkImage.dart';

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
      this.btnText = '确定',
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
              btnText: widget.btnText);
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
      String btnText = '确定',
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
            child: Stack(
              children: [
                Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/pengke/dialog_bg.png',
                      fit: BoxFit.fill,
                    )),
                Container(
                  width: ScreenUtil().setWidth(300),
                  padding: new EdgeInsets.only(
                      left: ScreenUtil().setWidth(24.5),
                      right: ScreenUtil().setWidth(24.5),
                      top: ScreenUtil().setWidth(25),
                      bottom: ScreenUtil().setWidth(33.5)),
                  child: Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Center(
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xffffffff),
                                    fontSize: ScreenUtil().setSp(24),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                                margin: new EdgeInsets.only(
                                    top: ScreenUtil().setWidth(26)),
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
                                                top: ScreenUtil().setWidth(40)),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                    child: Image.asset(
                                                  'assets/pengke/video/video_duan_btn.png',
                                                  fit: BoxFit.fill,
                                                )),
                                                Container(
                                                  width: ScreenUtil()
                                                      .setWidth(163.5),
                                                  height:
                                                      ScreenUtil().setWidth(32),
                                                  child: Center(
                                                    child: Text(
                                                      cancelText,
                                                      style:
                                                          DefaultStyle.zhuti13,
                                                    ),
                                                  ),
                                                )
                                              ],
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
                                                top: ScreenUtil().setWidth(40)),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  right: 0,
                                                  bottom: 0,
                                                    child: Image.asset(
                                                  'assets/pengke/video/video_duan_btn.png',
                                                  fit: BoxFit.fill,
                                                )),
                                                Container(
                                                  width: ScreenUtil()
                                                      .setWidth(163.5),
                                                  height:
                                                      ScreenUtil().setWidth(32),
                                                  child: Center(
                                                    child: Text(
                                                      btnText,
                                                      style:
                                                          DefaultStyle.zhuti13,
                                                    ),
                                                  ),
                                                )
                                              ],
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
                      Positioned(
                        top: ScreenUtil().setWidth(-103.5),
                        left: 0,
                        right: 0,
                        child: prohibitClose
                            ? Container()
                            : Center(
                                child: GestureDetector(
                                    onTap: () => context.pop(),
                                    child: PlatformAwareAssetImage(
                                        url: 'assets/images/yuepao/close.png',
                                        width: ScreenUtil().setWidth(43.5),
                                        height: ScreenUtil().setWidth(43.5),
                                        fit: BoxFit.fitHeight)),
                              ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
      },
    ).then((value) {
      if (cancelBack != null && clear) {
        cancelBack();
      }
    });
  }
}
