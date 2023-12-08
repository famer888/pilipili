import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/theme/default.dart';

import '../../utils/networkImage.dart';

class MyButton extends StatelessWidget {
  MyButton({
    Key key,
    this.onTap,
    this.type,
    this.text,
    this.icon,
    this.activate = false,
  }) : super(key: key);
  final Function onTap;
  final ButtonType type;
  final String icon;
  final String text;
  final bool activate;
  MyButton.text({this.onTap, this.text, this.activate = false})
      : type = ButtonType.text,
        icon = null;
  MyButton.topIcon({this.onTap, this.text, this.icon, this.activate = false})
      : type = ButtonType.iconOnTop;
  MyButton.leftIcon({this.onTap, this.text, this.icon, this.activate = false})
      : type = ButtonType.iconOnLeft;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ButtonType.text:
        return GestureDetector(
            onTap: () => onTap.call(),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.w),
                  boxShadow: activate
                      ? DefaultStyle.clickedButtonBoxShadow
                      : DefaultStyle.unClickButtonBoxShadow,
                  gradient: activate ? null : DefaultStyle.buttonGradient),
              width: 83.w,
              height: 36.w,
              child: Center(
                child: Text(text,
                    style: activate
                        ? DefaultStyle.buttonClickedTextStyle
                        : DefaultStyle.buttonUnClickTextStyle),
              ),
            ));
        break;
      case ButtonType.iconOnLeft:
        return GestureDetector(
            onTap: () => onTap.call(),
            child: Container(
              width: 60.w,
              height: 24.w,
              decoration: BoxDecoration(
                  gradient: activate ? null : DefaultStyle.buttonGradient,
                  borderRadius: BorderRadius.circular(8.w),
                  boxShadow: activate
                      ? DefaultStyle.clickedButtonBoxShadow
                      : DefaultStyle.unClickButtonBoxShadow),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlatformAwareAssetImage(
                      url: 'assets/images/detail/' + icon.toString() + '.png',
                      width: 10.w,
                      height: 12.w,
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.medium),
                  SizedBox(
                    width: 4.w,
                  ),
                  Text(
                    text,
                    style: activate
                        ? DefaultStyle.iconButtonClickedTextStyle
                        : DefaultStyle.iconButtonUnClickTextStyle,
                  )
                ],
              ),
            ));

      case ButtonType.iconOnTop:
        return GestureDetector(
            onTap: () => onTap.call(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                  gradient: activate ? null : DefaultStyle.buttonGradient,
                  borderRadius: BorderRadius.circular(8.w),
                  boxShadow: activate
                      ? DefaultStyle.clickedButtonBoxShadow
                      : DefaultStyle.unClickButtonBoxShadow),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlatformAwareAssetImage(
                      url: 'assets/images/detail/' + icon.toString() + '.png',
                      width: 10.w,
                      height: 12.w,
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.medium),
                  Text(
                    text,
                    style: activate
                        ? DefaultStyle.iconButtonClickedTextStyle
                        : DefaultStyle.iconButtonUnClickTextStyle,
                  )
                ],
              ),
            ));
    }
    return GestureDetector(
        onTap: () => onTap.call(),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.w),
              boxShadow: activate
                  ? DefaultStyle.clickedButtonBoxShadow
                  : DefaultStyle.unClickButtonBoxShadow,
              gradient: activate ? null : DefaultStyle.buttonGradient),
          width: 83.w,
          height: 36.w,
          child: Text(text,
              style: activate
                  ? DefaultStyle.buttonClickedTextStyle
                  : DefaultStyle.buttonUnClickTextStyle),
        ));
  }
}

enum ButtonType {
  /// 文字按钮
  text,

  /// 图标按钮(上)
  iconOnTop,

  /// 图标按钮(左）
  iconOnLeft,
}
