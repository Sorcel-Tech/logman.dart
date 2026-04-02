# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-02

### Added
- Security parameter to `openDashboard()` for consistent authentication support
- `reverse` parameter to `LazyLogList` for displaying items newest-first
- `maxLoadedRecords` parameter to `LazyLogList` for configurable memory limits
- Comprehensive test suite covering core logging, security, models, and batch processing

### Fixed
- Operator precedence bug in network error status code detection
- Static overlay entry overwrite causing orphaned overlays on double-attach
- Null safety crash in `durationInMs` and `sizeInBytes` record extensions
- Force-unwrap crash in `LogmanNavigatorObserver.didReplace()` when route is null
- `NavigationLogmanRecord.toString()` printing raw object references instead of route names
- `NetworkLogmanRecord.toString()` using wrong class name
- Password not cleared from memory after authentication submission
- Auto-logout on dashboard dispose causing unnecessary re-authentication
- Missing `mounted` checks in `LogmanAuthWrapper` causing setState-after-dispose errors
- Duplicate search computation in `RecordSearchDelegate`
- Unbounded memory growth in `LazyLogList` loaded records
- Dio interceptor: cache memory leak, null data crash, and unreliable request ID generation

### Changed
- `headers`, `statusCode`, and `body` on network record constructors are now optional instead of `required` to match their nullable types
- Log lists now use `ListView(reverse: true)` instead of `.reversed.toList()` for better performance
- `LazyLogList` uses granular append-based updates instead of full resets when new records arrive
- CI workflow runs `flutter pub get` before `dart fix` and `dart format` for consistent results
- Tests split into focused files mirroring the source structure

## [0.1.0] - 2024-08-24

### Added
- **5 Log Levels**: `verbose`, `debug`, `info`, `warn`, `error` with filtering and shorthand methods (`.v()`, `.d()`, `.i()`, `.w()`, `.e()`)
- **Security Lock**: PIN/password protection with session management and auto-logout
- **Performance**: Lazy loading, virtual scrolling, and background processing for large log collections
- **Tagged Logging**: Organize logs with custom tags and metadata
- **Enhanced UI**: Color-coded levels, modern badges, and improved PIN entry design

### Changed
- `setMinLogLevel()` → `minimumLogLevel` property
- `isError`/`isWarning` → `LogLevel` system (old properties still work via getters)

### Dependencies
- Added `crypto: ^3.0.3` for secure credential hashing

## [0.0.2] - Earlier Release

Cleanup from initial release

## [0.0.1] - Initial Release

Initial release