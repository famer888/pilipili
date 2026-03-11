import 'dart:async';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/comment_item.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/input/InputDailog.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:pilipili/utils/privilege.dart';
import 'package:provider/provider.dart';

class NovelReader extends StatefulWidget {
  const NovelReader({Key key, this.id}) : super(key: key);
  final int id;
  @override
  State<NovelReader> createState() => _NovelReaderState();
}

class _NovelReaderState extends State<NovelReader> {
  ValueNotifier<bool> isShow = ValueNotifier(true);
  ValueNotifier<double> currentSliderValue = ValueNotifier(14);
  ValueNotifier<int> themeStyle = ValueNotifier(0);
  ScrollController controller;
  List themeList = [
    {
      'borderColor': Color(0xffFF84A9),
      'bacgroundColor': Color(0xffFFF4F9),
      'fontColor': Color(0xff6D6D6D),
      'icon': 'A-gray'
    },
    {
      'borderColor': Color(0xffB8C1CC),
      'bacgroundColor': Color(0xffFFFFFF),
      'fontColor': Color(0xff1B395D),
      'icon': 'A-black'
    },
    {
      'borderColor': Color(0xff121213),
      'bacgroundColor': Color(0xff121213),
      'fontColor': Color(0xff2FB536),
      'icon': 'A-green'
    },
    {
      'borderColor': Color(0xff2F3655),
      'bacgroundColor': Color(0xff2F3655),
      'fontColor': Color(0xffFFFFFF),
      'icon': 'A-white'
    },
    {
      'borderColor': Color(0xff252525),
      'bacgroundColor': Color(0xff252525),
      'fontColor': Color(0xffFFFFFF),
      'icon': 'A-white'
    }
  ];
  List<String> content = [];
  Map data = {};
  bool loading = true;
  Map novelLocal;
  Timer _debounce;
  ValueNotifier<bool> isFavorites = ValueNotifier(false);
  bool isTap = false;
  @override
  void initState() {
    super.initState();

    //文章主题初始化
    Map novelTheme = AppGlobal.appBox.get('novel_theme');
    currentSliderValue.value = novelTheme['fontSize'];
    themeStyle.value = novelTheme['themeStyle'];
      initContent(widget.id);
  }

  changeOffset() {
    _themeChanged(() {
      Map currentInfo = novelLocal;
      currentInfo[data['novel_id']]['ofsset'][data['id']] = controller.offset;
      AppGlobal.appBox.put('novel_local', currentInfo);
    }, 500);
  }

