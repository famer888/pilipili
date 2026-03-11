import 'dart:convert';

MyRewardModel myRewardModelFromJson(String str) =>
    MyRewardModel.fromJson(json.decode(str));

String myRewardModelToJson(MyRewardModel data) => json.encode(data.toJson());

class MyRewardModel {
  MyRewardModel({
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

  factory MyRewardModel.fromJson(Map<String, dynamic> json) => MyRewardModel(
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
    this.nickname,
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
  });

  String? nickname;
  int? id;
  int? aff;
  int? source;
  int? type;
  String? coinCnt;
  String? desc;
  int? sourceAff;
  DateTime? createdAt;
  String? sourceStr;
  String? typeStr;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        nickname: json["nickname"] == null ? null : json["nickname"],
        id: json["id"] == null ? null : json["id"],
        aff: json["aff"] == null ? null : json["aff"],
        source: json["source"] == null ? null : json["source"],
        type: json["type"] == null ? null : json["type"],
        coinCnt: json["coinCnt"] == null ? null : json["coinCnt"],
        desc: json["desc"] == null ? null : json["desc"],
        sourceAff: json["source_aff"] == null ? null : json["source_aff"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        sourceStr: json["source_str"] == null ? null : json["source_str"],
        typeStr: json["type_str"] == null ? null : json["type_str"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname == null ? null : nickname,
        "id": id == null ? null : id,
        "aff": aff == null ? null : aff,
        "source": source == null ? null : source,
        "type": type == null ? null : type,
        "coinCnt": coinCnt == null ? null : coinCnt,
        "desc": desc == null ? null : desc,
        "source_aff": sourceAff == null ? null : sourceAff,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "source_str": sourceStr == null ? null : sourceStr,
        "type_str": typeStr == null ? null : typeStr,
      };
}
