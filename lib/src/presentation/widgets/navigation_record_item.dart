import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class NavigationRecordItem extends StatelessWidget {
  final NavigationLogmanRecord record;
  const NavigationRecordItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeadingIcon(record.action),
      title: _buildTitleText(),
      subtitle: Text(
        record.timeFormatted,
        style: const TextStyle(fontSize: 14.0, color: Colors.grey),
      ),
    );
  }

  Widget _buildLeadingIcon(NavigationAction action) {
    IconData icon;
    Color color;

    switch (action) {
      case NavigationAction.push:
        icon = Icons.arrow_forward;
        color = Colors.green;
      case NavigationAction.pop:
        icon = Icons.arrow_back;
        color = Colors.red;
      case NavigationAction.replace:
        icon = Icons.swap_horiz;
        color = Colors.grey.shade900;
      default:
        icon = Icons.remove;
        color = Colors.grey;
    }

    return Icon(icon, color: color);
  }

  Widget _buildTitleText() {
    final titleText =
        'Navigation ${record.action.toString().split('.').last}: ${record.route.settings.name}';
    return Text(
      titleText,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
    );
  }
}
