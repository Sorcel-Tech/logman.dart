import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

/// A widget that provides an overlay for logging and debugging.
/// It can attach a draggable floating action button (FAB) to the app's UI.
class LogmanOverlay extends StatelessWidget {
  final Widget? button;
  final Widget? debugPage;
  final Logman logman;
  static late OverlayEntry _overlayEntry;

  const LogmanOverlay._({
    this.button,
    this.debugPage,
    required this.logman,
  });

  static void attachOverlay({
    required BuildContext context,
    required Logman logman,
    Widget? button,
    Widget? debugPage,
  }) {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => LogmanOverlay._(
        button: button,
        logman: logman,
        debugPage: debugPage,
      ),
    );

    overlay.insert(_overlayEntry);
  }

  static void removeOverlay() {
    _overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return _DraggableFAB(
      button: button,
      logman: logman,
      debugPage: debugPage,
    );
  }
}

class _DraggableFAB extends StatefulWidget {
  final Widget? button;
  final Widget? debugPage;
  final Logman logman;

  const _DraggableFAB({this.button, required this.logman, this.debugPage});

  @override
  State<_DraggableFAB> createState() => _DraggableFABState();
}

class _DraggableFABState extends State<_DraggableFAB>
    with WidgetsBindingObserver {
  double dx = 50.0;
  double dy = 50.0;
  final containerSize = 50.0;
  final GlobalKey _buttonKey = GlobalKey();
  bool isOpened = false;
  final padding = 10.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final buttonSize = _buttonKey.currentContext!.size!;
      dx = size.width - (buttonSize.width + padding);
      dy = (size.height / 2) - (buttonSize.height / 2);
      setState(() {});
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => updatePosition(context));
  }

  void updatePosition(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonSize =
        _buttonKey.currentContext?.size ?? Size(containerSize, containerSize);
    dx = (dx < size.width / 2)
        ? padding
        : size.width - (buttonSize.width + padding);
    dy = min(
      size.height - (buttonSize.height + MediaQuery.of(context).padding.bottom),
      max(MediaQuery.of(context).padding.top + kToolbarHeight, dy),
    );
    setState(() {});
  }

  Logman get logman => widget.logman;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: dy,
      left: dx,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isOpened
            ? const SizedBox()
            : Draggable(
                feedback: _buildOverlayWidget(context),
                childWhenDragging: const SizedBox.shrink(),
                onDragEnd: (dragDetails) {
                  dx = dragDetails.offset.dx;
                  dy = dragDetails.offset.dy;

                  // we need the button's size to correctly snap it to the edge
                  final buttonSize = _buttonKey.currentContext!.size!;

                  if (dx < screenWidth / 2) {
                    dx = padding;
                  } else {
                    dx = screenWidth - (buttonSize.width + padding);
                  }

                  if (dy < kToolbarHeight + topPadding) {
                    dy = kToolbarHeight + topPadding;
                  } else if (dy >
                      screenHeight - (buttonSize.height + bottomPadding)) {
                    dy = screenHeight - (buttonSize.height + bottomPadding);
                  }

                  dx = min(
                    screenWidth - (buttonSize.width + padding),
                    max(padding, dx),
                  );
                  dy = min(
                    screenHeight - (buttonSize.height + bottomPadding),
                    max(kToolbarHeight + topPadding, dy),
                  );
                  setState(() {});
                },
                child: _buildOverlayWidget(context),
              ),
      ),
    );
  }

  Widget _buildOverlayWidget(BuildContext context) {
    return GestureDetector(
      key: _buttonKey,
      onTap: () async {
        isOpened = true;
        setState(() {});

        await LogmanDashboardPage.push(
          context,
          logman: logman,
          debugPage: widget.debugPage,
        );

        isOpened = false;
        setState(() {});
      },
      child: AbsorbPointer(
        child: widget.button ??
            Container(
              height: containerSize,
              width: containerSize,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bug_report,
                color: Colors.white,
              ),
            ),
      ),
    );
  }
}
