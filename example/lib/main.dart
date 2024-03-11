import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

import 'home_page.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Logman.instance.info('App started!');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'Logman Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue.shade900,
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
          ),
          home: const MyHomePage(title: 'Logman Demo Home Page'),
          navigatorObservers: [
            LogmanNavigatorObserver(),
          ],
        );
      },
    );
  }
}
