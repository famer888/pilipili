import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/input/yy_input.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/utils/common.dart';

import '../../routers.dart';
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

  Widget _login() {
    final phone = TextEditingController();
    final username = TextEditingController();
    final userPassword = TextEditingController();
    final phoneCode = TextEditingController();
    Function startTime;
    String code = '86';
    return LoginBox(
      btnText: '立即登录',
      footer: Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                context.push('/${Routes.register}');
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                child: Text(
                  '没有账号？快速注册',
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
                context.push('/${Routes.register}');
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
                CommonUtils.debugPrint(
                    '-**********************************12312312');
                loginType = loginType == 0 ? 1 : 0;
                setState(() {});
              },
              child: Container(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(16)),
                  child: Text(
                    loginType == 0 ? '账号密码登陆' : '手机验证码登陆',
                    style: TextStyle(
                        color: Color(0xffffffff),
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(13)),
                  )),
            ),
          ],
        ),
      ),
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
              child: Container(
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
          )),
        )
      ],
    );
  }
}
