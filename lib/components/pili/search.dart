import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/yuemei_card.dart';
import 'package:pilipili/components/pili/public_list.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:pilipili/utils/pp_asset_path.dart';
import 'package:pilipili/utils/primaryScrollContainer.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController myController = TextEditingController();
  String prevText;
  bool hideClear = true;
  List historyTags = [];
  List<GlobalKey<PrimaryScrollContainerState>> scrollChildKeys = [];
  bool loading = false;

  List tabList = [
    {
      'id': 1,
      'name': '次元',
      'api': '/api/mv/getList',
      'isFlow': true,
      'pramas': {},
    },
    {
      'id': 2,
      'name': '动漫',
      'api': '/api/mv/getList',
      'pramas': {'category': 1},
      'cardType': 'h',
      'isFlow': false,
    },
    {
      'id': 3,
      'name': '漫画',
      'api': '/api/book/getList',
      'pramas': {'type': 1},
      'cardType': 'v',
      'isFlow': false,
    }
  ];
  List hotTags = [];
  int tabIndex = 0;
  int cureentPage = 0;
  PageController pageController = PageController();
  PageController searchController = PageController();
  @override
  void initState() {
    super.initState();
    var searchTag = AppGlobal.appBox.get('search_history');
    if (searchTag != null) {
      historyTags = searchTag;
    }
    tabList.forEach((item) {
      scrollChildKeys.add(GlobalKey());
    });
    gethotTags().then((res) {
      if (res['status'] != 0) {
        hotTags = res['data'];
        setState(() {});
      }
    });
  }

  Widget _searchHead() {
    return Container(
      height: ScreenUtil().setWidth(50) + ScreenUtil().statusBarHeight,
      padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
      color: DefaultStyle.themeColor,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: DefaultStyle.pagePadding,
                vertical: ScreenUtil().setWidth(5)),
            child: GestureDetector(
              onTap: () {
                if (cureentPage == 0) {
                  context.pop();
                } else {
                  myController.clear();
                  searchController.jumpTo(0);
                }
              },
              child: PlatformAwareAssetImage(
                  url: 'assets/images/backarrow.png',
                  height: ScreenUtil().setWidth(22),
                  filterQuality: FilterQuality.medium),
            ),
          ),
          Expanded(
              child: Container(
            height: ScreenUtil().setWidth(36),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                color: Colors.white),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  autofocus: true,
                  onChanged: (value) {
                    if (!hideClear && value.isEmpty) {
                      searchController.jumpToPage(0);
                      hideClear = true;
                      setState(() {});
                    }
                    if (hideClear && value.isNotEmpty) {
                      hideClear = false;
                      setState(() {});
                    }
                  },
                  controller: myController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (e) {
                    if (myController.text.isEmpty) {
                      CommonUtils.showText('请输入搜索关键字～');
                      return;
                    }
                    if (prevText == myController.text && tabIndex == 1) return;
                    searchController.jumpToPage(1);
                    prevText = myController.text;
                    loading = true;
                    if (historyTags.indexOf(myController.text) == -1) {
                      if (historyTags.length >= 3) {
                        historyTags.removeAt(0);
                      }
                      historyTags.add(myController.text);
                      AppGlobal.appBox.put('search_history', historyTags);
                    }
                    setState(() {});
                    // Timer(Duration(milliseconds: 200), () {
                    //   loading = false;
                    //   setState(() {});
                    // });
                  },
                  decoration: InputDecoration(
                    hintText: '请输入搜索内容',
                    hintStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(14),
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6D6D6D)),
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      child: PlatformAwareAssetImage(
                          url: 'assets/images/detail/icon_search_red.png',
                          filterQuality: FilterQuality.medium),
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
                    color: Color(0xff000000),
                    fontSize: ScreenUtil().setSp(14),
                  ),
                )),
                hideClear
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          myController.clear();
                          hideClear = true;
                          searchController.jumpToPage(0);
                          setState(() {});
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(8)),
                          child: PlatformAwareAssetImage(
                              url: 'assets/images/detail/icon_input_clear.png',
                              width: ScreenUtil().setWidth(24),
                              filterQuality: FilterQuality.medium),
                        ),
                      )
              ],
            ),
          )),
          SizedBox(
            width: ScreenUtil().setWidth(8),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _searchHead(),
          Expanded(
              child: PageView(
            controller: searchController,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (e) {
              cureentPage = e;
              setState(() {});
            },
            children: [
              NestedScrollView(
                physics: ClampingScrollPhysics(),
                headerSliverBuilder:
                    (BuildContext context, bool boxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                        backgroundColor: Colors.transparent,
                        primary: false,
                        leading: Container(),
                        pinned: true,
                        elevation: 0,
                        forceElevated: true,
                        expandedHeight: ScreenUtil().setWidth(444),
                        flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: Container(
                              padding: EdgeInsets.only(
                                  bottom: ScreenUtil().setWidth(114)),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(16),
                                    vertical: ScreenUtil().setWidth(8)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 10,
                                      blurStyle: BlurStyle.outer,
                                      color: Color.fromRGBO(255, 91, 140, 0.2),
                                      offset:
                                          Offset(0, ScreenUtil().setWidth(6)),
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
                                    historyTags.isEmpty
                                        ? Container()
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '搜索记录',
                                                style: TextStyle(
                                                    color: Color(0xff6D6D6D),
                                                    fontSize:
                                                        ScreenUtil().setSp(14),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  historyTags.clear();
                                                  AppGlobal.appBox.put(
                                                      'search_history',
                                                      historyTags);
                                                  setState(() {});
                                                },
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                child: PlatformAwareAssetImage(
                                                    url:
                                                        'assets/images/detail/icon_clear.png',
                                                    width: ScreenUtil()
                                                        .setWidth(20),
                                                    filterQuality:
                                                        FilterQuality.medium),
                                              )
                                            ],
                                          ),
                                    historyTags.isEmpty
                                        ? Container()
                                        : Padding(
                                            padding: EdgeInsets.only(
                                                bottom:
                                                    ScreenUtil().setWidth(24)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: historyTags
                                                  .asMap()
                                                  .keys
                                                  .map((e) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    myController.text =
                                                        historyTags[e];
                                                    hideClear = false;
                                                    setState(() {});
                                                    searchController
                                                        .jumpToPage(1);
                                                  },
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: ScreenUtil()
                                                            .setWidth(8),
                                                        top: ScreenUtil()
                                                            .setWidth(8),
                                                        left: ScreenUtil()
                                                            .setWidth(8)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          historyTags[e],
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff979797),
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          14)),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            historyTags
                                                                .removeAt(e);
                                                            AppGlobal.appBox.put(
                                                                'search_history',
                                                                historyTags);
                                                            setState(() {});
                                                          },
                                                          behavior:
                                                              HitTestBehavior
                                                                  .translucent,
                                                          child: PlatformAwareAssetImage(
                                                              url:
                                                                  'assets/images/detail/icon_delete.png',
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          20),
                                                              filterQuality:
                                                                  FilterQuality
                                                                      .high),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                    hotTags == null || hotTags.isEmpty
                                        ? Container()
                                        : Text(
                                            '热门标签',
                                            style: TextStyle(
                                                color: Color(0xff6D6D6D),
                                                fontSize:
                                                    ScreenUtil().setSp(14),
                                                fontWeight: FontWeight.bold),
                                          ),
                                    hotTags == null || hotTags.isEmpty
                                        ? Container()
                                        : Container(
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setWidth(12)),
                                            child: Wrap(
                                              spacing: ScreenUtil().setWidth(8),
                                              runSpacing:
                                                  ScreenUtil().setWidth(12),
                                              children: hotTags
                                                  .asMap()
                                                  .keys
                                                  .map((e) => GestureDetector(
                                                        onTap: () {
                                                          myController.text =
                                                              hotTags[e];
                                                          hideClear = false;
                                                          setState(() {});
                                                          searchController
                                                              .jumpToPage(1);
                                                        },
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          28),
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      ScreenUtil()
                                                                          .setWidth(
                                                                              14)),
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xffFFF5F9),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          ScreenUtil()
                                                                              .setWidth(14))),
                                                              child: Text(
                                                                hotTags[e],
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xffFFADC6),
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              14),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ))
                                                  .toList(),
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            )),
                        bottom: PreferredSize(
                          preferredSize:
                              Size.fromHeight(ScreenUtil().setWidth(44.5)),
                          child: TabHead(
                              index: tabIndex,
                              changeHead: (e) {
                                pageController.jumpToPage(e);
                              }),
                        )),
                  ];
                },
                body: PageView(
                  controller: pageController,
                  onPageChanged: (e) {
                    for (int i = 0; i < scrollChildKeys.length; i++) {
                      GlobalKey<PrimaryScrollContainerState> key =
                          scrollChildKeys[i];

                      if (key.currentState != null) {
                        key.currentState.onPageChange(e == i); //控制是否当��显示
                      }
                    }
                    tabIndex = e;
                    setState(() {});
                  },
                  children: tabList.asMap().keys.map((e) {
                    return PageViewMixin(
                      child: PrimaryScrollContainer(
                          scrollChildKeys[e],
                          PublicList(
                            cartType: tabList[e]['cardType'],
                            isFlow: tabList[e]['isFlow'],
                            noRefresh: true,
                            contentType: e == 2 ? 2 : null,
                            data: tabList[e]['pramas'],
                            api: tabList[e]['api'],
                            isShow: e == tabIndex,
                            isSearch: true,
                          )
                          // PageGridView(
                          //   id: e,
                          // )
                          ),
                    );
                  }).toList(),
                ),
              ),
              cureentPage == 1
                  ? SearchResult(word: myController.text)
                  : Container()
            ],
          ))
        ],
      ),
    ));
  }
}

