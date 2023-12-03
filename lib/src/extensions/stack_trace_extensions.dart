extension StackTraceExtensions on StackTrace {
  String get traceSource {
    return extractSourceFromLine(1);
  }

  String extractSourceFromLine(int lineNumber) {
    final lines = toString().split('\n');

    if (lineNumber < lines.length) {
      final line = lines[lineNumber];
      final parts = line.split('(');
      if (parts.isNotEmpty) {
        final lineString = parts.first.trim();
        final source =
            lineString.split('#$lineNumber').last.split('.<').first.trim();

        return source;
      }
    }

    return 'Unavailable';
  }
}
