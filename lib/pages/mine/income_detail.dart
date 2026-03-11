import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';

class IncomeDetail extends StatefulWidget {
  const IncomeDetail({Key? key}) : super(key: key);

  @override
  State<IncomeDetail> createState() => _IncomeDetailState();
}

class _IncomeDetailState extends State<IncomeDetail> {
    // 辅助函数，确保月份和日期是两位数
String _twoDigits(int n) {
  if (n >= 10) {
    return '$n';
  }
  return '0$n';
}
String getDate(String date){
  // 解析日期字符串
  DateTime dateTime = DateTime.parse(date);

  // 格式化为所需的日期字符串格式（yyyy-MM-dd）
  String formattedDate = '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
  return formattedDate;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(paddingTop: ScreenUtil().statusBarHeight, title: '收益明細'),
          Expanded(
              child: PublicBuildList(
                  api: '/api/community/revenue_list',
                  isShow: true,
                  data: {},
                  itemBuild: (context, index, data, page, limit, getListData) {
                    return Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom: BorderSide(
                                  width: 0.5.w, color: Color(0xffECECEC)))),
                      child: DefaultTextStyle(
                          style: TextStyle(
                              color: Color(0xff6D6D6D),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'].toString(),
                                style: TextStyle(
                                    color: Color(0xff404040),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 6.w,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('日期'),
                                  Text(
                                   getDate(data['created_at']),
                                    style: TextStyle(color: Color(0xff979797)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6.w,
                              ),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text('金額'),
                              //     Text(
                              //       data['coinCnt'],
                              //       style: TextStyle(color: Color(0xff979797)),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(
                              //   height: 6.w,
                              // ),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text('平台費'),
                              //     Text(
                              //       '-250',
                              //       style: TextStyle(color: Color(0xff979797)),
                              //     ),
                              //   ],
                              // ),
                              SizedBox(
                                height: 6.w,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(data['type_str'].toString()),
                                  Text(
                                    data['coinCnt'],
                                    style: TextStyle(
                                        color: Color(0xffFF84A9),
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              )
                            ],
                          )),
                    );
                  }))
        ],
      ),
    );
  }
}
