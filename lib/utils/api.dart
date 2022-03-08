//获取精选顶部导航
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/model/animationDetail.dart';
import 'package:pilipili/model/basic.dart';
import 'package:pilipili/model/comicReading.dart';
import 'package:pilipili/model/comicsDetail.dart';
import 'package:pilipili/model/construct.dart';
import 'package:pilipili/model/element.dart';
import 'package:pilipili/model/homedata.dart';
import 'package:pilipili/model/recommendComics.dart';
import 'package:pilipili/model/userinfo.dart';
import 'package:pilipili/store/homeConfig.dart';
import 'package:pilipili/utils/common.dart';
import 'package:provider/provider.dart';

import 'http.dart';

//获取全局config接口
Future<HomeData> getHomeConfig(BuildContext context) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post('/api/home/config');
    Response<dynamic> res2 =
        await PlatformAwareHttp.post('/api/privilege/getUserPrivilege');
    if (res.data['data']['help'] != null) {
      AppGlobal.helpList.clear();
      var help = res.data['data']['help'];
      help.forEach((element) {
        for (var item in element['items']) {
          var problem = {
            'problem': item['question'],
            'reply': item['answer'],
          };
          AppGlobal.helpList.add(problem);
        }
      });
    }
    AppGlobal.shouApp = res.data['data']['showApp'] == 1;
    HomeData result = HomeData.fromJson(res.data);
    if (result.status != 0) {
      Provider.of<HomeConfig>(context, listen: false)
          .setMember(result.data.member);
      Provider.of<HomeConfig>(context, listen: false)
          .setNotice(result.data.notice);
      Provider.of<HomeConfig>(context, listen: false).setAbs(result.data.ads);
      Provider.of<HomeConfig>(context, listen: false)
          .setConfig(result.data.config);
      Provider.of<HomeConfig>(context, listen: false)
          .setVersionMsg(result.data.versionMsg);
      AppGlobal.vipLevel = result.data.member.vipLevel;
      AppGlobal.bannerImgBase = result.data.config.imgBase;
      CommonUtils.debugPrint('============AppGlobal.bannerImgBase===========');
      CommonUtils.debugPrint(AppGlobal.bannerImgBase);
      AppGlobal.uploadImgKey = result.data.config.uploadImgKey;
      AppGlobal.uploadImgUrl = result.data.config.imgUploadUrl;
      AppGlobal.m3u8_encrypt = result.data.config.m3u8_encrypt;
    }
    if (res2.data != null) {
      Provider.of<HomeConfig>(context, listen: false).setPrivilege(res2.data);
    }
    return result;
  } catch (e) {
    return null;
  }
}

Future<ElementModel> getFisrtTopNavConfig() async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/element/getElementById',
        data: {'id': 7});
    ElementModel result = ElementModel.fromJson(res.data['data']);
    return result;
  } catch (e) {
    return null;
  }
}

//获取精选某个栏目的元容元素
Future<ConstructModel> getConstructById({int id, int page, int limit}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/element/getConstructById',
        data: {'id': id, 'page': page, 'limit': limit});
    if (res.data['status'] == 0) {
      CommonUtils.showText(res.data['msg']);
    }
    ConstructModel result = ConstructModel.fromJson(res.data['data']);
    CommonUtils.debugPrint(result.toJson());
    return result;
  } catch (e) {
    return null;
  }
}

//获取某个栏目的内容元素
Future<dynamic> getElementById({int id, int page, int limit}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/element/getElementById',
        data: {'id': id, 'page': page, 'limit': limit});
    dynamic result = res.data;
    return result;
  } catch (e) {
    return null;
  }
}

//获取视频详情
Future<AnimationDetail> getVideoDetail({dynamic id}) async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/mv/getDetail', data: {'id': id});
    AnimationDetail result = AnimationDetail.fromJson(res.data);
    CommonUtils.debugPrint(result.toJson());
    return result;
  } catch (e) {
    return null;
  }
}

// 评论列表
Future getCommentList(
    {int page, int limit, int contentId, int contentType}) async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/comment/index', data: {
      'page': page,
      'limit': limit,
      'content_id': contentId,
      'content_type': contentType
    });
    return res.data;
  } catch (e) {
    return null;
  }
}

// 视频详情推荐视频
Future getDetailRecommendList(
    {int id, String tags, int limit, int page}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/mv/getDetailRecommendList',
        data: {'page': page, 'limit': limit, 'tags': tags, 'id': id});
    return res.data;
  } catch (e) {
    return null;
  }
}

//用户收藏   type: 1 mv  2 book 3 story 4 link 5 soundBook 6pic
Future<Basic> userFavorites({int type, int, id}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post('/api/user/favorites',
        data: {'type': type, 'relatedId': id});
    return Basic.fromJson(res.data);
  } catch (e) {
    return null;
  }
}

Future getDownloadUrl({int id}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/privilege/download',
        data: {'id': id});
    return res.data;
  } catch (e) {
    return null;
  }
}

//购买视频
Future<Basic> buyVideo({int id, int coins, BuildContext context}) async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/mv/buy', data: {'id': id});
    Basic data = Basic.fromJson(res.data);
    if (data.status != 0) {
      HomeConfig.setUserCoins(context, coins);
    }
    return data;
  } catch (e) {
    return null;
  }
}

