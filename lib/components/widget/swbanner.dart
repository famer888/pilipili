import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

class SwBanner extends StatefulWidget {
  SwBanner({Key key, this.data, this.element}) : super(key: key);
  final dynamic data;
  final dynamic element;
  @override
  _SwBannerState createState() => _SwBannerState();
}

class _SwBannerState extends State<SwBanner> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.data.length == 0 || widget.data == null
        ? Container()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints box) {
              return Container(
                width: box.maxWidth,
                height: (box.maxWidth / 7) * 2,
                margin: EdgeInsets.only(
                    bottom: ScreenUtil()
                        .setWidth(widget.element['is_margin'] == 1 ? 20 : 0)),
                child: Swiper(
                  autoplayDelay: 10000,
                  autoplay: widget.data.length > 1,
                  pagination: widget.data.length > 1
                      ? SwiperPagination(
                          margin: EdgeInsets.all(0),
                          alignment: Alignment.bottomRight,
                          builder: SwiperCustomPagination(builder:
                              (BuildContext context,
                                  SwiperPluginConfig config) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children:
                                  widget.data.asMap().keys.map<Widget>((e) {
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 250),
                                  width: ScreenUtil().setWidth(
                                      config.activeIndex == e ? 15.5 : 5),
                                  height: ScreenUtil().setWidth(1.5),
                                  margin: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(3)),
                                  decoration: BoxDecoration(
                                      color: DefaultStyle.themeColor,
                                      borderRadius: BorderRadius.circular(
                                          ScreenUtil().setWidth(0.8))),
                                );
                              }).toList(),
                            );
                          }))
                      : null,
                  onIndexChanged: (e) {
                    // CommonUtils.debugPrint('-------------------$e---------------------');
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        if (widget.data[index]['redirect_type'] == 1) {
                          String linkUrl = widget.data[index]['link_url'];
                          List urlList = linkUrl.split('?');
                          Map<String, dynamic> pramas = {};
                          if (urlList.length > 1) {
                            urlList[1].split("&").forEach((item) {
                              List stringText = item.split('=');
                              pramas[stringText[0]] =
                                  stringText.length > 1 ? stringText[1] : null;
                            });
                          }
                          context.push(urlList[0], extra: pramas);
                        } else if (widget.data[index]['redirect_type'] == 2) {
                          CommonUtils.launchURL(
                              widget.data[index]['link_url'].trim());
                        } else if (widget.data[index]['redirect_type'] == 3) {
                          //跳转结构
                          String linkUrl = widget.data[index]['link_url'];
                          List urlList = linkUrl.split('?');
                          if (urlList.length > 1) {
                            if (urlList[0] == 'video') {
                              int _cindex = AppGlobal.navList.indexWhere(
                                  (item) => item.name == urlList[1]);
                              //跳转结构
                              try {
                                EventBus().emit('pili_ciyuan',
                                    _cindex == null ? 0 : _cindex);
                              } catch (e) {}
                              return;
                            }
                          }
                        } else if (widget.data[index]['redirect_type'] == 4) {
                          var members =
                              Provider.of<HomeConfig>(context, listen: false)
                                  .member;
                          var aff = members.aff;
                          var piliid = members.uuid;
                          CommonUtils.launchURL(
                              widget.data[index]['link_url'].trim() +
                                  '?aff=$aff&piliid=$piliid');
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: ScreenUtil()
                              .setWidth(widget.data.length > 1 ? 5 : 0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.w),
                          child: PlatformAwareNetworkImage(
                              noVisibilityDetector: true,
                              url: widget.data == null
                                  ? ''
                                  : widget.data[index]['resource_url']),
                        ),
                      ),
                    );
                  },
                  itemCount: widget.data == null ? 1 : widget.data.length,
                ),
              );
            }),
          );
  }
}
