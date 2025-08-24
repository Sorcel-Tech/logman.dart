import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A password entry widget for Logman authentication
class LogmanPasswordEntry extends StatefulWidget {
  final String title;
  final String subtitle;
  final Function(String) onPasswordSubmitted;
  final Function()? onCancel;
  final Color? primaryColor;
  final String? errorMessage;
  final bool isLoading;
  final int attemptsRemaining;
  final Duration? lockoutTimeRemaining;

  const LogmanPasswordEntry({
    super.key,
    this.title = 'Enter Password',
    this.subtitle = 'Enter your password to access Logman',
    required this.onPasswordSubmitted,
    this.onCancel,
    this.primaryColor,
    this.errorMessage,
    this.isLoading = false,
    this.attemptsRemaining = 0,
    this.lockoutTimeRemaining,
  });

  @override
  State<LogmanPasswordEntry> createState() => _LogmanPasswordEntryState();
}

class _LogmanPasswordEntryState extends State<LogmanPasswordEntry>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    // Auto-focus password field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.lockoutTimeRemaining == null) {
        _passwordFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _submitPassword() {
    if (widget.isLoading || widget.lockoutTimeRemaining != null) return;
    
    final password = _passwordController.text.trim();
    if (password.isNotEmpty) {
      widget.onPasswordSubmitted(password);
    }
  }

  void _clearPassword() {
    _passwordController.clear();
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void didUpdateWidget(LogmanPasswordEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null && oldWidget.errorMessage != widget.errorMessage) {
      _triggerShakeAnimation();
      _clearPassword();
      if (widget.lockoutTimeRemaining == null) {
        _passwordFocusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Icon(
                Icons.security,
                size: 48,
                color: primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Lockout message
              if (widget.lockoutTimeRemaining != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.lock_clock, color: Colors.red, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        'Account Locked',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Too many failed attempts. Please try again in:',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.lockoutTimeRemaining!.inMinutes}m ${widget.lockoutTimeRemaining!.inSeconds % 60}s',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Password input
                SlideTransition(
                  position: _shakeAnimation,
                  child: TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: _obscurePassword,
                    enabled: !widget.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _submitPassword(),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                ),
                const SizedBox(height: 16),

                // Error message
                if (widget.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Attempts remaining
                if (widget.attemptsRemaining > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: widget.attemptsRemaining <= 2 
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.attemptsRemaining <= 2 
                            ? Colors.orange.withOpacity(0.3)
                            : Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: widget.attemptsRemaining <= 2 ? Colors.orange : Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Attempts remaining: ${widget.attemptsRemaining}',
                          style: TextStyle(
                            color: widget.attemptsRemaining <= 2 ? Colors.orange : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Submit button
                ElevatedButton(
                  onPressed: widget.isLoading ? null : _submitPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Unlock',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],

              const SizedBox(height: 16),

              // Cancel button
              if (widget.onCancel != null)
                TextButton(
                  onPressed: widget.isLoading || widget.lockoutTimeRemaining != null
                      ? null
                      : widget.onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),

              // Additional security info
              const SizedBox(height: 16),
              Text(
                'This screen protects access to sensitive log data',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}