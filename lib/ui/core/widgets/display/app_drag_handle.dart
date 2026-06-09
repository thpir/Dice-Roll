import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';

class AppDragHandle extends StatelessWidget {
  final double size;
  final Color? color;

  const AppDragHandle({
    super.key,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Icon(
      Icons.drag_indicator,
      color: color ?? colors.inkMute,
      size: size,
    );
  }
}
