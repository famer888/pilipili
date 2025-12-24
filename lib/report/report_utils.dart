import 'package:flutter/material.dart';
import 'package:pilipili/report/app_event_report.dart';
import 'package:pilipili/report/page_click_listener.dart';
import 'package:pilipili/report/page_name.dart';
import 'package:pilipili/report/report_search_click.dart';
import 'package:pilipili/report/router_observer.dart';

//广告行为
enum AdEventType { click, close, show }

//广告类型
enum AdType {
  homeActivate, //启动屏
  homeFloatBanner, //首页悬浮广告
  homePopup, //首页弹窗广告
  homeBanner, //首页banner
  homeFeedBanner, //首页列表banner
  elementBanner, //元素列表banner
  videoDetail, //视频详情banner
  welfareBanner, //福利页面
  chiguaBanner, //吃瓜页banner
  communityBanner, //社区首页banner
  postDetailTopListBanner, //帖子详情 列表广告
  postDetailBottomListBanner, //帖子详情 列表广告
  topicDetailListBanner, //社区详情 列表广告
  appsList, //应用广告列表广告
  fuliBanner, //福利页面Banner广告
  mineBanner, //我的页面banner
}

//视频事件类型
enum VideoEvenType {
  view, //展示
  play, //播放
  pause, //暂停
  share, //分享
  complete, //播放完成
  forward, //快进
  rewind //快退
}

class ReportUtils {
  static Map getVideoEventType(VideoEvenType type) {
    String key = '';
    String name = '';
    switch (type) {
      case VideoEvenType.view:
        key = 'video_view';
        name = '展示';
        break;
      case VideoEvenType.play:
        key = 'video_play';
        name = '播放';
        break;
      case VideoEvenType.pause:
        key = 'video_pause';
        name = '暂停';
        break;
      case VideoEvenType.share:
        key = 'video_share';
        name = '分享';
        break;
      case VideoEvenType.complete:
        key = 'video_complete';
        name = '播放完成';
        break;
      case VideoEvenType.forward:
        key = 'video_forward';
        name = '快进';
        break;
      case VideoEvenType.rewind:
        key = 'video_rewind';
        name = '快退';
        break;
      default:
    }
    return {'key': key, 'name': name};
  }

  static Map getAdType(AdType type) {
    String key = '';
    String name = '';
    switch (type) {
      case AdType.homeActivate:
        key = "home_activate";
        name = "启动屏广告";
        break;
      case AdType.homeFloatBanner:
        key = "home_float_banner";
        name = "首页悬浮广告";
        break;
      case AdType.homePopup:
        key = "home_popup";
        name = "首页弹窗";
        break;
      case AdType.homeBanner:
        key = "home_banner";
        name = "首页轮播图";
        break;
      case AdType.homeFeedBanner:
        key = "home_feed_banner";
        name = "首页列表轮播图";
        break;
      case AdType.elementBanner:
        key = "element_banner";
        name = "元素列表轮播图";
        break;
      case AdType.videoDetail:
        key = "video_detail_banner";
        name = "视频详情banner";
        break;
      case AdType.chiguaBanner:
        key = "chigua_banner";
        name = "吃瓜页轮播图";
        break;
      case AdType.welfareBanner:
        key = "welfare_banner";
        name = "应用中心轮播图";
        break;
      case AdType.postDetailTopListBanner:
        key = "post_detail_top_list_banner";
        name = "帖子详情顶部列表轮播图";
        break;
      case AdType.postDetailBottomListBanner:
        key = "post_detail_bottom_list_banner";
        name = "帖子详情底部列表轮播图";
        break;
      case AdType.topicDetailListBanner:
        key = "topic_detail_list_banner";
        name = "社区详情列表轮播图";
        break;
      case AdType.appsList:
        key = "apps_ist";
        name = "应用中心广告列表";
        break;
      case AdType.communityBanner:
        key = "community_banner";
        name = "社区首页轮播图";
        break;
      case AdType.mineBanner:
        key = "mine_banner";
        name = "我的页面轮播图";
        break;
      case AdType.fuliBanner:
        key = "fuli_banner";
        name = "福利页面轮播图";
        break;
      default:
    }
    return {"key": key, "name": name};
  }

