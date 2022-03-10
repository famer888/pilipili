import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_html/html.dart' as html;
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
      dataList = result['data']['office_contact']['data'];
      result['data']['download_link'].forEach((item) {
        downloadLink[item['name']] = item['value'];
      });
      isLoading = false;
      setState(() {});
    } else {
      context.pop();
      CommonUtils.showText('返回数据为空,请稍后再试～');
    }
  }

  Widget _contactItem({Map itemData}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${itemData['name']}',
          style: DefaultStyle.black16bold,
        ),
        SizedBox(
          height: ScreenUtil().setWidth(8),
        ),
        Text('${itemData['decs']}', style: TextStyle(color: Color(0xff6D6D6D))),
        Container(
          margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(11.5),
              bottom: ScreenUtil().setWidth(20)),
          padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12))),
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

  @override
  Widget build(BuildContext context) {
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
                      horizontal: DefaultStyle.pagePadding,
                      vertical: ScreenUtil().setWidth(30)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: dataList
                        .asMap()
                        .keys
                        .map(
                          (e) => _contactItem(itemData: dataList[e]),
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
  Widget appItem({String type, String href, String text}) {
    return Column(
      children: [
        PlatformAwareAssetImage(
          url: 'assets/images/mine/icon_$type.png',
          width: ScreenUtil().setWidth(38.8),
          height: ScreenUtil().setWidth(38.8),
        ),
        GestureDetector(
          onTap: () {
            CommonUtils.launchURL(href);
          },
          child: Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(14)),
            width: ScreenUtil().setWidth(83),
            height: ScreenUtil().setWidth(18.5),
            decoration: BoxDecoration(
                gradient: DefaultStyle.defaluGrandientLine,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(50))),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                    color: Colors.white, fontSize: ScreenUtil().setSp(12)),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
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
                    PlatformAwareAssetImage(
                      url: info['type'] == 'Telegram'
                          ? 'assets/images/mine/icon_tg.png'
                          : 'assets/images/mine/icon_pt.png',
                      width: ScreenUtil().setWidth(38.8),
                      height: ScreenUtil().setWidth(38.8),
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(13),
                    ),
                    Flexible(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${info['name']}',
                          style: DefaultStyle.black13bold,
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(5),
                        ),
                        Text(
                          '${info['decs']}',
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
                    height: ScreenUtil().setWidth(30),
                    width: ScreenUtil().setWidth(65),
                    decoration: BoxDecoration(
                        color: Color(0xff4d85f4),
                        gradient: DefaultStyle.defaluGrandientLine,
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().setWidth(50))),
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
                          height: ScreenUtil().setWidth(300),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '国内下载使用TG或登录TG官网均需要使用VPN，请先下载免费的蚂蚁VPN，开启VPN后再下载TG或访问TG官网',
                                  style: TextStyle(
                                      height: 1.5,
                                      color: Color(0xff979797),
                                      fontSize: ScreenUtil().setSp(14)),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: ScreenUtil().setWidth(30)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      appItem(
                                          href: downloadLink['antDownload'],
                                          type: 'my',
                                          text: '下载免费VPN'),
                                      appItem(
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
                                      fontSize: ScreenUtil().setSp(14)),
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
                                      fontSize: ScreenUtil().setSp(14)),
                                )
                              ],
                            ),
                          ),
                        );
                      }, btnText: '确定');
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setWidth(10),
                          left: ScreenUtil().setWidth(52)),
                      child: Text(
                        'TG群打不开?看这里',
                        style: TextStyle(
                            color: Color(0xff7bf7ff),
                            decoration: TextDecoration.underline,
                            fontSize: ScreenUtil().setSp(12)),
                      ),
                    ),
                  )
                : Container()
          ],
        ));
  }
}
