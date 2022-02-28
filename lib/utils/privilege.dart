// 一级权限
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youyutv/store/homeConfig.dart';
import 'package:youyutv/utils/common.dart';

const RESOURCE_TYPE_LONG_VIDEO = 1; // 长视频
const RESOURCE_TYPE_SHORT_VIDEO = 2; // 短视频
const RESOURCE_TYPE_CARTOON_VIDEO = 3; // 动漫视频
const RESOURCE_TYPE_BOOK = 4; // 漫画
const RESOURCE_TYPE_STORY = 5; // 小说
const RESOURCE_TYPE_PIC = 6; // 图集
const RESOURCE_TYPE_GIRL = 7; // 楼凤
const RESOURCE_TYPE_GIRL_AGENT = 8; // 约炮
const RESOURCE_TYPE_GIRL_CHAT = 9; // 裸聊
const RESOURCE_TYPE_SYSTEM = 10; // 系统权限（换头像，改昵称，客服使用权限）

// 二级嵌套权限（资源类）
const PRIVILEGE_TYPE_VIEW = 1; // 查看权限 使用isAllowedWithCount
const PRIVILEGE_TYPE_DOWNLOAD = 2; // 下载权限 使用isAllowedWithCount
const PRIVILEGE_TYPE_COMMENT = 3; // 评论权限 使用isAllowed
const PRIVILEGE_TYPE_DISCOUNT = 4; // 金币折扣 使用getDiscount
const PRIVILEGE_TYPE_UNLOCK = 5; // 解锁权限 使用isAllowedWithCount
const PRIVILEGE_TYPE_SETTING = 6; // 换头像和昵称 使用isAllowed
const PRIVILEGE_TYPE_FEED = 7; // 在线客服 使用isAllowed

class Privilege {
  // 判断是否有权限
  static bool isAllowed(
      BuildContext context, int resourceType, int privilegeType) {
    Map _privilege = Provider.of<HomeConfig>(context, listen: false).privilege;
    CommonUtils.debugPrint(_privilege);
    if (_privilege['data']['$resourceType']['$privilegeType']['status'] == 1) {
      return true;
    }
    return false;
  }

  static int getCount(
      BuildContext context, int resourceType, int privilegeType) {
    Map _privilege = Provider.of<HomeConfig>(context, listen: false).privilege;
    return _privilege['data']['$resourceType']['$privilegeType']['value'];
  }

  // 判断是否有权限, 需要判断次数的权限
  static bool isAllowedWithCount(
      BuildContext context, int resourceType, int privilegeType) {
    Map _privilege = Provider.of<HomeConfig>(context, listen: false).privilege;
    if (_privilege['data']['$resourceType']['$privilegeType']['status'] == 1) {
      if (_privilege['data']['$resourceType']['$privilegeType']['value'] > 0) {
        if (_privilege['data']['$resourceType']['$privilegeType']['value'] != 9999) {
          _privilege['data']['$resourceType']['$privilegeType']['value'] =
              _privilege['data']['$resourceType']['$privilegeType']['value'] - 1;
          Provider.of<HomeConfig>(context, listen: false)
              .setPrivilege(_privilege);
        }
        return true;
      }
    }
    return false;
  }

  // 获取折扣
  static double getDiscount(
      BuildContext context, int resourceType, int privilegeType) {
    Map _privilege = Provider.of<HomeConfig>(context, listen: false).privilege;
    if (_privilege['data']['$resourceType']['$privilegeType']['status'] == 1) {
      return double.parse(
              _privilege['data']['$resourceType']['$privilegeType']['value']) /
          100;
    }
    return 1.00;
  }
}
