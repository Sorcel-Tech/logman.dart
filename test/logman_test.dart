import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logman/logman.dart';

void main() {
  group('Logman', () {
    late Logman logman;

    setUp(() {
      logman = Logman.instance;
      logman.records.value = [];
    });

    tearDown(() {
      logman.stopTimer(); // Stop the timer after each test
      logman.records.value = [];
      logman.maxLogCount = 100;
      logman.maxLogLifetime = const Duration(minutes: 10);
    });

    test('Singleton instance returns the same object', () {
      final logman1 = Logman.instance;
      final logman2 = Logman.instance;
      expect(identical(logman1, logman2), isTrue);
    });

    test('adds info log', () {
      logman.info('test');
      expect(logman.records.value.length, 1);
      expect(logman.records.value.first, isA<SimpleLogmanRecord>());
    });

    test('adds navigation log', () {
      final record = NavigationLogmanRecord(
        route: MaterialPageRoute(builder: (context) => Container()),
        action: NavigationAction.push,
      );
      logman.navigation(record);
      expect(logman.records.value.isNotEmpty, true);
      expect(logman.records.value.last, isA<NavigationLogmanRecord>());
    });

    test('adds network request log', () {
      const record = NetworkRequestLogmanRecord(
        url: 'https://example.com',
        method: 'GET',
        headers: {'Content-Type': 'application/json'},
        body: {'name': 'John Doe'},
        id: '1234567890',
      );
      logman.networkRequest(record);
      expect(logman.records.value.isNotEmpty, true);
      expect(logman.records.value.last, isA<NetworkLogmanRecord>());
    });

    test('adds network response log', () {
      const requestRecord = NetworkRequestLogmanRecord(
        url: 'https://example.com',
        method: 'GET',
        headers: {'Content-Type': 'application/json'},
        body: {'name': 'John Doe'},
        id: '1234567890',
      );
      logman.networkRequest(requestRecord);

      final record = NetworkResponseLogmanRecord(
        id: '1234567890',
        statusCode: 200,
        headers: {'Content-Type': 'application/json'},
        body: {'name': 'John Doe'}.toString(),
      );
      logman.networkResponse(record);
      expect(logman.records.value.isNotEmpty, true);
      expect(logman.records.value.last, isA<NetworkLogmanRecord>());
    });

    test('respects maxLogCount', () {
      const int maxLogs = 5;
      logman.maxLogCount = maxLogs;

      for (int i = 0; i < maxLogs + 2; i++) {
        logman.info('Log #$i');
      }

      expect(logman.records.value.length, maxLogs);
    });

    test('removes old logs based on maxLogLifetime', () async {
      logman.maxLogLifetime = const Duration(seconds: 2);
      logman.info('Old Log');

      // advance time by 3 seconds to remove the old log
      await Future.delayed(const Duration(seconds: 3), () {});

      logman.info('New Log');
      expect(logman.records.value.length, 1);
      expect(
        (logman.records.value.first as SimpleLogmanRecord).message,
        'New Log',
      );
    });

    test('rotates logs based on timer', () async {
      logman.maxLogLifetime = const Duration(seconds: 2);

      logman.info('Log 1');
      logman.info('Log 2');
      await Future.delayed(const Duration(seconds: 2), () {});

      logman.info('Log 3');
      await Future.delayed(const Duration(seconds: 2), () {});

      // After two rotation intervals, only 'Log 3' should remain
      // because others are too old
      expect(logman.records.value.length, 1);
      expect(
        (logman.records.value.first as SimpleLogmanRecord).message,
        'Log 3',
      );
    });
  });
}
