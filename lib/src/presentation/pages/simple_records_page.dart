import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

class SimpleRecordsPage extends StatelessWidget {
  final List<LogmanRecord> records;
  const SimpleRecordsPage({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final simpleRecords = List<LogmanRecord>.from(records)
      ..retainWhere(
        (element) => element is SimpleLogmanRecord,
      );
    return ListView.builder(
      itemCount: simpleRecords.length,
      itemBuilder: (context, index) {
        final record = simpleRecords[index] as SimpleLogmanRecord;
        return SimpleRecordItem(record: record);
      },
    );
  }
}
