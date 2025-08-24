import 'package:flutter/material.dart';

/// A simple PIN entry widget for Logman authentication
class LogmanPinEntry extends StatefulWidget {
  final String title;
  final String subtitle;
  final int pinLength;
  final void Function(String) onPinCompleted;
  final void Function()? onCancel;
  final bool obscureText;
  final Color? primaryColor;
  final String? errorMessage;
  final bool isLoading;
  final int attemptsRemaining;
  final Duration? lockoutTimeRemaining;

  const LogmanPinEntry({
    super.key,
    this.title = 'Enter PIN',
    this.subtitle = 'Enter your PIN to access Logman',
    this.pinLength = 4,
    required this.onPinCompleted,
    this.onCancel,
    this.obscureText = true,
    this.primaryColor,
    this.errorMessage,
    this.isLoading = false,
    this.attemptsRemaining = 0,
    this.lockoutTimeRemaining,
  });

  @override
  State<LogmanPinEntry> createState() => _LogmanPinEntryState();
}

class _LogmanPinEntryState extends State<LogmanPinEntry>
    with SingleTickerProviderStateMixin {
  late List<String> _pinDigits;
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _pinDigits = List.filled(widget.pinLength, '');
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (widget.isLoading || widget.lockoutTimeRemaining != null) return;

    final currentIndex = _pinDigits.indexWhere((digit) => digit.isEmpty);
    if (currentIndex != -1) {
      setState(() {
        _pinDigits[currentIndex] = number;
      });

      // Check if PIN is complete
      if (currentIndex == widget.pinLength - 1) {
        final pin = _pinDigits.join();
        widget.onPinCompleted(pin);
      }
    }
  }

  void _onBackspacePressed() {
    if (widget.isLoading || widget.lockoutTimeRemaining != null) return;

    final lastFilledIndex =
        _pinDigits.lastIndexWhere((digit) => digit.isNotEmpty);
    if (lastFilledIndex != -1) {
      setState(() {
        _pinDigits[lastFilledIndex] = '';
      });
    }
  }

  void _clearPin() {
    setState(() {
      _pinDigits = List.filled(widget.pinLength, '');
    });
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void didUpdateWidget(LogmanPinEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null &&
        oldWidget.errorMessage != widget.errorMessage) {
      _triggerShakeAnimation();
      _clearPin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter PIN'),
        centerTitle: true,
        leading: widget.onCancel != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancel,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Header icon and subtitle
            Icon(
              Icons.lock_outline,
              size: 48,
              color: primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              widget.subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Lockout message
            if (widget.lockoutTimeRemaining != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock_clock, color: Colors.red, size: 24),
                    const SizedBox(height: 8),
                    const Text(
                      'Account Locked',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Try again in ${widget.lockoutTimeRemaining!.inMinutes}m ${widget.lockoutTimeRemaining!.inSeconds % 60}s',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ] else ...[
              // PIN dots display
              SlideTransition(
                position: _shakeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.pinLength,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _pinDigits[index].isNotEmpty
                            ? primaryColor
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Error message
              if (widget.errorMessage != null) ...[
                Text(
                  widget.errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Attempts remaining
              if (widget.attemptsRemaining > 0) ...[
                Text(
                  '${widget.attemptsRemaining} attempts remaining',
                  style: TextStyle(
                    color: widget.attemptsRemaining <= 2
                        ? Colors.orange
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],

              // Number pad
              Expanded(
                child: _buildNumberPad(primaryColor),
              ),

              // Loading indicator
              if (widget.isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad(Color primaryColor) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        // Numbers 1-9
        ...List.generate(9, (index) {
          final number = (index + 1).toString();
          return _buildNumberButton(number);
        }),
        // Empty space
        const SizedBox(),
        // Zero
        _buildNumberButton('0'),
        // Backspace
        _buildBackspaceButton(),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onBackspacePressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 20,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
