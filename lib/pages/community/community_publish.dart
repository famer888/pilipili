import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/pages/community/file_upload_item.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';

class CommunityPushlish extends StatefulWidget {
  const CommunityPushlish({Key? key}) : super(key: key);

  @override
  State<CommunityPushlish> createState() => _CommunityPushlishState();
}

class _CommunityPushlishState extends State<CommunityPushlish> {
  ValueNotifier<bool> showCoinInput = ValueNotifier(false);
  TextEditingController coin = TextEditingController(text: '0');
  TextEditingController title = TextEditingController(text: '');
  TextEditingController content = TextEditingController(text: '');
  List topics = [];
  ValueNotifier<List> imageList = ValueNotifier([]);
  ValueNotifier<List> videoList = ValueNotifier([]);
  final ImagePicker _picker = ImagePicker();
  bool loading = true;
  int maxLength = 9;
  int isPublic = 1;
  bool isChange = false;
  int videoMaxLength = 1;
  ValueNotifier<List> selectTopic = ValueNotifier([]);
  bool isAI = false;
  String aiMsg = '';
  List tags = [];
  String aiCoins = '0';
  int oImageLength = 0;

//选择视频
  Future<void> videoPickerAssets() async {
    int _length = videoList.value
        .where((element) {
          GlobalKey<FileUploadItemState> _key = element['key'];
          return _key.currentState!.showWidget;
        })
        .toList()
        .length;
    if (_length >= videoMaxLength) {
      CommonUtils.showText('最多上传$videoMaxLength个视频');
      return;
    }
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      if (kIsWeb) {
        String ext = file.name.split(".").last.toLowerCase();
        if (ext == "mp4" || file.mimeType == 'video/quicktime') {
          videoList.value = [
            ...videoList.value,
            {'file': file, 'key': new GlobalKey<FileUploadItemState>()}
          ];
        } else {
          CommonUtils.showText('请选择mp4格式的视频');
        }
      } else {
        bool flag = await CommonUtils.pngLimitSize(file, size: 100, tips: "请上传100M以内的视频");
        if (flag) return;
        String ext = file.name.split(".").last.toLowerCase();
        if (ext == "mp4" || file.mimeType == 'video/quicktime') {
          videoList.value = [
            ...videoList.value,
            {'file': file, 'key': new GlobalKey<FileUploadItemState>()}
          ];
        } else {
          CommonUtils.showText('请选择mp4格式的视频');
        }
      }
    }
  }

  //选择图片
  Future<void> imagePickerAssets() async {
    int _length = imageList.value
        .where((element) {
          GlobalKey<FileUploadItemState> _key = element['key'];
          return _key.currentState!.showWidget;
        })
        .toList()
        .length;
    if (_length >= maxLength) {
      CommonUtils.showText('最多上传$maxLength张图片');
      return;
    }
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      if (kIsWeb) {
        imageList.value = [
          ...imageList.value,
          {'file': file, 'key': new GlobalKey<FileUploadItemState>()}
        ];
      } else {
        bool flag = await CommonUtils.pngLimitSize(file, tips: "请上传5M以内的图片");
        if (flag) return;
        imageList.value = [
          ...imageList.value,
          {'file': file, 'key': new GlobalKey<FileUploadItemState>()}
        ];
      }
    }
  }

  isSelect(List _tags, int id) {
    return _tags.any((element) => int.parse(element['id'].toString()) == id);
  }

  changeImage() {
    isChange = true;
  }

  getCircle() {
    //所有圈子/发帖规则
    prePostData().then((res) {
      if (res['status'] != 0) {
        topics = res['data']['topic'] ?? [];
        aiCoins = res['data']['ai_coins'];
        aiMsg = res['data']['ai_msg'];
        if (AppGlobal.postInfo.isNotEmpty) {
          Map info = AppGlobal.postInfo;
          title.text = info['title'];
          content.text = info['content'];
          showCoinInput.value = true;
          coin.text = info['unlock_coins'].toString();
          selectTopic.value = info['topic_info'];
          isAI = selectTopic.value
              .where((element) {
                return element['is_ai'] != 0;
              })
              .toList()
              .isNotEmpty;
          List newImageList = List.from(info['medias']).where((item) => item['type'] == 1).toList();
          imageList.value = newImageList.map((e) {
            return {
              'key': new GlobalKey<FileUploadItemState>(),
              'media_url': e['ori_media_url'],
              'cover': (AppGlobal.bannerImgBase ?? '') + e['ori_media_url'],
              'type': 1,
              'w': e['thumb_width'],
              'h': e['thumb_height'],
            };
          }).toList();
          List newVideoList = List.from(info['medias']).where((item) => item['type'] == 2).toList();
          videoList.value = newVideoList.map((e) {
            return {
              'key': new GlobalKey<FileUploadItemState>(),
              'media_url': e['ori_media_url'],
              'cover': (AppGlobal.bannerImgBase ?? '') + e['ori_media_url'],
              'type': 2,
              'w': e['thumb_width'],
              'h': e['thumb_height'],
            };
          }).toList();
        }
        if (isAI) {
          maxLength = 3;
        } else {
          maxLength = 9;
        }
        loading = false;
        setState(() {});
        oImageLength = imageList.value.length;
        imageList.addListener(() {
          if (imageList.value.length != oImageLength && !isChange) {
            isChange = true;
          }
        });
      } else {
        CommonUtils.showText(res['msg'] ?? '接口异常');
      }
    });
  }

  bool uploadLoading() {
    int imageLength = imageList.value
        .where((element) {
          GlobalKey<FileUploadItemState> _key = element['key'];
          return _key.currentState!.showLoad.value;
        })
        .toList()
        .length;
    int videoLength = isAI
        ? 0
        : videoList.value
            .where((element) {
              GlobalKey<FileUploadItemState> _key = element['key'];
              return _key.currentState!.showLoad.value;
            })
            .toList()
            .length;
    return imageLength > 0 || videoLength > 0;
  }

  publishAiPost() {
    if (isChange) {
      YyShowDialog.showdialog(context, title: '温馨提示', btnText: '立即购买', cancelText: '取消', callBack: () {
        publishPost();
      }, content: (setDialogState) {
        return DefaultTextStyle(
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xffFF5B8C), fontSize: 16.sp),
            child: Text('AI脱衣将会花费$aiCoins皮哩币，若有VIP发布次数则会优先扣除是否确定发布帖子？'));
      });
    } else {
      publishPost();
    }
  }

  publishPost() {
    if (uploadLoading()) {
      CommonUtils.showText('请等待文件上传完成');
      return;
    }
    int imageLength = imageList.value
        .where((element) {
          GlobalKey<FileUploadItemState> _key = element['key'];
          return _key.currentState!.showWidget;
        })
        .toList()
        .length;
    int videoLength = isAI
        ? 0
        : videoList.value
            .where((element) {
              GlobalKey<FileUploadItemState> _key = element['key'];
              return _key.currentState!.showWidget;
            })
            .toList()
            .length;
    if (selectTopic.value.isEmpty) {
      CommonUtils.showText('请选择圈子');
      return;
    }
    try {
      if (coin.text.trim() != "") {
        int _coins = int.parse(coin.text);
        if (_coins > 900) {
          CommonUtils.showText('帖子最高价格请设置900以内');
          return;
        }
        if (_coins > 0 && videoLength == 0 && !isAI) {
          CommonUtils.showText('视频帖子才能设置价格');
          return;
        }
      }
    } catch (e) {
      CommonUtils.showText('帖子价格请输入正确金额');
      return;
    }
    if (title.text.isEmpty) {
      CommonUtils.showText('请输入帖子标题');
      return;
    }
    if (content.text.isEmpty) {
      CommonUtils.showText('请输入帖子内容');
      return;
    }

    if (imageLength == 0) {
      CommonUtils.showText('请上传图片');
      return;
    }
    // if (!isAI && videoLength == 0) {
    //   CommonUtils.showText('请上传视频');
    //   return;
    // }
    List newFilelist = [...imageList.value, ...(isAI ? [] : videoList.value)].where((element) {
      GlobalKey<FileUploadItemState> _key = element['key'];
      return _key.currentState!.showWidget;
    }).toList();
    List fileList = newFilelist.map((e) {
      GlobalKey<FileUploadItemState> _key = e['key'];
      Map dataInfo = _key.currentState!.dataInfo;
      return {
        'media_url': dataInfo['media_url'],
        'type': dataInfo['type'],
        'thumb_height': dataInfo['h'],
        'thumb_width': dataInfo['w']
      };
    }).toList();
    PageStatus.showLoading(text: '发布中...');
    createPost(
            postInfo: AppGlobal.postInfo,
            coins: coin.text,
            title: title.text,
            topicId: selectTopic.value.map((e) => e['id']).toList().join(','),
            content: content.text,
            medias: fileList,
            is_open: isAI ? isPublic : 0)
        .then((value) {
      if (value['status'] != 0) {
        context.pop();
        YyShowDialog.showdialog(context, title: '发布成功', btnText: '查看帖子', cancelText: '取消', callBack: () {
          AppGlobal.appContext!.push('/myPost');
        }, content: (setDialogState) {
          return DefaultTextStyle(
              style: TextStyle(
                color: Color(0xffFF5B8C),
                fontSize: ScreenUtil().setSp(16),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              child: Text('帖子发布成功,请耐心等待审核,可以在\n我的>帖子管理中查看'));
        });
      } else {
        print(value['msg']);
        CommonUtils.showText(value['msg'] ?? '接口异常');
      }
    }).whenComplete(() {
      PageStatus.closeLoading();
    });
  }

  @override
  void initState() {
    getCircle();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    AppGlobal.postInfo = {};
    imageList.dispose();
    videoList.dispose();
    title.dispose();
    coin.dispose();
    content.dispose();
    selectTopic.dispose();
  }

  static TextStyle titleStyle = TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Color(0xff6d6d6d));
  static TextStyle subtitleStyle = TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Color(0xff979797));
  static TextStyle btnStyle = TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white);

  Widget tapBtn(String text, {bool status = true}) {
    return Container(
      height: 30.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient: status ? DefaultStyle.defaluGrandientLine : DefaultStyle.whiteGrandientLine,
          borderRadius: BorderRadius.circular(50.w)),
      child: Text(
        text,
        style: status ? btnStyle : TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Color(0xffFF84A9)),
      ),
    );
  }

  showQuanzi() {
    tags = [...selectTopic.value];
    YyShowDialog.showdialog(context, title: '选择圈子', btnText: '确定', cancelText: '取消', callBack: () {
      selectTopic.value = tags;
      isAI = selectTopic.value
          .where((element) {
            return element['is_ai'] != 0;
          })
          .toList()
          .isNotEmpty;
      if (isAI) {
        maxLength = 3;
      } else {
        maxLength = 9;
      }
      setState(() {});
    }, content: (setDialogState) {
      return SizedBox(
        height: 200.w,
        child: GridView.builder(
            itemCount: topics.length,
            padding: EdgeInsets.zero,
            // physics: const NeverScrollableScrollPhysics(),
            // shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4.w,
              crossAxisSpacing: 4.w,
              childAspectRatio: 83 / 36,
            ),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  if (isSelect(tags, topics[index]['topic_id'])) {
                    int _index = tags.indexWhere((element) => element['id'] == topics[index]['topic_id'].toString());
                    tags.removeAt(_index);
                  } else {
                    tags.add({
                      'id': topics[index]['topic_id'].toString(),
                      'title': topics[index]['topic_name'],
                      'is_ai': topics[index]['is_ai']
                    });
                  }
                  setDialogState(() {});
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.w),
                      color: isSelect(tags, topics[index]['topic_id']) ? Color(0xffFF84A9) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: isSelect(tags, topics[index]['topic_id'])
                                ? Color(0xffA82118).withOpacity(0.26)
                                : Color(0xffFFD3E6),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0)
                      ]),
                  child: Text(
                    topics[index]['topic_name'],
                    style: TextStyle(
                        color: isSelect(tags, topics[index]['topic_id'])
                            ? Colors.white
                            : (topics[index]['is_ai'] != 0 ? Color(0xffFE155B) : Color(0xff828181)),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击任意地方，输入框失去焦点
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Column(
          children: [
            PageTitleBar(
              paddingTop: ScreenUtil().statusBarHeight,
              title: '發佈帖子',
            ),
            Expanded(
                child: loading
                    ? PageStatus.loading(true)
                    : ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                        children: [
                          Text(
                            '選擇圈子',
                            style: titleStyle,
                          ),
                          SizedBox(
                            height: 8.w,
                          ),
                          InkWell(
                            onTap: () {
                              showQuanzi();
                            },
                            child: SizedBox(
                              height: 36.w,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ValueListenableBuilder(
                                      valueListenable: selectTopic,
                                      builder: (context, _val, child) {
                                        return Expanded(
                                            child: Text(
                                          _val.isEmpty ? '#選擇圈子' : _val.map((e) => '#${e['title']}').toList().join(','),
                                          style: TextStyle(
                                              color: Color(0xff6d6d6d), fontSize: 14.sp, fontWeight: FontWeight.w400),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ));
                                      }),
                                  getImage('assets/images/2023/setup_right.png',
                                      width: 16.w, height: 16.w, isAssets: true)
                                ],
                              ),
                            ),
                          ),
                          isAI
                              ? Text(
                                  aiMsg.toString(),
                                  style: TextStyle(color: Color(0xffFE155B), fontSize: 12.sp),
                                )
                              : SizedBox(),
                          isAI
                              ? SizedBox()
                              : Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '上傳視頻',
                                                    style: titleStyle,
                                                  ),
                                                  SizedBox(
                                                    width: 8.w,
                                                  ),
                                                  Text(
                                                    '0/$videoMaxLength',
                                                    style: subtitleStyle,
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '支持mp4/mov格式，不超过 100 MB',
                                                style: subtitleStyle,
                                              ),
                                            ],
                                          ),
                                          GestureDetector(onTap: videoPickerAssets, child: tapBtn('新增影片'))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8.w,
                                      ),
                                      ValueListenableBuilder(
                                          valueListenable: videoList,
                                          builder: (context, List videos, child) {
                                            return videos.isEmpty
                                                ? Container()
                                                : Wrap(
                                                    spacing: 4.w,
                                                    runSpacing: 4.w,
                                                    alignment: WrapAlignment.spaceBetween,
                                                    children: videos.asMap().keys.map((index) {
                                                      return FileUploadItem(
                                                          type: 2, key: videos[index]['key'], data: videos[index]);
                                                    }).toList(),
                                                  );
                                          })
                                    ],
                                  ),
                                ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '上傳照片',
                                              style: titleStyle,
                                            ),
                                            SizedBox(
                                              width: 8.w,
                                            ),
                                            Text(
                                              '0/$maxLength',
                                              style: subtitleStyle,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '支持JPG/PNG格式，每張不超过 1 MB',
                                          style: subtitleStyle,
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: imagePickerAssets,
                                      child: tapBtn('新增照片'),
                                    )
                                  ],
                                ),
                                ValueListenableBuilder(
                                    valueListenable: imageList,
                                    builder: (context, List imgs, child) {
                                      return imgs.isEmpty
                                          ? Container()
                                          : Padding(
                                              padding: EdgeInsets.only(top: 8.w),
                                              child: Wrap(
                                                spacing: 4.w,
                                                runSpacing: 4.w,
                                                alignment: WrapAlignment.spaceBetween,
                                                children: imgs.asMap().keys.map((index) {
                                                  return FileUploadItem(key: imgs[index]['key'], data: imgs[index]);
                                                }).toList(),
                                              ),
                                            );
                                    })
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.w),
                            child: Text(
                              '標題',
                              style: titleStyle,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            alignment: Alignment.center,
                            child: TextField(
                              autofocus: false,
                              controller: title,
                              maxLength: 20,
                              cursorColor: Color(0xffFF84A9),
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                  isDense: true,
                                  counterText: '',
                                  hintText: '請輸入文字...',
                                  hintStyle: TextStyle(fontSize: 14.sp, color: Color(0xffc2c2c2)),
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none),
                              style: TextStyle(
                                color: Color(0xff6D6D6D),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.w),
                            child: Text(
                              '內文',
                              style: titleStyle,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            height: 88.w,
                            child: TextField(
                              autofocus: false,
                              controller: content,
                              maxLines: 999,
                              cursorColor: Color(0xffFF84A9),
                              maxLength: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  isDense: true,
                                  helperMaxLines: 66,
                                  hintText: '請輸入文字...',
                                  hintStyle: TextStyle(fontSize: 14.sp, color: Color(0xffc2c2c2)),
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none),
                              style: TextStyle(
                                color: Color(0xff6D6D6D),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          isAI
                              ? Text(
                                  '帖子是否公開',
                                  style: titleStyle,
                                )
                              : SizedBox(),
                          SizedBox(
                            height: isAI ? 8.w : 0,
                          ),
                          isAI
                              ? Row(
                                  children: [
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        isPublic = 1;
                                        coin.text = '';
                                        setState(() {});
                                      },
                                      child: Container(
                                        height: 36.w,
                                        decoration: isPublic == 1
                                            ? DefaultStyle.activeDecoration
                                            : DefaultStyle.defaultDecoration,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '僅限自己觀看',
                                          style: TextStyle(
                                              color: isPublic == 1 ? Colors.white : Color(0xff828181),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    )),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              isPublic = 0;
                                              setState(() {});
                                            },
                                            child: Container(
                                              height: 36.w,
                                              decoration: isPublic == 0
                                                  ? DefaultStyle.activeDecoration
                                                  : DefaultStyle.defaultDecoration,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '公開發佈帖子',
                                                style: TextStyle(
                                                    color: isPublic == 0 ? Colors.white : Color(0xff828181),
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w700),
                                              ),
                                            )))
                                  ],
                                )
                              : SizedBox(),
                          isPublic == 1 && isAI
                              ? SizedBox()
                              : Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '設置金幣',
                                            style: titleStyle,
                                          ),
                                          SizedBox(
                                            width: 8.w,
                                          ),
                                          Text(
                                            '最高設置900皮哩幣',
                                            style: subtitleStyle,
                                          )
                                        ],
                                      ),
                                      ValueListenableBuilder(
                                          valueListenable: showCoinInput,
                                          builder: (context, value, child) {
                                            return GestureDetector(
                                              onTap: () {
                                                showCoinInput.value = !showCoinInput.value;
                                                coin.text = '';
                                              },
                                              child: tapBtn(value ? '關閉' : '開啟', status: !showCoinInput.value),
                                            );
                                          })
                                    ],
                                  ),
                                ),
                          isPublic == 1 && isAI
                              ? SizedBox()
                              : ValueListenableBuilder(
                                  valueListenable: showCoinInput,
                                  builder: (context, value, child) {
                                    return value ? (child ?? Container()) : Container();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                                    alignment: Alignment.center,
                                    child: TextField(
                                      autofocus: true,
                                      controller: coin,
                                      maxLength: 20,
                                      cursorColor: Color(0xffFF84A9),
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                      ],
                                      decoration: InputDecoration(
                                          isDense: true,
                                          counterText: '',
                                          hintText: '請輸入金額',
                                          hintStyle: TextStyle(fontSize: 14.sp, color: Color(0xffc2c2c2)),
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none),
                                      style: TextStyle(
                                        color: Color(0xff6D6D6D),
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.w),
                            child: GestureDetector(
                              onTap: isAI ? publishAiPost : publishPost,
                              child: Container(
                                width: 327.w,
                                height: 40.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50.w),
                                    gradient: DefaultStyle.defaluGrandientLine),
                                child: Text(
                                  '立即發布',
                                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().bottomBarHeight + 30.w,
                          )
                        ],
                      ))
          ],
        ),
      ),
    );
  }
}
