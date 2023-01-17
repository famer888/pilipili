import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/input/yy_input.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';

class FillCodePage extends StatefulWidget {
  final Map args;

  FillCodePage({Key key, this.args}) : super(key: key);
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
  final password = TextEditingController();
  final newpassword = TextEditingController();
  final cnewpassword = TextEditingController();
  final newphone = TextEditingController();
  final newphoneCode = TextEditingController();
  String code = '86';
  String newcode = '86';
  List typeList = [
    {
      "name": "昵称修改",
      "btnname": "保存",
    },
    {"name": "绑定手机", "btnname": "立即绑定"},
    {"name": "更换手机", "btnname": "确认更换"},
    {
      "name": "请输入兑换码",
      "btnname": "确认",
    },
    {
      "name": "请输入邀请码",
      "btnname": "确认",
    },
    {
      "name": "修改密码",
      "btnname": "修改密码",
    },
    {
      "name": "设置密码",
      "btnname": "确认",
    },
  ];
  @override
  void dispose() {
    username.dispose();
    phone.dispose();
    phoneCode.dispose();
    exchange.dispose();
    invite.dispose();
    password.dispose();
    newpassword.dispose();
    cnewpassword.dispose();
    newphone.dispose();
    newphoneCode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // CommonUtils.debugPrint('-**********************************${widget.type}');
    if (widget?.args["type"] != null) {
      currentIndex = widget?.args["type"];
      setState(() {});
    }
  }

  Future<void> onSubmit() async {
    CommonUtils.debugPrint("$currentIndex");

    switch (currentIndex) {
      case 0:
        if (username.text.isEmpty) {
          CommonUtils.showText('请输入新的昵称');
          return;
        }
        if (username.text.length > 10) {
          CommonUtils.showText('昵称最大长度10个字符');
          // username.text = username.text.substring(0, 10);
          username.clear();
          return;
        }
        PageStatus.loading(mounted);
        var result = await updateUserInfo(nickname: username.text);
        if (result.status == 1) {
          context.read<HomeConfig>().setNickname(username.text);
          showText(status: result.status, msg: result.msg);
        } else {
          showText(status: result.status, msg: result.msg);
        }
        PageStatus.closeLoading();
        break;
      case 1:
        if (phone.text.isEmpty) {
          CommonUtils.showText('请输入需要绑定的手机号');
          return;
        }
        if (phoneCode.text.isEmpty) {
          CommonUtils.showText('请输入短信验证码');
          return;
        }
        PageStatus.showLoading();
        bindPhone(code: phoneCode.text, phonePrefix: code, phone: phone.text)
            .then((result) {
          if (result.status != 0) {
            CommonUtils.showText('手机绑定 ' + result.msg.toString());
            getHomeConfig(context).then((res) {
              context.pop();
            });
          } else {
            CommonUtils.showText('手机绑定 ' + result.msg.toString());
          }
        });
        PageStatus.closeLoading();
        break;
      case 2:
        if (phoneCode.text.isEmpty) {
          CommonUtils.showText('请输入原手机短信验证码～');
          return;
        }
        if (newphone.text.isEmpty) {
          CommonUtils.showText('请输入新手机号～');
          return;
        }
        if (newphoneCode.text.isEmpty) {
          CommonUtils.showText('请输入新手机短信验证码～');
          return;
        }
        PageStatus.showLoading();
        changePhone(
                oldPhone: widget.args["phone"],
                oldPhonePrefix: widget.args["phonePrefix"],
                oldCode: phoneCode.text,
                phone: newphone.text,
                phonePrefix: newcode,
                code: newphoneCode.text)
            .then((res) {
          if (res.status != 0) {
            CommonUtils.showText('手机换绑 ' + res.msg.toString());
            getHomeConfig(context).then((res) {
              context.pop();
            });
          } else {
            CommonUtils.showText('手机换绑 ' + res.msg.toString());
          }
        });
        PageStatus.closeLoading();
        break;
      case 3:
        if (exchange.text.isEmpty) {
          CommonUtils.showText('请输入兑换码');
          return;
        }
        PageStatus.showLoading();
        var result = await onExchange(cdk: exchange.text);
        showText(status: result.status, msg: result.msg, word: '兑换');
        PageStatus.closeLoading();
        break;
      case 4:
        if (invite.text.isEmpty) {
          CommonUtils.showText('请输入邀请码');
          return;
        }
        PageStatus.showLoading();
        var result = await toInvitation(affCode: invite.text);
        if (result.status == 1) {
          context.read<HomeConfig>().setInviteBy(invite.text);
        }
        showText(status: result.status, msg: result.msg, word: '填写');
        PageStatus.closeLoading();
        break;
      case 5:
        if (password.text.isEmpty) {
          CommonUtils.showText('请输入原密码');
          return;
        }
        if (newpassword.text.isEmpty) {
          CommonUtils.showText('请输入新密码');
          return;
        }
        if (cnewpassword.text.isEmpty) {
          CommonUtils.showText('请再次输入新密码');
          return;
        }
        CommonUtils.debugPrint(newpassword.text);
        CommonUtils.debugPrint(cnewpassword.text);
        if (newpassword.text != cnewpassword.text) {
          CommonUtils.showText('两次输入的密码不一致,请重新输入');
          newpassword.clear();
          cnewpassword.clear();
          return;
        }
        if (newpassword.text.length < 6) {
          CommonUtils.showText('请输入至少6位的新密码');
          return;
        }
        PageStatus.showLoading();
        updatePassword(
                password: password.text,
                newPassword: newpassword.text,
                newPasswordConfirm: cnewpassword.text)
            .then((res) {
          if (res.status != 0) {
            CommonUtils.showText('密码修改成功');
            context.pop();
          } else {
            CommonUtils.showText(res.msg);
          }
        });
        PageStatus.closeLoading();
        break;

      case 6:
        if (password.text.isEmpty) {
          CommonUtils.showText('请输入密码');
          return;
        }
        if (newpassword.text.isEmpty) {
          CommonUtils.showText('请输入确认密码');
          return;
        }
        if (newpassword.text != password.text) {
          CommonUtils.showText('两次输入的密码不一致,请重新输入');
          newpassword.clear();
          password.clear();
          return;
        }
        if (password.text.length < 6) {
          CommonUtils.showText('请输入至少6位的新密码');
          return;
        }
        PageStatus.showLoading();
        setPassword(
          password: password.text,
          passwordConfirm: newpassword.text,
        ).then((res) {
          if (res.status != 0) {
            CommonUtils.showText('密码设置成功');
            Future.delayed(Duration(seconds: 2), () {
              context.pop();
            });
            Provider.of<HomeConfig>(context, listen: false).setIsSetpassword(1);
          } else {
            CommonUtils.showText(res.msg);
          }
        }).whenComplete(() {
          PageStatus.closeLoading();
        });
        break;
    }
  }

