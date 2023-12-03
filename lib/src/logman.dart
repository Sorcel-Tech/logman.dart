import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

class Logman {
  late final Logger _logger;

  Logman._internal() {
    _logger = Logger();
  }

  // Public singleton instance
  static final Logman instance = Logman._internal();

  final _records = ValueNotifier(<LogmanRecord>[]);

  ValueNotifier<List<LogmanRecord>> get records => _records;

  void _addRecord(LogmanRecord record) =>
      _records.value = [..._records.value, record];

  void recordSimpleLog(String message) {
    _addRecord(
      SimpleLogmanRecord(
        message: message,
        source: StackTrace.current.traceSource,
      ),
    );
    _logger.i(message);
  }

  void recordNavigation(NavigationLogmanRecord record) {
    final currentRouteName = record.route.settings.name ?? '';
    final previousRouteName = record.previousRoute?.settings.name ?? '';

    // Ignore Logman routes
    if (currentRouteName.contains('/logman') ||
        previousRouteName.contains('/logman')) {
      return;
    }
    _addRecord(record);
    _logger.i(record);
  }

  void recordNetworkRequest(NetworkRequestLogmanRecord netWorkRequest) {
    _addRecord(NetworkLogmanRecord(request: netWorkRequest));
    _logger.i(netWorkRequest.toReadableString());
  }

  void recordNetworkResponse(NetworkResponseLogmanRecord record) {
    final records = List<LogmanRecord>.from(_records.value);
    final index = records.indexWhere((element) {
      if (element is NetworkLogmanRecord) {
        return element.request.id == record.id;
      }
      return false;
    });
    if (index != -1) {
      final networkRecord = NetworkLogmanRecord(
        request: (records[index] as NetworkLogmanRecord).request,
        response: record,
      );
      records[index] = networkRecord;
      _records.value = records;
      _logger.i(networkRecord.toReadableString());
    }
  }

  void attachOverlay({
    required BuildContext context,
    Widget? button,
    Widget? debugPage,
  }) {
    return LogmanOverlay.attachOverlay(
      context: context,
      logman: this,
      button: button,
      debugPage: debugPage,
    );
  }

  void removeOverlay() {
    return LogmanOverlay.removeOverlay();
  }
}
