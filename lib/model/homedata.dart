// To parse this JSON data, do
//
//     final homeData = homeDataFromJson(jsonString);

import 'dart:convert';

HomeData homeDataFromJson(String str) => HomeData.fromJson(json.decode(str));

String homeDataToJson(HomeData data) => json.encode(data.toJson());

class HomeData {
  HomeData({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
    this.line,
  });

  Data data;
  int status;
  String msg;
  bool crypt;
  bool isVip;
  String line;

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
        line: json["line"] == null ? null : json["line"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : data.toJson(),
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
        "line": line == null ? null : line,
      };
}

class Data {
  Data(
      {this.versionMsg,
      this.timestamp,
      this.config,
      this.notice,
      this.ads,
      this.member,
      this.darkPrivilege,
      this.darkprivilegeTips,
      this.allowPublishPost,
      this.noPermissionPublishPostTips,
      this.click_app_id,
      this.click_transit_path,
      this.buryPoint,
      this.maintainTipsStr});

  VersionMsg versionMsg;
  int timestamp;
  Notice notice;
  Config config;
  Ads ads;
  Member member;
  bool darkPrivilege;
  String darkprivilegeTips;
  int allowPublishPost;
  String noPermissionPublishPostTips;
  String click_app_id;
  String click_transit_path;
  ReportConfig buryPoint;
  String maintainTipsStr;
  factory Data.fromJson(Map<String, dynamic> json) => Data(
      versionMsg: json["versionMsg"] == null ? null : VersionMsg.fromJson(json["versionMsg"]),
      notice: json["notice"] == null ? null : Notice.fromJson(json["notice"]),
      timestamp: json["timestamp"] == null ? null : json["timestamp"],
      config: json["config"] == null ? null : Config.fromJson(json["config"]),
      ads: json["ads"] == null ? null : Ads.fromJson(json["ads"]),
      member: json["member"] == null ? null : Member.fromJson(json["member"]),
      darkPrivilege: json["dark_privilege"] ?? false,
      darkprivilegeTips: json["dark_privilege_tips"] ?? '',
      allowPublishPost: int.parse(json["allow_publish_post"] ?? '0'),
      noPermissionPublishPostTips: json["no_permission_publish_post_tips"] ?? '',
      click_app_id: json["click_app_id"],
      click_transit_path: json["click_transit_path"],
      buryPoint: ReportConfig.fromJson(json['bury_point']),
      maintainTipsStr: json["maintain_tips_str"] ?? "");

  Map<String, dynamic> toJson() => {
        "versionMsg": versionMsg == null ? null : versionMsg.toJson(),
        "timestamp": timestamp == null ? null : timestamp,
        "notice": notice == null ? null : notice.toJson(),
        "config": config == null ? null : config.toJson(),
        "ads": ads == null ? null : ads.toJson(),
        "member": member == null ? null : member.toJson(),
        "dark_privilege": darkPrivilege ?? false,
        "dark_privilege_tips": darkprivilegeTips ?? false,
        "allow_publish_post": allowPublishPost ?? 0,
        "no_permission_publish_post_tips": noPermissionPublishPostTips ?? '',
        "click_app_id": click_app_id,
        "click_transit_path": click_transit_path,
        "bury_point": buryPoint,
        "maintain_tips_str": maintainTipsStr
      };
}

class Ads {
  Ads({
    this.id,
    this.title,
    this.description,
    this.imgUrl,
    this.url,
    this.position,
    this.androidDownUrl,
    this.iosDownUrl,
    this.type,
    this.status,
    this.oauthType,
    this.mvM3U8,
    this.channel,
    this.createdAt,
  });

  int id;
  String title;
  String description;
  String imgUrl;
  String url;
  int position;
  String androidDownUrl;
  String iosDownUrl;
  int type;
  int status;
  int oauthType;
  String mvM3U8;
  String channel;
  String createdAt;

