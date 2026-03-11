import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/model/basic.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

class VipExchangePage extends StatefulWidget {
  const VipExchangePage({Key? key}) : super(key: key);

  @override
  State<VipExchangePage> createState() => _VipExchangePageState();
}

class _VipExchangePageState extends State<VipExchangePage> {
  List product = [];
  int page = 1;
  int limit = 50;
  List logs = [];
  bool onLoading = false;
  bool isAll = false;
  bool loading = true;
  getProduct() async {
    Basic res = await getProductOfGold(6);
    if (res.status != 0) {
      product = res.data['product'];
      setState(() {});
    } else {
      CommonUtils.showText(res.msg ?? '获取商品失败');
    }
  }

  getLogs() async {
    if (onLoading) return;
    onLoading = true;
    Basic res = await taskLogs(page, limit);
    onLoading = false;
    if (res.status != 0) {
      List _data = res.data ?? [];
      if (page == 1) {
        logs = _data;
      } else {
        logs.addAll(_data);
      }
      loading = false;
      isAll = _data.length < limit;
      setState(() {});
    } else {
      CommonUtils.showText(res.msg ?? '获取失败');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo(context);
    getProduct();
    getLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: "会员兑换",
          ),
          Expanded(
              child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 9.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 46.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7.5.w)),
                          child: Consumer<HomeConfig>(builder: (ctx, state, child) {
                            return Text.rich(TextSpan(
                                text: "当前积分：",
                                children: [
                                  TextSpan(
                                      text: "${state.userInfo.score}",
                                      style: TextStyle(
                                        color: Color(0xffff4c9a),
                                      ))
                                ],
                                style: TextStyle(color: Color(0xff2f2f2f), fontSize: 16.sp)));
                          }),
                        ),
                        if (product.isEmpty) PageStatus.noData(text: '没有兑换的商品'),
                        if (product.isNotEmpty)
                          GridView.builder(
                            itemCount: product.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 7.5.w,
                                mainAxisSpacing: 20.w,
                                childAspectRatio: 220 / 309),
                            itemBuilder: (context, index) {
                              Map item = product[index];
                              print(item);
                              return Column(
                                children: [
                                  Expanded(
                                      child: Container(
                                    padding: EdgeInsets.all(10.w),
                                    width: double.infinity,
                                    decoration:
                                        BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 45.w,
                                          height: 45.w,
                                          child: PlatformAwareNetworkImage(
                                            fit: BoxFit.fill,
                                            url: item['img'] ?? "",
                                          ),
                                        ),
                                        Text(
                                          '${item['coins']}积分',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Color(0xff999999), fontSize: 14.sp),
                                        ),
                                        Text(item['pname'] ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Color(0xff2f2f2f), fontSize: 16.sp)),
                                      ],
                                    ),
                                  )),
                                  SizedBox(
                                    height: 12.5.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      YyShowDialog.showdialog(context, title: '温馨提示', btnText: '确认', cancelText: '取消',
                                          callBack: () async {
                                        Basic res = await onOrderExchange(product_id: item['id']);
                                        if (res.status != 0) {
                                          CommonUtils.showText(res.msg ?? '兑换成功');
                                          getUserInfo(context);
                                          page = 1;
                                          isAll = false;
                                          getLogs();
                                        } else {
                                          CommonUtils.showText(res.msg ?? '兑换失败');
                                        }
                                      }, content: (setDialogState) {
                                        return Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(text: '是否使用 '),
                                              TextSpan(
                                                  text: '${item['coins']}',
                                                  style:
                                                      TextStyle(color: Color(0xffff4c9a), fontWeight: FontWeight.bold)),
                                              TextSpan(text: ' 积分,兑换 '),
                                              TextSpan(
                                                  text: '${item['pname']}',
                                                  style:
                                                      TextStyle(color: Color(0xffff4c9a), fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          style: TextStyle(color: Color(0xff2f2f2f), fontSize: 14.sp),
                                        );
                                      });
                                    },
                                    child: Container(
                                      width: 85.w,
                                      height: 32.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Color(0xffff4c52).withOpacity(0.14),
                                          borderRadius: BorderRadius.circular(16.w),
                                          border: Border.all(width: 1.w, color: Color(0xffff85a9))),
                                      child: Text(
                                        "兑换",
                                        style: TextStyle(color: Color(0xffff4c9a), fontSize: 14.sp),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                      ],
                    ),
                  ),
                )
              ];
            },
            body: Container(
              margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 28.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.w),
                    child: Text("兑换记录"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '兑换物品',
                          style: TextStyle(fontSize: 14.sp, color: Color(0xff999999)),
                        ),
                        Text('兑换时间', style: TextStyle(fontSize: 14.sp, color: Color(0xff999999))),
                      ],
                    ),
                  ),
                  Expanded(
                      child: loading
                          ? PageStatus.loading(true)
                          : PullRefreshList(
                              onLoading: isAll
                                  ? null
                                  : () {
                                      page++;
                                      getLogs();
                                    },
                              child: logs.isEmpty
                                  ? PageStatus.noData()
                                  : ListView.builder(
                                      itemCount: logs.length,
                                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0),
                                      itemBuilder: (context, index) {
                                        Map item = logs[index];
                                        return Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12.w),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('${item['type'] == 2 ? item['desc'] : item['source_name']}',
                                                      style: TextStyle(color: Color(0xff2f2f2f), fontSize: 16.sp)),
                                                  Text('${item['created_at']}',
                                                      style: TextStyle(color: Color(0xff2f2f2f), fontSize: 12.sp)),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 12.5.w,
                                              ),
                                              Text(
                                                '${item['type'] == 2 ? '-' : '+'}${item['coinCnt']}积分',
                                                style: TextStyle(color: Color(0xff777777), fontSize: 12.sp),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    )))
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
