import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/model/recommendComics.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pp_string.dart';

class NewComicsCard extends StatefulWidget {
  final Datum cardData;
  final bool relace;
  final double width;
  NewComicsCard({Key key, this.cardData, this.relace = false, this.width})
      : super(key: key);

  @override
  _NewComicsCardState createState() => _NewComicsCardState();
}

class _NewComicsCardState extends State<NewComicsCard> {
  double _height;
  String tags = '';
  @override
  void initState() {
    super.initState();
    _height = (widget.width / 109) * 152;
  }

  Color randomColor() {
    return Color.fromARGB(255, Random().nextInt(256) + 0,
        Random().nextInt(256) + 0, Random().nextInt(256) + 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.relace) {
          context.push(
              CommonUtils.getRealHash().replaceAll(RegExp("${PPString.test}comicsdetail/.*"),
                  'comicsdetail/' + widget.cardData.datumId.toString()),
              replace: widget.relace);
        } else {
          context.push(CommonUtils.getRealHash(
              'comicsdetail/' + widget.cardData.datumId.toString()));
        }
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(5))),
        width: widget.width,
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: widget.width,
              height: _height,
              child: PlatformAwareNetworkImage(
                url: widget.cardData == null ? null : widget.cardData.thumb,
                filterQuality: FilterQuality.medium,
                fit: BoxFit.cover,
              ),
            ),
            Container(
                width: widget.width,
                margin: EdgeInsets.only(top: ScreenUtil().setWidth(4)),
                child: Text(
                    widget.cardData == null
                        ? PPString.isnull
                        : widget.cardData.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: Color(0xff646464),
                        fontSize: ScreenUtil().setSp(14)))),
          ],
        )),
      ),
    );
  }

  tagItem(String text) {
    return Padding(
      padding: EdgeInsets.only(
        right: ScreenUtil().setWidth(5),
        bottom: ScreenUtil().setWidth(5),
      ),
      child: Text(text,
          style: TextStyle(
            color: Color(0xff666666),
            fontSize: ScreenUtil().setSp(13),
          )),
    );
  }
}
