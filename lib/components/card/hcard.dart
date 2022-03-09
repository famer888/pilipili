import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/mixin/cardMixin.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

// ignore: must_be_immutable
class Hcard extends StatefulWidget {
  Hcard(
      {Key key,
      this.width,
      this.thumbUrl,
      this.cardMargin,
      this.tagIconType, // 0不显示 1免费 2VIP 3GOLD 4AD
      this.cardData,
      this.showField = '',
      this.contentType,
      this.id,
      this.page,
      this.height,
      this.isNovel = false,
      this.replace = false,
      this.isSearch = false,
      this.isLocal = false,
      this.isSubtitle = false})
      : super(key: key);
  final double width;
  final double height;
  final String thumbUrl;
  final EdgeInsets cardMargin;
  final int tagIconType;
  final dynamic cardData;
  final String showField;
  final int contentType;
  final dynamic id;
  final int page;
  final bool isNovel;
  final bool replace;
  final bool isSearch;
  final bool isLocal;
  final bool isSubtitle;
  @override
  _HcardState createState() => _HcardState();
}

class _HcardState extends State<Hcard> with CardMixin<Hcard> {
  // String thumb = CommonUtils.getRandomThumb();
  int progress = 0;
  int currentImg = 1;
  int imgTotal = 0;
  bool downloading = false;
  bool downloadError = false;
  bool isWaiting = false;
  @override
  void initState() {
    super.initState();
    if (widget.cardData["progress"] != null) {
      downloading = widget.cardData["downloading"];
      isWaiting = widget.cardData["isWaiting"];
      progress = widget.cardData["progress"];
      if (!widget.isNovel) {
        if (widget.cardData["sets"].length > widget.cardData["progress"]) {
          currentImg =
              widget.cardData["sets"][widget.cardData["progress"]].length;
          imgTotal =
              widget.cardData["sets"][widget.cardData["progress"]].length;
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double thumbHeight = widget.width / 167 * 100;
    String desc = getCardDesc(widget);
    return callDetail(
        cardData: widget.cardData,
        widget: widget,
        smallVideoData: widget.isSearch ? widget.cardData : null,
        replace: widget.replace,
        progress: widget.isNovel
            ? (progress / (widget.cardData["serieses"]?.length ?? 1))
            : (progress / (widget.cardData["allEpisode"] ?? 1)),
        setDownloading: () {
          setState(() {
            isWaiting = true;
          });
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.cardMargin ?? EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          // color: Colors.grey,
                          borderRadius: BorderRadius.all(
                              Radius.circular(ScreenUtil().setWidth(5)))),
                      height: thumbHeight,
                      child: widget.isNovel
                          ? PlatformAwareAssetImage(
                              url: CommonUtils.getThumb(widget.cardData),
                              width: widget.width,
                              height: thumbHeight,
                              fit: BoxFit.cover,
                            )
                          : PlatformAwareNetworkImage(
                              width: widget.width,
                              height: thumbHeight,
                              fit: BoxFit.cover,
                              url: widget.thumbUrl,
                            )),
                  renderTagIcon(widget),
                ],
              ),
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(3)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.showField.indexOf('title') != -1
                            ? Text(
                                widget.isSubtitle
                                    ? (widget.cardData['second_title'] ??
                                        widget.cardData['title'] ??
                                        '')
                                    : widget.cardData['title' ?? ""],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Color(0xff646464),
                                    fontSize: ScreenUtil().setSp(14)),
                              )
                            : Container(),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        contentType: widget.contentType);
  }
}
