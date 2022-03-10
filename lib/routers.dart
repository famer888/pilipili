import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/comics/comicReader.dart';
import 'package:pilipili/components/comics/comics_detail.dart';
import 'package:pilipili/components/pili/search.dart';
import 'package:pilipili/components/video/small_video.dart';
import 'package:pilipili/components/video/video_detail.dart';
import 'package:pilipili/components/video/web_small_video.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/pages/login/index.dart';
import 'package:pilipili/pages/login/register.dart';
import 'package:pilipili/pages/mine/fill_code.dart';
import 'package:pilipili/pages/mine/setup.dart';
import 'package:pilipili/pages/welcome.dart';
import 'package:pilipili/pages/mine/collect.dart';
import 'package:pilipili/pages/mine/down_page.dart';
import 'package:pilipili/pages/mine/coinRecharge.dart';
import 'package:pilipili/pages/mine/coin_detail.dart';

import 'package:pilipili/components/xianmian.dart';
import 'package:pilipili/components/activityList.dart';
import 'package:pilipili/components/activityDetail.dart';
import 'package:pilipili/components/seconedPage.dart';
import 'package:pilipili/components/seconedPageDetail.dart';
import 'package:pilipili/components/morePage.dart';

import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';

import 'mixin/message_center.dart';

class Routes {
  static String xianmian = 'xianmian'; //home页限免页面
  static String seconedPage = 'seconedPage/:title'; // 网黄、cos、时间表等二级页面
  static String seconedPageDetail =
      'seconedPageDetail/:title'; // 网黄、cos、时间表等二级页面详情
  static String search = 'search'; // 网黄、cos、时间表等二级页面
  static String activityList = 'activityList'; // 精彩活动列表
  static String activityDetail = 'activityDetail/:id'; // 精彩活动详情
  static String videoDetail = 'videoDetail/:id'; //长视频详情页
  static String morePage = 'morePage/:id/:title/:morePageType'; //更多列表
  static String login = 'login'; //登陆页面
  static String register = 'register/:type'; //注册找回密码
  static String setup = 'setup'; //设置
  static String smallVideo = 'smallVideo/:id'; //短视频
  static String webSmallVideo = 'webSmallVideo/:id'; //短视频
  static String fillcode = 'fillcode'; //填写邀请码兑换码
  static String messagecenter = 'messagecenter'; // 消息中心

  static String comicsdetail = 'comicsdetail/:id'; // 漫画详情
  static String comicReader = 'comicReader/:chapid'; // 漫画阅读器
  static String localVideoDetail = 'localVideoDetail/:id'; //长视频本地详情页
  static String localSmallVideoDetail = 'localSmallVideoDetail/:id'; //小视频本地详情页
  static String localComicsDetatl = 'localComicsDetatl'; //漫画本地详情页
  static String localComicsReader = 'localComicsReader'; //漫画本地阅读器
  static String collect = 'collect'; //我的收藏
  static String down_page = 'down_page'; //我的下载
  static String coinRecharge = 'coinRecharge'; //皮哩币充值
  static String coinDetail = 'coinDetail'; //皮哩币明细

