import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_string.dart';
import 'package:pilipili/utils/privilege.dart';
import 'package:pilipili/utils/download_video.dart';
import 'package:pilipili/utils/download_comics.dart';
import 'package:provider/provider.dart';

import '../components/yy_dialog.dart';

mixin CardMixin<T extends StatefulWidget> on State<T> {
  // String thumb = CommonUtils.getRandomThumb();
  @override
  void initState() {
    super.initState();
  }

  String getCardDesc(widget) {
    String result = '';
    // if (widget.showField.indexOf('second_title') != -1) {
    //   result += widget.cardData['second_title'];
    // }
    if (widget.showField.indexOf('tags') != -1) {
      if (result != '' && result != null) result += '/';
      result += widget.cardData['tags'].replaceAll(',', ' ');
    }
    return result;
  }

  String getRouter(int contentType, {String id, bool replace}) {
    CommonUtils.debugPrint(
        '----------------------------------当前ContentType--$contentType');
    String router;
    switch (contentType) {
      case 1: //视频
        router = replace
            ? CommonUtils.getRealHash()
                .replaceAll(RegExp(r"videoDetail/.*"), 'videoDetail/$id')
            : CommonUtils.getRealHash('videoDetail/$id');
        break;
      case 2: //漫画
        router = replace
            ? CommonUtils.getRealHash()
                .replaceAll(RegExp(r"comicsdetail/.*"), 'comicsdetail/$id')
            : CommonUtils.getRealHash('comicsdetail/$id');
        break;
      case 3: //小说
        router = replace
            ? CommonUtils.getRealHash()
                .replaceAll(RegExp(r"novelDetail/.*"), 'novelDetail/$id')
            : CommonUtils.getRealHash('novelDetail/$id');
        break;
      case 4: //链接

        break;
      case 5: //有声小说
        router = CommonUtils.getRealHash('audiobookDetail/0');
        break;
      case 6: //图集
        router = replace
            ? CommonUtils.getRealHash()
                .replaceAll(RegExp(r"atlasDetail/.*"), 'atlasDetail/$id')
            : CommonUtils.getRealHash('atlasDetail/$id');
        break;
      case 7: //短视频
        router = CommonUtils.getRealHash(
            kIsWeb ? 'webSmallVideo/0' : 'smallVideo/0');
        break;
      case 10: //动漫
        router = replace
            ? CommonUtils.getRealHash()
                .replaceAll(RegExp(r"videoDetail/.*"), 'videoDetail/$id')
            : CommonUtils.getRealHash('videoDetail/$id');
        break;
      default:
    }
    return router;
  }

  Map privilegeMap = {
    // 1: {'privilege': RESOURCE_TYPE_LONG_VIDEO, 'text': '您没有开启视频权限哦！升级权益后别忘记祖传手艺呢~'},
    2: {'privilege': RESOURCE_TYPE_BOOK, 'text': '您没有开启漫画权限哦！二次元的天堂等您开启~'},
    3: {'privilege': RESOURCE_TYPE_STORY, 'text': '您没有开启小说权限呢！天马行空的色情想法就在眼前~'},
    6: {'privilege': RESOURCE_TYPE_PIC, 'text': '你没有开启色图权限呢！写真套图他人妻通通保存到手机~'},
    // 7: {'privilege': RESOURCE_TYPE_SHORT_VIDEO, 'text': '你没有开启短视频权限呢！该死，为什么我的手停不下来了~'},
  };

  Widget callDetail(
      {Widget child,
      int contentType,
      dynamic cardData,
      dynamic widget,
      dynamic smallVideoData,
      bool replace = false,
      bool isLocal = false,
      double progress = 0,
      bool downloading = false,
      bool isWaiting = false,
      Function setDownloading,
      Function onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (onTap != null) {
          onTap();
        }
        if (privilegeMap[contentType] != null) {
          bool _isAllowed = Privilege.isAllowed(context,
              privilegeMap[contentType]['privilege'], PRIVILEGE_TYPE_VIEW);
          if (!_isAllowed) {
            YyShowDialog.showdialog(
              context,
              content: (setDialogState) {
                return Text(
                  privilegeMap[contentType]['text'],
                  style: TextStyle(
                      color: Color(0xffff84a9),
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(16),
                      decoration: TextDecoration.none),
                );
              },
              cancelText: '取消',
              btnText: PPString.upgradeNuw,
              callBack: () {
                context.push('/${Routes.vip}');
              },
            );
            return;
          }
        }
        if (isLocal) {
          if (progress.toInt() == 1) {
            // 跳详情
            if (contentType == 1 || contentType == 7) {
              // 视频
              context.push(
                  contentType == 1
                      ? CommonUtils.getRealHash('localVideoDetail/0')
                      : CommonUtils.getRealHash('localSmallVideoDetail/0'),
                  extra: {'videoInfo': cardData});
            } else if (contentType == 2) {
              // 漫画
              context.push(CommonUtils.getRealHash('localComicsDetatl'),
                  extra: {'comicsInfo': cardData});
            }
          } else if (!downloading && !isWaiting) {
            setDownloading();
            if (contentType == 1 || contentType == 7) {
              DownloadUtil.createDownloadTask(cardData);
            } else if (contentType == 2) {
              DownloadComics.createDownloadTask(cardData);
            }
          }
        } else if (contentType != 4) {
          var id = cardData['related_id'] == null
              ? cardData['id']
              : cardData['related_id'];
          AppGlobal.currentDetailRouteExtra = {
            'videoData': smallVideoData,
            'id': id,
            'elementId': cardData['element_id'],
            'page': widget.page == null || widget.page == 0 ? 1 : widget.page
          };
          if (replace) {
            context.push(
                getRouter(contentType, id: id.toString(), replace: replace),
                replace: replace);
          } else {
            context.push(
                getRouter(contentType, id: id.toString(), replace: replace));
          }
        } else {
          AppGlobal.currenClickData = cardData;
          if (cardData['link_url'].indexOf('/') == -1) return;
          if (cardData['redirect_type'] == 1) {
            String linkUrl = cardData['link_url'];
            List urlList = linkUrl.split('?');
            Map<String, dynamic> pramas = {};
            if (urlList.length > 1) {
              urlList[1].split("&").forEach((item) {
                List stringText = item.split('=');
                pramas[stringText[0]] =
                    stringText.length > 1 ? stringText[1] : null;
              });
            }
            Map<String, dynamic> pramasObj = {};
            if (pramas['pramaskey'] != null) {
              pramasObj[pramas['pramaskey']] = pramas;
            } else {
              pramasObj = pramas;
            }
            context.push(urlList[0], extra: pramasObj);
          } else if (cardData['redirect_type'] == 2) {
            CommonUtils.launchURL(cardData['link_url']);
          } else if (cardData['redirect_type'] == 3) {
            String linkUrl = cardData['link_url'];
            List urlList = linkUrl.split('?');
            if (urlList.length > 1) {
              if (urlList[0] == 'video') {
                int _cindex = AppGlobal.navList
                    .indexWhere((item) => item.name == urlList[1]);
                //跳转结构
                try {
                  EventBus().emit('video_nav', _cindex == null ? 0 : _cindex);
                } catch (e) {}
                return;
              }
            }
          } else if (cardData['redirect_type'] == 4) {
            String linkUrl = cardData['link_url'];
            var members =
                Provider.of<HomeConfig>(context, listen: false).member;
            var aff = members.aff;
            var piliid = members.uuid;
            CommonUtils.launchURL(linkUrl.trim()+'?aff=$aff&piliid=$piliid');
          }
        }
      },
      child: child,
    );
  }

  Widget renderStackThumbArea(widget, thumbWidth, thumbHeight,
      {double progress = 0,
      bool downloading = false,
      bool downloadError = false,
      bool isWaiting = false,
      bool isLocal = false,
      bool isColor = false,
      marginBottom = 6.5}) {
    String getDownloadText() {
      String _text = downloadError
          ? "下载失败，点击尝试"
          : isWaiting
              ? "等待下载..."
              : progress == 0
                  ? "点击开始下载"
                  : downloading
                      ? "下载进度:" + (progress * 100).toInt().toString() + "%"
                      : PPString.pauseDownloads;
      return _text;
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
            width: thumbWidth,
            height: thumbHeight,
            // margin:
            //     EdgeInsets.only(bottom: ScreenUtil().setWidth(marginBottom)),
            child: widget.isNovel
                ? PlatformAwareAssetImage(
                    url: widget.thumbUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : (widget.previewUrl != null &&
                        widget.previewUrl.indexOf('http') != -1
                    ? Container()
                    : PlatformAwareNetworkImage(
                        width: thumbWidth,
                        height: thumbHeight,
                        fit: BoxFit.cover,
                        url: widget.thumbUrl,
                      ))),
        renderTagIcon(widget),
        isLocal && progress.toInt() != 1
            ? Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                  ),
                  child: Center(
                    child: Text(
                      getDownloadText(),
                      style: TextStyle(
                          color: progress == -1 ? Colors.red : Colors.white,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil().setSp(18)),
                    ),
                  ),
                ))
            : Container(),
        isLocal && progress.toInt() != 1
            ? Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                left: 0,
                child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        borderRadius: marginBottom != 0
                            ? BorderRadius.all(
                                Radius.circular(ScreenUtil().setWidth(5)))
                            : BorderRadius.vertical(
                                bottom: Radius.zero,
                                top:
                                    Radius.circular(ScreenUtil().setWidth(5)))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: ScreenUtil().setWidth(2),
                          width: thumbWidth * progress,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 35, 126, 1),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(ScreenUtil().setWidth(1)))),
                        ),
                      ],
                    )),
              )
            : Container(),
      ],
    );
  }

  Widget renderTagIcon(widget) {
    String _asset;
    if (widget.tagIconType == 0) {
      _asset = 'assets/images/icon_free.png';
    } else if (widget.tagIconType == 1) {
      _asset = null; // 'assets/images/icon_vip.png';
    } else if (widget.tagIconType == 2) {
      _asset = 'assets/images/icon_hot.png';
    } else if (widget.tagIconType == 3) {
      _asset = 'assets/images/icon_ad.png';
    }
    return widget.tagIconType != null && _asset != null
        ? Positioned(
            top: 0,
            right: 0,
            child: PlatformAwareAssetImage(
                url: _asset,
                alignment: Alignment.topRight,
                width: ScreenUtil().setWidth(34),
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.medium,
                height: ScreenUtil().setWidth(24)))
        : Container();
  }
}
