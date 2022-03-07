import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController myController = TextEditingController();
  String prevText;
  List historyTags = [];
  bool loading = false;
  List tabList = [
    {
      'id': 1,
      'name': '影片',
    },
    {
      'id': 2,
      'name': '短视频',
    },
    {
      'id': 3,
      'name': '漫画',
    },
    {
      'id': 4,
      'name': '小说',
    }
  ];
  Widget _searchHead() {
    return Container(
      height: ScreenUtil().setWidth(50) + ScreenUtil().statusBarHeight,
      padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
      color: Color(0xffFF84A9),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: DefaultStyle.pagePadding,
                vertical: ScreenUtil().setWidth(5)),
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Image.asset('assets/images/backarrow.png',
                  height: ScreenUtil().setWidth(22)),
            ),
          ),
          Expanded(
              child: Container(
            height: ScreenUtil().setWidth(36),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                color: Colors.white),
            child: TextField(
              autofocus: true,
              // onSubmitted: _onSubmit,
              controller: myController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: '请输入搜索内容',
                hintStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(14),
                    fontWeight: FontWeight.bold,
                    color: Color(0xff6D6D6D)),
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                prefixIcon: Padding(
                  child: Image.asset(
                    'assets/images/icon_search.png',
                    color: Color(0xffFF84A9),
                  ),
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(10),
                      right: ScreenUtil().setWidth(10)),
                ),
                prefixIconConstraints: BoxConstraints(
                  maxHeight: ScreenUtil().setWidth(30),
                  maxWidth: ScreenUtil().setWidth(40),
                ),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 0)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 0)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 0)),
              ),
              style: TextStyle(
                color: Color(0xffc9caff),
                fontSize: ScreenUtil().setSp(14),
              ),
            ),
          )),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: DefaultStyle.pagePadding,
                vertical: ScreenUtil().setWidth(5)),
            child: GestureDetector(
              onTap: () {
                if (myController.text.isEmpty) {
                  CommonUtils.showText('请输入搜索关键字～');
                  return;
                }
                if (prevText == myController.text) return;
                prevText = myController.text;
                loading = true;
                if (historyTags.indexOf(myController.text) == -1) {
                  historyTags.add(myController.text);
                  AppGlobal.appBox.put('search_history', historyTags);
                }
                setState(() {});
                Timer(Duration(milliseconds: 200), () {
                  loading = false;
                  setState(() {});
                });
              },
              child: Text(
                '搜索',
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(18), color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _searchHead(),
        Expanded(
            child: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16),
                    vertical: ScreenUtil().setWidth(8)),
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(6)),
                height: ScreenUtil().setWidth(280),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurStyle: BlurStyle.outer,
                      color: Color.fromRGBO(255, 91, 140, 0.2),
                      offset: Offset(0, ScreenUtil().setWidth(6)),
                    )
                  ],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        ScreenUtil().setWidth(30),
                      ),
                      bottomRight: Radius.circular(
                        ScreenUtil().setWidth(30),
                      )),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      '搜索记录',
                      style: TextStyle(
                          color: Color(0xff6D6D6D),
                          fontSize: ScreenUtil().setSp(14),
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '热门标签',
                      style: TextStyle(
                          color: Color(0xff6D6D6D),
                          fontSize: ScreenUtil().setSp(14),
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
                      child: Wrap(
                        spacing: ScreenUtil().setWidth(8),
                        runSpacing: ScreenUtil().setWidth(12),
                        children: List(20)
                            .asMap()
                            .keys
                            .map((e) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      height: ScreenUtil().setWidth(28),
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              ScreenUtil().setWidth(14)),
                                      decoration: BoxDecoration(
                                          color: Color(0xffFFF5F9),
                                          borderRadius: BorderRadius.circular(
                                              ScreenUtil().setWidth(14))),
                                      child: Text(
                                        e.toString(),
                                        style: TextStyle(
                                          color: Color(0xffFFADC6),
                                          fontSize: ScreenUtil().setSp(14),
                                        ),
                                      ),
                                    )
                                  ],
                                ))
                            .toList(),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: UnitPersistentHeaderDelegate(),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                  left: DefaultStyle.pagePadding,
                  right: DefaultStyle.pagePadding,
                  top: ScreenUtil().setWidth(23),
                  bottom: ScreenUtil().statusBarHeight),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //Grid按两列显示
                  mainAxisSpacing: ScreenUtil().setWidth(12),
                  crossAxisSpacing: ScreenUtil().setWidth(12),
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Container(
                      width: 20,
                      height: 20,
                      color: Colors.red,
                    );
                  },
                  childCount: 20,
                ),
              ),
            )
          ],
        ))
      ],
    ));
  }
}

class UnitPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    print(
        "=====shrinkOffset:$shrinkOffset======overlapsContent:$overlapsContent====");
    final String info = 'shrinkOffset:${shrinkOffset.toStringAsFixed(1)}'
        '\noverlapsContent:$overlapsContent';
    return Container(
      alignment: Alignment.center,
      height: ScreenUtil().setWidth(50),
      color: Colors.red,
    );
  }

  @override
  double get maxExtent => ScreenUtil().setWidth(50);

  @override
  double get minExtent => ScreenUtil().setWidth(50);

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
