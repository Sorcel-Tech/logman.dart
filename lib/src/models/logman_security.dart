import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Enum for different authentication types
enum LogmanAuthType {
  none,
  pin,
  password,
}

/// Security configuration for Logman
class LogmanSecurity {
  final LogmanAuthType authType;
  final String? hashedCredential;
  final String? salt;
  final Duration sessionTimeout;
  final int maxAttempts;
  final Duration lockoutDuration;

  const LogmanSecurity({
    this.authType = LogmanAuthType.none,
    this.hashedCredential,
    this.salt,
    this.sessionTimeout = const Duration(minutes: 30),
    this.maxAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 15),
  });

  /// Creates a PIN-based security configuration
  factory LogmanSecurity.withPin(
    String pin, {
    Duration sessionTimeout = const Duration(minutes: 30),
    int maxAttempts = 5,
    Duration lockoutDuration = const Duration(minutes: 15),
  }) {
    final salt = _generateSalt();
    final hashedPin = _hashCredential(pin, salt);

    return LogmanSecurity(
      authType: LogmanAuthType.pin,
      hashedCredential: hashedPin,
      salt: salt,
      sessionTimeout: sessionTimeout,
      maxAttempts: maxAttempts,
      lockoutDuration: lockoutDuration,
    );
  }

  /// Creates a password-based security configuration
  factory LogmanSecurity.withPassword(
    String password, {
    Duration sessionTimeout = const Duration(minutes: 30),
    int maxAttempts = 5,
    Duration lockoutDuration = const Duration(minutes: 15),
  }) {
    final salt = _generateSalt();
    final hashedPassword = _hashCredential(password, salt);

    return LogmanSecurity(
      authType: LogmanAuthType.password,
      hashedCredential: hashedPassword,
      salt: salt,
      sessionTimeout: sessionTimeout,
      maxAttempts: maxAttempts,
      lockoutDuration: lockoutDuration,
    );
  }

  /// Verifies if the provided credential matches the stored one
  bool verifyCredential(String credential) {
    if (authType == LogmanAuthType.none) return true;
    if (hashedCredential == null || salt == null) return false;

    final hashedInput = _hashCredential(credential, salt!);
    return hashedInput == hashedCredential;
  }

  /// Checks if authentication is required
  bool get requiresAuth => authType != LogmanAuthType.none;

  /// Generates a random salt for hashing
  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Hashes a credential with salt using SHA-256
  static String _hashCredential(String credential, String salt) {
    final bytes = utf8.encode(credential + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Authentication session management
class LogmanAuthSession {
  final DateTime authenticatedAt;
  final Duration sessionTimeout;

  LogmanAuthSession({
    required this.sessionTimeout,
  }) : authenticatedAt = DateTime.now();

  /// Checks if the current session is still valid
  bool get isValid {
    final now = DateTime.now();
    return now.difference(authenticatedAt) < sessionTimeout;
  }

  /// Returns remaining session time
  Duration get remainingTime {
    final elapsed = DateTime.now().difference(authenticatedAt);
    final remaining = sessionTimeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// Authentication attempt tracking
class LogmanAuthAttempts {
  final int maxAttempts;
  final Duration lockoutDuration;
  int _attemptCount = 0;
  DateTime? _lockoutStartTime;

  LogmanAuthAttempts({
    required this.maxAttempts,
    required this.lockoutDuration,
  });

  /// Records a failed authentication attempt
  void recordFailedAttempt() {
    _attemptCount++;
    if (_attemptCount >= maxAttempts) {
      _lockoutStartTime = DateTime.now();
    }
  }

  /// Resets attempt count on successful authentication
  void reset() {
    _attemptCount = 0;
    _lockoutStartTime = null;
  }

  /// Checks if currently locked out
  bool get isLockedOut {
    if (_lockoutStartTime == null) return false;

    final now = DateTime.now();
    final lockoutElapsed = now.difference(_lockoutStartTime!);

    if (lockoutElapsed >= lockoutDuration) {
      // Lockout period has expired
      _lockoutStartTime = null;
      _attemptCount = 0;
      return false;
    }

    return true;
  }

  /// Returns remaining lockout time
  Duration get remainingLockoutTime {
    if (_lockoutStartTime == null) return Duration.zero;

    final elapsed = DateTime.now().difference(_lockoutStartTime!);
    final remaining = lockoutDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Returns current attempt count
  int get attemptCount => _attemptCount;

  /// Returns attempts remaining before lockout
  int get attemptsRemaining =>
      (maxAttempts - _attemptCount).clamp(0, maxAttempts);
}
