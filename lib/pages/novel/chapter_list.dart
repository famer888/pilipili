import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/pili/publish_biuld_list.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/privilege.dart';
import 'package:provider/provider.dart';

class ChapterList extends StatefulWidget {
  const ChapterList({Key key, this.id}) : super(key: key);
  final int id;
  @override
  State<ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  bool isBuy = false;
  toChaoter(Map item) {
    if (item['payment_type'] == 'free') {
      //免费
      context.push('/novelReader/${item['id']}',
          replace: true, isNoRepeat: true);
    } else if (item['payment_type'] == 'vip') {
      //vip
      bool isView = Privilege.isAllowed(
          context, RESOURCE_TYPE_STORY, PRIVILEGE_TYPE_VIEW);
      if (isView) {
        context.push('/novelReader/${item['id']}',
            replace: true, isNoRepeat: true);
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
        context.push('/novelReader/${item['id']}',
            replace: true, isNoRepeat: true);
      } else {
        int money =
            Provider.of<HomeConfig>(context, listen: false).member.money;
        bool isInsufficient =
            money < double.parse(item['coins'].toString()).toInt();
        YyShowDialog.showdialog(context,
            title: '温馨提示',
            btnText: isInsufficient ? '余额不足,去充值' : '立即购买',
            cancelText: isInsufficient ? null : '取消', callBack: () {
          if (isInsufficient) {
            context.push('/coinRecharge');
          } else {
            PageStatus.showLoading();
            novelBuy(item['novel_id']).then((res) async {
              if (res['status'] != 0) {
                CommonUtils.showText('购买成功');
                isBuy = true;
                context.push('/novelReader/${item['id']}',
                    replace: true, isNoRepeat: true);
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
              child: Text(
                  '花費${double.parse(item['coins'].toString()).toInt()}皮哩币观看完整小說'));
        });
      }
    }
  }

  Widget _chapterItem(Map item) {
    int firstSpaceIndex = item['name'].indexOf(' ');
    return GestureDetector(
      onTap: () {
        toChaoter(item);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: ScreenUtil().statusBarHeight,
          ),
          PageTitleBar(
            title: '章节列表',
          ),
          Expanded(
              child: PublicBuildList(
                paddingTop: 16.w,
                  paddingLeft: 16.w,
                  paddingRight: 16.w,
                  api: '/api/novel/getChapterList',
                  isShow: true,
                  data: {'novelId': widget.id},
                  nullText: '还没有数据哦～',
                  itemBuild: (context, index, data, page, limit, getListData) {
                    return _chapterItem(data);
                  }))
        ],
      ),
    );
  }
}