class PageGridView extends StatefulWidget {
  PageGridView({Key key, this.id}) : super(key: key);
  final int id;
  @override
  _PageGridViewState createState() => _PageGridViewState();
}

class _PageGridViewState extends State<PageGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      cacheExtent: ScreenUtil().screenHeight * 5,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
          horizontal: DefaultStyle.pagePadding,
          vertical: ScreenUtil().setWidth(20)),
      itemCount: 20,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: ScreenUtil().setWidth(7),
        crossAxisSpacing: ScreenUtil().setWidth(7),
        childAspectRatio: 1.11,
      ),
      itemBuilder: (context, index) {
        return Container(
          color: Colors.red,
          child: Center(
            child: Text(widget.id.toString()),
          ),
        );
      },
    );
  }
}

class SearchResult extends StatefulWidget {
  final String word;
  SearchResult({Key key, this.word}) : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  PageController controller = PageController();
  int currentTab = 0;
  List tabList = [
    {
      'title': '次元',
      'api': '/api/mv/search',
      'pramas': {},
      'isFlow': true,
      'contentType': 1
    },
    {
      'title': '动漫',
      'api': '/api/mv/search',
      'cardType': 'h',
      'pramas': {'category': 1},
      'isFlow': false,
      'contentType': 10
    },
    {
      'title': '漫画',
      'cardType': 'v',
      'api': '/api/book/search',
      'pramas': {},
      'isFlow': false,
      'contentType': 2
    },
    {
      'title': '约妹',
      'cardType': 'yuemei',
      'api': '/api/girl/search',
      'pramas': {},
      'isFlow': false,
    }
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: ScreenUtil().setWidth(40),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(9)),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              blurStyle: BlurStyle.outer,
              color: Color(0xffFFD3E6),
              blurRadius: 2,
              offset: Offset(0, ScreenUtil().setWidth(4)),
            )
          ]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: tabList.asMap().keys.map((e) {
              return GestureDetector(
                onTap: () {
                  controller.jumpToPage(e);
                },
                child: Container(
                  margin: EdgeInsets.only(
                      right: e == tabList.length - 1
                          ? 0
                          : ScreenUtil().setWidth(20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: currentTab == e ? 1 : 0,
                        child: PlatformAwareAssetImage(
                            url: 'assets/images/icon_love_red.png',
                            width: ScreenUtil().setWidth(6),
                            filterQuality: FilterQuality.medium),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tabList[e]['title'],
                            style: currentTab == e
                                ? TextStyle(
                                    color: Color(0xffFF5B8C),
                                    fontWeight: FontWeight.w700,
                                    fontSize: ScreenUtil().setSp(14))
                                : TextStyle(
                                    color: Color(0xffC2C2C2),
                                    fontWeight: FontWeight.w700,
                                    fontSize: ScreenUtil().setSp(14)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
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
            Map pramas = {
              'word': widget.word,
            };
            pramas.addAll(tabList[e]['pramas']);
            return PageViewMixin(
              child: tabList[e]['cardType'] == 'yuemei'
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 18.w),
                      child: PublicBuildList(
                          api: tabList[e]['api'],
                          isShow: true,
                          data: pramas,
                          nullText: '还没有约炮信息哦～',
                          itemBuild:
                              (context, index, data, page, limit, getListData) {
                            return YuemeiCard(
                              w: 118.w,
                              h: 145.w,
                              isShowInfo: true,
                              data: data,
                            );
                          }),
                    )
                  : PublicList(
                      isFlow: tabList[e]['isFlow'],
                      data: pramas,
                      contentType: tabList[e]['contentType'],
                      cartType: tabList[e]['cardType'],
                      api: tabList[e]['api'],
                      isShow: e == currentTab,
                      isSearch: true,
                    ),
            );
          }).toList(),
        ))
      ],
    );
  }
}

