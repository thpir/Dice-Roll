import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';

class AppStatusDot extends StatelessWidget {
  final Color color;
  final String? label;
  final Color? labelColor;
  final double size;

  const AppStatusDot({
    super.key,
    required this.color,
    this.label,
    this.labelColor,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    if (label == null) {
      return dot;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: AppSpacing.s),
        Text(
          label!.toUpperCase(),
          style: AppTypography.overline.copyWith(
            color: labelColor ?? colors.inkMute,
          ),
        ),
      ],
    );
  }
}
