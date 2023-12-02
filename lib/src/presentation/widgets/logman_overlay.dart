import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:logman/src/presentation/presentation.dart';

class LogmanOverlay extends StatelessWidget {
  final Widget? button;
  final Logman logman;
  static late OverlayEntry _overlayEntry;

  const LogmanOverlay._({
    this.button,
    required this.logman,
  });

  static void attachOverlay({
    required BuildContext context,
    required Logman logman,
    Widget? button,
  }) {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => LogmanOverlay._(
        button: button,
        logman: logman,
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
    );
  }
}

class _DraggableFAB extends StatefulWidget {
  final Widget? button;
  final Logman logman;

  const _DraggableFAB({this.button, required this.logman});

  @override
  State<_DraggableFAB> createState() => _DraggableFABState();
}

class _DraggableFABState extends State<_DraggableFAB> {
  double dx = 50.0;
  double dy = 50.0;
  final containerSize = 50.0;
  final GlobalKey _buttonKey = GlobalKey();
  bool isOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final buttonSize = _buttonKey.currentContext!.size!;
      dx = size.width - (buttonSize.width + 10);
      dy = (size.height / 2) - (buttonSize.height / 2);
      setState(() {});
    });
  }

  Logman get logman => widget.logman;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;
    const padding = 10.0;

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

        await LogmanDashboardPage.push(context, logman: logman);

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
