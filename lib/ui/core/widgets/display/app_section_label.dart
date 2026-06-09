import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';

class AppSectionLabel extends StatelessWidget {
  final String label;
  final Color? color;

  const AppSectionLabel({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      label.toUpperCase(),
      style: AppTypography.overline.copyWith(color: color ?? colors.inkMute),
    );
  }
}