  factory Ads.fromJson(Map<String, dynamic> json) => Ads(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        imgUrl: json["img_url"],
        url: json["url"],
        position: json["position"],
        androidDownUrl: json["android_down_url"],
        iosDownUrl: json["ios_down_url"],
        type: json["type"],
        status: json["status"],
        oauthType: json["oauth_type"],
        mvM3U8: json["mv_m3u8"],
        channel: json["channel"],
        createdAt: json["created_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "img_url": imgUrl,
        "url": url,
        "position": position,
        "android_down_url": androidDownUrl,
        "ios_down_url": iosDownUrl,
        "type": type,
        "status": status,
        "oauth_type": oauthType,
        "mv_m3u8": mvM3U8,
        "channel": channel,
        "created_at": createdAt,
      };
}

class Config {
  Config(
      {this.imgUploadUrl,
      this.mp4UploadUrl,
      this.mobileMp4UploadUrl,
      this.uploadImgKey,
      this.uploadMp4Key,
      this.uuid,
      this.github,
      this.officeSite,
      this.officialGroup,
      this.share,
      this.imgBase,
      this.line,
      this.m3u8_encrypt,
      this.video_encrypt_api,
      this.video_encrypt_referer,
      this.video_encrypt_m3u8,
      this.withdraw_rate,
      this.withdraw_ratio,
      this.withdraw_rule,
      this.tgLink});

  String imgUploadUrl;
  String mp4UploadUrl;
  String mobileMp4UploadUrl;
  String uploadImgKey;
  String uploadMp4Key;
  String uuid;
  String github;
  String officeSite;
  String officialGroup;
  Share share;
  String imgBase;
  List<dynamic> line;
  String m3u8_encrypt;
  String video_encrypt_api;
  String video_encrypt_referer;
  String video_encrypt_m3u8;
  int withdraw_rate;
  int withdraw_ratio;
  String withdraw_rule;
  String tgLink;

  factory Config.fromJson(Map<String, dynamic> json) => Config(
      imgUploadUrl: json["img_upload_url"] == null ? null : json["img_upload_url"],
      mp4UploadUrl: json["mp4_upload_url"] == null ? null : json["mp4_upload_url"],
      mobileMp4UploadUrl: json["mobile_mp4_upload_url"] == null ? null : json["mobile_mp4_upload_url"],
      uploadImgKey: json["upload_img_key"] == null ? null : json["upload_img_key"],
      uploadMp4Key: json["upload_mp4_key"] == null ? null : json["upload_mp4_key"],
      uuid: json["uuid"] == null ? null : json["uuid"],
      github: json["github"] == null ? null : json["github"],
      officeSite: json["office_site"] == null ? null : json["office_site"],
      officialGroup: json["official_group"] == null ? null : json["official_group"],
      share: json["share"] == null ? null : Share.fromJson(json["share"]),
      imgBase: json["img_base"] == null ? null : json["img_base"],
      line: json["line"] == null ? null : List<dynamic>.from(json["line"].map((x) => x)),
      m3u8_encrypt: json['m3u8_encrypt'] == null ? null : json['m3u8_encrypt'].toString(),
      video_encrypt_api: json["video_encrypt_api"] == null ? null : json["video_encrypt_api"],
      video_encrypt_referer: json["video_encrypt_referer"] == null ? null : json["video_encrypt_referer"],
      video_encrypt_m3u8: json["video_encrypt_m3u8"] == null ? null : json["video_encrypt_m3u8"],
      withdraw_rate: json['withdraw_rate'] ?? 0,
      withdraw_ratio: json['withdraw_ratio'] ?? 0,
      withdraw_rule: json['withdraw_rule'] ?? 0,
      tgLink: json['tg_link'] ?? '');

  Map<String, dynamic> toJson() => {
        "img_upload_url": imgUploadUrl == null ? null : imgUploadUrl,
        "mp4_upload_url": mp4UploadUrl == null ? null : mp4UploadUrl,
        "mobile_mp4_upload_url": mobileMp4UploadUrl == null ? null : mobileMp4UploadUrl,
        "upload_img_key": uploadImgKey == null ? null : uploadImgKey,
        "upload_mp4_key": uploadMp4Key == null ? null : uploadMp4Key,
        "uuid": uuid == null ? null : uuid,
        "github": github == null ? null : github,
        "office_site": officeSite == null ? null : officeSite,
        "official_group": officialGroup == null ? null : officialGroup,
        "share": share == null ? null : share.toJson(),
        "img_base": imgBase == null ? null : imgBase,
        "line": line == null ? null : List<dynamic>.from(line.map((x) => x)),
        "m3u8_encrypt": m3u8_encrypt == null ? null : m3u8_encrypt,
        "video_encrypt_api": video_encrypt_api == null ? null : video_encrypt_api,
        "video_encrypt_referer": video_encrypt_referer == null ? null : video_encrypt_referer,
        "video_encrypt_m3u8": video_encrypt_m3u8 == null ? null : video_encrypt_m3u8,
        "withdraw_rate": withdraw_rate ?? 0,
        "withdraw_ratio": withdraw_ratio ?? 0,
        "withdraw_rule": withdraw_rule ?? '',
        "tg_link": tgLink ?? ''
      };
}

class Share {
  Share({
    this.affUrlCopy,
    this.affCode,
    this.affUrl,
  });

