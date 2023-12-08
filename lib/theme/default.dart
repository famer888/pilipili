import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultStyle {
  // 栏目顶部导航高度
  static double get navbarHegiht => ScreenUtil().setWidth(55);
  // 底部导航高度
  static double get bottomnavbarHegiht => ScreenUtil().setWidth(64);
  // 页面通用边距
  static double get pagePadding => ScreenUtil().setWidth(12.5);
  // 主题色
  static Color themeColor = Color(0xffFF84A9);
  // 主题线性渐层色
  static Color linerThemeColor = Color(0xffFF9E9E);
  // 按鈕主題色
  static Color btnThemeColor = Color(0xffFFCCDB);
  // 按鈕線性漸層色
  static Color btnLinerThemeColor = Color(0xffFFE4E4);
  // 导览页样式
  static TextStyle bottomNavStyle = TextStyle(
      color: Color(0xffFF5B8C),
      fontWeight: FontWeight.w500,
      fontSize: 12.sp,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);
  // 字体样式
  static TextStyle zhuti10 = TextStyle(
      color: Color(0xffFF84A9),
      fontSize: ScreenUtil().setSp(10),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle zhuti12 = TextStyle(
      color: Color(0xffFF84A9),
      fontSize: ScreenUtil().setSp(12),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle zhuti13 = TextStyle(
      color: Color(0xffFF84A9),
      fontSize: ScreenUtil().setSp(13),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle zhuti14 = TextStyle(
      color: Color(0xffFF84A9),
      fontSize: ScreenUtil().setSp(14),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle zhuti15 = TextStyle(
      color: Color(0xffFF84A9),
      fontSize: ScreenUtil().setSp(15),
      height: 1.5,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle zhuti16bolb = TextStyle(
      color: Color(0xffFF84A9),
      fontWeight: FontWeight.bold,
      fontSize: ScreenUtil().setSp(16),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle lgray10 = TextStyle(
      color: Color(0xff979797),
      fontSize: ScreenUtil().setSp(10),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle lgray11 = TextStyle(
      color: Color(0xff979797),
      fontSize: ScreenUtil().setSp(11),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle lgray12 = TextStyle(
      color: Color(0xff979797),
      fontSize: ScreenUtil().setSp(12),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle lgray13 = TextStyle(
      color: Color(0xff979797),
      fontSize: ScreenUtil().setSp(13),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle lgray14 = TextStyle(
      color: Color(0xff979797),
      fontSize: ScreenUtil().setSp(14),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle lgray14Bold = TextStyle(
      color: Color(0xff979797),
      fontWeight: FontWeight.bold,
      fontSize: ScreenUtil().setSp(14),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);
  static TextStyle lgray16bolb = TextStyle(
      color: Color(0xff979797),
      fontWeight: FontWeight.bold,
      fontSize: ScreenUtil().setSp(16),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle gray10 = TextStyle(
      color: Color(0xff6a6a6a),
      fontSize: ScreenUtil().setSp(10),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle gray11 = TextStyle(
      color: Color.fromRGBO(215, 215, 215, 1),
      fontSize: ScreenUtil().setSp(11),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle gray12 = TextStyle(
      color: Color(0xff6a6a6a),
      fontSize: ScreenUtil().setSp(12),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle gray13 = TextStyle(
      color: Color(0xff6a6a6a),
      fontSize: ScreenUtil().setSp(13),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle gray14 = TextStyle(
      color: Color.fromRGBO(215, 215, 215, 1),
      fontSize: ScreenUtil().setSp(14),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle gray15 = TextStyle(
      color: Color.fromRGBO(215, 215, 215, 1),
      fontSize: ScreenUtil().setSp(15),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle gray18 = TextStyle(
      color: Color.fromRGBO(153, 153, 153, 1),
      fontSize: ScreenUtil().setSp(18),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle red10 = TextStyle(
      color: Color.fromRGBO(255, 15, 114, 1),
      fontSize: ScreenUtil().setSp(10),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle red13 = TextStyle(
      color: Color.fromRGBO(255, 35, 126, 1),
      fontSize: ScreenUtil().setSp(13),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle red14 = TextStyle(
      color: Color.fromRGBO(255, 35, 126, 1),
      fontSize: ScreenUtil().setSp(14),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle red16bold = TextStyle(
      color: Color.fromRGBO(255, 35, 126, 1),
      fontSize: ScreenUtil().setSp(16),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle red20bold = TextStyle(
      color: Color.fromRGBO(255, 35, 126, 1),
      fontSize: ScreenUtil().setSp(20),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle black12 = TextStyle(
      color: Color.fromRGBO(51, 51, 51, 1),
      fontSize: ScreenUtil().setSp(12),
      decoration: TextDecoration.none);

  static TextStyle black13 = TextStyle(
      color: Color(0xff404040),
      fontSize: ScreenUtil().setSp(13),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle black13bold = TextStyle(
      color: Color(0xff404040),
      fontSize: ScreenUtil().setSp(13),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle black14 = TextStyle(
      color: Color(0xff404040),
      fontSize: ScreenUtil().setSp(14),
      decoration: TextDecoration.none);

  static TextStyle black15 = TextStyle(
      color: Color(0xff404040),
      fontSize: ScreenUtil().setSp(15),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle black15bold = TextStyle(
      color: Color(0xff404040),
      fontSize: ScreenUtil().setSp(15),
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none);

  static TextStyle black16 = TextStyle(
      color: Color(0xff404040),
      fontSize: ScreenUtil().setSp(16),
      decoration: TextDecoration.none);

  static TextStyle black16bold = TextStyle(
      color: Color(0xff404040),
      fontSize: ScreenUtil().setSp(16),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle black18bold = TextStyle(
      color: Color(0xff404040),
      fontSize: ScreenUtil().setSp(18),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle black24 = TextStyle(
      color: Color(0xff404040),
      fontSize: ScreenUtil().setSp(24),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white10 = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(10),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white11 = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(11),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white12 = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(12),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white13 = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(13),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white13bolb = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(13),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white14 = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(14),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white15 = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(15),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white15bold = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(15),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white16 = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(16),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white16bold = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(16),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white18 = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(18),
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white18bold = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(18),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white20bold = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(20),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle white24bold = TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontSize: ScreenUtil().setSp(24),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static TextStyle pink14bold = TextStyle(
      color: Color(0xffFF5B8C),
      fontSize: ScreenUtil().setSp(14),
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none);

  static LinearGradient defaluGrandientLine = LinearGradient(
    colors: [Color(0xffFF84A9), Color(0xffFF9E9E)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static LinearGradient whiteGrandientLine = LinearGradient(
    colors: [Color(0xffFFCCDB), Color(0xffFFE4E4)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static Decoration activeDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(5.w),
      color: Color(0xffFF84A9),
      boxShadow: [
        BoxShadow(
            color: Color(0xffA82118).withOpacity(0.26),
            offset: Offset(0, 2),
            blurRadius: 3,
            spreadRadius: 0)
      ]);
  static Decoration defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(5.w),
      boxShadow: [
        BoxShadow(
            color: Color.fromRGBO(255, 211, 201, 1),
            blurRadius: 4,
            blurStyle: BlurStyle.outer,
            offset: Offset(0, 2))
      ],
      gradient: LinearGradient(colors: [
        Color.fromRGBO(255, 255, 255, 1),
        Color.fromRGBO(255, 243, 248, 1),
        Color.fromRGBO(255, 211, 230, 1),
        Color.fromRGBO(255, 255, 255, 0.5)
      ], begin: Alignment(0, 0.5), end: Alignment(0, 2)));
}
