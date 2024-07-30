/*
 * @Author: Tom
 * @Date: 2021-12-27 16:56:56
 * @LastEditTime: 2021-12-27 17:00:56
 * @LastEditors: Tom
 * @Description: 
 * @FilePath: /flutter2021/lib/components/common/pagetitlebar.dart
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_asset_path.dart';

// ignore: must_be_immutable
class PageTitleBar extends StatefulWidget {
  PageTitleBar(
      {Key key,
      this.title,
      this.rightWidget,
      this.height,
      this.paddingTop = 0,
      this.bgColor})
      : super(key: key);
  String title;
  Widget rightWidget;
  double height;
  double paddingTop;
  Color bgColor;
  @override
  _PageTitleBarState createState() => _PageTitleBarState();
}

class _PageTitleBarState extends State<PageTitleBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
            padding: EdgeInsets.only(top: widget.paddingTop),
            color: widget.bgColor ?? DefaultStyle.themeColor,
            alignment: Alignment.center,
            width: ScreenUtil().screenWidth,
            child: Container(
              alignment: Alignment.center,
              height: widget.height ?? DefaultStyle.navbarHegiht,
              width: ScreenUtil().screenWidth * 0.8,
              child: Text(
                widget.title != null ? widget.title : '',
                style: DefaultStyle.white16bold,
              ),
            )),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: widget.paddingTop,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: DefaultStyle.pagePadding,
                          vertical: ScreenUtil().setWidth(5)),
                      child: Container(
                        alignment: Alignment.center,
                        // width: ScreenUtil().setWidth(40),
                        // height: ScreenUtil().setWidth(40),
                        child: PlatformAwareAssetImage(
                            url: PPAssetsPath.backArrow,
                            fit: BoxFit.fitHeight,
                            width: 20.w,
                            height: 20.w,
                            filterQuality: FilterQuality.medium),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: DefaultStyle.pagePadding),
                  child: widget.rightWidget != null
                      ? widget.rightWidget
                      : Container(),
                )
              ],
            ))
      ],
    );
  }
}