  AffUrlCopy affUrlCopy;
  String affCode;
  String affUrl;

  factory Share.fromJson(Map<String, dynamic> json) => Share(
        affUrlCopy: json["aff_url_copy"] == null ? null : AffUrlCopy.fromJson(json["aff_url_copy"]),
        affCode: json["aff_code"] == null ? null : json["aff_code"],
        affUrl: json["aff_url"] == null ? null : json["aff_url"],
      );

  Map<String, dynamic> toJson() => {
        "aff_url_copy": affUrlCopy == null ? null : affUrlCopy.toJson(),
        "aff_code": affCode == null ? null : affCode,
        "aff_url": affUrl == null ? null : affUrl,
      };
}

class AffUrlCopy {
  AffUrlCopy({
    this.code,
    this.url,
  });

  String code;
  String url;

  factory AffUrlCopy.fromJson(Map<String, dynamic> json) => AffUrlCopy(
        code: json["code"] == null ? null : json["code"],
        url: json["url"] == null ? null : json["url"],
      );

  Map<String, dynamic> toJson() => {
        "code": code == null ? null : code,
        "url": url == null ? null : url,
      };
}

class Member {
  Member({
    this.uid,
    this.uuid,
    this.username,
    this.createdAt,
    this.updatedAt,
    this.roleId,
    this.gender,
    this.regip,
    this.regdate,
    this.lastip,
    this.lastvisit,
    this.expiredAt,
    this.lastpost,
    this.oltime,
    this.pageviews,
    this.score,
    this.aff,
    this.channel,
    this.invitedBy,
    this.invitedNum,
    this.banPost,
    this.postNum,
    this.loginCount,
    this.appVersion,
    this.validate,
    this.share,
    this.isLogin,
    this.nickname,
    this.thumb,
    this.coins,
    this.money,
    this.tempVip,
    this.followedCount,
    this.videosCount,
    this.fabulousCount,
    this.likesCount,
    this.commentCount,
    this.vipLevel,
    this.personSignnatrue,
    this.oldVip,
    this.stature,
    this.interest,
    this.city,
    this.usedMoneyFreeNum,
    this.agentFee,
    this.agent,
    this.buildId,
    this.authStatus,
    this.exp,
    this.isVirtual,
    this.chatUid,
    this.phone,
    this.phonePrefix,
    this.freeViewCnt,
    this.lastactivity,
    this.thumbStr,
    this.oauthStr,
    this.isSetPassword,
    this.level, // 该字段已用于显示有效卡数量
  });

