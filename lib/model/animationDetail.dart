// To parse this JSON data, do
//
//     final animationDetail = animationDetailFromJson(jsonString);

import 'dart:convert';

AnimationDetail animationDetailFromJson(String str) => AnimationDetail.fromJson(json.decode(str));

String animationDetailToJson(AnimationDetail data) => json.encode(data.toJson());

class AnimationDetail {
  AnimationDetail({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  DetailData? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;

  factory AnimationDetail.fromJson(Map<String, dynamic> json) => AnimationDetail(
        data: json["data"] == null ? null : DetailData.fromJson(json["data"]),
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : data!.toJson(),
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
      };
}

class DetailData {
  DetailData({
    this.id,
    this.memberUuid,
    this.title,
    this.mvType,
    this.isActivity,
    this.isRecommend,
    this.source240,
    this.source480,
    this.source720,
    this.source1080,
    this.vExt,
    this.duration,
    this.thumbCover,
    this.thumbWidth,
    this.thumbHeight,
    this.directors,
    this.publisher,
    this.actors,
    this.category,
    this.tags,
    this.selfTag,
    this.tagsId,
    this.via,
    this.onshelfTm,
    this.rating,
    this.countPlay,
    this.countFavorites,
    this.countLike,
    this.countComment,
    this.countReward,
    this.countPay,
    this.incomeCoins,
    this.createdAt,
    this.refreshAt,
    this.updatedAt,
    this.callbackAt,
    this.isfree,
    this.status,
    this.thumbStartTime,
    this.thumbDuration,
    this.isHide,
    this.coins,
    this.musicId,
    this.enableBackground,
    this.enableSoundtrack,
    this.isDelete,
    this.rejectReason,
    this.rejectAt,
    this.isTop,
    this.clubId,
    this.isTester,
    this.desc,
    this.isPopular,
    this.isTiptop,
    this.userFavorites,
    this.userLike,
    this.coverThumbHorizontal,
    this.coverOriginalVertical,
    this.coverOriginalHorizontal,
    this.discountCoins,
    this.favorites,
    this.preview,
  });

  int? id;
  String? memberUuid;
  String? title;
  int? mvType;
  int? isActivity;
  int? isRecommend;
  String? source240;
  dynamic source480;
  dynamic source720;
  dynamic source1080;
  int? vExt;
  int? duration;
  String? thumbCover;
  int? thumbWidth;
  int? thumbHeight;
  String? directors;
  String? publisher;
  String? actors;
  String? category;
  late String categoryIds;
  String? tags;
  String? selfTag;
  String? tagsId;
  String? via;
  String? onshelfTm;
  int? rating;
  int? countPlay;
  dynamic countFavorites;
  int? countLike;
  int? countComment;
  int? countReward;
  int? countPay;
  int? incomeCoins;
  String? createdAt;
  String? refreshAt;
  String? updatedAt;
  String? callbackAt;
  int? isfree;
  int? status;
  int? thumbStartTime;
  int? thumbDuration;
  int? isHide;
  int? coins;
  int? musicId;
  int? enableBackground;
  int? enableSoundtrack;
  int? isDelete;
  dynamic rejectReason;
  int? rejectAt;
  int? isTop;
  int? clubId;
  int? isTester;
  String? desc;
  int? isPopular;
  int? isTiptop;
  int? userFavorites;
  int? userLike;
  String? coverThumbHorizontal;
  String? coverOriginalVertical;
  String? coverOriginalHorizontal;
  int? discountCoins;
  int? favorites;
  String? preview;
  factory DetailData.fromJson(Map<String, dynamic> json) => DetailData(
      id: json["id"] == null ? null : json["id"],
      memberUuid: json["member_uuid"] == null ? null : json["member_uuid"],
      title: json["title"] == null ? null : json["title"],
      mvType: json["mv_type"] == null ? null : json["mv_type"],
      isActivity: json["is_activity"] == null ? null : json["is_activity"],
      isRecommend: json["is_recommend"] == null ? null : json["is_recommend"],
      source240: json["source_240"] == null ? null : json["source_240"],
      source480: json["source_480"],
      source720: json["source_720"],
      source1080: json["source_1080"],
      vExt: json["v_ext"] == null ? null : json["v_ext"],
      duration: json["duration"] == null ? null : json["duration"],
      thumbCover: json["thumb_cover"] == null ? null : json["thumb_cover"],
      thumbWidth: json["thumb_width"] == null ? null : json["thumb_width"],
      thumbHeight: json["thumb_height"] == null ? null : json["thumb_height"],
      directors: json["directors"] == null ? null : json["directors"],
      publisher: json["publisher"] == null ? null : json["publisher"],
      actors: json["actors"] == null ? null : json["actors"],
      category: json["category"] == null ? null : json["category"],
      tags: json["tags"] == null ? null : json["tags"],
      selfTag: json["self_tag"] == null ? null : json["self_tag"],
      tagsId: json["tags_id"] == null ? null : json["tags_id"],
      via: json["via"] == null ? null : json["via"],
      onshelfTm: json["onshelf_tm"] == null ? null : json["onshelf_tm"],
      rating: json["rating"] == null ? null : json["rating"],
      countPlay: json["count_play"] == null ? null : json["count_play"],
      countFavorites: json["count_favorites"],
      countLike: json["count_like"] == null ? null : json["count_like"],
      countComment: json["count_comment"] == null ? null : json["count_comment"],
      countReward: json["count_reward"] == null ? null : json["count_reward"],
      countPay: json["count_pay"] == null ? null : json["count_pay"],
      incomeCoins: json["income_coins"] == null ? null : json["income_coins"],
      createdAt: json["created_at"] == null ? null : json["created_at"],
      refreshAt: json["refresh_at"] == null ? null : json["refresh_at"],
      updatedAt: json["updated_at"] == null ? null : json["updated_at"],
      callbackAt: json["callback_at"] == null ? null : json["callback_at"],
      isfree: json["isfree"] == null ? null : json["isfree"],
      status: json["status"] == null ? null : json["status"],
      thumbStartTime: json["thumb_start_time"] == null ? null : json["thumb_start_time"],
      thumbDuration: json["thumb_duration"] == null ? null : json["thumb_duration"],
      isHide: json["is_hide"] == null ? null : json["is_hide"],
      coins: json["coins"] == null ? null : json["coins"],
      musicId: json["music_id"] == null ? null : json["music_id"],
      enableBackground: json["enable_background"] == null ? null : json["enable_background"],
      enableSoundtrack: json["enable_soundtrack"] == null ? null : json["enable_soundtrack"],
      isDelete: json["is_delete"] == null ? null : json["is_delete"],
      rejectReason: json["reject_reason"],
      rejectAt: json["reject_at"] == null ? null : json["reject_at"],
      isTop: json["is_top"] == null ? null : json["is_top"],
      clubId: json["club_id"] == null ? null : json["club_id"],
      isTester: json["is_tester"] == null ? null : json["is_tester"],
      desc: json["desc"] == null ? null : json["desc"],
      isPopular: json["is_popular"] == null ? null : json["is_popular"],
      isTiptop: json["is_tiptop"] == null ? null : json["is_tiptop"],
      userFavorites: json["userFavorites"] == null ? null : json["userFavorites"],
      userLike: json["userLike"] == null ? null : json["userLike"],
      coverThumbHorizontal: json["cover_thumb_horizontal"] == null ? null : json["cover_thumb_horizontal"],
      coverOriginalVertical: json["cover_original_vertical"] == null ? null : json["cover_original_vertical"],
      coverOriginalHorizontal: json["cover_original_horizontal"] == null ? null : json["cover_original_horizontal"],
      discountCoins: json["discount_coins"] == null ? 0 : json["discount_coins"],
      favorites: json["favorites"] == null ? 0 : json["favorites"],
      preview: json["preview"] == null ? null : json["preview"]);

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "member_uuid": memberUuid == null ? null : memberUuid,
        "title": title == null ? null : title,
        "mv_type": mvType == null ? null : mvType,
        "is_activity": isActivity == null ? null : isActivity,
        "is_recommend": isRecommend == null ? null : isRecommend,
        "source_240": source240 == null ? null : source240,
        "source_480": source480,
        "source_720": source720,
        "source_1080": source1080,
        "v_ext": vExt == null ? null : vExt,
        "duration": duration == null ? null : duration,
        "thumb_cover": thumbCover == null ? null : thumbCover,
        "thumb_width": thumbWidth == null ? null : thumbWidth,
        "thumb_height": thumbHeight == null ? null : thumbHeight,
        "directors": directors == null ? null : directors,
        "publisher": publisher == null ? null : publisher,
        "actors": actors == null ? null : actors,
        "category": category == null ? null : category,
        "tags": tags == null ? null : tags,
        "self_tag": selfTag == null ? null : selfTag,
        "tags_id": tagsId == null ? null : tagsId,
        "via": via == null ? null : via,
        "onshelf_tm": onshelfTm == null ? null : onshelfTm,
        "rating": rating == null ? null : rating,
        "count_play": countPlay == null ? null : countPlay,
        "count_favorites": countFavorites,
        "count_like": countLike == null ? null : countLike,
        "count_comment": countComment == null ? null : countComment,
        "count_reward": countReward == null ? null : countReward,
        "count_pay": countPay == null ? null : countPay,
        "income_coins": incomeCoins == null ? null : incomeCoins,
        "created_at": createdAt == null ? null : createdAt,
        "refresh_at": refreshAt == null ? null : refreshAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "callback_at": callbackAt == null ? null : callbackAt,
        "isfree": isfree == null ? null : isfree,
        "status": status == null ? null : status,
        "thumb_start_time": thumbStartTime == null ? null : thumbStartTime,
        "thumb_duration": thumbDuration == null ? null : thumbDuration,
        "is_hide": isHide == null ? null : isHide,
        "coins": coins == null ? null : coins,
        "music_id": musicId == null ? null : musicId,
        "enable_background": enableBackground == null ? null : enableBackground,
        "enable_soundtrack": enableSoundtrack == null ? null : enableSoundtrack,
        "is_delete": isDelete == null ? null : isDelete,
        "reject_reason": rejectReason,
        "reject_at": rejectAt == null ? null : rejectAt,
        "is_top": isTop == null ? null : isTop,
        "club_id": clubId == null ? null : clubId,
        "is_tester": isTester == null ? null : isTester,
        "desc": desc == null ? null : desc,
        "is_popular": isPopular == null ? null : isPopular,
        "is_tiptop": isTiptop == null ? null : isTiptop,
        "userFavorites": userFavorites == null ? null : userFavorites,
        "userLike": userLike == null ? null : userLike,
        "cover_thumb_horizontal": coverThumbHorizontal == null ? null : coverThumbHorizontal,
        "cover_original_vertical": coverOriginalVertical == null ? null : coverOriginalVertical,
        "cover_original_horizontal": coverOriginalHorizontal == null ? null : coverOriginalHorizontal,
        "discount_coins": discountCoins == null ? 0 : discountCoins,
        "favorites": favorites == null ? 0 : favorites,
        "preview": preview == null ? null : preview,
      };
}
