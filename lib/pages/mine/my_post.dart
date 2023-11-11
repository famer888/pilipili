import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/post_card.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';

class MyPostPage extends StatefulWidget {
  const MyPostPage({Key key}) : super(key: key);

  @override
  State<MyPostPage> createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '我的帖子',
          ),
          Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.all(8.w),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return PostCard();
                  }))
        ],
      ),
    );
  }
}
