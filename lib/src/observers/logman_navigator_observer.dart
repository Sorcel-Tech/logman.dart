import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class LogmanNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    Logman.instance.recordNavigation(
      NavigationLogmanRecord(
        route: route,
        action: NavigationAction.push,
        previousRoute: previousRoute,
      ),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    Logman.instance.recordNavigation(
      NavigationLogmanRecord(
        route: route,
        action: NavigationAction.pop,
        previousRoute: previousRoute,
      ),
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    Logman.instance.recordNavigation(
      NavigationLogmanRecord(
        route: route,
        action: NavigationAction.remove,
        previousRoute: previousRoute,
      ),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    Logman.instance.recordNavigation(
      NavigationLogmanRecord(
        route: newRoute!,
        action: NavigationAction.replace,
        previousRoute: oldRoute,
      ),
    );
  }
}