  //应用页面展示日志
  static void appPageView({
    String pageKey,
    String pageName,
    String referrerPageKey,
    String referrerPageName,
    String currentPageKey,
    String currentPageName,
    int pageLoadTimeSec,
    int stayTimeMs,
  }) {
    Map data = {
      'user_type': AppEventReport.instance.isVip ? 'vip' : 'normal',
      'page_key': pageKey,
      'page_name': pageName,
      'referrer_page_key': referrerPageKey ?? '',
      'referrer_page_name': referrerPageName ?? '',
      'current_page_key': currentPageKey,
      'current_page_name': currentPageName,
      'page_load_time': pageLoadTimeSec,
      // 'duration': stayTimeMs,
    };
    AppEventReport.instance.track('app_page_view', data);
  }

  // 导航点击
  static onNavChange(String key, String name) {
    Map data = {
      'navigation_key': key,
      'navigation_name': name,
    };
    AppEventReport.instance.track('navigation', data);
  }

//APP广告行为
  static adVertising({
    AdEventType eventType,
    AdType advertisingKey,
    dynamic advertisingId,
    dynamic adtype, //传 ad_type
    dynamic adSlotKey, // position 或 pos
    dynamic adSlotName, //传 ad_name
    dynamic adPageKey, // 传 page_key
    dynamic adPageName, //传 page_name
  }) {
    String type = '';
    switch (eventType) {
      case AdEventType.click:
        type = 'click';
        break;
      case AdEventType.close:
        type = 'close';
        break;
      case AdEventType.show:
        type = 'show';
        break;
      default:
    }
    Map data = {
      'event_type': type, //事件类型：click(点击), close(关闭), show(展示)
      'advertising_key':
          getAdType(advertisingKey)['key'], //广告标识：home_popup(首页弹窗), home_banner(首页Banner), video_reward(激励视频)等
      'advertising_name': getAdType(advertisingKey)['name'], //广告标识名称：首页弹窗, 首页Banner, 激励视频
      'advertising_id': advertisingId.toString(), //广告ID
    };

    if (eventType == AdEventType.show) {
      //已经上报了就不在上报
      final key = "${adSlotKey}_vertisiong_$advertisingId";
      if (AppEventReport.instance.reportedAdIds.contains(key)) {
        return;
      }
      AppEventReport.instance.reportedAdIds.add(key);
      //展示上报
      AppEventReport.instance.track('advertising', data);
      adImpression(
          adSlotKey: adSlotKey ?? getAdType(advertisingKey)['key'],
          adSlotName: adSlotName ?? getAdType(advertisingKey)['name'],
          adId: advertisingId,
          adType: advertisingKey,
          adPageKey: adPageKey,
          adPageName: adPageName);
    } else {
      //内部
      AppEventReport.instance.track('advertising', data);
    }
    //外部
    if (eventType == AdEventType.click) {
      //点击上报
      adClick(
          adId: advertisingId,
          adType: advertisingKey,
          adtype: adtype ?? getAdType(advertisingKey)['key'],
          adSlotKey: adSlotKey,
          adSlotName: adSlotName,
          adPageKey: adPageKey,
          adPageName: adPageName);
    }
  }

  //广告点击事件
  static adClick({
    dynamic adId,
    dynamic creativeId,
    AdType adType,
    dynamic adtype,
    dynamic adSlotKey,
    dynamic adSlotName,
    dynamic adPageKey,
    dynamic adPageName,
  }) {
    final pageKey = MyNavObserver.instance.currentPageKey ?? '';
    final rawName = MyNavObserver.instance.currentRouteName ?? '';
    final pageName = RouterPageName.pageName[rawName] ?? rawName;
    Map data = {
      'page_key': adPageKey ?? pageKey,
      'page_name': adPageName ?? pageName,
      'ad_slot_key': adSlotKey ?? getAdType(adType)['key'], //广告位标识：与展示事件一致，如 home_banner_1
      'ad_slot_name': adSlotName ?? getAdType(adType)['name'], //广告位名称：与展示事件一致
      'ad_id': adId, //被点击的广告ID
      'creative_id': creativeId ?? '', //素材ID（可选）
      'ad_type': adtype ?? getAdType(adType)['key'], //广告类型：banner, feed, interstitial, reward_video 等
    };
    AppEventReport.instance.track('ad_click', data);
  }

