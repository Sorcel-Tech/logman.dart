import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logman/logman.dart';

extension StringExtensions on String {
  void copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: this));
    HapticFeedback.lightImpact();
    context.showSnackBarUsingText('Copied to clipboard');
  }

  /// Shortens the string by replacing Base64-like patterns with a
  /// shortened version
  ///
  /// This is useful for shortening long strings, such as JSON, that
  /// contain Base64-like patterns since base64 is very long and
  /// can make the console unreadable.
  String shorten() {
    final encodableMessage = _convertToEncodable(this);

    // Encode the message to JSON
    final jsonString = jsonEncode(encodableMessage);

    // Regex to detect Base64-like patterns (simplified for demonstration)
    const base64Pattern =
        '(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?';

    // Shorten Base64 strings to the first 30 and last 30 characters
    final shortened =
        jsonString.replaceAllMapped(RegExp(base64Pattern), (match) {
      final matchedString = match.group(0)!;
      if (matchedString.length > 60) {
        return '${matchedString.substring(0, 30)}...${matchedString.substring(matchedString.length - 30)}';
      }
      return matchedString;
    });

    return shortened;
  }

  String formatJson() {
    try {
      // Decode the JSON string
      final jsonData = jsonDecode(this);

      // Encode the JSON data with pretty printing
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonData);
    } catch (e) {
      // Return the original string if it's not valid JSON
      return this;
    }

  }
}

dynamic _convertToEncodable(dynamic item) {
  if (item is Map) {
    return item.map((key, value) => MapEntry(key, _convertToEncodable(value)));
  } else if (item is Iterable) {
    return item.map(_convertToEncodable).toList();
  } else {
    return item.toString();
  }
}
