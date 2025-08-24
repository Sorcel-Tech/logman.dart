import 'package:flutter/material.dart';

/// Enum representing different log levels in order of severity.
enum LogLevel {
  verbose(0, 'VERBOSE', Colors.grey),
  debug(1, 'DEBUG', Colors.blue),
  info(2, 'INFO', Colors.green),
  warn(3, 'WARN', Colors.orange),
  error(4, 'ERROR', Colors.red);

  const LogLevel(this.value, this.name, this.color);

  /// Numeric value for comparison and filtering
  final int value;
  
  /// Display name for the log level
  final String name;
  
  /// Associated color for UI display
  final Color color;

  /// Returns the appropriate icon for each log level
  IconData get icon {
    switch (this) {
      case LogLevel.verbose:
        return Icons.chat_bubble_outline;
      case LogLevel.debug:
        return Icons.bug_report;
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.warn:
        return Icons.warning;
      case LogLevel.error:
        return Icons.error;
    }
  }

  /// Check if this level should be logged based on minimum level
  bool shouldLog(LogLevel minLevel) {
    return value >= minLevel.value;
  }
}