import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';

class AppDivider extends StatelessWidget {
  final double thickness;
  final double? height;
  final Color? color;
  final double indent;
  final double endIndent;

  const AppDivider({
    super.key,
    this.thickness = 1,
    this.height,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Divider(
      thickness: thickness,
      height: height ?? thickness,
      color: color ?? colors.outline,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
