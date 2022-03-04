import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';

class Xianmian extends StatefulWidget {
  Xianmian({Key key}) : super(key: key);

  @override
  State<Xianmian> createState() => _XianmianState();
}

class _XianmianState extends State<Xianmian> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '精彩限免 请你白嫖',
          ),
          Expanded(child: Text("限免"))
        ],
      ),
    );
  }
}
