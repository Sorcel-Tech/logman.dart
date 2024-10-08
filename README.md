# Logman

A simple yet powerful logging package for Flutter apps with an integrated UI and an optional debug page.

## Features

- Easy-to-use logging with a singleton pattern.
- Supports various log types: simple, navigation, and network logs.
- Customizable floating UI overlay to display logs in development.
- Optional debug page for detailed log analysis.
- Dio interceptor for network logging.
- Navigator observer for tracking navigation events.


## Screenshots

<img src="https://raw.githubusercontent.com/Sorcel-Tech/logman.dart/main/doc/screenshots/1.png" width="300"> <img src="https://raw.githubusercontent.com/Sorcel-Tech/logman.dart/main/doc/screenshots/2.png" width="300"> 
<img src="https://raw.githubusercontent.com/Sorcel-Tech/logman.dart/main/doc/screenshots/3.png" width="300"> <img src="https://raw.githubusercontent.com/Sorcel-Tech/logman.dart/main/doc/screenshots/4.png" width="300"> 


## Installation

1. Add Logman to your **pubspec.yaml** file:

```yaml
dependencies:
  logman: ^[latest_version]
```
Replace [latest_version] with the latest version of Logman.

2. Install it:

```dart
flutter packages get
```

3. Import it in your Dart code:

```dart
import 'package:logman/logman.dart';
```
## Usage
Initialize Logman in your app's root (after MaterialApp) and use its instance throughout your app.

1. Attach the Overlay:
    
```dart
@override
void initState() {
   super.initState();
   WidgetsBinding.instance.addPostFrameCallback((_) {
      logman.attachOverlay(
         context: context,
         debugPage: // Your optional debug page,
         button: // Your optional custom button,
         maxLogLifetime: // Set the maximum lifetime of a single log record,
         maxLogCount: // Set the maximum number of log records to keep,
      );
   });
}
```

You can also hide the overlay using the showOverlay property like so.
```dart
logman.attachOverlay(
    context: context,
    showOverlay: false,
);
```

This can be useful when you want to hide the overlay in production. Also you can also disable logs 
using the printLogs property like so.

```dart
logman.attachOverlay(
    context: context,
    printLogs: false,
    recordLogs: false,
);
```

2. Log events

There are 3 types of logs currently (simple , navigation, and network).

For logging simple (info) logs:

```dart
final Logman _logman = Logman.instance;

_logman.info('test');
```

There's a [Dio interceptor ready for use in the example app](https://github.com/Sorcel-Tech/logman.dart/blob/main/example/lib/logman_dio_interceptor.dart).
Also, Logman ships with a Navigator Observer. You can use it like this in your MaterialApp.

```dart
MaterialApp(
  title: 'Logman Demo',
  theme: ...,
  home: const MyHomePage(title: 'Logman Demo Home Page'),
  navigatorObservers: [
    LogmanNavigatorObserver(), // Navigator observer
  ],
)
```

## Example
Find a complete example [here](https://github.com/Sorcel-Tech/logman.dart/blob/main/example/lib/main.dart). 

## Contributing
We welcome contributions! Please read our contribution guidelines for more information.

**Find this useful? Give our repo a star :star: :arrow_up:.**

[![Stargazers repo roster for @Sorcel-Tech/logman.dart](https://reporoster.com/stars/Sorcel-Tech/logman.dart)](https://github.com/Sorcel-Tech/logman.dart/stargazers)

## License
Logman is released under the Apache 2.0 License.
