import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/model/basic.dart';
import 'package:pilipili/model/task_index.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/privilege.dart';
import 'package:provider/provider.dart';

class AppWelfareCenterPage extends StatefulWidget {
  const AppWelfareCenterPage({Key? key}) : super(key: key);

  @override
  State<AppWelfareCenterPage> createState() => _AppWelfareCenterPageState();
}

class _AppWelfareCenterPageState extends State<AppWelfareCenterPage> {
  late TaskHomeData data;
  bool loading = true;

  getTaskIndex() async {
    Basic res = await taskIndex();
    if (res.status != 0) {
      data = TaskHomeData.fromJson(res.data);
      loading = false;
      setState(() {});
    } else {
      CommonUtils.showText(res.msg ?? "获取失败");
    }
  }

  taskBtn(Task task) {
    Widget btn = Container();
    switch (task.completed) {
      case 1:
        btn = GestureDetector(
            onTap: () async {
              PageStatus.showLoading();
              Basic res = await taskUpdate(task.id!);
              PageStatus.closeLoading();
              if (res.status != 0) {
                CommonUtils.showText(res.msg ?? '领取成功');
                getUserInfo(context);
                getTaskIndex();
              } else {
                CommonUtils.showText(res.msg ?? '领取失败');
              }
            },
            child: Container(
              height: 25.w,
              padding: EdgeInsets.symmetric(horizontal: 10.5.w),
              constraints: BoxConstraints(minWidth: 60.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.5.w), color: Color(0xffff85a9)),
              child: Text(
                '领取',
                style: TextStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ));
        break;
      case 2:
        btn = Container(
          height: 25.w,
          padding: EdgeInsets.symmetric(horizontal: 10.5.w),
          constraints: BoxConstraints(minWidth: 60.w),
          alignment: Alignment.center,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(12.5.w), color: Color(0xffff85a9).withOpacity(0.4)),
          child: Text(
            '已领取',
            style: TextStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        );
        break;
      case 3:
        btn = Container(
          height: 25.w,
          padding: EdgeInsets.symmetric(horizontal: 10.5.w),
          constraints: BoxConstraints(minWidth: 60.w),
          alignment: Alignment.center,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(12.5.w), color: Color(0xffff85a9).withOpacity(0.4)),
          child: Text(
            '已领取',
            style: TextStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        );
        break;
      default:
        btn = GestureDetector(
          onTap: () async {
            switch (task.group) {
              case 1: //登录

                YyShowDialog.showdialog(context, title: '温馨提示', btnText: '确认', cancelText: '取消', callBack: () {
                  context.pop();
                  context.push('/login');
                }, content: (setDialogState) {
                  return Text(
                    '请注册绑定或登录~',
                    style: TextStyle(color: Color(0xff2f2f2f), fontSize: 14.sp),
                  );
                });
                break; //发布帖子
              case 2:
                String noPermissionPublishPostTips =
                    Provider.of<HomeConfig>(context, listen: false).noPermissionPublishPostTips;
                int allowPublishPost = Provider.of<HomeConfig>(context, listen: false).allowPublishPost;
                if (allowPublishPost != 0) {
                  context.pop();
                  context.push('/communityPushlish');
                } else {
                  bool isPublish = Privilege.isAllowed(context, RESOURCE_TYPE_POST, PRIVILEGE_TYPE_POST);
                  if (isPublish) {
                    context.pop();
                    context.push('/communityPushlish');
                  } else {
                    CommonUtils.showText(noPermissionPublishPostTips);
                  }
                }
                break;
              case 3: //评论
                CommonUtils.showText("快去发表评论完成任务吧～");
                break;
              case 4: //邀请好友
                context.pop();
                context.push('/invitefriend');
                break;
              case 5: //购买VIP
                context.pop();
                context.push('/vip');
                break;
              case 6: // 购买金币
                context.pop();
                context.push('/coinRecharge');
                break;
              case 7: //下载APP
                Basic res = await taskComplete(task.id!);
                if (res.status != 0) {
                  getTaskIndex();
                  // String officeSite = Provider.of<HomeConfig>(context, listen: false).config?.officeSite ?? "";
                  CommonUtils.launchURL(task.url!);
                } else {
                  CommonUtils.showText(res.msg ?? '错误');
                }

                break;
              default:
            }
          },
          child: Container(
            height: 25.w,
            padding: EdgeInsets.symmetric(horizontal: 10.5.w),
            constraints: BoxConstraints(minWidth: 60.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.5.w), border: Border.all(width: 1.w, color: Color(0xffff85a9))),
            child: Text(
              '去完成',
              style: TextStyle(fontSize: 13.sp, color: Color(0xffff85a9), fontWeight: FontWeight.w500),
            ),
          ),
        );
    }
    return btn;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo(context);
    getTaskIndex();
  }

  @override
  Widget build(BuildContext context) {
    return PullRefreshList(
      onRefresh: () async {
        await getTaskIndex();
        getUserInfo(context);
      },
      child: loading
          ? PageStatus.loading(true)
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.w),
              cacheExtent: 5.sh,
              children: [
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.w), color: Colors.white),
                  padding: EdgeInsets.all(10.w),
                  child: Consumer<HomeConfig>(builder: (ctx, state, child) {
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25.w),
                          child: SizedBox(
                            width: 50.w,
                            height: 50.w,
                            child: state.member.thumb == null
                                ? PlatformAwareAssetImage(
                                    url: 'assets/images/wode/avatar.png',
                                    width: 50.w,
                                    fit: BoxFit.fitWidth,
                                    filterQuality: FilterQuality.medium)
                                : PlatformAwareNetworkImage(
                                    width: 50.w,
                                    fit: BoxFit.cover,
                                    url: state.member.thumb.toString(),
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.member.nickname ?? "游客用户",
                              style: TextStyle(color: Color(0xff2f2f2f), fontSize: 14.sp),
                            ),
                            SizedBox(
                              height: 5.w,
                            ),
                            Text(
                              data.freeViewCnt! < 999 ? "剩余观看次数：${data.freeViewCnt}/${data.totalFreeViewCnt}" : "无限观影",
                              style: TextStyle(color: Color(0xff999999), fontSize: 12.sp),
                            )
                          ],
                        )
                      ],
                    );
                  }),
                ),
                if (data.freeViewCnt! < 999)
                  GestureDetector(
                    onTap: () {
                      context.push('/vip');
                    },
                    child: Container(
                      height: 45.w,
                      margin: EdgeInsets.only(top: 15.w),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22.5.w),
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF89AC), Color(0xFFFF5B8C)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )),
                      alignment: Alignment.center,
                      child: Text(
                        '开通VIP即可无限观影',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
                  ),
                SizedBox(
                  height: 30.w,
                ),
                Text.rich(
                  TextSpan(text: '福利任务', children: [
                    TextSpan(text: '  提示：若状态未更新请下拉刷新哦~', style: TextStyle(color: Color(0xff999999), fontSize: 12.sp))
                  ]),
                  style: TextStyle(color: Color(0xff2f2f2f), fontSize: 16.sp),
                ),
                SizedBox(
                  height: 21.w,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<HomeConfig>(builder: (ctx, state, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(text: '邀请人数', children: [
                                TextSpan(text: '  ${data.invitedNum}', style: TextStyle(color: Color(0xffff85a9))),
                                TextSpan(text: '  我的积分'),
                                TextSpan(text: '  ${state.userInfo.score}', style: TextStyle(color: Color(0xffff85a9)))
                              ]),
                              style: TextStyle(color: Color(0xff999999), fontSize: 13.sp),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.push('/vipExchangePage');
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 25.w,
                                padding: EdgeInsets.symmetric(horizontal: 7.w),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.5.w), color: Color(0xffff85a9)),
                                child: Text(
                                  '兑换VIP',
                                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                ),
                              ),
                            )
                          ],
                        );
                      }),
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: data.task!.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          Task task = data.task![index];
                          return Row(
                            children: [
                              Container(
                                width: 37.w,
                                height: 37.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18.5.w),
                                    color: Color(0xffff85a9).withOpacity(0.1)),
                                child: SizedBox(
                                  width: 21.w,
                                  height: 21.w,
                                  child: PlatformAwareNetworkImage(
                                    width: 50.w,
                                    fit: BoxFit.fill,
                                    url: task.icon ?? '',
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Expanded(
                                  child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${task.title}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Color(0xff2f2f2f), fontSize: 14.sp),
                                  ),
                                  SizedBox(
                                    height: 2.w,
                                  ),
                                  Text(
                                    '${task.description}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Color(0xff999999), fontSize: 12.sp),
                                  )
                                ],
                              )),
                              SizedBox(
                                width: 10.w,
                              ),
                              taskBtn(task)
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) => SizedBox(
                          height: 23.5.w,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.w, bottom: 10.w),
                        child: Text(
                          '积分兑换',
                          style: TextStyle(color: Color(0xff2f2f2f), fontSize: 16.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: data.product!.length,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 9.w,
                            crossAxisSpacing: 9.w,
                            childAspectRatio: 336 / 217),
                        itemBuilder: (context, index) {
                          Product item = data.product![index];
                          return Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${item.pname}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Color(0xff2f2f2f), fontSize: 16.sp, fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          '${item.description}!',
                                          style: TextStyle(color: Color(0xff999999), fontSize: 10.sp),
                                        )
                                      ],
                                    )),
                                    SizedBox(
                                      width: 45.w,
                                      height: 45.w,
                                      child: PlatformAwareNetworkImage(
                                        fit: BoxFit.fill,
                                        url: item.img ?? '',
                                      ),
                                    )
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    YyShowDialog.showdialog(context, title: '温馨提示', btnText: '确认', cancelText: '取消',
                                        callBack: () async {
                                      Basic res = await onOrderExchange(product_id: item.id);
                                      if (res.status != 0) {
                                        CommonUtils.showText(res.msg ?? '兑换成功');
                                        getUserInfo(context);
                                      } else {
                                        CommonUtils.showText(res.msg ?? '兑换失败');
                                      }
                                    }, content: (setDialogState) {
                                      return Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(text: '是否使用 '),
                                            TextSpan(
                                                text: '${item.coins}',
                                                style:
                                                    TextStyle(color: Color(0xffff4c9a), fontWeight: FontWeight.bold)),
                                            TextSpan(text: ' 积分,兑换 '),
                                            TextSpan(
                                                text: '${item.pname}',
                                                style:
                                                    TextStyle(color: Color(0xffff4c9a), fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        style: TextStyle(color: Color(0xff2f2f2f), fontSize: 14.sp),
                                      );
                                    });
                                  },
                                  child: Container(
                                    height: 32.w,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16.w),
                                        gradient: LinearGradient(
                                          colors: [Color(0xFFFF89AC), Color(0xFFFF5B8C)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )),
                                    child: Text(
                                      "${item.coins} 积分兑换",
                                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
