import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pilipili/components/activityDetail.dart';
import 'package:pilipili/components/activityList.dart';
import 'package:pilipili/components/atlas/atlas_detail.dart';
import 'package:pilipili/components/atlas/atlas_list.dart';
import 'package:pilipili/components/cityPickers.dart';
import 'package:pilipili/components/comics/comicReader.dart';
import 'package:pilipili/components/comics/comics_detail.dart';
import 'package:pilipili/components/morePage.dart';
import 'package:pilipili/components/package_detail.dart';
import 'package:pilipili/components/pili/search.dart';
import 'package:pilipili/components/seconedPage.dart';
import 'package:pilipili/components/seconedPageDetail.dart';
import 'package:pilipili/components/series_detail.dart';
import 'package:pilipili/components/video/small_video.dart';
import 'package:pilipili/components/video/video_detail.dart';
import 'package:pilipili/components/xianmian.dart';
import 'package:pilipili/components/yuemei/yuemei_detail.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/mixin/message_center.dart';
import 'package:pilipili/pages/community/community_detail.dart';
import 'package:pilipili/pages/community/community_publish.dart';
import 'package:pilipili/pages/detail/local_comicsReader.dart';
import 'package:pilipili/pages/detail/local_comics_detail.dart';
import 'package:pilipili/pages/detail/local_small_video_detail.dart';
import 'package:pilipili/pages/detail/local_video_detail.dart';
import 'package:pilipili/pages/login/index.dart';
import 'package:pilipili/pages/login/register.dart';
import 'package:pilipili/pages/mine/app_center.dart';
import 'package:pilipili/pages/mine/buy_page.dart';
import 'package:pilipili/pages/mine/coinRecharge.dart';
import 'package:pilipili/pages/mine/coin_detail.dart';
import 'package:pilipili/pages/mine/collect.dart';
import 'package:pilipili/pages/mine/contact_official.dart';
import 'package:pilipili/pages/mine/customer_service.dart';
import 'package:pilipili/pages/mine/down_page.dart';
import 'package:pilipili/pages/mine/fill_code.dart';
import 'package:pilipili/pages/mine/income_detail.dart';
import 'package:pilipili/pages/mine/invite_friends.dart';
import 'package:pilipili/pages/mine/invite_recored.dart';
import 'package:pilipili/pages/mine/my_follow.dart';
import 'package:pilipili/pages/mine/my_post.dart';
import 'package:pilipili/pages/mine/notice_message.dart';
import 'package:pilipili/pages/mine/online_service.dart';
import 'package:pilipili/pages/mine/others_post.dart';
import 'package:pilipili/pages/mine/promote.dart';
import 'package:pilipili/pages/mine/recharg_record.dart';
import 'package:pilipili/pages/mine/setup.dart';
import 'package:pilipili/pages/mine/vip_page.dart';
import 'package:pilipili/pages/mine/watch_history.dart';
import 'package:pilipili/pages/mine/withdrawals_page.dart';
import 'package:pilipili/pages/welcome.dart';
import 'package:pilipili/pages/withdrawals_record.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';

class GoRouterModel {
  GoRouterModel({this.key, this.builder, this.pageBuilder});
  String key;
  Widget Function(BuildContext, GoRouterState) builder;
  Page<void> Function(BuildContext, GoRouterState) pageBuilder;
}

extension GetGoRouter on GoRouterModel {
  GoRoute toGoRouter({List<GoRoute> routes}) {
    return this.pageBuilder != null
        ? GoRoute(
            path: this.key, pageBuilder: this.pageBuilder, routes: routes ?? [])
        : GoRoute(path: this.key, builder: this.builder, routes: routes ?? []);
  }
}

class Routes {
  //home页限免页面
  static GoRouterModel xianmian =
      GoRouterModel(key: 'xianmian', builder: (context, state) => Xianmian());

  // 网黄、cos、时间表等二级页面
  static GoRouterModel seconedPage = GoRouterModel(
      key: 'seconedPage/:sctitle/:scid',
      builder: (context, state) => SeconedPage(
            title: state.params == null || state.params['sctitle'] == null
                ? null
                : state.params['sctitle'],
            id: state.params == null || state.params['scid'] == null
                ? null
                : int.parse(state.params['scid']),
          ));

