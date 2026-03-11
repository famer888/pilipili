// ignore_for_file: no_logic_in_create_state

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_asset_path.dart';

//基类
abstract class BaseWidget extends StatefulWidget {
  const BaseWidget({this.key}) : super(key: key);
  @override
  final Key key;

  @override
  State<StatefulWidget> createState() => cState();

  State<StatefulWidget> cState();
}

abstract class BaseWidgetState<T extends BaseWidget> extends State<T>
    with RouteAware {
  String _appTitle = "";
  Color _bgColor = const Color(0xfff7f7f7);
  Color _navColor = Color.fromRGBO(255, 255, 255, 1);
  Color _lineColor = Colors.transparent;
  bool _navBack = false;
  bool _isOverscroll = false;
  BuildContext _mContext;
  Widget _rightW;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    // 这个跑起来要报错 先注释了
    ModalRoute<dynamic> route = ModalRoute.of<dynamic>(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onCreate();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build 统一布局基础页面
    _mContext = context;

    if (kIsWeb) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Stack(children: [
          backGroundView(),
          Column(
            children: [appbar(), Expanded(child: pageBody(context))],
          )
        ]),
      );
    } else if (Platform.isAndroid) {
      return Scaffold(
        primary: false,
        appBar: PreferredSize(child: Container(), preferredSize: Size.zero),
        backgroundColor: _bgColor,
        body: SafeArea(
            child: Stack(children: [
          backGroundView(),
          Column(
            children: [appbar(), Expanded(child: pageBody(context))],
          ),
        ])),
      );
    } else {
      return Scaffold(
        body: Stack(children: [
          backGroundView(),
          Column(
            children: [appbar(), Expanded(child: pageBody(context))],
          )
        ]),
        backgroundColor: _bgColor,
      );
    }
  }

  @override
  void dispose() {
    beforeDispose();
    super.dispose();
    onDestroy();
  }

  //页面初始化
  void onCreate();
  //页面布局
  Widget pageBody(BuildContext context);
  //页面销毁
  void onDestroy();
  //初始化之前的操作
  void beforeInit() {}
  //销毁之前的操作
  void beforeDispose() {}
  /*
    销毁页面
   */
  void finish() {
    context.pop();
  }

  Widget backGroundView() {
    return Container();
  }

  /*
   *  公用的AppBar的title
   */
  void setAppTitle({
    String title = "",
    Color navColor = Colors.transparent,
    Color bgColor = const Color(0XFFF7F7F7),
    Widget rightW,
    Color lineColor = Colors.transparent,
  }) {
    _appTitle = title;
    _rightW = rightW;
    _navColor = navColor;
    _bgColor = bgColor;
    _lineColor = lineColor;
    setState(() {});
  }

  /*
   * 继承该基类的公用的AppBar 
   * 1.有标题默认正常标题栏；
   * 2.无标题为空，可以根据自身组件写标题组件或则调用appbar重写标题
   */
  Widget appbar() {
    return _navBack
        ? Column(
            children: [
              Container(
                height: ScreenUtil().statusBarHeight,
                color: _navColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal:16.w),
                height: DefaultStyle.navbarHegiht,
                decoration: BoxDecoration(
                  color: _navColor,
                  border: Border(
                      bottom: BorderSide(color: _lineColor, width: .4.w)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              width: 40.w,
                              height: 40.w,
                              child: PlatformAwareAssetImage(
                                  url: PPAssetsPath.backArrow,
                                  fit: BoxFit.fitHeight,
                                  width: 20.w,
                                  height: 20.w,
                                  filterQuality: FilterQuality.medium),
                            ),
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              finish();
                            },
                          ),
                          _rightW ??
                              SizedBox(
                                width: 20.w,
                                height: 20.w,
                              )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 80.w),
                      child: Center(
                          child: Text(_appTitle,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.normal,
                                  color: const Color.fromRGBO(31, 31, 31, 1)))),
                    ),
                  ],
                ),
              )
            ],
          )
        : Container();
  }

  // Called when the current route has been pushed.
  // 当前的页面被push显示到用户面前 viewWillAppear.
  @override
  void didPush() {
    if (Navigator.canPop(context)) {
      _navBack = true;
      setState(() {});
    }
  }

  /// Called when the current route has been popped off.
  /// 当前的页面被pop viewWillDisappear.
  @override
  void didPop() {}

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  /// 上面的页面被pop后当前页面被显示时 viewWillAppear.
  @override
  void didPopNext() {}

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  /// 从当前页面push到另一个页面 viewWillDisappear.
  @override
  void didPushNext() {}
}
