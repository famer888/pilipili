import 'package:flutter/material.dart';
import 'package:pilipili/utils/networkImage.dart';

Widget getImage(String url,
    {double? width,
    double? height,
    BoxFit? fit,
    FilterQuality filterQuality=FilterQuality.medium,
    bool isAssets = false}) {
  if (isAssets) {
    return Image.asset(
      url,
      fit: fit,
      width: width,
      height: height,
      filterQuality: filterQuality,
    );
  } else {
    return PlatformAwareAssetImage(
        url: url,
        fit: fit!,
        width: width,
        height: height,
        filterQuality: filterQuality);
  }
}
