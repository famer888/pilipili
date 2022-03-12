import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:pilipili/components/input/yy_input.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:provider/provider.dart';

import 'login_box.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.type, this.isExpired = false}) : super(key: key);
  final int type;
  final bool isExpired;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int currentIndex = 0;

  int loginType = 1; //0 手机 1 账号密码
  String retrieveName;
  @override
  void initState() {
    super.initState();
    CommonUtils.debugPrint('-**********************************${widget.type}');
    if (widget.isExpired) {
      // getHomeConfig(context);
    }
    if (widget.type != null) {
      currentIndex = widget.type;
      setState(() {});
    }
  }

  setToken(String value) async {
    Box box = AppGlobal.appBox;
    box.put('yy_token', value);
  }

  Widget _login() {
    final phone = TextEditingController();
    final username = TextEditingController();
    final userPassword = TextEditingController();
    final phoneCode = TextEditingController();
    Function startTime;
    String code = '86';
    return LoginBox(
      btnText: ["注册", "登陆"],
      btnMargin: ScreenUtil().setWidth(60),
      // footer: Container(
      //   margin: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
      //   width: double.infinity,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       GestureDetector(
      //         onTap: () {
      //           // context.push(CommonUtils.getRealHash('register'));
      //           context.push(CommonUtils.getRealHash('register/${0}'));
      //         },
      //         child: Container(
      //           padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
      //           child: Text(
      //             '没有账号？快速注册',
      //             style: TextStyle(
      //                 color: Color(0xffffffff),
      //                 fontWeight: FontWeight.bold,
      //                 fontSize: ScreenUtil().setSp(13)),
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
      topText: Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(16)),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // context.push('/${Routes.register}/${1}');
                context.push(CommonUtils.getRealHash('register/${1}'));
              },
              child: Text(
                '忘记密码',
                style: TextStyle(
                    color: Color(0xffffffff),
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(13)),
              ),
            ),
            GestureDetector(
              onTap: () {
                loginType = loginType == 0 ? 1 : 0;
                setState(() {});
              },
              child: Container(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(16)),
                  child: Text(
                    loginType == 0 ? '账号密码登录' : '手机验证码登录',
                    style: TextStyle(
                        color: Color(0xffffffff),
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(13)),
                  )),
            ),
          ],
        ),
      ),
      onLeftTap: () {
        if (username.text.isEmpty) {
          CommonUtils.showText('请输入用户名～');
          return;
        }
        if (userPassword.text.isEmpty) {
          CommonUtils.showText('请输入密码～');
          return;
        }
        PageStatus.showLoading();
        registerByPassword(username: username.text, password: userPassword.text)
            .then((res) {
          if (res.status != 0) {
            AppGlobal.apiToken = res.data;
            setToken(res.data);
            getHomeConfig(context).then((res) {
              context.pop('login');
              YyShowDialog.showdialog(
                context,
                title: '请截图保存账号密码',
                content: (setDialogState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '账号:   ',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(15),
                                decoration: TextDecoration.none),
                          ),
                          Text(
                            username.text,
                            style: TextStyle(
                                color: Color(0xffFE155B),
                                fontSize: ScreenUtil().setSp(15),
                                decoration: TextDecoration.none),
                          )
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(25),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '密码:   ',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(15),
                                decoration: TextDecoration.none),
                          ),
                          Text(
                            userPassword.text,
                            style: TextStyle(
                                color: Color(0xffFE155B),
                                fontSize: ScreenUtil().setSp(15),
                                decoration: TextDecoration.none),
                          )
                        ],
                      )
                    ],
                  );
                },
                btnText: '知道了',
              );
            });
          } else {
            CommonUtils.showText(res.msg);
          }
        }).whenComplete(() {
          PageStatus.closeLoading();
        });
      },
      onTap: () {
        if (loginType == 0) {
          if (phone.text.isEmpty) {
            CommonUtils.showText('请输入手机号～');
            return;
          }
          if (phoneCode.text.isEmpty) {
            CommonUtils.showText('请输入手机验证码～');
            return;
          }
          PageStatus.showLoading(text: '正在登录...');
          loginByPhone(
                  code: phoneCode.text, phone: phone.text, phonePrefix: code)
              .then((res) {
            if (res.status != 0) {
              CommonUtils.showText('登录成功～');
              AppGlobal.apiToken = res.data;
              setToken(res.data);
              getHomeConfig(context).then((res) {
                context.pop('login');
              });
            } else {
              CommonUtils.showText(res.msg);
            }
          }).whenComplete(() {
            PageStatus.closeLoading();
          });
        } else {
          if (username.text.isEmpty) {
            CommonUtils.showText('请输入用户名～');
            return;
          }
          if (userPassword.text.isEmpty) {
            CommonUtils.showText('请输入密码～');
            return;
          }
          PageStatus.showLoading(text: '正在登录...');
          loginByPassword(password: userPassword.text, username: username.text)
              .then((res) {
            if (res.status != 0) {
              CommonUtils.showText('登录成功～');
              AppGlobal.apiToken = res.data;
              setToken(res.data);
              getHomeConfig(context).then((res) {
                context.pop('login');
              });
            } else {
              CommonUtils.showText(res.msg);
            }
          }).whenComplete(() {
            PageStatus.closeLoading();
          });
        }
      },

      children: loginType == 0
          ? [
              YyInput(
                controller: phone,
                hintText: '请输入手机号',
                type: TextInputType.phone,
                onChangeCountryCode: (CountryCode countryCode) {
                  code = countryCode.toString().replaceAll('+', '');
                },
              ),
              YyInput(
                controller: phoneCode,
                hintText: '请输入短信验证码',
                isGetCode: true,
                initTime: (Function e) {
                  startTime = e;
                },
                onSendCode: () {
                  if (phone.text.isEmpty) {
                    CommonUtils.showText('手机号为空，请输入');
                    return;
                  }
                  PageStatus.showLoading();
                  sendPhone(phone: phone.text, phonePrefix: code, type: 1)
                      .then((res) {
                    if (res.status == 1) {
                      if (startTime != null) {
                        startTime();
                        CommonUtils.showText('发送成功～');
                      }
                    } else {
                      CommonUtils.showText(res.msg);
                    }
                    PageStatus.closeLoading();
                  });
                },
              ),
            ]
          : [
              YyInput(
                controller: username,
                hintText: '请输入用户名',
                type: TextInputType.text,
              ),
              YyInput(
                  hintText: '请输入密码',
                  controller: userPassword,
                  type: TextInputType.text,
                  isPassword: true),
            ],
    );
  }

  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child:
                Image.asset('assets/images/login/bg_1.png', fit: BoxFit.fill)),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
              child: Stack(
            children: [
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        child: IndexedStack(
                      index: currentIndex,
                      children: [
                        _login(), //登录 0
                      ],
                    ))
                  ],
                ),
              ),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: DefaultStyle.pagePadding,
                      ),
                      child: GestureDetector(
                        onTap: () => {context.pop()},
                        child: Container(
                          height: ScreenUtil().setWidth(44),
                          child: Row(children: [
                            Center(
                              child: Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: ScreenUtil().setSp(35),
                              ),
                            ),
                            Text(
                              "登录",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(16),
                              ),
                            ),
                          ]),
                        ),
                      )))
            ],
          )),
        )
      ],
    );
  }
}
