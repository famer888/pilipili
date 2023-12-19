import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/utils/pp_asset_path.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:pilipili/components/page_status.dart';
import 'package:pilipili/components/yy_dialog.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class ContactOfficial extends StatefulWidget {
  ContactOfficial({Key key}) : super(key: key);

  @override
  _ContactOfficialState createState() => _ContactOfficialState();
}

class _ContactOfficialState extends State<ContactOfficial> {
  List dataList = [];
  bool isLoading = true;
  Map downloadLink = {};
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    var result = await getContactList();
    if (result != null && result['data'] != null) {
      CommonUtils.debugPrint(result['data']);
      if (result['data']['download_link'] == null &&
          result['data']['office_contact'] == null) {
        context.pop();
        CommonUtils.showText('返回数据为空,请稍后再试～');
      } else {
        if (result['data']['office_contact'] != null) {
          dataList = result['data']['office_contact']['data'];
        }
        if (result['data']['download_link'] != null) {
          result['data']['download_link'].forEach((item) {
            downloadLink[item['name']] = item['value'];
          });
          isLoading = false;
          setState(() {});
        }
      }
    } else {
      context.pop();
      CommonUtils.showText('返回数据为空,请稍后再试～');
    }
  }

  @override
  Widget build(BuildContext context) {
    CommonUtils.debugPrint(downloadLink);
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleBar(title: '联系官方', paddingTop: ScreenUtil().statusBarHeight),
        Expanded(
          child: isLoading
              ? PageStatus.loading(mounted)
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: DefaultStyle.pagePadding, vertical: 30.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: dataList
                        .asMap()
                        .keys
                        .map(
                          (e) => ContactItem(
                            itemData: dataList[e],
                            downloadLink: downloadLink,
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
      ],
    ));
  }
}

class AppInfo extends StatelessWidget {
  final Map info;
  final Map downloadLink;
  const AppInfo({Key key, this.info, this.downloadLink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    getImage(
                        info['type'] == 'Telegram'
                            ? PPAssetsPath.iconTG
                            : PPAssetsPath.iconPT,
                        width: 38.8.w,
                        height: 38.8.w,
                        isAssets: true),
                    SizedBox(
                      width: 13.w,
                    ),
                    Flexible(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          info['name'].toString(),
                          style: DefaultStyle.black13bold,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Text(
                          info['decs'].toString(),
                          style: DefaultStyle.lgray12,
                        ),
                      ],
                    ))
                  ],
                )),
                GestureDetector(
                  onTap: () {
                    CommonUtils.launchURL(info['url']);
                  },
                  child: Container(
                    height: 30.w,
                    width: 65.w,
                    decoration: BoxDecoration(
                        color: Color(0xff4d85f4),
                        gradient: DefaultStyle.defaluGrandientLine,
                        borderRadius: BorderRadius.circular(50.w)),
                    child: Center(
                      child: Text(
                        '立即加入',
                        style: DefaultStyle.white12,
                      ),
                    ),
                  ),
                )
              ],
            ),
            info['type'] == 'Telegram'
                ? GestureDetector(
                    onTap: () {
                      YyShowDialog.showdialog(context, title: '无法加入TG社群解决方法',
                          content: (setDialogState) {
                        return Container(
                          height: 300.w,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '国内下载使用TG或登录TG官网均需要使用VPN，请先下载免费的蚂蚁VPN，开启VPN后再下载TG或访问TG官网',
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Color(0xff979797),
                                      fontSize: 14.sp),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 30.w),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      AppItem(
                                          href: downloadLink['antDownload'],
                                          type: 'my',
                                          text: '下载免费VPN'),
                                      AppItem(
                                          href: downloadLink['tgDownload'],
                                          type: 'tg',
                                          text: '下载TG'),
                                    ],
                                  ),
                                ),
                                Text(
                                  '无法加入TG群时，请按照以下步骤操作：\n打开TG网页版并登陆：',
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Color(0xff979797),
                                      fontSize: 14.sp),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    CommonUtils.launchURL(
                                        'https://web.telegram.org/');
                                  },
                                  child: Text(
                                    'https://web.telegram.org/',
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        height: 1.5,
                                        color: Color(0xff979797),
                                        fontSize: ScreenUtil().setSp(14)),
                                  ),
                                ),
                                Text(
                                  '1.点击「Settings/设置」\n2.点击「Privacy and Security/隐私和安全」\n3.点击「Sensitive content/敏感内容」\n4.打开「Disable filtering/停止过滤」选项\n5.重启TG，即可加入TG社群',
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Color(0xff979797),
                                      fontSize: 14.sp),
                                )
                              ],
                            ),
                          ),
                        );
                      }, btnText: '确定');
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10.w, left: 52.w),
                      child: Text(
                        'TG群打不开?看这里',
                        style: TextStyle(
                            color: DefaultStyle.themeColor,
                            decoration: TextDecoration.underline,
                            fontSize: 12.sp),
                      ),
                    ),
                  )
                : Container()
          ],
        ));
  }
}

class ContactItem extends StatelessWidget {
  const ContactItem({Key key, this.itemData, this.downloadLink})
      : super(key: key);
  final Map itemData;
  final Map downloadLink;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          itemData['name'].toString(),
          style: DefaultStyle.black16bold,
        ),
        SizedBox(
          height: 8.w,
        ),
        Text(itemData['decs'].toString(),
            style: TextStyle(color: Color(0xff6D6D6D))),
        Container(
          margin: EdgeInsets.only(top: 11.5.w, bottom: 20.w),
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12.w)),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: itemData['list']
                .map<Widget>((value) => AppInfo(
                      downloadLink: downloadLink,
                      info: value,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class AppItem extends StatelessWidget {
  const AppItem({Key key, this.type, this.href, this.text}) : super(key: key);
  final String type;
  final String href;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getImage('assets/images/2023/icon_' + type.toString() + '.png',
            width: 38.8.w, height: 38.8.w, isAssets: true),
        Container(
          margin: EdgeInsets.only(top: 14.w),
          width: 83.w,
          height: 18.5.w,
          decoration: BoxDecoration(
              gradient: DefaultStyle.defaluGrandientLine,
              borderRadius: BorderRadius.circular(50.w)),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.transparent, shadowColor: Colors.transparent),
            onPressed: () {
              CommonUtils.launchURL(href);
            },
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
        ),
      ],
    );
  }
}
