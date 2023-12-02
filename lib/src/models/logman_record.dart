import 'package:flutter/material.dart';

abstract class LogmanRecord {
  final LogmanRecordType type;
  final DateTime _date;

  LogmanRecord(this.type) : _date = DateTime.now();

  DateTime get date => _date;
  String get timeFormatted => date.toIso8601String();
}

class SimpleLogmanRecord extends LogmanRecord {
  final String message;

  SimpleLogmanRecord(this.message) : super(LogmanRecordType.simple);
}

class NavigationLogmanRecord extends LogmanRecord {
  final Route<dynamic> route;
  final NavigationAction action;

  NavigationLogmanRecord({
    required this.route,
    required this.action,
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

  @override
  String toString() {
    return 'NavigationLogmanRecord: $action to ${route.settings.name} with params: $parameters';
  }
}

enum NavigationAction {
  push,
  pop,
  replace,
  remove;

  @override
  String toString() {
    return super.toString().split('.').last;
  }
}

enum LogmanRecordType {
  simple,
  network,
  database,
  navigation;

  @override
  String toString() {
    return super.toString().split('.').last;
  }
}
