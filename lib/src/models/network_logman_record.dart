import 'package:intl/intl.dart';
import 'package:logman/logman.dart';

class NetworkLogmanRecord extends LogmanRecord {
  final NetworkRequestLogmanRecord request;
  final NetworkResponseLogmanRecord? response;

  NetworkLogmanRecord({
    required this.request,
    this.response,
  }) : super(LogmanRecordType.network);

  String get id => request.id;

  String toReadableString() {
    final readableJson = '{request: ${request.toReadableString()}, response: ${response?.toReadableString()}}';
    return 'NetworkLogmanRecord ::: $readableJson';
  }

  @override
  String toString() {
    return '';
  }
}

class NetworkRequestLogmanRecord {
  final String id;
  final String url;
  final String method;
  final Map<String, dynamic>? headers;
  final Object? body;
  final DateTime? sentAt;

  const NetworkRequestLogmanRecord({
    required this.id,
    required this.url,
    required this.method,
    required this.headers,
    this.body,
    this.sentAt,
  });

  String get dateFormatted => sentAt == null
      ? ''
      : DateFormat("EEE, MMM d 'at'").add_Hms().format(sentAt!);

  String toReadableString() {
    final readableJson = '{url: $url, method: $method, headers: ${headers ?? ''}, body: ${body ?? ''}, sentAt: $sentAt}'.formatJson();
    return 'NetworkRequestLogmanRecord $readableJson';
  }
}

class NetworkResponseLogmanRecord {
  final String id;
  final int? statusCode;
  final Map<String, String>? headers;
  final String? body;
  final DateTime? receivedAt;

  NetworkResponseLogmanRecord({
    required this.id,
    required this.statusCode,
    required this.headers,
    required this.body,
    this.receivedAt,
  });

  String get dateFormatted => receivedAt == null
      ? ''
      : DateFormat("EEE, MMM d 'at'").add_Hms().format(receivedAt!);

  String toReadableString() {
    final readableJson = '{statusCode: $statusCode, headers: ${headers ?? ''}, body: ${body ?? ''}, receivedAt: $receivedAt}';
    return 'NetworkResponseLogmanRecord $readableJson';
  }
}
