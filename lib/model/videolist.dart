// To parse this JSON data, do
//
//     final videoList = videoListFromJson(jsonString);

import 'dart:convert';

VideoList videoListFromJson(String str) => VideoList.fromJson(json.decode(str));

String videoListToJson(VideoList data) => json.encode(data.toJson());

class VideoList {
  VideoList({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  List<VideoItem>? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;

  factory VideoList.fromJson(Map<String, dynamic> json) => VideoList(
        data: json["data"] == null
            ? null
            : List<VideoItem>.from(
                json["data"].map((x) => VideoItem.fromJson(x))),
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
      };
}

class VideoItem {
  VideoItem(
      {this.datumId,
      this.aff,
      this.id,
      this.pId,
      this.title,
      this.secondTitle,
      this.mvType,
      this.isActivity,
      this.isRecommend,
      this.vExt,
      this.duration,
      this.coverOriginalVertical,
      this.coverZipVertical,
      this.coverThumbVertical,
      this.coverOriginalHorizontal,
      this.coverZipHorizontal,
      this.coverThumbHorizontal,
      this.directors,
      this.publisher,
      this.actors,
      this.category,
      this.tags,
      this.selfTag,
      this.tagsId,
      this.via,
      this.releaseAt,
      this.rating,
      this.countPlay,
      this.countLike,
      this.favorites,
      this.countComment,
      this.countReward,
      this.countPay,
      this.incomeCoins,
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
      this.rejesqReason,
      this.rejesqAt,
      this.isTop,
      this.clubId,
      this.isTester,
      this.desc,
      this.isPopular,
      this.isTiptop,
      this.createdAt,
      this.updatedAt,
      this.refreshAt,
      this.callbackAt,
      this.preview,
      this.sourceOriginStr,
      this.source240,
      this.userFavorites,
      this.discountCoins});

  int? datumId;
  dynamic aff;
  String? id;
  int? pId;
  String? title;
  dynamic secondTitle;
  int? mvType;
  int? isActivity;
  int? isRecommend;
  int? vExt;
  int? duration;
  String? coverOriginalVertical;
  String? coverZipVertical;
  String? coverThumbVertical;
  String? coverOriginalHorizontal;
  String? coverZipHorizontal;
  String? coverThumbHorizontal;
  String? directors;
  String? publisher;
  String? actors;
  String? category;
  String? tags;
  dynamic selfTag;
  String? tagsId;
  String? via;
  DateTime? releaseAt;
  int? rating;
  int? countPlay;
  int? countLike;
  int? favorites;
  int? countComment;
  int? countReward;
  int? countPay;
  int? incomeCoins;
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
  dynamic rejesqReason;
  int? rejesqAt;
  int? isTop;
  int? clubId;
  int? isTester;
  String? desc;
  int? isPopular;
  int? isTiptop;
  String? createdAt;
  String? updatedAt;
  String? refreshAt;
  String? callbackAt;
  dynamic preview;
  dynamic sourceOriginStr;
  String? source240;
  int? userFavorites;
  int? discountCoins;
  factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
      datumId: json["id"] == null ? null : json["id"],
      aff: json["aff"],
      id: json["_id"] == null ? null : json["_id"],
      pId: json["p_id"] == null ? null : json["p_id"],
      title: json["title"] == null ? null : json["title"],
      secondTitle: json["second_title"],
      mvType: json["mv_type"] == null ? null : json["mv_type"],
      isActivity: json["is_activity"] == null ? null : json["is_activity"],
      isRecommend: json["is_recommend"] == null ? null : json["is_recommend"],
      vExt: json["v_ext"] == null ? null : json["v_ext"],
      duration: json["duration"] == null ? null : json["duration"],
      coverOriginalVertical: json["cover_original_vertical"] == null
          ? null
          : json["cover_original_vertical"],
      coverZipVertical: json["cover_zip_vertical"] == null
          ? null
          : json["cover_zip_vertical"],
      coverThumbVertical: json["cover_thumb_vertical"] == null
          ? null
          : json["cover_thumb_vertical"],
      coverOriginalHorizontal: json["cover_original_horizontal"] == null
          ? null
          : json["cover_original_horizontal"],
      coverZipHorizontal: json["cover_zip_horizontal"] == null
          ? null
          : json["cover_zip_horizontal"],
      coverThumbHorizontal: json["cover_thumb_horizontal"] == null
          ? null
          : json["cover_thumb_horizontal"],
      directors: json["directors"] == null ? null : json["directors"],
      publisher: json["publisher"] == null ? null : json["publisher"],
      actors: json["actors"] == null ? null : json["actors"],
      category: json["category"] == null ? null : json["category"],
      tags: json["tags"] == null ? null : json["tags"],
      selfTag: json["self_tag"],
      tagsId: json["tags_id"] == null ? null : json["tags_id"],
      via: json["via"] == null ? null : json["via"],
      releaseAt: json["release_at"] == null
          ? null
          : DateTime.parse(json["release_at"]),
      rating: json["rating"] == null ? null : json["rating"],
      countPlay: json["count_play"] == null ? null : json["count_play"],
      countLike: json["count_like"] == null ? null : json["count_like"],
      favorites: json["favorites"] == null ? null : json["favorites"],
      countComment:
          json["count_comment"] == null ? null : json["count_comment"],
      countReward: json["count_reward"] == null ? null : json["count_reward"],
      countPay: json["count_pay"] == null ? null : json["count_pay"],
      incomeCoins: json["income_coins"] == null ? null : json["income_coins"],
      isfree: json["isfree"] == null ? null : json["isfree"],
      status: json["status"] == null ? null : json["status"],
      thumbStartTime:
          json["thumb_start_time"] == null ? null : json["thumb_start_time"],
      thumbDuration:
          json["thumb_duration"] == null ? null : json["thumb_duration"],
      isHide: json["is_hide"] == null ? null : json["is_hide"],
      coins: json["coins"] == null ? null : json["coins"],
      musicId: json["music_id"] == null ? null : json["music_id"],
      enableBackground:
          json["enable_background"] == null ? null : json["enable_background"],
      enableSoundtrack:
          json["enable_soundtrack"] == null ? null : json["enable_soundtrack"],
      isDelete: json["is_delete"] == null ? null : json["is_delete"],
      rejesqReason: json["rejesq_reason"],
      rejesqAt: json["rejesq_at"] == null ? null : json["rejesq_at"],
      isTop: json["is_top"] == null ? null : json["is_top"],
      clubId: json["club_id"] == null ? null : json["club_id"],
      isTester: json["is_tester"] == null ? null : json["is_tester"],
      desc: json["desc"] == null ? null : json["desc"],
      isPopular: json["is_popular"] == null ? null : json["is_popular"],
      isTiptop: json["is_tiptop"] == null ? null : json["is_tiptop"],
      createdAt: json["created_at"] == null ? null : json["created_at"],
      updatedAt: json["updated_at"] == null ? null : json["updated_at"],
      refreshAt: json["refresh_at"] == null ? null : json["refresh_at"],
      callbackAt: json["callback_at"] == null ? null : json["callback_at"],
      preview: json["preview"],
      sourceOriginStr: json["source_origin_str"],
      source240: json['source_240'] == null ? null : json['source_240'],
      userFavorites:
          json['userFavorites'] == null ? null : json['userFavorites'],
      discountCoins:
          json['discount_coins'] == null ? 0 : json['discount_coins']);

  Map<String, dynamic> toJson() => {
        "id": datumId == null ? null : datumId,
        "aff": aff,
        "_id": id == null ? null : id,
        "p_id": pId == null ? null : pId,
        "title": title == null ? null : title,
        "second_title": secondTitle,
        "mv_type": mvType == null ? null : mvType,
        "is_activity": isActivity == null ? null : isActivity,
        "is_recommend": isRecommend == null ? null : isRecommend,
        "v_ext": vExt == null ? null : vExt,
        "duration": duration == null ? null : duration,
        "cover_original_vertical":
            coverOriginalVertical == null ? null : coverOriginalVertical,
        "cover_zip_vertical":
            coverZipVertical == null ? null : coverZipVertical,
        "cover_thumb_vertical":
            coverThumbVertical == null ? null : coverThumbVertical,
        "cover_original_horizontal":
            coverOriginalHorizontal == null ? null : coverOriginalHorizontal,
        "cover_zip_horizontal":
            coverZipHorizontal == null ? null : coverZipHorizontal,
        "cover_thumb_horizontal":
            coverThumbHorizontal == null ? null : coverThumbHorizontal,
        "directors": directors == null ? null : directors,
        "publisher": publisher == null ? null : publisher,
        "actors": actors == null ? null : actors,
        "category": category == null ? null : category,
        "tags": tags == null ? null : tags,
        "self_tag": selfTag,
        "tags_id": tagsId == null ? null : tagsId,
        "via": via == null ? null : via,
        "release_at": releaseAt == null ? null : releaseAt,
        "rating": rating == null ? null : rating,
        "count_play": countPlay == null ? null : countPlay,
        "count_like": countLike == null ? null : countLike,
        "favorites": favorites == null ? null : favorites,
        "count_comment": countComment == null ? null : countComment,
        "count_reward": countReward == null ? null : countReward,
        "count_pay": countPay == null ? null : countPay,
        "income_coins": incomeCoins == null ? null : incomeCoins,
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
        "rejesq_reason": rejesqReason,
        "rejesq_at": rejesqAt == null ? null : rejesqAt,
        "is_top": isTop == null ? null : isTop,
        "club_id": clubId == null ? null : clubId,
        "is_tester": isTester == null ? null : isTester,
        "desc": desc == null ? null : desc,
        "is_popular": isPopular == null ? null : isPopular,
        "is_tiptop": isTiptop == null ? null : isTiptop,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "refresh_at": refreshAt == null ? null : refreshAt,
        "callback_at": callbackAt == null ? null : callbackAt,
        "preview": preview,
        "source_origin_str": sourceOriginStr,
        "source_240": source240 == null ? null : source240,
        "userFavorites": userFavorites == null ? null : userFavorites,
        "discount_coins": discountCoins == null ? 0 : discountCoins,
      };
}
