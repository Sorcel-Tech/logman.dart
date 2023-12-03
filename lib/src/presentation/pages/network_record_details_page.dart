import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class NetworkRecordDetailsPage extends StatelessWidget {
  final NetworkLogmanRecord record;
  const NetworkRecordDetailsPage({super.key, required this.record});

  static void push({
    required BuildContext context,
    required NetworkLogmanRecord record,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => NetworkRecordDetailsPage(record: record),
        settings: const RouteSettings(name: '/logman-network-details'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Network call details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRequest(),
          const SizedBox(height: 16.0),
          _buildResponse(),
        ],
      ),
    );
  }

  Widget _buildRequest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Request',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        Text(
          record.request.url,
          style: const TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 10.0),
        Text(
          record.request.method,
          style: const TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 10.0),
        Text(
          record.request.headers.toString(),
          style: const TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 10.0),
        Text(
          record.request.body.toString(),
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  Widget _buildResponse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Response',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        Text(
          record.response?.statusCode.toString() ?? 'No response',
          style: const TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 10.0),
        Text(
          record.response?.headers.toString() ?? 'No response',
          style: const TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 10.0),
        Text(
          record.response?.body.toString() ?? 'No response',
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }
}
