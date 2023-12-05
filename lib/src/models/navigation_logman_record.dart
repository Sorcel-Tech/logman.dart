import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class NavigationLogmanRecord extends LogmanRecord {
  final Route<dynamic> route;
  final Route<dynamic>? previousRoute;
  final NavigationAction action;

  NavigationLogmanRecord({
    required this.route,
    required this.action,
    this.previousRoute,
  }) : super(LogmanRecordType.navigation);

  Map<String, dynamic> get parameters {
    final params = <String, dynamic>{};
    if (route.settings.arguments != null) {
      params['arguments'] = route.settings.arguments;
    }
    if (route.settings.name != null) {
      params['name'] = route.settings.name;
    }
    return params;
  }

  String get routeName => route.settings.name ?? 'Unknown route';

  String get previousRouteName =>
      previousRoute?.settings.name ?? 'Unknown previous route';

  @override
  String toString() {
    return 'NavigationLogmanRecord{route: $routeName, action: $action, previousRoute: $previousRoute, parameters: $parameters}';
  }
}
