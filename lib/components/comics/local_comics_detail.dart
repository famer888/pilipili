import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:provider/provider.dart';

import '../../utils/privilege.dart';

class LocalComicsDetatl extends StatefulWidget {
  LocalComicsDetatl({Key key, this.comicsInfo}) : super(key: key);
  final Map comicsInfo;

  @override
  _LocalComicsDetatlState createState() => _LocalComicsDetatlState();
}

class _LocalComicsDetatlState extends State<LocalComicsDetatl> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Widget selectItem(int value, int length) {
    String text = '';
    bool more;
    if (length >= 8 && value == 5) {
      text = '...';
      more = true;
    } else {
      text = value.toString();
      more = false;
    }
    return GestureDetector(
      onTap: () {
        if (!more) {
          context.push(CommonUtils.getRealHash('localComicsReader'),
              extra: {'comicsInfo': widget.comicsInfo, 'episode': value});
        } else {
          _scaffoldKey.currentState.openEndDrawer();
        }
      },
      child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/pengke/video/${value <= 4 ? 'comics_btn' : 'comics_btn_un'}.png',
                fit: BoxFit.fill,
              )),
          Container(
            width: ScreenUtil().setWidth(84),
            height: ScreenUtil().setWidth(34),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                    color: Color(value <= 4 ? 0xffd7d7d7 : 0xff6a6a6a),
                    fontSize: ScreenUtil().setSp(16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _btnItem({String icon, String name, Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/pengke/video/$icon.png',
          width: ScreenUtil().setWidth(25),
          fit: BoxFit.fitWidth,
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

  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  @override
  Widget build(BuildContext context) {
    List tags = widget.comicsInfo["tags"]?.split(',');
    tags = tags.length > 3 ? tags.getRange(0, 2).toList() : tags;
    List allList = List.filled(widget.comicsInfo["allEpisode"], 1);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xfff7f6fb),
      endDrawer: comicDrawer(),
      body: Stack(
        children: [
          Stack(
            children: [
              Opacity(
                opacity: 0.7,
                child: PlatformAwareNetworkImage(
                  url: widget.comicsInfo["thumb"],
                  fit: BoxFit.cover,
                ),
              ),
              ClipRect(
                //背景过滤器
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: ScreenUtil().setWidth(215),
            color: Color(0xffffa500),
            child: PlatformAwareNetworkImage(
                url: widget.comicsInfo["thumb"], fit: BoxFit.fill),
          ),
          Positioned(
            child: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: ScreenUtil().setWidth(50.5) +
                          (kIsWeb ? 0 : ScreenUtil().bottomBarHeight)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setWidth(94),
                            left: ScreenUtil().setWidth(14.5),
                            right: ScreenUtil().setWidth(10.5)),
                        child: Stack(
                          children: [
                            Positioned(
                                top: 0,
                                left: 0,
                                bottom: 0,
                                right: 0,
                                child: Image.asset(
                                  'assets/pengke/video/comics_card_bg.png',
                                  fit: BoxFit.fill,
                                )),
                            Container(
                              padding:
                                  EdgeInsets.all(ScreenUtil().setWidth(13.5)),
                              height: ScreenUtil().setWidth(185.5),
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        right: ScreenUtil().setWidth(15)),
                                    height: ScreenUtil().setWidth(155.5),
                                    width: ScreenUtil().setWidth(110),
                                    child: PlatformAwareNetworkImage(
                                        url: widget.comicsInfo["thumb"]),
                                  ),
                                  Expanded(
                                      child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          widget.comicsInfo["title"],
                                          style: DefaultStyle.white18bold,
                                        ),
                                        Text(
                                          '作者：${widget.comicsInfo["author"] == null || widget.comicsInfo["author"] == "" ? "--" : widget.comicsInfo["author"]}',
                                          style: TextStyle(
                                            color: Color(0xff62f7ff),
                                            fontSize: ScreenUtil().setSp(12),
                                          ),
                                        ),
                                        Text(
                                          '${CommonUtils.renderFixedNumber(double.parse(widget.comicsInfo["viewsCount"].toString()))}次观看',
                                          style: DefaultStyle.lgray13,
                                        ),
                                        Container(
                                          child: Row(
                                              children: tags
                                                  .asMap()
                                                  .keys
                                                  .map((e) => e <= 1
                                                      ? Padding(
                                                          padding: EdgeInsets.only(
                                                              right:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          8.5)),
                                                          child: Text(
                                                            '#${tags[e]}',
                                                            style: DefaultStyle
                                                                .white10,
                                                          ),
                                                        )
                                                      : Container())
                                                  .toList()),
                                        ),
                                        widget.comicsInfo['description'] ==
                                                    null ||
                                                widget.comicsInfo[
                                                        'description'] ==
                                                    ''
                                            ? Container()
                                            : Text(
                                                widget
                                                    .comicsInfo['description'],
                                                style: TextStyle(
                                                    height: 1.7,
                                                    fontSize:
                                                        ScreenUtil().setSp(12),
                                                    color: Color(0xff666666)),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: DefaultStyle.pagePadding,
                            vertical: ScreenUtil().setWidth(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(),
                            GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState.openEndDrawer();
                              },
                              behavior: HitTestBehavior.translucent,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '全部',
                                    style: DefaultStyle.gray12,
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setWidth(8.5),
                                  ),
                                  Image.asset(
                                    'assets/pengke/icon_more.png',
                                    width: ScreenUtil().setWidth(12),
                                    height: ScreenUtil().setWidth(12),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: DefaultStyle.pagePadding,
                            vertical: ScreenUtil().setWidth(16)),
                        child: Wrap(
                          spacing: ScreenUtil().setWidth(3),
                          runSpacing: ScreenUtil().setWidth(4),
                          children: allList
                              .asMap()
                              .keys
                              .map((e) => selectItem(
                                  e + 1, widget.comicsInfo["allEpisode"]))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          Positioned(
              child: SafeArea(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: DefaultStyle.pagePadding),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, ScreenUtil().setWidth(1)),
                            blurRadius: ScreenUtil().setWidth(5))
                      ],
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white70),
                  width: ScreenUtil().setWidth(30),
                  height: ScreenUtil().setWidth(30),
                  child: Center(
                    child: Image.asset(
                      'assets/pengke/backarrow.png',
                      width: ScreenUtil().setWidth(20),
                      height: ScreenUtil().setWidth(20),
                    ),
                  ),
                ),
              ),
            ],
          ))),
          Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: 0,
                    top: 0,
                    child: ClipRect(
                      //背景过滤器
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    child: Image.asset(
                      'assets/pengke/video/fot_bg.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: DefaultStyle.pagePadding,
                        bottom: kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                    height: ScreenUtil().setWidth(50.5) +
                        (kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        GestureDetector(
                          onTap: () {
                            swichComic(1);
                          },
                          child: Stack(
                            children: [
                              Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Image.asset(
                                    'assets/pengke/video/video_duan_btn.png',
                                    fit: BoxFit.fill,
                                  )),
                              Container(
                                height: ScreenUtil().setWidth(34),
                                width: ScreenUtil().setWidth(128),
                                child: Center(
                                  child: Text(
                                    '开始阅读',
                                    style: DefaultStyle.zhuti15,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(12),
                        )
                      ],
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }

  swichComic(int episode) {
    context.push(CommonUtils.getRealHash('localComicsReader'),
        extra: {'comicsInfo': widget.comicsInfo, 'episode': episode});
  }

  //阅读器目录
  Widget comicDrawer() {
    List allList = List.filled(widget.comicsInfo["allEpisode"], 1);
    return Container(
      height: ScreenUtil().screenHeight,
      width: ScreenUtil().setWidth(286.5),
      color: Color(0xff161423),
      child: Column(
        children: [
          SizedBox(
            height: ScreenUtil().statusBarHeight,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(19),
                horizontal: ScreenUtil().setWidth(14)),
            child: Row(
              children: [
                Text('共${widget.comicsInfo["allEpisode"]}话',
                    style: TextStyle(
                        color: Color(0xff999999),
                        fontSize: ScreenUtil().setSp(13))),
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
            child: Wrap(
              spacing: ScreenUtil().setWidth(2.5),
              runSpacing: ScreenUtil().setWidth(4),
              children: allList.asMap().keys.map((e) {
                return GestureDetector(
                  onTap: () {
                    context.pop();
                    swichComic(e + 1);
                  },
                  child: Stack(
                    children: [
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Image.asset(
                            'assets/pengke/video/comics_btn.png',
                            fit: BoxFit.fill,
                          )),
                      Container(
                        width: ScreenUtil().setWidth(84.5),
                        height: ScreenUtil().setWidth(32),
                        child: Center(
                            child: Text(
                          (e + 1).toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(15)),
                        )),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ))
        ],
      ),
    );
  }
}
