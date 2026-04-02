import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logman/logman.dart';

void main() {
  group('Logman', () {
    late Logman logman;

    setUp(() {
      logman = Logman.instance;
      logman.records.value = [];
      logman.enableBackgroundProcessing = false;
      logman.printLogs = false;
      logman.recordLogs = true;
      logman.minLogLevel = LogLevel.verbose;
      logman.removeSecurity();
    });

    tearDown(() {
      logman.stopTimer();
      logman.records.value = [];
      logman.maxLogCount = null;
      logman.maxLogLifetime = null;
      logman.enableBackgroundProcessing = false;
    });

    test('Singleton instance returns the same object', () {
      final logman1 = Logman.instance;
      final logman2 = Logman.instance;
      expect(identical(logman1, logman2), isTrue);
    });

    group('log levels', () {
      test('info() adds a record with LogLevel.info', () {
        logman.info('info message');
        expect(logman.records.value.length, 1);
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.message, 'info message');
        expect(record.level, LogLevel.info);
        expect(record.isInfo, isTrue);
      });

      test('error() adds a record with LogLevel.error', () {
        logman.error('something failed');
        expect(logman.records.value.length, 1);
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.message, 'something failed');
        expect(record.level, LogLevel.error);
        expect(record.isError, isTrue);
      });

      test('warn() adds a record with LogLevel.warn', () {
        logman.warn('be careful');
        expect(logman.records.value.length, 1);
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.message, 'be careful');
        expect(record.level, LogLevel.warn);
        expect(record.isWarn, isTrue);
      });

      test('debug() adds a record with LogLevel.debug', () {
        logman.debug('debug info');
        expect(logman.records.value.length, 1);
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.message, 'debug info');
        expect(record.level, LogLevel.debug);
        expect(record.isDebug, isTrue);
      });

      test('verbose() adds a record with LogLevel.verbose', () {
        logman.verbose('trace detail');
        expect(logman.records.value.length, 1);
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.message, 'trace detail');
        expect(record.level, LogLevel.verbose);
        expect(record.isVerbose, isTrue);
      });
    });

    group('shorthand methods', () {
      test('i() is equivalent to info()', () {
        logman.i('short info');
        expect(logman.records.value.length, 1);
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.message, 'short info');
        expect(record.level, LogLevel.info);
      });

      test('e() is equivalent to error()', () {
        logman.e('short error');
        expect(logman.records.value.length, 1);
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.level, LogLevel.error);
      });

      test('w() is equivalent to warn()', () {
        logman.w('short warn');
        expect(logman.records.value.length, 1);
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.level, LogLevel.warn);
      });

      test('d() is equivalent to debug()', () {
        logman.d('short debug');
        expect(logman.records.value.length, 1);
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.level, LogLevel.debug);
      });

      test('v() is equivalent to verbose()', () {
        logman.v('short verbose');
        expect(logman.records.value.length, 1);
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.level, LogLevel.verbose);
      });
    });

    group('tagged logging', () {
      test('info() stores tag when provided', () {
        logman.info('tagged message', tag: 'AUTH');
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.tag, 'AUTH');
      });

      test('info() stores metadata when provided', () {
        logman.info(
          'with metadata',
          metadata: {'key': 'value', 'count': 42},
        );
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.metadata, isNotNull);
        expect(record.metadata!['key'], 'value');
        expect(record.metadata!['count'], 42);
      });

      test('tag and metadata are null when not provided', () {
        logman.info('plain message');
        final record = logman.records.value.first as SimpleLogmanRecord;
        expect(record.tag, isNull);
        expect(record.metadata, isNull);
      });

      test('getRecordsByTag returns only matching records', () {
        logman.info('auth log', tag: 'AUTH');
        logman.info('network log', tag: 'NETWORK');
        logman.info('another auth log', tag: 'AUTH');
        logman.info('untagged log');

        final authRecords = logman.getRecordsByTag('AUTH');
        expect(authRecords.length, 2);
      });

      test('getAllTags returns sorted unique tags', () {
        logman.info('a', tag: 'NETWORK');
        logman.info('b', tag: 'AUTH');
        logman.info('c', tag: 'NETWORK');
        logman.info('d', tag: 'DB');

        final tags = logman.getAllTags();
        expect(tags, ['AUTH', 'DB', 'NETWORK']);
      });
    });

    group('minimum log level', () {
      test('logs below minimumLogLevel are not recorded', () {
        logman.minimumLogLevel = LogLevel.warn;

        logman.verbose('should be ignored');
        logman.debug('should be ignored');
        logman.info('should be ignored');
        logman.warn('should be recorded');
        logman.error('should be recorded');

        expect(logman.records.value.length, 2);
      });

      test('minimumLogLevel getter returns the current level', () {
        logman.minimumLogLevel = LogLevel.error;
        expect(logman.minimumLogLevel, LogLevel.error);
      });

      test('getRecordsByLevel filters correctly', () {
        logman.verbose('v');
        logman.debug('d');
        logman.info('i');
        logman.warn('w');
        logman.error('e');

        final warnAndAbove = logman.getRecordsByLevel(LogLevel.warn);
        expect(warnAndAbove.length, 2);
      });
    });

    group('recordLogs', () {
      test('when false, no logs are recorded', () {
        logman.recordLogs = false;
        logman.info('should not be recorded');
        expect(logman.records.value.length, 0);
      });

      test('when true, logs are recorded', () {
        logman.recordLogs = true;
        logman.info('should be recorded');
        expect(logman.records.value.length, 1);
      });
    });

    group('navigation logging', () {
      test('adds navigation log', () {
        final record = NavigationLogmanRecord(
          route: MaterialPageRoute(
            builder: (context) => Container(),
            settings: const RouteSettings(name: '/home'),
          ),
          action: NavigationAction.push,
        );
        logman.navigation(record);
        expect(logman.records.value.length, 1);
        expect(logman.records.value.last, isA<NavigationLogmanRecord>());
      });

      test('ignores logman routes', () {
        final record = NavigationLogmanRecord(
          route: MaterialPageRoute(
            builder: (context) => Container(),
            settings: const RouteSettings(name: '/logman-dashboard'),
          ),
          action: NavigationAction.push,
        );
        logman.navigation(record);
        expect(logman.records.value.length, 0);
      });
    });

    group('network logging', () {
      test('adds network request log', () {
        const record = NetworkRequestLogmanRecord(
          url: 'https://example.com',
          method: 'GET',
          headers: {'Content-Type': 'application/json'},
          id: '1234567890',
        );
        logman.networkRequest(record);
        expect(logman.records.value.length, 1);
        expect(logman.records.value.last, isA<NetworkLogmanRecord>());
      });

      test('pairs response with matching request by id', () {
        const requestRecord = NetworkRequestLogmanRecord(
          url: 'https://example.com',
          method: 'GET',
          id: 'req-1',
        );
        logman.networkRequest(requestRecord);

        final responseRecord = NetworkResponseLogmanRecord(
          id: 'req-1',
          statusCode: 200,
          headers: {'Content-Type': 'application/json'},
          body: '{"ok": true}',
          url: 'https://example.com',
        );
        logman.networkResponse(responseRecord);

        expect(logman.records.value.length, 1);
        final netRecord = logman.records.value.first as NetworkLogmanRecord;
        expect(netRecord.response, isNotNull);
        expect(netRecord.response!.statusCode, 200);
      });

      test('ignores response with no matching request', () {
        final responseRecord = NetworkResponseLogmanRecord(
          id: 'non-existent',
          statusCode: 404,
          url: 'https://example.com',
        );
        logman.networkResponse(responseRecord);
        expect(logman.records.value.length, 0);
      });

      test('network request works without optional fields', () {
        const record = NetworkRequestLogmanRecord(
          url: 'https://example.com',
          method: 'GET',
          id: 'minimal-req',
        );
        logman.networkRequest(record);
        expect(logman.records.value.length, 1);

        final netRecord = logman.records.value.first as NetworkLogmanRecord;
        expect(netRecord.request.headers, isNull);
        expect(netRecord.request.body, isNull);
        expect(netRecord.request.sentAt, isNull);
      });

      test('network response works without optional fields', () {
        const requestRecord = NetworkRequestLogmanRecord(
          url: 'https://example.com',
          method: 'GET',
          id: 'req-opt',
        );
        logman.networkRequest(requestRecord);

        final responseRecord = NetworkResponseLogmanRecord(
          id: 'req-opt',
          url: 'https://example.com',
        );
        logman.networkResponse(responseRecord);

        final netRecord = logman.records.value.first as NetworkLogmanRecord;
        expect(netRecord.response!.statusCode, isNull);
        expect(netRecord.response!.headers, isNull);
        expect(netRecord.response!.body, isNull);
      });
    });

    group('log rotation', () {
      test('respects maxLogCount', () {
        const int maxLogs = 5;
        logman.maxLogCount = maxLogs;

        for (int i = 0; i < maxLogs + 3; i++) {
          logman.info('Log #$i');
        }

        expect(logman.records.value.length, maxLogs);
        final lastMessage =
            (logman.records.value.last as SimpleLogmanRecord).message;
        expect(lastMessage, 'Log #${maxLogs + 3 - 1}');
      });

      test('removes old logs based on maxLogLifetime', () async {
        logman.maxLogLifetime = const Duration(seconds: 2);
        logman.info('Old Log');

        await Future<dynamic>.delayed(const Duration(seconds: 3));

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
        await Future<dynamic>.delayed(const Duration(seconds: 2));

        logman.info('Log 3');
        await Future<dynamic>.delayed(const Duration(seconds: 2));

        expect(logman.records.value.length, 1);
        expect(
          (logman.records.value.first as SimpleLogmanRecord).message,
          'Log 3',
        );
      });
    });

    group('background batch processing', () {
      test('queued logs are flushed with flushLogQueue()', () {
        logman.enableBackgroundProcessing = true;

        logman.info('queued log 1');
        logman.info('queued log 2');
        logman.info('queued log 3');

        logman.flushLogQueue();

        expect(logman.records.value.length, 3);
      });

      test('configureBackgroundProcessing updates settings', () {
        logman.configureBackgroundProcessing(
          enabled: true,
          batchSize: 10,
          memoryThreshold: 25,
        );
        expect(logman.enableBackgroundProcessing, isTrue);
        expect(logman.maxBatchSize, 10);
        expect(logman.memoryThresholdMB, 25);
      });

      test('getMemoryStats returns valid data', () {
        logman.info('a');
        logman.info('b');

        final stats = logman.getMemoryStats();
        expect(stats['recordCount'], 2);
        expect(stats['estimatedMemoryKB'], isA<double>());
        expect(stats.containsKey('backgroundProcessingEnabled'), isTrue);
      });
    });

    group('security', () {
      test('no security by default', () {
        expect(logman.requiresAuthentication, isFalse);
        expect(logman.isAuthenticated, isTrue);
        expect(logman.authType, LogmanAuthType.none);
      });

      test('configureSecurity with PIN sets up auth requirement', () {
        logman.configureSecurity(LogmanSecurity.withPin('1234'));

        expect(logman.requiresAuthentication, isTrue);
        expect(logman.isAuthenticated, isFalse);
        expect(logman.authType, LogmanAuthType.pin);
      });

      test('configureSecurity with password sets up auth requirement', () {
        logman.configureSecurity(LogmanSecurity.withPassword('secret'));

        expect(logman.requiresAuthentication, isTrue);
        expect(logman.isAuthenticated, isFalse);
        expect(logman.authType, LogmanAuthType.password);
      });

      test('authenticate with correct PIN succeeds', () {
        logman.configureSecurity(LogmanSecurity.withPin('9999'));

        final result = logman.authenticate('9999');
        expect(result, isTrue);
        expect(logman.isAuthenticated, isTrue);
      });

      test('authenticate with wrong PIN fails', () {
        logman.configureSecurity(LogmanSecurity.withPin('9999'));

        final result = logman.authenticate('0000');
        expect(result, isFalse);
        expect(logman.isAuthenticated, isFalse);
      });

      test('authenticate with correct password succeeds', () {
        logman.configureSecurity(LogmanSecurity.withPassword('myPassword'));

        final result = logman.authenticate('myPassword');
        expect(result, isTrue);
        expect(logman.isAuthenticated, isTrue);
      });

      test('authenticate with wrong password fails', () {
        logman.configureSecurity(LogmanSecurity.withPassword('myPassword'));

        final result = logman.authenticate('wrongPassword');
        expect(result, isFalse);
        expect(logman.isAuthenticated, isFalse);
      });

      test('logout invalidates the session', () {
        logman.configureSecurity(LogmanSecurity.withPin('1234'));
        logman.authenticate('1234');
        expect(logman.isAuthenticated, isTrue);

        logman.logout();
        expect(logman.isAuthenticated, isFalse);
      });

      test('removeSecurity clears all auth state', () {
        logman.configureSecurity(LogmanSecurity.withPin('1234'));
        logman.authenticate('1234');

        logman.removeSecurity();
        expect(logman.requiresAuthentication, isFalse);
        expect(logman.isAuthenticated, isTrue);
        expect(logman.authType, LogmanAuthType.none);
      });

      test('lockout after max failed attempts', () {
        logman.configureSecurity(
          LogmanSecurity.withPin(
            '1234',
            maxAttempts: 3,
            lockoutDuration: const Duration(minutes: 5),
          ),
        );

        logman.authenticate('0000');
        logman.authenticate('0000');
        logman.authenticate('0000');

        expect(logman.isLockedOut, isTrue);
        expect(logman.attemptsRemaining, 0);
        expect(logman.remainingLockoutTime, isNot(Duration.zero));
      });

      test('correct PIN is rejected during lockout', () {
        logman.configureSecurity(
          LogmanSecurity.withPin('1234', maxAttempts: 2),
        );

        logman.authenticate('0000');
        logman.authenticate('0000');
        expect(logman.isLockedOut, isTrue);

        final result = logman.authenticate('1234');
        expect(result, isFalse);
      });

      test('extendSession creates a new session', () {
        logman.configureSecurity(LogmanSecurity.withPin('1234'));
        logman.authenticate('1234');

        final sessionBefore = logman.currentSession;
        expect(sessionBefore, isNotNull);

        logman.extendSession();
        final sessionAfter = logman.currentSession;

        expect(sessionAfter, isNotNull);
        expect(identical(sessionBefore, sessionAfter), isFalse);
      });

      test('attemptsRemaining decreases with each failure', () {
        logman.configureSecurity(
          LogmanSecurity.withPin('1234'),
        );

        expect(logman.attemptsRemaining, 5);
        logman.authenticate('0000');
        expect(logman.attemptsRemaining, 4);
        logman.authenticate('0000');
        expect(logman.attemptsRemaining, 3);
      });
    });
  });
}
