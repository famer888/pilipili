import 'dart:convert';

CoinOrVipModel coinOrVipModelFromJson(String str) =>
    CoinOrVipModel.fromJson(json.decode(str));

String coinOrVipModelToJson(CoinOrVipModel data) => json.encode(data.toJson());

class CoinOrVipModel {
  CoinOrVipModel({
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

  factory CoinOrVipModel.fromJson(Map<String, dynamic> json) => CoinOrVipModel(
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
    this.uuid,
    this.oauthType,
    this.productId,
    this.appOrder,
    this.descp,
    this.orderType,
    this.amount,
    this.payAmount,
    this.payway,
    this.payUrl,
    this.status,
    this.msg,
    this.channel,
    this.updatedAt,
    this.createdAt,
    this.expiredAt,
    this.payType,
    this.descImg,
    this.giftDiamond,
    this.buildId,
    this.statusText,
  });

  int? id;
  String? uuid;
  String? oauthType;
  int? productId;
  String? appOrder;
  String? descp;
  int? orderType;
  String? amount;
  String? payAmount;
  String? payway;
  String? payUrl;
  int? status;
  String? msg;
  String? channel;
  String? updatedAt;
  String? createdAt;
  int? expiredAt;
  String? payType;
  String? descImg;
  int? giftDiamond;
  String? buildId;
  String? statusText;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] == null ? null : json["id"],
        uuid: json["uuid"] == null ? null : json["uuid"],
        oauthType: json["oauth_type"] == null ? null : json["oauth_type"],
        productId: json["product_id"] == null ? null : json["product_id"],
        appOrder: json["app_order"] == null ? null : json["app_order"],
        descp: json["descp"] == null ? null : json["descp"],
        orderType: json["order_type"] == null ? null : json["order_type"],
        amount: json["amount"] == null ? null : json["amount"],
        payAmount: json["pay_amount"] == null ? null : json["pay_amount"],
        payway: json["payway"] == null ? null : json["payway"],
        payUrl: json["pay_url"] == null ? null : json["pay_url"],
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        channel: json["channel"] == null ? null : json["channel"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        expiredAt: json["expired_at"] == null ? null : json["expired_at"],
        payType: json["pay_type"] == null ? null : json["pay_type"],
        descImg: json["desc_img"] == null ? null : json["desc_img"],
        giftDiamond: json["gift_diamond"] == null ? null : json["gift_diamond"],
        buildId: json["build_id"] == null ? null : json["build_id"],
        statusText: json["status_text"] == null ? null : json["status_text"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "uuid": uuid == null ? null : uuid,
        "oauth_type": oauthType == null ? null : oauthType,
        "product_id": productId == null ? null : productId,
        "app_order": appOrder == null ? null : appOrder,
        "descp": descp == null ? null : descp,
        "order_type": orderType == null ? null : orderType,
        "amount": amount == null ? null : amount,
        "pay_amount": payAmount == null ? null : payAmount,
        "payway": payway == null ? null : payway,
        "pay_url": payUrl == null ? null : payUrl,
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "channel": channel == null ? null : channel,
        "updated_at": updatedAt == null ? null : updatedAt,
        "created_at": createdAt == null ? null : createdAt,
        "expired_at": expiredAt == null ? null : expiredAt,
        "pay_type": payType == null ? null : payType,
        "desc_img": descImg == null ? null : descImg,
        "gift_diamond": giftDiamond == null ? null : giftDiamond,
        "build_id": buildId == null ? null : buildId,
        "status_text": statusText == null ? null : statusText,
      };
}
