// To parse this JSON data, do
//
//     final comicReading = comicReadingFromJson(jsonString);

import 'dart:convert';

ComicReading comicReadingFromJson(String str) => ComicReading.fromJson(json.decode(str));

String comicReadingToJson(ComicReading data) => json.encode(data.toJson());

class ComicReading {
    ComicReading({
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

    factory ComicReading.fromJson(Map<String, dynamic> json) => ComicReading(
        data: json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
    };
}

class Datum {
    Datum({
        this.short,
        this.imgUrl,
        this.imgWidth,
        this.imgHeight,
    });

    int? short;
    String? imgUrl;
    String? imgWidth;
    String? imgHeight;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        short: json["short"] == null ? null : json["short"],
        imgUrl: json["img_url"] == null ? null : json["img_url"],
        imgWidth: json["img_width"] == null ? null : json["img_width"],
        imgHeight: json["img_height"] == null ? null : json["img_height"],
    );

    Map<String, dynamic> toJson() => {
        "short": short == null ? null : short,
        "img_url": imgUrl == null ? null : imgUrl,
        "img_width": imgWidth == null ? null : imgWidth,
        "img_height": imgHeight == null ? null : imgHeight,
    };
}
