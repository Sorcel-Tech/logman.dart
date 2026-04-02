import 'package:flutter_test/flutter_test.dart';
import 'package:logman/logman.dart';

void main() {
  group('SimpleLogmanRecord', () {
    test('convenience level getters are accurate', () {
      final verboseRecord = SimpleLogmanRecord(
        message: 'v',
        source: 'test',
        level: LogLevel.verbose,
      );
      expect(verboseRecord.isVerbose, isTrue);
      expect(verboseRecord.isDebug, isFalse);
      expect(verboseRecord.isInfo, isFalse);
      expect(verboseRecord.isWarn, isFalse);
      expect(verboseRecord.isError, isFalse);

      final errorRecord = SimpleLogmanRecord(
        message: 'e',
        source: 'test',
        level: LogLevel.error,
      );
      expect(errorRecord.isError, isTrue);
      expect(errorRecord.isVerbose, isFalse);
    });

    test('toString includes tag when present', () {
      final record = SimpleLogmanRecord(
        message: 'hello',
        source: 'test.dart',
        tag: 'AUTH',
      );

      final str = record.toString();
      expect(str, contains('tag: AUTH'));
    });

    test('toString excludes tag when null', () {
      final record = SimpleLogmanRecord(
        message: 'hello',
        source: 'test.dart',
      );

      final str = record.toString();
      expect(str, isNot(contains('tag:')));
    });

    test('toJson includes all fields', () {
      final record = SimpleLogmanRecord(
        message: 'test',
        source: 'src',
        level: LogLevel.warn,
        tag: 'DB',
        metadata: {'query': 'SELECT *'},
      );

      final json = record.toJson();
      expect(json['message'], 'test');
      expect(json['source'], 'src');
      expect(json['level'], 'WARN');
      expect(json['tag'], 'DB');
      expect(json['metadata'], {'query': 'SELECT *'});
    });

    test('toJson handles null tag and metadata', () {
      final record = SimpleLogmanRecord(
        message: 'test',
        source: 'src',
      );

      final json = record.toJson();
      expect(json['tag'], isNull);
      expect(json['metadata'], isNull);
    });

    test('default level is info', () {
      final record = SimpleLogmanRecord(
        message: 'test',
        source: 'src',
      );

      expect(record.level, LogLevel.info);
    });

    test('record type is simple', () {
      final record = SimpleLogmanRecord(
        message: 'test',
        source: 'src',
      );

      expect(record.type, LogmanRecordType.simple);
    });
  });
}
