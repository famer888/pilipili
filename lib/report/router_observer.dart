import 'package:flutter/material.dart';
import 'package:pilipili/report/page_name.dart';
import 'package:pilipili/report/report_utils.dart';
import 'package:pilipili/utils/common.dart';

import 'page_request_tracker.dart';

class MyNavObserver extends NavigatorObserver {
  MyNavObserver._internal();
  static final MyNavObserver instance = MyNavObserver._internal();

  Route<dynamic>? _currentRoute;
  int? _enterTimeMs;
  String? _fromPageName;
  String? _fromPageKey; // 上一个页面的 key

  String? get currentRouteName {
    final name = _cleanRouteName(_currentRoute?.settings.name);
    return name.isEmpty ? null : name;
  }

  String? get fromPageName => _fromPageName;
  String? get fromPageKey => _fromPageKey;

  String? get currentPageKey {
    return _currentRoute != null ? _buildPageKey(_currentRoute!) : null;
  }

  int get currentEnterTimeMs => _enterTimeMs ?? 0;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _endPage(_currentRoute);
    _startPage(route, previousRoute);

    CommonUtils.debugPrint(
      'didPush: 当前路由=${route.settings.name}, previousRoute=${previousRoute != null ? previousRoute.settings.name : null}',
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    if (route == _currentRoute) {
      _endPage(route);
    }
    if (previousRoute != null) _startPage(previousRoute, route);
  
    CommonUtils.debugPrint(
      'didPop: ${route.str} 当前路由=${previousRoute != null ? previousRoute.settings.name : null}',
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);

    if (route == _currentRoute) {
      _endPage(route);
      if (previousRoute != null) _startPage(previousRoute, route);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    if (oldRoute == _currentRoute && oldRoute != null) {
      _endPage(oldRoute);
    }
    if (newRoute != null) _startPage(newRoute, oldRoute);
  }

  String _cleanRouteName(String? name) {
    if (name == null || name.isEmpty || name == 'unknown') return 'home';
    try {
      name = name.split('/')[1];
      if (name.isEmpty) name = 'home';
      return name;
    } catch (e) {
      return '';
    }
  }

  void _startPage(Route route, Route? fromRoute) {
    final name = _cleanRouteName(route.settings.name);
    if (name.isEmpty) return;

    _fromPageName = fromRoute != null ? _cleanRouteName(fromRoute.settings.name) : null;
    _fromPageKey = fromRoute != null ? _buildPageKey(fromRoute) : null;
  
    _currentRoute = route;
    _enterTimeMs = DateTime.now().millisecondsSinceEpoch;

    final key = _buildPageKey(route);
    PageRequestTracker.instance.onPageEnter(key, _enterTimeMs!);

    CommonUtils.debugPrint(
      '[PageTracker] 进入页面: name=$name, key=$key, 来自页面=$_fromPageName, 来自key=$_fromPageKey',
    );
  }

  void _endPage(Route? route) {
    if (route == null) return;
    final rawName = _cleanRouteName(route.settings.name);
    if (rawName.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final stayMs = now - (_enterTimeMs ?? now);

    final key = _buildPageKey(route);
    final pageName = RouterPageName.pageName[rawName] ?? rawName;
    final fromName = RouterPageName.pageName[_fromPageName] ?? _fromPageName;

    PageRequestTracker.instance.onPageLeave(
      key,
      _enterTimeMs ?? now,
      onInitDuration: (initMs) {
        ReportUtils.appPageView(
          pageKey: key,
          pageName: pageName,
          referrerPageKey: _fromPageKey,
          referrerPageName: fromName,
          currentPageKey: key,
          currentPageName: pageName,
          pageLoadTimeSec: initMs,
          stayTimeMs: stayMs,
        );
      },
    );

    if (route == _currentRoute) {
      _currentRoute = null;
      _enterTimeMs = null;
      _fromPageName = null;
      _fromPageKey = null;
    }
  }

  String _buildPageKey(Route route) {
    final name = _cleanRouteName(route.settings.name);
    final args = route.settings.arguments;

    if (args is Map && args['pageKey'] is String) {
      return args['pageKey'];
    }
    return name;
  }
}

extension on Route {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}
