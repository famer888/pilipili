/// A declarative router for Flutter based on Navigation 2 supporting
/// deep linking, data-driven routes and more
library go_router;

import 'package:flutter/widgets.dart';
import 'src/go_router.dart';
import 'dart:async';
export 'src/custom_transition_page.dart';
export 'src/go_route.dart';
export 'src/go_router.dart';
export 'src/go_router_refresh_stream.dart';
export 'src/go_router_state.dart';
export 'src/typedefs.dart' show GoRouterPageBuilder, GoRouterRedirect;
export 'src/url_path_strategy.dart';

/// Dart extension to add navigation function to a BuildContext object, e.g.
/// context.go('/');
// NOTE: adding this here instead of in /src to work-around a Dart analyzer bug
// and fix: https://github.com/csells/go_router/issues/116
bool isClick = true;

extension GoRouterHelper on BuildContext {
  /// Get a location from route name and parameters.
  String namedLocation(
    String name, {
    Map<String, String> params = const {},
    Map<String, String> queryParams = const {},
  }) =>
      GoRouter.of(this)
          .namedLocation(name, params: params, queryParams: queryParams);

  /// Navigate to a location.
  void go(String location, {Object? extra}) =>
      GoRouter.of(this).go(location, extra: extra);

  /// Navigate to a named route.
  void goNamed(
    String name, {
    Map<String, String> params = const {},
    Map<String, String> queryParams = const {},
    Object? extra,
  }) =>
      GoRouter.of(this).goNamed(
        name,
        params: params,
        queryParams: queryParams,
        extra: extra,
      );

  /// Push a location onto the page stack.
  void push(String location,
      {Object? extra, bool replace = false, bool isNoRepeat = false}) {
    if (isClick) {
      isClick = false;
      Timer(Duration(milliseconds: 500), () {
        isClick = true;
      });
      return GoRouter.of(this).push(location,
          extra: extra, replace: replace, isNoRepeat: isNoRepeat);
    }
  }

  /// Navigate to a named route onto the page stack.
  void pushNamed(
    String name, {
    Map<String, String> params = const {},
    Map<String, String> queryParams = const {},
    Object? extra,
  }) =>
      GoRouter.of(this).pushNamed(
        name,
        params: params,
        queryParams: queryParams,
        extra: extra,
      );

  /// Pop the top page off the Navigator's page stack by calling
  /// [Navigator.pop].
  void pop([dynamic result]) => GoRouter.of(this).pop(this, result);
}
