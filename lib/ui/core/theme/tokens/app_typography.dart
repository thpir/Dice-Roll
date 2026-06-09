import 'package:flutter/widgets.dart';

import 'app_font_families.dart';

abstract final class AppTypography {
  static const displayL = TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 96,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );
  static const displayM = TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
  static const titleL = TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const titleM = TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const bodyM = TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const labelL = TextStyle(
    fontFamily: AppFontFamilies.mono,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
  static const labelM = TextStyle(
    fontFamily: AppFontFamilies.mono,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.4,
  );
  static const overline = TextStyle(
    fontFamily: AppFontFamilies.mono,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 1.5,
  );
  static const caption = TextStyle(
    fontFamily: AppFontFamilies.mono,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.3,
  );
}
