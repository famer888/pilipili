import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

class CommentItem extends StatefulWidget {
  const CommentItem({Key key}) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  Widget commentItem() {
    return Container(
      padding: EdgeInsets.only(bottom: 8.w),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xffFFD1DF), width: 0.5.w))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.w),
            child: SizedBox(
              width: 32.w,
              height: 32.w,
              child: PlatformAwareNetworkImage(url: '', fit: BoxFit.cover),
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '天天都要看',
                    style: TextStyle(
                        color: Color(0xff646464),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: CommonUtils.vipLevel(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Text(
                      '2022.03.04',
                      style: TextStyle(
                          color: Color(0xffC2C2C2),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
              Text(
                '好看啊，好看啊好看啊好看啊，好看啊好看啊好看啊...好看啊好看啊',
                style: TextStyle(color: Color(0xff646464), fontSize: 12.sp),
              ),
              SizedBox(
                height: 8.w,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  _LikeBtn(),
                ],
              )
            ],
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 16.w, right: 16.w, top: 16.5.w, bottom: 8.w),
      child: Column(
        children: [
          commentItem(),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(56.w, 0, 0, 0),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(top: 16.5.w),
                  child: commentItem(),
                );
              })
        ],
      ),
    );
  }
}

class _LikeBtn extends StatefulWidget {
  const _LikeBtn({Key key}) : super(key: key);

  @override
  State<_LikeBtn> createState() => _LikeBtnState();
}

class _LikeBtnState extends State<_LikeBtn>
    with AutomaticKeepAliveClientMixin<_LikeBtn> {
  bool isLike = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isLike = !isLike;
        setState(() {});
      },
      child: Container(
        width: 60.w,
        height: 24.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isLike ? Color(0xffFF84A9) : Colors.white,
            borderRadius: BorderRadius.circular(8.w),
            boxShadow: [
              BoxShadow(
                  color: isLike
                      ? Color(0xffA82118).withOpacity(0.26)
                      : Color(0xffFFD3E6),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0)
            ]),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            getImage(
                'assets/images/2023/${isLike ? "icon_love" : "icon_love_red2"}.png',
                width: 10.w,
                fit: BoxFit.fitWidth,
                isAssets: true),
            SizedBox(
              width: 5.w,
            ),
            Text(
              '999',
              style: TextStyle(
                  color: isLike ? Colors.white : Color(0XFFFF84A9),
                  fontSize: 12.sp),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
