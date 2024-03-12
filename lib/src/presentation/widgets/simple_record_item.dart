import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class SimpleRecordItem extends StatelessWidget {
  final SimpleLogmanRecord record;
  const SimpleRecordItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => record.message.copyToClipboard(context),
      title: Row(
        children: [
          Icon(
            record.isError ? Icons.error : Icons.info_outline,
            color: record.isError ? Colors.red : Colors.black,
            size: 17.0,
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              record.source,
              style:
                  const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.0),
          ),
          const SizedBox(height: 5),
          Text(
            record.timeFormatted,
            style: const TextStyle(fontSize: 13.0, color: Colors.grey),
          ),
        ],
      ),
      trailing: const Icon(Icons.copy, color: Colors.black, size: 17.0),
    );
  }
}
