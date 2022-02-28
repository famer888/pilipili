import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:youyutv/components/common/pullrefreshlist.dart';
import 'package:youyutv/components/page_status.dart';
import 'package:youyutv/global.dart';
import 'package:youyutv/model/homedata.dart';
import 'package:youyutv/routers.dart';
import 'package:youyutv/store/homeConfig.dart';
import 'package:youyutv/theme/default.dart';
import 'package:youyutv/utils/index.dart';
import 'package:youyutv/utils/networkImage.dart';

class Wode extends StatefulWidget {
  Wode({Key key, this.isShow = false}) : super(key: key);
  final bool isShow;
  @override
  _WodeState createState() => _WodeState();
}

class _WodeState extends State<Wode> {
  int pageStatus = 0;

  @override
  void initState() {
    // TODO: implement initState 
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    EventBus().off('need-update-login-state');
  }

  @override
  void didUpdateWidget(covariant Wode oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isShow && pageStatus == 0) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: Text(
        '我的',
        style: DefaultStyle.black18bold,
      ),
    ));
  }
}
