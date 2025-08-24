import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

/// A widget that manages Logman authentication sessions and handles timeouts
class LogmanSessionManager extends StatefulWidget {
  final Logman logman;
  final Widget child;
  final Duration checkInterval;
  final VoidCallback? onSessionExpired;

  const LogmanSessionManager({
    super.key,
    required this.logman,
    required this.child,
    this.checkInterval = const Duration(seconds: 30),
    this.onSessionExpired,
  });

  @override
  State<LogmanSessionManager> createState() => _LogmanSessionManagerState();
}

class _LogmanSessionManagerState extends State<LogmanSessionManager> {
  Timer? _sessionTimer;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _startSessionMonitoring();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startSessionMonitoring() {
    _sessionTimer?.cancel();
    
    if (!widget.logman.requiresAuthentication) {
      return; // No need to monitor if auth is not required
    }

    _sessionTimer = Timer.periodic(widget.checkInterval, (timer) {
      _checkSessionStatus();
    });
  }

  void _checkSessionStatus() {
    if (!mounted) return;

    // Check if session has expired
    if (widget.logman.requiresAuthentication && !widget.logman.isAuthenticated) {
      _handleSessionExpired();
    }

    // Update lockout timer if needed
    if (widget.logman.isLockedOut) {
      _startLockoutTimer();
    }
  }

  void _handleSessionExpired() {
    // Just call the callback - no intrusive dialog needed
    // since the dashboard will auto-close and user can re-authenticate
    widget.onSessionExpired?.call();
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    
    final remainingTime = widget.logman.remainingLockoutTime;
    if (remainingTime > Duration.zero) {
      _lockoutTimer = Timer(remainingTime, () {
        if (mounted) {
          setState(() {}); // Refresh UI when lockout expires
        }
      });
    }
  }

  void _showSessionExpiredDialog() {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock_clock, color: Colors.orange),
              SizedBox(width: 8),
              Text('Session Expired'),
            ],
          ),
          content: const Text(
            'Your session has expired for security reasons. Please authenticate again to continue using Logman.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // The auth wrapper will handle re-authentication
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Session info widget that shows remaining session time
class LogmanSessionInfo extends StatefulWidget {
  final Logman logman;
  final TextStyle? textStyle;
  final bool showIcon;

  const LogmanSessionInfo({
    super.key,
    required this.logman,
    this.textStyle,
    this.showIcon = true,
  });

  @override
  State<LogmanSessionInfo> createState() => _LogmanSessionInfoState();
}

class _LogmanSessionInfoState extends State<LogmanSessionInfo> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.logman.requiresAuthentication || !widget.logman.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final session = widget.logman.currentSession;
    if (session == null) return const SizedBox.shrink();

    final remainingTime = session.remainingTime;
    final isExpiringSoon = remainingTime.inMinutes < 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isExpiringSoon 
            ? Colors.orange.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isExpiringSoon 
              ? Colors.orange.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIcon) ...[
            Icon(
              isExpiringSoon ? Icons.timer : Icons.security,
              size: 14,
              color: isExpiringSoon ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            'Session: ${_formatDuration(remainingTime)}',
            style: widget.textStyle ?? TextStyle(
              fontSize: 10,
              color: isExpiringSoon ? Colors.orange : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) {
      return 'Expired';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}