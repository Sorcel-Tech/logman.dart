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

  void addSimpleRecord(String message) {
    _addRecord(SimpleLogmanRecord(message));
    _logger.i(message);
  }

  void addNavigationRecord(NavigationLogmanRecord record) {
    _addRecord(record);
    _logger.i(record);
  }

  void attachOverlay({
    required BuildContext context,
    Widget? button,
  }) {
    return LogmanOverlay.attachOverlay(
      context: context,
      logman: this,
      button: button,
    );
  }
}
