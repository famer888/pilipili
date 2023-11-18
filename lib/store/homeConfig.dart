import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pilipili/model/homedata.dart';
import 'package:pilipili/model/systemnotice.dart';
import 'package:pilipili/utils/common.dart';

class GetConfig {
  static String imagePath;
}

class HomeConfig with ChangeNotifier, DiagnosticableTreeMixin {
  VersionMsg _versionMsg;
  Ads _ads;
  Notice _notice;
  Config _config;
  Member _member;
  bool _darkPrivilege;
  String _darkprivilegeTips;
  SystemNotice _systemNotice;
  Map _privilege;
  int _chatMoney;

  SystemNotice get systemnotice => _systemNotice;
  Member get member => _member;
  Notice get notice => _notice;
  Config get config => _config;
  Ads get ads => _ads;
  VersionMsg get versionMsg => _versionMsg;
  Map get privilege => _privilege;
  bool get darkPrivilege => _darkPrivilege;
  String get darkprivilegeTips => _darkprivilegeTips;
  int get chatMoney => _chatMoney;

  void setDarkPrivilegeTips(String text) {
    _darkprivilegeTips = text;
    notifyListeners();
  }

  void setDarkPrivilege(bool isDark) {
    _darkPrivilege = isDark;
    notifyListeners();
  }

  void setPrivilege(Map data) {
    _privilege = data;
    notifyListeners();
  }

  void setSystemNotice(dynamic data) {
    _systemNotice = data;
    notifyListeners();
  }

  void setMoney(dynamic newMoney) {
    _member.money = newMoney;
    notifyListeners();
  }

  void setInviteBy(dynamic inviteBy) {
    _member.invitedBy = inviteBy;
    notifyListeners();
  }

  void setIsSetpassword(int status) {
    _member.isSetPassword = status;
    notifyListeners();
  }

  void setNickname(dynamic nickname) {
    _member.nickname = nickname;
    notifyListeners();
  }

  void setAvatar(dynamic url) {
    _member.thumb = url;
    notifyListeners();
  }

  void setNotice(dynamic newNotice) {
    _notice = newNotice;
    notifyListeners();
  }

  void setMember(Member newData) {
    _member = newData;
    notifyListeners();
  }

  void setVersionMsg(VersionMsg newVersionMsg) {
    _versionMsg = newVersionMsg;
    notifyListeners();
  }

  void setAbs(Ads newAbs) {
    _ads = newAbs;
    notifyListeners();
  }

  void setConfig(Config newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void setLevel(dynamic value) {
    _member.level = value;
    notifyListeners();
  }

  void setAgent(dynamic value) {
    _member.agent = value;
    notifyListeners();
  }

  void setInvitation(dynamic invitation) {
    _member.invitedBy = invitation;
    notifyListeners();
  }

  void setChatMoney(BuildContext context, int coin) {
    _chatMoney = coin;
    notifyListeners();
  }

  static setUserCoins(BuildContext context, int coin) async {
    Provider.of<HomeConfig>(context, listen: false).setMoney(coin);
  }
}