  int uid;
  String uuid;
  String username;
  String createdAt;
  String updatedAt;
  int roleId;
  int gender;
  String regip;
  String regdate;
  String lastip;
  String lastvisit;
  dynamic expiredAt;
  int lastpost;
  int oltime;
  int pageviews;
  int score;
  String aff;
  String channel;
  dynamic invitedBy;
  int invitedNum;
  int banPost;
  int postNum;
  int loginCount;
  String appVersion;
  int validate;
  int share;
  int isLogin;
  String nickname;
  String thumb;
  int coins;
  int money;
  int tempVip;
  int followedCount;
  int videosCount;
  int fabulousCount;
  int likesCount;
  int commentCount;
  int vipLevel;
  String personSignnatrue;
  int oldVip;
  int stature;
  String interest;
  String city;
  int usedMoneyFreeNum;
  int agentFee;
  int agent;
  int buildId;
  int authStatus;
  int exp;
  String isVirtual;
  String chatUid;
  dynamic phone;
  dynamic phonePrefix;
  int freeViewCnt;
  String lastactivity;
  dynamic thumbStr;
  String oauthStr;
  int isSetPassword;
  int level;

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        uid: json["uid"] == null ? null : json["uid"],
        uuid: json["uuid"] == null ? null : json["uuid"],
        username: json["username"] == null ? null : json["username"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        roleId: json["role_id"] == null ? null : json["role_id"],
        gender: json["gender"] == null ? null : json["gender"],
        regip: json["regip"] == null ? null : json["regip"],
        regdate: json["regdate"] == null ? null : json["regdate"],
        lastip: json["lastip"] == null ? null : json["lastip"],
        lastvisit: json["lastvisit"] == null ? null : json["lastvisit"],
        expiredAt: json["expired_at"] == null ? null : json["expired_at"],
        lastpost: json["lastpost"] == null ? null : json["lastpost"],
        oltime: json["oltime"] == null ? null : json["oltime"],
        pageviews: json["pageviews"] == null ? null : json["pageviews"],
        score: json["score"] == null ? null : json["score"],
        aff: json["aff"] == null ? null : json["aff"],
        channel: json["channel"] == null ? null : json["channel"],
        invitedBy: json["invited_by"] == null ? null : json["invited_by"],
        invitedNum: json["invited_num"] == null ? null : json["invited_num"],
        banPost: json["ban_post"] == null ? null : json["ban_post"],
        postNum: json["post_num"] == null ? null : json["post_num"],
        loginCount: json["login_count"] == null ? null : json["login_count"],
        appVersion: json["app_version"] == null ? null : json["app_version"],
        validate: json["validate"] == null ? null : json["validate"],
        share: json["share"] == null ? null : json["share"],
        isLogin: json["is_login"] == null ? null : json["is_login"],
        nickname: json["nickname"] == null ? null : json["nickname"],
        thumb: json["thumb"] == null ? null : json["thumb"],
        coins: json["coins"] == null ? null : json["coins"],
        money: json["money"] == null ? null : json["money"],
        tempVip: json["temp_vip"] == null ? null : json["temp_vip"],
        followedCount: json["followed_count"] == null ? null : json["followed_count"],
        videosCount: json["videos_count"] == null ? null : json["videos_count"],
        fabulousCount: json["fabulous_count"] == null ? null : json["fabulous_count"],
        likesCount: json["likes_count"] == null ? null : json["likes_count"],
        commentCount: json["comment_count"] == null ? null : json["comment_count"],
        vipLevel: json["vip_level"] == null ? null : json["vip_level"],
        personSignnatrue: json["person_signnatrue"] == null ? null : json["person_signnatrue"],
        oldVip: json["old_vip"] == null ? null : json["old_vip"],
        stature: json["stature"] == null ? null : json["stature"],
        interest: json["interest"] == null ? null : json["interest"],
        city: json["city"] == null ? null : json["city"],
        usedMoneyFreeNum: json["used_money_free_num"] == null ? null : json["used_money_free_num"],
        agentFee: json["agent_fee"] == null ? null : json["agent_fee"],
        agent: json["agent"] == null ? null : json["agent"],
        buildId: json["build_id"] == null ? null : json["build_id"],
        authStatus: json["auth_status"] == null ? null : json["auth_status"],
        exp: json["exp"] == null ? null : json["exp"],
        isVirtual: json["is_virtual"] == null ? null : json["is_virtual"],
        chatUid: json["chat_uid"] == null ? null : json["chat_uid"],
        phone: json["phone"] == null ? null : json["phone"],
        phonePrefix: json["phone_prefix"] == null ? null : json["phone_prefix"],
        freeViewCnt: json["free_view_cnt"] == null ? null : json["free_view_cnt"],
        lastactivity: json["lastactivity"] == null ? null : json["lastactivity"],
        thumbStr: json["thumb_str"] == null || json["thumb_str"] == '' ? null : json["thumb_str"],
        oauthStr: json["oauth_str"] == null ? null : json["oauth_str"],
        isSetPassword: json["is_set_password"] == null ? null : json["is_set_password"],
        level: json["level"] == null ? null : json["level"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid == null ? null : uid,
        "uuid": uuid == null ? null : uuid,
        "username": username == null ? null : username,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "role_id": roleId == null ? null : roleId,
        "gender": gender == null ? null : gender,
        "regip": regip == null ? null : regip,
        "regdate": regdate == null ? null : regdate,
        "lastip": lastip == null ? null : lastip,
        "lastvisit": lastvisit == null ? null : lastvisit,
        "expired_at": expiredAt == null ? null : expiredAt,
        "lastpost": lastpost == null ? null : lastpost,
        "oltime": oltime == null ? null : oltime,
        "pageviews": pageviews == null ? null : pageviews,
        "score": score == null ? null : score,
        "aff": aff == null ? null : aff,
        "channel": channel == null ? null : channel,
        "invited_by": invitedBy == null ? null : invitedBy,
        "invited_num": invitedNum == null ? null : invitedNum,
        "ban_post": banPost == null ? null : banPost,
        "post_num": postNum == null ? null : postNum,
        "login_count": loginCount == null ? null : loginCount,
        "app_version": appVersion == null ? null : appVersion,
        "validate": validate == null ? null : validate,
        "share": share == null ? null : share,
        "is_login": isLogin == null ? null : isLogin,
        "nickname": nickname == null ? null : nickname,
        "thumb": thumb == null ? null : thumb,
        "coins": coins == null ? null : coins,
        "money": money == null ? null : money,
        "temp_vip": tempVip == null ? null : tempVip,
        "followed_count": followedCount == null ? null : followedCount,
        "videos_count": videosCount == null ? null : videosCount,
        "fabulous_count": fabulousCount == null ? null : fabulousCount,
        "likes_count": likesCount == null ? null : likesCount,
        "comment_count": commentCount == null ? null : commentCount,
        "vip_level": vipLevel == null ? null : vipLevel,
        "person_signnatrue": personSignnatrue == null ? null : personSignnatrue,
        "old_vip": oldVip == null ? null : oldVip,
        "stature": stature == null ? null : stature,
        "interest": interest == null ? null : interest,
        "city": city == null ? null : city,
        "used_money_free_num": usedMoneyFreeNum == null ? null : usedMoneyFreeNum,
        "agent_fee": agentFee == null ? null : agentFee,
        "agent": agent == null ? null : agent,
        "build_id": buildId == null ? null : buildId,
        "auth_status": authStatus == null ? null : authStatus,
        "exp": exp == null ? null : exp,
        "is_virtual": isVirtual == null ? null : isVirtual,
        "chat_uid": chatUid == null ? null : chatUid,
        "phone": phone == null ? null : phone,
        "phone_prefix": phonePrefix == null ? null : phonePrefix,
        "free_view_cnt": freeViewCnt == null ? null : freeViewCnt,
        "lastactivity": lastactivity == null ? null : lastactivity,
        "thumb_str": thumbStr == null || thumbStr == '' ? null : thumbStr,
        "oauth_str": oauthStr == null ? null : oauthStr,
        "is_set_password": isSetPassword == null ? null : isSetPassword,
        "level": level == null ? null : level,
      };
}

class Notice {
  Notice({this.id, this.title, this.content, this.createdAt, this.type, this.imgUrl, this.imgWidth, this.imgHeight});

