import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/comment_item.dart';
import 'package:pilipili/components/card/navel_card.dart';
import 'package:pilipili/components/card/newComicsCard.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/widgetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/components/sharemovie.dart';
import 'package:pilipili/components/widget/my_button.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:pilipili/utils/privilege.dart';
import 'package:provider/provider.dart';

class NovelDetail extends StatefulWidget {
  const NovelDetail({Key key, this.id}) : super(key: key);
  final int id;
  @override
  State<NovelDetail> createState() => _NovelDetailState();
}

class _NovelDetailState extends State<NovelDetail> {
  PageController controller = PageController();
  int currentTab = 0;
  Map data = {};
  int likeCount = 0;
  bool isTap = false;
  bool isFavorites = false;
  bool loading = true;
  bool isBuy = false;
  Map novelLocal = {};
  ValueNotifier<List> recommendList = ValueNotifier([]);
  ValueNotifier<bool> isMore = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    novelLocal = AppGlobal.appBox.get('novel_local') ?? {};
    getDetail();
  }

  getDetail() async {
    await novelDetail(novelId: widget.id).then((res) {
      if (res['status'] != 0) {
        loading = false;
        data = res['data'];
        likeCount = data['like_count'];
        isFavorites = data['is_like'];
        setState(() {});
        if (data['categories'] is List && data['categories'].length > 1) {
          novelRecommend(
                  categoryId: data['categories'][0]['id'], page: 1, limit: 12)
              .then((value) {
            if (value['status'] != 0) {
              recommendList.value = value['data'];
            } else {
              CommonUtils.showText(value['msg'] ?? '系统错误～');
            }
          });
        }
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误～');
      }
    });
  }

  @override
  void dispose() {
    recommendList.dispose();
    super.dispose();
  }

  List tabList = [
    {
      'name': '简介',
    },
    {
      'name': '评论',
    }
  ];
  Widget _chapterItem(Map item) {
    int firstSpaceIndex = item['name'].indexOf(' ');
    return GestureDetector(
      onTap: () {
        if (item['payment_type'] == 'free') {
          //免费
          context.push('/novelReader/${item['id']}');
        } else if (item['payment_type'] == 'vip') {
          //vip
          bool isView = Privilege.isAllowed(
                  context, RESOURCE_TYPE_STORY, PRIVILEGE_TYPE_VIEW) ||
              item['has_permission'];
          if (isView) {
            context.push('/novelReader/${item['id']}');
          } else {
            YyShowDialog.showdialog(context,
                title: '温馨提示', btnText: '开通会员', cancelText: '取消', callBack: () {
              context.push('/vip');
            }, content: (setDialogState) {
              return DefaultTextStyle(
                  style: TextStyle(
                      color: Color(0xff646464),
                      fontSize: ScreenUtil().setSp(16),
                      fontWeight: FontWeight.bold),
                  child: Text('您还没有权限，请升级会员权限'));
            });
          }
        } else {
          //金币
          if (isBuy || item['has_permission']) {
            context.push('/novelReader/${item['id']}');
          } else {
            int money =
                Provider.of<HomeConfig>(context, listen: false).member.money;
            bool isInsufficient =
                money < double.parse(item['coins'].toString());
            YyShowDialog.showdialog(context,
                title: '温馨提示',
                btnText: isInsufficient ? '余额不足,去充值' : '立即购买',
                cancelText: isInsufficient ? null : '取消', callBack: () {
              if (isInsufficient) {
                context.push('/coinRecharge');
              } else {
                PageStatus.showLoading();
                novelBuy(widget.id).then((res) async {
                  print(res);
                  if (res['status'] != 0) {
                    CommonUtils.showText('购买成功');
                    isBuy = true;
                    context.push('/novelReader/${item['id']}');
                  } else {
                    CommonUtils.showText(res['msg'] ?? '系统错误～');
                  }
                }).whenComplete(() {
                  PageStatus.closeLoading();
                });
              }
            }, content: (setDialogState) {
              return DefaultTextStyle(
                  style: TextStyle(
                      color: Color(0xff646464),
                      fontSize: ScreenUtil().setSp(16),
                      fontWeight: FontWeight.bold),
                  child: Text('花費${item['coins']}皮哩币观看完整小說'));
            });
          }
        }
      },
      child: Container(
        height: 36.w,
        margin: EdgeInsets.only(bottom: 8.w),
        decoration: BoxDecoration(
            gradient: DefaultStyle.buttonGradient,
            borderRadius: BorderRadius.circular(5.w),
            boxShadow: DefaultStyle.unClickButtonBoxShadow),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      firstSpaceIndex == -1
                          ? ''
                          : item['name'].substring(0, firstSpaceIndex),
                      style: TextStyle(
                          color: Color(0xff828181),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      width: firstSpaceIndex == -1 ? 0 : 8.w,
                    ),
                    Expanded(
                        child: Text(
                      firstSpaceIndex == -1
                          ? item['name']
                          : item['name'].substring(firstSpaceIndex + 1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xff979797),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ))
                  ],
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              getNovelType(item['payment_type'])
            ],
          ),
        ),
      ),
    );
  }

  getNovelType(String type) {
    switch (type) {
      case 'free':
        return Text(
          '免费',
          style: TextStyle(
              color: Color(0xffFF84A9),
              fontSize: 14.sp,
              fontWeight: FontWeight.w700),
        );
        break;
      case 'vip':
        return PlatformAwareAssetImage(
          url: 'assets/images/comics/icon_vip.png',
          height: 16.w,
          fit: BoxFit.fitHeight,
        );
        break;
      default:
        return PlatformAwareAssetImage(
          url: 'assets/images/comics/icon_money.png',
          height: 16.w,
          fit: BoxFit.fitHeight,
        );
    }
  }

  _share() {
    var config = Provider.of<HomeConfig>(context, listen: false).config;
    ShareMovieModel.showShareMovie(BackButtonBehavior.none,
        copyUrl: config.share.affUrlCopy.url,
        thumb: data['thumbnail'],
        title: data['name'] ?? '--',
        subtitle: data['tags'] ?? '--',
        url: config.share.affUrl.toString());
  }

  _useFavorite() {
    if (isTap) {
      CommonUtils.showText('请勿频繁操作');
      return;
    }
    ;
    isTap = true;
    novelLikeToggle(widget.id).then((res) {
      if (res != null && res['status'] != 0) {
        if (isFavorites) {
          likeCount--;
        } else {
          likeCount++;
        }
        isFavorites = !isFavorites;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误~');
      }
    }).whenComplete(() {
      isTap = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: ScreenUtil().statusBarHeight,
          ),
          PageTitleBar(
            title: '小说详情',
          ),
          Expanded(
              child: loading
                  ? PageStatus.loading(true)
                  : ExtendedNestedScrollView(
                      onlyOneScrollInBody: true,
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            backgroundColor: Colors.white,
                            primary: false,
                            leading: Container(),
                            toolbarHeight: 0,
                            pinned: true,
                            elevation: 0,
                            expandedHeight: 208.w,
                            flexibleSpace: FlexibleSpaceBar(
                              background: Container(
                                padding:
                                    EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 48.w),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3.w),
                                      child: SizedBox(
                                        height: double.infinity,
                                        width: 109.w,
                                        child: PlatformAwareNetworkImage(
                                          url: data['thumbnail'],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    Expanded(
                                        child: Container(
                                      height: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'] ?? '标题',
                                            style: TextStyle(
                                                color: Color(0xff404040),
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            '作者：${data['author'] ?? '鸡儿川'}',
                                            style: TextStyle(
                                              color: Color(0xffFF5B8C),
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          Text(
                                            '${CommonUtils.renderFixedNumber(data['view_count'])}人看过 - 更新至${CommonUtils.renderFixedNumber(data['chapter_count'])}话 - ${CommonUtils.renderFixedNumber(data['word_count'])}字',
                                            style: TextStyle(
                                                color: Color(0xff979797),
                                                fontSize: 11.sp),
                                          ),
                                          Wrap(
                                              spacing: 4.w,
                                              runSpacing: 4.w,
                                              children:
                                                  List.from(data['categories'])
                                                      .map((e) {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      height: 21.w,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.w),
                                                          color: Color(
                                                              0xffFFF5F9)),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 12.sp,
                                                      ),
                                                      child: Text(
                                                        e['title'],
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffFFADC6),
                                                            fontSize: 12.sp),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              }).toList())
                                        ],
                                      ),
                                    ))
                                  ],
                                ),
                              ),
                            ),
                            bottom: PreferredSize(
                                child: Container(
                                  height: 40.w,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: DefaultStyle.pagePadding),
                                  child: Row(
                                    children: tabList.asMap().keys.map((e) {
                                      return GestureDetector(
                                        onTap: () {
                                          controller.jumpToPage(e);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right: e == tabList.length - 1
                                                  ? 0
                                                  : 20.w),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Opacity(
                                                opacity:
                                                    currentTab == e ? 1 : 0,
                                                child: PlatformAwareAssetImage(
                                                    url:
                                                        'assets/images/icon_love_red.png',
                                                    width: 6.w,
                                                    filterQuality:
                                                        FilterQuality.medium),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    tabList[e]['name'],
                                                    style: currentTab == e
                                                        ? TextStyle(
                                                            color: Color(
                                                                0xffFF5B8C),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14.sp)
                                                        : TextStyle(
                                                            color: Color(
                                                                0xffC2C2C2),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14.sp),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color(0xffFFD3E6),
                                          offset: Offset(0, 4),
                                          blurRadius: 4,
                                          spreadRadius: 0)
                                    ],
                                  ),
                                ),
                                preferredSize: Size(1.sw, 40.w)),
                          )
                        ];
                      },
                      body: PageView(
                        controller: controller,
                        onPageChanged: (index) {
                          currentTab = index;
                          setState(() {});
                        },
                        children: [
                          PageViewMixin(
                            child: ExtendedVisibilityDetector(
                                uniqueKey: const Key('Tab1'),
                                child: ListView(
                                  padding: EdgeInsets.all(16.w),
                                  children: [
                                    Text(
                                      '小说简介',
                                      style: TextStyle(
                                          color: Color(0xff404040),
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    ValueListenableBuilder(
                                        valueListenable: isMore,
                                        builder: (context, _v, child) {
                                          return Stack(
                                            children: [
                                              AnimatedSizeAndFade(
                                                  child: _v
                                                      ? Text(
                                                          data['description'],
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff6D6D6D),
                                                              fontSize: 14.sp),
                                                        )
                                                      : Text(
                                                          data['description'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff6D6D6D),
                                                              fontSize: 14.sp),
                                                        )),
                                              Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: !_v
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            isMore.value =
                                                                !isMore.value;
                                                            setState(() {});
                                                          },
                                                          behavior:
                                                              HitTestBehavior
                                                                  .translucent,
                                                          child: Container(
                                                            color: Color(
                                                                0xfffff5f9),
                                                            child:
                                                                PlatformAwareAssetImage(
                                                              url:
                                                                  'assets/images/comics/comics_more.png',
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          24),
                                                            ),
                                                          ),
                                                        )
                                                      : Container())
                                            ],
                                          );
                                        }),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 32.w, bottom: 24.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                ScreenUtil()
                                                                    .setWidth(
                                                                        4)),
                                                    child: MyButton.topIcon(
                                                        onTap: _useFavorite,
                                                        icon: isFavorites
                                                            ? PPString
                                                                .iconunLike
                                                            : PPString.iconLike,
                                                        text: CommonUtils
                                                            .renderFixedNumber(
                                                                likeCount
                                                                    .toDouble()),
                                                        activate: isFavorites)),
                                                MyButton.topIcon(
                                                    onTap: _share,
                                                    icon: 'icon_share',
                                                    text: '分享',
                                                    activate: false)
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (novelLocal[widget.id] ==
                                                    null) {
                                                  context.push(
                                                      '/novelReader/${data['first_chapter']['id']}');
                                                } else {
                                                  context.push(
                                                      '/novelReader/${novelLocal[widget.id]['chapter']}');
                                                }
                                              },
                                              child: Container(
                                                height: 40.w,
                                                decoration: BoxDecoration(
                                                    gradient: DefaultStyle
                                                        .defaluGrandientLine,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.w),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Color(
                                                                  0xffFF80A3)
                                                              .withOpacity(0.5),
                                                          offset: Offset(0, 2),
                                                          blurRadius: 4,
                                                          spreadRadius: 0)
                                                    ]),
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.w),
                                                child: Text(
                                                  novelLocal[widget.id] == null
                                                      ? '开始观看'
                                                      : '继续观看',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.from(data['chapter_list'])
                                          .map((e) {
                                        return _chapterItem(e);
                                      }).toList(),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context
                                            .push('/chapterList/${widget.id}');
                                      },
                                      child: Container(
                                        height: 36.w,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.w),
                                            gradient: LinearGradient(
                                                colors: [
                                                  Color(0XFFFFE4E4),
                                                  Color(0xffFFCCDB)
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      255, 128, 163, 0.5),
                                                  offset: Offset(0, 2),
                                                  blurRadius: 4,
                                                  spreadRadius: 0)
                                            ]),
                                        child: Text(
                                          '全部章节',
                                          style: TextStyle(
                                              color: Color(0XFFFF84A9),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 0.5.w,
                                      color: Color(0xffFFD1DF),
                                      margin: EdgeInsets.only(
                                          top: 16.w, bottom: 23.w),
                                    ),
                                    WidgetTitleBar(
                                      title: '为您推荐',
                                    ),
                                    ValueListenableBuilder(
                                        valueListenable: recommendList,
                                        builder: (context, _list, child) {
                                          return _list.length == 0
                                              ? PageStatus.noData()
                                              : GridView.count(
                                                  padding: EdgeInsets.only(
                                                      bottom: ScreenUtil()
                                                              .setWidth(50.5) +
                                                          (kIsWeb
                                                              ? 0
                                                              : ScreenUtil()
                                                                  .bottomBarHeight)),
                                                  physics:
                                                      new NeverScrollableScrollPhysics(),
                                                  crossAxisCount: 3,
                                                  shrinkWrap: true,
                                                  crossAxisSpacing: 7.w,
                                                  mainAxisSpacing: 16.w,
                                                  childAspectRatio: 109 / 196,
                                                  children: _list
                                                      .asMap()
                                                      .keys
                                                      .map<Widget>((e) {
                                                    return NovelCard(
                                                      data: _list[e],
                                                    );
                                                  }).toList(),
                                                );
                                        })
                                  ],
                                )),
                          ),
                          PageViewMixin(
                            child: ExtendedVisibilityDetector(
                                uniqueKey: const Key('Tab2'),
                                child: PublicBuildList(
                                    isController: false,
                                    api: '/api/novel/getComment',
                                    isShow: true,
                                    data: {'novelId': widget.id},
                                    nullText: '还没有评论哦～',
                                    itemBuild: (context, index, data, page,
                                        limit, getListData) {
                                      return CommentItem(
                                        data: data,
                                      );
                                    })),
                          )
                        ],
                      ),
                    ))
        ],
      ),
    );
  }
}
