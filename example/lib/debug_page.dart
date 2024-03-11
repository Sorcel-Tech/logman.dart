import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

// This is just a sample of what a debug page could look like.
// You can use this as a starting point to build your own debug page.
//
// Only the theme switch is functional in this sample.
class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('Reset app'),
            onTap: () {},
          ),
          ValueListenableBuilder(
            valueListenable: isDarkModeNotifier,
            builder: (context, isDarkMode, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: isDarkMode,
                onChanged: (value) {
                  isDarkModeNotifier.value = value;
                  Logman.instance.info(
                    'Dark mode is now ${value ? 'enabled' : 'disabled'}',
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Force Crash app'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Log out'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
