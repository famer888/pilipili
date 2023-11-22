import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/comment_item.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/input/InputDailog.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/model/homedata.dart';
import 'package:pilipili/store/community.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/crypto.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_asset_path.dart';
import 'package:pilipili/utils/privilege.dart';
import 'package:provider/provider.dart';

class CommunityDetail extends StatefulWidget {
  const CommunityDetail({Key key, this.id}) : super(key: key);
  final int id;
  @override
  State<CommunityDetail> createState() => _CommunityDetailState();
}

class _CommunityDetailState extends State<CommunityDetail> {
  bool isFollow = false;
  bool loading = true;
  bool loadFollow = false;
  String tag = '';
  Map detailData = {};
  int limit = 15;
  int page = 1;
  Map picMap = {};
  bool isAll = false;
  bool isLike = false;
  ValueNotifier<List> commentList = ValueNotifier([]);

  getComentList(int id) {
    getPostComments(id, page, limit).then((res) {
      if (isAll) return;
      List newComments = commentList.value;
      if (res['status'] != 0) {
        if (page == 1) {
          newComments = res['data'];
        } else {
          newComments = [...newComments, ...res['data']];
        }
        isAll = res['data'].length < limit;
        commentList.value = newComments;
      } else {
        CommonUtils.showText(res['msg'] ?? '接口异常,请稍后再试');
      }
    });
  }

  String getCover(Map item) {
    String path = '';
    if (item['cover'] != '' && item['cover'] != null) {
      path = item['cover'];
    } else if (item['media_url'] != '' && item['media_url'] != null) {
      path = item['media_url'];
    } else {
      path = item['media_url_full'];
    }
    return path;
  }

