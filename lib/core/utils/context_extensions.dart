import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  /// Shows a [SnackBar] with the given [message].
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
