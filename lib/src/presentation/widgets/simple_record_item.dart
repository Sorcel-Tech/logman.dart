import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class SimpleRecordItem extends StatelessWidget {
  final SimpleLogmanRecord record;
  const SimpleRecordItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => record.message.copyToClipboard(context),
      leading: Icon(
        record.isError ? Icons.error : Icons.info_outline,
        color: record.isError ? Colors.red : Colors.black,
      ),
      title: Text(
        record.source,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(record.message, maxLines: 4, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Text(
            record.timeFormatted,
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
        ],
      ),
      trailing: const Icon(Icons.copy, color: Colors.black),
    );
  }
}
