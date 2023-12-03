import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class LogmanRecord {
  final LogmanRecordType type;
  final DateTime _dateTime;

  LogmanRecord(this.type) : _dateTime = DateTime.now();

  DateTime get dateTime => _dateTime;

  String get timeFormatted =>
      DateFormat("MMM d 'at'").add_Hms().format(dateTime);
}

class SimpleLogmanRecord extends LogmanRecord {
  final String message;
  final String source;

  SimpleLogmanRecord({required this.message, required this.source})
      : super(LogmanRecordType.simple);
}

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

class NetworkLogmanRecord extends LogmanRecord {
  final NetworkRequestLogmanRecord request;
  final NetworkResponseLogmanRecord response;

  NetworkLogmanRecord({
    required this.request,
    required this.response,
  }) : super(LogmanRecordType.network);

  @override
  String toString() {
    return '';
  }
}

class NetworkRequestLogmanRecord {
  final String url;
  final String method;
  final Map<String, dynamic>? headers;
  final Object? body;
  final DateTime? sentAt;

  const NetworkRequestLogmanRecord({
    required this.url,
    required this.method,
    required this.headers,
    this.body,
    this.sentAt,
  });
}

class NetworkResponseLogmanRecord {
  final int? statusCode;
  final Map<String, String>? headers;
  final Object? body;
  final DateTime? receivedAt;

  NetworkResponseLogmanRecord({
    required this.statusCode,
    required this.headers,
    required this.body,
    this.receivedAt,
  });
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
