import 'package:flutter/widgets.dart';

abstract final class AppRadii {
  static const s = 4.0;
  static const sm = 6.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;

  static const sR = Radius.circular(s);
  static const smR = Radius.circular(sm);
  static const mdR = Radius.circular(md);
  static const lgR = Radius.circular(lg);
  static const xlR = Radius.circular(xl);

  static const sBR = BorderRadius.all(sR);
  static const smBR = BorderRadius.all(smR);
  static const mdBR = BorderRadius.all(mdR);
  static const lgBR = BorderRadius.all(lgR);
  static const xlBR = BorderRadius.all(xlR);
}
