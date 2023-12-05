import 'package:intl/intl.dart';
import 'package:logman/logman.dart';

abstract class LogmanRecord {
  final LogmanRecordType type;
  final DateTime _dateTime;

  LogmanRecord(this.type) : _dateTime = DateTime.now();

  DateTime get dateTime => _dateTime;

  String get timeFormatted =>
      DateFormat("MMM d 'at'").add_Hms().format(dateTime);
}
