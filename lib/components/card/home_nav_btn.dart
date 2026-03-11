import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/mixin/cardMixin.dart';
import 'package:pilipili/utils/networkImage.dart';

class HomeNavBtn extends StatefulWidget {
  HomeNavBtn(
      {Key? key,
      this.cardData,
      this.contentType,
      this.id,
      this.replace = false,
      this.page})
      : super(key: key);
  final dynamic cardData;
  final int? contentType;
  final dynamic id;
  final bool replace;
  final int? page;
  @override
  _HomeNavBtnState createState() => _HomeNavBtnState();
}

class _HomeNavBtnState extends State<HomeNavBtn> with CardMixin {
  @override
  Widget build(BuildContext context) {
    return callDetail(
        contentType: widget.contentType,
        cardData: widget.cardData,
        widget: widget,
        replace: widget.replace,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: PlatformAwareAssetImage(
                    url: 'assets/images/btn_bg.png',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium)),
            Container(
              width: ScreenUtil().setWidth(79),
              height: ScreenUtil().setWidth(51),
              padding: EdgeInsets.only(
                  right: ScreenUtil().setWidth(3),
                  bottom: ScreenUtil().setWidth(3)),
              alignment: Alignment.center,
              child: Text(
                widget.cardData['name'],
                style: TextStyle(
                    color: Color(0xffc8003c),
                    fontSize: ScreenUtil().setSp(16),
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ));
  }
}
