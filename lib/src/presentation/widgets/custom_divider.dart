import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
    );
  }
}
