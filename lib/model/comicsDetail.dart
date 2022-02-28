// To parse this JSON data, do
//
//     final comicDetail = comicDetailFromJson(jsonString);

import 'dart:convert';

ComicDetail comicDetailFromJson(String str) =>
    ComicDetail.fromJson(json.decode(str));

String comicDetailToJson(ComicDetail data) => json.encode(data.toJson());

class ComicDetail {
  ComicDetail({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  Data data;
  int status;
  String msg;
  bool crypt;
  bool isVip;

  factory ComicDetail.fromJson(Map<String, dynamic> json) => ComicDetail(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : data.toJson(),
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
      };
}

class Data {
  Data({
    this.dataId,
    this.id,
    this.recommendTitle,
    this.title,
    this.description,
    this.author,
    this.categories,
    this.bgThumb,
    this.thumb,
    this.reThumb,
    this.tags,
    this.isFree,
    this.adult,
    this.finished,
    this.imagesCount,
    this.viewsCount,
    this.likesCount,
    this.favorites,
    this.cjFinished,
    this.viewMoney,
    this.downloadMoney,
    this.status,
    this.updateTime,
    this.freeTime,
    this.recommend,
    this.indexRecommend,
    this.obtained,
    this.goodLook,
    this.mustAwesome,
    this.whatAwesome,
    this.noAwesome,
    this.from,
    this.refreshAt,
    this.createdAt,
    this.updatedAt,
    this.newestSeries,
    this.watchLog,
    this.userFavorites,
    this.userLike,
  });

  int dataId;
  String id;
  String recommendTitle;
  String title;
  String description;
  String author;
  String categories;
  String bgThumb;
  String thumb;
  dynamic reThumb;
  String tags;
  int isFree;
  int adult;
  int finished;
  int imagesCount;
  int viewsCount;
  int likesCount;
  dynamic favorites;
  int cjFinished;
  int viewMoney;
  int downloadMoney;
  int status;
  String updateTime;
  int freeTime;
  int recommend;
  int indexRecommend;
  int obtained;
  int goodLook;
  int mustAwesome;
  int whatAwesome;
  int noAwesome;
  int from;
  String refreshAt;
  DateTime createdAt;
  DateTime updatedAt;
  int newestSeries;
  int watchLog;
  dynamic userFavorites;
  int userLike;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        dataId: json["id"] == null ? null : json["id"],
        id: json["_id"] == null ? null : json["_id"],
        recommendTitle:
            json["recommend_title"] == null ? null : json["recommend_title"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        author: json["author"] == null ? null : json["author"],
        categories: json["categories"] == null ? null : json["categories"],
        bgThumb: json["bg_thumb"] == null ? null : json["bg_thumb"],
        thumb: json["thumb"] == null ? null : json["thumb"],
        reThumb: json["re_thumb"],
        tags: json["tags"] == null ? null : json["tags"],
        isFree: json["is_free"] == null ? null : json["is_free"],
        adult: json["adult"] == null ? null : json["adult"],
        finished: json["finished"] == null ? null : json["finished"],
        imagesCount: json["images_count"] == null ? null : json["images_count"],
        viewsCount: json["views_count"] == null ? null : json["views_count"],
        likesCount: json["likes_count"] == null ? null : json["likes_count"],
        favorites: json["favorites"],
        cjFinished: json["cj_finished"] == null ? null : json["cj_finished"],
        viewMoney: json["view_money"] == null ? null : json["view_money"],
        downloadMoney:
            json["download_money"] == null ? null : json["download_money"],
        status: json["status"] == null ? null : json["status"],
        updateTime: json["update_time"] == null ? null : json["update_time"],
        freeTime: json["free_time"] == null ? null : json["free_time"],
        recommend: json["recommend"] == null ? null : json["recommend"],
        indexRecommend:
            json["index_recommend"] == null ? null : json["index_recommend"],
        obtained: json["obtained"] == null ? null : json["obtained"],
        goodLook: json["good_look"] == null ? null : json["good_look"],
        mustAwesome: json["must_awesome"] == null ? null : json["must_awesome"],
        whatAwesome: json["what_awesome"] == null ? null : json["what_awesome"],
        noAwesome: json["no_awesome"] == null ? null : json["no_awesome"],
        from: json["from"] == null ? null : json["from"],
        refreshAt: json["refresh_at"] == null ? null : json["refresh_at"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        newestSeries:
            json["newest_series"] == null ? null : json["newest_series"],
        watchLog: json["watchLog"] == null ? null : json["watchLog"],
        userFavorites:
            json["userFavorites"] == null ? null : json["userFavorites"],
        userLike: json["userLike"] == null ? null : json["userLike"],
      );

  Map<String, dynamic> toJson() => {
        "id": dataId == null ? null : dataId,
        "_id": id == null ? null : id,
        "recommend_title": recommendTitle == null ? null : recommendTitle,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "author": author == null ? null : author,
        "categories": categories == null ? null : categories,
        "bg_thumb": bgThumb == null ? null : bgThumb,
        "thumb": thumb == null ? null : thumb,
        "re_thumb": reThumb,
        "tags": tags == null ? null : tags,
        "is_free": isFree == null ? null : isFree,
        "adult": adult == null ? null : adult,
        "finished": finished == null ? null : finished,
        "images_count": imagesCount == null ? null : imagesCount,
        "views_count": viewsCount == null ? null : viewsCount,
        "likes_count": likesCount == null ? null : likesCount,
        "favorites": favorites,
        "cj_finished": cjFinished == null ? null : cjFinished,
        "view_money": viewMoney == null ? null : viewMoney,
        "download_money": downloadMoney == null ? null : downloadMoney,
        "status": status == null ? null : status,
        "update_time": updateTime == null ? null : updateTime,
        "free_time": freeTime == null ? null : freeTime,
        "recommend": recommend == null ? null : recommend,
        "index_recommend": indexRecommend == null ? null : indexRecommend,
        "obtained": obtained == null ? null : obtained,
        "good_look": goodLook == null ? null : goodLook,
        "must_awesome": mustAwesome == null ? null : mustAwesome,
        "what_awesome": whatAwesome == null ? null : whatAwesome,
        "no_awesome": noAwesome == null ? null : noAwesome,
        "from": from == null ? null : from,
        "refresh_at": refreshAt == null ? null : refreshAt,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "newest_series": newestSeries == null ? null : newestSeries,
        "watchLog": watchLog == null ? null : watchLog,
        "userFavorites": userFavorites == null ? null : userFavorites,
        "userLike": userLike == null ? null : userLike,
      };
}
