import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';

class PageStatus {
  //全屏式loding
  static Function showLoading({String text}) {
    return BotToast.showLoading(
        backgroundColor: Colors.black45,
        wrapToastAnimation: (AnimationController animation, fc, Widget child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: ScreenUtil().setWidth(120),
                child: PlatformAwareAssetImage(
                    url: 'assets/images/loading_pink.gif',
                    fit: BoxFit.fitWidth,
                    filterQuality: FilterQuality.medium),
              ),
              SizedBox(
                height: ScreenUtil().setWidth(15),
              ),
              Text(
                text == null ? '' : text,
                style: DefaultStyle.white12,
              )
            ],
          );
        });
  }

//列表loding
  static Widget loading(bool mouted, {String text}) {
    if (mouted) {
      return SafeArea(
          child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(100)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ScreenUtil().setWidth(120),
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(50)),
              child: PlatformAwareAssetImage(
                  url: 'assets/images/loading_pink.gif',
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.medium),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(15),
            ),
            Text(
              text == null ? '正在为您加载数据...' : text,
              style: TextStyle(
                  color: Color(0xffFFA4BF), fontSize: ScreenUtil().setSp(14)),
            )
          ],
        ),
      ));
    } else {
      return Container();
    }
  }

//关闭全屏式loading
  static void closeLoading() {
    return BotToast.closeAllLoading();
  }

//无数据
  static Widget noData({String text}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(100)),
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlatformAwareAssetImage(
              url: 'assets/images/nodata.png',
              width: ScreenUtil().setWidth(100),
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium),
          SizedBox(
            height: ScreenUtil().setWidth(9),
          ),
          Text(
            text == null ? '快来填满我～' : text,
            style: TextStyle(
                color: Color(0xffFFA4BF), fontSize: ScreenUtil().setSp(14)),
          )
        ],
      ),
    );
  }

//网络错误
  static Widget noNetWork({String text, Function onTap}) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setWidth(100)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlatformAwareAssetImage(
                  url: 'assets/images/404.png',
                  width: ScreenUtil().setWidth(164),
                  filterQuality: FilterQuality.medium),
              SizedBox(
                height: ScreenUtil().setWidth(9),
              ),
              Text(
                text == null ? '加载失败，检查网络' : text,
                style: TextStyle(
                    color: Color(0xffFFA4BF), fontSize: ScreenUtil().setSp(14)),
              ),
              SizedBox(
                height: ScreenUtil().setWidth(20),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // PlatformAwareAssetImage(
                  //   url: 'assets/images/icon_shuaxin.png',
                  //   width: ScreenUtil().setWidth(14),
                  //   fit: BoxFit.fitWidth,
                  // ),
                  SizedBox(
                    width: ScreenUtil().setWidth(5),
                  ),
                  Text(
                    '轻触屏幕重试',
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        color: Color(0xfff52219)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
