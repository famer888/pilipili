import 'package:dio/dio.dart';
import 'package:pilipili/report/router_observer.dart';
import 'package:pilipili/utils/common.dart';
import 'page_request_tracker.dart';

class ApiTimingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final now = DateTime.now().millisecondsSinceEpoch;
    options.extra['startTime'] = now;

    final pageKey = MyNavObserver.instance.currentPageKey;
    final enterMs = MyNavObserver.instance.currentEnterTimeMs ?? now;
    options.extra['pageKey'] = pageKey;
    options.extra['pageEnterMs'] = enterMs;

    PageRequestTracker.instance.onRequestStart(pageKey, enterMs, now);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _finish(response.requestOptions, success: true);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _finish(err.requestOptions, success: false);
    super.onError(err, handler);
  }

  void _finish(RequestOptions options, {bool success}) {
    final now = DateTime.now().millisecondsSinceEpoch;

    final pageKey = (options.extra['pageKey'] as String) ?? 'unknown';
    final enterMs = (options.extra['pageEnterMs'] as int) ?? now;

    PageRequestTracker.instance.onRequestEnd(pageKey, enterMs, now);

    final start = options.extra['startTime'] as int;

    final duration = now - start;
    final url = options.uri.toString();
    final method = options.method;

    CommonUtils.debugPrint(
      '[ApiTracker] $method $url success=$success '
      'duration=${duration}ms pageKey=$pageKey',
    );
  }
}
