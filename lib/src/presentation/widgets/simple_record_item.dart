import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class SimpleRecordItem extends StatelessWidget {
  final SimpleLogmanRecord record;
  const SimpleRecordItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(
        record.source,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(record.message),
          const SizedBox(height: 5),
          Text(
            record.timeFormatted,
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