  //广告展示
  static adImpression({
    dynamic adSlotKey,
    dynamic adSlotName,
    dynamic adId,
    dynamic creativeId,
    AdType adType,
    dynamic type,
    dynamic adPageKey,
    dynamic adPageName,
  }) {
    //已经上报了就不在上报
    final key = "${adSlotKey}_impression_$adId";
    if (AppEventReport.instance.reportedAdIds.contains(key)) {
      return;
    }
    AppEventReport.instance.reportedAdIds.add(key);
    final pageKey = MyNavObserver.instance.currentPageKey ?? '';
    final rawName = MyNavObserver.instance.currentRouteName ?? '';
    final pageName = RouterPageName.pageName[rawName] ?? rawName;
    Map data = {
      'page_key': adPageKey ?? pageKey,
      'page_name': adPageName ?? pageName,
      'ad_slot_key': adSlotKey, //广告位标识：如 home_banner_1, home_feed_3等
      'ad_slot_name': adSlotName, //广告位名称：如 首页顶部Banner，第3条信息流广告
      'ad_id': adId, //广告ID, 多个广告ID英文逗号分隔
      'creative_id': creativeId ?? '', //素材id
      'ad_type': type ?? getAdType(adType)['key'] //广告类型：banner, feed, interstitial, reward_video 等
    };
    AppEventReport.instance.track('ad_impression', data);
  }

  //视频事件
  static videoEvent({
    dynamic id, //视频 id
    String title, //视频标题
    int typeId, //视频分类ID
    String typeName, //视频分类名称
    String tagKey, //标签KEY, 多个标签使用英文逗号分隔
    String tagName, //标签名称,多个标签使用英文逗号分隔
    int duration, //视频总时长（秒）
    int playDuration, //本次播放时长（秒）
    int playProgress, //播放进度百分比（0-100）
    String
        behaviorKey, //视频行为标识：video_view(展示),video_play(播放), video_pause(暂停), video_share(分享), video_complete(播放完成), video_forward(快进), video_rewind(快退)等
    String behaviorName, //视频行为名称：视频展示,播放, 暂停, 分享, 播放完成, 快进, 快退
  }) {
    Map data = {
      'video_id': id,
      'video_title': title,
      'video_type_id': typeId,
      'video_type_name': typeName,
      'video_tag_key': tagKey,
      'video_tag_name': tagName,
      'video_duration': duration,
      'play_duration': playDuration,
      'play_progress': playProgress,
      'video_behavior_key': behaviorKey,
      'video_behavior_name': behaviorName,
    };
    AppEventReport.instance.track('video_event', data);
  }

  static keywordClick({
    String keyword,
    int id,
    String typeKey,
    String typeName,
    String position,
  }) {
    Map data = {
      'keyword': keyword, //关联关键词
      'click_item_id': id, //点击项目ID（视频ID/小说ID等）
      'click_item_type_key': typeKey, //点击项目类型：video(视频), novel(小说), comic(漫画)
      'click_item_type_name': typeName, //点击项目类型：视频, 小说, 漫画
      'click_position': position, //点击位置（搜索结果中的排序位置）
    };
    AppEventReport.instance.track('keyword_click', data);
  }
}

extension EventClick on Widget {
  Widget withPageClickLog() {
    return PageClickListener(
      child: this,
    );
  }

  Widget withSearchReport(bool isReport, Map data) {
    if (!isReport) return this;
    return ReportSearchClick(
      child: this,
      data: data,
    );
  }
}