  // 网黄、cos、时间表等二级页面详情
  static GoRouterModel seconedPageDetail = GoRouterModel(
      key: 'seconedPageDetail',
      builder: (context, state) => SeconedPageDetail());

  //搜索
  static GoRouterModel search =
      GoRouterModel(key: 'search', builder: (context, state) => SearchPage());

  //精彩活动列表
  static GoRouterModel activityList = GoRouterModel(
      key: 'activityList', builder: (context, state) => ActivityList());

  //精彩活动详情
  static GoRouterModel activityDetail = GoRouterModel(
      key: 'activityDetail/:acid',
      builder: (context, state) => ActivityDetail(
            id: state.params == null || state.params['acid'] == null
                ? null
                : '${state.params['acid']}',
          ));

//长视频详情页
  static GoRouterModel videoDetail = GoRouterModel(
      key: 'videoDetail/:vid',
      builder: (context, state) => VideoDetail(
          id: state.params == null || state.params['vid'] == null
              ? null
              : int.parse(state.params['vid'].toString())));

//更多列表
  static GoRouterModel morePage = GoRouterModel(
      key: 'morePage/:mid/:mtitle/:morePageType',
      builder: (context, state) => MorePage(
          title: state.params['mtitle'] == null
              ? ''
              : state.params['mtitle'].toString(),
          id: state.params['mid'] == null
              ? null
              : int.parse(state.params['mid'].toString()),
          morePageType: state.params['morePageType'] == null
              ? 1
              : int.parse(state.params['morePageType'].toString())));

//登录页面
  static GoRouterModel login =
      GoRouterModel(key: 'login', builder: (context, state) => LoginPage());

//注册找回密码
  static GoRouterModel register = GoRouterModel(
      key: 'register/:rtype',
      builder: (context, state) => Register(
          type: state.params == null || state.params['rtype'] == null
              ? null
              : int.parse(state.params['rtype'].toString())));

//设置
  static GoRouterModel setup =
      GoRouterModel(key: 'setup', builder: (context, state) => SetupPage());

//短视频
  static GoRouterModel smallVideo = GoRouterModel(
      key: 'smallVideo/:sid',
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
      });

//短视频
  static GoRouterModel webSmallVideo = GoRouterModel(
      key: 'webSmallVideo/:wid',
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
      });

//填写邀请码兑换码
  static GoRouterModel fillcode = GoRouterModel(
      key: 'fillcode',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return FillCodePage(args: args);
      });

//消息中心
  static GoRouterModel messagecenter = GoRouterModel(
      key: 'messagecenter', builder: (context, state) => MessageCenter());

//系统消息
  static GoRouterModel noticemessage = GoRouterModel(
      key: 'noticemessage',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return NoticeMessage(args: args);
      });

//客服
  static GoRouterModel customerService = GoRouterModel(
      key: 'customerService', builder: (context, state) => CustomerService());

//图集详情
  static GoRouterModel atlasDetail = GoRouterModel(
      key: 'atlasDetail/:aid',
      builder: (context, state) {
        return AtlasDetail(
            id: state.params == null || state.params['aid'] == null
                ? null
                : int.parse(state.params['aid'].toString()));
      });

//约妹详情
  static GoRouterModel yuemeiDetail = GoRouterModel(
      key: 'yuemeiDetail/:yid',
      builder: (context, state) {
        return YuemeiDetail(
            id: state.params == null || state.params['yid'] == null
                ? null
                : int.parse(state.params['yid'].toString()));
      });

//系列详情
  static GoRouterModel seriesDetail = GoRouterModel(
      key: 'seriesDetail/:sid/:stype',
      builder: (context, state) {
        return SeriesDetail(
            id: state.params == null || state.params['sid'] == null
                ? null
                : int.parse(state.params['sid'].toString()),
            type: state.params == null || state.params['sid'] == null
                ? null
                : int.parse(state.params['stype'].toString()));
      });

