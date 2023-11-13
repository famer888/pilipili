import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/theme/default.dart';

class WithdrawalsPage extends StatefulWidget {
  const WithdrawalsPage({Key key}) : super(key: key);

  @override
  State<WithdrawalsPage> createState() => _WithdrawalsPageState();
}

class _WithdrawalsPageState extends State<WithdrawalsPage> {
  String userName = '';
  String userBlankNumber = '';
  String userMoney = '';
  Widget withdraInput(
      {Function(String) onChanged, String hintText, bool isNumber = false}) {
    return Row(
      children: [
        Expanded(
            child: TextField(
          textAlign: TextAlign.right,
          autofocus: true,
          onChanged: onChanged,
          maxLength: 20,
          cursorColor: Color(0xffFF84A9),
          textInputAction: TextInputAction.done,
          keyboardType: isNumber
              ? TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: isNumber
              ? []
              : [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
          decoration: InputDecoration(
              isDense: true,
              counterText: '',
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 14.sp, color: Color(0xffc2c2c2)),
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none),
          style: TextStyle(
            color: Color(0xff6D6D6D),
            fontSize: 14.sp,
          ),
        )),
        SizedBox(width: 8.w),
        getImage('assets/images/2023/setup_right.png',
            width: 16.w, height: 16.w, isAssets: true)
      ],
    );
  }

  Widget withdraItem({bool border = true, title = '', Widget rightChild}) {
    return Container(
      height: 52.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: border
          ? BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xffECECEC), width: 0.5.w)))
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Color(0XFF6D6D6D),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            width: 16.w,
          ),
          Expanded(
              child: Container(
            alignment: Alignment.centerRight,
            child: rightChild,
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // 点击任意地方，输入框失去焦点
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: Column(
            children: [
              PageTitleBar(
                paddingTop: ScreenUtil().statusBarHeight,
                title: '提现申请',
                rightWidget: GestureDetector(
                    onTap: () {
                      context.push('/withdrawalsRecord');
                    },
                    child: Text(
                      '提現紀錄',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900),
                    )),
              ),
              Expanded(
                  child: ListView(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 24.w, bottom: 16.w),
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: Container(
                                decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Color(0xffFF80A3).withOpacity(0.15),
                              offset: Offset(0, 2),
                              blurRadius: 8,
                              spreadRadius: 0)
                        ]))),
                        Positioned.fill(
                            child: getImage('assets/images/2023/my_post_bg.png',
                                height: 100.w,
                                width: double.infinity,
                                isAssets: true)),
                        Container(
                          height: 100.w,
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '可體現收益',
                                    style: TextStyle(
                                        color: Color(0xff979797),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp),
                                  ),
                                  SizedBox(
                                    height: 2.w,
                                  ),
                                  Text('2400',
                                      style: TextStyle(
                                          color: Color(0xffFE155B),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 32.sp)),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '換算現金',
                                    style: TextStyle(
                                        color: Color(0xff979797),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp),
                                  ),
                                  SizedBox(
                                    height: 2.w,
                                  ),
                                  Text('2000',
                                      style: TextStyle(
                                          color: Color(0xffFE155B),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 32.sp)),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.w),
                        color: Colors.white),
                    child: Column(
                      children: [
                        withdraItem(
                            title: '提款方式',
                            rightChild: Text(
                              '銀行卡',
                              style: TextStyle(
                                  color: Color(0xff979797),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400),
                            )),
                        withdraItem(
                            title: '提現手續費',
                            rightChild: Text(
                              '5%',
                              style: TextStyle(
                                  color: Color(0xff979797),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400),
                            )),
                        withdraItem(
                          title: '收款人姓名',
                          rightChild: withdraInput(
                              hintText: '請輸入收款人姓名',
                              onChanged: (value) {
                                userName = value;
                              }),
                        ),
                        withdraItem(
                          title: '銀行卡帳號',
                          rightChild: withdraInput(
                              hintText: '請輸入銀行卡帳號',
                              isNumber: true,
                              onChanged: (value) {
                                userBlankNumber = value;
                              }),
                        ),
                        withdraItem(
                          border: false,
                          title: '提現金額',
                          rightChild: withdraInput(
                              hintText: '請輸入提現金額',
                              isNumber: true,
                              onChanged: (value) {
                                userMoney = value;
                              }),
                        ),
                      ],
                    ),
                  ),
                 Center(
                  child:  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 24.w
                    ),
                    width: 200.w,
                    height: 36.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.w),
                        gradient: DefaultStyle.defaluGrandientLine,
                        boxShadow: [
                          BoxShadow(
                              color: Color(0xffFF80A3).withOpacity(0.5),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 0)
                        ]),
                    child: Text(
                      '提交申請',
                      style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                 )
                ],
              ))
            ],
          ),
        ));
  }
}
