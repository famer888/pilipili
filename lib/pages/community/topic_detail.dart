import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/post_card.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

class TopicDetail extends StatefulWidget {
  const TopicDetail({Key? key, this.id}) : super(key: key);
  final int? id;
  @override
  State<TopicDetail> createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetail>
    with SingleTickerProviderStateMixin {
  PageController _controller = PageController();
  bool loading = true;
  ValueNotifier<int> currentTab = ValueNotifier(0);
  Map data = {};
  late ScrollController scrollController;
  bool loadFollow = false;
  Map topic = {};
  ValueNotifier<bool> isFollow = ValueNotifier(false);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTopicDetail(widget.id!).then((res) {
      if (res['status'] != 0) {
        data = res['data'];
        currentTab.value = data['tab'][0]['id'];
        loading = false;
        isFollow.value = data['topic']['is_follow'] == 1;
        topic = data['topic'];
        setState(() {});
        scrollController = ScrollController();
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误,请稍后再试');
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: loading ? '' : data['topic']['name'],
          ),
          Expanded(
              child: loading
                  ? PageStatus.loading(true)
                  : NestedScrollView(
                      controller: scrollController,
                      headerSliverBuilder: (context, _) {
                        return [
                          SliverAppBar(
                            toolbarHeight: 0,
                            shadowColor: Colors.transparent,
                            pinned: true,
                            backgroundColor: Colors.transparent,
                            primary: false,
                            leading: const SizedBox(),
                            forceElevated: false,
                            expandedHeight: 165.w,
                            flexibleSpace: FlexibleSpaceBar(
                                collapseMode: CollapseMode.parallax,
                                background: Stack(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 125.w,
                                          child: PlatformAwareNetworkImage(
                                            url: topic['bg_thumb'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding: EdgeInsets.all(8.w),
                                              height: 57.w,
                                              color: Color(0XFF82384E)
                                                  .withOpacity(0.5),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        topic['intro'],
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                        maxLines: 1,
                                                      ),
                                                      DefaultTextStyle(
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffFF84A9),
                                                              fontSize: 12.sp),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                  '${CommonUtils.renderFixedNumber(topic['post_num'].toDouble())}个帖子'),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8.w),
                                                                height: 12.w,
                                                                width: 1.w,
                                                                color: Color(
                                                                    0xffFF84A9),
                                                              ),
                                                              Text(
                                                                  '${CommonUtils.renderFixedNumber(topic['view_num'].toDouble())}次瀏覽'),
                                                            ],
                                                          )),
                                                    ],
                                                  )),
                                                  SizedBox(
                                                    width: 8.w,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (loadFollow) {
                                                        CommonUtils.showText(
                                                            '请勿频繁操作');
                                                        return;
                                                      }
                                                      loadFollow = true;
                                                      toggleFollowTopic(
                                                              topic['id'])
                                                          .then((res) {
                                                        if (res['status'] !=
                                                            0) {
                                                          isFollow.value = res[
                                                                      'data'][
                                                                  'is_follow'] ==
                                                              1;
                                                        } else {
                                                          CommonUtils.showText(
                                                              res['msg'] ??
                                                                  '系统错误,请稍后重试');
                                                        }
                                                      }).whenComplete(() {
                                                        loadFollow = false;
                                                      });
                                                    },
                                                    child:
                                                        ValueListenableBuilder(
                                                            valueListenable:
                                                                isFollow,
                                                            builder: (context,
                                                                value, child) {
                                                              return CommonUtils
                                                                  .shadowBtn(
                                                                      'assets/images/2023/icon_${value ? "unfollow" : "follow"}.png',
                                                                      text: value
                                                                          ? '已關注'
                                                                          : '關注',
                                                                      isActive:
                                                                          value);
                                                            }),
                                                  )
                                                ],
                                              ),
                                            ))
                                      ],
                                    )
                                  ],
                                )),
                            bottom: PreferredSize(
                                preferredSize: Size.fromHeight(40.w),
                                child: Container(
                                  color: Color(0xffFFF4F9),
                                  height: 40.w,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20.w),
                                          bottomRight: Radius.circular(20.w),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color(0xffFF80A3)
                                                  .withOpacity(0.5),
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                              spreadRadius: 0)
                                        ]),
                                    child: ValueListenableBuilder(
                                      valueListenable: currentTab,
                                      builder: (context, value, child) {
                                        return Row(
                                          children:
                                              data['tab'].map<Widget>((item) {
                                            return Expanded(
                                                child: GestureDetector(
                                              onTap: () {
                                                int _index =
                                                    List.from(data['tab'])
                                                        .indexWhere((element) =>
                                                            element['id'] ==
                                                            item['id']);
                                                _controller.jumpToPage(_index);
                                              },
                                              child: Container(
                                                height: 40.w,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Opacity(
                                                      opacity:
                                                          item['id'] == value
                                                              ? 1
                                                              : 0,
                                                      child: PlatformAwareAssetImage(
                                                          url:
                                                              "assets/images/icon_love_red2.png",
                                                          width: 6.w,
                                                          fit: BoxFit.fitWidth,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .medium),
                                                    ),
                                                    Text(
                                                      item['name'],
                                                      style: value == item['id']
                                                          ? DefaultStyle
                                                              .pink14bold
                                                          : DefaultStyle
                                                              .lgray14Bold,
                                                    ),
                                                    Opacity(
                                                      opacity: 0,
                                                      child: PlatformAwareAssetImage(
                                                          url:
                                                              "assets/images/icon_love_red2.png",
                                                          width: 6.w,
                                                          fit: BoxFit.fitWidth,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .medium),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ));
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ),
                                )),
                          ),
                        ];
                      },
                      body: PageView(
                        controller: _controller,
                        onPageChanged: (index) {
                          currentTab.value = data['tab'][index]['id'];
                        },
                        children: data['tab'].map<Widget>((item) {
                          return PageViewMixin(
                            child: PublicBuildList(
                                isController: false,
                                paddingLeft: 8.w,
                                paddingTop: 8.w,
                                paddingRight: 8.w,
                                api: '/${item['api']}',
                                isShow: true,
                                data: item['params'],
                                itemBuild: (context, index, data, page, limit,
                                    getListData) {
                                  return PostCard(data: data, topic: topic);
                                }),
                          );
                        }).toList(),
                      )))
        ],
      ),
    );
  }
}
