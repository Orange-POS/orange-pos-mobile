import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 24;
  static const double xxl = 49;
  static const double pill = 999;

  static BorderRadius get small => BorderRadius.circular(sm);
  static BorderRadius get medium => BorderRadius.circular(md);
  static BorderRadius get large => BorderRadius.circular(lg);
  static BorderRadius get card => BorderRadius.circular(xl);
  static BorderRadius get heroCard => BorderRadius.circular(xxl);
  static BorderRadius get pillShape => BorderRadius.circular(pill);
}
