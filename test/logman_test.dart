import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logman/logman.dart';

void main() {
  group('Logman', () {
    test('Singleton instance returns the same object', () {
      final logman1 = Logman.instance;
      final logman2 = Logman.instance;
      expect(identical(logman1, logman2), isTrue);
    });

    test('recordSimpleLog', () {
      final logman = Logman.instance;
      logman.info('test');
      expect(logman.records.value.length, 1);
      expect(logman.records.value.first, isA<SimpleLogmanRecord>());
    });

    test('recordNavigation', () {
      final logman = Logman.instance;
      final record = NavigationLogmanRecord(
        route: MaterialPageRoute(builder: (context) => Container()),
        action: NavigationAction.push,
      );
      logman.navigation(record);
      expect(logman.records.value.isNotEmpty, true);
      expect(logman.records.value.last, isA<NavigationLogmanRecord>());
    });

    test('recordNetworkRequest', () {
      final logman = Logman.instance;
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

    test('recordNetworkResponse', () {
      final logman = Logman.instance;
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
  });
}
