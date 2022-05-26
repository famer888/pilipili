import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/sharemovie.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

class AtlasDetail extends StatefulWidget {
  AtlasDetail({Key key, this.id}) : super(key: key);
  final dynamic id;
  @override
  _AtlasDetailState createState() => _AtlasDetailState();
}

class _AtlasDetailState extends State<AtlasDetail> {
  Map picDetail;
  List picList;
  bool isLike = false;
  int likeNum = 0;
  @override
  void initState() {
    super.initState();
    getPicDetail(id: widget.id).then((res) {
      CommonUtils.debugPrint('------------图集详情----------');
      CommonUtils.debugPrint(res);
      if (res['status'] != 0) {
        picList = res['data']['resources'];
        picDetail = res['data'];
        likeNum = res['data']['favorites'];
        isLike = res['data']['userFavorites'] == 1;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
        context.pop();
      }
    });
  }

  Widget _btnItem({String icon, String name, Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/pengke/video/$icon.png',
          width: ScreenUtil().setWidth(25),
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.medium
        ),
        SizedBox(
          width: ScreenUtil().setWidth(7),
        ),
        Text(
          name,
          style: TextStyle(
              color: color != null ? color : Color(0xffffffff),
              fontSize: ScreenUtil().setSp(14)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List tags = picDetail == null ? [] : picDetail['tags'].split(',');
    List images = picDetail == null
        ? []
        : (picDetail['resources'].length > 9
            ? picDetail['resources'].sublist(0, 9)
            : picDetail['resources']);
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleBar(
            title: '图集详情',
          ),
          Expanded(
              child: picDetail == null
                  ? PageStatus.loading(mounted)
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: DefaultStyle.pagePadding,
                                vertical: ScreenUtil().setWidth(14)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(picDetail['title'],
                                    style: DefaultStyle.white16bold),
                                SizedBox(
                                  height: ScreenUtil().setWidth(12),
                                ),
                                Text(
                                  picDetail['desc'] ?? '--',
                                  style: TextStyle(
                                    color: Color(0xff999999),
                                    fontSize: ScreenUtil().setSp(13),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setSp(16)),
                                  child: Wrap(
                                    spacing: ScreenUtil().setWidth(5.5),
                                    runSpacing: ScreenUtil().setWidth(5.5),
                                    children:
                                        images.asMap().keys.map<Widget>((e) {
                                      return Stack(
                                        children: [
                                          GestureDetector(
                                              onTap: () {
                                                AppGlobal
                                                    .currentReaderRouteExtra = {
                                                  'resources': picList,
                                                  'index': e
                                                };
                                                context.push(
                                                    CommonUtils.getRealHash(
                                                        'atlasList/0'));
                                              },
                                              child: Container(
                                                width: ScreenUtil()
                                                    .setWidth(112.5),
                                                height: ScreenUtil()
                                                    .setWidth(112.5),
                                                child:
                                                    PlatformAwareNetworkImage(
                                                        fit: BoxFit.cover,
                                                        url: images[e]
                                                            ['thumb_url']),
                                              )),
                                          Positioned(
                                              right: 0,
                                              left: 0,
                                              bottom: 0,
                                              top: 0,
                                              child: IgnorePointer(
                                                child: Image.asset(
                                                  'assets/pengke/video/atlas_boder.png',
                                                  fit: BoxFit.fill,
                                                  filterQuality: FilterQuality.medium
                                                ),
                                              ))
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setSp(14)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('点击图片看大图',
                                          style: DefaultStyle.gray14),
                                      Text('共${picDetail['resources'].length}张',
                                          style: DefaultStyle.gray14)
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setWidth(18)),
                                  child: Wrap(
                                    spacing: ScreenUtil().setWidth(5),
                                    runSpacing: ScreenUtil().setWidth(14),
                                    children: tags
                                        .asMap()
                                        .keys
                                        .map((e) => YyTap(text: tags[e]))
                                        .toList(),
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setWidth(16.5),
                                ),
                                Text('${picDetail['views_count']}人观看',
                                    style: DefaultStyle.gray11)
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
          Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/pengke/video/fot_bg.png',
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium
                ),
              ),
              Container(
                height: ScreenUtil().setWidth(50),
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(33.5)),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        userFavorites(type: 6, id: picDetail['id']).then((res) {
                          if (res != null && res.status != 0) {
                            isLike ? likeNum-- : likeNum++;
                            isLike = !isLike;
                            setState(() {});
                          } else {
                            CommonUtils.showText(res.msg);
                          }
                        });
                      },
                      child: _btnItem(
                          icon: isLike ? 'icon_like' : 'icon_unlike',
                          name: likeNum.toString(),
                          color:
                              isLike ? Color(0xff37f4ff) : Color(0xff999999)),
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(25),
                    ),
                    GestureDetector(
                      onTap: () {
                        var config =
                            Provider.of<HomeConfig>(context, listen: false)
                                .config;
                        ShareMovieModel.showShareMovie(BackButtonBehavior.none,
                            copyUrl: config.share.affUrlCopy.url,
                            thumb: picDetail['thumb'],
                            title: picDetail['title'] ?? '--',
                            subtitle: picDetail['desc'] ?? '--',
                            url: '${config.share.affUrl}');
                      },
                      child: _btnItem(icon: 'icon_share', name: '分享'),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      )),
    );
  }
}

class YyTap extends StatefulWidget {
  YyTap({Key key, this.text}) : super(key: key);
  String text;
  @override
  _YyTapState createState() => _YyTapState();
}

class _YyTapState extends State<YyTap> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8.5)),
          height: ScreenUtil().setWidth(20),
          decoration: BoxDecoration(
              border: Border.all(
                  width: ScreenUtil().setWidth(0.5), color: Color(0xff777676)),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(5))),
          child: Center(
            child: Text(
              '#${widget.text}',
              style: DefaultStyle.white11,
            ),
          ),
        )
      ],
    );
  }
}
