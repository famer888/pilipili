// To parse this JSON data, do
//
//     final comicsData = comicsDataFromJson(jsonString);

import 'dart:convert';

ComicsData comicsDataFromJson(String str) =>
    ComicsData.fromJson(json.decode(str));

String comicsDataToJson(ComicsData data) => json.encode(data.toJson());

class ComicsData {
  ComicsData({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  List<Datum> data;
  int status;
  String msg;
  bool crypt;
  bool isVip;

  factory ComicsData.fromJson(Map<String, dynamic> json) => ComicsData(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
      );

  Map<String, dynamic> toJson() => {
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
      };
}

class Datum {
  Datum(
      {this.datumId,
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
      this.cjFinished,
      this.viewMoney,
      this.downloadMoney,
      this.status,
      this.updateTime,
      this.freeTime,
      this.recommend,
      this.refreshAt,
      this.createdAt,
      this.updatedAt,
      this.indexRecommend,
      this.obtained,
      this.goodLook,
      this.mustAwesome,
      this.whatAwesome,
      this.noAwesome,
      this.from,
      this.newestSeries,
      this.favorites,
      this.sort});

  int datumId;
  String id;
  String recommendTitle;
  String title;
  String description;
  String author;
  String categories;
  String bgThumb;
  String thumb;
  String reThumb;
  String tags;
  int isFree;
  int adult;
  int finished;
  int imagesCount;
  int viewsCount;
  int likesCount;
  int cjFinished;
  int viewMoney;
  int downloadMoney;
  int status;
  String updateTime;
  int freeTime;
  int recommend;
  String refreshAt;
  String createdAt;
  String updatedAt;
  int indexRecommend;
  int obtained;
  int goodLook;
  int mustAwesome;
  int whatAwesome;
  int noAwesome;
  int from;
  int newestSeries;
  int favorites;
  int sort;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        datumId: json["id"] == null ? null : json["id"],
        id: json["_id"] == null ? null : json["_id"],
        recommendTitle:
            json["recommend_title"] == null ? null : json["recommend_title"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        author: json["author"] == null ? null : json["author"],
        categories: json["categories"] == null ? null : json["categories"],
        bgThumb: json["bg_thumb"] == null ? null : json["bg_thumb"],
        thumb: json["thumb"] == null ? null : json["thumb"],
        reThumb: json["re_thumb"] == null ? null : json["re_thumb"],
        tags: json["tags"] == null ? null : json["tags"],
        isFree: json["is_free"] == null ? null : json["is_free"],
        adult: json["adult"] == null ? null : json["adult"],
        finished: json["finished"] == null ? null : json["finished"],
        imagesCount: json["images_count"] == null ? null : json["images_count"],
        viewsCount: json["views_count"] == null ? null : json["views_count"],
        likesCount: json["likes_count"] == null ? null : json["likes_count"],
        cjFinished: json["cj_finished"] == null ? null : json["cj_finished"],
        viewMoney: json["view_money"] == null ? null : json["view_money"],
        downloadMoney:
            json["download_money"] == null ? null : json["download_money"],
        status: json["status"] == null ? null : json["status"],
        updateTime: json["update_time"] == null ? null : json["update_time"],
        freeTime: json["free_time"] == null ? null : json["free_time"],
        recommend: json["recommend"] == null ? null : json["recommend"],
        refreshAt: json["refresh_at"] == null ? null : json["refresh_at"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        indexRecommend:
            json["index_recommend"] == null ? null : json["index_recommend"],
        obtained: json["obtained"] == null ? null : json["obtained"],
        goodLook: json["good_look"] == null ? null : json["good_look"],
        mustAwesome: json["must_awesome"] == null ? null : json["must_awesome"],
        whatAwesome: json["what_awesome"] == null ? null : json["what_awesome"],
        noAwesome: json["no_awesome"] == null ? null : json["no_awesome"],
        from: json["from"] == null ? null : json["from"],
        newestSeries:
            json["newest_series"] == null ? null : json["newest_series"],
        favorites: json["favorites"] == null ? null : json["favorites"],
        sort: json["sort"] == null ? null : json["sort"],
      );

  Map<String, dynamic> toJson() => {
        "id": datumId == null ? null : datumId,
        "_id": id == null ? null : id,
        "recommend_title": recommendTitle == null ? null : recommendTitle,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "author": author == null ? null : author,
        "categories": categories == null ? null : categories,
        "bg_thumb": bgThumb == null ? null : bgThumb,
        "thumb": thumb == null ? null : thumb,
        "re_thumb": reThumb == null ? null : reThumb,
        "tags": tags == null ? null : tags,
        "is_free": isFree == null ? null : isFree,
        "adult": adult == null ? null : adult,
        "finished": finished == null ? null : finished,
        "images_count": imagesCount == null ? null : imagesCount,
        "views_count": viewsCount == null ? null : viewsCount,
        "likes_count": likesCount == null ? null : likesCount,
        "cj_finished": cjFinished == null ? null : cjFinished,
        "view_money": viewMoney == null ? null : viewMoney,
        "download_money": downloadMoney == null ? null : downloadMoney,
        "status": status == null ? null : status,
        "update_time": updateTime == null ? null : updateTime,
        "free_time": freeTime == null ? null : freeTime,
        "recommend": recommend == null ? null : recommend,
        "refresh_at": refreshAt == null ? null : refreshAt,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "index_recommend": indexRecommend == null ? null : indexRecommend,
        "obtained": obtained == null ? null : obtained,
        "good_look": goodLook == null ? null : goodLook,
        "must_awesome": mustAwesome == null ? null : mustAwesome,
        "what_awesome": whatAwesome == null ? null : whatAwesome,
        "no_awesome": noAwesome == null ? null : noAwesome,
        "from": from == null ? null : from,
        "newest_series": newestSeries == null ? null : newestSeries,
        "favorites": favorites == null ? null : favorites,
        "sort": sort == null ? null : sort,
      };
}
