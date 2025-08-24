import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

/// A wrapper widget that handles authentication for Logman access
class LogmanAuthWrapper extends StatefulWidget {
  final Logman logman;
  final Widget child;
  final Color? primaryColor;

  const LogmanAuthWrapper({
    super.key,
    required this.logman,
    required this.child,
    this.primaryColor,
  });

  @override
  State<LogmanAuthWrapper> createState() => _LogmanAuthWrapperState();
}

class _LogmanAuthWrapperState extends State<LogmanAuthWrapper> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    // If no authentication required or already authenticated, show child
    if (!widget.logman.requiresAuthentication || widget.logman.isAuthenticated) {
      return;
    }
  }

  Future<void> _handleAuthentication(String credential) async {
    if (widget.logman.isLockedOut) {
      setState(() {
        _errorMessage = 'Account is temporarily locked';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate network delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    final success = widget.logman.authenticate(credential);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Authentication successful - the widget will rebuild and show child
      setState(() {});
    } else {
      // Authentication failed
      final attemptsLeft = widget.logman.attemptsRemaining;
      if (widget.logman.isLockedOut) {
        setState(() {
          _errorMessage = 'Too many failed attempts. Account locked.';
        });
      } else if (attemptsLeft > 0) {
        setState(() {
          _errorMessage = 'Invalid ${_getCredentialTypeName()}. $attemptsLeft attempts remaining.';
        });
      } else {
        setState(() {
          _errorMessage = 'Invalid ${_getCredentialTypeName()}.';
        });
      }
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  String _getCredentialTypeName() {
    switch (widget.logman.authType) {
      case LogmanAuthType.pin:
        return 'PIN';
      case LogmanAuthType.password:
        return 'password';
      case LogmanAuthType.none:
        return 'credential';
    }
  }

  Widget _buildAuthenticationScreen() {
    switch (widget.logman.authType) {
      case LogmanAuthType.pin:
        return LogmanPinEntry(
          title: 'Secure Access',
          subtitle: 'Enter your PIN to access Logman dashboard',
          onPinCompleted: _handleAuthentication,
          onCancel: _handleCancel,
          primaryColor: widget.primaryColor,
          errorMessage: _errorMessage,
          isLoading: _isLoading,
          attemptsRemaining: widget.logman.attemptsRemaining,
          lockoutTimeRemaining: widget.logman.isLockedOut 
              ? widget.logman.remainingLockoutTime 
              : null,
        );
      case LogmanAuthType.password:
        return LogmanPasswordEntry(
          title: 'Secure Access',
          subtitle: 'Enter your password to access Logman dashboard',
          onPasswordSubmitted: _handleAuthentication,
          onCancel: _handleCancel,
          primaryColor: widget.primaryColor,
          errorMessage: _errorMessage,
          isLoading: _isLoading,
          attemptsRemaining: widget.logman.attemptsRemaining,
          lockoutTimeRemaining: widget.logman.isLockedOut 
              ? widget.logman.remainingLockoutTime 
              : null,
        );
      case LogmanAuthType.none:
        return widget.child;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no authentication required or user is authenticated, show the child
    if (!widget.logman.requiresAuthentication || widget.logman.isAuthenticated) {
      return widget.child;
    }

    // Show authentication screen
    return _buildAuthenticationScreen();
  }
}

/// A helper function to wrap any widget with authentication
Widget withLogmanAuth({
  required Logman logman,
  required Widget child,
  Color? primaryColor,
}) {
  return LogmanAuthWrapper(
    logman: logman,
    primaryColor: primaryColor,
    child: child,
  );
}