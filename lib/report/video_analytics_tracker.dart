import 'package:pilipili/report/app_event_report.dart';
import 'package:pilipili/report/report_utils.dart';
import 'package:pilipili/utils/api.dart';
import 'package:video_player/video_player.dart';

class VideoAnalyticsTracker {
  final VideoPlayerController controller;

  // 内部状态
  Duration _lastPosition = Duration.zero;
  bool _wasPlaying = false;
  bool _hasSentView = false;
  bool _hasCompleted = false;

  // 用来判断是否为 seek 的阈值（毫秒）
  static const int _seekThresholdMs = 1500;
  Duration _accumulatedPlayTime = Duration.zero;
  bool _hasLoggedOneMinute = false;
  static const Duration _oneMinute = Duration(minutes: 1);

  VideoAnalyticsTracker({
    this.controller,
  });

  /// 开始监听
  void init() {
    controller.addListener(_onControllerUpdated);
  }

  /// 停止监听（注意：不 dispose controller）
  void dispose() {
    controller.removeListener(_onControllerUpdated);
  }

  // =====================================================
  // 核心监听逻辑
  // =====================================================
  void _onControllerUpdated() {
    final v = controller.value;
    if (!v.isInitialized) return;

    // 1) 视频展示
    if (!_hasSentView) {
      _hasSentView = true;
      _sendBehaviorEvent(VideoEvenType.view);
    }

    final currentPosition = v.position;
    final delta = currentPosition - _lastPosition;

    // 2) 快进/快退
    _checkSeek(delta, currentPosition);

    // 3) 播放/暂停
    _checkPlayPause(v);

    _checkPlayOneMinuteLog(v, delta);

    // 4) 播放完成
    _checkComplete(v);

    // 5) 更新历史状态
    _lastPosition = currentPosition;
    _wasPlaying = v.isPlaying;
  }

  void _checkSeek(Duration delta, Duration currentPosition) {
    if (delta.inMilliseconds.abs() >= _seekThresholdMs) {
      // 认为是一次 seek，判定快进 / 快退
      if (delta.inMilliseconds > 0) {
        _sendBehaviorEvent(
          VideoEvenType.forward,
          extra: {
            'seek_from': _lastPosition.inSeconds,
            'seek_to': currentPosition.inSeconds,
          },
        );
      } else if (delta.inMilliseconds < 0) {
        _sendBehaviorEvent(
          VideoEvenType.rewind,
          extra: {
            'seek_from': _lastPosition.inSeconds,
            'seek_to': currentPosition.inSeconds,
          },
        );
      }
    }
  }

  void _checkPlayPause(VideoPlayerValue v) {
    if (v.isPlaying && !_wasPlaying) {
      // 未播放 -> 播放
      _sendBehaviorEvent(VideoEvenType.play);
    } else if (!v.isPlaying && _wasPlaying && v.position < v.duration) {
      // 播放 -> 暂停（未完成）
      _sendBehaviorEvent(VideoEvenType.pause);
    }
  }

  void _checkPlayOneMinuteLog(VideoPlayerValue v, Duration delta) {
    if (_hasLoggedOneMinute) return;
    if (!v.isPlaying) return;

    if (delta.inMilliseconds <= 0) return;
    if (delta.inMilliseconds.abs() >= _seekThresholdMs) return;

    _accumulatedPlayTime += delta;

    if (_accumulatedPlayTime >= _oneMinute) {
      _hasLoggedOneMinute = true;
      mvView(int.parse(AppEventReport.instance.videoInfo['video_id'].toString()));
    }
  }

  void _checkComplete(VideoPlayerValue v) {
    if (_hasCompleted) return;
    if (v.duration <= Duration.zero) return;

    final remaining = v.duration - v.position;
    if (!remaining.isNegative && remaining.inMilliseconds > 500) {
      return;
    }

    _hasCompleted = true;
    _sendBehaviorEvent(VideoEvenType.complete);
  }

  int _calcPlayProgressPercent() {
    final durationMs = controller.value.duration.inMilliseconds;
    if (durationMs <= 0) return 0;
    final posMs = controller.value.position.inMilliseconds;
    final p = (posMs * 100 / durationMs);
    return p.clamp(0, 100).round();
  }

  int get playDurationSeconds => controller.value.position.inSeconds;

  int get playProgressPercent => _calcPlayProgressPercent();
  int get videoDurationSeconds => controller.value.duration.inSeconds;

  void trackShare() {
    _sendBehaviorEvent(VideoEvenType.share);
  }

  // 统一上报封装
  void _sendBehaviorEvent(
    VideoEvenType behaviorKey, {
    Map<String, dynamic> extra,
  }) {
    final v = controller.value;
    final eventMeta = ReportUtils.getVideoEventType(behaviorKey);

    final payload = <String, dynamic>{
      ...AppEventReport.instance.videoInfo,
      // 指标
      'video_duration': v.duration.inSeconds,
      'play_duration': playDurationSeconds,
      'play_progress': _calcPlayProgressPercent(),

      // 行为
      'video_behavior_key': eventMeta['key'],
      'video_behavior_name': eventMeta['name'],
    };

    if (extra != null) {
      payload.addAll(extra);
    }

    AppEventReport.instance.track('video_event', payload);
  }
}
