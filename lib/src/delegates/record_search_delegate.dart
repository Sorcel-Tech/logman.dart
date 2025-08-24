import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class RecordSearchDelegate extends SearchDelegate<LogmanRecord> {
  final List<LogmanRecord> records;

  RecordSearchDelegate({
    super.searchFieldLabel,
    super.searchFieldStyle,
    super.searchFieldDecorationTheme,
    super.keyboardType,
    super.textInputAction,
    required this.records,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      // Clear search query button
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear_rounded),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Back button
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const BackButtonIcon(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchRecords = _likeSearch(records);

    return _searchRecordListView(searchRecords);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final searchRecords = _likeSearch(records);

    if (searchRecords.isEmpty) {
      return const Center(
        child: Text.rich(
          TextSpan(
            text: 'No record(s) found',
            children: [
              TextSpan(text: ' 🫣', style: TextStyle(fontSize: 25)),
            ],
          ),
        ),
      );
    }

    return _searchRecordListView(searchRecords);
  }

  Widget _searchRecordListView(List<LogmanRecord> searchRecords) {
    return ListView.separated(
      itemCount: searchRecords.length,
      itemBuilder: (context, index) {
        final record = searchRecords[index];
        if (record is SimpleLogmanRecord) {
          return SimpleRecordItem(record: record);
        }

        if (record is NavigationLogmanRecord) {
          return NavigationRecordItem(record: record);
        }

        if (record is NetworkLogmanRecord) {
          return NetworkRecordItem(record: record);
        }

        return const SizedBox.shrink();
      },
      separatorBuilder: (context, index) => const CustomDivider(),
    );
  }

  // Function to perform a "like" search on all logman records
  List<LogmanRecord> _likeSearch(List<LogmanRecord> records) {
    // Convert search query to lowercase for case-insensitive search
    final String lowerSearchQuery = query.toLowerCase();

    return records.where((record) {
      if (record is SimpleLogmanRecord) {
        return record.message.toLowerCase().contains(lowerSearchQuery);
      }

      if (record is NavigationLogmanRecord) {
        return record.routeName.toLowerCase().contains(lowerSearchQuery) ||
            record.action.name.toLowerCase().contains(lowerSearchQuery);
      }

      if (record is NetworkLogmanRecord) {
        return record.request.url.toLowerCase().contains(lowerSearchQuery) ||
            Uri.parse(record.request.url)
                .path
                .toLowerCase()
                .contains(lowerSearchQuery) ||
            record.request.method.toLowerCase().contains(lowerSearchQuery);
      }

      return false;
    }).toList();
  }
}