//图集列表展示
  static GoRouterModel atlasList = GoRouterModel(
      key: 'atlasList/:index',
      builder: (context, state) {
        final args = AppGlobal.currentReaderRouteExtra;
        return AtilasList(pramas: args);
      });

//在线客服
  static GoRouterModel onlineService = GoRouterModel(
      key: 'onlineService', builder: (context, state) => OnlineService());

//联系官方
  static GoRouterModel contactOfficial = GoRouterModel(
      key: 'contactOfficial', builder: (context, state) => ContactOfficial());

//应用推荐
  static GoRouterModel appCenter =
      GoRouterModel(key: 'appCenter', builder: (context, state) => AppCenter());

//会员充值页面
  static GoRouterModel vip =
      GoRouterModel(key: 'vip', builder: (context, state) => VipPage());

//充值记录
  static GoRouterModel rechargeRecord = GoRouterModel(
      key: 'RechargeRecord/:type',
      builder: (context, state) => RechargeRecord(args: state.params));

//观看记录
  static GoRouterModel watchhistory = GoRouterModel(
      key: 'watchhistory', builder: (context, state) => WatchHistoryPage());

  //漫画详情
  static GoRouterModel comicsdetail = GoRouterModel(
      key: 'comicsdetail/:cid',
      builder: (context, state) => ComicsDetatl(
          id: state.params == null || state.params['cid'] == null
              ? null
              : int.parse(state.params['cid'].toString())));

//漫画阅读器
  static GoRouterModel comicReader = GoRouterModel(
      key: 'comicReader/:chapid',
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
          title: args == null || args['title'] == null ? null : args['title'],
          type: args == null || args['type'] == null
              ? null
              : int.parse(args['type'].toString()),
        );
      });

//长视频本地详情页
  static GoRouterModel localVideoDetail = GoRouterModel(
      key: 'localVideoDetail/:lvid',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return LocalVideoDetail(
          videoInfo: args == null || args['videoInfo'] == null
              ? null
              : args['videoInfo'],
        );
      });

//小视频本地详情页
  static GoRouterModel localSmallVideoDetail = GoRouterModel(
      key: 'localSmallVideoDetail/:lsid',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return LocalSmallVideo(
          videoInfo: args == null || args['videoInfo'] == null
              ? null
              : args['videoInfo'],
        );
      });

//漫画本地详情页
  static GoRouterModel localComicsDetatl = GoRouterModel(
      key: 'localComicsDetatl',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return LocalComicsDetatl(
          comicsInfo: args == null || args['comicsInfo'] == null
              ? null
              : args['comicsInfo'],
        );
      });

//漫画本地详情页
  static GoRouterModel localComicsReader = GoRouterModel(
      key: 'localComicsReader',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return LocalComicsReader(
          comicsInfo: args == null || args['comicsInfo'] == null
              ? null
              : args['comicsInfo'],
          episode:
              args == null || args['episode'] == null ? null : args['episode'],
        );
      });

//我的收藏
  static GoRouterModel collect =
      GoRouterModel(key: 'collect', builder: (context, state) => CollectPage());

//我的下载
  static GoRouterModel downPage =
      GoRouterModel(key: 'downPage', builder: (context, state) => DownPage());

//皮哩币充值
  static GoRouterModel coinRecharge = GoRouterModel(
      key: 'coinRecharge', builder: (context, state) => Coinrecharge());

//皮哩币明细
  static GoRouterModel coinDetail = GoRouterModel(
      key: 'coinDetail', builder: (context, state) => CoinDetail());

//视频包详情
  static GoRouterModel packageDetail = GoRouterModel(
      key: 'packageDetail/:pid/:contentType/:ptitle',
      builder: (context, state) => PackageDetail(
          id: state.params == null || state.params['pid'] == null
              ? null
              : int.parse(state.params['pid'].toString()),
          contentType: state.params == null || state.params['pid'] == null
              ? 1
              : int.parse(state.params['contentType'].toString()),
          title: state.params == null || state.params['pid'] == null
              ? ''
              : state.params['ptitle']));

