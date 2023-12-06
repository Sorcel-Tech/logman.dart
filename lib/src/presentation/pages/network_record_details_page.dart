import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

class NetworkRecordDetailsPage extends StatefulWidget {
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
  State<NetworkRecordDetailsPage> createState() =>
      _NetworkRecordDetailsPageState();
}

class _NetworkRecordDetailsPageState extends State<NetworkRecordDetailsPage>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  NetworkLogmanRecord get record => widget.record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          '${record.request.method} ${Uri.parse(record.request.url).path}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20.0),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Request'),
            Tab(text: 'Response'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequest(),
          _buildResponse(),
        ],
      ),
    );
  }

  Widget _buildRequest() {
    final url = Uri.parse(record.request.url);
    return ListView(
      children: [
        _NetworkDetailItem(
          title: 'Method',
          subtitle: record.request.method,
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Base URL',
          subtitle: url.host,
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Endpoint',
          subtitle: url.path,
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'query parameters',
          subtitleWidget: url.queryParameters.entries.isEmpty
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in url.queryParameters.entries)
                      GestureDetector(
                        onTap: () => entry.value.copyToClipboard(context),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}: ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(entry.value),
                          ],
                        ),
                      ),
                  ],
                ),
          subtitle: 'No query parameters',
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Duration',
          subtitle: record.durationInMs,
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Started',
          subtitle: record.request.dateFormatted,
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Finished',
          subtitle: record.response?.dateFormatted ?? '',
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Body',
          subtitle: record.request.body == null
              ? 'No body sent with request'
              : record.request.body.toString(),
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Headers',
          subtitle: 'No headers sent with request',
          subtitleWidget: (record.request.headers?.isEmpty ?? true)
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in record.request.headers!.entries)
                      GestureDetector(
                        onTap: () =>
                            entry.value.toString().copyToClipboard(context),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(entry.value.toString()),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 30.0),
      ],
    );
  }

  Widget _buildResponse() {
    if (record.response == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        _NetworkDetailItem(
          title: 'status',
          subtitle: record.response?.statusCode.toString(),
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Received at',
          subtitle: record.response?.dateFormatted,
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Bytes received',
          subtitle: record.response?.sizeInBytes,
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Headers',
          subtitle: 'No headers received with response',
          subtitleWidget: (record.response?.headers?.isEmpty ?? true)
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in record.response!.headers!.entries)
                      GestureDetector(
                        onTap: () => entry.value.copyToClipboard(context),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}: ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Flexible(child: Text(entry.value)),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const CustomDivider(),
        _NetworkDetailItem(
          title: 'Body',
          subtitle: record.response?.body == null
              ? 'No body passed with request'
              : record.response?.body.toString(),
        ),
        const SizedBox(height: 30.0),
      ],
    );
  }
}

class _NetworkDetailItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;

  const _NetworkDetailItem({
    required this.title,
    this.subtitle,
    this.subtitleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: subtitleWidget != null
          ? null
          : () {
              if (subtitle != null) subtitle!.copyToClipboard(context);
            },
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
      subtitle: subtitleWidget ??
          SelectableText(
            subtitle ?? '',
            style: const TextStyle(fontSize: 14.0),
          ),
    );
  }
}
