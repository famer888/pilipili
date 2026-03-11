// To parse this JSON data, do
//
//     final updateNumModel = updateNumModelFromJson(jsonString);

import 'dart:convert';

UpdateNumModel updateNumModelFromJson(String str) =>
    UpdateNumModel.fromJson(json.decode(str));

String updateNumModelToJson(UpdateNumModel data) => json.encode(data.toJson());

class UpdateNumModel {
  UpdateNumModel({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
    this.line,
  });

  Data? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;
  String? line;

  factory UpdateNumModel.fromJson(Map<String, dynamic> json) => UpdateNumModel(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        msg: json["msg"],
        crypt: json["crypt"],
        isVip: json["isVip"],
        line: json["line"],
      );

  Map<String, dynamic> toJson() => {
        "data": data!.toJson(),
        "status": status,
        "msg": msg,
        "crypt": crypt,
        "isVip": isVip,
        "line": line,
      };
}

class Data {
  Data({
    this.mvNum,
    this.smvNum,
    this.bookNum,
    this.mhNum,
    this.storyNum,
    this.picNum,
    this.girlNum,
  });

  int? mvNum;
  int? smvNum;
  int? bookNum;
  int? mhNum;
  int? storyNum;
  int? picNum;
  int? girlNum;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        mvNum: json["mvNum"],
        smvNum: json["smvNum"],
        bookNum: json["bookNum"],
        mhNum: json["mhNum"],
        storyNum: json["storyNum"],
        picNum: json["picNum"],
        girlNum: json["girlNum"],
      );

  Map<String, dynamic> toJson() => {
        "mvNum": mvNum,
        "smvNum": smvNum,
        "bookNum": bookNum,
        "mhNum": mhNum,
        "storyNum": storyNum,
        "picNum": picNum,
        "girlNum": girlNum,
      };
}
