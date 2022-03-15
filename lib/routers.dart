import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/atlas/atlas_detail.dart';
import 'package:pilipili/components/atlas/atlas_list.dart';
import 'package:pilipili/components/comics/comicReader.dart';
import 'package:pilipili/components/comics/comics_detail.dart';
import 'package:pilipili/components/package_detail.dart';
import 'package:pilipili/components/pili/search.dart';
import 'package:pilipili/components/video/small_video.dart';
import 'package:pilipili/components/video/video_detail.dart';
import 'package:pilipili/components/video/web_small_video.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/pages/login/index.dart';
import 'package:pilipili/pages/login/register.dart';
import 'package:pilipili/pages/mine/buy_page.dart';
import 'package:pilipili/pages/mine/contact_official.dart';
import 'package:pilipili/pages/mine/customer_service.dart';
import 'package:pilipili/pages/mine/fill_code.dart';
import 'package:pilipili/pages/mine/invite_friends.dart';
import 'package:pilipili/pages/mine/invite_recored.dart';
import 'package:pilipili/pages/mine/notice_message.dart';
import 'package:pilipili/pages/mine/online_service.dart';
import 'package:pilipili/pages/mine/promote.dart';
import 'package:pilipili/pages/mine/recharg_record.dart';
import 'package:pilipili/pages/mine/setup.dart';
import 'package:pilipili/pages/mine/vip_page.dart';
import 'package:pilipili/pages/welcome.dart';
import 'package:pilipili/pages/mine/collect.dart';
import 'package:pilipili/pages/mine/down_page.dart';
import 'package:pilipili/pages/mine/coinRecharge.dart';
import 'package:pilipili/pages/mine/coin_detail.dart';
import 'package:pilipili/pages/mine/recharg_record.dart';
import 'package:pilipili/pages/detail/local_video_detail.dart';
import 'package:pilipili/pages/detail/local_small_video_detail.dart';
import 'package:pilipili/pages/detail/local_comics_detail.dart';
import 'package:pilipili/pages/detail/local_comicsReader.dart';

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
  static String seconedPage = 'seconedPage/:title/:id'; // 网黄、cos、时间表等二级页面
  static String seconedPageDetail = 'seconedPageDetail'; // 网黄、cos、时间表等二级页面详情
  static String search = 'search'; // 网黄、cos、时间表等二级页面
  static String activityList = 'activityList'; // 精彩活动列表
  static String activityDetail = 'activityDetail/:id'; // 精彩活动详情
  static String videoDetail = 'videoDetail/:id'; //长视频详情页
  static String morePage = 'morePage/:id/:title/:morePageType'; //更多列表
  static String login = 'login'; //登录页面
  static String register = 'register/:type'; //注册找回密码
  static String setup = 'setup'; //设置
  static String smallVideo = 'smallVideo/:id'; //短视频
  static String webSmallVideo = 'webSmallVideo/:id'; //短视频
  static String fillcode = 'fillcode'; //填写邀请码兑换码
  static String messagecenter = 'messagecenter'; // 消息中心
  static String noticemessage = 'noticemessage'; // 系统消息
  static String customerService = 'customerService'; //客服
  static String atlasDetail = 'atlasDetail/:id'; //图集详情
  static String atlasList = 'atlasList/:index'; //图集列表展示
  static String onlineService = 'onlineService'; //在线客服
  static String contactOfficial = 'contactOfficial'; //联系官方

  static String vip = 'vip'; //会员充值页面
  static String rechargeRecord = 'RechargeRecord/:type'; //充值记录

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
  static String packageDetail = 'packageDetail/:id/:contentType/:title'; //视频包详情

  static String invitefriend = 'invitefriend'; // 邀请好友
  static String promote = 'promote'; // 去推广
  static String inviterecored = 'inviterecored'; // 邀请记录
  static String promoteActionList = 'promoteActionList'; //推广方法;
  static String buy = 'buy'; //我的购买记录

  static List<GoRoute> getDetailRoutes() {
    return [
      GoRoute(
          path: packageDetail,
          builder: (context, state) {
            return PackageDetail(
                id: state.params == null || state.params['id'] == null
                    ? null
                    : int.parse(state.params['id'].toString()),
                contentType: state.params == null || state.params['id'] == null
                    ? 1
                    : int.parse(state.params['contentType'].toString()),
                title: state.params == null || state.params['id'] == null
                    ? ''
                    : state.params['title']);
          },
          routes: [
            GoRoute(
              path: videoDetail,
              builder: (context, state) {
                return VideoDetail(
                    id: state.params == null || state.params['id'] == null
                        ? null
                        : int.parse(state.params['id'].toString()));
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
            )
          ]),
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
      GoRoute(
          path: invitefriend,
          builder: (context, state) => InviteFriend(),
          routes: [
            GoRoute(
                path: promote,
                builder: (context, state) => Promote(),
                routes: [
                  GoRoute(
                    path: promoteActionList,
                    builder: (context, state) => PromoteActionList(),
                  ),
                  GoRoute(
                    path: inviterecored,
                    builder: (context, state) => InviteRecored(),
                  )
                ]),
            GoRoute(
              path: inviterecored,
              builder: (context, state) => InviteRecored(),
            ),
          ]),
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
        routes: [
          GoRoute(
            path: noticemessage,
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>;
              return NoticeMessage(args: args);
            },
          ),
          GoRoute(
            path: customerService,
            builder: (context, state) => CustomerService(),
          ),
        ],
      ),
      GoRoute(
          path: onlineService,
          builder: (context, state) => OnlineService(),
          routes: [
            GoRoute(
              path: customerService,
              builder: (context, state) => CustomerService(),
            ),
          ]),
      GoRoute(
        path: contactOfficial,
        builder: (context, state) => ContactOfficial(),
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
        builder: (context, state) => SeconedPageDetail(),
      ),
      GoRoute(
          path: atlasDetail,
          builder: (context, state) {
            return AtlasDetail(
                id: state.params == null || state.params['id'] == null
                    ? null
                    : int.parse(state.params['id'].toString()));
          },
          routes: [
            GoRoute(
              path: atlasList,
              builder: (context, state) {
                final args = AppGlobal.currentReaderRouteExtra;
                return AtilasList(pramas: args);
              },
            ),
          ]),
    ];
  }

  static GoRouter init() {
    List<GoRoute> rootRoutes = [
      GoRoute(path: vip, builder: (context, state) => VipPage(), routes: [
        GoRoute(
            path: rechargeRecord,
            builder: (context, state) {
              return RechargeRecord(args: state.params);
            },
            routes: [
              GoRoute(
                path: customerService,
                builder: (context, state) => CustomerService(),
              ),
            ]),
        GoRoute(
          path: customerService,
          builder: (context, state) => CustomerService(),
        ),
      ]),
      GoRoute(
          path: search,
          builder: (context, state) => SearchPage(),
          routes: getDetailRoutes()),
      GoRoute(
          path: buy,
          builder: (context, state) => BuyPage(),
          routes: getDetailRoutes()),
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
            GoRoute(
                path: rechargeRecord,
                builder: (context, state) {
                  return RechargeRecord(args: state.params);
                },
                routes: [
                  GoRoute(
                    path: customerService,
                    builder: (context, state) => CustomerService(),
                  ),
                ]),
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
                id: state.params == null || state.params['id'] == null
                    ? null
                    : int.parse(state.params['id']),
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
          routes: [
            GoRoute(
              path: localVideoDetail,
              builder: (context, state) {
                final args = state.extra as Map<String, dynamic>;
                return LocalVideoDetail(
                  videoInfo: args == null || args['videoInfo'] == null
                      ? null
                      : args['videoInfo'],
                );
              },
            ),
            GoRoute(
              path: localSmallVideoDetail,
              builder: (context, state) {
                final args = state.extra as Map<String, dynamic>;
                return LocalSmallVideo(
                  videoInfo: args == null || args['videoInfo'] == null
                      ? null
                      : args['videoInfo'],
                );
              },
            ),
            GoRoute(
                path: localComicsDetatl,
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>;
                  return LocalComicsDetatl(
                    comicsInfo: args == null || args['comicsInfo'] == null
                        ? null
                        : args['comicsInfo'],
                  );
                },
                routes: [
                  GoRoute(
                    path: localComicsReader,
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>;
                      return LocalComicsReader(
                        comicsInfo: args == null || args['comicsInfo'] == null
                            ? null
                            : args['comicsInfo'],
                        episode: args == null || args['episode'] == null
                            ? null
                            : args['episode'],
                      );
                    },
                  ),
                ]),
          ]),
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
    if (route.str.indexOf('/${Routes.login}') != -1 ||
        route.str.indexOf('/${Routes.setup}') != -1) {
      route.popped.then((value) {
        EventBus().emit('need-update-login-state', value);
      });
    }
    if (route.str.indexOf('noticemessage') != -1 ||
        route.str.indexOf('customerService') != -1) {
      CommonUtils.updateSystemNotice(AppGlobal.appContext);
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
