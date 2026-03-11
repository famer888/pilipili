import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/networkImage.dart';

class CommentItem extends StatefulWidget {
  const CommentItem({Key key, this.data}) : super(key: key);
  final Map data;
  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem>
    with AutomaticKeepAliveClientMixin<CommentItem> {
  List childComment = [];
  int limit = 15;
  int page = 1;
  bool isAll = false;
  getComentList() {
    getPostCommentsChild(widget.data['id']).then((res) {
      if (isAll) return;
      List newComments = childComment;
      if (res['status'] != 0) {
        if (page == 1) {
          newComments = res['data'];
        } else {
          newComments = [...newComments, ...res['data']];
        }
        isAll = res['data'].length < limit;
        childComment = newComments;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg'] ?? '接口异常,请稍后再试');
      }
    });
  }

  Widget commentItem(Map item, {bool isMaster = false}) {
    return Container(
      padding: EdgeInsets.only(
          left: isMaster ? 16.w : 0, right: 16.w, top: 16.5.w, bottom: 8.w),
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
              child: PlatformAwareNetworkImage(
                  url: item['user'] == null
                      ? (item['thumb'] ?? '')
                      : item['user']['thumb'] ?? '',
                  fit: BoxFit.cover),
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
                    item['user'] == null ? 'plipili' : item['user']['nickname'],
                    style: TextStyle(
                        color: Color(0xff646464),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700),
                  ),
                  item['user'] != null && item['user']['vip_level'] > 0
                      ? Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: CommonUtils.vipLevel(
                              text: 'LV${item['user']['vip_level']}'),
                        )
                      : SizedBox(),
                  Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Text(
                      item['created_at'].split(' ')[0],
                      style: TextStyle(
                          color: Color(0xffC2C2C2),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
              Text(
                item['comment'] ?? item['content'],
                style: TextStyle(color: Color(0xff646464), fontSize: 12.sp),
              ),
              SizedBox(
                height: 8.w,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  _LikeBtn(
                      isNovel: item['like_num'] == null,
                      id: item['id'],
                      isLike: item['like_num'] == null
                          ? item['is_like']
                          : item['is_like'] == 1,
                      likeNum: item['like_num'] ?? item['like_count']),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commentItem(widget.data, isMaster: true),
        (widget.data['comments'] ?? widget.data['child']).isEmpty
            ? SizedBox()
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(56.w, 0, 0, 0),
                itemCount:
                    (widget.data['comments'] ?? widget.data['child']).length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(top: 16.5.w),
                    child: commentItem((widget.data['comments'] ??
                        widget.data['child'])[index]),
                  );
                })
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _LikeBtn extends StatefulWidget {
  const _LikeBtn(
      {Key key, this.isLike, this.id, this.likeNum, this.isNovel = false})
      : super(key: key);
  final bool isLike;
  final int id;
  final int likeNum;
  final bool isNovel;
  @override
  State<_LikeBtn> createState() => _LikeBtnState();
}

class _LikeBtnState extends State<_LikeBtn> {
  bool isLike = false;
  bool isTap = false;
  int likeNum = 0;
  @override
  void initState() {
    super.initState();
    isLike = widget.isLike;
    likeNum = widget.likeNum;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isTap) return;
        if (widget.isNovel) {
          commentLikeToggle(widget.id).then((res) {
            if (res['status'] != 0) {
              isLike = res['data'] == 1;
              if (isLike) {
                likeNum++;
              } else {
                likeNum--;
              }
              setState(() {});
            } else {
              CommonUtils.showText(res['msg'] ?? '系统错误，请稍后再试');
            }
          }).whenComplete(() {
            isTap = false;
          });
        } else {
          communityLike(widget.id, 'comment').then((res) {
            if (res['status'] != 0) {
              isLike = res['data']['is_like'] == 1;
              if (isLike) {
                likeNum++;
              } else {
                likeNum--;
              }
              setState(() {});
            } else {
              CommonUtils.showText(res['msg'] ?? '系统错误，请稍后再试');
            }
          }).whenComplete(() {
            isTap = false;
          });
        }
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
              likeNum.toString(),
              style: TextStyle(
                  color: isLike ? Colors.white : Color(0XFFFF84A9),
                  fontSize: 12.sp),
            )
          ],
        ),
      ),
    );
  }
}
