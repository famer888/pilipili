import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';

class WithdrawalsRecord extends StatefulWidget {
  const WithdrawalsRecord({Key key}) : super(key: key);

  @override
  State<WithdrawalsRecord> createState() => _WithdrawalsRecordState();
}

class _WithdrawalsRecordState extends State<WithdrawalsRecord> {
  static TextStyle titleStyle = TextStyle(
      fontSize: 14.sp, fontWeight: FontWeight.w400, color: Color(0xff6D6D6D));
  static TextStyle subTextStyle = TextStyle(
      fontSize: 14.sp, fontWeight: FontWeight.w400, color: Color(0xff979797));

  Widget witdraStatus(int status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color:status%2==1? Color(0xffFF84A9):Color(0xffFE155B), borderRadius: BorderRadius.circular(5.w)),
      child: Text(
       status%2==1?'通过' :'待审核',
        style: TextStyle(
            color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(paddingTop: ScreenUtil().statusBarHeight, title: '提交紀錄'),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '日期',
                                        style: titleStyle,
                                      ),
                                      SizedBox(
                                        width: 8.w,
                                      ),
                                      Text(
                                        '2019-03-02',
                                        style: subTextStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '狀態:',
                                        style: titleStyle,
                                      ),
                                      SizedBox(
                                        width: 8.w,
                                      ),
                                      witdraStatus(index),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 8.w,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '金額',
                                        style: titleStyle,
                                      ),
                                      SizedBox(
                                        width: 8.w,
                                      ),
                                      Text(
                                        '500',
                                        style: subTextStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'VISA:',
                                        style: titleStyle,
                                      ),
                                      SizedBox(
                                        width: 8.w,
                                      ),
                                      Text(
                                        '324650***341',
                                        style: subTextStyle,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 8.w,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '提領方式',
                                        style: titleStyle,
                                      ),
                                      SizedBox(
                                        width: 8.w,
                                      ),
                                      Text(
                                        '銀行卡',
                                        style: subTextStyle,
                                      ),
                                    ],
                                  ),
                                  SizedBox()
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
