import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

class LogmanDashboardPage extends StatelessWidget {
  final Widget? debugPage;
  final Logman logman;

  const LogmanDashboardPage({super.key, this.debugPage, required this.logman});

  static Future<void> push(
    BuildContext context, {
    required Logman logman,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (_) => LogmanDashboardPage(
          logman: logman,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: debugPage != null ? 5 : 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Logman'),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'All'),
              const Tab(text: 'Logs'),
              const Tab(text: 'Network'),
              const Tab(text: 'Navigation'),
              if (debugPage != null) const Tab(text: 'Debug'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: logman.records,
          builder: (context, records, _) {
            return TabBarView(
              children: [
                AllRecordsPage(records: records),
                SimpleRecordsPage(records: records),
                const Center(
                  child: Text('Network'),
                ),
                const Center(
                  child: Text('Navigation'),
                ),
                if (debugPage != null) debugPage!,
              ],
            );
          },
        ),
      ),
    );
  }
}
