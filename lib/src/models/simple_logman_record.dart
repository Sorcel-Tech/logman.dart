import 'package:logman/logman.dart';

class SimpleLogmanRecord extends LogmanRecord {
  final String message;
  final String source;

  SimpleLogmanRecord({required this.message, required this.source})
      : super(LogmanRecordType.simple);
}
