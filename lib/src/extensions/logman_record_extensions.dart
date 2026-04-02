import 'dart:convert';

import 'package:logman/logman.dart';

extension NetworkLogmanRecordExtensions on NetworkLogmanRecord {
  String get durationInMs {
    final sentAt = request.sentAt;
    final receivedAt = response?.receivedAt;
    if (sentAt == null || receivedAt == null) {
      return '0 ms';
    }
    return '${receivedAt.difference(sentAt).inMilliseconds} ms';
  }
}

extension NetworkResponseLogmanRecordExtensions on NetworkResponseLogmanRecord {
  String get sizeInBytes {
    if (body == null) return '0 bytes';
    final encoded = utf8.encode(body!);
    return '${encoded.length} bytes';
  }
}
