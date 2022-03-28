import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/mixin/cardMixin.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/index.dart';

// ignore: must_be_immutable
class Vcard extends StatefulWidget {
  Vcard(
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
      this.replace = false,
      this.isSearch = false,
      this.isLocal = false,
      this.isSubtitle = false,
      this.maxLines = 1,
      this.onTap})
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
  final bool replace;
  final bool isSearch;
  final bool isLocal;
  final bool isSubtitle;
  final int maxLines;
  final Function onTap;
  @override
  _VcardState createState() => _VcardState();
}

class _VcardState extends State<Vcard> with CardMixin<Vcard> {
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
      if (widget.cardData["sets"].length > widget.cardData["progress"]) {
        currentImg =
            widget.cardData["sets"][widget.cardData["progress"]].length;
        imgTotal = widget.cardData["sets"][widget.cardData["progress"]].length;
      }
      setState(() {});
    }
    if (widget.isLocal) {
      EventBus().on('DOWNLOADCOMICS_PROGRESS_${widget.cardData["id"]}', (arg) {
        // print(arg);
        if (widget.cardData["id"] == arg["id"]) {
          setState(() {
            progress = arg["progress"] ?? progress;
            downloading = arg["downloading"] ?? true;
            downloadError = arg["downloadError"] ?? false;
            currentImg = arg["currentImg"] ?? currentImg;
            imgTotal = arg["imgTotal"] ?? imgTotal;
            isWaiting = false;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(Vcard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLocal) {
      if (widget.cardData["id"] != oldWidget.cardData["id"]) {
        progress = widget.cardData["progress"];
        downloading = widget.cardData["downloading"];
        isWaiting = widget.cardData["isWaiting"];
        downloadError = false;
        if (widget.cardData["sets"].length > widget.cardData["progress"]) {
          currentImg =
              widget.cardData["sets"][widget.cardData["progress"]].length;
          imgTotal =
              widget.cardData["sets"][widget.cardData["progress"]].length;
        }
        setState(() {});
      }
    }
  }

  String getDownloadText() {
    return "${progress < widget.cardData["sets"].length ? progress + 1 : progress}章:${currentImg}/${imgTotal}";
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.isLocal) {
      EventBus().off('DOWNLOADCOMICS_PROGRESS_${widget.cardData["id"]}');
    }
  }

  @override
  Widget build(BuildContext context) {
    double thumbHeight = (widget.width / 140) * 194;
    String desc = getCardDesc(widget);
    return callDetail(
        cardData: widget.cardData,
        widget: widget,
        smallVideoData: widget.isSearch ? widget.cardData : null,
        replace: widget.replace,
        isLocal: widget.isLocal,
        progress: (progress / (widget.cardData["allEpisode"] ?? 1)),
        onTap: widget.onTap,
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
                      child: PlatformAwareNetworkImage(
                        width: widget.width,
                        height: thumbHeight,
                        fit: BoxFit.cover,
                        url: widget.thumbUrl,
                      )),
                  renderTagIcon(widget),
                  widget.isLocal && progress != widget.cardData["allEpisode"]
                      ? Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(ScreenUtil().setWidth(5))),
                                color: Color.fromRGBO(0, 0, 0, 0.4)),
                          ))
                      : Container(),
                  widget.isLocal && progress != widget.cardData["allEpisode"]
                      ? Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          left: 0,
                          child: downloading
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "正在下载:",
                                      style: TextStyle(
                                          color: progress == -1
                                              ? Colors.red
                                              : Colors.white,
                                          decoration: TextDecoration.none,
                                          fontSize: ScreenUtil().setSp(16)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: ScreenUtil().setWidth(6)),
                                      child: Text(
                                        getDownloadText(),
                                        style: TextStyle(
                                            color: progress == -1
                                                ? Colors.red
                                                : Colors.white,
                                            decoration: TextDecoration.none,
                                            fontSize: ScreenUtil().setSp(16)),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Text(
                                    downloadError
                                        ? "下载失败，点击重试"
                                        : isWaiting
                                            ? "等待下载..."
                                            : progress == 0
                                                ? "点击开始下载"
                                                : "暂停下载",
                                    style: TextStyle(
                                        color: progress == -1
                                            ? Colors.red
                                            : Colors.white,
                                        decoration: TextDecoration.none,
                                        fontSize: ScreenUtil().setSp(16)),
                                    textAlign: TextAlign.center,
                                  ),
                                ))
                      : Container()
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
                                    : widget.cardData['title' ?? ''],
                                maxLines: widget.maxLines,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
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
