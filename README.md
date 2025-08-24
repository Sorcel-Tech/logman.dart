# Logman

A simple yet powerful logging package for Flutter apps with an integrated UI, advanced log levels, performance optimizations, and optional security features.

## Features

### Core Logging
- Easy-to-use logging with a singleton pattern
- **5 Log Levels**: `verbose`, `debug`, `info`, `warn`, `error` with priority-based filtering
- **Tagged Logging**: Organize logs with custom tags and metadata
- **Shorthand Methods**: `.v()`, `.d()`, `.i()`, `.w()`, `.e()` for quick logging
- Supports various log types: simple, navigation, and network logs

### Performance & UI
- **Lazy Loading**: Handle thousands of logs efficiently with pagination
- **Virtual Scrolling**: Optimized rendering for large log collections
- **Background Processing**: Batch log processing to prevent UI blocking
- **Memory Management**: Automatic cleanup with configurable thresholds
- **Enhanced UI**: Color-coded log levels with modern badges and icons
- Customizable floating UI overlay to display logs in development

### Security & Authentication
- **PIN/Password Protection**: Secure access to log data in production
- **Session Management**: Configurable timeouts and automatic logout
- **Brute-force Protection**: Failed attempt tracking with lockout periods
- **Encrypted Storage**: SHA-256 hashing with salt for credentials
- **Auto-logout**: Sessions expire when dashboard is closed

### Integration
- Optional debug page for detailed log analysis
- Dio interceptor for network logging
- Navigator observer for tracking navigation events
- Search and filter capabilities across all logs


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

### Security Configuration

Protect your log data with PIN or password authentication:

```dart
// PIN Protection
logman.attachOverlay(
    context: context,
    security: LogmanSecurity.withPin(
        '1234',
        sessionTimeout: Duration(minutes: 15),
        maxAttempts: 5,
        lockoutDuration: Duration(minutes: 10),
    ),
);

// Password Protection
logman.attachOverlay(
    context: context,
    security: LogmanSecurity.withPassword(
        'mySecurePassword',
        sessionTimeout: Duration(hours: 1),
    ),
);
```

### Performance Configuration

```dart
// Configure background processing and memory management
logman.configureBackgroundProcessing(
    enabled: true,
    batchSize: 100,
    batchInterval: Duration(milliseconds: 200),
    memoryThreshold: 50, // MB
);

// Set log retention policies
logman.attachOverlay(
    context: context,
    maxLogLifetime: Duration(hours: 24),
    maxLogCount: 10000,
);
```

2. **Log Events**

### Basic Logging
```dart
final Logman _logman = Logman.instance;

// Different log levels
_logman.verbose('Detailed debug information');
_logman.debug('Debug information');
_logman.info('General information');
_logman.warn('Warning message');
_logman.error('Error occurred');

// Shorthand methods
_logman.v('Verbose message');
_logman.d('Debug message');
_logman.i('Info message');
_logman.w('Warning message');
_logman.e('Error message');
```

### Tagged Logging
```dart
// Add tags and metadata for better organization
_logman.info('User logged in', tag: 'AUTH');
_logman.error('API call failed', 
  tag: 'NETWORK', 
  metadata: {'endpoint': '/api/users', 'statusCode': 500}
);
```

### Log Level Filtering
```dart
// Set minimum log level (ignores logs below this level)
_logman.minimumLogLevel = LogLevel.warn; // Only show warnings and errors

// Get current minimum log level
final currentLevel = _logman.minimumLogLevel;

// Get logs by level or tag
final warningLogs = _logman.getRecordsByLevel(LogLevel.warn);
final authLogs = _logman.getRecordsByTag('AUTH');
```

### Network & Navigation Logging

There's a [Dio interceptor ready for use in the example app](https://github.com/Sorcel-Tech/logman.dart/blob/main/example/lib/interceptors/logman_dio_interceptor.dart).

Logman ships with a Navigator Observer for automatic navigation tracking:

```dart
MaterialApp(
  title: 'Logman Demo',
  theme: ...,
  home: const MyHomePage(title: 'Logman Demo Home Page'),
  navigatorObservers: [
    LogmanNavigatorObserver(), // Automatic navigation logging
  ],
)
```

## API Reference

### Log Methods
- `verbose(String message, {String? tag, Map<String, dynamic>? metadata})`
- `debug(String message, {String? tag, Map<String, dynamic>? metadata})`
- `info(String message, {String? tag, Map<String, dynamic>? metadata})`
- `warn(String message, {String? tag, Map<String, dynamic>? metadata})`
- `error(Object error, {StackTrace? stackTrace, String? tag, Map<String, dynamic>? metadata})`

### Shorthand Methods
- `v()`, `d()`, `i()`, `w()`, `e()`

### Properties
- `minimumLogLevel` (getter/setter) - Get/set minimum log level
- `configureSecurity(LogmanSecurity security)`
- `configureBackgroundProcessing({...})`
- `getRecordsByLevel(LogLevel level)`
- `getRecordsByTag(String tag)`
- `getMemoryStats()`

### Security Methods
- `authenticate(String credential)`
- `logout()`
- `extendSession()`

## Performance Features

### Memory Management
- **Automatic cleanup** based on configurable thresholds
- **Background processing** to prevent UI blocking
- **Lazy loading** for large log collections
- **Virtual scrolling** for smooth UI performance

### Optimization Tips
```dart
// For high-traffic apps, configure aggressive cleanup
logman.attachOverlay(
    context: context,
    maxLogLifetime: Duration(minutes: 30),
    maxLogCount: 5000,
);

// Enable background processing for better performance
logman.configureBackgroundProcessing(
    enabled: true,
    batchSize: 50,
    memoryThreshold: 100, // MB
);
```

## Examples

- **Basic Setup**: [main.dart](https://github.com/Sorcel-Tech/logman.dart/blob/main/example/lib/main.dart)
- **Security Configuration**: [Secure logging example](https://github.com/Sorcel-Tech/logman.dart/blob/main/example/lib/home_page.dart)
- **Network Logging**: [Dio interceptor](https://github.com/Sorcel-Tech/logman.dart/blob/main/example/lib/interceptors/logman_dio_interceptor.dart)
- **Custom Debug Page**: [Debug page example](https://github.com/Sorcel-Tech/logman.dart/blob/main/example/lib/debug_page.dart) 

## Contributing
We welcome contributions! Please read our contribution guidelines for more information.

**Find this useful? Give our repo a star :star: :arrow_up:.**

[![Stargazers repo roster for @Sorcel-Tech/logman.dart](https://reporoster.com/stars/Sorcel-Tech/logman.dart)](https://github.com/Sorcel-Tech/logman.dart/stargazers)

## License
Logman is released under the Apache 2.0 License.
