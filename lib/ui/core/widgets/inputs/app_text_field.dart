import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? prefixText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.autofocus = false,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final restingBorder = OutlineInputBorder(
      borderSide: BorderSide(color: colors.outline, width: 2),
    );
    final focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: colors.acid, width: 2),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      autofocus: autofocus,
      style: AppTypography.bodyM.copyWith(color: colors.ink),
      cursorColor: colors.acid,
      decoration: InputDecoration(
        prefixText: prefixText,
        hintText: hintText,
        hintStyle: AppTypography.bodyM.copyWith(color: colors.inkMute),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        border: restingBorder,
        enabledBorder: restingBorder,
        focusedBorder: focusedBorder,
      ),
    );
  }
}
