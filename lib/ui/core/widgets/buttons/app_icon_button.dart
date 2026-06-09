import 'package:dice_roll/ui/core/theme/tokens/app_durations.dart';
import 'package:flutter/material.dart';
import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';

class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool framed;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.framed = false,
    this.size = 24,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
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
    final color = _enabled ? (widget.color ?? colors.ink) : colors.inkMute;
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
          _pressed ? 2 : 0,
          _pressed ? 2 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: widget.framed ? colors.surface : Colors.transparent,
          border: widget.framed ? Border.all(color: color, width: 2) : null,
          boxShadow: widget.framed
              ? [BoxShadow(color: color, offset: Offset(offset, offset))]
              : null,
        ),
        padding: EdgeInsets.all(widget.framed ? AppSpacing.s : AppSpacing.xs),
        child: Icon(widget.icon, color: color, size: widget.size),
      ),
    );
  }
}
