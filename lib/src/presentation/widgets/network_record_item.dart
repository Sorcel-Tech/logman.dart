import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

class NetworkRecordItem extends StatelessWidget {
  final NetworkLogmanRecord record;

  const NetworkRecordItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return _buildNetworkItem(context);
  }

  Widget _buildNetworkItem(BuildContext context) {
    return ListTile(
      onTap: () => _navigateToDetails(context),
      leading: _buildStatusIcon(),
      title: _buildTitle(),
      subtitle: _buildSubtitle(),
      trailing: record.response == null
          ? const CupertinoActivityIndicator()
          : const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  void _navigateToDetails(BuildContext context) {
    NetworkRecordDetailsPage.push(context: context, record: record);
  }

  Widget _buildStatusIcon() {
    final statusCode = record.response?.statusCode;

    IconData icon;
    Color color;

    if (statusCode == null) {
      icon = Icons.public_off;
      color = Colors.grey;
    } else if (statusCode >= 200 && statusCode < 300) {
      icon = Icons.public;
      color = Colors.green;
    } else {
      icon = Icons.public_off;
      color = Colors.red;
    }

    return Icon(icon, color: color);
  }

  Widget _buildTitle() {
    return Text(
      '${record.request.method} ${Uri.parse(record.request.url).path}',
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          record.request.url,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: const TextStyle(fontSize: 14.0),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            record.response == null
                ? record.timeFormatted
                : '${record.timeFormatted} • ${record.durationInMs}',
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
