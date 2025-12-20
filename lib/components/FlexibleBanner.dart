import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/mixin/cardMixin.dart';
import 'package:pilipili/report/report_utils.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeTopBanner extends StatefulWidget {
  const HomeTopBanner({Key key, this.fixedBanner}) : super(key: key);
  final dynamic fixedBanner;
  @override
  State<HomeTopBanner> createState() => _HomeTopBannerState();
}

class _HomeTopBannerState extends State<HomeTopBanner> with CardMixin {
  adVertising(AdEventType eventType, int index) {
    ReportUtils.adVertising(
        eventType: eventType,
        advertisingKey: AdType.homeFloatBanner,
        advertisingId: widget.fixedBanner['value'][index]['id'],
        adSlotKey: widget.fixedBanner['value'][index]['advertise_location_code'],
        adSlotName: widget.fixedBanner['value'][index]['ad_slot_name'],
        adtype: widget.fixedBanner['value'][index]['ad_type']);
  }

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(clipBehavior: Clip.none, children: [
          widget.fixedBanner == null || !(widget.fixedBanner is Map) || widget.fixedBanner['value'].length == 0
              ? PlatformAwareAssetImage(
                  url: 'assets/images/demo_bg.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium)
              : Swiper(
                  autoplayDelay: 3000,
                  autoplay: widget.fixedBanner['value'].length > 1,
                  physics: widget.fixedBanner['value'].length > 1 ? null : new NeverScrollableScrollPhysics(),
                  onIndexChanged: (e) {
                    // CommonUtils.debugPrint('-------------------$e---------------------');
                  },
                  pagination: SwiperPagination(
                      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(40)),
                      alignment: Alignment.bottomCenter,
                      builder: SwiperCustomPagination(builder: (BuildContext context, SwiperPluginConfig config) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.fixedBanner['value'].asMap().keys.map<Widget>((e) {
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
                            '${ReportUtils.getAdType(AdType.homeBanner)['key']}_Banner_${widget.fixedBanner['value'][index]['id']}'),
                        child: callDetail(
                          onTap: () {
                            adVertising(AdEventType.click, index);
                          },
                          cardData: widget.fixedBanner['value'][index],
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
                                          url: widget.fixedBanner['value'][index]['resource_url'],
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
                  itemCount: widget.fixedBanner['value'].length,
                )
        ]));
  }
}
