import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';

class ZhaomuPage extends StatefulWidget {
  const ZhaomuPage({Key key});

  @override
  State<ZhaomuPage> createState() => _ZhaomuPageState();
}

class _ZhaomuPageState extends State<ZhaomuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '',
          ),
          Expanded(
              child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  getImage('assets/images/2023/zhaomu_bg.png',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      isAssets: true),
                  Positioned(
                    top: 549.w,
                    right: 12.w,
                    child: GestureDetector(
                      onTap: (){},
                      child: getImage('assets/images/2023/zhaomu_btn.png',
                        height: 55.w,
                         fit: BoxFit.fitHeight, isAssets: true)),
                  )
                ],
              )
            ],
          ))
        ],
      ),
    );
  }
}
