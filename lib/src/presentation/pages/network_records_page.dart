import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

class NetworkRecordsPage extends StatelessWidget {
  final List<LogmanRecord> records;

  const NetworkRecordsPage({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final simpleRecords = List<LogmanRecord>.from(records)
      ..retainWhere(
        (element) => element is NetworkLogmanRecord,
      );

    if (simpleRecords.isEmpty) {
      return const Center(
        child: Text('No Network calls recorded yet!'),
      );
    }

    return ListView.separated(
      itemCount: simpleRecords.length,
      itemBuilder: (context, index) {
        final record = simpleRecords[index] as NetworkLogmanRecord;
        return NetworkRecordItem(record: record);
      },
      separatorBuilder: (context, index) => const CustomDivider(),
    );
  }
}
