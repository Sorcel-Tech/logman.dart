import 'package:logman/logman.dart';

class SimpleLogmanRecord extends LogmanRecord {
  final String message;
  final String source;
  final LogLevel level;
  final String? tag;
  final Map<String, dynamic>? metadata;

  SimpleLogmanRecord({
    required this.message,
    required this.source,
    this.level = LogLevel.info,
    this.tag,
    this.metadata,
  }) : super(LogmanRecordType.simple);

  @override
  String toString() {
    final tagStr = tag != null ? ', tag: $tag' : '';
    return 'SimpleLogmanRecord(message: $message, source: $source, level: ${level.name}$tagStr)';
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'source': source,
      'level': level.name,
      'tag': tag,
      'metadata': metadata,
    };
  }

  /// Convenience getters for log levels
  bool get isVerbose => level == LogLevel.verbose;
  bool get isDebug => level == LogLevel.debug;
  bool get isInfo => level == LogLevel.info;
  bool get isWarn => level == LogLevel.warn;
  bool get isError => level == LogLevel.error;
}
