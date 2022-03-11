import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/invitionlist.dart';
import 'package:pilipili/utils/api.dart';

class InviteRecored extends StatefulWidget {
  InviteRecored({Key key}) : super(key: key);

  final Color baseColor = Color(0xff333333);

  @override
  _InviteRecoredState createState() => _InviteRecoredState();
}

class _InviteRecoredState extends State<InviteRecored> {
  List list = [];
  int currentPage = 1;
  int limit = 24;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getMoreData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getMoreData() async {
    var result = await getListInvition(page: currentPage, limit: limit);
    if (result?.status == 1) {
      isLoading = false;
      List resData = result.data.list == null ? [] : result.data.list;

      if (currentPage == 1) {
        list = resData;
      } else {
        list.addAll(resData);
      }
      setState(() {});
    }
  }

  _onRefreshPost() async {
    currentPage = 1;
    _getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        PageTitleBar(
          paddingTop: ScreenUtil().statusBarHeight,
          title: '邀请记录',
        ),
        Expanded(
            child: isLoading
                ? PageStatus.loading(mounted)
                : Column(
                    children: [
                      // Padding(
                      //   padding: EdgeInsets.all(ScreenUtil().setWidth(12.5)),
                      //   child: Row(
                      //     children: [
                      //       RecoredHeader(title: '用户昵称'),
                      //       RecoredHeader(title: '状态'),
                      //       RecoredHeader(title: '时间'),
                      //     ],
                      //   ),
                      // ),
                      Flexible(
                        child: PullRefreshList(
                          onRefresh: _onRefreshPost,
                          onLoading: () {
                            currentPage++;
                            _getMoreData();
                          },
                          child: list.length == 0
                              ? SingleChildScrollView(
                                  child: PageStatus.noData(text: '暂无邀请记录～'),
                                )
                              : ListView.builder(
                                  cacheExtent: ScreenUtil().screenHeight * 5,
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    return RecoredItem(
                                      item: list[index],
                                    );
                                  }),
                        ),
                      ),
                    ],
                  ))
      ],
    ));
  }
}

class RecoredItem extends StatelessWidget {
  final ListElement item;
  const RecoredItem({Key key, this.item}) : super(key: key);

  // String handleTime(time) {
  //   getTime(int _num) {
  //     return _num < 10 ? '0' + _num.toString() : _num;
  //   }

  //   var times = new DateTime.fromMillisecondsSinceEpoch(time * 1000);
  //   String cTime =
  //       '${getTime(times.hour)}-${getTime(times.minute)} ${getTime(times.minute)}:${getTime(times.second)}';
  //   return '$cTime';
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(bottom: BorderSide(width: 1, color: Color(0xffECECEC)))),
      child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(12.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nickname,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(16),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(8)),
                  Text(item.createdAt,
                      style: TextStyle(
                        color: Color(0xff979797),
                        fontSize: ScreenUtil().setSp(14),
                      ))
                ],
              ),
              Text(item.register,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.register == "未注册"
                        ? Color(0xffFF84A9)
                        : Color(0xffFE155B),
                    fontSize: ScreenUtil().setSp(14),
                  ))
            ],
          )),
    );
  }
}

// class RecoredValue extends StatelessWidget {
//   final String value;
//   const RecoredValue({Key key, this.value}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Text(
//         value,
//         textAlign: TextAlign.center,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: TextStyle(
//             fontSize: ScreenUtil().setSp(13),
//             fontWeight: FontWeight.w400,
//             color: Color(0xffd7d7d7)),
//       ),
//     );
//   }
// }

class RecoredHeader extends StatelessWidget {
  final String title;
  const RecoredHeader({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: ScreenUtil().setSp(15),
            fontWeight: FontWeight.w500,
            color: Colors.white),
      ),
    );
  }
}
