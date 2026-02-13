// To parse this JSON data, do
//
//     final taskIndex = taskIndexFromJson(jsonString);

class TaskHomeData {
  int score;
  int invitedNum;
  List<Task> task;
  List<Product> product;
  int freeViewCnt;
  int totalFreeViewCnt;

  TaskHomeData({this.score, this.invitedNum, this.task, this.product, this.freeViewCnt, this.totalFreeViewCnt});

  factory TaskHomeData.fromJson(Map<String, dynamic> json) => TaskHomeData(
        score: json["score"],
        invitedNum: json["invited_num"],
        task: List<Task>.from(json["task"].map((x) => Task.fromJson(x))),
        product: List<Product>.from(json["product"].map((x) => Product.fromJson(x))),
        freeViewCnt: json['free_view_cnt'] ?? 0,
        totalFreeViewCnt: json['total_free_view_cnt'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "free_view_cnt": freeViewCnt,
        "total_free_view_cnt": totalFreeViewCnt,
        "score": score,
        "invited_num": invitedNum,
        "task": List<dynamic>.from(task.map((x) => x.toJson())),
        "product": List<dynamic>.from(product.map((x) => x.toJson())),
      };
}

class Product {
  int id;
  int type;
  String pname;
  String img;
  String secondImg;
  String price;
  String promoPrice;
  dynamic promoExpireTime;
  int discount;
  int validDate;
  int coins;
  int freeCoins;
  int forever;
  int relatedSuperGoldCardId;
  int status;
  int sortOrder;
  String description;
  DateTime updatedAt;
  DateTime createdAt;
  int vipLevel;
  int showMore;
  int giveCoinsTotalDays;
  int dailyGiveCoins;
  String imgUrl;
  String secondImgUrl;
  dynamic right;
  List<dynamic> pay;

  Product({
    this.id,
    this.type,
    this.pname,
    this.img,
    this.secondImg,
    this.price,
    this.promoPrice,
    this.promoExpireTime,
    this.discount,
    this.validDate,
    this.coins,
    this.freeCoins,
    this.forever,
    this.relatedSuperGoldCardId,
    this.status,
    this.sortOrder,
    this.description,
    this.updatedAt,
    this.createdAt,
    this.vipLevel,
    this.showMore,
    this.giveCoinsTotalDays,
    this.dailyGiveCoins,
    this.imgUrl,
    this.secondImgUrl,
    this.right,
    this.pay,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        type: json["type"],
        pname: json["pname"],
        img: json["img"],
        secondImg: json["second_img"],
        price: json["price"],
        promoPrice: json["promo_price"],
        promoExpireTime: json["promo_expire_time"],
        discount: json["discount"],
        validDate: json["valid_date"],
        coins: json["coins"],
        freeCoins: json["free_coins"],
        forever: json["forever"],
        relatedSuperGoldCardId: json["related_super_gold_card_id"],
        status: json["status"],
        sortOrder: json["sort_order"],
        description: json["description"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        vipLevel: json["vip_level"],
        showMore: json["show_more"],
        giveCoinsTotalDays: json["give_coins_total_days"],
        dailyGiveCoins: json["daily_give_coins"],
        imgUrl: json["img_url"],
        secondImgUrl: json["second_img_url"],
        right: json["right"],
        pay: List<dynamic>.from(json["pay"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "pname": pname,
        "img": img,
        "second_img": secondImg,
        "price": price,
        "promo_price": promoPrice,
        "promo_expire_time": promoExpireTime,
        "discount": discount,
        "valid_date": validDate,
        "coins": coins,
        "free_coins": freeCoins,
        "forever": forever,
        "related_super_gold_card_id": relatedSuperGoldCardId,
        "status": status,
        "sort_order": sortOrder,
        "description": description,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "vip_level": vipLevel,
        "show_more": showMore,
        "give_coins_total_days": giveCoinsTotalDays,
        "daily_give_coins": dailyGiveCoins,
        "img_url": imgUrl,
        "second_img_url": secondImgUrl,
        "right": right,
        "pay": List<dynamic>.from(pay.map((x) => x)),
      };
}

class Task {
  int id;
  String title;
  String description;
  int group;
  String icon;
  int day;
  String url;
  int point;
  int sort;
  int completed;

  Task({
    this.id,
    this.title,
    this.description,
    this.group,
    this.icon,
    this.day,
    this.url,
    this.point,
    this.sort,
    this.completed,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        group: json["group"],
        icon: json["icon"],
        day: json["day"],
        url: json["url"],
        point: json["point"],
        sort: json["sort"],
        completed: json["completed"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "group": group,
        "icon": icon,
        "day": day,
        "url": url,
        "point": point,
        "sort": sort,
        "completed": completed,
      };
}
