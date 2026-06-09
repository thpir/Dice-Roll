import 'package:flutter/material.dart';

class AppColorsExt extends ThemeExtension<AppColorsExt> {
  final Color bg;
  final Color surface;
  final Color acid;
  final Color pink;
  final Color ink;
  final Color onPink;
  final Color inkMute;
  final Color outline;

  const AppColorsExt({
    required this.bg,
    required this.surface,
    required this.acid,
    required this.pink,
    required this.ink,
    required this.onPink,
    required this.inkMute,
    required this.outline,
  });

  @override
  AppColorsExt copyWith({
    Color? bg,
    Color? surface,
    Color? acid,
    Color? pink,
    Color? ink,
    Color? onPink,
    Color? inkMute,
    Color? outline,
  }) {
    return AppColorsExt(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      acid: acid ?? this.acid,
      pink: pink ?? this.pink,
      ink: ink ?? this.ink,
      onPink: onPink ?? this.onPink,
      inkMute: inkMute ?? this.inkMute,
      outline: outline ?? this.outline,
    );
  }

  @override
  AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) {
      return this;
    }
    return AppColorsExt(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      acid: Color.lerp(acid, other.acid, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      onPink: Color.lerp(onPink, other.onPink, t)!,
      inkMute: Color.lerp(inkMute, other.inkMute, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColorsExt get appColors => Theme.of(this).extension<AppColorsExt>()!;
}
