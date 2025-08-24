import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
    _startBatchProcessTimer();
  }

  /// Whether logs should be printed to the console.
  ///
  /// If `true`, logs are printed to the console using the internal logger.
  /// This can be toggled to disable console logging for production.
  bool printLogs = true;

  /// Whether logs should be recorded.
  ///
  /// If `true`, [Logman] records the logs.
  /// If `false`, [Logman] ignores the logs totally (this can be useful in prod).
  bool recordLogs = true;

  /// Minimum log level to record and display.
  ///
  /// Logs below this level will be ignored.
  LogLevel minLogLevel = LogLevel.verbose;

  /// Whether to process logs in background to improve performance.
  bool enableBackgroundProcessing = true;

  /// Queue for background log processing.
  final List<Map<String, dynamic>> _logQueue = [];

  /// Timer for batch processing logs.
  Timer? _batchProcessTimer;

  /// Duration for batch processing interval.
  Duration batchProcessInterval = const Duration(milliseconds: 100);

  /// Maximum number of logs to process in a single batch.
  int maxBatchSize = 50;

  /// Memory threshold (in MB) after which aggressive cleanup is triggered.
  int memoryThresholdMB = 100;

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
    if (!recordLogs) return;

    if (enableBackgroundProcessing) {
      _queueLogForProcessing(record);
    } else {
      _processLogRecord(record);
    }
  }

  /// Queues a log record for background processing.
  void _queueLogForProcessing(LogmanRecord record) {
    _logQueue.add({
      'record': record,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // If queue is full, process immediately
    if (_logQueue.length >= maxBatchSize) {
      _processBatch();
    }
  }

  /// Processes a log record immediately.
  void _processLogRecord(LogmanRecord record) {
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
  void info(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LogLevel.info, message, tag: tag, metadata: metadata);
  }

  /// Records a simple log message.
  void error(
    Object error, {
    StackTrace? stackTrace,
    String? tag,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.error,
      error.toString(),
      tag: tag,
      metadata: metadata,
      stackTrace: stackTrace,
    );
  }

  /// Records a warning log message.
  void warn(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LogLevel.warn, message, tag: tag, metadata: metadata);
  }

  /// Records a debug log message.
  void debug(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LogLevel.debug, message, tag: tag, metadata: metadata);
  }

  /// Records a verbose log message.
  void verbose(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LogLevel.verbose, message, tag: tag, metadata: metadata);
  }

  /// Internal method to handle logging with levels.
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    if (!level.shouldLog(minLogLevel)) return;

    final trace = stackTrace ?? StackTrace.current;
    _addRecord(
      SimpleLogmanRecord(
        message: message,
        source: kIsWeb ? trace.extractSourceFromLine(3) : trace.traceSource,
        level: level,
        tag: tag,
        metadata: metadata,
      ),
    );

    if (printLogs) {
      switch (level) {
        case LogLevel.verbose:
          _logger.t(message.shorten());
        case LogLevel.debug:
          _logger.d(message.shorten());
        case LogLevel.info:
          _logger.i(message.shorten());
        case LogLevel.warn:
          _logger.w(message.shorten());
        case LogLevel.error:
          _logger.e(message.shorten());
      }
    }
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
  ///
  /// [recordLogs] is optional and true by default, if set to false,
  /// logs will not be recorded
  void attachOverlay({
    required BuildContext context,
    Widget? button,
    Widget? debugPage,
    bool printLogs = true,
    bool showOverlay = true,
    Duration? maxLogLifetime,
    int? maxLogCount,
    bool? recordLogs,
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

    if (recordLogs != null) this.recordLogs = recordLogs;

    return LogmanOverlay.attachOverlay(
      context: context,
      logman: this,
      button: button,
      debugPage: debugPage,
    );
  }

  /// Opens the Logman dashboard.
  /// This can be useful when you don't want to use the overlay but
  /// you want to open the dashboard manually using another widget
  /// Or if you want to open he dashboard on device shake.
  ///
  /// [context] is required, the current context of the application
  /// [debugPage] is optional. You can see an example of this in the example app
  Future<void> openDashboard(BuildContext context, {Widget? debugPage}) {
    return LogmanDashboardPage.push(
      context,
      logman: this,
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
    _batchProcessTimer?.cancel();
  }

  /// Starts the batch processing timer.
  void _startBatchProcessTimer() {
    _batchProcessTimer?.cancel();
    _batchProcessTimer = Timer.periodic(batchProcessInterval, (timer) {
      if (_logQueue.isNotEmpty) {
        _processBatch();
      }
    });
  }

  /// Processes a batch of queued logs.
  void _processBatch() {
    if (_logQueue.isEmpty) return;

    try {
      final batchToProcess = _logQueue.take(maxBatchSize).toList();
      _logQueue.removeRange(
        0,
        batchToProcess.length.clamp(0, _logQueue.length),
      );

      final newRecords =
          batchToProcess.map((item) => item['record'] as LogmanRecord).toList();

      _records.value = [..._records.value, ...newRecords];
      _rotateRecords();

      // Check memory usage and trigger cleanup if needed
      _checkMemoryUsage();
    } catch (e) {
      _logger.e('Error processing log batch: $e');
    }
  }

  /// Checks memory usage and triggers cleanup if threshold is exceeded.
  void _checkMemoryUsage() {
    // Estimate memory usage (rough calculation)
    final recordCount = _records.value.length;
    final estimatedMemoryMB =
        (recordCount * 0.5) / 1024; // Rough estimate: 0.5KB per record

    if (estimatedMemoryMB > memoryThresholdMB) {
      _performAggressiveCleanup();
    }
  }

  /// Performs aggressive memory cleanup.
  void _performAggressiveCleanup() {
    final records = _records.value;
    final targetCount = (maxLogCount ?? 1000) ~/ 2; // Keep only half

    if (records.length > targetCount) {
      final remainingRecords = records.sublist(records.length - targetCount);
      _records.value = remainingRecords;

      if (printLogs) {
        _logger.i(
          'Performed aggressive memory cleanup, kept $targetCount most recent logs',
        );
      }
    }
  }

  /// Configures background processing settings.
  void configureBackgroundProcessing({
    bool? enabled,
    Duration? batchInterval,
    int? batchSize,
    int? memoryThreshold,
  }) {
    if (enabled != null) enableBackgroundProcessing = enabled;
    if (batchInterval != null) {
      batchProcessInterval = batchInterval;
      _startBatchProcessTimer();
    }
    if (batchSize != null) maxBatchSize = batchSize;
    if (memoryThreshold != null) memoryThresholdMB = memoryThreshold;
  }

  /// Forces processing of all queued logs.
  void flushLogQueue() {
    while (_logQueue.isNotEmpty) {
      _processBatch();
    }
  }

  /// Shorthand for [error] method.
  void e(
    Object error, {
    StackTrace? stackTrace,
    String? tag,
    Map<String, dynamic>? metadata,
  }) =>
      this.error(error, stackTrace: stackTrace, tag: tag, metadata: metadata);

  /// Shorthand for [info] method.
  void i(String message, {String? tag, Map<String, dynamic>? metadata}) =>
      info(message, tag: tag, metadata: metadata);

  /// Shorthand for [warn] method.
  void w(String message, {String? tag, Map<String, dynamic>? metadata}) =>
      warn(message, tag: tag, metadata: metadata);

  /// Shorthand for [debug] method.
  void d(String message, {String? tag, Map<String, dynamic>? metadata}) =>
      debug(message, tag: tag, metadata: metadata);

  /// Shorthand for [verbose] method.
  void v(String message, {String? tag, Map<String, dynamic>? metadata}) =>
      verbose(message, tag: tag, metadata: metadata);

  /// Sets the minimum log level.
  void setMinLogLevel(LogLevel level) {
    minLogLevel = level;
  }

  /// Gets all records filtered by log level.
  List<LogmanRecord> getRecordsByLevel(LogLevel minLevel) {
    return _records.value.where((record) {
      if (record is SimpleLogmanRecord) {
        return record.level.shouldLog(minLevel);
      }
      return true; // Include non-simple records
    }).toList();
  }

  /// Gets all records filtered by tag.
  List<LogmanRecord> getRecordsByTag(String tag) {
    return _records.value.where((record) {
      if (record is SimpleLogmanRecord) {
        return record.tag == tag;
      }
      return false;
    }).toList();
  }

  /// Gets all unique tags from recorded logs.
  List<String> getAllTags() {
    final tags = <String>{};
    for (final record in _records.value) {
      if (record is SimpleLogmanRecord && record.tag != null) {
        tags.add(record.tag!);
      }
    }
    return tags.toList()..sort();
  }

  /// Gets memory usage statistics.
  Map<String, dynamic> getMemoryStats() {
    final recordCount = _records.value.length;
    final queueSize = _logQueue.length;
    final estimatedMemoryKB = recordCount * 0.5; // Rough estimate

    return {
      'recordCount': recordCount,
      'queueSize': queueSize,
      'estimatedMemoryKB': estimatedMemoryKB,
      'estimatedMemoryMB': estimatedMemoryKB / 1024,
      'backgroundProcessingEnabled': enableBackgroundProcessing,
    };
  }
}