// 发表评论
Future publishComment(
    {int commentId, String reply, int contentId, int contentType}) async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/comment/comment', data: {
      'comment_id': commentId,
      'reply': reply,
      'content_id': contentId,
      'content_type': contentType
    });
    return res.data;
  } catch (e) {
    return null;
  }
}

// 二级列表
Future getElementByIdSecondPage({int id, int page, int limit}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/element/getElementByIdSecondPage',
        data: {'id': id, 'page': page, 'limit': limit});
    return res.data;
  } catch (e) {
    return null;
  }
}

//漫画阅读
Future<ComicReading> getComicReading({int id, int episode}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post("/api/book/read",
        data: {'bookId': id, 'episode': episode});
    return ComicReading.fromJson(res.data);
  } catch (e) {
    return null;
  }
}

//详情页推荐漫画
Future<RecommendComics> getRecommendComicsList(
    {int limit = 5, int page = 1, String category = '', int id}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        "/api/book/getDetailRecommendList",
        data: {'limit': limit, 'page': page, 'category': category, 'id': id});
    return RecommendComics.fromJson(res.data);
  } catch (e) {
    return null;
  }
}

//漫画详情
Future<ComicDetail> getComicDetail({int id}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post("/api/book/getDetail",
        data: {'bookId': id});
    CommonUtils.debugPrint(res.data);
    return ComicDetail.fromJson(res.data);
  } catch (e) {
    return null;
  }
}

//验证手机号
Future<Basic> validatePhone({String phone, String phonePrefix}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/account/validatePhone',
        data: {'phone': phone, 'phonePrefix': phonePrefix});
    Basic result = Basic.fromJson(res.data);
    return result;
  } catch (e) {
    return null;
  }
}

//验证用户名
Future<Basic> validateUsername({String username}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/account/validateUsername',
        data: {'username': username});
    Basic result = Basic.fromJson(res.data);
    return result;
  } catch (e) {
    return null;
  }
}

//发送验证码
Future<Basic> sendPhone({String phone, String phonePrefix, int type}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post('/api/home/send',
        data: {'phone': phone, 'phonePrefix': phonePrefix, 'type': type});
    Basic result = Basic.fromJson(res.data);
    return result;
  } catch (e) {
    return null;
  }
}

//手机注册
Future<Basic> registerByPhone(
    {String phone, String phonePrefix, String code, String invitedAff}) async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/account/registerByPhone', data: {
      'phone': phone,
      'phonePrefix': phonePrefix,
      'code': code,
      'invitedAff': invitedAff
    });
    Basic result = Basic.fromJson(res.data);
    return result;
  } catch (e) {
    return null;
  }
}

//用户名注册
Future<Basic> registerByPassword(
    {String username,
    String password,
    String confirmPwd,
    String invitedAff}) async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/account/registerByPassword', data: {
      'username': username,
      'password': password,
      'confirm_pwd': confirmPwd,
      'invitedAff': invitedAff
    });
    Basic result = Basic.fromJson(res.data);
    return result;
  } catch (e) {
    return null;
  }
}

//手机登录
Future<Basic> loginByPhone(
    {String phone, String phonePrefix, String code}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/account/loginByPhone',
        data: {'phone': phone, 'phonePrefix': phonePrefix, 'code': code});
    Basic result = Basic.fromJson(res.data);
    return result;
  } catch (e) {
    return null;
  }
}

//用户名登录
Future<Basic> loginByPassword({String username, String password}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/account/loginByPassword',
        data: {'username': username, 'password': password});
    Basic result = Basic.fromJson(res.data);
    return result;
  } catch (e) {
    return null;
  }
}

//忘记密码
Future<Basic> forgetPassword(
    {String username,
    String phone,
    String phonePrefix,
    String code,
    String password,
    String passwordConfirm}) async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/account/forgetPassword', data: {
      'username': username,
      'phone': phone,
      'phonePrefix': phonePrefix,
      'code': code,
      'password': password,
      'passwordConfirm': passwordConfirm
    });
    Basic result = Basic.fromJson(res.data);
    return result;
  } catch (e) {
    return null;
  }
}

// 活动列表
Future getActivityList() async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/page/list', data: {});
    return res.data;
  } catch (e) {
    return null;
  }
}

// 活动详情
Future getActivityDetail(id) async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/page/detail', data: {'id': id});
    return res.data;
  } catch (e) {
    return null;
  }
}

//修改用户头像或昵称
Future<Basic> updateUserInfo({String nickname, String thumb}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/user/updateUserInfo',
        data: {'nickname': nickname, 'thumb': thumb});
    return Basic.fromJson(res.data);
  } catch (e) {
    return null;
  }
}

//填写邀请码
Future<Basic> toInvitation({String affCode}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post('/api/user/invitation',
        data: {'aff_code': affCode});
    return Basic.fromJson(res.data);
  } catch (e) {
    return null;
  }
}

//获取获取用户信息
Future<UserInfo> getUserInfo(BuildContext context) async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/user/userInfo', data: {});
    UserInfo data = UserInfo.fromJson(res.data);
    HomeConfig.setUserCoins(context, data.data.money);
    return data;
  } catch (e) {
    return null;
  }
}

//兑换
Future<Basic> onExchange({String cdk}) async {
  try {
    Response<dynamic> res =
        await PlatformAwareHttp.post('/api/home/exchange', data: {'cdk': cdk});
    return Basic.fromJson(res.data);
  } catch (e) {
    return null;
  }
}
