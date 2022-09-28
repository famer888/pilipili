import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/card/youxuan_card.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
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
      'api':'/api/user/getUserBuy'
    },
    {
      'id': 11,
      'name': '次元竖屏',
      'index': 2,
      'api':'/api/user/getUserBuy'
    },
    {
      'id': 1,
      'name': '动漫',
      'index': 3,
      'api':'/api/user/getUserBuy'
    },
    {
      'id': 99,
      'name': '合集包',
      'index': 4,
      'api':'/api/user/getUserBuy'
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
        onTabsChange(_tabController.index + 1);
      }
    });
    initBuyData();
  }

  initBuyData() async {
    var result = await getUserBuy(page: 1, type: tabList[0]['id']);
    if (result['data'] != null && result['data'].length > 0) {
      setState(() {
        dataList[1]['data'] = result['data'];
        dataList[1]['isloading'] = false;
      });
      if (result['data'].length < 24) {
        setState(() {
          dataList[1]['isall'] = true;
        });
      }
    } else {
      setState(() {
        dataList[1]['isall'] = true;
        dataList[1]['isloading'] = false;
      });
    }
  }

  onTabsChange(int index) async {
    if (dataList[index]['data'].length == 0 &&
        dataList[index]['isall'] == false) {
      var result = await getUserBuy(
          category: index == 3 ? 1 : null,
          page: 1,
          type: tabList[index - 1]['id']);
      if (result['data'] != null && result['data'].length > 0) {
        setState(() {
          dataList[index]['data'] = result['data'];
          dataList[index]['isloading'] = false;
        });
        if (result['data'].length < 24) {
          setState(() {
            dataList[index]['isall'] = true;
          });
        }
      } else {
        setState(() {
          dataList[index]['isall'] = true;
          dataList[index]['isloading'] = false;
        });
      }
    }
  }

  _onRefreshPost(int index) async {
    setState(() {
      dataList[index]['isloading'] = true;
    });
    dataList[index]['page'] = 1;
    var result = await getUserBuy(
        category: index == 3 ? 1 : null,
        page: dataList[index]['page'],
        type: tabList[index - 1]['id']);
    if (result['data'] != null && result['data'].length > 0) {
      setState(() {
        dataList[index]['data'] = result['data'];
        dataList[index]['isloading'] = false;
      });
      if (result['data'].length < 24) {
        setState(() {
          dataList[index]['isall'] = true;
        });
      } else {
        setState(() {
          dataList[index]['isall'] = false;
        });
      }
    } else {
      setState(() {
        dataList[index]['isall'] = true;
        dataList[index]['isloading'] = false;
      });
    }
  }

  _onLoading(int index) async {
    if (dataList[index]['isall'] == false) {
      dataList[index]['page']++;
      var result = await getUserBuy(
          category: index == 3 ? 1 : null,
          page: dataList[index]['page'],
          type: tabList[index - 1]['id']);
      if (result['data'] != null && result['data'].length > 0) {
        setState(() {
          dataList[index]['data'].addAll(result['data']);
          dataList[index]['isloading'] = false;
        });
        if (result['data'].length < 24) {
          setState(() {
            dataList[index]['isall'] = true;
          });
        } else {
          setState(() {
            dataList[index]['isall'] = false;
          });
        }
      } else {
        setState(() {
          dataList[index]['isall'] = true;
          dataList[index]['isloading'] = false;
        });
      }
    } else {
      CommonUtils.showText("已加载全部 "+tabList[index - 1]['name'].toString());
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
                  children: tabList
                      .map(
                        (e) => PageViewMixin(
                          key: Key('collectList'+e['id'].toString()+'-'+e['name'].toString()),
                          child: BuyList(
                            index: e['index'],
                            type: e['id'],
                            dataList: dataList,
                            onRefreshPost: _onRefreshPost,
                            onLoading: _onLoading,
                          ),
                        ),
                      )
                      .toList()),
            ),
          ],
        ))
      ],
    ));
  }
}

class BuyList extends StatefulWidget {
  final int type;
  final int index;
  final Map<int, dynamic> dataList;
  final Function onRefreshPost;
  final Function onLoading;
  BuyList(
      {Key key,
      this.type,
      this.dataList,
      this.onRefreshPost,
      this.onLoading,
      this.index})
      : super(key: key);

