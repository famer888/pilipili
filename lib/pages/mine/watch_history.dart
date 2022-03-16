import 'package:flutter/material.dart';
// import 'package:pilipili/components/card/comics_card.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

class WatchHistoryPage extends StatefulWidget {
  WatchHistoryPage({Key key}) : super(key: key);

  @override
  _WatchHistoryPageState createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends State<WatchHistoryPage>
    with TickerProviderStateMixin {
  final myController = TextEditingController();
  TabController _tabController;
  int currentTab = 0;
  List tabList = [
    {
      'id': 1,
      'name': '视频',
    },
    {
      'id': 2,
      'name': '漫画',
    },
    {
      'id': 3,
      'name': '小说',
    },
    {
      'id': 4,
      'name': '小视频',
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        PageTitleBar(
          title: '观看记录',
          paddingTop: ScreenUtil().statusBarHeight,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(
            //   height: ScreenUtil().setWidth(17.5),
            // ),
            Container(
              height: ScreenUtil().setWidth(44),
              // padding: EdgeInsets.only(left: ScreenUtil().setWidth(6)),
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
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Opacity(
                              opacity: currentTab == e ? 1 : 0,
                              child: Positioned(
                                top: 0,
                                child: Image.asset(
                                  'assets/images/vip_table_active.png',
                                  fit: BoxFit.fitHeight,
                                  height: ScreenUtil().setWidth(7),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(8)),
                              child: Text(
                                tabList[e]['name'],
                                style: currentTab == e
                                    ? DefaultStyle.pink14bold
                                    : DefaultStyle.lgray14Bold,
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  )),
            ),
            Expanded(
              child: TabBarView(
                  controller: _tabController,
                  children: tabList
                      .asMap()
                      .keys
                      .map((e) => PageViewMixin(
                            child: HistoryList(
                              type: tabList[e]['id'],
                            ),
                          ))
                      .toList()),
            )
          ],
        ))
      ],
    ));
  }
}

class HistoryList extends StatefulWidget {
  HistoryList({Key key, this.type}) : super(key: key);
  int type;
  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  List history = [];
  @override
  void initState() {
    super.initState();
    List boxdata;
    switch (widget.type) {
      case 1:
        boxdata = AppGlobal.videoWatchRecordBox.values.toList();
        break;
      case 2:
        boxdata = AppGlobal.manhuaWatchRecordBox.values.toList();
        break;
      case 3:
        boxdata = AppGlobal.bookWatchRecordBox.values.toList();
        break;
      default:
        boxdata = AppGlobal.smallVideoWatchRecordBox.values.toList();
    }
    boxdata.sort(
        (left, right) => right['recordTimer'].compareTo(left['recordTimer']));
    history = boxdata;
    setState(() {});
  }

  _videoList() {
    return GridView.builder(
        cacheExtent: ScreenUtil().screenHeight * 5,
        padding: EdgeInsets.symmetric(
            horizontal: DefaultStyle.pagePadding,
            vertical: ScreenUtil().setWidth(20)),
        itemCount: history.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: ScreenUtil().setWidth(20),
          crossAxisSpacing: ScreenUtil().setWidth(7),
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          return Hcard(
            width: ScreenUtil().setWidth(171.5),
            cardData: history[index],
            tagIconType: history[index]['isfree'],
            contentType: 1,
            thumbUrl: history[index]['thumb'],
            showField: 'title',
          );
        });
  }

  _smallVideoList() {
    return GridView.builder(
        cacheExtent: ScreenUtil().screenHeight * 5,
        padding: EdgeInsets.symmetric(
            horizontal: DefaultStyle.pagePadding,
            vertical: ScreenUtil().setWidth(20)),
        itemCount: history.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: ScreenUtil().setWidth(9.5),
          crossAxisSpacing: ScreenUtil().setWidth(9.5),
          childAspectRatio: 0.55,
        ),
        itemBuilder: (context, index) {
          return Vcard(
            width: ScreenUtil().setWidth(110.5),
            cardData: history[index],
            tagIconType: history[index]['isfree'],
            contentType: 7,
            isSearch: true,
            thumbUrl: history[index]['thumb'],
            showField: 'title',
          );
        });
  }

  _comicsList() {
    return GridView.builder(
        cacheExtent: ScreenUtil().screenHeight * 5,
        padding: EdgeInsets.symmetric(
            horizontal: DefaultStyle.pagePadding,
            vertical: ScreenUtil().setWidth(20)),
        itemCount: history.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: ScreenUtil().setWidth(9.5),
          crossAxisSpacing: ScreenUtil().setWidth(9.5),
          childAspectRatio: 0.55,
        ),
        itemBuilder: (context, index) {
          return Vcard(
            width: ScreenUtil().setWidth(110.5),
            cardData: history[index],
            tagIconType: history[index]['isfree'],
            contentType: 2,
            thumbUrl: history[index]['thumb'],
            showField: 'title',
          );
        });
  }

  _novelList() {
    return GridView.builder(
        cacheExtent: ScreenUtil().screenHeight * 5,
        padding: EdgeInsets.symmetric(
            horizontal: DefaultStyle.pagePadding,
            vertical: ScreenUtil().setWidth(20)),
        itemCount: history.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: ScreenUtil().setWidth(9.5),
          crossAxisSpacing: ScreenUtil().setWidth(9.5),
          childAspectRatio: 0.55,
        ),
        itemBuilder: (context, index) {
          return Vcard(
            width: ScreenUtil().setWidth(110.5),
            cardData: history[index],
            tagIconType: history[index]['isfree'],
            contentType: 3,
            // isNovel: true,
            showField: 'title',
          );
        });
  }

  // _voiceNovelList() {
  //   return ListView.builder(
  //       cacheExtent: ScreenUtil().screenHeight * 5,
  //       padding: EdgeInsets.symmetric(
  //           horizontal: DefaultStyle.pagePadding,
  //           vertical: ScreenUtil().setWidth(20)),
  //       itemCount: history.length,
  //       itemBuilder: (context, index) {
  //         return ComicsCard(
  //           thumbUrl: 'https://staff.tea123.me/e.jpg',
  //         );
  //       });
  // }

  getListWidget() {
    switch (widget.type) {
      case 1:
        return _videoList();
        break;
      case 2:
        return _comicsList();
        break;
      case 3:
        return _novelList();
        break;
      case 4:
        return _smallVideoList();
        break;
      default:
        return _comicsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return history == null || history.isEmpty
        ? PageStatus.noData()
        : getListWidget();
  }
}
