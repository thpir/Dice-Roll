import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';

class AppScreenPadding extends StatelessWidget {
  final Widget child;
  final double horizontal;
  final double vertical;

  const AppScreenPadding({
    super.key,
    required this.child,
    this.horizontal = AppSpacing.l,
    this.vertical = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: child,
    );
  }
}
