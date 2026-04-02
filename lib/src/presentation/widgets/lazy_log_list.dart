import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

/// A widget that provides lazy loading for large log lists to improve performance.
///
/// This widget loads logs in chunks as the user scrolls, preventing memory issues
/// with large numbers of log records.
class LazyLogList extends StatefulWidget {
  final ValueNotifier<List<LogmanRecord>> records;
  final Widget Function(BuildContext context, LogmanRecord record) itemBuilder;
  final int pageSize;
  final Widget? emptyWidget;
  final EdgeInsets? padding;
  final ScrollController? controller;

  /// Maximum number of records to keep loaded in memory.
  /// Once reached, no further pages are loaded until a full reset occurs.
  /// Defaults to 1000.
  final int maxLoadedRecords;

  /// Whether to display items in reverse order (latest first).
  final bool reverse;

  const LazyLogList({
    super.key,
    required this.records,
    required this.itemBuilder,
    this.pageSize = 50,
    this.emptyWidget,
    this.padding,
    this.controller,
    this.maxLoadedRecords = 1000,
    this.reverse = false,
  });

  @override
  State<LazyLogList> createState() => _LazyLogListState();
}

class _LazyLogListState extends State<LazyLogList> {
  final ScrollController _scrollController = ScrollController();
  final List<LogmanRecord> _loadedRecords = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  /// Track the total record count from the last update to detect
  /// appends vs full resets (e.g. filters, clears).
  int _previousRecordCount = 0;

  ScrollController get effectiveController =>
      widget.controller ?? _scrollController;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    effectiveController.addListener(_onScroll);
    widget.records.addListener(_onRecordsChanged);
  }

  @override
  void dispose() {
    effectiveController.removeListener(_onScroll);
    widget.records.removeListener(_onRecordsChanged);
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onRecordsChanged() {
    if (!mounted) return;

    final allRecords = widget.records.value;
    final newCount = allRecords.length;

    // Case 1: New records were appended (most common during active logging).
    // Append only the new entries to _loadedRecords, preserving scroll position.
    if (newCount > _previousRecordCount && _previousRecordCount > 0) {
      // Only auto-append if the user has already scrolled through all
      // previously loaded pages (i.e. they're near the end). Otherwise
      // just update _hasMore so they can scroll to fetch them.
      if (!_hasMore) {
        final newEntries = allRecords.sublist(_previousRecordCount);
        setState(() {
          _loadedRecords.addAll(newEntries);
          _hasMore = false;
        });
        // Recalculate the current page to stay in sync.
        _currentPage = (_loadedRecords.length / widget.pageSize).ceil();
      } else {
        // More pages still to load — just note that there's still more.
        setState(() {
          _hasMore = true;
        });
      }
      _previousRecordCount = newCount;
      return;
    }

    // Case 2: Records were removed, filtered, or fully replaced.
    // A full reset is necessary.
    _previousRecordCount = newCount;
    setState(() {
      _currentPage = 0;
      _loadedRecords.clear();
      _hasMore = true;
    });
    _loadInitialData();
  }

  void _loadInitialData() {
    if (_isLoading) return;
    _previousRecordCount = widget.records.value.length;
    _loadMoreData();
  }

  void _loadMoreData() {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    Future.microtask(() {
      if (!mounted) return;

      // If we've already loaded the maximum allowed records, stop loading
      // more to prevent unbounded memory growth. The user can still see
      // everything loaded so far without any index-shifting jumps.
      if (_loadedRecords.length >= widget.maxLoadedRecords) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      final allRecords = widget.records.value;
      final startIndex = _currentPage * widget.pageSize;

      if (startIndex >= allRecords.length) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      final endIndex =
          (startIndex + widget.pageSize).clamp(startIndex, allRecords.length);
      final newRecords = allRecords.sublist(startIndex, endIndex);

      setState(() {
        _loadedRecords.addAll(newRecords);
        _currentPage++;
        _hasMore = endIndex < allRecords.length;
        _isLoading = false;
      });
    });
  }

  void _onScroll() {
    if (effectiveController.position.pixels >=
        effectiveController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadedRecords.isEmpty && !_isLoading) {
      return widget.emptyWidget ??
          const Center(
            child: Text(
              'No logs available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
    }

    return ListView.builder(
      controller: effectiveController,
      reverse: widget.reverse,
      padding: widget.padding,
      itemCount: _loadedRecords.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _loadedRecords.length) {
          // Loading indicator
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(context, _loadedRecords[index]);
      },
    );
  }
}

/// A more advanced lazy log list with virtual scrolling capabilities
class VirtualLogList extends StatefulWidget {
  final ValueNotifier<List<LogmanRecord>> records;
  final Widget Function(BuildContext context, LogmanRecord record) itemBuilder;
  final double itemHeight;
  final int visibleItemCount;
  final Widget? emptyWidget;
  final EdgeInsets? padding;

  const VirtualLogList({
    super.key,
    required this.records,
    required this.itemBuilder,
    this.itemHeight = 80.0,
    this.visibleItemCount = 10,
    this.emptyWidget,
    this.padding,
  });

  @override
  State<VirtualLogList> createState() => _VirtualLogListState();
}

class _VirtualLogListState extends State<VirtualLogList> {
  final ScrollController _scrollController = ScrollController();
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.records.addListener(_updateVisibleRange);
    _updateVisibleRange();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    widget.records.removeListener(_updateVisibleRange);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateVisibleRange();
  }

  void _updateVisibleRange() {
    if (!mounted) return;

    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;

    final viewportHeight = _scrollController.hasClients
        ? _scrollController.position.viewportDimension
        : widget.itemHeight * widget.visibleItemCount;

    final firstIndex = (scrollOffset / widget.itemHeight).floor();
    final lastIndex =
        ((scrollOffset + viewportHeight) / widget.itemHeight).ceil();

    final recordCount = widget.records.value.length;

    setState(() {
      _firstVisibleIndex = firstIndex.clamp(0, recordCount - 1);
      _lastVisibleIndex = lastIndex.clamp(0, recordCount - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = widget.records.value;

    if (records.isEmpty) {
      return widget.emptyWidget ??
          const Center(
            child: Text(
              'No logs available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
    }

    return ValueListenableBuilder<List<LogmanRecord>>(
      valueListenable: widget.records,
      builder: (context, currentRecords, _) {
        if (currentRecords.isEmpty) {
          return widget.emptyWidget ??
              const Center(
                child: Text(
                  'No logs available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
        }

        // Calculate visible items with buffer
        const buffer = 5;
        final startIndex =
            (_firstVisibleIndex - buffer).clamp(0, currentRecords.length - 1);
        final endIndex =
            (_lastVisibleIndex + buffer).clamp(0, currentRecords.length - 1);

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Top spacer
            if (startIndex > 0)
              SliverToBoxAdapter(
                child: SizedBox(height: startIndex * widget.itemHeight),
              ),

            // Visible items
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recordIndex = startIndex + index;
                  if (recordIndex >= currentRecords.length) return null;

                  return SizedBox(
                    height: widget.itemHeight,
                    child: widget.itemBuilder(
                      context,
                      currentRecords[recordIndex],
                    ),
                  );
                },
                childCount:
                    (endIndex - startIndex + 1).clamp(0, currentRecords.length),
              ),
            ),

            // Bottom spacer
            if (endIndex < currentRecords.length - 1)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: (currentRecords.length - endIndex - 1) *
                      widget.itemHeight,
                ),
              ),
          ],
        );
      },
    );
  }
}
