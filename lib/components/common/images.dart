import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/utils/networkImage.dart';

Widget getImage(String url,
    {double width, double height, BoxFit fit, FilterQuality filterQuality}) {
  return Image.asset(
    url,
    fit: fit,
    width: width,
    height: height,
    filterQuality: filterQuality,
  );

  // return PlatformAwareAssetImage(
  //     url: url,
  //     fit: fit,
  //     width: width,
  //     height: height,
  //     filterQuality: filterQuality);
}