  static List<GoRoute> getDetailRoutes() {
    return [
      GoRoute(
        path: smallVideo,
        builder: (context, state) {
          final args = AppGlobal.currentDetailRouteExtra;
          return SmallVideo(
              videoData: args == null || args['videoData'] == null
                  ? null
                  : args['videoData'],
              elementId: args == null || args['elementId'] == null
                  ? null
                  : int.parse(args['elementId'].toString()),
              page: args == null || args['page'] == null
                  ? null
                  : int.parse(args['page'].toString()),
              id: args == null || args['id'] == null
                  ? null
                  : int.parse(args['id'].toString()));
        },
      ),
      GoRoute(
        path: webSmallVideo,
        builder: (context, state) {
          final args = AppGlobal.currentDetailRouteExtra;
          return WebSmallVideo(
              videoData: args == null || args['videoData'] == null
                  ? null
                  : args['videoData'],
              elementId: args == null || args['elementId'] == null
                  ? null
                  : int.parse(args['elementId'].toString()),
              page: args == null || args['page'] == null
                  ? null
                  : int.parse(args['page'].toString()),
              id: args == null || args['id'] == null
                  ? null
                  : int.parse(args['id'].toString()));
        },
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
      GoRoute(path: login, builder: (context, state) => LoginPage(), routes: [
        GoRoute(
          path: register,
          builder: (context, state) => Register(
              type: state.params == null || state.params['type'] == null
                  ? null
                  : int.parse(state.params['type'].toString())),
        ),
      ]),
      GoRoute(
        path: setup,
        builder: (context, state) => SetupPage(),
        routes: [
          GoRoute(
              path: fillcode,
              builder: (context, state) {
                final args = state.extra as Map<String, dynamic>;
                return FillCodePage(args: args);
              }),
        ],
      ),
      GoRoute(
        path: messagecenter,
        builder: (context, state) => MessageCenter(),
        // routes: [
        //   GoRoute(
        //     path: noticemessage,
        //     builder: (context, state) {
        //       final args = state.extra as Map<String, dynamic>;
        //       return NoticeMessage(args: args);
        //     },
        //   ),
        //   GoRoute(
        //     path: customerService,
        //     builder: (context, state) => CustomerService(),
        //   ),
        // ],
      ),
      GoRoute(
          path: comicsdetail,
          builder: (context, state) {
            return ComicsDetatl(
                id: state.params == null || state.params['id'] == null
                    ? null
                    : int.parse(state.params['id'].toString()));
          },
          routes: [
            GoRoute(
              path: comicReader,
              builder: (context, state) {
                final args = AppGlobal.currentReaderRouteExtra;
                return ComicReader(
                  id: args == null || args['id'] == null
                      ? null
                      : int.parse(args['id'].toString()),
                  episode: args == null || args['episode'] == null
                      ? null
                      : int.parse(args['episode'].toString()),
                  allEpisode: args == null || args['allEpisode'] == null
                      ? null
                      : int.parse(args['allEpisode'].toString()),
                  title: args == null || args['title'] == null
                      ? null
                      : args['title'],
                  type: args == null || args['type'] == null
                      ? null
                      : int.parse(args['type'].toString()),
                );
              },
            ),
          ]),
      GoRoute(
        path: activityDetail,
        builder: (context, state) => ActivityDetail(
          id: state.params == null || state.params['id'] == null
              ? null
              : '${state.params['id']}',
        ),
      ),
      GoRoute(
        path: seconedPageDetail,
        builder: (context, state) => SeconedPageDetail(
          title: state.params == null || state.params['title'] == null
              ? null
              : state.params['title'],
        ),
      )
    ];
  }

  static GoRouter init() {
    List<GoRoute> rootRoutes = [
      GoRoute(
        path: xianmian,
        builder: (context, state) => Xianmian(),
      ),
      GoRoute(
          path: coinRecharge,
          builder: (context, state) => Coinrecharge(),
          routes: [
            GoRoute(
              path: coinDetail,
              builder: (context, state) => CoinDetail(),
            ),
          ]),
      GoRoute(
          path: activityList,
          builder: (context, state) => ActivityList(),
          routes: getDetailRoutes()),
      GoRoute(
          path: seconedPage,
          builder: (context, state) => SeconedPage(
                title: state.params == null || state.params['title'] == null
                    ? null
                    : state.params['title'],
              ),
          routes: getDetailRoutes()),
      GoRoute(
          path: morePage,
          builder: (context, state) {
            return MorePage(
                title: state.params['title'] == null
                    ? ''
                    : state.params['title'].toString(),
                id: state.params['id'] == null
                    ? null
                    : int.parse(state.params['id'].toString()),
                morePageType: state.params['morePageType'] == null
                    ? 1
                    : int.parse(state.params['morePageType'].toString()));
          },
          routes: getDetailRoutes()),
      GoRoute(
          path: collect,
          builder: (context, state) => CollectPage(),
          routes: getDetailRoutes()),
      GoRoute(
          path: down_page,
          builder: (context, state) => DownPage(),
          routes: getDetailRoutes()),
    ];
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