//邀请好友
  static GoRouterModel invitefriend = GoRouterModel(
      key: 'invitefriend', builder: (context, state) => InviteFriend());

//去推广
  static GoRouterModel promote =
      GoRouterModel(key: 'promote', builder: (context, state) => Promote());

//邀请记录
  static GoRouterModel inviterecored = GoRouterModel(
      key: 'inviterecored', builder: (context, state) => InviteRecored());

//推广方法
  static GoRouterModel promoteActionList = GoRouterModel(
      key: 'promoteActionList',
      builder: (context, state) => PromoteActionList());

//我的购买记录
  static GoRouterModel buy =
      GoRouterModel(key: 'buy', builder: (context, state) => BuyPage());

//城市选择
  static GoRouterModel cityPicker = GoRouterModel(
      key: 'cityPicker', builder: (context, state) => CityPicker());

  //我的关注
  static GoRouterModel myFollow = GoRouterModel(
      key: 'myFollow', builder: (context, state) => MyFollowPage());

  //我的帖子
  static GoRouterModel myPost =
      GoRouterModel(key: 'myPost', builder: (context, state) => MyPostPage());

  //他人帖子
  static GoRouterModel othersPost = GoRouterModel(
      key: 'othersPost/:aff',
      builder: (context, state) =>
          OthersPostPage(aff: int.parse(state.params['aff'] ?? '0')));

  //帖子详情
  static GoRouterModel communityDetail = GoRouterModel(
      key: 'communityDetail/:id',
      builder: (context, state) => CommunityDetail(
            id: int.parse(state.params['id'] ?? '0'),
          ));

  //帖子发布/编辑
  static GoRouterModel communityPushlish = GoRouterModel(
      key: 'communityPushlish',
      builder: (context, state) => CommunityPushlish());

  //收益明細
  static GoRouterModel incomeDetail = GoRouterModel(
      key: 'incomeDetail', builder: (context, state) => IncomeDetail());

  //提現申請
  static GoRouterModel withdrawalsPage = GoRouterModel(
      key: 'withdrawalsPage', builder: (context, state) => WithdrawalsPage());

  //提現记录
  static GoRouterModel withdrawalsRecord = GoRouterModel(
      key: 'withdrawalsRecord',
      builder: (context, state) => WithdrawalsRecord());

  static GoRouter init() {
    List<GoRoute> pages = [
      xianmian.toGoRouter(),
      seconedPage.toGoRouter(),
      seconedPageDetail.toGoRouter(),
      search.toGoRouter(),
      activityList.toGoRouter(),
      activityDetail.toGoRouter(),
      videoDetail.toGoRouter(),
      morePage.toGoRouter(),
      login.toGoRouter(),
      register.toGoRouter(),
      setup.toGoRouter(),
      smallVideo.toGoRouter(),
      webSmallVideo.toGoRouter(),
      fillcode.toGoRouter(),
      messagecenter.toGoRouter(),
      noticemessage.toGoRouter(),
      customerService.toGoRouter(),
      atlasDetail.toGoRouter(),
      yuemeiDetail.toGoRouter(),
      seriesDetail.toGoRouter(),
      atlasList.toGoRouter(),
      onlineService.toGoRouter(),
      contactOfficial.toGoRouter(),
      appCenter.toGoRouter(),
      vip.toGoRouter(),
      rechargeRecord.toGoRouter(),
      watchhistory.toGoRouter(),
      comicsdetail.toGoRouter(),
      comicReader.toGoRouter(),
      localVideoDetail.toGoRouter(),
      localSmallVideoDetail.toGoRouter(),
      localComicsDetatl.toGoRouter(),
      localComicsReader.toGoRouter(),
      collect.toGoRouter(),
      downPage.toGoRouter(),
      coinRecharge.toGoRouter(),
      coinDetail.toGoRouter(),
      packageDetail.toGoRouter(),
      invitefriend.toGoRouter(),
      promote.toGoRouter(),
      inviterecored.toGoRouter(),
      promoteActionList.toGoRouter(),
      buy.toGoRouter(),
      cityPicker.toGoRouter(),
      myFollow.toGoRouter(),
      myPost.toGoRouter(),
      othersPost.toGoRouter(),
      communityDetail.toGoRouter(),
      communityPushlish.toGoRouter(),
      incomeDetail.toGoRouter(),
      withdrawalsRecord.toGoRouter(),
      withdrawalsPage.toGoRouter()
    ];
    List<GoRoute> rootPages = [
      xianmian.toGoRouter(routes: pages),
      seconedPage.toGoRouter(routes: pages),
      seconedPageDetail.toGoRouter(routes: pages),
      search.toGoRouter(routes: pages),
      activityList.toGoRouter(routes: pages),
      activityDetail.toGoRouter(routes: pages),
      videoDetail.toGoRouter(routes: pages),
      morePage.toGoRouter(routes: pages),
      login.toGoRouter(routes: pages),
      register.toGoRouter(routes: pages),
      setup.toGoRouter(routes: pages),
      smallVideo.toGoRouter(routes: pages),
      webSmallVideo.toGoRouter(routes: pages),
      fillcode.toGoRouter(routes: pages),
      messagecenter.toGoRouter(routes: pages),
      noticemessage.toGoRouter(routes: pages),
      customerService.toGoRouter(routes: pages),
      atlasDetail.toGoRouter(routes: pages),
      yuemeiDetail.toGoRouter(routes: pages),
      seriesDetail.toGoRouter(routes: pages),
      atlasList.toGoRouter(routes: pages),
      onlineService.toGoRouter(routes: pages),
      contactOfficial.toGoRouter(routes: pages),
      appCenter.toGoRouter(routes: pages),
      vip.toGoRouter(routes: pages),
      rechargeRecord.toGoRouter(routes: pages),
      watchhistory.toGoRouter(routes: pages),
      comicsdetail.toGoRouter(routes: pages),
      comicReader.toGoRouter(routes: pages),
      localVideoDetail.toGoRouter(routes: pages),
      localSmallVideoDetail.toGoRouter(routes: pages),
      localComicsDetatl.toGoRouter(routes: pages),
      localComicsReader.toGoRouter(routes: pages),
      collect.toGoRouter(routes: pages),
      downPage.toGoRouter(routes: pages),
      coinRecharge.toGoRouter(routes: pages),
      coinDetail.toGoRouter(routes: pages),
      packageDetail.toGoRouter(routes: pages),
      invitefriend.toGoRouter(routes: pages),
      promote.toGoRouter(routes: pages),
      inviterecored.toGoRouter(routes: pages),
      promoteActionList.toGoRouter(routes: pages),
      buy.toGoRouter(routes: pages),
      cityPicker.toGoRouter(routes: pages),
      myFollow.toGoRouter(routes: pages),
      myPost.toGoRouter(routes: pages),
      othersPost.toGoRouter(routes: pages),
      communityDetail.toGoRouter(routes: pages),
      communityPushlish.toGoRouter(routes: pages),
      incomeDetail.toGoRouter(routes: pages),
      withdrawalsPage.toGoRouter(routes: pages),
      withdrawalsRecord.toGoRouter(routes: pages)
    ];
    return GoRouter(
      // errorBuilder: (context, state) => ErrorScreen(path: state.location),
      debugLogDiagnostics: true,
      // urlPathStrategy: UrlPathStrategy.path,
      initialLocation: "/",
      routerNeglect: true,
      routes: [
        GoRoute(
            path: '/',
            builder: (context, state) => Welcome(),
            routes: rootPages)
      ],
      observers: [BotToastNavigatorObserver(), MyNavObserver()],
    );
  }
}

changeRouter() {
  GoRouter(routerNeglect: true, routes: [
    GoRoute(path: '/', builder: (context, state) => Welcome(), routes: [])
  ], observers: [
    BotToastNavigatorObserver(),
    MyNavObserver()
  ]);
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
    if (route.str.indexOf('/login') != -1 ||
        route.str.indexOf('/setup') != -1) {
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
