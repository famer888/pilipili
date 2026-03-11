import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/store/community.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

class MyFollowPage extends StatefulWidget {
  const MyFollowPage({Key? key}) : super(key: key);

  @override
  State<MyFollowPage> createState() => _MyFollowPageState();
}

class _MyFollowPageState extends State<MyFollowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '我的關注',
          ),
          Expanded(
              child: PublicBuildList(
                  paddingLeft: 8.w,
                  paddingTop: 8.w,
                  paddingRight: 8.w,
                  api: '/api/user/list_follows',
                  isShow: true,
                  data: {},
                  itemBuild: (context, index, data, page, limit, getListData) {
                    return GestureDetector(
                      onTap: () {
                        context.push('/othersPost/${data['aff']}');
                      },
                      behavior: HitTestBehavior.translucent,
                      child: _FollowUserItem(
                        data: data,
                        isFollow: data['is_follow'] == 1,
                      ),
                    );
                  }))
        ],
      ),
    );
  }
}

class _FollowUserItem extends StatefulWidget {
  const _FollowUserItem({this.data, this.isFollow});
  final Map? data;
  final bool? isFollow;
  @override
  State<_FollowUserItem> createState() => __FollowUserItemState();
}

class __FollowUserItemState extends State<_FollowUserItem> {
  bool? isFollow = false;
  bool loadFollow = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isFollow = widget.isFollow;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 16.w),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xffECECEC), width: 0.5.w))),
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
                    url: widget.data!['thumb'],
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
                    widget.data!['nickname'],
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
                      widget.data!['vip_level'] > 0
                          ? CommonUtils.vipLevel(
                              text: 'LV${widget.data!['vip_level']}')
                          : SizedBox(),
                      SizedBox(
                        width: widget.data!['vip_level'] > 0 ? 4.w : 0,
                      ),
                      Text(
                        '${widget.data!['post_num']}篇文章',
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
              toggleFollow(widget.data!['aff']).then((res) {
                if (res['status'] != 0) {
                  isFollow = res['data']['is_follow'] == 1;
                  Provider.of<CommunityStore>(context, listen: false)
                      .setFollowData(widget.data!['aff'], isFollow!);
                } else {
                  CommonUtils.showText(res['msg'] ?? '系统错误,请稍后重试');
                }
              }).whenComplete(() {
                loadFollow = false;
              });
            },
            child: Selector<CommunityStore, Map>(
              builder: (context, followData, child) {
                int _aff = widget.data!['aff'];
                return CommonUtils.shadowBtn(
                    'assets/images/2023/icon_${(followData[_aff] ?? isFollow) ? "unfollow" : "follow"}.png',
                    text: (followData[_aff] ?? isFollow) ? '已關注' : '關注',
                    isActive: (followData[_aff] ?? isFollow));
              },
              selector: (_, communityStore) => communityStore.followData,
            ),
          ),
        ],
      ),
    );
  }
}
