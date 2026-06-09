import 'package:dice_roll/ui/core/theme/tokens/app_colors.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_durations.dart';
import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';

enum AppOutlinedButtonVariant { acid, pink }

class AppOutlinedButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppOutlinedButtonVariant variant;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppOutlinedButtonVariant.acid,
  });

  @override
  State<AppOutlinedButton> createState() => _AppOutlinedButtonState();
}

class _AppOutlinedButtonState extends State<AppOutlinedButton> {
  var _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_enabled) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = widget.onPressed != null;
    final accent = widget.variant == AppOutlinedButtonVariant.acid
        ? colors.acid
        : colors.pink;
    final fg = enabled ? accent : colors.inkMute;
    final offset = _pressed ? 0.0 : 2.0;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          _pressed ? 4 : 0,
          _pressed ? 4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: fg, width: 2),
          color: AppColors.bg,
          boxShadow: [
            BoxShadow(color: fg, offset: Offset(offset, offset))
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: fg, size: 20),
              const SizedBox(width: AppSpacing.s),
            ],
            Text(
              widget.label.toUpperCase(),
              style: AppTypography.labelL.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
