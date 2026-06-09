import 'package:flutter/material.dart';

import 'extensions/app_colors_ext.dart';
import 'tokens/app_colors.dart';
import 'tokens/app_font_families.dart';
import 'tokens/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.pink,
      onPrimary: AppColors.ink,
      secondary: AppColors.acid,
      onSecondary: AppColors.bg,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.pink,
      onError: AppColors.ink,
      outline: AppColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: AppFontFamilies.body,
      textTheme: _textTheme,
      extensions: const [_appColors],
    );
  }

  static const _appColors = AppColorsExt(
    bg: AppColors.bg,
    surface: AppColors.surface,
    acid: AppColors.acid,
    pink: AppColors.pink,
    ink: AppColors.ink,
    onPink: AppColors.onPink,
    inkMute: AppColors.inkMute,
    outline: AppColors.outline,
  );

  static const _textTheme = TextTheme(
    displayLarge: AppTypography.displayL,
    displayMedium: AppTypography.displayM,
    headlineLarge: AppTypography.titleL,
    titleLarge: AppTypography.titleL,
    titleMedium: AppTypography.titleM,
    bodyMedium: AppTypography.bodyM,
    labelLarge: AppTypography.labelL,
    labelMedium: AppTypography.labelM,
    labelSmall: AppTypography.overline,
    bodySmall: AppTypography.caption,
  );
}
