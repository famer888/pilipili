import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:pilipili/utils/privilege.dart';

class NovelCard extends StatelessWidget {
  const NovelCard({Key? key, this.data}) : super(key: key);
  final Map? data;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        bool _isAllowed = Privilege.isAllowed(
            context, RESOURCE_TYPE_STORY, PRIVILEGE_TYPE_VIEW);
        if (!_isAllowed) {
          YyShowDialog.showdialog(
            context,
            content: (setDialogState) {
              return Text(
                '您没有开启小说权限呢！天马行空的色情想法就在眼前~',
                style: TextStyle(
                    color: DefaultStyle.themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(16),
                    decoration: TextDecoration.none),
              );
            },
            cancelText: '取消',
            btnText: PPString.upgradeNuw,
            callBack: () {
              context.push('/vip');
            },
          );
          return;
        }
        context.push('/novelDetail/${data!['id']}');
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3.w),
            child: Stack(children: [
              SizedBox(
                height: 152.w,
                child: PlatformAwareNetworkImage(
                  url: 'Invalid or corrupted pad block',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 16.w,
                    width: 32.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xffFF8B8B).withOpacity(0.8),
                              Color(0xffFF7696).withOpacity(0.8),
                              Color(0xffFF7299).withOpacity(0.8)
                            ]),
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(3.w))),
                    child: Text(
                      data!['is_end'] == 1 ? '完结' : '连载',
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                  ))
            ]),
          ),
          SizedBox(
            height: 4.w,
          ),
          Text(
            data!['name'] ?? '标题',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Color(0xff646464),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }
}
