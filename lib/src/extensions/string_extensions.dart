import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logman/logman.dart';

extension StringExtensions on String {
  void copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: this));
    HapticFeedback.lightImpact();
    context.showSnackBarUsingText('Copied to clipboard');
  }
}
