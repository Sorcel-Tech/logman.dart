import 'package:flutter_test/flutter_test.dart';
import 'package:logman/logman.dart';

void main() {
  group('NetworkLogmanRecord', () {
    test('toString uses correct class name', () {
      final record = NetworkLogmanRecord(
        request: const NetworkRequestLogmanRecord(
          id: '1',
          url: 'https://example.com',
          method: 'GET',
        ),
      );

      final str = record.toString();
      expect(str, startsWith('NetworkLogmanRecord('));
      expect(str, isNot(startsWith('NetworkRequestLogmanRecord(')));
    });

    test('toJson includes request and null response', () {
      final record = NetworkLogmanRecord(
        request: const NetworkRequestLogmanRecord(
          id: '1',
          url: 'https://example.com',
          method: 'POST',
          body: 'hello',
        ),
      );

      final json = record.toJson();
      expect(json['request'], isA<Map>());
      expect(json['request']['url'], 'https://example.com');
      expect(json['request']['method'], 'POST');
      expect(json['response'], isNull);
    });

    test('id delegates to request id', () {
      final record = NetworkLogmanRecord(
        request: const NetworkRequestLogmanRecord(
          id: 'abc-123',
          url: 'https://example.com',
          method: 'GET',
        ),
      );

      expect(record.id, 'abc-123');
    });
  });

  group('NetworkRequestLogmanRecord', () {
    test('can be created with only required fields', () {
      const record = NetworkRequestLogmanRecord(
        id: 'req-1',
        url: 'https://api.test.com',
        method: 'DELETE',
      );

      expect(record.headers, isNull);
      expect(record.body, isNull);
      expect(record.sentAt, isNull);
      expect(record.dateFormatted, '');
    });

    test('can be created with all fields', () {
      final now = DateTime.now();
      final record = NetworkRequestLogmanRecord(
        id: 'req-2',
        url: 'https://api.test.com/users',
        method: 'POST',
        headers: {'Authorization': 'Bearer token'},
        body: '{"name": "test"}',
        sentAt: now,
      );

      expect(record.headers, isNotNull);
      expect(record.body, '{"name": "test"}');
      expect(record.sentAt, now);
      expect(record.dateFormatted, isNotEmpty);
    });

    test('toJson serializes all fields', () {
      final now = DateTime.now();
      final record = NetworkRequestLogmanRecord(
        id: 'req-3',
        url: 'https://api.test.com',
        method: 'PUT',
        headers: {'Accept': 'application/json'},
        body: 'data',
        sentAt: now,
      );

      final json = record.toJson();
      expect(json['id'], 'req-3');
      expect(json['url'], 'https://api.test.com');
      expect(json['method'], 'PUT');
      expect(json['headers'], {'Accept': 'application/json'});
      expect(json['body'], 'data');
      expect(json['sentAt'], now.toIso8601String());
    });
  });

  group('NetworkResponseLogmanRecord', () {
    test('can be created with only required fields', () {
      final record = NetworkResponseLogmanRecord(
        id: 'res-1',
        url: 'https://api.test.com',
      );

      expect(record.statusCode, isNull);
      expect(record.headers, isNull);
      expect(record.body, isNull);
      expect(record.receivedAt, isNull);
      expect(record.dateFormatted, '');
    });

    test('can be created with all fields', () {
      final now = DateTime.now();
      final record = NetworkResponseLogmanRecord(
        id: 'res-2',
        url: 'https://api.test.com/users',
        statusCode: 201,
        headers: {'Content-Type': 'application/json'},
        body: '{"id": 1}',
        receivedAt: now,
      );

      expect(record.statusCode, 201);
      expect(record.headers, isNotNull);
      expect(record.body, '{"id": 1}');
      expect(record.receivedAt, now);
      expect(record.dateFormatted, isNotEmpty);
    });

    test('toJson serializes all fields', () {
      final now = DateTime.now();
      final record = NetworkResponseLogmanRecord(
        id: 'res-3',
        url: 'https://api.test.com',
        statusCode: 404,
        headers: {'X-Error': 'not found'},
        body: 'Not Found',
        receivedAt: now,
      );

      final json = record.toJson();
      expect(json['id'], 'res-3');
      expect(json['statusCode'], 404);
      expect(json['headers'], {'X-Error': 'not found'});
      expect(json['body'], 'Not Found');
      expect(json['receivedAt'], now.toIso8601String());
      expect(json['url'], 'https://api.test.com');
    });
  });
}
