import 'package:flutter_test/flutter_test.dart';
import 'package:logman/logman.dart';

void main() {
  group('LogLevel', () {
    test('shouldLog respects level hierarchy', () {
      expect(LogLevel.error.shouldLog(LogLevel.verbose), isTrue);
      expect(LogLevel.warn.shouldLog(LogLevel.warn), isTrue);
      expect(LogLevel.info.shouldLog(LogLevel.warn), isFalse);
      expect(LogLevel.debug.shouldLog(LogLevel.error), isFalse);
      expect(LogLevel.verbose.shouldLog(LogLevel.verbose), isTrue);
    });

    test('levels have correct ordering', () {
      expect(LogLevel.verbose.value, lessThan(LogLevel.debug.value));
      expect(LogLevel.debug.value, lessThan(LogLevel.info.value));
      expect(LogLevel.info.value, lessThan(LogLevel.warn.value));
      expect(LogLevel.warn.value, lessThan(LogLevel.error.value));
    });
  });
}
