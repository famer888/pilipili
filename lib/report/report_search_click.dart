import 'package:flutter/material.dart';
import 'package:pilipili/report/app_event_report.dart';

class ReportSearchClick extends StatefulWidget {
  final Widget child;
  final Map data;
  const ReportSearchClick({Key key, this.child, this.data}) : super(key: key);

  @override
  State<ReportSearchClick> createState() => _ReportSearchClickState();
}

class _ReportSearchClickState extends State<ReportSearchClick> {
  Offset _downPosition;
  Duration _downTime;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent, // 不抢事件，内部 onTap 照常生效
      onPointerDown: (PointerDownEvent event) {
        _downPosition = event.position;
        _downTime = event.timeStamp;
      },
      onPointerUp: (PointerUpEvent event) {
        final upPos = event.position;
        final upTime = event.timeStamp;
        // 位移阈值 + 时间阈值，简单判定是“点击”而不是滑动
        const moveThreshold = 10.0; // 像素
        const timeThreshold = Duration(milliseconds: 300);

        final distance = (upPos - _downPosition).distance;
        final dt = upTime - _downTime;

        if (distance > moveThreshold || dt > timeThreshold) {
          return; // 当成滑动/长按，不上报 click
        }

        AppEventReport.instance.track('keyword_click', widget.data);
      },
      child: widget.child,
    );
  }
}
