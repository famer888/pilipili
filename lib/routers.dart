import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/pili/search.dart';
import 'package:pilipili/components/video/video_detail.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/pages/welcome.dart';
import 'package:pilipili/components/xianmian.dart';
import 'package:pilipili/components/seconedPage.dart';

import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';

class Routes {
  static String xianmian = 'xianmian'; //home页限免页面
  static String seconedPage = 'seconedPage/:title'; // 网黄、cos、时间表等二级页面
  static String search = 'search'; // 网黄、cos、时间表等二级页面
  static String videoDetail = 'videoDetail/:id'; //长视频详情页

  static List<GoRoute> getDetailRoutes() {
    return [
      GoRoute(
        path: xianmian,
        builder: (context, state) => Xianmian(),
      ),
      GoRoute(
        path: seconedPage,
        builder: (context, state) => SeconedPage(
          title: state.params == null || state.params['title'] == null
              ? null
              : state.params['title'],
        ),
      ),
      GoRoute(path: search, builder: (context, state) => SearchPage()),
      GoRoute(
        path: videoDetail,
        builder: (context, state) {
          return VideoDetail(
              id: state.params == null || state.params['id'] == null
                  ? null
                  : int.parse(state.params['id'].toString()));
        },
      ),
    ];
  }

  static GoRouter init() {
    List<GoRoute> rootRoutes = [];
    rootRoutes.addAll(getDetailRoutes());
    return GoRouter(routerNeglect: true, routes: [
      GoRoute(
          path: '/', builder: (context, state) => Welcome(), routes: rootRoutes)
    ], observers: [
      BotToastNavigatorObserver(),
      MyNavObserver()
    ]);
  }
}

class MyNavObserver extends NavigatorObserver {
  MyNavObserver() {
    //
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route != null && route.settings != null && route.settings.name != '/') {
      AppGlobal.routerReplace = true;
    }
    if (previousRoute != null &&
        route.settings.name != null &&
        (previousRoute.str.indexOf('smallVideo') != -1 ||
            previousRoute.str.indexOf('webSmallVideo') != -1 ||
            previousRoute.str.indexOf('videoDetail') != -1)) {
      EventBus().emit('stop-current-play');
    }
    CommonUtils.debugPrint(
        'didPush: 当前路由=${route.settings.name}, previousRoute= ${previousRoute?.settings?.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute != null &&
        previousRoute.settings != null &&
        previousRoute.settings.name == '/') {
      AppGlobal.routerReplace = false;
    }
    CommonUtils.debugPrint(
        'didPop: ${route.str} result: ${route?.settings?.name}, 当前路由= ${previousRoute?.settings?.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) =>
      CommonUtils.debugPrint(
          'didRemove: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) =>
      CommonUtils.debugPrint(
          'didReplace: new= ${newRoute?.str}, old= ${oldRoute?.str}');

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic> previousRoute,
  ) =>
      CommonUtils.debugPrint('didStartUserGesture: ${route.str}, '
          'previousRoute= ${previousRoute?.str}');

  @override
  void didStopUserGesture() => CommonUtils.debugPrint('didStopUserGesture');
}

extension on Route<dynamic> {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}
