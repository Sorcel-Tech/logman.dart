import 'package:flutter/cupertino.dart';
import 'package:logman/src/models/models.dart';
import 'package:logman/src/presentation/pages/pages.dart';

class NetworkRecordNotifier extends ValueNotifier<List<NetworkLogmanRecord>> {
  NetworkRecordNotifier(List<NetworkLogmanRecord> initialValue) : super(initialValue) {
    _originalNetworkRecords = List.from(initialValue);
  }

  late final List<NetworkLogmanRecord> _originalNetworkRecords;

  void filterNetworkRecords(NetworkStatus status) {
    value = _originalNetworkRecords.where((networkRecord) {
      switch (status) {
        case NetworkStatus.success:
          return _isSuccessStatusCode(networkRecord);
        case NetworkStatus.error:
          return _isErrorStatusCode(networkRecord);
        case NetworkStatus.failed:
          return _isFailedStatusCode(networkRecord);
        case NetworkStatus.all:
        default:
          return true;
      }
    }).toList();
    notifyListeners();
  }

  bool _isSuccessStatusCode(NetworkLogmanRecord record) {
    final statusCode = record.response?.statusCode;
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  bool _isErrorStatusCode(NetworkLogmanRecord record) {
    final statusCode = record.response?.statusCode;
    return statusCode != null && (statusCode >= 400 && statusCode <= 500) || statusCode == 0;
  }

  bool _isFailedStatusCode(NetworkLogmanRecord record) {
    return record.response?.statusCode == null;
  }
}
