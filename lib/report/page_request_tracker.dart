import 'package:pilipili/utils/common.dart';

class _PageSessionKey {
  final String pageKey;
  final int enterTimeMs;

  _PageSessionKey(this.pageKey, this.enterTimeMs);

  @override
  bool operator ==(Object other) {
    return other is _PageSessionKey && other.pageKey == pageKey && other.enterTimeMs == enterTimeMs;
  }

  @override
  int get hashCode => Object.hash(pageKey, enterTimeMs);
}

class _RequestRecord {
  final int startMs;
  int endMs;
  bool isInit;

  _RequestRecord(this.startMs, {this.isInit = false});
}

class PageRequestTracker {
  PageRequestTracker._internal();
  static final PageRequestTracker instance = PageRequestTracker._internal();

  final Map<_PageSessionKey, List<_RequestRecord>> _records = {};

  // 第一条请求必须在进入页面 300ms 内
  static const int firstRequestWindowMs = 300;

  // 后续初始化请求：开始时间 - 上一条 init 请求的结束时间 < 300ms
  static const int nextRequestGapMs = 300;

  // 存储"最后一条初始化请求结束时间"
  final Map<_PageSessionKey, int> _lastInitEnd = {};

  // 存储是否已经关闭初始化链
  final Map<_PageSessionKey, bool> _initClosed = {};

  void onPageEnter(String pageKey, int enterTimeMs) {
    final key = _PageSessionKey(pageKey, enterTimeMs);
    _records[key] = [];
    _lastInitEnd[key] = null;
    _initClosed[key] = false;
  }

  void onPageLeave(
    String pageKey,
    int enterTimeMs, {
    void Function(int initDurationMs) onInitDuration,
  }) {
    final key = _PageSessionKey(pageKey, enterTimeMs);
    final lastEnd = _lastInitEnd[key];
    int initDuration = 0;

    if (lastEnd != null) {
      initDuration = lastEnd - enterTimeMs;
    }

    onInitDuration(initDuration);

    CommonUtils.debugPrint(
      '[InitAgg] pageKey=$pageKey initRequestDuration=${initDuration}ms',
    );

    _records.remove(key);
    _lastInitEnd.remove(key);
    _initClosed.remove(key);
  }

  void onRequestStart(String pageKey, int pageEnterMs, int nowMs) {
    if (pageKey == null) return;

    final key = _PageSessionKey(pageKey, pageEnterMs);
    final list = _records[key];
    if (list == null) return;

    bool closed = _initClosed[key] ?? false;
    int lastEnd = _lastInitEnd[key];

    bool isInit = false;

    if (!closed) {
      if (lastEnd == null) {
        // 第一条请求：必须发生在进入页面300ms内
        if (nowMs - pageEnterMs <= firstRequestWindowMs) {
          isInit = true;
        } else {
          _initClosed[key] = true;
          isInit = false;
        }
      } else {
        // 后续请求：下一条请求开始时间 - 上一条初始化请求结束时间 < 300ms
        if ((nowMs - lastEnd) < nextRequestGapMs) {
          isInit = true;
        } else {
          _initClosed[key] = true;
          isInit = false;
        }
      }
    }

    list.add(_RequestRecord(nowMs, isInit: isInit));
  }

  void onRequestEnd(String pageKey, int pageEnterMs, int nowMs) {
    if (pageKey == null) return;

    final key = _PageSessionKey(pageKey, pageEnterMs);
    final list = _records[key];
    if (list == null || list.isEmpty) return;

    for (var i = list.length - 1; i >= 0; i--) {
      final r = list[i];
      if (r.endMs == null) {
        r.endMs = nowMs;
        if (r.isInit) {
          final prev = _lastInitEnd[key];
          if (prev == null || nowMs > prev) {
            _lastInitEnd[key] = nowMs;
          }
        }
        break;
      }
    }
  }
}
