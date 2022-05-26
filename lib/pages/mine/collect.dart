import 'package:flutter/material.dart';

import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
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
    {'id': 1, 'name': '次元精选', 'index': 1},
    {'id': 10, 'name': '次元竖屏', 'index': 2},
    {'id': 3, 'name': '动漫', 'index': 3},
    {'id': 2, 'name': '漫画', 'index': 4},
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
    initCollect();
  }

  initCollect() async {
    var result =
        await getUserFavor(page: 1, limit: limit, type: tabList[0]['id']);
    if (result['data'] != null && result['data'].length > 0) {
      setState(() {
        dataList[1]['data'] = result['data'];
        dataList[1]['isloading'] = false;
      });
      if (result['data'].length < limit) {
        setState(() {
          dataList[1]['isall'] = true;
        });
      }
    } else {
      setState(() {
        dataList[1]['data'] = [];
        dataList[1]['isall'] = true;
        dataList[1]['isloading'] = false;
      });
    }
  }

  onTabsChange(int index) async {
    if (dataList[index]['data'].length == 0 &&
        dataList[index]['isall'] == false) {
      var result = await getUserFavor(
          category: index == 3 ? 1 : null,
          page: 1,
          limit: limit,
          type: tabList[index - 1]['id']);
      if (result['data'] != null && result['data'].length > 0) {
        setState(() {
          dataList[index]['data'] = result['data'];
          dataList[index]['isloading'] = false;
        });
        if (result['data'].length < limit) {
          setState(() {
            dataList[index]['isall'] = true;
          });
        }
      } else {
        setState(() {
          dataList[index]['data'] = [];
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
    var result = await getUserFavor(
        category: index == 3 ? 1 : null,
        page: dataList[index]['page'],
        limit: limit,
        type: tabList[index - 1]['id']);
    if (result['data'] != null && result['data'].length > 0) {
      setState(() {
        dataList[index]['data'] = result['data'];
        dataList[index]['isloading'] = false;
      });
      if (result['data'].length < limit) {
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
      var result = await getUserFavor(
          category: index == 3 ? 1 : null,
          page: dataList[index]['page'],
          limit: limit,
          type: tabList[index - 1]['id']);
      if (result['data'] != null && result['data'].length > 0) {
        setState(() {
          dataList[index]['data'].addAll(result['data']);
          dataList[index]['isloading'] = false;
        });
        if (result['data'].length < limit) {
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
      CommonUtils.showText("已加载全部 ${tabList[index - 1]['name']}");
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
                                  child: Image.asset(
                                    "assets/images/icon_love_red2.png",
                                    width: ScreenUtil().setWidth(6),
                                    fit: BoxFit.fitWidth,
                                    filterQuality: FilterQuality.medium
                                  ),
                                ),
                                Text(
                                  tabList[e]['name'],
                                  style: currentTab == e
                                      ? DefaultStyle.pink14bold
                                      : DefaultStyle.lgray14Bold,
                                ),
                                Opacity(
                                  opacity: 0,
                                  child: Image.asset(
                                    "assets/images/icon_love_red2.png",
                                    width: ScreenUtil().setWidth(6),
                                    fit: BoxFit.fitWidth,
                                    filterQuality: FilterQuality.medium
                                  ),
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
                    children: tabList
                        .map(
                          (e) => PageViewMixin(
                            key: Key('collectList${e['id']}-${e['name']}'),
                            child: CollectList(
                              index: e['index'],
                              type: e['id'],
                              dataList: dataList,
                              onRefreshPost: _onRefreshPost,
                              onLoading: _onLoading,
                            ),
                          ),
                        )
                        .toList()),
              )
            ],
          ))
        ],
      ),
    );
  }
}

class CollectList extends StatefulWidget {
  final int type;
  final int index;
  final Map<int, dynamic> dataList;
  final Function onRefreshPost;
  final Function onLoading;
  CollectList(
      {Key key,
      this.type,
      this.onRefreshPost,
      this.onLoading,
      this.dataList,
      this.index})
      : super(key: key);
  @override
  _CollectListState createState() => _CollectListState();
}

class _CollectListState extends State<CollectList> {
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
                    child: PageStatus.noData(text: '视频 收藏为空'),
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

  Widget _comicsList() {
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
                    child: PageStatus.noData(text: '漫画 收藏为空'),
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
                        contentType: 2,
                        width: ScreenUtil().setWidth(110.5),
                        thumbUrl: widget.dataList[widget.index]['data'][index]
                            ['thumb'],
                        cardData: widget.dataList[widget.index]['data'][index],
                        showField: 'title',
                      );
                    }),
          );
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
                    child: PageStatus.noData(text: '您还没收藏短视频'),
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

  getListWidget() {
    switch (widget.type) {
      case 1:
        return _videoList();
        break;
      case 2:
        return _comicsList();
        break;
      case 10:
        return _smallVideoList();
        break;
      default:
        return _videoList();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getListWidget();
  }
}
