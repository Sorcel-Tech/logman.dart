import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/delegates/delegates.dart';

enum NetworkStatus { all, error, success }

class LogmanDashboardPage extends StatefulWidget {
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
        builder: (_) => LogmanSessionManager(
          logman: logman,
          onSessionExpired: () {
            // Auto-close dashboard when session expires
            Navigator.of(_).pop();
          },
          child: withLogmanAuth(
            logman: logman,
            child: LogmanDashboardPage(
              logman: logman,
              debugPage: debugPage,
            ),
          ),
        ),
        fullscreenDialog: true,
        settings: const RouteSettings(name: '/logman-dashboard'),
      ),
    );
  }

  @override
  State<LogmanDashboardPage> createState() => _LogmanDashboardPageState();
}

class _LogmanDashboardPageState extends State<LogmanDashboardPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0; // To track tab page index

  late final NetworkRecordNotifier _recordNotifier;
  late final _tabController = TabController(
    initialIndex: currentIndex,
    length: widget.debugPage != null ? 5 : 4,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    // Get all NetworkLogmanRecords from logman record list
    final networkRecords =
        widget.logman.records.value.whereType<NetworkLogmanRecord>().toList();

    _recordNotifier = NetworkRecordNotifier(networkRecords);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Auto-logout when dashboard is closed
    if (widget.logman.requiresAuthentication && widget.logman.isAuthenticated) {
      widget.logman.logout();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Logman',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.logman.requiresAuthentication &&
                widget.logman.isAuthenticated)
              LogmanSessionInfo(
                logman: widget.logman,
                textStyle: const TextStyle(fontSize: 10),
              ),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          onTap: (value) => setState(() => currentIndex = value),
          // Update currentIndex value
          tabs: [
            const Tab(text: 'All'),
            const Tab(text: 'Logs'),
            const Tab(text: 'Network'),
            const Tab(text: 'Navigation'),
            if (widget.debugPage != null) const Tab(text: 'Debug'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => showSearch(
              context: context,
              delegate: RecordSearchDelegate(
                records: widget.logman.records.value.reversed.toList(),
              ),
            ),
            icon: const Icon(Icons.search_rounded),
          ),
          // Only show these action widgets when network tab is active
          Visibility(
            visible: currentIndex == 2,
            child: _NetworkFilterButton(recordsNotifier: _recordNotifier),
          ),
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
        valueListenable: widget.logman.records,
        builder: (context, records, _) {
          // Reverse the list to show the latest records first
          records = records.reversed.toList();
          return TabBarView(
            controller: _tabController,
            children: [
              AllRecordsPage(records: records),
              SimpleRecordsPage(records: records),
              NetworkRecordsPage(networkRecordNotifier: _recordNotifier),
              NavigationRecordsPage(records: records),
              if (widget.debugPage != null) widget.debugPage!,
            ],
          );
        },
      ),
    );
  }
}

class _NetworkFilterButton extends StatefulWidget {
  const _NetworkFilterButton({required this.recordsNotifier});

  final NetworkRecordNotifier recordsNotifier;

  @override
  State<_NetworkFilterButton> createState() => _NetworkFilterButtonState();
}

class _NetworkFilterButtonState extends State<_NetworkFilterButton> {
  late final NetworkRecordNotifier _recordNotifier;

  @override
  void initState() {
    super.initState();

    _recordNotifier = widget.recordsNotifier;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NetworkStatus>(
      position: PopupMenuPosition.under,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      onSelected: (value) => _recordNotifier.filterNetworkRecords(value),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: NetworkStatus.all,
          child: filterPopupButton(
            icon: Icons.public,
            title: 'All',
          ),
        ),
        PopupMenuItem(
          value: NetworkStatus.error,
          child: filterPopupButton(
            icon: Icons.public_off,
            title: 'Error',
            color: Colors.red,
          ),
        ),
        PopupMenuItem(
          value: NetworkStatus.success,
          child: filterPopupButton(
            icon: Icons.public,
            title: 'Success',
            color: Colors.green,
          ),
        ),
      ],
      child: const Icon(Icons.filter_alt_rounded),
    );
  }

  Row filterPopupButton({
    required IconData icon,
    required String title,
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Text(title),
      ],
    );
  }
}
