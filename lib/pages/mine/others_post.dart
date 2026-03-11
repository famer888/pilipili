import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/post_card.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/store/community.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

class OthersPostPage extends StatefulWidget {
  const OthersPostPage({Key? key, this.aff}) : super(key: key);
  final int? aff;
  @override
  State<OthersPostPage> createState() => _OthersPostPageState();
}

class _OthersPostPageState extends State<OthersPostPage> {
  bool isFollow = false;
  bool loadFollow = false;
  ValueNotifier<Map> userInfo = ValueNotifier({});
  getUserInfo() {
    otherHomeInfo(widget.aff!).then((res) {
      CommonUtils.debugPrint(res);
      if (res['status'] != 0) {
        userInfo.value = res['data'];
        isFollow = userInfo.value['is_follow'];
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误,请稍后再试');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '作者資訊',
          ),
          ValueListenableBuilder(
              valueListenable: userInfo,
              builder: (context, Map info, child) {
                return info.isEmpty
                    ? SizedBox()
                    : Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.w, horizontal: 16.w),
                        decoration: BoxDecoration(
                            color: Color(0xffffffff),
                            border: Border(
                                bottom: BorderSide(
                                    color: Color(0xffECECEC), width: 0.5.w))),
                        child: Row(
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
                                      url: info['thumb'],
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      info['nickname'],
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
                                        info['vip_level'] > 0
                                            ? CommonUtils.vipLevel(
                                                text: 'LV${info['vip_level']}')
                                            : SizedBox(),
                                        SizedBox(
                                          width:
                                              info['vip_level'] > 0 ? 4.w : 0,
                                        ),
                                        Text(
                                          '粉丝 ${CommonUtils.renderFixedNumber((info['fans_count'] ?? 0).toDouble())}',
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
                            GestureDetector(
                              onTap: () {
                                if (loadFollow) {
                                  CommonUtils.showText('请勿频繁操作');
                                  return;
                                }
                                loadFollow = true;
                                toggleFollow(info['aff']).then((res) {
                                  if (res['status'] != 0) {
                                    isFollow = res['data']['is_follow'] == 1;
                                    Provider.of<CommunityStore>(context,
                                            listen: false)
                                        .setFollowData(info['aff'], isFollow);
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
                                  int _aff = info['aff'];
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
                      );
              }),
          Expanded(
              child: PublicBuildList(
                  paddingLeft: 8.w,
                  paddingTop: 8.w,
                  paddingRight: 8.w,
                  api: '/api/community/peer_center_post',
                  isShow: true,
                  data: {'aff': widget.aff},
                  itemBuild: (context, index, data, page, limit, getListData) {
                    return PostCard(
                      data: data,
                      showFollow: false,
                    );
                  }))
        ],
      ),
    );
  }
}
