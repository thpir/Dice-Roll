import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';

class AppColorSwatch extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;
  final double size;
  final bool selected;

  const AppColorSwatch({
    super.key,
    required this.color,
    this.onTap,
    this.size = 56,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: colors.outline,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
