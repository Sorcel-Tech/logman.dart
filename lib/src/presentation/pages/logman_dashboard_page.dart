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
    Widget? debugPage,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (_) => LogmanDashboardPage(
          logman: logman,
          debugPage: debugPage,
        ),
        fullscreenDialog: true,
        settings: const RouteSettings(name: '/logman-dashboard'),
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
            tabAlignment: TabAlignment.center,
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
            // Reverse the list to show the latest records first
            records = records.reversed.toList();
            return TabBarView(
              children: [
                AllRecordsPage(records: records),
                SimpleRecordsPage(records: records),
                NetworkRecordsPage(records: records),
                NavigationRecordsPage(records: records),
                if (debugPage != null) debugPage!,
              ],
            );
          },
        ),
      ),
    );
  }
}
