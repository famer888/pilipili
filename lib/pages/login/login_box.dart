import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/theme/default.dart';

class LoginBox extends StatefulWidget {
  LoginBox(
      {Key? key,
      this.children,
      this.title,
      this.btnText,
      this.topText,
      this.onTap,
      this.onLeftTap,
      this.btnMargin,
      this.footer})
      : super(key: key);
  List<Widget>? children;
  String? title;
  dynamic btnText;
  Function? onTap;
  Widget? topText;
  Function? onLeftTap;
  Widget? footer;
  num? btnMargin;
  @override
  _LoginBoxState createState() => _LoginBoxState();
}

class _LoginBoxState extends State<LoginBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: ScreenUtil().setWidth(325),
        // color: Colors.white,
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(22.5),
            vertical: ScreenUtil().setWidth(45.5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.children!,
            ),
            widget.topText != null ? widget.topText! : Container(),
            widget.btnText is List
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: (){
                          widget.onLeftTap?.call();
                        },
                        child: Container(
                            margin: EdgeInsets.only(
                                top: ScreenUtil().setWidth(30),
                                bottom: widget.btnMargin != null
                                    ? widget.btnMargin!.toDouble()
                                    : ScreenUtil().setWidth(48)),
                            child: Center(
                              child: Container(
                                width: ScreenUtil().setWidth(100),
                                height: ScreenUtil().setHeight(34),
                                decoration: new BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      DefaultStyle.btnThemeColor,
                                      DefaultStyle.btnLinerThemeColor
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  //设置四周边框
                                ),
                                child: Center(
                                  child: Text(
                                    widget.btnText[0],
                                    style: TextStyle(
                                      color: Color(0xffff84A9),
                                      fontSize: ScreenUtil().setSp(15),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                      GestureDetector(
                        onTap: (){
                          widget.onTap?.call();
                        },
                        child: Container(
                            margin: EdgeInsets.only(
                                top: ScreenUtil().setWidth(30),
                                bottom: widget.btnMargin != null
                                    ? widget.btnMargin!.toDouble()
                                    : ScreenUtil().setWidth(48)),
                            child: Center(
                              child: Container(
                                width: ScreenUtil().setWidth(100),
                                height: ScreenUtil().setHeight(34),
                                decoration: new BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      DefaultStyle.btnThemeColor,
                                      DefaultStyle.btnLinerThemeColor
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  //设置四周边框
                                ),
                                child: Center(
                                  child: Text(
                                    widget.btnText[1],
                                    style: TextStyle(
                                      color: Color(0xffff84A9),
                                      fontSize: ScreenUtil().setSp(15),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      )
                    ],
                  )
                : GestureDetector(
                    onTap: (){
                      widget.onTap?.call();
                    },
                    child: Container(
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setWidth(30),
                            bottom: widget.btnMargin != null
                                ? widget.btnMargin!.toDouble()
                                : ScreenUtil().setWidth(48)),
                        child: Center(
                          child: Container(
                            width: ScreenUtil().setWidth(160),
                            height: ScreenUtil().setHeight(34),
                            decoration: new BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  DefaultStyle.btnThemeColor,
                                  DefaultStyle.btnLinerThemeColor
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),

                              //设置四周边框
                            ),
                            child: Center(
                              child: Text(
                                widget.btnText,
                                style: TextStyle(
                                  color: Color(0xffff84A9),
                                  fontSize: ScreenUtil().setSp(15),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )),
                  ),
            widget.footer != null ? widget.footer! : Container()
          ],
        ));
  }
}
