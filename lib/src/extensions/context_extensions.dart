import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  void showSnackBarUsingText(String text) {
    final snackBar = SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }
}
