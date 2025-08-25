# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Security parameter to `openDashboard()` function for consistent authentication support

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