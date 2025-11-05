import 'package:flutter/material.dart';
import 'route_observer.dart';

/// Mixin to refresh data whenever a page becomes visible again
/// (e.g., after navigating back to it).
///
/// Usage:
/// class MyPageState extends State<MyPage> with RouteAwareState<MyPage> {
///   @override
///   void onPageVisible() {
///     // reload data here
///   }
/// }
mixin RouteAwareState<T extends StatefulWidget> on State<T>
    implements RouteAware {
  ModalRoute<dynamic>? _route;

  /// Called when the page is visible to the user (initial push and when popped back to).
  void onPageVisible() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (_route != route && route is PageRoute) {
      _route = route;
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    if (_route is PageRoute) routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    onPageVisible();
  }

  @override
  void didPopNext() {
    onPageVisible();
  }

  @override
  void didPop() {}

  @override
  void didPushNext() {}
}
