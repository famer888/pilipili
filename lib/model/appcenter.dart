import 'dart:convert';

AppCenterModel appCenterModelFromJson(String str) => AppCenterModel.fromJson(json.decode(str));

String appCenterModelToJson(AppCenterModel data) => json.encode(data.toJson());

class AppCenterModel {
  AppCenterModel({
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

  factory AppCenterModel.fromJson(Map<String, dynamic> json) => AppCenterModel(
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
    this.banner,
    this.apps,
  });

  List banner;
  List apps;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        banner: json["banner"] ?? [],
        apps: json["apps"] ?? [],
      );

  Map<String, dynamic> toJson() => {
        "banner": banner ?? [],
        "apps": apps ?? [],
      };
}

class App {
  App({
    this.id,
    this.title,
    this.description,
    this.imgUrl,
    this.linkUrl,
    this.clicked,
    this.createdAt,
  });

  int id;
  String title;
  String description;
  String imgUrl;
  String linkUrl;
  int clicked;
  CreatedAt createdAt;

  factory App.fromJson(Map<String, dynamic> json) => App(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        imgUrl: json["img_url"] == null ? null : json["img_url"],
        linkUrl: json["link_url"] == null ? null : json["link_url"],
        clicked: json["clicked"] == null ? null : json["clicked"],
        createdAt: json["created_at"] == null ? null : createdAtValues.map[json["created_at"]],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "img_url": imgUrl == null ? null : imgUrl,
        "link_url": linkUrl == null ? null : linkUrl,
        "clicked": clicked == null ? null : clicked,
        "created_at": createdAt == null ? null : createdAtValues.reverse[createdAt],
      };
}

enum CreatedAt { THE_19700101 }

final createdAtValues = EnumValues({"1970/01/01": CreatedAt.THE_19700101});

class Banner {
  Banner({
    this.id,
    this.title,
    this.description,
    this.imgUrl,
    this.url,
    this.position,
    this.androidDownUrl,
    this.iosDownUrl,
    this.type,
    this.status,
    this.oauthType,
    this.mvM3U8,
    this.channel,
    this.createdAt,
    this.imgFullUrl,
  });

  int id;
  String title;
  String description;
  String imgUrl;
  String url;
  int position;
  String androidDownUrl;
  String iosDownUrl;
  int type;
  int status;
  int oauthType;
  String mvM3U8;
  String channel;
  DateTime createdAt;
  String imgFullUrl;

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        imgUrl: json["img_url"] == null ? null : json["img_url"],
        url: json["url"] == null ? null : json["url"],
        position: json["position"] == null ? null : json["position"],
        androidDownUrl: json["android_down_url"] == null ? null : json["android_down_url"],
        iosDownUrl: json["ios_down_url"] == null ? null : json["ios_down_url"],
        type: json["type"] == null ? null : json["type"],
        status: json["status"] == null ? null : json["status"],
        oauthType: json["oauth_type"] == null ? null : json["oauth_type"],
        mvM3U8: json["mv_m3u8"] == null ? null : json["mv_m3u8"],
        channel: json["channel"] == null ? null : json["channel"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        imgFullUrl: json["img_full_url"] == null ? null : json["img_full_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "img_url": imgUrl == null ? null : imgUrl,
        "url": url == null ? null : url,
        "position": position == null ? null : position,
        "android_down_url": androidDownUrl == null ? null : androidDownUrl,
        "ios_down_url": iosDownUrl == null ? null : iosDownUrl,
        "type": type == null ? null : type,
        "status": status == null ? null : status,
        "oauth_type": oauthType == null ? null : oauthType,
        "mv_m3u8": mvM3U8 == null ? null : mvM3U8,
        "channel": channel == null ? null : channel,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "img_full_url": imgFullUrl == null ? null : imgFullUrl,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
