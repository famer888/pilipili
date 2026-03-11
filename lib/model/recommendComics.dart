// To parse this JSON data, do
//
//     final recommendComics = recommendComicsFromJson(jsonString);

import 'dart:convert';

RecommendComics recommendComicsFromJson(String str) => RecommendComics.fromJson(json.decode(str));

String recommendComicsToJson(RecommendComics data) => json.encode(data.toJson());

class RecommendComics {
    RecommendComics({
        this.data,
        this.status,
        this.msg,
        this.crypt,
        this.isVip,
    });

    List<Datum>? data;
    int? status;
    String? msg;
    bool? crypt;
    bool? isVip;

    factory RecommendComics.fromJson(Map<String, dynamic> json) => RecommendComics(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        status: json["status"],
        msg: json["msg"],
        crypt: json["crypt"],
        isVip: json["isVip"],
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status,
        "msg": msg,
        "crypt": crypt,
        "isVip": isVip,
    };
}

class Datum {
    Datum({
        this.datumId,
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
    });

    int? datumId;
    String? id;
    dynamic recommendTitle;
    String? title;
    String? description;
    String? author;
    String? categories;
    String? bgThumb;
    String? thumb;
    dynamic reThumb;
    String? tags;
    int? isFree;
    int? adult;
    int? finished;
    int? imagesCount;
    int? viewsCount;
    int? likesCount;
    int? favorites;
    int? cjFinished;
    int? viewMoney;
    int? downloadMoney;
    int? status;
    String? updateTime;
    int? freeTime;
    int? recommend;
    int? indexRecommend;
    int? obtained;
    int? goodLook;
    int? mustAwesome;
    int? whatAwesome;
    int? noAwesome;
    int? from;
    DateTime? refreshAt;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? newestSeries;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        datumId: json["id"],
        id: json["_id"],
        recommendTitle: json["recommend_title"],
        title: json["title"],
        description: json["description"],
        author: json["author"],
        categories: json["categories"],
        bgThumb: json["bg_thumb"],
        thumb: json["thumb"],
        reThumb: json["re_thumb"],
        tags: json["tags"],
        isFree: json["is_free"],
        adult: json["adult"],
        finished: json["finished"],
        imagesCount: json["images_count"],
        viewsCount: json["views_count"],
        likesCount: json["likes_count"],
        favorites: json["favorites"],
        cjFinished: json["cj_finished"],
        viewMoney: json["view_money"],
        downloadMoney: json["download_money"],
        status: json["status"],
        updateTime: json["update_time"],
        freeTime: json["free_time"],
        recommend: json["recommend"],
        indexRecommend: json["index_recommend"],
        obtained: json["obtained"],
        goodLook: json["good_look"],
        mustAwesome: json["must_awesome"],
        whatAwesome: json["what_awesome"],
        noAwesome: json["no_awesome"],
        from: json["from"],
        refreshAt: DateTime.parse(json["refresh_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        newestSeries: json["newest_series"] == null ? null : json["newest_series"],
    );

    Map<String, dynamic> toJson() => {
        "id": datumId,
        "_id": id,
        "recommend_title": recommendTitle,
        "title": title,
        "description": description,
        "author": author,
        "categories": categories,
        "bg_thumb": bgThumb,
        "thumb": thumb,
        "re_thumb": reThumb,
        "tags": tags,
        "is_free": isFree,
        "adult": adult,
        "finished": finished,
        "images_count": imagesCount,
        "views_count": viewsCount,
        "likes_count": likesCount,
        "favorites": favorites,
        "cj_finished": cjFinished,
        "view_money": viewMoney,
        "download_money": downloadMoney,
        "status": status,
        "update_time": updateTime,
        "free_time": freeTime,
        "recommend": recommend,
        "index_recommend": indexRecommend,
        "obtained": obtained,
        "good_look": goodLook,
        "must_awesome": mustAwesome,
        "what_awesome": whatAwesome,
        "no_awesome": noAwesome,
        "from": from,
        "refresh_at": refreshAt!.toIso8601String(),
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "newest_series": newestSeries == null ? null : newestSeries,
    };
}
