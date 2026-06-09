import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_durations.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';

class AppPrimaryButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
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
    final bg = _enabled ? colors.pink : colors.surface;
    final fg = _enabled ? colors.onPink : colors.inkMute;
    final shadowColor = _enabled ? colors.acid : colors.outline;
    final offset = _pressed ? 0.0 : 4.0;

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
          color: bg,
          boxShadow: [
            BoxShadow(color: shadowColor, offset: Offset(offset, offset)),
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
