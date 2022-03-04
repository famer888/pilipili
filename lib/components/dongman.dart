import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pilipili/model/element.dart';
import 'package:pilipili/theme/default.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/routers.dart';

class Dongman extends StatefulWidget {
  Dongman({Key key, this.isShow}) : super(key: key);
  bool isShow;
  @override
  _DongmanState createState() => _DongmanState();
}

class _DongmanState extends State<Dongman> {
  List<LinkModel> navitems;
  List pages;
  int pageStatus = 0;
  bool networkErr = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Dongman oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && pageStatus == 0) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: GestureDetector(
        onTap: () {
          context.push("/${Routes.xianmian}");
        },
        child: Text(
          '动漫',
          style: DefaultStyle.black18bold,
        ),
      ),
    ));
  }
}
