import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/theme/default.dart';

class Comicsdetail extends StatefulWidget {
  const Comicsdetail({Key key}) : super(key: key);

  @override
  _ComicsdetailState createState() => _ComicsdetailState();
}

class _ComicsdetailState extends State<Comicsdetail> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              primary: false,
              leading: Container(),
              pinned: false,
              elevation: 0,
              forceElevated: true,
              expandedHeight: ScreenUtil().setWidth(230),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Image.network(
                  "https://www.meishujixun.com/uploads/9a21a34e7d12c47a97a05034849faca9.jpg",
                  width: ScreenUtil().screenWidth,
                  height: ScreenUtil().setWidth(230),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                  horizontal: DefaultStyle.pagePadding,
                  vertical: ScreenUtil().setWidth(15)),
              sliver: Container(
                color: Colors.red,
                height: 2000,
              ),
            )
          ],
        )
      ],
    );
  }
}
