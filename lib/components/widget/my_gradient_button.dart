import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyGradientButton extends StatelessWidget {
  MyGradientButton(
      {Key key,
      this.onTap,
      this.buttonText,
      this.backgroundColor,
      this.shadowColors,
      this.gradientColor,
      this.textColor})
      : super(key: key);

  final Function onTap;
  final Color backgroundColor;
  final List<BoxShadow> shadowColors;
  final Gradient gradientColor;
  final String buttonText;
  final Color textColor;

  const MyGradientButton.outter(
      {this.onTap,
      this.shadowColors,
      this.gradientColor,
      this.buttonText,
      this.textColor})
      : backgroundColor = null;
  const MyGradientButton.inner(
      {this.onTap,
      this.backgroundColor,
      this.shadowColors,
      this.buttonText,
      this.textColor})
      : gradientColor = null;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onTap.call(),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.w),
              color: backgroundColor,
              boxShadow: shadowColors,
              gradient: gradientColor),
          width: 83.w,
          height: 36.w,
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 14.sp),
            ),
          ),
        ));
  }
}
