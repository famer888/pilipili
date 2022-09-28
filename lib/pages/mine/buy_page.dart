import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/card/youxuan_card.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

class BuyPage extends StatefulWidget {
  BuyPage({Key key}) : super(key: key);

  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> with TickerProviderStateMixin {
  final myController = TextEditingController();
  TabController _tabController;
  int currentTab = 0;
  List tabList = [
    {
      'id': 1,
      'name': '次元精选',
      'index': 1,
      'api': '/api/user/getUserBuy',
      'row': 2,
      'aspectRatio': 1.2
    },
    {
      'id': 11,
      'name': '次元竖屏',
      'index': 2,
      'api': '/api/user/getUserBuy',
      'row': 3,
      'aspectRatio': 0.61
    },
    {
      'id': 1,
      'name': '动漫',
      'index': 3,
      'api': '/api/user/getUserBuy',
      'row': 2,
      'aspectRatio': 1.2
    },
    {
      'id': 99,
      'name': '合集包',
      'index': 4,
      'api': '/api/user/getUserBuy',
      'row': 1,
      'aspectRatio': null
    },
  ];


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
        return Hcard(
            maxLines: 1,
            width: ScreenUtil().setWidth(171.5),
            thumbUrl: CommonUtils.getThumb(data),
            contentType: 1,
            cardData: data,
            showField: 'title');
        break;
      case 99:
        return YouxuanCard(data: data, isHorizontal: data['type'] == 1);
        break;
      case 11:
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        PageTitleBar(
          paddingTop: ScreenUtil().statusBarHeight,
          title: '我的购买',
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(255, 91, 140, 0.1),
                    offset: Offset(0, 10),
                    blurRadius: 10,
                    spreadRadius: 0)
              ]),
              child: Theme(
                  data: ThemeData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: TabBar(
                    indicatorColor: Colors.transparent,
                    isScrollable: true,
                    labelColor: Colors.black,
                    controller: _tabController,
                    unselectedLabelColor: Colors.transparent,
                    labelPadding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(0),
                        horizontal: ScreenUtil().setWidth(6)),
                    // labelStyle: GVStyle.ts14_gray,
                    tabs: tabList.asMap().keys.map((e) {
                      return Container(
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
                      );
                    }).toList(),
                  )),
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
                          itemBuild:
                              (context, index, data, page, limit, getListData) {
                            return getCardType(tabList[e]['id'], data);
                          }),
                    );
                  }).toList()),
            ),
          ],
        ))
      ],
    ));
  }
}