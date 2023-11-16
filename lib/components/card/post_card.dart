import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/store/community.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_asset_path.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    Key key,
    this.data,
    this.showFollow = true,
    this.showLike = true,
    this.showEdit = false,
    this.topic,
  }) : super(key: key);
  final Map data;
  final bool showFollow;
  final bool showLike;
  final bool showEdit;
  final Map topic;
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isFollow = false;
  bool isLike = false;
  bool loadFollow = false;
  bool loadLike = false;
  Map user;
  Map data;
  List medias = [];
  String tag = '';
  @override
  void initState() {
    super.initState();
    data = widget.data;
    user = data['user'];
    if (user != null) {
      isFollow = user['is_follow'] == 1 ?? false;
    }
    isLike = (data['is_like'] ?? 0) == 1;
    if (data['medias'].length > 2) {
      medias = data['medias'].sublist(0, 2);
    } else {
      medias = data['medias'];
    }
    List topics = data['topics'].split(',');
    tag = topics.isEmpty ? '' : topics[0];
  }

  String getCreateTime() {
    DateTime timeint = DateTime.parse(widget.data['created_at']);
    var beforeText = RelativeDateFormat.format(timeint);
    return beforeText;
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
    return GestureDetector(
      onTap: () {
        context.push('/communityDetail/${data['id']}');
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0xffFF80A3).withOpacity(0.5),
                offset: Offset(0, 2.w),
                blurRadius: 4.w,
                spreadRadius: 0)
          ],
          borderRadius: BorderRadius.circular(11.w),
        ),
        child: Column(
          children: [
            user == null
                ? SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.w),
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              child: PlatformAwareNetworkImage(
                                url: user['thumb'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['nickname'] ?? '用户名',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Color(0XFF646464),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: 4.w,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  user['vip_level'] > 0
                                      ? CommonUtils.vipLevel(
                                          text: 'LV${user['vip_level']}')
                                      : SizedBox(),
                                  SizedBox(
                                    width: user['vip_level'] > 0 ? 4.w : 0,
                                  ),
                                  Text(
                                    getCreateTime() ?? '',
                                    style: TextStyle(
                                        color: Color(0xff979797),
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              )
                            ],
                          ))
                        ],
                      )),
                      widget.showFollow && user['is_follow'] != null
                          ? GestureDetector(
                              onTap: () {
                                if (loadFollow) {
                                  CommonUtils.showText('请勿频繁操作');
                                  return;
                                }
                                loadFollow = true;
                                toggleFollow(user['aff']).then((res) {
                                  if (res['status'] != 0) {
                                    isFollow = res['data']['is_follow'] == 1;
                                    Provider.of<CommunityStore>(context,
                                            listen: false)
                                        .setFollowData(user['aff'], isFollow);
                                  } else {
                                    CommonUtils.showText(
                                        res['msg'] ?? '系统错误,请稍后重试');
                                  }
                                }).whenComplete(() {
                                  loadFollow = false;
                                });
                              },
                              child: Selector<CommunityStore, Map>(
                                builder: (context, followData, child) {
                                  int _aff = user['aff'];
                                  return CommonUtils.shadowBtn(
                                      'assets/images/2023/icon_${(followData[_aff] ?? isFollow) ? "unfollow" : "follow"}.png',
                                      text: (followData[_aff] ?? isFollow)
                                          ? '已關注'
                                          : '關注',
                                      isActive: (followData[_aff] ?? isFollow));
                                },
                                selector: (_, communityStore) =>
                                    communityStore.followData,
                              ),
                            )
                          : SizedBox(),
                      widget.showLike && data['is_like'] != null
                          ? GestureDetector(
                              onTap: () {
                                if (loadLike) {
                                  CommonUtils.showText('请勿频繁操作');
                                  return;
                                }
                                loadLike = true;
                                communityLike(data['id'], 'post').then((res) {
                                  if (res['status'] != 0) {
                                    isLike = res['data']['is_like'] == 1;
                                    Provider.of<CommunityStore>(context,
                                            listen: false)
                                        .setLikeData(data['id'], isLike);
                                  } else {
                                    CommonUtils.showText(
                                        res['msg'] ?? '系统错误,请稍后再试');
                                  }
                                }).whenComplete(() {
                                  loadLike = false;
                                });
                              },
                              child: Selector<CommunityStore, Map>(
                                builder: (context, likeData, child) {
                                  int _id = data['id'];
                                  return CommonUtils.shadowBtn(
                                      'assets/images/2023/${(likeData[_id] ?? isLike) ? "icon_love" : "icon_post_like"}.png',
                                      text: (likeData[_id] ?? isLike)
                                          ? '已點讚'
                                          : '點讚',
                                      size: 10.w,
                                      isActive: (likeData[_id] ?? isLike));
                                },
                                selector: (_, communityStore) =>
                                    communityStore.likeData,
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
            SizedBox(
              height: 8.w,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                data['is_featured'] != 1
                    ? Container()
                    : Container(
                        alignment: Alignment.center,
                        width: 40.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xffEE86FF), Color(0xff7548D4)]),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.w),
                              topRight: Radius.circular(5.w),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(15.w),
                            )),
                        child: Text(
                          '精華',
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        )),
                data['is_featured'] != 1
                    ? Container()
                    : SizedBox(
                        width: 4.w,
                      ),
                Expanded(
                    child: Text(
                  data['title'] ?? '标题',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Color(0xff646464),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700),
                )),
                widget.showEdit
                    ? Container(
                        margin: EdgeInsets.only(left: 8.w),
                        width: 48.w,
                        height: 30.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.w),
                            gradient: DefaultStyle.defaluGrandientLine),
                        child: Text(
                          '编辑',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    : SizedBox()
              ],
            ),
            SizedBox(
              height: medias.isEmpty ? 0 : 8.w,
            ),
            medias.isEmpty
                ? SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: medias.map((e) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(3.w),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 167.w,
                              height: 100.w,
                              child: PlatformAwareNetworkImage(
                                url: e['type'] == 2
                                    ? e['cover']
                                    : e['media_url_full'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            e['type'] == 2
                                ? Positioned.fill(
                                    child: Container(
                                    color: Colors.black26,
                                    child: Center(
                                      child: PlatformAwareAssetImage(
                                          url: PPAssetsPath.iconPlay,
                                          width: 35.w,
                                          height: 35.w,
                                          filterQuality: FilterQuality.medium),
                                    ),
                                  ))
                                : SizedBox()
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            SizedBox(
              height: 16.w,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    bottomRow('comment', data['comment_num']),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                      height: 12.w,
                      width: 1.w,
                      decoration: BoxDecoration(
                          color: Color(0xffFF84A9).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5.w)),
                    ),
                    bottomRow('like', data['like_num']),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                      height: 12.w,
                      width: 1.w,
                      decoration: BoxDecoration(
                          color: Color(0xffFF84A9).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5.w)),
                    ),
                    bottomRow('view', data['view_num']),
                  ],
                ),
                SizedBox(
                  width: 16.w,
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.topic == null) {
                      context.push('/topicDetail/${data['topic_ary'][0]}',
                          isNoRepeat: true);
                    }
                  },
                  child: Text(
                    widget.topic == null ? '#$tag' : '#${widget.topic['name']}',
                    style: TextStyle(
                        color: Color(0xffFF5B8C),
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
