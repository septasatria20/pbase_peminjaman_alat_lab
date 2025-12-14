import 'package:flutter/material.dart';

/// ===== PRIMARY THEME =====
const Color themeBlue = Color(0xFF38BDF8);
const Color themeGreen = Color(0xFF4ADE80);

/// ===== GRADIENT =====
const LinearGradient themeGradient = LinearGradient(
  colors: [themeBlue, themeGreen],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// ===== SEMANTIC COLORS =====
const Color primaryColor = themeBlue;
const Color secondaryColor = themeGreen;

const Color successColor = Color(0xFF22C55E);
const Color warningColor = Color(0xFFF59E0B);
const Color errorColor   = Color(0xFFEF4444);

const Color backgroundColor = Color(0xFFF8FAFC);
const Color cardColor = Colors.white;
const Color borderColor = Color(0xFFE5E7EB);
const Color textPrimary = Color(0xFF111827);
const Color textSecondary = Color(0xFF6B7280);
