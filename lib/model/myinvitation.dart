import 'dart:convert';

MyInvitationModel myInvitationModelFromJson(String str) =>
    MyInvitationModel.fromJson(json.decode(str));

String myInvitationModelToJson(MyInvitationModel data) =>
    json.encode(data.toJson());

class MyInvitationModel {
  MyInvitationModel({
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

  factory MyInvitationModel.fromJson(Map<String, dynamic> json) =>
      MyInvitationModel(
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
    this.allNum,
    this.regNum,
    this.moneyNum,
  });

  int? allNum;
  int? regNum;
  int? moneyNum;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        allNum: json["all_num"] == null ? null : json["all_num"],
        regNum: json["reg_num"] == null ? null : json["reg_num"],
        moneyNum: json["money_num"] == null ? null : json["money_num"],
      );

  Map<String, dynamic> toJson() => {
        "all_num": allNum == null ? null : allNum,
        "reg_num": regNum == null ? null : regNum,
        "money_num": moneyNum == null ? null : moneyNum,
      };
}