  void showText({status, msg, word}) {
    if (status == 1) {
      CommonUtils.showText((word ?? '修改').toString() + '成功 ' + msg.toString());
      Future.delayed(Duration(seconds: 2), () {
        context.pop();
      });
    } else {
      CommonUtils.showText((word ?? '修改').toString() + '失败 ' + msg.toString());
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
            sendPhone(phone: phone.text, phonePrefix: code, type: 2)
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

  Widget _changePasswor() {
    var member = Provider.of<HomeConfig>(context, listen: false).member;
    return Column(
      children: [
        member?.username == null
            ? SizedBox()
            : YyInput(
                isLogin: false,
                margin: 1,
                isPassword: true,
                controller: password,
                type: TextInputType.text,
                hintText: '请输入原密码',
              ),
        YyInput(
          isLogin: false,
          margin: 1,
          isPassword: true,
          controller: newpassword,
          type: TextInputType.text,
          hintText: '请输入新密码',
        ),
        YyInput(
          isLogin: false,
          margin: 1,
          isPassword: true,
          controller: cnewpassword,
          type: TextInputType.text,
          hintText: '请再次确认新密码',
        )
      ],
    );
  }

  Widget _setPassword() {
    return Column(
      children: [
        YyInput(
          isLogin: false,
          margin: 1,
          isPassword: true,
          controller: password,
          type: TextInputType.text,
          hintText: '请输入密码',
        ),
        YyInput(
          isLogin: false,
          margin: 1,
          isPassword: true,
          controller: newpassword,
          type: TextInputType.text,
          hintText: '请再次输入密码',
        ),
      ],
    );
  }

  Widget _setPhone() {
    Function startTime;
    Function newstartTime;

    return Column(
      children: [
        Container(
            height: ScreenUtil().setHeight(53),
            color: Colors.white,
            // margin: EdgeInsets.only(top: ScreenUtil().setWidth(28)),
            child: Center(
              child: Text(
                '当前手机号:+' +
                    widget.args["phonePrefix"].toString() +
                    widget.args["phone"].toString(),
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
            sendPhone(
                    phone: widget.args["phone"],
                    phonePrefix: widget.args["phonePrefix"],
                    type: 4)
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
                "更换后原来手机号将不能用于登录",
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
              title: typeList[currentIndex]["name"],
              rightWidget: TextButton(
                onPressed: onSubmit,
                child: Text(
                  typeList[currentIndex]["btnname"],
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
              _getInvite(), //输入邀请码4
              _changePasswor(), // 设置密码 5
              _setPassword() //修改密码 6
            ],
          ))
        ],
      ),
    );
  }
}
