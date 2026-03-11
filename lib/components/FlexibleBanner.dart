import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/mixin/cardMixin.dart';
import 'package:pilipili/report/report_utils.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeTopBanner extends StatefulWidget {
  const HomeTopBanner({Key key, this.fixedBanner, this.pos}) : super(key: key);
  final dynamic fixedBanner;
  final int pos;
  @override
  State<HomeTopBanner> createState() => _HomeTopBannerState();
}

class _HomeTopBannerState extends State<HomeTopBanner> with CardMixin {
  List _banner = [];
  Future<dynamic> getAd() async {
    var adBanner = await getAdForCoin(pos: widget.pos);
    if (adBanner != null && adBanner['data'] != null && adBanner['data'].length > 0) {
      _banner = adBanner['data'];
      setState(() {});
    }
  }

  adVertising(AdEventType eventType, int index) {
    ReportUtils.adVertising(
        eventType: eventType,
        advertisingKey: AdType.homeFloatBanner,
        advertisingId: _banner[index]['id'],
        adSlotKey: _banner[index]['advertise_location_code'],
        adSlotName: _banner[index]['ad_slot_name'],
        adtype: _banner[index]['ad_type']);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAd();
  }

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(clipBehavior: Clip.none, children: [
          _banner.isEmpty
              ? PlatformAwareAssetImage(
                  url: 'assets/images/demo_bg.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium)
              : Swiper(
                  autoplayDelay: 3000,
                  autoplay: _banner.length > 1,
                  physics: _banner.length > 1 ? null : new NeverScrollableScrollPhysics(),
                  pagination: SwiperPagination(
                      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(40)),
                      alignment: Alignment.bottomCenter,
                      builder: SwiperCustomPagination(builder: (BuildContext context, SwiperPluginConfig config) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _banner.asMap().keys.map<Widget>((e) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 250),
                              width: ScreenUtil().setWidth(6),
                              height: ScreenUtil().setWidth(6),
                              margin: EdgeInsets.only(left: ScreenUtil().setWidth(16)),
                              decoration: BoxDecoration(
                                  color: config.activeIndex == e ? Colors.white : Colors.white54,
                                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(3))),
                            );
                          }).toList(),
                        );
                      })),
                  itemBuilder: (BuildContext context, int index) {
                    return VisibilityDetector(
                        key: Key(
                            '${ReportUtils.getAdType(AdType.homeBanner)['key']}_${widget.pos}_Banner_${_banner[index]['id']}'),
                        child: callDetail(
                          onTap: () {
                            adVertising(AdEventType.click, index);
                            CommonUtils.bannerTopath(context, url: _banner[index]['url'], type: _banner[index]['type']);
                          },
                          cardData: _banner[index],
                          contentType: 4,
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: ShapeDecoration(shape: BeveledRectangleBorder()),
                            child: Stack(
                              children: [
                                Container(
                                  height: ScreenUtil().setWidth(260) + ScreenUtil().statusBarHeight,
                                ),
                                Positioned(
                                    top: 0,
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Container(
                                        width: double.infinity,
                                        child: PlatformAwareNetworkImage(
                                          alignment: Alignment.center,
                                          noVisibilityDetector: true,
                                          url: _banner[index]['img_url'] ?? _banner[index]['resource_url'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ),
                        onVisibilityChanged: (info) {
                          final visibleFraction = info.visibleFraction;
                          if (visibleFraction > 0.7) {
                            adVertising(AdEventType.show, index);
                          }
                        });
                  },
                  itemCount: _banner.length,
                )
        ]));
  }
}
