import 'dart:async';

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
  /// Logger instance for internal logging.
  ///
  /// This logger is used to log errors, warnings, and general information
  /// within the `Logman` class.
  late final Logger _logger;

  /// Private constructor for `Logman`, implementing the Singleton pattern.
  ///
  /// This constructor initializes the internal logger and starts the rotation
  /// timer for log maintenance. It should be called only once and is not
  /// meant to be used directly. Access the singleton instance via `Logman.instance`.
  Logman._internal() {
    _logger = Logger();
    _startRotationTimer();
  }

  /// Whether logs should be printed to the console.
  ///
  /// If `true`, logs are printed to the console using the internal logger.
  /// This can be toggled to disable console logging for production.
  bool printLogs = true;

  /// Maximum duration for which logs should be retained in memory.
  ///
  /// Any log older than this duration will be removed during log rotation.
  Duration? maxLogLifetime;

  /// Maximum number of logs that should be retained in memory.
  ///
  /// If the number of logs exceeds this count, older logs will be removed
  /// during log rotation.
  int? maxLogCount;

  /// Timer instance used for scheduling periodic log rotations.
  ///
  /// This timer triggers `_rotateRecords` at the interval defined by `rotationInterval`.
  Timer? _rotationTimer;

  /// Duration between consecutive log rotation executions.
  ///
  /// This interval defines how often `_rotateRecords` is called to remove
  /// outdated logs and control the total log count.
  Duration rotationInterval = const Duration(seconds: 30);

  /// The single public instance of Logman.
  static final Logman instance = Logman._internal();

  /// Stores the list of log records currently retained in memory.
  ///
  /// This is a `ValueNotifier` that notifies listeners whenever the log
  /// records are updated. The logs are retained in a list, which is managed
  /// through log rotation methods like `_rotateRecords`.
  /// Notes:
  /// - The list of log records is constrained by `maxLogLifetime` and `maxLogCount`,
  ///   meaning older or excessive logs are removed during log rotation.
  /// - Use `ValueNotifier<List<LogmanRecord>>` to efficiently notify listeners
  ///   of changes to the logs.
  final _records = ValueNotifier(<LogmanRecord>[]);

  /// Gets the current list of log records.
  ValueNotifier<List<LogmanRecord>> get records => _records;

  /// Starts a periodic timer that triggers log rotation at a specified interval.
  ///
  /// The method cancels any existing timer before starting a new one, ensuring that
  /// only one timer is running. The timer invokes `_rotateRecords` at each interval
  /// to enforce log retention policies, such as `maxLogLifetime` and `maxLogCount`.
  void _startRotationTimer() {
    _rotationTimer?.cancel(); // Cancel any existing timer
    _rotationTimer = Timer.periodic(rotationInterval, (timer) {
      _rotateRecords();
    });
  }

  /// Adds a new log record to the log list.
  ///
  /// This method appends a new log record to `_records`. It also explicitly calls
  /// `_rotateRecords` to ensure that the log list adheres to the defined log
  /// retention policies (like `maxLogLifetime` and `maxLogCount`).
  ///
  /// Parameters:
  /// - `record`: The `LogmanRecord` instance representing the new log entry to add.
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
    var newRecords = _records.value;

    // Check if maxLogLifetime is not null before filtering by dateTime difference
    if (maxLogLifetime != null) {
      newRecords = newRecords.where((record) {
        return now.difference(record.dateTime) < maxLogLifetime!;
      }).toList();
    }

    // Check if maxLogCount is not null before limiting the number of records
    if (maxLogCount != null && newRecords.length > maxLogCount!) {
      newRecords = newRecords.sublist(newRecords.length - maxLogCount!);
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
  /// [maxLogLifetime] is optional, it defines the maximum lifetime
  /// of a single log record
  ///
  /// [maxLogCount] is optional, it defines the maximum number of
  /// log records to keep
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
    if (maxLogLifetime != null) {
      this.maxLogLifetime = maxLogLifetime;

      if (maxLogLifetime < rotationInterval) {
        rotationInterval = maxLogLifetime;
        _startRotationTimer();
      }
    }

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

  /// Stops the log rotation timer.
  void stopTimer() {
    _rotationTimer?.cancel();
  }
}
