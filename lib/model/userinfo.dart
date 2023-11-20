// To parse this JSON data, do
//
//     final userInfo = userInfoFromJson(jsonString);

import 'dart:convert';

UserInfo userInfoFromJson(String str) => UserInfo.fromJson(json.decode(str));

String userInfoToJson(UserInfo data) => json.encode(data.toJson());

class UserInfo {
  UserInfo({
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

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
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
  Data(
      {this.money,
      this.exp,
      this.level,
      this.thumb,
      this.nickname,
      this.shortMvFreeTime,
      this.longMvFreeTime,
      this.postMoney});

  int money;
  int exp;
  int level;
  String thumb;
  String nickname;
  int shortMvFreeTime;
  int longMvFreeTime;
  int postMoney;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
      money: json["money"] == null ? null : json["money"],
      exp: json["exp"] == null ? null : json["exp"],
      level: json["level"] == null ? null : json["level"],
      thumb: json["thumb"] == null ? null : json["thumb"],
      nickname: json["nickname"] == null ? null : json["nickname"],
      shortMvFreeTime:
          json["shortMvFreeTime"] == null ? null : json["shortMvFreeTime"],
      longMvFreeTime:
          json["longMvFreeTime"] == null ? null : json["longMvFreeTime"],
      postMoney: json['post_money'] ?? 0);

  Map<String, dynamic> toJson() => {
        "money": money == null ? null : money,
        "exp": exp == null ? null : exp,
        "level": level == null ? null : level,
        "thumb": thumb == null ? null : thumb,
        "nickname": nickname == null ? null : nickname,
        "shortMvFreeTime": shortMvFreeTime == null ? null : shortMvFreeTime,
        "longMvFreeTime": longMvFreeTime == null ? null : longMvFreeTime,
        "post_money": postMoney ?? 0
      };
}
