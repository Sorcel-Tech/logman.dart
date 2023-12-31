import 'dart:convert';

import 'package:logman/logman.dart';

extension NetworkLogmanRecordExtensions on NetworkLogmanRecord {
  String get durationInMs {
    if (request.sentAt == null || response?.receivedAt == null) {
      return '0 ms';
    }
    return '${response?.receivedAt!.difference(request.sentAt!).inMilliseconds} ms';
  }
}

extension NetworkResponseLogmanRecordExtensions on NetworkResponseLogmanRecord {
  String get sizeInBytes {
    final encoded = utf8.encode(body.toString());
    return '${encoded.length} bytes';
  }
}
