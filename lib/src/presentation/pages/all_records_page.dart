import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

class AllRecordsPage extends StatelessWidget {
  final List<LogmanRecord> records;
  const AllRecordsPage({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        if (record is SimpleLogmanRecord) {
          return SimpleRecordItem(record: record);
        }

        if (record is NavigationLogmanRecord) {
          return NavigationRecordItem(record: record);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