  int id;
  String title;
  String content;
  String createdAt;
  String type;
  String imgUrl;
  double imgWidth;
  double imgHeight;
  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
      id: json["id"],
      title: json["title"],
      content: json["content"],
      createdAt: json["created_at"].toString(),
      type: json["type"],
      imgUrl: json["img_url"],
      imgWidth: json["img_width"] == null ? null : double.parse(json["img_width"].toString()),
      imgHeight: json["img_height"] == null ? null : double.parse(json["img_height"].toString()));

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "created_at": createdAt,
        "type": type,
        "img_url": imgUrl,
        "img_width": imgWidth,
        "img_height": imgHeight
      };
}

class VersionMsg {
  VersionMsg({
    this.version,
    this.type,
    this.apk,
    this.tips,
    this.must,
    this.status,
    this.message,
    this.mstatus,
    this.channel,
  });

  String version;
  String type;
  String apk;
  String tips;
  int must;
  int status;
  String message;
  int mstatus;
  String channel;

  factory VersionMsg.fromJson(Map<String, dynamic> json) => VersionMsg(
        version: json["version"] == null ? null : json["version"],
        type: json["type"] == null ? null : json["type"],
        apk: json["apk"] == null ? null : json["apk"],
        tips: json["tips"] == null ? null : json["tips"],
        must: json["must"] == null ? null : json["must"],
        status: json["status"] == null ? null : json["status"],
        message: json["message"] == null ? null : json["message"],
        mstatus: json["mstatus"] == null ? null : json["mstatus"],
        channel: json["channel"] == null ? null : json["channel"],
      );