  @override
  _BuyListState createState() => _BuyListState();
}

class _BuyListState extends State<BuyList> {
  Widget _videoList() {
    return widget.dataList[widget.index]['isloading']
        ? PageStatus.loading(mounted)
        : PullRefreshList(
            onRefresh: () {
              widget.onRefreshPost(widget.index);
            },
            onLoading: () {
              widget.onLoading(widget.index);
            },
            child: widget.dataList[widget.index]['data'].length == 0
                ? SingleChildScrollView(
                    child: PageStatus.noData(text: '您还没有购买视频'),
                  )
                : GridView.builder(
                    cacheExtent: ScreenUtil().screenHeight * 5,
                    padding: EdgeInsets.symmetric(
                        horizontal: DefaultStyle.pagePadding,
                        vertical: ScreenUtil().setWidth(20)),
                    itemCount: widget.dataList[widget.index]['data'].length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: ScreenUtil().setWidth(10),
                      crossAxisSpacing: ScreenUtil().setWidth(7),
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      return Hcard(
                          maxLines: 1,
                          width: ScreenUtil().setWidth(171.5),
                          thumbUrl: CommonUtils.getThumb(
                              widget.dataList[widget.index]['data'][index]),
                          contentType: 1,
                          cardData: widget.dataList[widget.index]['data']
                              [index],
                          showField: 'title');
                    }));
  }

  Widget _smallVideoList() {
    return widget.dataList[widget.index]['isloading']
        ? PageStatus.loading(mounted)
        : PullRefreshList(
            onRefresh: () {
              widget.onRefreshPost(widget.index);
            },
            onLoading: () {
              widget.onLoading(widget.index);
            },
            child: widget.dataList[widget.index]['data'].length == 0
                ? SingleChildScrollView(
                    child: PageStatus.noData(text: '您还没有购买短视频'),
                  )
                : GridView.builder(
                    cacheExtent: ScreenUtil().screenHeight * 5,
                    padding: EdgeInsets.symmetric(
                        horizontal: DefaultStyle.pagePadding,
                        vertical: ScreenUtil().setWidth(20)),
                    itemCount: widget.dataList[widget.index]['data'].length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: ScreenUtil().setWidth(9.5),
                      crossAxisSpacing: ScreenUtil().setWidth(9.5),
                      childAspectRatio: 0.61,
                    ),
                    itemBuilder: (context, index) {
                      return Vcard(
                          maxLines: 1,
                          isSearch: true,
                          width: ScreenUtil().setWidth(110.5),
                          thumbUrl: CommonUtils.getThumb(
                              widget.dataList[widget.index]['data'][index]),
                          contentType: 7,
                          cardData: widget.dataList[widget.index]['data']
                              [index],
                          showField: 'title');
                    }));
  }

  Widget _youxuanList() {
    return widget.dataList[widget.index]['isloading']
        ? PageStatus.loading(mounted)
        : PullRefreshList(
            onRefresh: () {
              widget.onRefreshPost(widget.index);
            },
            onLoading: () {
              widget.onLoading(widget.index);
            },
            child: widget.dataList[widget.index]['data'].length == 0
                ? SingleChildScrollView(
                    child: PageStatus.noData(text: '您还没有购买打折包包哦～'),
                  )
                : ListView.builder(
                    cacheExtent: ScreenUtil().screenHeight * 5,
                    padding: EdgeInsets.symmetric(
                        vertical: DefaultStyle.pagePadding,
                        horizontal: DefaultStyle.pagePadding),
                    itemCount: widget.dataList[widget.index]['data'].length,
                    itemBuilder: (BuildContext context, int index) {
                      return YouxuanCard(
                          data: widget.dataList[widget.index]['data'][index],
                          isHorizontal: widget.dataList[widget.index]['data']
                                  [index]['type'] ==
                              1);
                    }));
  }

  getListWidget() {
    switch (widget.type) {
      case 1:
        return _videoList();
        break;
      case 2:
        return _videoList();
        break;
      case 99:
        return _youxuanList();
        break;
      case 11:
        return _smallVideoList();
        break;
      default:
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getListWidget();
  }
}
