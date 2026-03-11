import 'package:flutter/material.dart';

import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/model/coindetail.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/utils/pp_string.dart';

class CoinDetail extends StatefulWidget {
  const CoinDetail({Key? key}) : super(key: key);

  @override
  _CoinDetailState createState() => _CoinDetailState();
}

class _CoinDetailState extends State<CoinDetail> {
  String type = '';
  int limit = 15;
  bool filterShow = false;
  List arrayDetial = [];
  bool isLoading = true;
  bool isAll = false;
  int page = 1;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    CoinDetialModel result =
        await getListMoneyDetail(page: page, type: type, limit: limit);
    if (result.status != 0) {
      isAll = result.data!.length < limit;
      List resdata = result.data ?? [];
      isLoading = false;
      if (page == 1) {
        arrayDetial = resdata;
      } else {
        arrayDetial.addAll(resdata);
      }
      setState(() {});
    } else {
      CommonUtils.showText(result.msg!);
    }
  }

  Widget coinItem(Datum itemdata) {
    return Container(
      padding: EdgeInsets.all(DefaultStyle.pagePadding),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Color(0xffECECEC), width: 0.6))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(itemdata.sourceStr.toString(), style: DefaultStyle.black16bold),
              SizedBox(
                height: ScreenUtil().setWidth(6),
              ),
              Text(itemdata.createdAt.toString(),
                  style: TextStyle(
                      color: Color.fromRGBO(151, 151, 151, 1),
                      fontSize: ScreenUtil().setSp(14))),
            ],
          )),
          Text(
            (itemdata.type == 1 ? PPString.add : PPString.reduce).toString() +
                ' ' +
                itemdata.coin.toString(),
            style: TextStyle(
                color: itemdata.type == 1
                    ? DefaultStyle.themeColor
                    : Color.fromRGBO(254, 21, 91, 1),
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setSp(14)),
          )
        ],
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
            title: '皮哩币明细',
          ),
          Expanded(
              child: isLoading
                  ? PageStatus.loading(mounted)
                  : PullRefreshList(
                      onRefresh: () {
                        page = 1;
                        getData();
                      },
                      onLoading: () {
                        if (isAll) {
                          CommonUtils.showText('已经到底了哦～');
                          return;
                        }
                        page++;
                        getData();
                      },
                      child: arrayDetial.length == 0
                          ? SingleChildScrollView(
                              child: PageStatus.noData(),
                            )
                          : ListView.builder(
                              cacheExtent: ScreenUtil().screenHeight * 5,
                              padding: EdgeInsets.all(ScreenUtil()
                                  .setWidth(DefaultStyle.pagePadding)),
                              itemCount: arrayDetial.length,
                              itemBuilder: (BuildContext contenxt, int index) {
                                return coinItem(
                                  arrayDetial[index],
                                );
                              },
                            ),
                    ))
        ],
      ),
    );
  }
}
