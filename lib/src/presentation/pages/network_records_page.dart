import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class NetworkRecordsPage extends StatelessWidget {
  final NetworkRecordNotifier networkRecordNotifier;

  const NetworkRecordsPage({super.key, required this.networkRecordNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<NetworkLogmanRecord>>(
      valueListenable: networkRecordNotifier,
      builder: (context, networkRecords, child) {
        if (networkRecords.isEmpty) {
          return const Center(
            child: Text('No Network calls recorded yet!'),
          );
        }

        return ListView.separated(
          itemCount: networkRecords.length,
          itemBuilder: (context, index) {
            final networkRecord = networkRecords.reversed.toList()[index];
            return NetworkRecordItem(record: networkRecord);
          },
          separatorBuilder: (context, index) => const CustomDivider(),
        );
      },
    );
  }
}
