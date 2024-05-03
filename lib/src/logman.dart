import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

/// A logging utility class for Flutter applications.
/// It supports various types of logs including simple logs, navigation,
/// and network logs.
///
/// This class uses the Singleton pattern to ensure a single instance
/// is used throughout the application.
class Logman {
  late final Logger _logger;

  Logman._internal() {
    _logger = Logger();
  }

  bool printLogs = true;

  Duration maxLogLifetime = const Duration(minutes: 10);

  int maxLogCount = 100;

  /// The single public instance of Logman.
  static final Logman instance = Logman._internal();

  final _records = ValueNotifier(<LogmanRecord>[]);

  /// Gets the current list of log records.
  ValueNotifier<List<LogmanRecord>> get records => _records;

  void _addRecord(LogmanRecord record) {
    try {
      _records.value = [..._records.value, record];
      _rotateRecords();
    } catch (e) {
      _logger.e(e.toString());
    }
  }

  /// Rotates the log records by enforcing the maximum log lifetime and count.
  ///
  /// This method performs the following operations:
  /// 1. Filters the existing log records to retain only those that were created
  ///    within the defined `maxLogLifetime`.
  /// 2. Trims the list of remaining records to ensure that it does not exceed
  ///    the `maxLogCount` limit, keeping only the most recent records.
  ///
  /// The resulting list of filtered records replaces the current log record list,
  /// thus effectively managing memory usage.
  void _rotateRecords() {
    final now = DateTime.now();
    var newRecords = _records.value.where((record) {
      return now.difference(record.dateTime) < maxLogLifetime;
    }).toList();

    if (newRecords.length > maxLogCount) {
      newRecords = newRecords.sublist(newRecords.length - maxLogCount);
    }

    _records.value = newRecords;
  }

  /// Records a simple log message.
  void info(String message) {
    _addRecord(
      SimpleLogmanRecord(
        message: message,
        source: StackTrace.current.traceSource,
      ),
    );
    if (printLogs) _logger.i(message.shorten());
  }

  /// Records a simple log message.
  void error(Object error, {StackTrace? stackTrace}) {
    _addRecord(
      SimpleLogmanRecord(
        message: error.toString(),
        source: stackTrace?.traceSource ?? StackTrace.current.traceSource,
        isError: true,
      ),
    );
    if (printLogs) _logger.e(error.toString().shorten());
  }

  /// Records navigation events in the application.
  void navigation(NavigationLogmanRecord record) {
    final currentRouteName = record.route.settings.name ?? '';
    final previousRouteName = record.previousRoute?.settings.name ?? '';

    // Ignore Logman routes
    if (currentRouteName.contains('logman') ||
        previousRouteName.contains('logman')) {
      return;
    }
    _addRecord(record);
    if (printLogs) _logger.i(record);
  }

  /// Records a network request.
  void networkRequest(NetworkRequestLogmanRecord netWorkRequest) {
    _addRecord(NetworkLogmanRecord(request: netWorkRequest));
    if (printLogs) _logger.i(netWorkRequest.toReadableString());
  }

  /// Updates a network log with the corresponding response.
  void networkResponse(NetworkResponseLogmanRecord record) {
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
      if (printLogs) _logger.i(networkRecord.toReadableString());
    }
  }

  /// Attaches a logging overlay to the application UI.
  ///
  /// [button] is optional, the default button will be displayed if
  /// it's not giving
  ///
  /// [debugPage] is also optional, you can see an example of this
  /// in the example app
  ///
  /// [printLogs] is optional and true by default, if set to false,
  /// logs will not be printed
  ///
  /// [showOverlay] is optional and true by default, if set to false,
  /// the overlay will not be displayed
  ///
  /// [maxLogLifetime] is optional and set to 10 minutes by default,
  /// it defines the maximum lifetime of a single log record
  ///
  /// [maxLogCount] is optional and set to 100 by default, it defines
  /// the maximum number of log records to keep
  void attachOverlay({
    required BuildContext context,
    Widget? button,
    Widget? debugPage,
    bool printLogs = true,
    bool showOverlay = true,
    Duration? maxLogLifetime,
    int? maxLogCount,
  }) {
    this.printLogs = printLogs;
    if (maxLogLifetime != null) this.maxLogLifetime = maxLogLifetime;
    if (maxLogCount != null) this.maxLogCount = maxLogCount;

    if (!showOverlay) return;

    return LogmanOverlay.attachOverlay(
      context: context,
      logman: this,
      button: button,
      debugPage: debugPage,
    );
  }

  /// Removes the logging overlay from the application UI.
  void removeOverlay() {
    return LogmanOverlay.removeOverlay();
  }
}
