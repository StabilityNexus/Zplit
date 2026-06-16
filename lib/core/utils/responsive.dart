import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 600;
  static const double _large = 900;
  static const double contentMaxWidth = 680;
  static const double _hPadTablet = 32;
  static const double _hPadPhone = 16;

  static double _scale(
    double size,
    double w, {
    required double tablet,
    required double large,
  }) {
    if (w >= _large) return size * large;
    if (w >= tabletBreakpoint) return size * tablet;
    return size;
  }

  // scaling for font according to contsraints.
  static double sp(double size, BoxConstraints constraints) =>
      _scale(size, constraints.maxWidth, tablet: 1.12, large: 1.25);

  // scale for ui dimensions according to constraints.
  static double dp(double size, BoxConstraints constraints) =>
      _scale(size, constraints.maxWidth, tablet: 1.15, large: 1.3);

  // horizontal padding for page-level content.
  static EdgeInsets horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= _large) {
      final h = ((w - contentMaxWidth) / 2).clamp(24.0, double.infinity);
      return EdgeInsets.symmetric(horizontal: h);
    }
    if (w >= tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: _hPadTablet);
    } else {
      return const EdgeInsets.symmetric(horizontal: _hPadPhone);
    }
  }
}
