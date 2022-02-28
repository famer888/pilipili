import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youyutv/model/element.dart';
import 'package:youyutv/theme/default.dart';
import 'package:youyutv/utils/index.dart';

class Scrollnav extends StatefulWidget {
  Scrollnav(
      {Key key,
      this.emitName,
      this.navitems,
      this.pages,
      this.onNavIndexChanged,
      this.onBackTop,
      this.hideClose = false})
      : super(key: key);
  final String emitName;
  final List<LinkModel> navitems;
  final List<Widget> pages;
  final Function onNavIndexChanged;
  final Function onBackTop;
  final bool hideClose;
  @override
  _ScrollnavState createState() => _ScrollnavState();
}

class _ScrollnavState extends State<Scrollnav> {
  List<GlobalKey> keys = <GlobalKey>[];
  ScrollController _controller;
  PageController _pageController;
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _pageController = PageController();
    _pageController.addListener(() {
      int index = _pageController.page.round();
      if (selectedIndex != index) {
        selectedIndex = index;
        setState(() {});
        scrollItemToCenter(index);
        if (widget.onNavIndexChanged != null) {
          widget.onNavIndexChanged(index);
        }
      }
    });
    for (int i = 0; i < widget.navitems.length; i++) {
      keys.add(GlobalKey(debugLabel: 'navitems-${i.toString()}'));
    }
    if (widget.emitName != null) {
      EventBus().on(widget.emitName, (arg) {
        _pageController.jumpToPage(arg);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.emitName != null) {
      EventBus().off(widget.emitName);
    }
    _controller.dispose();
    _pageController.dispose();
  }

  void scrollItemToCenter(int pos) {
    RenderBox box = keys[pos].currentContext.findRenderObject();
    Offset os = box.localToGlobal(Offset.zero);
    double w = box.size.width;
    double x = os.dx;
    double windowW = ScreenUtil().screenWidth;
    double rlOffset = windowW / 2 - (x + w / 2);
    double offset = _controller.offset - rlOffset;
    _controller.animateTo(offset,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: (widget.navitems != null && widget.pages != null)
            ? Column(
                children: [
                  Container(
                    alignment: AlignmentDirectional.center,
                    color: Colors.transparent,
                    width: ScreenUtil().screenWidth,
                    height: DefaultStyle.navbarHegiht,
                    padding: EdgeInsets.symmetric(
                        horizontal: DefaultStyle.pagePadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: ListView(
                          cacheExtent: ScreenUtil().screenHeight * 5,
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          controller: _controller,
                          children: widget.navitems
                              .asMap()
                              .keys
                              .map<Widget>((index) => GestureDetector(
                                    onTap: () {
                                      if (selectedIndex == index) {
                                        widget.onBackTop(index);
                                      }
                                      _pageController.animateToPage(index,
                                          duration: Duration(milliseconds: 200),
                                          curve: Curves.easeInOut);
                                    },
                                    child: Container(
                                      key: keys[index],
                                      // height: DefaultStyle.navbarHegiht,
                                      padding: EdgeInsets.only(
                                          right: ScreenUtil().setWidth(5)),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Opacity(
                                            opacity:
                                                selectedIndex == index ? 1 : 0,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: ScreenUtil()
                                                      .setWidth(3.5)),
                                              child: Image.asset(
                                                'assets/pengke/nav_icon_left.png',
                                                fit: BoxFit.fitHeight,
                                                height:
                                                    ScreenUtil().setWidth(23.3),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    ScreenUtil().setWidth(3)),
                                            child: Text(
                                              widget.navitems[index].name,
                                              style: selectedIndex == index
                                                  ? DefaultStyle.white20bold
                                                  : DefaultStyle.gray18,
                                            ),
                                          ),
                                          Opacity(
                                              opacity: selectedIndex == index
                                                  ? 1
                                                  : 0,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil()
                                                        .setWidth(3.5)),
                                                child: Image.asset(
                                                  'assets/pengke/nav_icon_right.png',
                                                  fit: BoxFit.fitHeight,
                                                  height: ScreenUtil()
                                                      .setWidth(23.3),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        )),
                        widget.hideClose
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  // 打开搜索
                                  // context.push('/${Routes.search}');
                                  showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(builder:
                                            (context, setBottomSheetState) {
                                          return Stack(
                                            children: [
                                              Positioned(
                                                  child: ClipRRect(
                                                child: Image.asset(
                                                  'assets/pengke/search_bg.png',
                                                  fit: BoxFit.fitWidth,
                                                  width:
                                                      ScreenUtil().screenWidth,
                                                ),
                                              )),
                                            ],
                                          );
                                        });
                                      });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(6)),
                                  child: Image.asset(
                                    'assets/pengke/icon_search.png',
                                    width: ScreenUtil().setWidth(20.5),
                                    height: ScreenUtil().setWidth(20.5),
                                  ),
                                ))
                      ],
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setWidth(6)),
                    child: PageView(
                      controller: _pageController,
                      children: widget.pages,
                    ),
                  ))
                ],
              )
            : Container());
  }
}