  Map<String, dynamic> toJson() => {
        "version": version == null ? null : version,
        "type": type == null ? null : type,
        "apk": apk == null ? null : apk,
        "tips": tips == null ? null : tips,
        "must": must == null ? null : must,
        "status": status == null ? null : status,
        "message": message == null ? null : message,
        "mstatus": mstatus == null ? null : mstatus,
        "channel": channel == null ? null : channel,
      };
}

class ReportConfig {
  ReportConfig({
    this.clickAppId = '',
    this.clickTransitPath = '',
    this.isReportOrderPaid = 0,
    this.isReportCoinConsume = 0,
    this.isReportNavigation = 0,
    this.isReportAppPageView = 0,
    this.isReportPageClick = 0,
    this.isReportAdvertising = 0,
    this.isReportPageLifecycle = 0,
    this.isReportVideoEvent = 0,
    this.isReportVideoLike = 0,
    this.isReportVideoComment = 0,
    this.isReportVideoCollect = 0,
    this.isReportVideoPurchase = 0,
    this.isReportKeywordSearch = 0,
    this.isReportKeywordClick = 0,
    this.isReportAdImpression = 0,
    this.isReportAdClick = 0,
    this.isEncryption = 0,
    this.encryptionKey = '',
    this.encryptionIv = '',
    this.signKey = '',
    this.authenticationKey = '',
    this.authenticationTime = 3600,
  });

  final String clickAppId;
  final String clickTransitPath;
  final int isReportOrderPaid;
  final int isReportCoinConsume;
  final int isReportNavigation;
  final int isReportAppPageView;
  final int isReportPageClick;
  final int isReportAdvertising;
  final int isReportPageLifecycle;
  final int isReportVideoEvent;
  final int isReportVideoLike;
  final int isReportVideoComment;
  final int isReportVideoCollect;
  final int isReportVideoPurchase;
  final int isReportKeywordSearch;
  final int isReportKeywordClick;
  final int isReportAdImpression;
  final int isReportAdClick;
  final int isEncryption;
  final String encryptionKey;
  final String encryptionIv;
  final String signKey;
  final String authenticationKey;
  final int authenticationTime;

  factory ReportConfig.fromJson(Map<String, dynamic> json) {
    return ReportConfig(
      clickAppId: json['click_app_id'] ?? '',
      clickTransitPath: json['click_transit_path'] ?? '',
      isReportOrderPaid: json['is_report_order_paid'] ?? 0,
      isReportCoinConsume: json['is_report_coin_consume'] ?? 0,
      isReportNavigation: json['is_report_navigation'] ?? 0,
      isReportAppPageView: json['is_report_app_page_view'] ?? 0,
      isReportPageClick: json['is_report_page_click'] ?? 0,
      isReportAdvertising: json['is_report_advertising'] ?? 0,
      isReportPageLifecycle: json['is_report_page_lifecycle'] ?? 0,
      isReportVideoEvent: json['is_report_video_event'] ?? 0,
      isReportVideoLike: json['is_report_video_like'] ?? 0,
      isReportVideoComment: json['is_report_video_comment'] ?? 0,
      isReportVideoCollect: json['is_report_video_collect'] ?? 0,
      isReportVideoPurchase: json['is_report_video_purchase'] ?? 0,
      isReportKeywordSearch: json['is_report_keyword_search'] ?? 0,
      isReportKeywordClick: json['is_report_keyword_click'] ?? 0,
      isReportAdImpression: json['is_report_ad_impression'] ?? 0,
      isReportAdClick: json['is_report_ad_click'] ?? 0,
      isEncryption: json['is_encryption'] ?? 0,
      encryptionKey: json['encryption_key'] ?? '',
      encryptionIv: json['encryption_iv'] ?? '',
      signKey: json['sign_key'] ?? '',
      authenticationKey: json['authentication_key'] ?? '',
      authenticationTime: int.tryParse(json['authentication_time'] ?? '3600') ?? 3600,
    );
  }
}
