// To parse this JSON data, do
//
//     final constructModel = constructModelFromJson(jsonString);

import 'dart:convert';

ConstructModel constructModelFromJson(String str) => ConstructModel.fromJson(json.decode(str));

String constructModelToJson(ConstructModel data) => json.encode(data.toJson());

class ConstructModel {
    ConstructModel({
        this.id,
        this.name,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.elements,
    });

    int id;
    String name;
    int status;
    String createdAt;
    String updatedAt;
    List<dynamic> elements;

    factory ConstructModel.fromJson(Map<String, dynamic> json) => ConstructModel(
        id: json["id"],
        name: json["name"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        elements: json["elements"] != null ? List<dynamic>.from(json["elements"].map((x) => x)) : [],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "elements": List<dynamic>.from(elements.map((x) => x)),
    };
}
