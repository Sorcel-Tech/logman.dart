import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class LogmanNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    Logman.instance.addNavigationRecord(
      NavigationLogmanRecord(
        route: route,
        action: NavigationAction.push,
      ),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    Logman.instance.addNavigationRecord(
      NavigationLogmanRecord(
        route: route,
        action: NavigationAction.pop,
      ),
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    Logman.instance.addNavigationRecord(
      NavigationLogmanRecord(
        route: route,
        action: NavigationAction.remove,
      ),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    Logman.instance.addNavigationRecord(
      NavigationLogmanRecord(
        route: newRoute!,
        action: NavigationAction.replace,
      ),
    );
  }
}
