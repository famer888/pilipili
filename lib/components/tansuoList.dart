import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/pili/public_list.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

class TansuoList extends StatefulWidget {
  TansuoList({Key key}) : super(key: key);

  @override
  _TansuoListState createState() => _TansuoListState();
}

class _TansuoListState extends State<TansuoList> {
  PageController controller = PageController();
  List tabList = [
    {
      'name': '次元',
      'id': 0,
      'api': '/api/mv/getList',
      'pramas': {},
      'isFlow': true,
      'crossAxisCount': 2,
    },
    {
      'name': '动漫',
      'id': 1,
      'api': '/api/mv/getList',
      'cardType': 'h',
      'pramas': {'category': 1},
      'isFlow': false,
      'crossAxisCount': 2,
    },
    {
      'name': '漫画',
      'id': 2,
      'cardType': 'v',
      'api': '/api/book/getList',
      'pramas': {'type': 1},
      'isFlow': false,
      'crossAxisCount': 3,
      'width': 109
    }
  ];
  int currentTab = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
              top: DefaultStyle.navbarHegiht +
                  MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(255, 128, 163, 0.5),
                offset: Offset(0, 2),
                blurRadius: 3,
                spreadRadius: 0)
          ]),
          child: Row(
            children: tabList.asMap().keys.map<Widget>((e) {
              return GestureDetector(
                onTap: () {
                  currentTab = tabList[e]['id'];
                  controller.jumpToPage(currentTab);
                  setState(() {});
                },
                child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
                    child: Column(
                      children: [
                        Opacity(
                          opacity: currentTab == e ? 1 : 0,
                          child: PlatformAwareAssetImage(
                              url: 'assets/images/icon_love_red.png',
                              width: ScreenUtil().setWidth(6),
                              filterQuality: FilterQuality.medium),
                        ),
                        Text(
                          tabList[e]['name'],
                          style: TextStyle(
                              color: currentTab == tabList[e]['id']
                                  ? Color(0xffff5b8c)
                                  : Color(0xffc2c2c2),
                              height: 1),
                        )
                      ],
                    )),
              );
            }).toList(),
          ),
        ),
        Expanded(
            child: PageView(
          controller: controller,
          onPageChanged: (e) {
            currentTab = e;
            setState(() {});
          },
          children: tabList.asMap().keys.map((e) {
            return PageViewMixin(
              child: PublicList(
                cartType: tabList[e]['cardType'],
                isFlow: tabList[e]['isFlow'],
                noRefresh: true,
                crossAxisCount: tabList[e]['crossAxisCount'],
                contentType: e == 2 ? 2 : null,
                data: tabList[e]['pramas'],
                api: tabList[e]['api'],
                width: tabList[e]['width'],
                limit: 30,
                isShow: e == currentTab,
              ),
            );
          }).toList(),
        ))
      ],
    );
  }
}
