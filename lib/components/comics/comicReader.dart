import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/comics/comicsImg.dart';
import 'package:pilipili/components/gestureZoomBox.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/scrollablePositionedList/item_positions_listener.dart';
import 'package:pilipili/components/scrollablePositionedList/scrollable_positioned_list.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/mixin/watchRecordMixin.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';

class ComicReader extends StatefulWidget {
  final int id;
  final int episode;
  final int type;
  final int allEpisode;
  final dynamic title;
  ComicReader(
      {Key key, this.id, this.episode, this.allEpisode, this.title, this.type})
      : super(key: key);

  @override
  _ComicReaderState createState() => _ComicReaderState();
}

class _ComicReaderState extends State<ComicReader> with WatchRecordMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ItemScrollController comicScroll = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  bool isHorizontal = false; //是否横向滑动
  int selectState = 1; //底部翻页控制器选择
  bool isAutomatic = false; //是否开启自动翻页
  int cureentIndex; //当前 X 话
  bool showPrompt = false; //展示提示
  bool isShow = true; //控制器的隐藏显示
  bool isTap = false; //正在控制器上操作
  double topOffset = 0; //垂直方向滑动记录
  double leftOffset = 0; //横向方向滑动记录
  int comicLength = 1; //漫画length
  bool automatic = false;
  int animationTime = 500;
  bool intPage = true;
  Axis scrollDirection = Axis.vertical;
  Map controllerOffset;
  List timeList = [
    1,
    1.5,
    2,
    2.5,
    3,
    3.5,
    4,
    4.5,
    5,
    5.5,
    6,
    6.5,
    7,
    7.5,
    8,
    8.5,
    9,
    9.5,
    10
  ];
  List comicsData;
  int defaultTime = 8;
  Timer _timer;
  int currenPage = 0;
  bool loading = true;
  double leftDx;
  double leftDxb;
  GlobalKey _key = GlobalKey();
  GlobalKey _keyb = GlobalKey();
  int randomIndex;
  _getRenderBox(_) {
    //获取`RenderBox`对象
    RenderBox renderBox = _key.currentContext.findRenderObject();
    Offset offset = renderBox.localToGlobal(Offset(0, 0));
    leftDx = offset.dx;
    RenderBox renderBoxb = _keyb.currentContext.findRenderObject();
    Offset offsetb = renderBoxb.localToGlobal(Offset(0, 0));
    leftDxb = offsetb.dx;
    var manhuaData = AppGlobal.manhuaWatchRecordBox.get(widget.id);
    if (manhuaData != null && manhuaData[widget.episode] != null) {
      currenPage = manhuaData[widget.episode];
      setState(() {});
      comicScroll.jumpTo(index: manhuaData[widget.episode] + 1);
    }
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  //   if (AppGlobal.vipLevel < 2) {
  //     context.pop();
  //     YyShowDialog.showdialog(
  //       context,
  //       title: '提示',
  //       content: (setDialogState) {
  //         return Text(
  //           '开通月卡会员即畅读所有漫画哟～',
  //           style: TextStyle(
  //               color: Color.fromRGBO(51, 51, 51, 1),
  //               fontSize: ScreenUtil().setSp(15),
  //               decoration: TextDecoration.none),
  //         );
  //       },
  //       cancelText: '取消',
  //       btnText: '立即开通',
  //       callBack: () {
  //         // context.push('/${Routes.vip}');
  //       },
  //     );
  //   }
  // }

  @override
  void initState() {
    super.initState();
    cureentIndex = widget.episode;
    List allList = List.filled(widget.allEpisode, 1);
    int index = 1;
    allList.forEach((item) {
      episodeList.add(index);
      index++;
    });
    getPageDetail();
  }

  swichComic(int episode, {bool replace = false}) {
    AppGlobal.currentReaderRouteExtra = {
      'title': widget.title,
      'id': widget.id,
      'allEpisode': widget.allEpisode,
      'type': widget.type,
      'episode': episode
    };
    context.push(
        CommonUtils.getRealHash()
            .replaceAll(RegExp(r"comicReader/.*"), 'comicReader/$episode'),
        replace: replace);
  }

  getPageDetail() async {
    var res = await getComicReading(id: widget.id, episode: widget.episode);
    // List stringList = res.data.toList().map((e) => e.toJson()).toList();
    // LogUtil.d("漫画单页-----${stringList}");
    if (res.status != 0) {
      watchRcordTimer = Timer.periodic(new Duration(seconds: 2), (timer) {
        startWatchRecordTimer(AppGlobal.manhuaWatchRecordBox, widget.id,
            chapterId: widget.episode,
            offset: currenPage,
            thumb: AppGlobal.comicThumb,
            title: widget.title);
      });
      comicsData = res.data;
      comicLength = res.data.length;
      controllerOffset = {
        'offsetLeft': 0.0, //页面进度
        'pageIndex': {'min': 1, 'max': res.data.length},
        'timeLeft': 0.0, //翻页间隔
        'timeIndex': {'min': 0, 'max': timeList.length}
      };
      loading = false;
      var segmet =
          ScreenUtil().setWidth(590) / controllerOffset['pageIndex']['max'];
      controllerOffset['offsetLeft'] = (currenPage + 1) * segmet;
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback(_getRenderBox);
    } else {
      CommonUtils.showText(res.msg);
      context.pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('GETOFFSET');
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
  }

  List episodeList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: loading
          ? PageStatus.loading(mounted)
          : Container(
              height: ScreenUtil().screenHeight,
              width: ScreenUtil().screenWidth,
              child: Stack(
                overflow: Overflow.clip,
                children: [
                  Column(
                    children: [
                      // SizedBox(
                      //   height: ScreenUtil().statusBarHeight,
                      // ),
                      Expanded(
                          child: GestureZoomBox(
                        maxScale: 5.0,
                        isHorizontal: isHorizontal,
                        doubleTapScale: 2.0,
                        duration: Duration(milliseconds: 200),
                        onPressed: () {
                          isShow = !isShow;
                          setState(() {});
                        },
                        child: comicsPageView(),
                      ))
                    ],
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: operatiogArea()),
                  pageController()
                ],
              ),
            ),
      endDrawer: comicDrawer(),
    );
  }

  nextPage() {
    var segmet =
        ScreenUtil().setWidth(295) / controllerOffset['pageIndex']['max'];
    // if (isShow) {
    //   isShow = false;
    // }
    if (currenPage < comicLength - 1) {
      currenPage++;
      controllerOffset['offsetLeft'] = (currenPage + 1) * segmet;
      comicScroll.jumpTo(index: currenPage);
    }
    setState(() {});
  }

  prevPage() {
    var segmet =
        ScreenUtil().setWidth(295) / controllerOffset['pageIndex']['max'];
    // if (isShow) {
    //   isShow = false;
    // }
    if (currenPage >= 1) {
      currenPage--;
      controllerOffset['offsetLeft'] = (currenPage + 1) * segmet;
      CommonUtils.debugPrint(currenPage);
      comicScroll.jumpTo(index: currenPage);
    }
    setState(() {});
  }

  // 手势操作部分
  Widget operatiogArea() {
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            !showPrompt
                ? Container()
                : GestureDetector(
                    onTap: () {
                      isShow = true;
                      showPrompt = false;
                      setState(() {});
                    },
                    child: Container(
                      height: ScreenUtil().setWidth(50),
                      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(5)),
                      color: showPrompt
                          ? Color.fromRGBO(247, 48, 48, 0.5)
                          : Colors.transparent,
                      child: Center(
                        child: Text(
                          '设定',
                          style: TextStyle(
                              color: showPrompt
                                  ? Colors.white
                                  : Colors.transparent,
                              fontSize: ScreenUtil().setSp(18)),
                        ),
                      ),
                    ),
                  ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: prevPage,
                  onPanEnd: (DragEndDetails e) {
                    prevPage();
                  },
                  child: Container(
                    height: double.infinity,
                    width: ScreenUtil().setWidth(50),
                    color: showPrompt
                        ? Color.fromRGBO(134, 197, 36, 0.5)
                        : Colors.transparent,
                    child: Center(
                      child: DefaultTextStyle(
                          style: TextStyle(
                              color: showPrompt
                                  ? Colors.white
                                  : Colors.transparent,
                              fontSize: ScreenUtil().setSp(18)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('上'),
                              Text('一'),
                              Text('页'),
                            ],
                          )),
                    ),
                  ),
                ),
                !showPrompt
                    ? Container()
                    : Expanded(
                        child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          isShow = !isShow;
                          showPrompt = false;
                          setState(() {});
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(5)),
                          height: double.infinity,
                          color: showPrompt
                              ? Color.fromRGBO(34, 156, 240, 0.5)
                              : Colors.transparent,
                          child: Center(
                            child: DefaultTextStyle(
                                style: TextStyle(
                                    color: showPrompt
                                        ? Colors.white
                                        : Colors.transparent,
                                    fontSize: ScreenUtil().setSp(18)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('手势操作区域'),
                                    // Text('区域内双击可缩放'),
                                    SizedBox(
                                      height: ScreenUtil().setWidth(25),
                                    ),
                                    Text('点我关闭提示'),
                                  ],
                                )),
                          ),
                        ),
                      )),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: nextPage,
                  onPanEnd: (DragEndDetails e) {
                    nextPage();
                  },
                  child: Container(
                    height: double.infinity,
                    width: ScreenUtil().setWidth(50),
                    color: showPrompt
                        ? Color.fromRGBO(134, 197, 36, 0.5)
                        : Colors.transparent,
                    child: Center(
                      child: DefaultTextStyle(
                          style: TextStyle(
                              color: showPrompt
                                  ? Colors.white
                                  : Colors.transparent,
                              fontSize: ScreenUtil().setSp(18)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('下'),
                              Text('一'),
                              Text('页'),
                            ],
                          )),
                    ),
                  ),
                ),
              ],
            )),
            GestureDetector(
              onTap: nextPage,
              onPanEnd: (DragEndDetails e) {
                nextPage();
              },
              child: Container(
                height: ScreenUtil().setWidth(50),
                margin: EdgeInsets.only(top: ScreenUtil().setWidth(5)),
                color: showPrompt
                    ? Color.fromRGBO(134, 197, 36, 0.5)
                    : Colors.transparent,
                child: Center(
                  child: Text(
                    '下一页',
                    style: TextStyle(
                        color: showPrompt ? Colors.white : Colors.transparent,
                        fontSize: ScreenUtil().setSp(18)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget comicsPageView() {
    return Listener(
      onPointerDown: (PointerDownEvent e) {
        if (_timer != null && _timer.isActive) {
          _timer.cancel();
        }
      },
      onPointerUp: (PointerUpEvent e) {
        if (_timer != null && !_timer.isActive && isAutomatic) {
          int time = (timeList[defaultTime] * 1000).toInt();
          _timer = Timer.periodic(Duration(milliseconds: time), (timer) {
            autoPage();
          });
        }
      },
      child: ScrollablePositionedList.builder(
          physics: ClampingScrollPhysics(),
          scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
          itemScrollController: comicScroll,
          itemPositionsListener: itemPositionsListener,
          padding: EdgeInsets.only(top: 0),
          itemBuilder: (BuildContext context, int index) {
            return isHorizontal
                ? comicsData[index].imgWidth == 'none' ||
                        comicsData[index].imgHeight == 'none'
                    ? Container()
                    : Container(
                        height: ScreenUtil().screenHeight,
                        width: ScreenUtil().screenWidth,
                        color: Colors.black,
                        child: Center(
                          child: ComicsImg(
                              img: comicsData[index].imgUrl,
                              isHorizontal: isHorizontal,
                              isTap: isTap,
                              index: index,
                              width: comicsData[index].imgWidth == '0'
                                  ? ScreenUtil().screenWidth
                                  : double.parse(comicsData[index].imgWidth),
                              height: comicsData[index].imgHeight == '0'
                                  ? ScreenUtil().screenHeight
                                  : double.parse(comicsData[index].imgHeight),
                              currentIndex: currenPage,
                              setPosition: (int position, double pageOffset) {
                                currenPage = position;
                                controllerOffset['offsetLeft'] = pageOffset;
                                setState(() {});
                              },
                              length: comicLength),
                        ),
                      )
                : (comicsData[index].imgWidth == 'none' ||
                        comicsData[index].imgHeight == 'none'
                    ? Container()
                    : ComicsImg(
                        img: comicsData[index].imgUrl,
                        isHorizontal: isHorizontal,
                        width: comicsData[index].imgWidth == '0'
                            ? ScreenUtil().screenWidth
                            : double.parse(comicsData[index].imgWidth),
                        height: comicsData[index].imgHeight == '0'
                            ? ScreenUtil().screenHeight
                            : double.parse(comicsData[index].imgHeight),
                        isTap: isTap,
                        index: index,
                        currentIndex: currenPage,
                        setPosition: (int position, double pageOffset) {
                          currenPage = position;
                          controllerOffset['offsetLeft'] = pageOffset;
                          setState(() {});
                        },
                        length: comicLength));
          },
          itemCount: comicLength),
    );
  }

  Widget pageController() {
    return Positioned(
      child: Container(
        height: ScreenUtil().screenHeight,
        width: ScreenUtil().screenWidth,
        // color: Color.fromRGBO(0, 0, 0, 0.5),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              transitionWidget(
                  height: ScreenUtil().setWidth(44),
                  top: isShow ? 0 : ScreenUtil().setWidth(-50),
                  opacity: isShow ? 1 : 0,
                  child: comicHeader(),
                  time: animationTime),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    transitionWidget(
                        height: ScreenUtil().setWidth(75),
                        width: ScreenUtil().setWidth(45),
                        left: isShow ? 0 : ScreenUtil().setWidth(-100),
                        opacity: isShow ? 1 : 0,
                        child: comicButtom(
                            type: 'left',
                            onTap: () {
                              if (widget.episode > 1) {
                                swichComic(widget.episode - 1, replace: true);
                              } else {
                                BotToast.showText(
                                    text: '已经是第一话了哦～',
                                    align: Alignment(0, 0),
                                    duration: new Duration(seconds: 2));
                              }
                            }),
                        time: animationTime),
                    transitionWidget(
                        height: ScreenUtil().setWidth(75),
                        width: ScreenUtil().setWidth(45),
                        right: isShow ? 0 : ScreenUtil().setWidth(-100),
                        opacity: isShow ? 1 : 0,
                        child: comicButtom(
                            type: 'right',
                            onTap: () {
                              if (widget.episode < widget.allEpisode) {
                                swichComic(widget.episode + 1, replace: true);
                              } else {
                                BotToast.showText(
                                    text: '已经是最后一话了哦～',
                                    align: Alignment(0, 0),
                                    duration: new Duration(seconds: 2));
                              }
                              CommonUtils.debugPrint('下一话');
                            }),
                        time: animationTime),
                  ],
                ),
              ),
              transitionWidget(
                  height: ScreenUtil().setWidth(244),
                  bottom: isShow ? 0 : ScreenUtil().setWidth(-250),
                  opacity: isShow ? 1 : 0,
                  child: bottomController(),
                  time: animationTime)
            ],
          ),
        ),
      ),
    );
  }

  autoPage() {
    var segmet =
        ScreenUtil().setWidth(295) / controllerOffset['pageIndex']['max'];
    if (currenPage + 1 != comicLength) {
      currenPage++;
      CommonUtils.debugPrint('--------${currenPage + 1}-$comicLength--');
      controllerOffset['offsetLeft'] = (currenPage + 1) * segmet;
      comicScroll.jumpTo(index: currenPage);
      setState(() {});
    } else {
      isAutomatic = false;
      _timer.cancel();
    }
  }

  Widget bottomController() {
    return Container(
      width: ScreenUtil().screenWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          transitionWidget(
              height: ScreenUtil().setWidth(120.5),
              right: automatic ? 0 : ScreenUtil().screenWidth,
              opacity: automatic ? 1 : 0,
              child: DefaultTextStyle(
                  style: TextStyle(
                      color: Colors.white, fontSize: ScreenUtil().setSp(12)),
                  child: Container(
                    height: ScreenUtil().setWidth(120.5),
                    width: ScreenUtil().screenWidth,
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(14),
                        bottom: ScreenUtil().setWidth(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('自动翻页间隔${timeList[defaultTime]}秒'),
                        gestureWidget(_keyb, 'timeLeft', defaultTime,
                            timeList.length - 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_timer != null && _timer.isActive) {
                                  _timer.cancel();
                                }
                                int time =
                                    (timeList[defaultTime] * 1000).toInt();
                                _timer = Timer.periodic(
                                    Duration(milliseconds: time), (timer) {
                                  autoPage();
                                });
                                isAutomatic = true;
                                isShow = false;
                                setState(() {});
                              },
                              child: Container(
                                width: ScreenUtil().setWidth(81),
                                height: ScreenUtil().setWidth(26.5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white,
                                        width: ScreenUtil().setWidth(0.5)),
                                    borderRadius: BorderRadius.circular(2.5)),
                                child: Center(child: Text('开始')),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_timer != null && _timer.isActive) {
                                  _timer.cancel();
                                }
                                setState(() {
                                  isAutomatic = false;
                                  isShow = false;
                                });
                              },
                              child: Container(
                                width: ScreenUtil().setWidth(81),
                                height: ScreenUtil().setWidth(26.5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white,
                                        width: ScreenUtil().setWidth(0.5)),
                                    borderRadius: BorderRadius.circular(2.5)),
                                child: Center(child: Text('结束自动翻页')),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
              time: 200),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(3.5)),
            height: ScreenUtil().setWidth(120),
            width: ScreenUtil().screenWidth,
            color: Color.fromRGBO(0, 0, 0, 0.7),
            padding: EdgeInsets.only(
                top: ScreenUtil().setWidth(15),
                bottom: ScreenUtil().setWidth(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                      fontSize: ScreenUtil().setWidth(14), color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                          '${currenPage + 1 > controllerOffset['pageIndex']['max'] ? controllerOffset['pageIndex']['max'] : currenPage + 1}'),
                      gestureWidget(_key, 'offsetLeft', currenPage + 1,
                          controllerOffset['pageIndex']['max']),
                      Text(controllerOffset['pageIndex']['max'].toString())
                    ],
                  ),
                ),
                Container(
                  height: ScreenUtil().setWidth(0.5),
                  width: ScreenUtil().setWidth(345),
                  color: Color(0xffb1b1b1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //selectState
                    settingBtn(
                        color: Colors.white,
                        img: '1',
                        title: '目录',
                        onTap: () {
                          if (automatic) {
                            automatic = false;
                            setState(() {});
                          }
                          _scaffoldKey.currentState.openEndDrawer();
                        }),
                    settingBtn(
                        color:
                            selectState == 1 ? Color(0xffff2e4e) : Colors.white,
                        img: selectState == 1 ? '3' : '2',
                        title: '上下翻页',
                        onTap: () {
                          isHorizontal = false;
                          selectState = 1;
                          if (automatic) {
                            automatic = false;
                          }
                          setState(() {});
                          comicScroll.jumpTo(index: currenPage);
                        }),
                    settingBtn(
                        color:
                            selectState == 2 ? Color(0xffff2e4e) : Colors.white,
                        img: selectState == 2 ? '5' : '4',
                        title: '左右翻页',
                        onTap: () {
                          isHorizontal = true;
                          selectState = 2;
                          if (automatic) {
                            automatic = false;
                          }
                          setState(() {});
                          comicScroll.jumpTo(index: currenPage);
                        }),
                    settingBtn(
                        color: Colors.white,
                        img: '6', //selectState == 3 ? '7' :
                        title: '自动翻页',
                        onTap: () {
                          setState(() {
                            automatic = true;
                          });
                        })
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  fixOffset(String offset, double segmet, int max) {
    if (offset == 'timeLeft') {
      defaultTime = (controllerOffset[offset] / segmet).toInt() > max
          ? max
          : (controllerOffset[offset] / segmet).toInt();
    } else {
      currenPage = (controllerOffset[offset] / segmet).toInt() > max
          ? max
          : (controllerOffset[offset] / segmet).toInt();
      if (currenPage >= 0 && currenPage <= comicLength - 1) {
        comicScroll.jumpTo(index: currenPage);
      }
    }
    setState(() {});
  }

  Widget gestureWidget(GlobalKey key, String offset, int min, int max) {
    //容器长度/分割数量
    var segmet = ScreenUtil().setWidth(295) / max;
    if (offset == 'timeLeft' && intPage) {
      controllerOffset[offset] = defaultTime * segmet;
      intPage = false;
      fixOffset(offset, segmet, max);
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanDown: (DragDownDetails e) {
        CommonUtils.debugPrint('手指触碰');
        if (_timer != null && _timer.isActive) {
          _timer.cancel();
        }
        isTap = true;
        //打印手指按下的位置(相对于屏��)
        controllerOffset[offset] = e.globalPosition.dx - leftDx;
        fixOffset(offset, segmet, max);
      },
      onPanUpdate: (DragUpdateDetails e) {
        //用户手指滑动时，更新偏移，重新构建
        controllerOffset[offset] = e.globalPosition.dx - leftDx < 0
            ? 0.0
            : e.globalPosition.dx - leftDx;
        fixOffset(offset, segmet, max);
      },
      onPanEnd: (DragEndDetails e) {
        isTap = false;
        CommonUtils.debugPrint('手指抬起');
        if (_timer != null && !_timer.isActive && isAutomatic) {
          int time = (timeList[defaultTime] * 1000).toInt();
          _timer = Timer.periodic(Duration(milliseconds: time), (timer) {
            autoPage();
          });
        }
      },
      child: Container(
        key: key,
        height: ScreenUtil().setWidth(25),
        child: Center(
          child: Container(
            width: ScreenUtil().setWidth(295),
            height: ScreenUtil().setWidth(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(1.5)),
              color: Color.fromRGBO(250, 250, 250, 0.2),
            ),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                    return AnimatedContainer(
                        width: ((box.maxWidth / max) * min).truncateToDouble(),
                        height: ScreenUtil().setWidth(6),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(1.5)),
                          color: Color(0xffff506b),
                        ),
                        child: Stack(
                          overflow: Overflow.visible,
                          children: [
                            Positioned(
                                right: 0,
                                top: ScreenUtil().setWidth(-3),
                                child: Container(
                                  width: ScreenUtil().setWidth(9),
                                  height: ScreenUtil().setWidth(9),
                                  decoration: BoxDecoration(
                                      color: Color(0xffff2e4e),
                                      borderRadius: BorderRadius.circular(
                                          ScreenUtil().setWidth(4.5)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xffff2e4e),
                                          blurRadius: ScreenUtil().setWidth(5),
                                        )
                                      ]),
                                ))
                          ],
                        ),
                        duration: Duration(milliseconds: 0));
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget settingBtn({Color color, String title, String img, Function onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/comics/reader_icon_$img.png',
            width: ScreenUtil().setWidth(20),
            height: ScreenUtil().setWidth(20),
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: ScreenUtil().setWidth(9),
          ),
          Text(
            title,
            style: TextStyle(color: color, fontSize: ScreenUtil().setSp(12)),
          )
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
            Image.asset(
              'assets/images/comics/' +
                  (type == 'left' ? 'left.png' : 'right.png'),
              width: ScreenUtil().setWidth(12.5),
              height: ScreenUtil().setWidth(16),
              filterQuality: FilterQuality.high,
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
                    Text('话'),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget comicHeader() {
    return Container(
      height: ScreenUtil().setWidth(44),
      width: ScreenUtil().screenWidth,
      color: Color.fromRGBO(0, 0, 0, 0.5),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Container(
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                    child: Image.asset(
                      'assets/images/comics/icon_w_black.png',
                      width: ScreenUtil().setWidth(20),
                      height: ScreenUtil().setWidth(20),
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.contain,
                    )),
              ),
              Container(
                  width: ScreenUtil().screenWidth * 0.7,
                  child: Text(
                    widget.title,
                    style: TextStyle(
                        color: Colors.white, fontSize: ScreenUtil().setSp(21)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ))
            ],
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                isShow = false;
                showPrompt = true;
              });
            },
            child: Container(
              width: ScreenUtil().setWidth(50),
              height: double.infinity,
              child: Center(
                child: Container(
                  height: ScreenUtil().setWidth(15),
                  width: ScreenUtil().setWidth(15),
                  decoration: BoxDecoration(
                      color: Color(0xffff526d),
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(7.5))),
                  child: Center(
                    child: Text(
                      '?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(11)),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  //阅读器目录
  Widget comicDrawer() {
    return Container(
      height: ScreenUtil().screenHeight,
      width: ScreenUtil().setWidth(286.5),
      color: Color(0xfff7f6fb),
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
                Text(widget.type == 0 ? '连载' : '已完结',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil().setSp(18),
                        fontWeight: FontWeight.w700)),
                SizedBox(width: ScreenUtil().setWidth(10.5)),
                Text('更新至${widget.allEpisode}话',
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
              children: episodeList.asMap().keys.map((e) {
                return GestureDetector(
                  onTap: () {
                    swichComic(e + 1, replace: true);
                    setState(() {
                      cureentIndex = e + 1;
                    });
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(84.5),
                    height: ScreenUtil().setWidth(32),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.5),
                        color: cureentIndex == e + 1
                            ? Color(0xffff506b)
                            : Colors.white),
                    child: Center(
                        child: Text(
                      episodeList[e].toString(),
                      style: TextStyle(
                          color: cureentIndex == e + 1
                              ? Colors.white
                              : Colors.black,
                          fontSize: ScreenUtil().setSp(15)),
                    )),
                  ),
                );
              }).toList(),
            ),
          ))
        ],
      ),
    );
  }

  Widget transitionWidget(
      {int time = 200,
      double height,
      double opacity,
      double width,
      Widget child,
      double left,
      double right,
      double bottom,
      double top}) {
    return Container(
      height: height,
      width: width,
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Container(),
          AnimatedPositioned(
              right: right,
              left: left,
              bottom: bottom,
              top: top,
              child: AnimatedOpacity(
                opacity: opacity,
                duration: Duration(milliseconds: time),
                child: child,
              ),
              duration: Duration(milliseconds: time))
        ],
      ),
    );
  }
}
