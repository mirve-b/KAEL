import 'package:flutter/material.dart';

/// Shared light/dark palette for sidebars, tab bars, glass panels, and CV chrome.
class KaelTheme {
  final bool isLightMode;

  const KaelTheme({required this.isLightMode});

  static KaelTheme of(bool isLightMode) => KaelTheme(isLightMode: isLightMode);

  // --- Surfaces ---
  Color get sidebarBackground =>
      isLightMode ? const Color(0xFFF2F2F2) : const Color(0xFF000000);

  Color get sidebarBorder =>
      isLightMode ? const Color(0xFFD0D0D0) : const Color.fromARGB(255, 79, 78, 78);

  Color get tabBarBackground =>
      isLightMode ? const Color(0xFFE8E8E8) : const Color.fromARGB(255, 18, 18, 18);

  Color get panelBackground =>
      isLightMode ? const Color.fromARGB(110, 255, 255, 255) : const Color.fromARGB(90, 14, 14, 14);

  Color get panelBackgroundAlt =>
      isLightMode ? const Color.fromARGB(100, 255, 255, 255) : const Color.fromARGB(75, 0, 0, 0);

  Color get canvasBackground =>
      isLightMode ? const Color(0xFFF5F5F5) : const Color(0xFF121212);

  Color get cvCanvasBackground =>
      isLightMode ? const Color(0xFFFAFAFA) : const Color(0xFF000000);

  // --- Interaction ---
  Color get selectedBackground => Colors.red.shade900.withValues(alpha: 0.3);

  Color get hoverBackground =>
      isLightMode ? Colors.black.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.1);

  Color get hoverBorder =>
      isLightMode ? Colors.black.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.15);

  // --- Text ---
  Color get textPrimary => isLightMode ? const Color(0xFF1A1A1A) : Colors.white;

  Color get textSecondary =>
      isLightMode ? const Color(0xFF5C5C5C) : Colors.white70;

  Color get textMuted =>
      isLightMode ? const Color(0xFF8A8A8A) : const Color.fromARGB(255, 120, 110, 95);

  Color get textDim =>
      isLightMode ? const Color(0xFFB0B0B0) : Colors.white24;

  Color get accentGrey =>
      isLightMode ? const Color(0xFF6E6E6E) : const Color.fromARGB(255, 171, 163, 153);

  // --- Toggle button ---
  Color get themeToggleFill =>
      isLightMode ? const Color(0xFF2A2A2A) : Colors.white;

  Color get themeToggleHoverGlow =>
      isLightMode ? Colors.black.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.5);

  // --- CV-specific (replaces old gold palette) ---
  Color get cvText => accentGrey;

  Color get cvFieldBorder => accentGrey.withValues(alpha: 0.25);

  Color get cvCardBorder => accentGrey.withValues(alpha: 0.2);
}
