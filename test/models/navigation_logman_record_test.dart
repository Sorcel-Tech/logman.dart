import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logman/logman.dart';

void main() {
  group('NavigationLogmanRecord', () {
    test('toString uses route names not object references', () {
      final record = NavigationLogmanRecord(
        route: MaterialPageRoute(
          builder: (_) => Container(),
          settings: const RouteSettings(name: '/home'),
        ),
        action: NavigationAction.push,
        previousRoute: MaterialPageRoute(
          builder: (_) => Container(),
          settings: const RouteSettings(name: '/splash'),
        ),
      );

      final str = record.toString();
      expect(str, contains('/home'));
      expect(str, contains('/splash'));
      expect(str, isNot(contains('Instance of')));
    });

    test('routeName defaults to Unknown route when name is null', () {
      final record = NavigationLogmanRecord(
        route: MaterialPageRoute(builder: (_) => Container()),
        action: NavigationAction.pop,
      );

      expect(record.routeName, 'Unknown route');
      expect(record.previousRouteName, 'Unknown previous route');
    });

    test('parameters includes name and arguments when present', () {
      final record = NavigationLogmanRecord(
        route: MaterialPageRoute(
          builder: (_) => Container(),
          settings: const RouteSettings(
            name: '/detail',
            arguments: {'id': 42},
          ),
        ),
        action: NavigationAction.push,
      );

      expect(record.parameters['name'], '/detail');
      expect(record.parameters['arguments'], {'id': 42});
    });

    test('parameters is empty when no name or arguments', () {
      final record = NavigationLogmanRecord(
        route: MaterialPageRoute(builder: (_) => Container()),
        action: NavigationAction.push,
      );

      expect(record.parameters, isEmpty);
    });
  });
}
