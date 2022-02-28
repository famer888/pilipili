// To parse this JSON data, do
//
//     final element = elementFromJson(jsonString);

import 'dart:convert';

import 'package:youyutv/utils/common.dart';

class ElementModel {
  ElementModel({
    this.id,
    this.constructId,
    this.type,
    this.contentType,
    this.title,
    this.moreButton,
    this.morePageShowType,
    this.maxNum,
    this.showField,
    this.changeButton,
    this.sort,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.value,
  });

  int id;
  int constructId;
  int type;
  int contentType;
  String title;
  int moreButton;
  int morePageShowType;
  int maxNum;
  String showField;
  int changeButton;
  int sort;
  int status;
  String createdAt;
  String updatedAt;
  List value;

  factory ElementModel.fromJson(Map<String, dynamic> json) {
    return ElementModel(
      id: json["id"],
      constructId: json["construct_id"],
      type: json["type"],
      contentType: json["content_type"],
      title: json["title"],
      moreButton: json["more_button"],
      morePageShowType: json["more_page_show_type"],
      maxNum: json["max_num"],
      showField: json["show_field"],
      changeButton: json["change_button"],
      sort: json["sort"],
      status: json["status"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      value: json["value"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "construct_id": constructId,
        "type": type,
        "content_type": contentType,
        "title": title,
        "more_button": moreButton,
        "more_page_show_type": morePageShowType,
        "max_num": maxNum,
        "show_field": showField,
        "change_button": changeButton,
        "sort": sort,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "value": value,
      };
}

class LinkModel {
  LinkModel({
    this.id,
    this.relatedId,
    this.elementId,
    this.linkUrl,
    this.resourceUrl,
    this.redirectType,
    this.name,
    this.desc,
    this.sort,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  dynamic relatedId;
  int elementId;
  String linkUrl;
  String resourceUrl;
  int redirectType;
  String name;
  String desc;
  int sort;
  String createdAt;
  String updatedAt;

  factory LinkModel.fromJson(Map<String, dynamic> json) => LinkModel(
        id: json["id"],
        relatedId: json["related_id"],
        elementId: json["element_id"],
        linkUrl: json["link_url"],
        resourceUrl: json["resource_url"],
        redirectType: json["redirect_type"],
        name: json["name"],
        desc: json["desc"],
        sort: json["sort"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "related_id": relatedId,
        "element_id": elementId,
        "link_url": linkUrl,
        "resource_url": resourceUrl,
        "redirect_type": redirectType,
        "name": name,
        "desc": desc,
        "sort": sort,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
