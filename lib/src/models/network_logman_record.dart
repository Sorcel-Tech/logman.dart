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
    final readableJson =
        '{request: ${request.toReadableString()}, response: ${response?.toReadableString()}}';
    return readableJson.shorten().formatJson();
  }

  @override
  String toString() {
    return 'NetworkRequestLogmanRecord(request: $request, response: $response)';
  }

  Map<String, dynamic> toJson() {
    return {
      'request': request.toJson(),
      'response': response?.toJson(),
    };
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
    final readableJson =
    '{url: $url, method: $method, headers: ${headers ?? ''}, body: ${body ?? ''}, sentAt: $sentAt}'
        .formatJson();
    return 'NetworkRequestLogmanRecord $readableJson';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'method': method,
      'headers': headers,
      'body': body,
      'sentAt': sentAt?.toIso8601String(),
    };
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
    final readableJson =
    '{statusCode: $statusCode, headers: ${headers ?? ''}, body: ${body ?? ''}, receivedAt: $receivedAt}'
        .formatJson();
    return 'NetworkResponseLogmanRecord $readableJson';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'statusCode': statusCode,
      'headers': headers,
      'body': body,
      'receivedAt': receivedAt?.toIso8601String(),
    };
  }
}
