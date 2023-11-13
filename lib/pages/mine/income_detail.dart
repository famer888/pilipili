import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';

class IncomeDetail extends StatefulWidget {
  const IncomeDetail({Key key}) : super(key: key);

  @override
  State<IncomeDetail> createState() => _IncomeDetailState();
}

class _IncomeDetailState extends State<IncomeDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '收益明細'
          ),
          Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 10,
                  itemBuilder: (context, index) {
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
                                '帖子名稱帖子名稱帖子名稱帖子名稱帖子名稱帖子名稱',
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
                                    '2019-03-02',
                                    style: TextStyle(color: Color(0xff979797)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6.w,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('販售金額'),
                                  Text(
                                    '500',
                                    style: TextStyle(color: Color(0xff979797)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6.w,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('平台費'),
                                  Text(
                                    '-250',
                                    style: TextStyle(color: Color(0xff979797)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6.w,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('淨收益'),
                                  Text(
                                    '-250',
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
