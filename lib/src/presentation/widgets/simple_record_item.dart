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
            record.level.icon,
            color: record.level.color,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: record.level.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: record.level.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  record.level.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: record.level.color,
                  ),
                ),
              ),
              if (record.tag != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    record.tag!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            record.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.0),
          ),
          const SizedBox(height: 5),
          Text(
            record.timeFormatted,
            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
        ],
      ),
      trailing: const Icon(Icons.copy, size: 17.0),
    );
  }
}
