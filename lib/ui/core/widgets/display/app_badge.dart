import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color ?? colors.acid,
        borderRadius: AppRadii.sBR,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.overline.copyWith(color: textColor ?? colors.bg),
      ),
    );
  }
}
