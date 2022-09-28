import 'package:flutter/material.dart';

import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

class CollectPage extends StatefulWidget {
  CollectPage({Key key}) : super(key: key);

  @override
  _CollectPageState createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage>
    with TickerProviderStateMixin {
  final myController = TextEditingController();
  TabController _tabController;
  int currentTab = 0;
  int limit = 24;
  List tabList = [
    {
      'id': 1,
      'name': '次元精选',
      'index': 1,
      'api': '/api/user/getUserFavor',
      'row': 2,
      'aspectRatio': 1.2
    },
    {
      'id': 10,
      'name': '次元竖屏',
      'index': 2,
      'api': '/api/user/getUserFavor',
      'row': 3,
      'aspectRatio': 0.61
    },
    {
      'id': 3,
      'name': '动漫',
      'index': 3,
      'api': '/api/user/getUserFavor',
      'row': 2,
      'aspectRatio': 1.2
    },
    {
      'id': 2,
      'name': '漫画',
      'index': 4,
      'api': '/api/user/getUserFavor',
      'row': 3,
      'aspectRatio': 0.61
    },
  ];

  Map<int, dynamic> dataList = {
    1: {"page": 1, "data": [], "isall": false, "isloading": true},
    2: {"page": 1, "data": [], "isall": false, "isloading": true},
    3: {"page": 1, "data": [], "isall": false, "isloading": true},
    4: {"page": 1, "data": [], "isall": false, "isloading": true},
  };

  @override
  void initState() {
    super.initState();

    /// 选项卡控制器
    _tabController = TabController(
      length: tabList.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.index.toDouble() == _tabController.animation.value) {
        setState(() {
          currentTab = _tabController.index;
        });
      }
    });
  }

  Widget getCardType(int id, dynamic data) {
    switch (id) {
      case 1:
        return Hcard(
            maxLines: 1,
            width: ScreenUtil().setWidth(171.5),
            thumbUrl: CommonUtils.getThumb(data),
            contentType: 1,
            cardData: data,
            showField: 'title');
        break;
      case 2:
        return Vcard(
          maxLines: 1,
          contentType: 2,
          width: ScreenUtil().setWidth(110.5),
          thumbUrl: CommonUtils.getThumb(data),
          cardData: data,
          showField: 'title',
        );
        break;
      case 10:
        return Vcard(
            maxLines: 1,
            isSearch: true,
            width: ScreenUtil().setWidth(110.5),
            thumbUrl: CommonUtils.getThumb(data),
            contentType: 7,
            cardData: data,
            showField: 'title');
        break;
      default:
        return Hcard(
            maxLines: 1,
            width: ScreenUtil().setWidth(171.5),
            thumbUrl: CommonUtils.getThumb(data),
            contentType: 1,
            cardData: data,
            showField: 'title');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '我的收藏',
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: ScreenUtil().setWidth(44),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(255, 91, 140, 0.1),
                      offset: Offset(0, 10),
                      blurRadius: 10,
                      spreadRadius: 0)
                ]),
                child: TabBar(
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.transparent,
                  labelPadding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(0),
                      horizontal: ScreenUtil().setWidth(3)),
                  controller: _tabController,
                  isScrollable: true,
                  tabs: tabList
                      .asMap()
                      .keys
                      .map((e) => Container(
                            height: ScreenUtil().setWidth(44),
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Opacity(
                                  opacity: e == currentTab ? 1 : 0,
                                  child: PlatformAwareAssetImage(
                                      url: "assets/images/icon_love_red2.png",
                                      width: ScreenUtil().setWidth(6),
                                      fit: BoxFit.fitWidth,
                                      filterQuality: FilterQuality.medium),
                                ),
                                Text(
                                  tabList[e]['name'],
                                  style: currentTab == e
                                      ? DefaultStyle.pink14bold
                                      : DefaultStyle.lgray14Bold,
                                ),
                                Opacity(
                                  opacity: 0,
                                  child: PlatformAwareAssetImage(
                                      url: "assets/images/icon_love_red2.png",
                                      width: ScreenUtil().setWidth(6),
                                      fit: BoxFit.fitWidth,
                                      filterQuality: FilterQuality.medium),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                    controller: _tabController,
                    children: tabList.asMap().keys.map<Widget>((e) {
                      return PageViewMixin(
                        child: PublicBuildList(
                            api: tabList[e]['api'],
                            isFlow: false,
                            isShow: true,
                            row: tabList[e]['row'],
                            aspectRatio: tabList[e]['aspectRatio'],
                            data: {
                              'category': tabList[e]['index'] == 3 ? 1 : null,
                              'type': tabList[e]['id']
                            },
                            itemBuild: (context, index, data, page, limit,
                                getListData) {
                              return getCardType(tabList[e]['id'], data);
                            }),
                      );
                    }).toList()),
              )
            ],
          ))
        ],
      ),
    );
  }
}
