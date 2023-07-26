import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/yuemei_card.dart';
import 'package:pilipili/components/pili/public_list.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/store/search.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:pilipili/utils/pp_asset_path.dart';
import 'package:pilipili/utils/primaryScrollContainer.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController myController = TextEditingController();

  bool hideClear = true;
  List<GlobalKey<PrimaryScrollContainerState>> scrollChildKeys = [];

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
  int tabIndex = 0;
  int currentPage = 0;
  PageController pageController = PageController();
  PageController searchController = PageController();
  Search searchProvider;
  ValueNotifier<bool> hideClearNotifier = ValueNotifier<bool>(true);
  @override
  void initState() {
    super.initState();
    searchProvider = context.read<Search>();
    tabList.forEach((item) {
      scrollChildKeys.add(GlobalKey());
    });
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
          SearchHeader(
            pageController: searchController,
            hideClearIconNotifier: hideClearNotifier,
            textController: myController,
            tabIndex: tabIndex,
            currentPage: currentPage,
          ),
          Expanded(
              child: PageView(
            controller: searchController,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (e) {
              currentPage = e;
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
                        expandedHeight: 444.w,
                        flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: Container(
                              padding: EdgeInsets.only(bottom: 114.w),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 10,
                                      blurStyle: BlurStyle.outer,
                                      color: Color.fromRGBO(255, 91, 140, 0.2),
                                      offset: Offset(0, 6.w),
                                    )
                                  ],
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(
                                        30.w,
                                      ),
                                      bottomRight: Radius.circular(
                                        30.w,
                                      )),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Selector<Search, List<dynamic>>(
                                        selector: (_, searchSelector) =>
                                            searchSelector.historyTags,
                                        shouldRebuild: (_, __) => true,
                                        builder: (context, historyTags, child) {
                                          return historyTags.isEmpty
                                              ? const SizedBox()
                                              : Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          '搜索记录',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff6D6D6D),
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            searchProvider
                                                                .clearHistoryTag();
                                                          },
                                                          behavior:
                                                              HitTestBehavior
                                                                  .translucent,
                                                          child: PlatformAwareAssetImage(
                                                              url:
                                                                  'assets/images/detail/icon_clear.png',
                                                              width: 20.w,
                                                              filterQuality:
                                                                  FilterQuality
                                                                      .medium),
                                                        )
                                                      ],
                                                    ),
                                                    ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 24.w),
                                                        itemCount:
                                                            historyTags.length,
                                                        itemBuilder:
                                                            (context, index) =>
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        myController.text =
                                                                            historyTags[index];
                                                                        hideClearNotifier.value =
                                                                            false;
                                                                        searchController
                                                                            .jumpToPage(1);
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                8.w,
                                                                            top: 8.w,
                                                                            bottom: 8.w),
                                                                        child:
                                                                            Text(
                                                                          historyTags[
                                                                              index],
                                                                          style: TextStyle(
                                                                              color: Color(0xff979797),
                                                                              fontSize: 14.sp),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        searchProvider
                                                                            .removeHistoryTag(historyTags[index]);
                                                                      },
                                                                      behavior:
                                                                          HitTestBehavior
                                                                              .translucent,
                                                                      child: PlatformAwareAssetImage(
                                                                          url:
                                                                              'assets/images/detail/icon_delete.png',
                                                                          width: 20
                                                                              .w,
                                                                          filterQuality:
                                                                              FilterQuality.high),
                                                                    )
                                                                  ],
                                                                )),
                                                  ],
                                                );
                                        }),
                                    searchProvider.hotTags.isEmpty
                                        ? const SizedBox()
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '热门标签',
                                                style: TextStyle(
                                                    color: Color(0xff6D6D6D),
                                                    fontSize: 14.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 12.w),
                                                child: Wrap(
                                                  spacing: 8.w,
                                                  runSpacing: 12.w,
                                                  children:
                                                      searchProvider.hotTags
                                                          .map((e) =>
                                                              GestureDetector(
                                                                onTap: () {
                                                                  myController
                                                                      .text = e;
                                                                  hideClearNotifier
                                                                          .value =
                                                                      false;
                                                                  searchController
                                                                      .jumpToPage(
                                                                          1);
                                                                },
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      height:
                                                                          28.w,
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              14.w),
                                                                      decoration: BoxDecoration(
                                                                          color: Color(
                                                                              0xffFFF5F9),
                                                                          borderRadius:
                                                                              BorderRadius.circular(14.w)),
                                                                      child:
                                                                          Text(
                                                                        e,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xffFFADC6),
                                                                          fontSize:
                                                                              14.sp,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ))
                                                          .toList(),
                                                ),
                                              ),
                                            ],
                                          )
                                  ],
                                ),
                              ),
                            )),
                        bottom: PreferredSize(
                          preferredSize: Size.fromHeight(44.5.w),
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
              currentPage == 1
                  ? SearchResult(word: myController.text)
                  : const SizedBox()
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
      cacheExtent: 1.sh * 5,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
          horizontal: DefaultStyle.pagePadding, vertical: 20.w),
      itemCount: 20,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 7.w,
        crossAxisSpacing: 7.w,
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
  ValueNotifier<int> currentTabNotifier = ValueNotifier<int>(0);

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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: currentTabNotifier,
        builder: (context, currentTab, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 40.w,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 9.w),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      blurStyle: BlurStyle.outer,
                      color: Color(0xffFFD3E6),
                      blurRadius: 2,
                      offset: Offset(0, 4.w),
                    )
                  ]),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(
                      width: 20.w,
                    ),
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: tabList.length,
                    itemBuilder: (context, index) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        controller.jumpToPage(index);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: currentTab == index ? 1 : 0,
                            child: PlatformAwareAssetImage(
                                url: 'assets/images/icon_love_red.png',
                                width: 6.27.w,
                                height: 5.w,
                                filterQuality: FilterQuality.medium),
                          ),
                          Text(
                            tabList[index]['title'],
                            style: currentTab == index
                                ? TextStyle(
                                    color: Color(0xffFF5B8C),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp)
                                : TextStyle(
                                    color: Color(0xffC2C2C2),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp),
                          )
                        ],
                      ),
                    ),
                  )),
              Expanded(
                  child: PageView(
                controller: controller,
                onPageChanged: (e) {
                  currentTabNotifier.value = e;
                },
                children: tabList.map((tab) {
                  Map pramas = {
                    'word': widget.word,
                  };
                  pramas.addAll(tab['pramas']);
                  return PageViewMixin(
                    child: tab['cardType'] == 'yuemei'
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 18.w),
                            child: PublicBuildList(
                                api: tab['api'],
                                isShow: true,
                                data: pramas,
                                nullText: '还没有约炮信息哦～',
                                itemBuild: (context, index, data, page, limit,
                                    getListData) {
                                  return YuemeiCard(
                                    w: 118.w,
                                    h: 145.w,
                                    isShowInfo: true,
                                    data: data,
                                  );
                                }),
                          )
                        : PublicList(
                            isFlow: tab['isFlow'],
                            data: pramas,
                            contentType: tab['contentType'],
                            cartType: tab['cardType'],
                            api: tab['api'],
                            isShow: tabList.indexOf(tab) == currentTab,
                            isSearch: true,
                          ),
                  );
                }).toList(),
              ))
            ],
          );
        });
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
              padding: EdgeInsets.symmetric(vertical: 16.w),
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
            height: 50.w,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 38.w),
                  decoration: BoxDecoration(
                    color: DefaultStyle.themeColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.w),
                        topRight: Radius.circular(12.w)),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(top: 2.w, left: 2.w, right: 2.w),
                    decoration: BoxDecoration(
                      color: Color(0xfffff4f9),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.w),
                          topRight: Radius.circular(8.w)),
                    ),
                  ),
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 9.w,
                    child: Container(
                      padding: EdgeInsets.only(left: 16.w),
                      height: 36.w,
                      child: ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(
                                width: 4.w,
                              ),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          itemCount: tabList.length,
                          itemBuilder: (context, index) => GestureDetector(
                                onTap: () {
                                  currentIndex = index;
                                  widget.changeHead(index);
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
                                            url: currentIndex != index
                                                ? PPAssetsPath.seachBtn
                                                : PPAssetsPath.seachBtnActive,
                                            fit: BoxFit.fill,
                                            filterQuality:
                                                FilterQuality.medium)),
                                    Container(
                                      width: 79.w,
                                      height: 36.w,
                                      alignment: Alignment.center,
                                      padding: currentIndex != index
                                          ? null
                                          : EdgeInsets.only(
                                              top: 2.w, right: 3.w),
                                      child: Text(
                                        tabList[index]['title'],
                                        style: TextStyle(
                                            color: currentIndex != index
                                                ? Colors.white
                                                : Color(0xff6d6567),
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SearchHeader extends StatefulWidget {
  const SearchHeader(
      {Key key,
      this.pageController,
      this.hideClearIconNotifier,
      this.textController,
      this.currentPage,
      this.tabIndex})
      : super(key: key);
  final PageController pageController;
  final ValueNotifier hideClearIconNotifier;
  final TextEditingController textController;
  final int currentPage;
  final int tabIndex;
  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  Search searchProvider;
  String prevText;
  @override
  void initState() {
    searchProvider = context.read<Search>();
    super.initState();
  }

  void clickSearchBoxClearIcon() {
    widget.textController.clear();
    widget.pageController.jumpTo(0);
    widget.hideClearIconNotifier.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.w + ScreenUtil().statusBarHeight,
      padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
      color: DefaultStyle.themeColor,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (widget.currentPage == 0) {
                context.pop();
              } else {
                clickSearchBoxClearIcon();
              }
            },
            child: Padding(
              padding: EdgeInsets.only(left: 15.w, right: 13.w),
              child: PlatformAwareAssetImage(
                  url: PPAssetsPath.backArrow,
                  height: 22.w,
                  width: 12.w,
                  filterQuality: FilterQuality.medium),
            ),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Container(
              height: 36.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.w),
                  color: Colors.white),
              child: ValueListenableBuilder(
                  valueListenable: widget.hideClearIconNotifier,
                  builder: (context, hideClear, child) {
                    return TextField(
                      autofocus: true,
                      onChanged: (value) {
                        if (!hideClear && value.isEmpty) {
                          widget.pageController.jumpToPage(0);
                          widget.hideClearIconNotifier.value = true;
                        }
                        if (hideClear && value.isNotEmpty) {
                          widget.hideClearIconNotifier.value = false;
                        }
                      },
                      controller: widget.textController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (e) {
                        if (widget.textController.text.isEmpty) {
                          CommonUtils.showText('请输入搜索关键字～');
                          return;
                        }
                        if (prevText == widget.textController.text &&
                            widget.tabIndex == 1) return;
                        widget.pageController.jumpToPage(1);
                        prevText = widget.textController.text;
                        if (!searchProvider.historyTags
                            .contains(widget.textController.text)) {
                          if (searchProvider.historyTags.length >= 3) {
                            searchProvider.historyTags.removeAt(0);
                          }
                          searchProvider
                              .addHistoryTag(widget.textController.text);
                        }

                        // Timer(Duration(milliseconds: 200), () {
                        //   loading = false;
                        //   setState(() {});
                        // });
                      },
                      decoration: InputDecoration(
                        hintText: '请输入搜索内容',
                        hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff6D6D6D)),
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 6.w),
                          child: PlatformAwareAssetImage(
                            url: 'assets/images/detail/icon_search_red.png',
                            filterQuality: FilterQuality.medium,
                            width: 24.w,
                            height: 24.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                        suffixIcon: hideClear
                            ? const SizedBox()
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 6.w),
                                child: GestureDetector(
                                  onTap: clickSearchBoxClearIcon,
                                  behavior: HitTestBehavior.translucent,
                                  child: PlatformAwareAssetImage(
                                    url:
                                        'assets/images/detail/icon_input_clear.png',
                                    filterQuality: FilterQuality.medium,
                                    width: 24.w,
                                    height: 24.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                        disabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      style: TextStyle(
                        color: Color(0xff000000),
                        fontSize: 14.sp,
                      ),
                    );
                  }),
            ),
          )),
        ],
      ),
    );
  }
}
