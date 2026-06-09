import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';

class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onPressed != null;
    final fg = enabled ? (color ?? colors.acid) : colors.inkMute;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.smBR,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.smBR,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.labelL.copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}
