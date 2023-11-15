import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/card/comment_item.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/input/InputDailog.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class CommunityDetail extends StatefulWidget {
  const CommunityDetail({Key key, this.id}) : super(key: key);
  final int id;
  @override
  State<CommunityDetail> createState() => _CommunityDetailState();
}

class _CommunityDetailState extends State<CommunityDetail> {
  bool isFollow = false;

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
          _num.toString(),
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
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '我是標題，但好像大家都打很多字我是標題，但好像大家都打很多字',
          ),
          Expanded(
              child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child:GestureDetector(
                                onTap: (){
                                  context.push('/othersPost/1');
                                },
                                child:  Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.w),
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  child: PlatformAwareNetworkImage(
                                    url: '',
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
                                    '天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看天天都要看',
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
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w),
                                        height: 18.w,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(9.w),
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xffFFD875),
                                                  Color(0XFFFF6915),
                                                ])),
                                        child: Text(
                                          '會員等級',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Text(
                                        '三小时前',
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
                          ),)),
                          GestureDetector(
                            onTap: () {
                              isFollow = !isFollow;
                              setState(() {});
                            },
                            child: CommonUtils.shadowBtn(
                                'assets/images/2023/icon_${isFollow ? "unfollow" : "follow"}.png',
                                text: isFollow ? '已關注' : '關注',
                                isActive: isFollow),
                          ),
                          GestureDetector(
                            onTap: () {
                              isFollow = !isFollow;
                              setState(() {});
                            },
                            child: CommonUtils.shadowBtn(
                                'assets/images/2023/${isFollow ? "icon_love" : "icon_post_like"}.png',
                                text: isFollow ? '已點讚' : '點讚',
                                size: 10.w,
                                isActive: isFollow),
                          ),
                          GestureDetector(
                            onTap: () {
                              isFollow = !isFollow;
                              setState(() {});
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
                              bottomRow('comment', 122),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16.w),
                                height: 12.w,
                                width: 1.w,
                                decoration: BoxDecoration(
                                    color: Color(0xffFF84A9).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(5.w)),
                              ),
                              bottomRow('like', 332),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16.w),
                                height: 12.w,
                                width: 1.w,
                                decoration: BoxDecoration(
                                    color: Color(0xffFF84A9).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(5.w)),
                              ),
                              bottomRow('view', 122),
                            ],
                          ),
                          SizedBox(
                            width: 16.w,
                          ),
                          Text(
                            '#破處回憶',
                            style: TextStyle(
                                color: Color(0xffFF5B8C),
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.w),
                        child: Text(
                          '內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文內文',
                          style: TextStyle(
                              color: Color(0xff646464),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 32.w,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.w),
                                gradient: DefaultStyle.defaluGrandientLine),
                            child: Text(
                              '解鎖媒體(500金幣)',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.w),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.w),
                            child: Stack(
                              children: [
                                Container(
                                  height: 200.w,
                                  child: PlatformAwareNetworkImage(
                                      url: '', fit: BoxFit.cover),
                                ),
                                Positioned.fill(
                                    child: ClipRect(
                                        child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 5.0, sigmaY: 5.0),
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: Container(
                                      color: Color(0xff6E1D35),
                                    ),
                                  ),
                                ))),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                  pinned: true,
                  delegate: IndexPageHeaderDelegate(
                      Container(
                        decoration:
                            BoxDecoration(color: Colors.white, boxShadow: [
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 11.w),
                                  child: getImage(
                                      'assets/images/2023/icon_love_red2.png',
                                      height: 5.w,
                                      fit: BoxFit.fitHeight,
                                      isAssets: true),
                                ),
                                Text(
                                  '评论(200)',
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
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return CommentItem();
                },
                childCount: 20,
                addSemanticIndexes: false,
                addRepaintBoundaries: true,
                addAutomaticKeepAlives: true,
              ))
            ],
          )),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
                vertical: 9.w, horizontal: DefaultStyle.pagePadding),
            child: GestureDetector(
              onTap: () {
                if (false) {
                  InputDialog.show(context, '请输入您的影评～').then((value) {
                    if (value != null && value != '') {
                      publishComment(
                              contentId: widget.id,
                              contentType: 1,
                              reply: value)
                          .then((res) {
                        if (res['status'] != 0) {
                          CommonUtils.showText('影评发布成功,请刷新查看～');
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
                      title: '温馨提示',
                      btnText: '升级VIP',
                      cancelText: '取消', callBack: () {
                    context.push('/vip');
                  }, content: (setDialogState) {
                    return DefaultTextStyle(
                        style: DefaultStyle.black14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '升级VIP即可发布影评哦～',
                              style: TextStyle(
                                  color: Color(0xffFF5B8C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp),
                            ),
                          ],
                        ));
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                height: 36.w,
                child: Row(
                  children: [
                    Text(
                      false ? '能不能火就靠你啦～' : '升级VIP即可发布影评哦～',
                      style:
                          TextStyle(color: Color(0xff979797), fontSize: 14.sp),
                    )
                  ],
                ),
              ),
            ),
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
