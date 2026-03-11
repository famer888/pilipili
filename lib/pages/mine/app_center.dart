import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/pullrefreshlist.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/model/appcenter.dart';
import 'package:pilipili/report/report_utils.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AppCenter extends StatefulWidget {
  AppCenter({Key? key}) : super(key: key);

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
    setState(() {
      banner.addAll(result.data!.banner!);
      appList.addAll(result.data!.apps!);
      ReportUtils.adVertising(
          eventType: AdEventType.show,
          advertisingKey: AdType.appsList,
          advertisingId: result.data!.apps!.map((e) => e['id']).toList().join(','),
          adSlotKey: result.data!.apps!.first['advertise_location_code'],
          adSlotName: result.data!.apps!.first['ad_slot_name'],
          adtype: result.data!.apps!.first['ad_type']);
      isLoading = false;
    });
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
    return isLoading
        ? PageStatus.loading(mounted)
        : PullRefreshList(
            onRefresh: onRefreshPost,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
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
                          padding: EdgeInsets.only(top: 24.w, left: 16.w, bottom: 16.w),
                          child: Text(
                            '推荐APP',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                        )
                      ],
                    ),
                  )
                ];
              },
              body: ListView(
                padding: EdgeInsets.zero,
                children: [
                  appList.length == 0
                      ? Container(
                          child: Center(
                            child: Text(
                              "应用列表为空",
                              style: DefaultStyle.black15bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          addRepaintBoundaries: false,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: appList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: ApplicationItem(
                                app: appList[index],
                                id: appList[index]['id'],
                                appname: appList[index]['title'],
                                iconurl: appList[index]['img_url'],
                                des: appList[index]['description'],
                                clicked: appList[index]['clicked'],
                                link: appList[index]['link_url'],
                              ),
                            );
                          })
                ],
              ),
            ));
  }
}

class SwiperContainer extends StatefulWidget {
  final List? banner;
  SwiperContainer({Key? key, this.banner}) : super(key: key);

  @override
  _SwiperContainerState createState() => _SwiperContainerState();
}

class _SwiperContainerState extends State<SwiperContainer> {
  List _banner = [];
  @override
  void initState() {
    super.initState();
    _banner = widget.banner!;
  }

  adVertising(AdEventType eventType, Map data) {
    ReportUtils.adVertising(
        eventType: eventType,
        advertisingKey: AdType.homeFloatBanner,
        advertisingId: data['id'],
        adSlotKey: data['advertise_location_code'],
        adSlotName: data['ad_slot_name'],
        adtype: data['ad_type']);
  }

  @override
  Widget build(BuildContext context) {
    return _banner.length > 1
        ? SizedBox(
            height: 160.w,
            child: Swiper(
              onTap: (index) {
                adVertising(AdEventType.click, _banner[index]);
                CommonUtils.bannerTopath(context, url: _banner[index]['url'], type: _banner[index]['type']);
              },
              itemBuilder: (BuildContext context, int index) {
                return VisibilityDetector(
                    key: Key('${ReportUtils.getAdType(AdType.welfareBanner)['key']}_Banner_${_banner[index]['id']}'),
                    child: Container(
                      width: 315.w,
                      height: 150.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.w),
                        child: PlatformAwareNetworkImage(
                          url: _banner[index]['img_url'],
                        ),
                      ),
                    ),
                    onVisibilityChanged: (info) {
                      final visibleFraction = info.visibleFraction;
                      if (visibleFraction > 0.7) {
                        adVertising(AdEventType.show, _banner[index]);
                      }
                    });
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
                ? VisibilityDetector(
                    key: Key('${ReportUtils.getAdType(AdType.welfareBanner)['key']}_Banner_${_banner[0]['id']}'),
                    child: GestureDetector(
                      onTap: () {
                        adVertising(AdEventType.click, _banner[0]);
                        CommonUtils.launchURL(_banner[0]['url'].toString());
                      },
                      child: PlatformAwareNetworkImage(
                        url: _banner[0]['img_url'],
                      ),
                    ),
                    onVisibilityChanged: (info) {
                      final visibleFraction = info.visibleFraction;
                      if (visibleFraction > 0.7) {
                        adVertising(AdEventType.show, _banner[0]);
                      }
                    })
                : SizedBox(),
          );
  }
}

class ApplicationItem extends StatefulWidget {
  final int? id;
  final String? appname;
  final String? iconurl;
  final String? des;
  final int? clicked;
  final String? link;
  final Map? app;
  ApplicationItem({Key? key, this.appname, this.iconurl, this.des, this.link, this.clicked, this.id, this.app})
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
    if ((number.toString().length - number.toString().lastIndexOf(".") - 1) < postion) {
      //小数点后有几位小数
      return number.toStringAsFixed(postion).substring(0, number.toString().lastIndexOf(".") + postion + 1).toString();
    } else {
      return number.toString().substring(0, number.toString().lastIndexOf(".") + postion + 1).toString();
    }
  }

  @override
  void initState() {
    super.initState();
    clickNumber = renderFixedNumber(widget.clicked! * 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          ReportUtils.adVertising(
              eventType: AdEventType.click,
              advertisingKey: AdType.appsList,
              advertisingId: widget.app!['id'],
              adSlotKey: widget.app!['advertise_location_code'],
              adSlotName: widget.app!['ad_slot_name'],
              adtype: widget.app!['ad_type']);
          CommonUtils.bannerTopath(context, url: widget.link, type: 1);
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
                        gradient: DefaultStyle.defaluGrandientLine, borderRadius: BorderRadius.circular(50.w)),
                    child: Center(
                      child: Text(
                        '下载',
                        style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
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
