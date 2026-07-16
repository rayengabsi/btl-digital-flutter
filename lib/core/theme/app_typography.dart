import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

abstract final class AppTypography {
  static final TextStyle _base = GoogleFonts.plusJakartaSans();

  static TextStyle get h1 =>
      _base.copyWith(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get h2 =>
      _base.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25);

  static TextStyle get h3 =>
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get h4 =>
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w600, height: 1.35);

  static TextStyle get h5 =>
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get h6 =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get bodyLarge =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodyMedium =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodySmall =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get labelLarge =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get labelMedium =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get labelSmall =>
      _base.copyWith(fontSize: 10, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get buttonLarge =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get buttonMedium =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get caption =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary);

  static TextStyle get overline =>
      _base.copyWith(fontSize: 10, fontWeight: FontWeight.w500, height: 1.6, letterSpacing: 1.5);
}
