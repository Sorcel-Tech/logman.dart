import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

class SimpleRecordsPage extends StatefulWidget {
  final List<LogmanRecord> records;

  const SimpleRecordsPage({super.key, required this.records});

  @override
  State<SimpleRecordsPage> createState() => _SimpleRecordsPageState();
}

class _SimpleRecordsPageState extends State<SimpleRecordsPage> {
  late final ValueNotifier<List<LogmanRecord>> _recordsNotifier;

  @override
  void initState() {
    super.initState();
    final simpleRecords = List<LogmanRecord>.from(widget.records)
      ..retainWhere((element) => element is SimpleLogmanRecord);
    _recordsNotifier = ValueNotifier(simpleRecords);
  }

  @override
  void dispose() {
    _recordsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LazyLogList(
      records: _recordsNotifier,
      pageSize: 25, // Load 25 items at a time for better performance
      itemBuilder: (context, record) {
        return Column(
          children: [
            SimpleRecordItem(record: record as SimpleLogmanRecord),
            const CustomDivider(),
          ],
        );
      },
      emptyWidget: const Center(
        child: Text('No Logs recorded yet!'),
      ),
    );
  }
}
