import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';

// ignore: must_be_immutable
class WidgetTitleBar extends StatefulWidget {
  WidgetTitleBar({Key key, this.title}) : super(key: key);
  String title;
  @override
  _WidgetTitleBarState createState() => _WidgetTitleBarState();
}

class _WidgetTitleBarState extends State<WidgetTitleBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlatformAwareAssetImage(
              url: 'assets/images/icon_love_red.png',
              width: ScreenUtil().setWidth(8),
              filterQuality: FilterQuality.medium),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8)),
            child: Text(
              widget.title,
              style: DefaultStyle.black18bold,
            ),
          ),
          PlatformAwareAssetImage(
              url: 'assets/images/icon_love_red.png',
              width: ScreenUtil().setWidth(8),
              filterQuality: FilterQuality.medium),
        ],
      ),
    );
  }
}
