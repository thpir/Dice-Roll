import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_text_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmLabel;
  final String? cancelLabel;
  final bool destructive;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
  });

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String? cancelLabel = 'Cancel',
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Dialog(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.sBR),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.titleL.copyWith(color: colors.ink),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                message!,
                style: AppTypography.bodyM.copyWith(color: colors.inkMute),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (cancelLabel != null) ...[
                  AppTextButton(
                    label: cancelLabel!,
                    onPressed: () => Navigator.of(context).pop(false),
                    color: colors.inkMute,
                  ),
                  const SizedBox(width: AppSpacing.s),
                ],
                AppTextButton(
                  label: confirmLabel,
                  onPressed: () => Navigator.of(context).pop(true),
                  color: destructive ? colors.pink : colors.acid,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
