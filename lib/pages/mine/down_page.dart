import 'package:flutter/material.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/card/hcard.dart';
import 'package:pilipili/components/card/vcard.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';
import 'package:hive/hive.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/components/page_status.dart';
import 'dart:io';
import 'package:pilipili/utils/download_video.dart';
import 'package:pilipili/utils/download_comics.dart';

import 'package:pilipili/utils/logUtil.dart';

class DownPage extends StatefulWidget {
  DownPage({Key key}) : super(key: key);

  @override
  _DownPageState createState() => _DownPageState();
}

class _DownPageState extends State<DownPage> with TickerProviderStateMixin {
  final myController = TextEditingController();
  TabController _tabController;
  int currentTab = 0;
  bool isEdit = false;
  bool isAll = false;
  List tabList = [
    {
      'id': 1,
      'name': '视频',
    },
    {
      'id': 2,
      'name': '漫画',
    },
  ];
  @override
  void initState() {
    super.initState();

    /// 选项卡控制器
    _tabController = TabController(
      length: tabList.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.index.toDouble() == _tabController.animation.value) {
        if (isEdit && isAll) {
          isAll = false;
          EventBus()
              .emit("EDIT_DOWNLOAD", {"isAll": false, "current": currentTab});
        }
        currentTab = _tabController.index;
        setState(() {});
      }
    });
  }

  changeIsAll(bool status) {
    setState(() {
      isAll = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            paddingTop: ScreenUtil().statusBarHeight,
            title: '我的下载',
            rightWidget: GestureDetector(
              onTap: () {
                setState(() {
                  isEdit = !isEdit;
                });
              },
              child: Container(
                child: Text(
                  '编辑',
                  style: TextStyle(
                      color: Color(0xffffffff),
                      fontSize: ScreenUtil().setWidth(15)),
                ),
              ),
            ),
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: ScreenUtil().setWidth(44),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(255, 91, 140, 0.1),
                      offset: Offset(0, 10),
                      blurRadius: 10,
                      spreadRadius: 0)
                ]),
                child: TabBar(
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.transparent,
                  labelPadding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(0),
                      horizontal: ScreenUtil().setWidth(3)),
                  controller: _tabController,
                  isScrollable: true,
                  tabs: tabList
                      .asMap()
                      .keys
                      .map((e) => Container(
                            height: ScreenUtil().setWidth(44),
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Opacity(
                                  opacity: e == currentTab ? 1 : 0,
                                  child: Image.asset(
                                    "assets/images/icon_love_red2.png",
                                    width: ScreenUtil().setWidth(6),
                                    fit: BoxFit.fitWidth,
                                    filterQuality: FilterQuality.high
                                  ),
                                ),
                                Text(
                                  tabList[e]['name'],
                                  style: TextStyle(
                                      color: e == currentTab
                                          ? Color(0xffff5b8c)
                                          : Color(0xffc2c2c2),
                                      fontSize: ScreenUtil().setSp(15)),
                                ),
                                Opacity(
                                  opacity: 0,
                                  child: Image.asset(
                                    "assets/images/icon_love_red2.png",
                                    width: ScreenUtil().setWidth(6),
                                    fit: BoxFit.fitWidth,
                                    filterQuality: FilterQuality.high
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    PageViewMixin(
                      child: DownList(
                          type: 1,
                          isEdit: isEdit,
                          current: currentTab,
                          changeIsAll: changeIsAll),
                    ),
                    PageViewMixin(
                      child: DownList(
                          type: 2,
                          isEdit: isEdit,
                          current: currentTab,
                          changeIsAll: changeIsAll),
                    ),
                  ],
                ),
              )
            ],
          )),
          renderBottom()
        ],
      ),
    );
  }

  Widget renderBottom() {
    String allIcon = 'assets/images/icon_all_choose.png';
    String allNotIcon = 'assets/images/icon_all_choose_not.png';
    if (!isEdit) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(0, 0),
            blurRadius: 10,
            spreadRadius: 0)
      ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              EventBus().emit(
                  "EDIT_DOWNLOAD", {"isAll": !isAll, "current": currentTab});
              setState(() {
                isAll = !isAll;
              });
            },
            child: Container(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(15)),
              decoration: BoxDecoration(color: Colors.transparent),
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    isAll ? allIcon : allNotIcon,
                    width: ScreenUtil().setWidth(15),
                    height: ScreenUtil().setWidth(15),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high
                  ),
                  Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                    child: Text(
                      isAll ? "全不选" : "全选",
                      style: TextStyle(
                          color: DefaultStyle.themeColor,
                          fontSize: ScreenUtil().setSp(15)),
                    ),
                  )
                ],
              ),
            ),
          )),
          Container(
            color: DefaultStyle.themeColor,
            padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(10)),
            child: GestureDetector(
                onTap: () {
                  EventBus().emit("EDIT_DOWNLOAD",
                      {"isDelete": true, "current": currentTab});
                },
                child: Center(
                  child: Text(
                    "删除",
                    style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: ScreenUtil().setSp(15)),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

class DownList extends StatefulWidget {
  DownList({Key key, this.type, this.isEdit, this.current, this.changeIsAll})
      : super(key: key);
  int type;
  bool isEdit;
  int current;
  Function changeIsAll;
  @override
  _DownListState createState() => _DownListState();
}

class _DownListState extends State<DownList> {
  List data = [];
  bool loading = true;
  int chooseNum = 0;

  String chooseIcon = 'assets/images/icon_item_choose.png';
  String chooseNotIcon = 'assets/images/icon_item_choose_not.png';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch (widget.type) {
      case 1:
        // 获取视频数据
        getVideoDownloadInfo();
        break;
      case 2:
        // 获取漫画数据
        getComicsDownloadInfo();
        break;
      default:
        getVideoDownloadInfo();
    }
    EventBus().on('EDIT_DOWNLOAD', (arg) {
      if (arg["current"] == widget.type - 1) {
        if (arg["isAll"] != null && arg["isAll"]) {
          for (var i = 0; i < data.length; i++) {
            data[i]["choosed"] = true;
          }
          chooseNum = data.length;
          setState(() {});
        } else if (arg["isAll"] != null && !arg["isAll"]) {
          for (var i = 0; i < data.length; i++) {
            data[i]["choosed"] = false;
          }
          chooseNum = 0;
          setState(() {});
        }
        if (arg["isDelete"] != null && arg["isDelete"]) {
          onDelete();
        }
      }
    });
  }

  onDelete() async {
    Box box = await Hive.openBox('HiveBox');
    // data = box.get('download_video_tasks') ?? [];
    for (var i = 0; i < data.length; i++) {
      if (data[i]["choosed"] == true) {
        String path;
        String dir;
        if (widget.type == 1) {
          DownloadUtil.removeTask(data[i]["id"]);
          path = data[i]["url"];
          dir = path.substring(0, path.lastIndexOf("/"));
        } else if (widget.type == 2) {
          DownloadComics.removeTask(data[i]["id"]);
          dir = data[i]["url"];
        }
        Directory directory = Directory(dir);
        bool isExists = await directory.exists();
        if (isExists) {
          directory.deleteSync(recursive: true);
        }
      }
    }
    data.removeWhere((e) => e["choosed"] == true);
    if (widget.type == 1) {
      box.put("download_video_tasks", data);
    } else if (widget.type == 2) {
      box.put("download_comics_tasks", data);
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('EDIT_DOWNLOAD');
  }

  // 获取视频下载信息
  Future getVideoDownloadInfo() async {
    Box box = await Hive.openBox('HiveBox');
    data = box.get('download_video_tasks') ?? [];
    // print("视频信息-----$data");
    for (var i = 0; i < data.length; i++) {
      data[i]["choosed"] = false;
    }
    setState(() {
      loading = false;
    });
  }

  Future getComicsDownloadInfo() async {
    Box box = await Hive.openBox('HiveBox');
    data = box.get('download_comics_tasks') ?? [];
    LogUtil.d("漫画信息-----${data}");
    for (var i = 0; i < data.length; i++) {
      data[i]["choosed"] = false;
    }
    setState(() {
      loading = false;
    });
  }

  Widget chooseWidget(int index) {
    return widget.isEdit
        ? Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            left: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (data[index]["choosed"]) {
                  chooseNum--;
                } else {
                  chooseNum++;
                }
                data[index]["choosed"] = !data[index]["choosed"];
                if (chooseNum < data.length) {
                  widget.changeIsAll(false);
                } else if (chooseNum == data.length) {
                  widget.changeIsAll(true);
                }
                setState(() {});
              },
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(
                    top: ScreenUtil().setWidth(6),
                    left: ScreenUtil().setWidth(6)),
                child: Image.asset(
                  data[index]["choosed"] == true ? chooseIcon : chooseNotIcon,
                  width: ScreenUtil().setWidth(17),
                  height: ScreenUtil().setWidth(17),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high
                ),
              ),
            ))
        : Container();
  }

  _videoList() {
    return data.length == 0
        ? PageStatus.noData(text: '视频 下载为空')
        : GridView.builder(
            cacheExtent: ScreenUtil().screenHeight * 5,
            padding: EdgeInsets.symmetric(
                horizontal: DefaultStyle.pagePadding,
                vertical: ScreenUtil().setWidth(20)),
            itemCount: data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: ScreenUtil().setWidth(20),
              crossAxisSpacing: ScreenUtil().setWidth(7),
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Hcard(
                    maxLines: 1,
                    width: ScreenUtil().setWidth(171.5),
                    contentType: data[index]["contentType"],
                    thumbUrl: data[index]["thumbCover"],
                    cardData: data[index],
                    showField: 'title,tags',
                    isLocal: true,
                  ),
                  chooseWidget(index)
                ],
              );
            });
  }

  _comicsList() {
    return data.length == 0
        ? PageStatus.noData(text: '漫画 下载为空')
        : GridView.builder(
            cacheExtent: ScreenUtil().screenHeight * 5,
            padding: EdgeInsets.symmetric(
                horizontal: DefaultStyle.pagePadding,
                vertical: ScreenUtil().setWidth(20)),
            itemCount: data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: ScreenUtil().setWidth(9.5),
              crossAxisSpacing: ScreenUtil().setWidth(9.5),
              childAspectRatio: 0.61,
            ),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Vcard(
                    maxLines: 1,
                    width: ScreenUtil().setWidth(110),
                    contentType: 2,
                    thumbUrl: data[index]["thumb"],
                    cardData: data[index],
                    showField: 'title',
                    isLocal: true,
                  ),
                  chooseWidget(index)
                ],
              );
            });
  }

  getListWidget() {
    switch (widget.type) {
      case 1:
        return _videoList();
        break;
      case 2:
        return _comicsList();
        break;
      default:
        return _comicsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading ? PageStatus.loading(mounted) : getListWidget();
  }
}
