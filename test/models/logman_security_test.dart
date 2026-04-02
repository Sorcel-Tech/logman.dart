import 'package:flutter_test/flutter_test.dart';
import 'package:logman/logman.dart';

void main() {
  group('LogmanSecurity', () {
    test('withPin verifies correct PIN', () {
      final security = LogmanSecurity.withPin('4567');
      expect(security.verifyCredential('4567'), isTrue);
      expect(security.verifyCredential('0000'), isFalse);
    });

    test('withPassword verifies correct password', () {
      final security = LogmanSecurity.withPassword('s3cret!');
      expect(security.verifyCredential('s3cret!'), isTrue);
      expect(security.verifyCredential('wrong'), isFalse);
    });

    test('none auth type always verifies', () {
      const security = LogmanSecurity();
      expect(security.requiresAuth, isFalse);
      expect(security.verifyCredential('anything'), isTrue);
    });

    test('default configuration values', () {
      final security = LogmanSecurity.withPin('1234');
      expect(security.sessionTimeout, const Duration(minutes: 30));
      expect(security.maxAttempts, 5);
      expect(security.lockoutDuration, const Duration(minutes: 15));
    });

    test('custom configuration values', () {
      final security = LogmanSecurity.withPin(
        '1234',
        sessionTimeout: const Duration(hours: 2),
        maxAttempts: 10,
        lockoutDuration: const Duration(minutes: 30),
      );
      expect(security.sessionTimeout, const Duration(hours: 2));
      expect(security.maxAttempts, 10);
      expect(security.lockoutDuration, const Duration(minutes: 30));
    });
  });

  group('LogmanAuthSession', () {
    test('new session is valid', () {
      final session = LogmanAuthSession(
        sessionTimeout: const Duration(minutes: 30),
      );
      expect(session.isValid, isTrue);
      expect(session.remainingTime.inMinutes, greaterThan(0));
    });

    test('expired session is not valid', () {
      final session = LogmanAuthSession(
        sessionTimeout: Duration.zero,
      );
      expect(session.isValid, isFalse);
      expect(session.remainingTime, Duration.zero);
    });
  });

  group('LogmanAuthAttempts', () {
    test('locks out after max attempts', () {
      final attempts = LogmanAuthAttempts(
        maxAttempts: 3,
        lockoutDuration: const Duration(minutes: 5),
      );

      attempts.recordFailedAttempt();
      attempts.recordFailedAttempt();
      expect(attempts.isLockedOut, isFalse);

      attempts.recordFailedAttempt();
      expect(attempts.isLockedOut, isTrue);
      expect(attempts.attemptsRemaining, 0);
    });

    test('reset clears attempt count and lockout', () {
      final attempts = LogmanAuthAttempts(
        maxAttempts: 2,
        lockoutDuration: const Duration(minutes: 5),
      );

      attempts.recordFailedAttempt();
      attempts.recordFailedAttempt();
      expect(attempts.isLockedOut, isTrue);

      attempts.reset();
      expect(attempts.isLockedOut, isFalse);
      expect(attempts.attemptCount, 0);
      expect(attempts.attemptsRemaining, 2);
    });

    test('remainingLockoutTime is zero when not locked out', () {
      final attempts = LogmanAuthAttempts(
        maxAttempts: 5,
        lockoutDuration: const Duration(minutes: 5),
      );
      expect(attempts.remainingLockoutTime, Duration.zero);
    });
  });
}
