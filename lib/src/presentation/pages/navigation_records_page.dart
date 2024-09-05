import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

class NavigationRecordsPage extends StatelessWidget {
  final List<LogmanRecord> records;

  const NavigationRecordsPage({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final navigationRecords = List<LogmanRecord>.from(records)
      ..retainWhere(
        (element) => element is NavigationLogmanRecord,
      );

    if (navigationRecords.isEmpty) {
      return const Center(
        child: Text(
          'No Navigation logs recorded yet. Check your navigation observer!',
        ),
      );
    }

    return ListView.separated(
      itemCount: navigationRecords.length,
      itemBuilder: (context, index) {
        final record = navigationRecords[index] as NavigationLogmanRecord;
        return NavigationRecordItem(record: record);
      },
      separatorBuilder: (context, index) => const CustomDivider(),
    );
  }
}
