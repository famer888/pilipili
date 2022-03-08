import 'package:country_code_picker/country_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/input/yy_input.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';

class FillCodePage extends StatefulWidget {
  FillCodePage({Key key, this.type}) : super(key: key);
  final int type;
  @override
  _FillCodePageState createState() => _FillCodePageState();
}

class _FillCodePageState extends State<FillCodePage> {
  int currentIndex = 0;

  final username = TextEditingController();
  final phone = TextEditingController();
  final phoneCode = TextEditingController();
  final exchange = TextEditingController();
  final invite = TextEditingController();
  final newphone = TextEditingController();
  final newphoneCode = TextEditingController();
  List typeList = [
    {
      "name": "昵称修改",
      "btnname": "保存",
    },
    {"name": "绑定手机", "btnname": "立即绑定"},
    {"name": "更换手机", "btnname": "确认更换"},
    {
      "name": "输入兑换码",
      "btnname": "确认",
    },
    {
      "name": "输入邀请码",
      "btnname": "确认",
    },
  ];

  @override
  void initState() {
    super.initState();
    CommonUtils.debugPrint('-**********************************${widget.type}');
    if (widget.type != null) {
      currentIndex = widget.type;
      setState(() {});
    }
  }

  void onSubmit() {
    CommonUtils.debugPrint("${username.text}");
    switch (widget.type) {
      case 0:
        if (username.text.isEmpty) {
          CommonUtils.showText('请输入新的昵称');
          return;
        }
        if (username.text.length > 10) {
          CommonUtils.showText('昵称最大长度10个字符');
        }
        break;
    }
  }

  Widget _setName() {
    // final exchange = TextEditingController();
    // final invite = TextEditingController();
    return Container(
      height: ScreenUtil().setHeight(40),
      child: YyInput(
        isLogin: false,
        controller: username,
        margin: 1,
        hintText: "请输入新的昵称",
        type: TextInputType.name,
      ),
    );
  }

  Widget _getExChange() {
    return Container(
      height: ScreenUtil().setHeight(40),
      child: YyInput(
        isLogin: false,
        controller: exchange,
        margin: 1,
        hintText: "请输入正确的兑换码",
        type: TextInputType.name,
      ),
    );
  }

  Widget _getInvite() {
    return Container(
      height: ScreenUtil().setHeight(40),
      child: YyInput(
        isLogin: false,
        controller: invite,
        margin: 1,
        hintText: "请输入正确的邀请码",
        type: TextInputType.name,
      ),
    );
  }

  Widget _bindPhone() {
    String code = '86';
    Function startTime;
    return Column(
      children: [
        YyInput(
          isLogin: false,
          margin: 1,
          controller: phone,
          hintText: '请输入手机号',
          type: TextInputType.phone,
          onChangeCountryCode: (CountryCode countryCode) {
            code = countryCode.toString().replaceAll('+', '');
          },
        ),
        YyInput(
          isLogin: false,
          margin: 1,
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
      ],
    );
  }

  Widget _setPhone() {
    Function startTime;
    Function newstartTime;
    String code = '86';
    String newcode = '86';
    return Column(
      children: [
        Container(
            height: ScreenUtil().setHeight(53),
            color: Colors.white,
            // margin: EdgeInsets.only(top: ScreenUtil().setWidth(28)),
            child: Center(
              child: Text(
                '当前手机号:+8613333333333',
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(15),
                    color: Color(0xff6D6D6D),
                    fontWeight: FontWeight.bold),
              ),
            )),
        YyInput(
          isLogin: false,
          margin: 1,
          controller: phoneCode,
          hintText: '请输入原手机短信验证码',
          isGetCode: true,
          initTime: (Function e) {
            startTime = e;
          },
          onSendCode: () {
            sendPhone(phone: phone.text, phonePrefix: code, type: 4)
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
          isLogin: false,
          margin: ScreenUtil().setHeight(16),
          controller: newphone,
          hintText: '请输入新手机号',
          type: TextInputType.phone,
          onChangeCountryCode: (CountryCode countryCode) {
            newcode = countryCode.toString().replaceAll('+', '');
          },
        ),
        YyInput(
          isLogin: false,
          margin: 1,
          controller: newphoneCode,
          hintText: '请输入新手机短信验证码',
          isGetCode: true,
          initTime: (Function e) {
            newstartTime = e;
          },
          onSendCode: () {
            sendPhone(phone: newphone.text, phonePrefix: newcode, type: 4)
                .then((res) {
              if (res.status == 1) {
                if (newstartTime != null) {
                  newstartTime();
                  CommonUtils.showText('发送成功～');
                }
              } else {
                CommonUtils.showText(res.msg);
              }
            });
          },
        ),
        Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(16)),
            child: Center(
              child: Text(
                "更换后原来手机号将不能用于登陆",
                style: TextStyle(
                  color: Color(0xffFE155B),
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(13),
                ),
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
              paddingTop: ScreenUtil().statusBarHeight,
              title: typeList[widget.type]["name"],
              rightWidget: TextButton(
                onPressed: onSubmit,
                // child: Text("123123"),
                child: Text(
                  typeList[widget.type]["btnname"],
                  style: TextStyle(color: Colors.white),
                ),
              )),
          Expanded(
              child: IndexedStack(
            index: currentIndex,
            children: [
              _setName(), //修改用户名 0
              _bindPhone(), //绑定手机号 1
              _setPhone(), //更换手机号2
              _getExChange(), //输入兑换码3
              _getInvite() //输入邀请码4
            ],
          ))
        ],
      ),
    );
  }
}
