import 'package:logman/logman.dart';

class SimpleLogmanRecord extends LogmanRecord {
  final String message;
  final String source;
  final bool isError;

  SimpleLogmanRecord({
    required this.message,
    required this.source,
    this.isError = false,
  }) : super(LogmanRecordType.simple);
}
