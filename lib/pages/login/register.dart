import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/input/yy_input.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'login_box.dart';

class Register extends StatefulWidget {
  Register({Key key, this.type}) : super(key: key);
  final int type;
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  int currentIndex = 0;

  int loginType = 1; //0 手机 1 账号密码
  int retrieveStatus = 0; //0 输入找回账号  1开始找回
  String retrieveName;
  @override
  void initState() {
    super.initState();
    if (widget.type != null) {
      currentIndex = widget.type;
      setState(() {});
    }
  }

  Widget _register() {
    final username = TextEditingController();
    final code = TextEditingController();
    final password = TextEditingController();
    final cpassword = TextEditingController();
    final phone = TextEditingController();
    final phoneCode = TextEditingController();
    Function startTime;
    String phonePrefix = '86';
    clearInput() {
      username.clear();
      code.clear();
      password.clear();
      cpassword.clear();
      phone.clear();
      phoneCode.clear();
    }

    return LoginBox(
      btnText: '立即注册',
      footer: Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                child: Text(
                  '已有账号 ！去登录',
                  style: TextStyle(
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(13)),
                ),
              ),
            )
          ],
        ),
      ),
      topText: Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(16)),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                loginType = loginType == 0 ? 1 : 0;
                setState(() {});
              },
              child: Text(
                loginType == 0
                    ? PPString.acountPasswodRegister
                    : PPString.phoneCodRegister,
                style: TextStyle(
                    color: Color(0xffffffff),
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(12)),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        if (loginType == 0) {
          if (phoneCode.text.isEmpty) {
            CommonUtils.showText('请输入手机验证码～');
            return;
          }
          if (phone.text.isEmpty) {
            CommonUtils.showText('请输入手机号码～');
            return;
          }
          PageStatus.showLoading();
          registerByPhone(
                  code: phoneCode.text,
                  phone: phone.text,
                  phonePrefix: phonePrefix,
                  invitedAff: code.text)
              .then((res) {
            if (res.status != 0) {
              currentIndex = 0;
              setState(() {});
              CommonUtils.showText('注册成功,快去登录吧～');
              clearInput();
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
          if (password.text.isEmpty) {
            CommonUtils.showText('请输入密码～');
            return;
          }
          if (password.text.length < 6) {
            CommonUtils.showText('请输入6位数及以上的密码～');
            return;
          }
          if (password.text != cpassword.text) {
            CommonUtils.showText('两次输入的密码不一致,请重新输入～');
            password.clear();
            cpassword.clear();
            return;
          }
          PageStatus.showLoading();
          registerByPassword(
                  username: username.text,
                  password: password.text,
                  confirmPwd: cpassword.text,
                  invitedAff: code.text)
              .then((res) {
            if (res.status != 0) {
              currentIndex = 0;
              setState(() {});
              CommonUtils.showText('注册成功,快去登录吧～');
              clearInput();
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
                  type: TextInputType.phone,
                  hintText: '输入手机号',
                  onChangeCountryCode: (CountryCode countryCode) {
                    phonePrefix = countryCode.toString().replaceAll('+', '');
                  }),
              YyInput(
                isGetCode: true,
                controller: phoneCode,
                type: TextInputType.text,
                initTime: (Function e) {
                  startTime = e;
                },
                onSendCode: () {
                  sendPhone(
                          phone: phone.text, phonePrefix: phonePrefix, type: 5)
                      .then((res) {
                    if (res.status == 1) {
                      if (startTime != null) {
                        startTime();
                        CommonUtils.showText('发送成功～');
                      }
                    } else {
                      CommonUtils.showText(res.msg);
                    }
                  });
                },
                hintText: '输入短信验证码',
              ),
              YyInput(
                controller: code,
                type: TextInputType.text,
                hintText: '输入邀请码（选填）',
              ),
            ]
          : [
              YyInput(
                controller: username,
                type: TextInputType.text,
                hintText: '请输入包含字母的用户名',
              ),
              YyInput(
                isPassword: true,
                controller: password,
                type: TextInputType.text,
                hintText: '请输入密码',
              ),
              YyInput(
                isPassword: true,
                controller: cpassword,
                type: TextInputType.text,
                hintText: '请再次输入密码',
              ),
              YyInput(
                controller: code,
                type: TextInputType.text,
                hintText: '输入邀请码（选填）',
              ),
            ],
    );
  }

  Widget _recoverAccount() {
    final acount = TextEditingController();
    final phone = TextEditingController();
    final phoneCode = TextEditingController();
    final password = TextEditingController();
    final cpassword = TextEditingController();

    Function startTime;
    String code = '86';
    clearinput() {
      acount.clear();
      phone.clear();
      phoneCode.clear();
      password.clear();
      cpassword.clear();
    }

    return LoginBox(
      title: '忘记密码',
      btnText: retrieveStatus == 0 ? PPString.next : PPString.resetPassword,
      btnMargin: retrieveStatus == 0 ? ScreenUtil().setWidth(200) : null,
      onTap: () {
        if (retrieveStatus == 0) {
          if (acount.text.isEmpty) {
            CommonUtils.showText('请输入要找回的用户名～');
            return;
          }
          PageStatus.showLoading();
          validateUsername(username: acount.text).then((res) {
            if (res.status == 0) {
              retrieveName = acount.text;
              retrieveStatus = 1;
              setState(() {});
            }
            if (res.status == 1) {
              CommonUtils.showText('该账号不存在～');
            }
          }).whenComplete(() {
            PageStatus.closeLoading();
          });
        } else {
          if (phone.text.isEmpty) {
            CommonUtils.showText('请输入手机号');
            return;
          }
          if (phoneCode.text.isEmpty) {
            CommonUtils.showText('请输入短信验证码');
            return;
          }
          if (password.text.isEmpty) {
            CommonUtils.showText('请输入新密码');
            return;
          }
          if (cpassword.text.isEmpty) {
            CommonUtils.showText('请输入再次输入新密码');
            return;
          }
          if (password.text.length < 6) {
            CommonUtils.showText('请至少输入6位数新密码');
            return;
          }
          if (password.text != cpassword.text) {
            CommonUtils.showText('两次输入的密码不一致,请重新密码');
            password.clear();
            cpassword.clear();
            return;
          }
          PageStatus.showLoading();
          forgetPassword(
                  code: phoneCode.text,
                  username: retrieveName,
                  phone: phone.text,
                  phonePrefix: code,
                  password: password.text,
                  passwordConfirm: cpassword.text)
              .then((res) {
            if (res.status != 0) {
              currentIndex = 0;
              setState(() {});
              CommonUtils.showText('密码已成功找回～');
              clearinput();
            } else {
              CommonUtils.showText(res.msg);
            }
          }).whenComplete(() {
            PageStatus.closeLoading();
          });
        }
      },
      children: retrieveStatus == 0
          ? [
              YyInput(
                  controller: acount,
                  type: TextInputType.text,
                  hintText: '请输入要找回的账号')
            ]
          : [
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
                  sendPhone(phone: phone.text, phonePrefix: code, type: 3)
                      .then((res) {
                    if (res.status == 1) {
                      if (startTime != null) {
                        startTime();
                        CommonUtils.showText('发送成功～');
                      }
                    } else {
                      CommonUtils.showText(res.msg);
                    }
                  });
                },
              ),
              YyInput(
                  hintText: '请输入新密码(至少6位)',
                  controller: password,
                  type: TextInputType.text,
                  isPassword: true),
              YyInput(
                  hintText: '请再次输入新密码(至少6位)',
                  controller: cpassword,
                  type: TextInputType.text,
                  isPassword: true)
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
            child: PlatformAwareAssetImage(
                url: 'assets/images/login/bg_2.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium)),
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
                          _register(), //注册 0
                          _recoverAccount() //忘记密码 1
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
                                currentIndex == 0
                                    ? PPString.registerLogin
                                    : PPString.forgoPassword,
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
            ))),
      ],
    );
  }
}
