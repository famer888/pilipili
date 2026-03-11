import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';

mixin WatchRecordMixin<T extends StatefulWidget> on State<T> {
  late Timer watchRcordTimer;

  @override
  void dispose() {
    super.dispose();
    CommonUtils.debugPrint('WatchRecordMixin dispose');
    removeHandleOfRecordWatch();
    stopWatchRecordTimer();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CommonUtils.debugPrint('WatchRecordMixin initState');
    handleRecordWatch();
  }

  void startWatchRecordTimer(Box theBox, int id,
      {int? chapterId,
      String? thumb,
      int? isFree,
      String? title,
      int? current, //小说  当前章节index
      dynamic offset}) {
    CommonUtils.debugPrint('startWatchRecordTimer');
    CommonUtils.debugPrint('-----上次播放至:'+offset.toString()+'');
    CommonUtils.debugPrint('send record_watch');
    EventBus().emit('record_watch', [
      theBox,
      {
        'id': id,
        'thumb': thumb,
        'is_free': isFree,
        'recordTimer': DateTime.now().millisecondsSinceEpoch,
        chapterId: offset, //视频代表播放位置  小说代表滚动位置
        'current': current,
        'isfree': isFree,
        'title': title
      },
    ]);
  }

  void stopWatchRecordTimer() {
    watchRcordTimer.cancel();
  }

  void handleRecordWatch() {
    CommonUtils.debugPrint('handleRecordWatch');
    EventBus().off('record_watch');
    EventBus().on('record_watch', (arg) {
      CommonUtils.debugPrint('on record_watch');
      Box theBox = arg[0];
      Map data = arg[1];
      theBox.put(data['id'], data);
      if (theBox.length == 100) {
        theBox.deleteAt(99);
      }
    });
  }

  void removeHandleOfRecordWatch() {
    CommonUtils.debugPrint('/*************关闭*************/');
    EventBus().off('record_watch');
  }
}
