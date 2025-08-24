import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class AllRecordsPage extends StatelessWidget {
  final List<LogmanRecord> records;
  const AllRecordsPage({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text('Nothing is recorded yet!'),
      );
    }

    return ListView.separated(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        if (record is SimpleLogmanRecord) {
          return SimpleRecordItem(record: record);
        }

        if (record is NavigationLogmanRecord) {
          return NavigationRecordItem(record: record);
        }

        if (record is NetworkLogmanRecord) {
          return NetworkRecordItem(record: record);
        }

        return const SizedBox.shrink();
      },
      separatorBuilder: (context, index) => const CustomDivider(),
    );
  }
}
