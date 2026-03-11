import 'dart:convert';

InvitionList invitionListFromJson(String str) =>
    InvitionList.fromJson(json.decode(str));

String invitionListToJson(InvitionList data) => json.encode(data.toJson());

class InvitionList {
  InvitionList({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  Data? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;

  factory InvitionList.fromJson(Map<String, dynamic> json) => InvitionList(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
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

class Data {
  Data({
    this.list,
    this.count,
  });

  List<ListElement>? list;
  Count? count;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        list: json["list"] == null
            ? null
            : List<ListElement>.from(
                json["list"].map((x) => ListElement.fromJson(x))),
        count: json["count"] == null ? null : Count.fromJson(json["count"]),
      );

  Map<String, dynamic> toJson() => {
        "list": list == null
            ? null
            : List<dynamic>.from(list!.map((x) => x.toJson())),
        "count": count == null ? null : count!.toJson(),
      };
}

class Count {
  Count({
    this.allNum,
    this.regNum,
  });

  int? allNum;
  int? regNum;

  factory Count.fromJson(Map<String, dynamic> json) => Count(
        allNum: json["all_num"] == null ? null : json["all_num"],
        regNum: json["reg_num"] == null ? null : json["reg_num"],
      );

  Map<String, dynamic> toJson() => {
        "all_num": allNum == null ? null : allNum,
        "reg_num": regNum == null ? null : regNum,
      };
}

class ListElement {
  ListElement({
    this.nickname,
    this.createdAt,
    this.register,
  });

  String? nickname;
  String? createdAt;
  String? register;

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        nickname: json["nickname"] == null ? null : json["nickname"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        register: json["register"] == null ? null : json["register"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname == null ? null : nickname,
        "created_at": createdAt == null ? null : createdAt,
        "register": register == null ? null : register,
      };
}
