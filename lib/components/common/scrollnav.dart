import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/model/element.dart';
import 'package:pilipili/routers.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/networkImage.dart';

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
    for (int i = 0; i < widget.navitems.length; i++) {
      keys.add(GlobalKey(debugLabel: 'navitems-' + i.toString()));
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
    _controller
        .animateTo(offset,
            duration: Duration(milliseconds: 200), curve: Curves.easeInOut)
        .then((value) {
      if (widget.onNavIndexChanged != null) {
        widget.onNavIndexChanged(pos);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (widget.navitems != null && widget.pages != null)
        ? Stack(
            children: [
              PageView(
                controller: _pageController,
                children: widget.pages,
                onPageChanged: (index) {
                  if (selectedIndex != index) {
                    selectedIndex = index;
                    setState(() {});
                    scrollItemToCenter(index);
                  }
                },
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    color: Color.fromRGBO(130, 26, 70, 0.44),
                    width: ScreenUtil().screenWidth,
                    height: DefaultStyle.navbarHegiht +
                        MediaQuery.of(context).padding.top,
                    padding: EdgeInsets.only(
                        left: DefaultStyle.pagePadding,
                        right: DefaultStyle.pagePadding,
                        top: MediaQuery.of(context).padding.top),
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
                                      _pageController.jumpToPage(index);
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                            top: 0,
                                            bottom: 0,
                                            right: 0,
                                            left: 0,
                                            child: selectedIndex == index
                                                ? Container(
                                                    padding: EdgeInsets.only(
                                                        top: ScreenUtil()
                                                            .setWidth(13)),
                                                    decoration: BoxDecoration(
                                                        gradient: RadialGradient(
                                                            colors: [
                                                          Color.fromRGBO(255, 0,
                                                              107, 0.33),
                                                          Color.fromRGBO(
                                                              255, 0, 122, 0.0)
                                                        ],
                                                            radius: 0.8,
                                                            center: Alignment
                                                                .bottomCenter)),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        PlatformAwareAssetImage(
                                                            url:
                                                                'assets/images/icon_love.png',
                                                            width: ScreenUtil()
                                                                .setWidth(6.5),
                                                            filterQuality:
                                                                FilterQuality
                                                                    .high),
                                                        Container(
                                                          color:
                                                              Color(0xffFFDCE9),
                                                          height: ScreenUtil()
                                                              .setWidth(1),
                                                          width: ScreenUtil()
                                                              .setWidth(37),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container()),
                                        Container(
                                          key: keys[index],
                                          // height: DefaultStyle.navbarHegiht,
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  ScreenUtil().setWidth(13)),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: ScreenUtil()
                                                        .setWidth(3)),
                                                child: Text(
                                                  widget.navitems[index].name ??
                                                      "",
                                                  style: TextStyle(
                                                      color:
                                                          selectedIndex == index
                                                              ? Colors.white
                                                              : Color.fromRGBO(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  0.8),
                                                      fontSize: ScreenUtil()
                                                          .setSp(
                                                              selectedIndex ==
                                                                      index
                                                                  ? 18
                                                                  : 16),
                                                      fontWeight:
                                                          selectedIndex == index
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                              .toList(),
                        )),
                        widget.hideClose
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  // 打开搜索
                                  context.push('/search');
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(6)),
                                  child: PlatformAwareAssetImage(
                                      url: 'assets/images/icon_search.png',
                                      width: ScreenUtil().setWidth(20.5),
                                      height: ScreenUtil().setWidth(20.5),
                                      filterQuality: FilterQuality.medium),
                                ))
                      ],
                    ),
                  ))
            ],
          )
        : Container();
  }
}
