import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';

abstract final class AppSnackbar {
  static void show(BuildContext context, String message) {
    final colors = context.appColors;
    _show(context, message, background: colors.acid, foreground: colors.bg);
  }

  static void error(BuildContext context, String message) {
    final colors = context.appColors;
    _show(context, message, background: colors.pink, foreground: colors.ink);
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color background,
    required Color foreground,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.bodyM.copyWith(color: foreground),
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdBR),
          margin: const EdgeInsets.all(AppSpacing.l),
        ),
      );
  }
}
