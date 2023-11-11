import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/pages/community/xfile_progress_toast.dart';
import 'package:pilipili/theme/default.dart';
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
  String coin = '';
  String title = '';
  String content = '';
  ValueNotifier<List> imageList = ValueNotifier([]);
  ValueNotifier<List> videoList = ValueNotifier([]);
  final ImagePicker _picker = ImagePicker();
  int maxLength = 10;
  int selectIndex = 0;
//选择视频
  Future<void> videoPickerAssets() async {
    if (imageList.value.length >= maxLength) {
      CommonUtils.showText('最多上传$maxLength张图片');
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
              {
                'media_url': orgURL,
                'cover': '',
                'type': 2,
              }
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

  @override
  void initState() {
    super.initState();
    if (AppGlobal.postInfo.isNotEmpty) {
      print('编辑');
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
  }

  static TextStyle titleStyle = TextStyle(
      fontSize: 14.sp, fontWeight: FontWeight.w700, color: Color(0xff6d6d6d));
  static TextStyle subtitleStyle = TextStyle(
      fontSize: 12.sp, fontWeight: FontWeight.w400, color: Color(0xff979797));
  static TextStyle btnStyle = TextStyle(
      fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white);
  Widget tapBtn(String text) {
    return Container(
      height: 30.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient: DefaultStyle.defaluGrandientLine,
          borderRadius: BorderRadius.circular(50.w)),
      child: Text(
        text,
        style: btnStyle,
      ),
    );
  }

  showQuanzi() {
    YyShowDialog.showdialog(context,
        title: '选择圈子',
        btnText: '确定',
        cancelText: '取消',
        callBack: () {}, content: (setDialogState) {
      return GridView.builder(
          itemCount: 6,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4.w,
            crossAxisSpacing: 4.w,
            childAspectRatio: 83 / 36,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: (){
                selectIndex=index;
                setDialogState((){});
              },
              child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.w),
                  color:
                      selectIndex == index ? Color(0xffFF84A9) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: selectIndex == index
                            ? Color(0xffA82118).withOpacity(0.26)
                            : Color(0xffFFD3E6),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0)
                  ]),
              child: Text(
                '破處回憶',
                style: TextStyle(
                    color:
                        selectIndex == index ? Colors.white : Color(0xff828181),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700),
              ),
            ),
            );
          });
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
                          '#選擇圈子',
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
                                    '0/10',
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
                                          child: PlatformAwareNetworkImage(
                                            url: videos[index]['cover'],
                                            fit: BoxFit.cover,
                                          ),
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
                                    '0/10',
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
                    onChanged: (value) {
                      title = value;
                    },
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
                    onChanged: (value) {
                      content = value;
                    },
                    cursorColor: Color(0xffFF84A9),
                    textInputAction: TextInputAction.done,
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
                                coin = '';
                              },
                              child: tapBtn(value ? '關閉' : '開啟'),
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
                      onChanged: (value) {
                        coin = value;
                      },
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
                    onTap: () {},
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
