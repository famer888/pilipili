import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/appcenter.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class AppCenter extends StatefulWidget {
  AppCenter({Key key}) : super(key: key);

  @override
  _AppCenterState createState() => _AppCenterState();
}

class _AppCenterState extends State<AppCenter> {
  bool isLoading = true;
  List banner = [];
  List appList = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    AppCenterModel result = await getAppCenter();
    if (result != null && result.data != null) {
      setState(() {
        banner.addAll(result.data.banner);
        appList.addAll(result.data.apps);
        isLoading = false;
      });
    }
  }

  Widget applicationColumn() {
    return Expanded(
      child: appList.length == 0
          ? Container(
              color: Color(0xFFEEEEEE),
              child: Center(
                child: Text(
                  "应用列表为空",
                  style: DefaultStyle.black15bold,
                ),
              ),
            )
          : ListView.builder(
              addRepaintBoundaries: false,
              padding: EdgeInsets.zero,
              itemCount: appList.length,
              itemBuilder: (context, index) {
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.w)),
                    child: ApplicationItem(
                      id: appList[index].id,
                      appname: appList[index].title,
                      iconurl: appList[index].imgUrl,
                      des: appList[index].description,
                      clicked: appList[index].clicked,
                      link: appList[index].linkUrl,
                    ),
                  );
              }),
    );
  }

  onRefreshPost() {
    banner = [];
    appList = [];
    isLoading = true;
    setState(() {});
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        PageTitleBar(title: '应用推荐', paddingTop: ScreenUtil().statusBarHeight),
        Expanded(
          child: isLoading
              ? PageStatus.loading(mounted)
              : PullRefreshList(
                  onRefresh: onRefreshPost,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 24.w,
                      ),
                      SwiperContainer(
                        banner: banner,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 24.w, left: 16.w, bottom: 16.w),
                        child: Text(
                          '推荐APP',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp),
                        ),
                      ),
                      applicationColumn(),
                      SizedBox(
                        height: ScreenUtil().bottomBarHeight,
                      )
                    ],
                  ),
                ),
        ),
      ],
    ));
  }
}

class SwiperContainer extends StatefulWidget {
  final List banner;
  SwiperContainer({Key key, this.banner}) : super(key: key);

  @override
  _SwiperContainerState createState() => _SwiperContainerState();
}

class _SwiperContainerState extends State<SwiperContainer> {
  List _banner = [];
  @override
  void initState() {
    super.initState();
    _banner = widget.banner;
  }

  _onTapSwiper(int index) {
    if (_banner.length == 0) return;
    var item = _banner[index];
    var type = item.type;
    var _adsUrl = item.url;
    if (['', null, false].contains(_adsUrl)) {
      BotToast.showText(text: '未配置跳转链接', align: Alignment(0, 0));
      return;
    }
    switch (type) {
      case 1:
        // 外部浏览器
        CommonUtils.launchURL("$_adsUrl");
        break;
      case 3:
        // 外部浏览器
        CommonUtils.launchURL("$_adsUrl");
        break;
      case 4:
        // 外部浏览器
        CommonUtils.launchURL("$_adsUrl");
        break;
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return _banner.length > 1
        ? SizedBox(
            height: 160.w,
            child: Swiper(
              onTap: (index) {
                _onTapSwiper(index);
              },
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 315.w,
                  height: 150.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.w),
                    child: PlatformAwareNetworkImage(
                      url: _banner[index].imgUrl,
                    ),
                  ),
                );
              },
              itemCount: _banner.length,
              autoplay: _banner.length > 1,
              viewportFraction: 0.8,
              scale: 0.9,
            ))
        : Container(
            width: double.infinity,
            height: _banner.length == 1 ? 150.w : 0,
            child: _banner.length == 1
                ? GestureDetector(
                    onTap: () {
                      CommonUtils.launchURL(_banner[0].url.toString());
                    },
                    child: PlatformAwareNetworkImage(
                      url: _banner[0].imgUrl,
                    ),
                  )
                : SizedBox(),
          );
  }
}

class ApplicationItem extends StatefulWidget {
  final int id;
  final String appname;
  final String iconurl;
  final String des;
  final int clicked;
  final String link;
  ApplicationItem(
      {Key key,
      this.appname,
      this.iconurl,
      this.des,
      this.link,
      this.clicked,
      this.id})
      : super(key: key);

  @override
  _ApplicationItemState createState() => _ApplicationItemState();
}

class _ApplicationItemState extends State<ApplicationItem> {
  dynamic clickNumber;

  renderFixedNumber(double value) {
    var tips;
    if (value >= 10000) {
      var newvalue = (value / 1000) / 10.round();
      tips = formatNum(newvalue, 2) + "万";
    } else if (value >= 1000) {
      var newvalue = (value / 100) / 10.round();
      tips = formatNum(newvalue, 2) + "千";
    } else {
      tips = value.toString();
    }
    return tips;
  }

  formatNum(double number, int postion) {
    if ((number.toString().length - number.toString().lastIndexOf(".") - 1) <
        postion) {
      //小数点后有几位小数
      return number
          .toStringAsFixed(postion)
          .substring(0, number.toString().lastIndexOf(".") + postion + 1)
          .toString();
    } else {
      return number
          .toString()
          .substring(0, number.toString().lastIndexOf(".") + postion + 1)
          .toString();
    }
  }

  @override
  void initState() {
    super.initState();
    clickNumber = renderFixedNumber(widget.clicked * 1.0);
  }

  _onTapSwiper() {
    var _adsUrl = widget.link;
    if (['', null, false].contains(_adsUrl)) {
      BotToast.showText(text: '未配置跳转链接', align: Alignment(0, 0));
      return;
    }
    // 外部浏览器
    CommonUtils.launchURL("$_adsUrl");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _onTapSwiper();
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: 26.5.w),
          child: Row(
            children: [
              Expanded(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 13.w),
                    height: 64.w,
                    width: 64.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.w),
                      child: PlatformAwareNetworkImage(
                        url: widget.iconurl,
                        noVisibilityDetector: true,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.appname.toString(),
                          style: DefaultStyle.black15bold,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          clickNumber.toString() + '次下载',
                          style: DefaultStyle.lgray10,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.des.toString(),
                          style: DefaultStyle.lgray11,
                        ),
                      ],
                    ),
                  ))
                ],
              )),
              Stack(
                children: [
                  // Positioned(
                  //     top: 0,
                  //     bottom: 0,
                  //     left: 0,
                  //     right: 0,
                  //     child: PlatformAwareAssetImage(
                  // url:
                  //       'assets/pengke/video/video_duan_btn.png',
                  //       fit: BoxFit.fill,
                  //     )),
                  Container(
                    width: 56.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                        gradient: DefaultStyle.defaluGrandientLine,
                        borderRadius: BorderRadius.circular(50.w)),
                    child: Center(
                      child: Text(
                        '下载',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
