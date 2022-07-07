import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class AtilasList extends StatefulWidget {
  AtilasList({Key key, this.pramas}) : super(key: key);
  final Map pramas;

  @override
  _AtilasListState createState() => _AtilasListState();
}

class _AtilasListState extends State<AtilasList> {
  int currentIndex = 0;
  PageController _controller;
  List<GlobalKey> keyList = [];
  List<TransformationController> transformationControllerList = [];

  bool _scroolEnabled = true;

  @override
  void initState() {
    super.initState();
    widget.pramas['resources'].forEach((item) {
      GlobalKey _key = GlobalKey();
      TransformationController transformationController =
          TransformationController();
      transformationControllerList.add(transformationController);
      keyList.add(_key);
    });
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    }
    _controller = PageController(initialPage: widget.pramas['index']);
    currentIndex = widget.pramas['index'];
    setState(() {});
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    super.dispose();
  }

  Widget _head() {
    return Container(
      height: ScreenUtil().setWidth(44),
      width: double.infinity,
      child: Stack(
        children: [
          // Center(
          //   child: Text(
          //     '1/9',
          //     style: DefaultStyle.white18bold,
          //   ),
          // ),
          Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: DefaultStyle.pagePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: PlatformAwareAssetImage(
                          url: 'assets/images/backarrow.png',
                          width: ScreenUtil().setWidth(20),
                          height: ScreenUtil().setWidth(20),
                          filterQuality: FilterQuality.medium),
                    ),
                    Container()
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget comicButtom({String type, Function onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(7.5)),
        width: ScreenUtil().setWidth(45),
        height: ScreenUtil().setWidth(75),
        decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.7),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                    type == 'left' ? ScreenUtil().setWidth(37.5) : 10),
                topRight: Radius.circular(
                    type == 'left' ? 10 : ScreenUtil().setWidth(37.5)),
                bottomLeft: Radius.circular(
                    type == 'left' ? ScreenUtil().setWidth(37.5) : 10),
                bottomRight: Radius.circular(
                    type == 'left' ? 10 : ScreenUtil().setWidth(37.5)))),
        child: Row(
          textDirection: type == 'left' ? TextDirection.ltr : TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PlatformAwareAssetImage(
              url: 'assets/images/comics/' +
                  (type == 'left' ? 'left.png' : 'right.png'),
              width: ScreenUtil().setWidth(12.5),
              height: ScreenUtil().setWidth(16),
              filterQuality: FilterQuality.medium,
              fit: BoxFit.contain,
            ),
            DefaultTextStyle(
                style: TextStyle(
                    color: Colors.white, fontSize: ScreenUtil().setSp(15)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(type == 'left' ? '上' : '下'),
                    Text('一'),
                    Text('张'),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0f011b),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _head(),
          Expanded(
              child: Stack(
            children: [
              PageView(
                  controller: _controller,
                  physics: _scroolEnabled
                      ? PageScrollPhysics()
                      : NeverScrollableScrollPhysics(),
                  allowImplicitScrolling: true,
                  onPageChanged: (e) {
                    currentIndex = e;
                    setState(() {});
                  },
                  children: widget.pramas['resources']
                      .asMap()
                      .keys
                      .map<Widget>((e) => new InteractiveViewer(
                          transformationController:
                              transformationControllerList[e],
                          minScale: 0.3,
                          maxScale: 10,
                          onInteractionStart: (scale) {
                            _scroolEnabled = false;
                            setState(() {});
                          },
                          onInteractionEnd: (scale) {
                            if (transformationControllerList[e]
                                    .value
                                    .getMaxScaleOnAxis() ==
                                1) {
                              _scroolEnabled = true;
                              setState(() {});
                            }
                          },
                          child: PlatformAwareNetworkImage(
                              background: Color(0xff0f011b),
                              key: keyList[e],
                              noVisibilityDetector: true,
                              fit: BoxFit.fitWidth,
                              url: widget.pramas['resources'][e]
                                      ['original_url'] ??
                                  widget.pramas['resources'][e]['url'])))
                      .toList()),
              Positioned(
                  child: Center(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(15)),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      comicButtom(
                          type: 'left',
                          onTap: () {
                            if (currentIndex == 0) {
                              CommonUtils.showText('已经是第一张啦～');
                              return;
                            }
                            transformationControllerList[currentIndex].value =
                                Matrix4.identity()..scale(1.0);
                            _controller.animateToPage(currentIndex - 1,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          }),
                      comicButtom(
                          type: 'right',
                          onTap: () {
                            if (currentIndex ==
                                widget.pramas['resources'].length - 1) {
                              CommonUtils.showText('已经是最后一张啦～');
                              return;
                            }
                            transformationControllerList[currentIndex].value =
                                Matrix4.identity()..scale(1.0);
                            _controller.animateToPage(currentIndex + 1,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          }),
                    ],
                  ),
                ),
              )),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(),
                      child: Stack(children: [
                        Positioned(
                          right: 0,
                          left: 0,
                          bottom: 0,
                          top: 0,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              color: Colors.black38,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: PlatformAwareAssetImage(
                              url: 'assets/pengke/video/fot_bg.png',
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.medium),
                        ),
                        Container(
                          height: ScreenUtil().setWidth(50) +
                              ScreenUtil().bottomBarHeight,
                          width: double.infinity,
                          padding: EdgeInsets.only(
                              bottom: ScreenUtil().bottomBarHeight,
                              left: ScreenUtil().setWidth(18.5),
                              right: ScreenUtil().setWidth(18.5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${currentIndex + 1}/${widget.pramas['resources'].length}',
                                style: DefaultStyle.white18bold,
                              ),
                            ],
                          ),
                        )
                      ])))
            ],
          )),
        ],
      )),
    );
  }
}
