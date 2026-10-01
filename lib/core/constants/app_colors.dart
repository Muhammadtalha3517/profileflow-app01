import 'package:flutter/material.dart';

/// AppColors defines the curated, harmonious Material 3 color system for ProfileFlow.
/// Designed with modern Indigo, Deep Slate, and Teal accents.
class AppColors {
  // Brand Primary & Secondary
  static const Color primary = Color(0xFF3F51B5); // Deep Indigo
  static const Color primaryDark = Color(0xFF303F9F);
  static const Color primaryLight = Color(0xFFC5CAE9);
  static const Color secondary = Color(0xFF00897B); // Teal Accent
  static const Color secondaryLight = Color(0xFF80CBC4);
  static const Color accent = Color(0xFF6C63FF);

  // Surface & Background - Light Mode
  static const Color backgroundLight = Color(0xFFF8F9FD);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Surface & Background - Dark Mode
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDark = Color(0xFF1E293B);
  static const Color dividerDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // Status & Confidence Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444); // Crimson
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoBg = Color(0xFFEFF6FF);

  // Confidence Badges
  static const Color confidenceHigh = Color(0xFF10B981);
  static const Color confidenceMedium = Color(0xFFF59E0B);
  static const Color confidenceUncertain = Color(0xFFEC4899);

  // Security Shields & Badges
  static const Color securityBadge = Color(0xFF059669);
  static const Color securityBadgeBg = Color(0xFFD1FAE5);
}
