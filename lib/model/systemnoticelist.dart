import 'dart:convert';

SystemNoticeList systemNoticeListFromJson(String str) =>
    SystemNoticeList.fromJson(json.decode(str));

String systemNoticeListToJson(SystemNoticeList data) =>
    json.encode(data.toJson());

class SystemNoticeList {
  SystemNoticeList({
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

  factory SystemNoticeList.fromJson(Map<String, dynamic> json) =>
      SystemNoticeList(
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
            : List<dynamic>.from(data.map((x) => x.toJson())),
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
    this.content,
    this.read,
    this.createdAt,
    this.updatedAt,
    this.title,
  });

  int id;
  int aff;
  String content;
  int read;
  dynamic createdAt;
  dynamic updatedAt;
  String title;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] == null ? null : json["id"],
        aff: json["aff"] == null ? null : json["aff"],
        content: json["content"] == null ? null : json["content"],
        read: json["read"] == null ? null : json["read"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        title: json["title"] == null ? null : json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "aff": aff == null ? null : aff,
        "content": content == null ? null : content,
        "read": read == null ? null : read,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "title": title == null ? null : title,
      };
}
