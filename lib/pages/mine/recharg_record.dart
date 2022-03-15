import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/coinorvip.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/privilege.dart';

class RechargeRecord extends StatefulWidget {
  final Map args;
  RechargeRecord({Key key, this.args}) : super(key: key);

  @override
  _RechargeRecordState createState() => _RechargeRecordState();
}

class _RechargeRecordState extends State<RechargeRecord> {
  List recordList = [];
  bool isLoading = true;
  bool networkErr = false;
  bool isAll = false;
  int page = 1;
  int limit = 15;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    if (widget?.args['type'] == null) {
      isLoading = false;
      recordList = [];
      setState(() {});
      // 1 vip 2 GOLD
      CommonUtils.showText('请传入type');
      return;
    }
    CoinOrVipModel result = await getOrderList(
        page: page, type: widget?.args['type'], limit: limit);
    if (result == null) {
      networkErr = true;
      setState(() {});
      return;
    }
    if (result.status != 0) {
      List resData = result.data == null ? [] : result.data;
      isAll = resData.length < limit;
      if (page == 1) {
        recordList = resData;
      } else {
        recordList.addAll(resData);
      }
      isLoading = false;
      setState(() {});
    } else {
      CommonUtils.showText(result.msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleBar(
              title: '充值记录',
              rightWidget: GestureDetector(
                onTap: () {
                  if (Privilege.isAllowed(
                      context, RESOURCE_TYPE_SYSTEM, PRIVILEGE_TYPE_FEED)) {
                    context.push(CommonUtils.getRealHash('customerService'));
                  } else {
                    CommonUtils.showText('哥哥~开启1V1服务需要会员呢！您好像没有哦~');
                  }
                },
                child: Container(
                  width: ScreenUtil().setWidth(69.5),
                  height: ScreenUtil().setWidth(18),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: ScreenUtil().setWidth(0.5),
                          color: Color(0xff7bf7ff)),
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(9))),
                  child: Center(
                    child: Text(
                      '联系客服',
                      style: TextStyle(
                          color: Color(0xff7bf7ff),
                          fontSize: ScreenUtil().setSp(11)),
                    ),
                  ),
                ),
              )),
          Expanded(
            child: networkErr
                ? Container(
                    width: double.infinity,
                    child: PageStatus.noNetWork(onTap: () {
                      networkErr = false;
                      setState(() {});
                      getData();
                    }),
                  )
                : isLoading
                    ? PageStatus.loading(mounted)
                    : PullRefreshList(
                        onRefresh: () {
                          page = 1;
                          getData();
                        },
                        onLoading: () {
                          if (isAll) {
                            CommonUtils.showText('已经没有更多记录啦~');
                            return;
                          }
                          page++;
                          getData();
                        },
                        child: recordList.length == 0
                            ? SingleChildScrollView(
                                child: PageStatus.noData(text: '您还没有充值记录'),
                              )
                            : ListView.builder(
                                cacheExtent: ScreenUtil().screenHeight * 5,
                                padding: EdgeInsets.all(ScreenUtil()
                                    .setWidth(DefaultStyle.pagePadding)),
                                itemCount: recordList.length,
                                itemBuilder:
                                    (BuildContext contenxt, int index) {
                                  return OrderItem(
                                    orderData: recordList[index],
                                  );
                                },
                              ),
                      ),
          ),
        ],
      )),
    );
  }
}

class OrderItem extends StatelessWidget {
  final Datum orderData;
  const OrderItem({Key key, this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(18.5),
          horizontal: ScreenUtil().setWidth(14)),
      decoration: ShapeDecoration(
          shape: BeveledRectangleBorder(
              side: BorderSide(
                  width: ScreenUtil().setWidth(0.5), color: Color(0xffd7d7d7)),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(ScreenUtil().setWidth(10)),
                  topRight: Radius.circular(ScreenUtil().setWidth(10))))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '订单编号：${orderData?.id}',
                style: DefaultStyle.lgray12,
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: '订单编号：${orderData?.id}'));
                  CommonUtils.showText('复制成功');
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/pengke/user/clipboard_icon.png',
                      width: ScreenUtil().setWidth(15),
                      height: ScreenUtil().setWidth(10),
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(6),
                    ),
                    Text(
                      '复制单号',
                      style: TextStyle(
                          color: Color(0xff7bf7ff),
                          fontSize: ScreenUtil().setSp(12),
                          overflow: TextOverflow.ellipsis,
                          decoration: TextDecoration.none),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: ScreenUtil().setWidth(10),
          ),
          CustomPaint(
            size: Size(double.infinity, ScreenUtil().setWidth(0.5)),
            painter: CurvePainter(),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(14.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${orderData?.descp}',
                style: DefaultStyle.white16bold,
              ),
              Text('${orderData?.amount}', style: DefaultStyle.white16bold),
            ],
          ),
          SizedBox(
            height: ScreenUtil().setWidth(11.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${orderData?.createdAt}', style: DefaultStyle.lgray12),
              Text(
                '${orderData?.statusText}',
                style: DefaultStyle.lgray12,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.black12;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height / 2, size.width, 0);
    path.quadraticBezierTo(size.width / 2, -size.height / 2, 0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
