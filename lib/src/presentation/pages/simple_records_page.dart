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

    if (simpleRecords.isEmpty) {
      return const Center(
        child: Text('No Logs recorded yet!'),
      );
    }

    return ListView.separated(
      itemCount: simpleRecords.length,
      itemBuilder: (context, index) {
        final record = simpleRecords[index] as SimpleLogmanRecord;
        return SimpleRecordItem(record: record);
      },
      separatorBuilder: (context, index) => const CustomDivider(),
    );
  }
}
