// To parse this JSON data, do
//
//     final coinDetialModel = coinDetialModelFromJson(jsonString);

import 'dart:convert';

CoinDetialModel coinDetialModelFromJson(String str) =>
    CoinDetialModel.fromJson(json.decode(str));

String coinDetialModelToJson(CoinDetialModel data) =>
    json.encode(data.toJson());

class CoinDetialModel {
  CoinDetialModel({
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

  factory CoinDetialModel.fromJson(Map<String, dynamic> json) =>
      CoinDetialModel(
        data: json["data"] == null
            ? null
            : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
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

class Datum {
  Datum({
    this.id,
    this.aff,
    this.source,
    this.type,
    this.coinCnt,
    this.desc,
    this.sourceAff,
    this.createdAt,
    this.sourceStr,
    this.typeStr,
    this.sourceName,
    this.coin,
  });

  int? id;
  int? aff;
  int? source;
  int? type;
  String? coinCnt;
  String? desc;
  int? sourceAff;
  String? createdAt;
  String? sourceStr;
  String? typeStr;
  String? sourceName;
  String? coin;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] == null ? null : json["id"],
        aff: json["aff"] == null ? null : json["aff"],
        source: json["source"] == null ? null : json["source"],
        type: json["type"] == null ? null : json["type"],
        coinCnt: json["coinCnt"] == null ? null : json["coinCnt"],
        desc: json["desc"] == null ? null : json["desc"],
        sourceAff: json["source_aff"] == null ? null : json["source_aff"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        sourceStr: json["source_str"] == null ? null : json["source_str"],
        typeStr: json["type_str"] == null ? null : json["type_str"],
        sourceName: json["source_name"] == null ? null : json["source_name"],
        coin: json["coin"] == null ? null : json["coin"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "aff": aff == null ? null : aff,
        "source": source == null ? null : source,
        "type": type == null ? null : type,
        "coinCnt": coinCnt == null ? null : coinCnt,
        "desc": desc == null ? null : desc,
        "source_aff": sourceAff == null ? null : sourceAff,
        "created_at": createdAt == null ? null : createdAt,
        "source_str": sourceStr == null ? null : sourceStr,
        "type_str": typeStr == null ? null : typeStr,
        "source_name": sourceName == null ? null : sourceName,
        "coin": coin == null ? null : coin,
      };
}