  toChaoter(Map item) {
    if (item['payment_type'] == 'free') {
      //免费
      context.push('/novelReader/${item['id']}',
          replace: true);
    } else if (item['payment_type'] == 'vip') {
      //vip
      bool isView = Privilege.isAllowed(
          context, RESOURCE_TYPE_STORY, PRIVILEGE_TYPE_VIEW);
      if (isView) {
        context.push('/novelReader/${item['id']}',
            replace: true);
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
      int _coin=double.parse(item['coins'].toString()).toInt();
      if (_coin==0||item['has_permission']!=null&&item['has_permission']) {
        context.push('/novelReader/${item['id']}',
            replace: true);
      } else {
        int money =
            Provider.of<HomeConfig>(context, listen: false).member.money;
        bool isInsufficient = money < _coin;
        YyShowDialog.showdialog(context,
            title: '温馨提示',
            btnText: isInsufficient ? '余额不足,去充值' : '立即购买',
            cancelText: isInsufficient ? null : '取消', callBack: () {
          if (isInsufficient) {
            context.push('/novelReader/${item['id']}',
                replace: true);
          } else {
            PageStatus.showLoading();
            novelBuy(data['novel_id']).then((res) async {
              if (res['status'] != 0) {
                CommonUtils.showText('购买成功');
                context.push('/novelReader/${item['id']}',
                    replace: true);
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
              child: Text('花費${_coin}皮哩币观看完整小說'));
        });
      }
    }
  }

  initContent(int id) {
    getChapterDetail(id).then((res) {
      if (res['status'] != 0) {
        content = res['data']['content'].split('\n\n');
        data = res['data'];
        data.remove('content');
        isFavorites.value = data['is_like'];
        loading = false;

        //滚动初始化
        novelLocal = AppGlobal.appBox.get('novel_local');
        Map currentInfo = novelLocal;
        if (currentInfo[data['novel_id']] == null) {
          currentInfo[data['novel_id']] = {
            'chapter': data['id'],
            'ofsset': {data['id']: 0.0}
          };
        } else {
          currentInfo[data['novel_id']]['chapter'] = data['id'];
        }
        AppGlobal.appBox.put('novel_local', currentInfo);
        controller = ScrollController(
            initialScrollOffset:
                currentInfo[data['novel_id']]['ofsset'][data['id']] ?? 0);
            } else {
        CommonUtils.showText(res['msg'] ?? '系统错误～');
      }
      setState(() {});
      controller.addListener(changeOffset);
    });
  }

  void _themeChanged(Function callBack, int time) {
    if (_debounce.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: time), () {
      callBack();
    });
  }

  _useFavorite() {
    if (isTap) {
      CommonUtils.showText('请勿频繁操作');
      return;
    }
    isTap = true;
    novelLikeToggle(data['novel_id']).then((res) {
      if (res['status'] != 0) {
        isFavorites.value = !isFavorites.value;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误~');
      }
    }).whenComplete(() {
      isTap = false;
    });
  }

  Future showConment() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: ScreenUtil().setWidth(470),
                  color: Color(0xffFFF4F9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              blurStyle: BlurStyle.outer,
                              color: Color.fromRGBO(255, 91, 140, 0.2),
                              offset: Offset(0, ScreenUtil().setWidth(6)),
                            )
                          ],
                        ),
                        width: double.infinity,
                        height: ScreenUtil().setWidth(40),
                        child: Center(
                          child: Text(
                            '评论',
                            style: TextStyle(
                                color: Color(0xffFF5B8C),
                                fontSize: ScreenUtil().setSp(14),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                          child: PublicBuildList(
                              api: '/api/novel/getComment',
                              isShow: true,
                              data: {'novelId': data['novel_id']},
                              nullText: '还没有评论哦～',
                              itemBuild: (context, index, _data, page, limit,
                                  getListData) {
                                return GestureDetector(
                                  onTap: () {
                                    if (Privilege.isAllowed(
                                        context,
                                        RESOURCE_TYPE_SHORT_VIDEO,
                                        PRIVILEGE_TYPE_COMMENT)) {
                                      InputDialog.show(context, '请输入您的影评～')
                                          .then((value) {
                                        if (value != '') {
                                          novelComment(
                                                  novelId: data['novel_id'],
                                                  content: value,
                                                  parentId: _data['id'])
                                              .then((res) {
                                            if (res['status'] != 0) {
                                              CommonUtils.showText(
                                                  '影评发布成功,请刷新查看');
                                            } else {
                                              CommonUtils.showText(res['msg']);
                                            }
                                          });
                                        } else {
                                          CommonUtils.showText('请输入您的影评');
                                        }
                                      });
                                    } else {
                                      YyShowDialog.showdialog(context,
                                          btnText: '升级VIP',
                                          cancelText: '取消', callBack: () {
                                        context.push('/vip');
                                      }, content: (setDialogState) {
                                        return DefaultTextStyle(
                                            style: TextStyle(
                                                color: Color(0xff646464),
                                                fontSize:
                                                    ScreenUtil().setSp(16),
                                                fontWeight: FontWeight.bold),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('升级VIP即可发布影评哦～'),
                                              ],
                                            ));
                                      });
                                    }
                                  },
                                  child: CommentItem(
                                    data: _data,
                                  ),
                                );
                              })),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (Privilege.isAllowed(
                              context,
                              RESOURCE_TYPE_SHORT_VIDEO,
                              PRIVILEGE_TYPE_COMMENT)) {
                            InputDialog.show(context, '请输入您的影评～').then((value) {
                              if (value != '') {
                                novelComment(
                                        novelId: data['novel_id'],
                                        content: value)
                                    .then((res) {
                                  if (res['status'] != 0) {
                                    CommonUtils.showText('影评发布成功,请刷新查看');
                                  } else {
                                    CommonUtils.showText(res['msg']);
                                  }
                                });
                              } else {
                                CommonUtils.showText('请输入您的影评');
                              }
                            });
                          } else {
                            YyShowDialog.showdialog(context,
                                btnText: '升级VIP',
                                cancelText: '取消', callBack: () {
                              context.push('/vip');
                            }, content: (setDialogState) {
                              return DefaultTextStyle(
                                  style: TextStyle(
                                      color: Color(0xff646464),
                                      fontSize: ScreenUtil().setSp(16),
                                      fontWeight: FontWeight.bold),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('升级VIP即可发布影评哦～'),
                                    ],
                                  ));
                            });
                          }
                        },
                        child: Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(
                              bottom:
                                  kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                          padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(12),
                              horizontal: DefaultStyle.pagePadding),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(16)),
                            height: ScreenUtil().setWidth(36),
                            child: Row(
                              children: [
                                Text(
                                  Privilege.isAllowed(
                                          context,
                                          RESOURCE_TYPE_STORY,
                                          PRIVILEGE_TYPE_COMMENT)
                                      ? PPString.vipCommentHint
                                      : PPString.noVipCommentHint,
                                  style: TextStyle(
                                      color: Color(0xff999999),
                                      fontSize: ScreenUtil().setSp(14)),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                    top: ScreenUtil().setWidth(8),
                    right: ScreenUtil().setWidth(16),
                    child: GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: PlatformAwareAssetImage(
                          url: 'assets/images/icon_close_red.png',
                          width: ScreenUtil().setWidth(24),
                          height: ScreenUtil().setWidth(24),
                          filterQuality: FilterQuality.medium),
                    ))
              ],
            );
          });
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.removeListener(changeOffset);
    isShow.dispose();
    currentSliderValue.dispose();
    _debounce.cancel();
    themeStyle.dispose();
    isFavorites.dispose();
    controller.dispose();
  }

  _fontBgItem(Map item, bool isActive) {
    return Container(
        width: 46.w,
        height: 36.w,
        decoration: BoxDecoration(
            color: item['bacgroundColor'],
            borderRadius: BorderRadius.circular(5.w),
            border: Border.all(
                width: isActive ? 2.w : 1.w,
                color: isActive ? Color(0xffFF84A9) : item['borderColor'])),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/2023/${item['icon']}.png',
          width: 22.w,
          fit: BoxFit.fitWidth,
        )
        // Text(
        //   'Aa',
        //   style: TextStyle(
        //       color: item['fontColor'],
        //       fontSize: 20.sp,
        //       fontWeight: FontWeight.bold),
        // ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ValueListenableBuilder(
                valueListenable: themeStyle,
                builder: (context, _value, child) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    color: themeList[_value]['bacgroundColor'],
                  );
                }),
          ),
          Column(
            children: [
              ValueListenableBuilder(
                  valueListenable: isShow,
                  builder: (context, show, child) {
                    return AnimatedSizeAndFade(
                      child: show
                          ? PageTitleBar(
                              paddingTop: ScreenUtil().statusBarHeight,
                              title: loading ? '' : data['name'],
                            )
                          : SizedBox(
                              width: double.infinity,
                            ),
                    );
                  }),
              Expanded(
                child: loading
                    ? PageStatus.loading(true)
                    : GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          isShow.value = !isShow.value;
                        },
                        child: ValueListenableBuilder(
                            valueListenable: currentSliderValue,
                            builder: (context, double _size, child) {
                              return ValueListenableBuilder(
                                  valueListenable: themeStyle,
                                  builder: (context, _value, child) {
                                    return AnimatedDefaultTextStyle(
                                        child: ListView.builder(
                                            controller: controller,
                                            padding: EdgeInsets.all(16.w),
                                            itemCount: content.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 6.w),
                                                child: Text(content[index]),
                                              );
                                            }),
                                        style: TextStyle(
                                            color: themeList[_value]
                                                ['fontColor'],
                                            fontSize: _size.sp),
                                        duration: Duration(milliseconds: 500));
                                  });
                            })),
              )
            ],
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: loading
                ? SizedBox()
                : ValueListenableBuilder(
                    valueListenable: isShow,
                    builder: (context, show, child) {
                      return AnimatedSizeAndFade(
                        child: show
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color(0xffFF84A9)
                                              .withOpacity(0.2),
                                          offset: Offset(0, -1),
                                          blurRadius: 5,
                                          spreadRadius: 0)
                                    ]),
                                padding: EdgeInsets.fromLTRB(12.w, 10.w, 12.w,
                                    24.w + ScreenUtil().bottomBarHeight),
                                child: Column(
                                  children: [
                                    DefaultTextStyle(
                                        style: TextStyle(
                                            color: Color(0xffFF5B8C),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (data['pre_chapter'] !=
                                                        null &&
                                                    data['pre_chapter']['id'] !=
                                                        null) {
                                                  toChaoter(
                                                      data['pre_chapter']);
                                                } else {
                                                  CommonUtils.showText(
                                                      '没有上一章啦～');
                                                }
                                              },
                                              child: Text('上一章'),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                context.push(
                                                    '/chapterList/${data['novel_id']}');
                                              },
                                              child: Text('目录'),
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  print(data['next_chapter']);
                                                  if (data['next_chapter'] !=
                                                          null &&
                                                      data['next_chapter']
                                                              ['id'] !=
                                                          null) {
                                                    toChaoter(
                                                        data['next_chapter']);
                                                  } else {
                                                    CommonUtils.showText(
                                                        '没有下一章啦～');
                                                  }
                                                },
                                                child: Text('下一章')),
                                          ],
                                        )),
                                    SizedBox(
                                      height: 20.w,
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/2023/A-pink.png',
                                          width: 28.8.w,
                                          fit: BoxFit.fitWidth,
                                        ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            if (currentSliderValue.value > 10) {
                                              currentSliderValue.value--;
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: 16.w,
                                                top: 5.w,
                                                bottom: 5.w),
                                            height: 2.w,
                                            width: 20.w,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(2.w),
                                                color: Color(0xffFF84A9)),
                                          ),
                                        ),
                                        Expanded(
                                            child: ValueListenableBuilder(
                                          valueListenable: currentSliderValue,
                                          builder: (context, value, child) {
                                            return SliderTheme(
                                                data: SliderTheme.of(context)
                                                    .copyWith(
                                                  // 修改滑块的大小
                                                  thumbShape:
                                                      RoundSliderThumbShape(
                                                    enabledThumbRadius: 7.w,
                                                  ),
                                                ),
                                                child: Slider(
                                                  value: value,
                                                  thumbColor: Color(0xffFF84A9),
                                                  inactiveColor:
                                                      Color(0xffE0E0E0),
                                                  activeColor:
                                                      Color(0xffFF84A9),
                                                  min: 10,
                                                  max: 30,
                                                  onChanged: (double value) {
                                                    currentSliderValue.value =
                                                        value;
                                                    _themeChanged(() {
                                                      AppGlobal.appBox.put(
                                                          'novel_theme', {
                                                        'fontSize':
                                                            currentSliderValue
                                                                .value,
                                                        'themeStyle':
                                                            themeStyle.value
                                                      });
                                                    }, 1000);
                                                  },
                                                ));
                                          },
                                        )),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            if (currentSliderValue.value < 30) {
                                              currentSliderValue.value++;
                                            }
                                          },
                                          child: Stack(children: [
                                            SizedBox(
                                              width: 20.w,
                                              height: 20.w,
                                            ),
                                            Positioned.fill(
                                                child: Center(
                                              child: Container(
                                                height: 2.w,
                                                width: 20.w,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.w),
                                                    color: Color(0xffFF84A9)),
                                              ),
                                            )),
                                            Positioned.fill(
                                                child: Center(
                                              child: Container(
                                                height: 20.w,
                                                width: 2.w,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.w),
                                                    color: Color(0xffFF84A9)),
                                              ),
                                            ))
                                          ]),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20.w,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: ValueListenableBuilder(
                                                valueListenable: themeStyle,
                                                builder:
                                                    (context, value, child) {
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: themeList
                                                        .asMap()
                                                        .keys
                                                        .map((e) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          themeStyle.value = e;
                                                          _themeChanged(() {
                                                            AppGlobal.appBox.put(
                                                                'novel_theme', {
                                                              'fontSize':
                                                                  currentSliderValue
                                                                      .value,
                                                              'themeStyle':
                                                                  themeStyle
                                                                      .value
                                                            });
                                                          }, 1000);
                                                        },
                                                        child: _fontBgItem(
                                                            themeList[e],
                                                            value == e),
                                                      );
                                                    }).toList(),
                                                  );
                                                })),
                                        SizedBox(
                                          width: 12.w,
                                        ),
                                        ValueListenableBuilder(
                                            valueListenable: isFavorites,
                                            builder: (context, _value, child) {
                                              return GestureDetector(
                                                onTap: _useFavorite,
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                child: Column(
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/2023/icon_like_red.png',
                                                      width: 18.w,
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                    SizedBox(
                                                      height: 4.w,
                                                    ),
                                                    Text(
                                                      _value ? '已收藏' : '收藏',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xffFF84A9),
                                                          fontSize: 14.sp,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }),
                                        SizedBox(
                                          width: 12.w,
                                        ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: showConment,
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/images/2023/icon_post_comment.png',
                                                width: 18.w,
                                                fit: BoxFit.fitWidth,
                                              ),
                                              SizedBox(
                                                height: 4.w,
                                              ),
                                              Text(
                                                '评论',
                                                style: TextStyle(
                                                    color: Color(0xffFF84A9),
                                                    fontSize: 14.sp,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                              ),
                      );
                    }),
          )
        ],
      ),
    );
  }
}
