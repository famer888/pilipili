import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/theme/default.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/utils/logUtilS.dart';
import 'package:pilipili/utils/networkImage.dart';
import '../utils/api.dart';

class ActivityList extends StatefulWidget {
  ActivityList({Key key}) : super(key: key);
  @override
  State<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  bool loading = true;
  List listData;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() {
    getActivityList().then((res) {
      LogUtilS.d(res['data']);
      if (res != null && res['data'] != null) {
        setState(() {
          listData = res['data'];
        });
      }
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    });
  }

  Widget renderItem(Map _data) {
    return GestureDetector(
      onTap: () {
        context.push(CommonUtils.getRealHash(
            'activityDetail/' + _data['id'].toString()));
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(255, 91, 140, 0.2),
                  offset: Offset(0, 2),
                  blurRadius: 3,
                  spreadRadius: 0)
            ],
            borderRadius:
                BorderRadius.all(Radius.circular(ScreenUtil().setWidth(5)))),
        margin: EdgeInsets.only(bottom: DefaultStyle.pagePadding),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width:
                      (ScreenUtil().screenWidth - DefaultStyle.pagePadding * 2),
                  height: (ScreenUtil().screenWidth -
                          DefaultStyle.pagePadding * 2) *
                      0.37,
                  child: PlatformAwareNetworkImage(
                    url: _data["resource"][0]['url'],
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width:
                      (ScreenUtil().screenWidth - DefaultStyle.pagePadding * 2),
                  color: Colors.white,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(6),
                      horizontal: ScreenUtil().setWidth(6)),
                  child: Text(
                    _data['title'],
                    // _data['desc'].split('：')[1],
                    style: TextStyle(
                      color: Color(0xff979797),
                      fontSize: ScreenUtil().setSp(12),
                    ),
                  ),
                ),
              ],
            ),
            _data['status'] == 1
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: PlatformAwareAssetImage(
                        url: "assets/images/icon_ing.png",
                        width: ScreenUtil().setWidth(50),
                        fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.medium))
                : Container()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: "精彩活动",
          ),
          Expanded(
              child: loading
                  ? PageStatus.loading(mounted)
                  : listData.length == 0
                      ? PageStatus.noData()
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(DefaultStyle.pagePadding),
                          child: Column(
                            children:
                                listData.map((e) => renderItem(e)).toList(),
                          ),
                        ))
        ],
      ),
    );
  }
}
