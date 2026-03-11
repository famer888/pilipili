import 'package:flutter/material.dart';
import 'package:pilipili/report/app_event_report.dart';
import 'package:pilipili/report/page_name.dart';
import 'package:pilipili/report/router_observer.dart';

class PageClickListener extends StatefulWidget {
  final Widget child;

  const PageClickListener({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  State<PageClickListener> createState() => _PageClickListenerState();
}

class _PageClickListenerState extends State<PageClickListener> {
  Offset _downPosition;
  Duration _downTime;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width.toInt();
    final screenHeight = size.height.toInt();

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

        // 这里才认为是一次真正的点击
        final pageKey = MyNavObserver.instance.currentPageKey ?? 'home';
        final rawName = MyNavObserver.instance.currentRouteName ?? '首页';
        final pageName = RouterPageName.pageName[rawName] ?? rawName;

        final clickPageX = upPos.dx.toInt();
        final clickPageY = upPos.dy.toInt();

        int percent(num v, int total) {
          if (total == 0) return 0;
          final p = (v / total * 100).clamp(0, 100);
          return p.toInt();
        }

        final clickXPercent = percent(clickPageX, screenWidth);
        final clickYPercent = percent(clickPageY, screenHeight);

        final data = {
          'page_key': pageKey,
          'page_name': pageName,
          'click_page_x': clickPageX,
          'click_page_y': clickPageY,
          'click_x_percent': clickXPercent,
          'click_y_percent': clickYPercent,
          'screen_width': screenWidth,
          'screen_height': screenHeight,
        };

        AppEventReport.instance.track('page_click', data);
      },
      child: widget.child,
    );
  }
}