class TabHead extends StatefulWidget {
  TabHead({Key key, this.changeHead, this.index}) : super(key: key);
  final Function changeHead;
  final int index;
  @override
  _TabHeadState createState() => _TabHeadState();
}

class _TabHeadState extends State<TabHead> {
  int currentIndex = 0;
  List tabList = [
    {'title': '次元', 'api': '/api/mv/getList', 'data': {}},
    {
      'title': '动漫',
      'api': '/api/mv/getList',
      'data': {'category': 1}
    },
    {'title': '漫画', 'api': '/api/book/getList', 'data': {}}
  ];
  @override
  void didUpdateWidget(TabHead oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      currentIndex = widget.index;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfffff4f9),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
              child: Text(
                '最近更新',
                style: TextStyle(
                    color: Color(0xff6d6d6d),
                    fontSize: ScreenUtil().setSp(16),
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            height: ScreenUtil().setWidth(50),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setWidth(38)),
                  decoration: BoxDecoration(
                    color: DefaultStyle.themeColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil().setWidth(12)),
                        topRight: Radius.circular(ScreenUtil().setWidth(12))),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setWidth(2),
                        left: ScreenUtil().setWidth(2),
                        right: ScreenUtil().setWidth(2)),
                    decoration: BoxDecoration(
                      color: Color(0xfffff4f9),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ScreenUtil().setWidth(8)),
                          topRight: Radius.circular(ScreenUtil().setWidth(8))),
                    ),
                  ),
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: ScreenUtil().setWidth(9),
                    child: Container(
                      height: ScreenUtil().setWidth(36),
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(16)),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: ScreenUtil().setWidth(4),
                        children: tabList.asMap().keys.map((e) {
                          return GestureDetector(
                            onTap: () {
                              currentIndex = e;
                              widget.changeHead(e);
                              setState(() {});
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Stack(
                              children: [
                                Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: PlatformAwareAssetImage(
                                        url: currentIndex != e
                                            ? PPAssetsPath.seachBtn
                                            : PPAssetsPath.seachBtnActive,
                                        fit: BoxFit.fill,
                                        filterQuality: FilterQuality.medium)),
                                Container(
                                  width: ScreenUtil().setWidth(79),
                                  height: ScreenUtil().setWidth(36),
                                  alignment: Alignment.center,
                                  padding: currentIndex != e
                                      ? null
                                      : EdgeInsets.only(
                                          top: ScreenUtil().setWidth(2),
                                          right: ScreenUtil().setWidth(3)),
                                  child: Text(
                                    tabList[e]['title'],
                                    style: TextStyle(
                                        color: currentIndex != e
                                            ? Colors.white
                                            : Color(0xff6d6567),
                                        fontSize: ScreenUtil().setSp(16),
                                        fontWeight: FontWeight.w700),
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
