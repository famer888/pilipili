import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:bot_toast/bot_toast.dart';
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
import 'package:pilipili/pages/community/xfile_progress_toast.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/http.dart';
import 'package:pilipili/utils/networkImage.dart';

class CommunityPushlish extends StatefulWidget {
  const CommunityPushlish({Key key}) : super(key: key);

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
  int maxLength = 9;
  int videoMaxLength = 1;
  int selectId = 0;
  String selectText;
//选择视频
  Future<void> videoPickerAssets() async {
    if (videoList.value.length >= videoMaxLength) {
      CommonUtils.showText('最多上传$videoMaxLength张图片');
      return;
    }
    final XFile file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      bool flag =
          await CommonUtils.pngLimitSize(file, size: 100, tips: "请上传100M以内的图片");
      if (flag) return;
      String ext = file.name.split(".").last.toLowerCase();
      if (ext == "mp4" || file.mimeType == 'video/quicktime') {
        uploadVideo(file);
      } else {
        CommonUtils.showText('请选择mp4格式的视频');
      }
    }
  }

  void uploadVideo(XFile file) {
    BotToast.showCustomLoading(
      backgroundColor: Colors.black.withOpacity(0.7),
      toastBuilder: (cancel) => XFileProgressToast(
        file: file,
        response: (data) {
          BotToast.closeAllLoading();
          if (data.isEmpty) return;
          if (data['code'] == 1) {
            String orgURL = data['msg'] ?? '';
            videoList.value = [
              ...videoList.value,
              {'media_url': orgURL, 'cover': '', 'type': 2, 'w': 0, 'h': 0}
            ];
          } else {
            CommonUtils.showText(data['msg'] ?? "failed");
          }
        },
        cancel: () {
          BotToast.closeAllLoading();
        },
      ),
    );
  }

  //选择图片
  Future<void> imagePickerAssets() async {
    if (imageList.value.length >= maxLength) {
      CommonUtils.showText('最多上传$maxLength张图片');
      return;
    }
    final XFile file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      bool flag = await CommonUtils.pngLimitSize(file, tips: "请上传5M以内的图片");
      if (flag) return;
      uploadFileImg(file);
    }
  }

  void uploadFileImg(XFile file) async {
    PageStatus.showLoading(text: '上传中...');
    var data;
    Uint8List bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes.toList());
    int imageWidth = image.width;
    int imageHeight = image.height;
    if (kIsWeb) {
      data = await PlatformAwareHttp.xfileHtmlUploadImage(
          file: file, position: 'upload');
    } else {
      data = await PlatformAwareHttp.xfileUploadImage(
          file: file, position: 'upload');
    }
    PageStatus.closeLoading();
    if (data['code'] == 1) {
      String orgURL = data['msg'] ?? '';
      imageList.value = [
        ...imageList.value,
        {
          'media_url': orgURL,
          'cover': AppGlobal.bannerImgBase + orgURL,
          'type': 1,
          'w': imageWidth,
          'h': imageHeight
        }
      ];
    } else {
      CommonUtils.showText(data['msg'] ?? "failed");
    }
  }

  Widget mediaItem({Widget child, Function onClose}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.w),
          boxShadow: [
            BoxShadow(
                color: Color(0xffFFD3E6),
                offset: Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0)
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.w),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: child ?? Container(),
            ),
            Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    if (onClose != null) {
                      onClose();
                    }
                  },
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15.w)),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xffFF8B8B).withOpacity(0.8),
                              Color(0xffFF7696).withOpacity(0.8),
                              Color(0xffFF7299).withOpacity(0.8)
                            ])),
                    child: getImage('assets/images/2023/icon_close.png',
                        width: 12.w, height: 12.w, isAssets: true),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  getCircle() {
    //所有圈子/发帖规则
    prePostData().then((res) {
      if (res['status'] != 0) {
        CommonUtils.debugPrint(res['data']);
        topics = res['data']['topic'] ?? [];
        selectId = topics[0]['topic_id'];
        setState(() {});
      } else {
        CommonUtils.showText(res['msg'] ?? '接口异常');
      }
    });
  }

  publishPost() {
    if (selectText == null) {
      CommonUtils.showText('请选择圈子');
      return;
    }
    try {
      if (coin.text.trim() != "") {
        int _coins = int.parse(coin.text);
        if (_coins > 90) {
          CommonUtils.showText('帖子最高价格请设置90以内');
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
    if (videoList.value.isEmpty && imageList.value.isEmpty) {
      CommonUtils.showText('请上传图片或视频');
      return;
    }
    List fileList = [...imageList.value, ...videoList.value].map((e) {
      return {
        'media_url': e['media_url'],
        'type': e['type'],
        'thumb_height': e['h'],
        'thumb_width': e['w']
      };
    }).toList();
    PageStatus.showLoading(text: '发布中...');
    createPost(
            postInfo: AppGlobal.postInfo,
            coins: coin.text,
            title: title.text,
            topicId: selectId,
            content: content.text,
            medias: fileList)
        .then((value) {
      if (value['status'] != 0) {
        CommonUtils.showText(value['msg'] ?? '上传成功,请耐心等待审核');
        context.pop();
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
    if (AppGlobal.postInfo.isNotEmpty) {
      Map info = AppGlobal.postInfo;
      CommonUtils.debugPrint(info);
      title.text = info['title'];
      content.text = info['content'];
      showCoinInput.value = true;
      coin.text = info['unlock_coins'].toString();
      selectText = '#${info['topics']}';
      selectId = int.parse(info['topic_id']);
      List newImageList =
          List.from(info['medias']).where((item) => item['type'] == 1).toList();
      imageList.value = newImageList.map((e) {
        return {
          'media_url': e['ori_media_url'],
          'cover': AppGlobal.bannerImgBase + e['ori_media_url'],
          'type': 1,
          'w': e['thumb_width'],
          'h': e['thumb_height'],
        };
      }).toList();
      List newVideoList =
          List.from(info['medias']).where((item) => item['type'] == 2).toList();
      videoList.value = newVideoList.map((e) {
        return {
          'media_url': e['ori_media_url'],
          'cover': AppGlobal.bannerImgBase + e['ori_media_url'],
          'type': 1,
          'w': e['thumb_width'],
          'h': e['thumb_height'],
        };
      }).toList();
    } else {
      print('发布');
    }
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
  }

  static TextStyle titleStyle = TextStyle(
      fontSize: 14.sp, fontWeight: FontWeight.w700, color: Color(0xff6d6d6d));
  static TextStyle subtitleStyle = TextStyle(
      fontSize: 12.sp, fontWeight: FontWeight.w400, color: Color(0xff979797));
  static TextStyle btnStyle = TextStyle(
      fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white);
  Widget tapBtn(String text, {bool status = true}) {
    return Container(
      height: 30.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient: status
              ? DefaultStyle.defaluGrandientLine
              : DefaultStyle.whiteGrandientLine,
          borderRadius: BorderRadius.circular(50.w)),
      child: Text(
        text,
        style: status
            ? btnStyle
            : TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xffFF84A9)),
      ),
    );
  }

  showQuanzi() {
    String tags = topics[0]['topic_name_formate'];
    YyShowDialog.showdialog(context,
        title: '选择圈子', btnText: '确定', cancelText: '取消', callBack: () {
      selectText = tags;
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
                  selectId = topics[index]['topic_id'];
                  tags = topics[index]['topic_name_formate'];
                  setDialogState(() {});
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.w),
                      color: selectId == topics[index]['topic_id']
                          ? Color(0xffFF84A9)
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: selectId == topics[index]['topic_id']
                                ? Color(0xffA82118).withOpacity(0.26)
                                : Color(0xffFFD3E6),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0)
                      ]),
                  child: Text(
                    topics[index]['topic_name'],
                    style: TextStyle(
                        color: selectId == topics[index]['topic_id']
                            ? Colors.white
                            : Color(0xff828181),
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
                child: ListView(
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
                  onTap: showQuanzi,
                  child: SizedBox(
                    height: 36.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectText ?? '#選擇圈子',
                          style: TextStyle(
                              color: Color(0xff6d6d6d),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400),
                        ),
                        getImage('assets/images/2023/setup_right.png',
                            width: 16.w, height: 16.w, isAssets: true)
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.w),
                  child: Column(
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
                          GestureDetector(
                              onTap: videoPickerAssets, child: tapBtn('新增影片'))
                        ],
                      ),
                      ValueListenableBuilder(
                          valueListenable: videoList,
                          builder: (context, List videos, child) {
                            return videos.isEmpty
                                ? Container()
                                : GridView.builder(
                                    itemCount: videos.length,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.5.w, vertical: 10.w),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 4.w,
                                      crossAxisSpacing: 4.w,
                                      childAspectRatio: 120 / 80,
                                    ),
                                    itemBuilder: (context, index) {
                                      return mediaItem(
                                          child: getImage(
                                              'assets/images/2023/upload_video_bg.png',
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              isAssets: true),
                                          onClose: () {
                                            List _videos = videoList.value;
                                            _videos.removeAt(index);
                                            imageList.value = [..._videos];
                                          });
                                    });
                          })
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.w),
                  child: Column(
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
                                : GridView.builder(
                                    itemCount: imgs.length,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.5.w, vertical: 10.w),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 4.w,
                                      crossAxisSpacing: 4.w,
                                      childAspectRatio: 120 / 80,
                                    ),
                                    itemBuilder: (context, index) {
                                      return mediaItem(
                                          child: PlatformAwareNetworkImage(
                                            url: imgs[index]['cover'],
                                            fit: BoxFit.cover,
                                          ),
                                          onClose: () {
                                            List _images = imageList.value;
                                            _images.removeAt(index);
                                            imageList.value = [..._images];
                                          });
                                    });
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
                        hintStyle: TextStyle(
                            fontSize: 14.sp, color: Color(0xffc2c2c2)),
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
                    keyboardType:TextInputType.multiline,
                    decoration: InputDecoration(
                        isDense: true,
                        helperMaxLines: 66,
                        hintText: '請輸入文字...',
                        hintStyle: TextStyle(
                            fontSize: 14.sp, color: Color(0xffc2c2c2)),
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
                            '最高設置90皮哩幣',
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
                              child: tapBtn(value ? '關閉' : '開啟',
                                  status: !showCoinInput.value),
                            );
                          })
                    ],
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: showCoinInput,
                  builder: (context, value, child) {
                    return value ? child : Container();
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
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: InputDecoration(
                          isDense: true,
                          counterText: '',
                          hintText: '請輸入金額',
                          hintStyle: TextStyle(
                              fontSize: 14.sp, color: Color(0xffc2c2c2)),
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
                    onTap: publishPost,
                    child: Container(
                      width: 327.w,
                      height: 40.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.w),
                          gradient: DefaultStyle.defaluGrandientLine),
                      child: Text(
                        '立即發布',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700),
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