  showUnlok(int type) {
    if (type == 1) {
      YyShowDialog.showdialog(context,
          title: '温馨提示', btnText: '开通会员', cancelText: '取消', callBack: () {
        context.push('/vip');
      }, content: (setDialogState) {
        return DefaultTextStyle(
            style: TextStyle(
                color: Color(0xff646464),
                fontSize: ScreenUtil().setSp(16),
                fontWeight: FontWeight.bold),
            child: Text('是否开通会员解锁观看所有内容?'));
      });
    } else {
      YyShowDialog.showdialog(context,
          title: '温馨提示', btnText: '解锁', cancelText: '取消', callBack: () {
        PageStatus.showLoading();
        unlockPost(detailData['id']).then((res) {
          if (res['status'] != 0) {
            CommonUtils.showText('解锁成功');
            getDetailData();
          } else {
            CommonUtils.showText(res['msg'] ?? '系统错误,请稍后再试');
          }
        }).whenComplete(() {
          PageStatus.closeLoading();
        });
      }, content: (setDialogState) {
        return DefaultTextStyle(
            style: TextStyle(
                color: Color(0xff646464),
                fontSize: ScreenUtil().setSp(16),
                fontWeight: FontWeight.bold),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '确定花费'),
              TextSpan(
                  text: ' ${detailData['unlock_coins']}皮哩币 ',
                  style: TextStyle(color: Color(0xffFF84A9))),
              TextSpan(text: '解锁该帖吗？'),
            ])));
      });
    }
  }

  getDetailData() {
    postDetail(widget.id).then((res) {
      CommonUtils.debugPrint(res);
      if (res['status'] != 0) {
        detailData = res['data']['detail'];
        isLike = detailData['is_like'] == 1;
        List topics = detailData['topics'].split(',');
        tag = topics.isEmpty ? '' : topics[0];
        loading = false;
        setState(() {});
        picMap = {
          'resources': List.from(detailData['medias']).map((e) {
            return getCover(e);
          }).toList(),
          'index': 0
        };
        getComentList(detailData['id']);
      } else {
        CommonUtils.showText(res['msg'] ?? '接口异常,稍后再试');
      }
    }).whenComplete(() {
      PageStatus.closeLoading();
    });
  }

  String getCreateTime() {
    DateTime timeint = DateTime.parse(detailData['created_at']);
    var beforeText = RelativeDateFormat.format(timeint);
    return beforeText;
  }

  @override
  void initState() {
    super.initState();
    getDetailData();
  }

  @override
  void dispose() {
    commentList.dispose();
    super.dispose();
  }

  getPosType(int type, bool isView) {
    Widget _btn = SizedBox();
    switch (type) {
      case 1: //vip
        _btn = !isView
            ? GestureDetector(
                onTap: () {
                  showUnlok(type);
                },
                child: Container(
                  height: 32.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.w),
                      gradient: DefaultStyle.defaluGrandientLine),
                  child: Text(
                    '开通会员解锁',
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              )
            : SizedBox();
        break;
      case 2: //金币
        _btn = detailData['is_pay'] != 1 && detailData['unlock_coins'] > 0
            ? GestureDetector(
                onTap: () {
                  showUnlok(type);
                },
                child: Container(
                  height: 32.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.w),
                      gradient: DefaultStyle.defaluGrandientLine),
                  child: Text(
                    '解鎖媒體(${detailData['unlock_coins']}皮哩币)',
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              )
            : SizedBox();
        break;
      default:
    }
    return _btn;
  }

  Widget bottomRow(String icon, int _num) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        getImage('assets/images/2023/icon_post_$icon.png',
            width: 16.w, height: 16.w, isAssets: true),
        SizedBox(
          width: 8.w,
        ),
        Text(
          CommonUtils.renderFixedNumber(_num.toDouble()),
          style: TextStyle(
              color: Color(0xffFF84A9),
              fontSize: 12.sp,
              fontWeight: FontWeight.w700),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var member = Provider.of<HomeConfig>(context, listen: false).member;
    bool isView =
        Privilege.isAllowed(context, RESOURCE_TYPE_POST, PRIVILEGE_TYPE_VIEW);
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: detailData['title'] ?? '',
          ),
          Expanded(
              child: loading
                  ? PageStatus.loading(true)
                  : PullRefreshList(
                      onLoading: () {
                        page++;
                        isAll = false;
                        getComentList(detailData['id']);
                      },
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: GestureDetector(
                                        onTap: () {
                                          context.push(
                                              '/othersPost/${detailData['user']['aff']}');
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20.w),
                                              child: Container(
                                                width: 40.w,
                                                height: 40.w,
                                                child:
                                                    PlatformAwareNetworkImage(
                                                  url: detailData['user']
                                                      ['thumb'],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8.w,
                                            ),
                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  detailData['user']
                                                      ['nickname'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Color(0XFF646464),
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                SizedBox(
                                                  height: 4.w,
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    detailData['user']
                                                                ['vip_level'] >
                                                            0
                                                        ? CommonUtils.vipLevel(
                                                            text:
                                                                'LV${detailData['user']['vip_level']}')
                                                        : SizedBox(),
                                                    SizedBox(
                                                      width: detailData['user'][
                                                                  'vip_level'] >
                                                              0
                                                          ? 4.w
                                                          : 0,
                                                    ),
                                                    Text(
                                                      getCreateTime(),
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff979797),
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ))
                                          ],
                                        ),
                                      )),
                                      GestureDetector(
                                        onTap: () {
                                          if (loadFollow) {
                                            CommonUtils.showText('请勿频繁操作');
                                            return;
                                          }
                                          loadFollow = true;
                                          toggleFollow(
                                                  detailData['user']['aff'])
                                              .then((res) {
                                            if (res['status'] != 0) {
                                              isFollow =
                                                  res['data']['is_follow'] == 1;
                                              Provider.of<CommunityStore>(
                                                      context,
                                                      listen: false)
                                                  .setFollowData(
                                                      detailData['user']['aff'],
                                                      isFollow);
                                            } else {
                                              CommonUtils.showText(
                                                  res['msg'] ?? '系统错误,请稍后重试');
                                            }
                                          }).whenComplete(() {
                                            loadFollow = false;
                                          });
                                        },
                                        child: Selector<CommunityStore, Map>(
                                          builder:
                                              (context, followData, child) {
                                            int _aff =
                                                detailData['user']['aff'];
                                            return CommonUtils.shadowBtn(
                                                'assets/images/2023/icon_${(followData[_aff] ?? isFollow) ? "unfollow" : "follow"}.png',
                                                text: (followData[_aff] ??
                                                        isFollow)
                                                    ? '已關注'
                                                    : '關注',
                                                isActive: (followData[_aff] ??
                                                    isFollow));
                                          },
                                          selector: (_, communityStore) =>
                                              communityStore.followData,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          communityLike(
                                                  detailData['id'], 'post')
                                              .then((res) {
                                            if (res['status'] != 0) {
                                              isLike =
                                                  res['data']['is_like'] == 1;
                                              Provider.of<CommunityStore>(
                                                      context,
                                                      listen: false)
                                                  .setLikeData(
                                                      detailData['id'], isLike);
                                            } else {
                                              CommonUtils.showText(
                                                  res['msg'] ?? '系统错误,请稍后再试');
                                            }
                                          });
                                        },
                                        child: Selector<CommunityStore, Map>(
                                          builder: (context, likeData, child) {
                                            int _id = detailData['id'];
                                            return CommonUtils.shadowBtn(
                                                'assets/images/2023/${(likeData[_id] ?? isLike) ? "icon_love" : "icon_post_like"}.png',
                                                text: (likeData[_id] ?? isLike)
                                                    ? '已點讚'
                                                    : '點讚',
                                                size: 10.w,
                                                isActive:
                                                    (likeData[_id] ?? isLike));
                                          },
                                          selector: (_, communityStore) =>
                                              communityStore.likeData,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.push('/promote');
                                        },
                                        child: CommonUtils.shadowBtn(
                                            'assets/images/2023/icon_post_share.png',
                                            text: '分享',
                                            isActive: false),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.w,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          bottomRow('comment',
                                              detailData['comment_num']),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 16.w),
                                            height: 12.w,
                                            width: 1.w,
                                            decoration: BoxDecoration(
                                                color: Color(0xffFF84A9)
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(5.w)),
                                          ),
                                          bottomRow(
                                              'like', detailData['like_num']),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 16.w),
                                            height: 12.w,
                                            width: 1.w,
                                            decoration: BoxDecoration(
                                                color: Color(0xffFF84A9)
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(5.w)),
                                          ),
                                          bottomRow(
                                              'view', detailData['view_num']),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 16.w,
                                      ),
                                      tag.isEmpty
                                          ? SizedBox()
                                          : GestureDetector(
                                              onTap: () {
                                                context.push(
                                                    '/topicDetail/${detailData['topic_ary'][0]}',
                                                    isNoRepeat: true);
                                              },
                                              child: Text(
                                                '#$tag',
                                                style: TextStyle(
                                                    color: Color(0xffFF5B8C),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14.sp),
                                              ),
                                            )
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.w),
                                    child: Text(
                                      detailData['content'] ?? '',
                                      style: TextStyle(
                                          color: Color(0xff646464),
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      getPosType(detailData['type'], isView)
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.from(detailData['medias'])
                                        .asMap()
                                        .keys
                                        .map((e) {
                                      Map _item = detailData['medias'][e];
                                      bool noSize = _item['thumb_width'] == 0 ||
                                          _item['thumb_height'] == 0;
                                      return GestureDetector(
                                        onTap: () {
                                          if ((detailData['is_pay'] != 1 &&
                                                  detailData['unlock_coins'] >
                                                      0 &&
                                                  detailData['type'] == 2) ||
                                              (detailData['type'] == 1 &&
                                                  !isView)) {
                                            showUnlok(detailData['type']);
                                            return;
                                          }
                                          if (_item['type'] == 1) {
                                            picMap['index'] = e;
                                            String data =
                                                pliEncry(jsonEncode(picMap));
                                            context.push(
                                                '/homepreviewviewpage/$data');
                                          } else {
                                            context.push(
                                                '/videoPreview/${Uri.encodeComponent(_item['media_url_full'])}/${Uri.encodeComponent(_item['cover'])}');
                                          }
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 8.w),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.w),
                                            child: Stack(
                                              children: [
                                                LayoutBuilder(
                                                    builder: (context, box) {
                                                  return Container(
                                                    height: noSize ||
                                                            _item['type'] != 1
                                                        ? 200.w
                                                        : (box.maxWidth /
                                                                _item[
                                                                    'thumb_width']) *
                                                            _item[
                                                                'thumb_height'],
                                                    width: box.maxWidth,
                                                    child:
                                                        PlatformAwareNetworkImage(
                                                            url:
                                                                getCover(_item),
                                                            fit: BoxFit.cover),
                                                  );
                                                }),
                                                (detailData['type'] == 1 &&
                                                            detailData[
                                                                    'is_pay'] !=
                                                                1 &&
                                                            detailData[
                                                                    'unlock_coins'] >
                                                                0) ||
                                                        (detailData['type'] ==
                                                                1 &&
                                                            !isView)
                                                    ? Positioned.fill(
                                                        child: ClipRect(
                                                            child:
                                                                BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 5.0,
                                                                sigmaY: 5.0),
                                                        child: Opacity(
                                                          opacity: 0.5,
                                                          child: Container(
                                                            color: Color(
                                                                0xff6E1D35),
                                                          ),
                                                        ),
                                                      )))
                                                    : SizedBox(),
                                                _item['type'] != 1
                                                    ? Positioned.fill(
                                                        child: Container(
                                                        color: Colors.black26,
                                                        child: Center(
                                                          child: PlatformAwareAssetImage(
                                                              url: PPAssetsPath
                                                                  .iconPlay,
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          80),
                                                              height:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          80),
                                                              filterQuality:
                                                                  FilterQuality
                                                                      .medium),
                                                        ),
                                                      ))
                                                    : SizedBox()
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SliverPersistentHeader(
                              pinned: true,
                              delegate: IndexPageHeaderDelegate(
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color(0xffFFD3E6),
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                              spreadRadius: 0)
                                        ]),
                                    height: 40.w,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                    child: Row(
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 11.w),
                                              child: getImage(
                                                  'assets/images/2023/icon_love_red2.png',
                                                  height: 5.w,
                                                  fit: BoxFit.fitHeight,
                                                  isAssets: true),
                                            ),
                                            Text(
                                              '评论(${detailData['comment_num']})',
                                              style: TextStyle(
                                                  color: Color(0xffFF5B8C),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14.sp),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  maxHeight: 40.w,
                                  minHeight: 40.w)),
                          ValueListenableBuilder(
                              valueListenable: commentList,
                              builder: (context, List coment, child) {
                                return coment.isEmpty
                                    ? SliverToBoxAdapter(
                                        child: PageStatus.noData(),
                                      )
                                    : SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              // if (Privilege.isAllowed(
                                              //     context,
                                              //     RESOURCE_TYPE_POST,
                                              //     PRIVILEGE_TYPE_COMMENT)) {
                                              InputDialog.show(
                                                      context, '请输入您的影评～')
                                                  .then((value) {
                                                if (value != null &&
                                                    value != '') {
                                                  communityComment({
                                                    'comment_id': coment[index]
                                                        ['id'],
                                                    'content': value
                                                  }).then((res) {
                                                    if (res['status'] != 0) {
                                                      CommonUtils.showText(
                                                          '影评发布成功,请刷新查看～');
                                                    } else {
                                                      CommonUtils.debugPrint(
                                                          res);
                                                      CommonUtils.showText(
                                                          res['msg']);
                                                    }
                                                  });
                                                } else {
                                                  CommonUtils.showText(
                                                      '请输入您的影评');
                                                }
                                              });
                                              // } else {
                                              //   YyShowDialog.showdialog(context,
                                              //       title: '温馨提示',
                                              //       btnText: '升级VIP',
                                              //       cancelText: '取消',
                                              //       callBack: () {
                                              //     context.push('/vip');
                                              //   }, content: (setDialogState) {
                                              //     return DefaultTextStyle(
                                              //         style:
                                              //             DefaultStyle.black14,
                                              //         child: Column(
                                              //           crossAxisAlignment:
                                              //               CrossAxisAlignment
                                              //                   .start,
                                              //           children: [
                                              //             Text(
                                              //               '升级VIP即可发布影评哦～',
                                              //               style: TextStyle(
                                              //                   color: Color(
                                              //                       0xffFF5B8C),
                                              //                   fontWeight:
                                              //                       FontWeight
                                              //                           .bold,
                                              //                   fontSize:
                                              //                       16.sp),
                                              //             ),
                                              //           ],
                                              //         ));
                                              //   });
                                              // }
                                            },
                                            child: CommentItem(
                                              data: coment[index],
                                            ),
                                          );
                                        },
                                        childCount: coment.length,
                                        addSemanticIndexes: false,
                                        addRepaintBoundaries: true,
                                        addAutomaticKeepAlives: true,
                                      ));
                              })
                        ],
                      ),
                    )),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
                vertical: 9.w, horizontal: DefaultStyle.pagePadding),
            child: GestureDetector(
              onTap: () {
                // if (Privilege.isAllowed(
                //     context, RESOURCE_TYPE_POST, PRIVILEGE_TYPE_COMMENT)) {
                InputDialog.show(context, '请输入您的影评～').then((value) {
                  if (value != null && value != '') {
                    communityComment({'post_id': widget.id, 'content': value})
                        .then((res) {
                      if (res['status'] != 0) {
                        CommonUtils.showText('影评发布成功,请刷新查看～');
                      } else {
                        CommonUtils.debugPrint(res);
                        CommonUtils.showText(res['msg']);
                      }
                    });
                  } else {
                    CommonUtils.showText('请输入您的影评');
                  }
                });
                // } else {
                //   YyShowDialog.showdialog(context,
                //       title: '温馨提示',
                //       btnText: '升级VIP',
                //       cancelText: '取消', callBack: () {
                //     context.push('/vip');
                //   }, content: (setDialogState) {
                //     return DefaultTextStyle(
                //         style: DefaultStyle.black14,
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               '升级VIP即可发布影评哦～',
                //               style: TextStyle(
                //                   color: Color(0xffFF5B8C),
                //                   fontWeight: FontWeight.bold,
                //                   fontSize: 16.sp),
                //             ),
                //           ],
                //         ));
                //   });
                // }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                height: 36.w,
                child: Row(
                  children: [
                    Text(
                      '能不能火就靠你啦～',
                      style:
                          TextStyle(color: Color(0xff979797), fontSize: 14.sp),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom +
                AppGlobal.webBottomHeight,
          )
        ],
      ),
    );
  }
}

class IndexPageHeaderDelegate extends SliverPersistentHeaderDelegate {
  IndexPageHeaderDelegate(this.child,
      {this.minHeight = 50, this.maxHeight = 50});

  Widget child;
  final double minHeight;
  final double maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
