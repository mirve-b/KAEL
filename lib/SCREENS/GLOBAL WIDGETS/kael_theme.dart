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
      isLightMode ? const Color(0xFFE8E8E8) : const Color.fromARGB(255, 24, 24, 24);

  Color get panelBackground =>
      isLightMode ? const Color.fromARGB(110, 255, 255, 255) : const Color.fromARGB(90, 14, 14, 14);

  Color get panelBackgroundAlt =>
      isLightMode ? const Color.fromARGB(100, 255, 255, 255) : const Color.fromARGB(75, 0, 0, 0);

  /// Charcoal — not pitch black.
  Color get canvasBackground =>
      isLightMode ? const Color(0xFFF5F5F5) : const Color(0xFF1E1E1E);

  Color get cvCanvasBackground =>
      isLightMode ? const Color(0xFFFAFAFA) : const Color(0xFF000000);

  // --- Accent palette (grey + red) ---
  Color get accentRed => const Color(0xFFB71C1C);

  Color get accentGrey =>
      isLightMode ? const Color(0xFF6E6E6E) : const Color(0xFF9A9A9A);

  Color get accentGreyMuted =>
      isLightMode ? const Color(0xFF9A9A9A) : const Color(0xFF7A7A7A);

  // --- Interaction ---
  Color get hoverBackground =>
      isLightMode ? const Color(0xFFE4E4E4) : const Color(0xFF3A3A3A);

  Color get hoverBorder =>
      isLightMode ? const Color(0xFF9A9A9A) : const Color(0xFF6E6E6E);

  Color get hoverText => accentGrey;

  Color get selectedBackground => isLightMode
      ? const Color(0xFFD0D0D0).withValues(alpha: 0.65)
      : accentRed.withValues(alpha: 0.35);

  Color get selectedBorder =>
      isLightMode ? Colors.black : accentRed.withValues(alpha: 0.6);

  Color get selectedText => isLightMode ? Colors.black : Colors.white;

  // --- Text ---
  Color get textPrimary => isLightMode ? const Color(0xFF1A1A1A) : Colors.white;

  Color get textSecondary =>
      isLightMode ? const Color(0xFF5C5C5C) : Colors.white70;

  Color get textMuted =>
      isLightMode ? const Color(0xFF8A8A8A) : const Color(0xFF9A9A9A);

  Color get textDim =>
      isLightMode ? const Color(0xFFB0B0B0) : Colors.white24;

  // --- Toggle button ---
  Color get themeToggleFill =>
      isLightMode ? const Color(0xFF2A2A2A) : Colors.white;

  Color get themeToggleHoverGlow =>
      isLightMode ? Colors.black.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.5);

  // --- CV-specific ---
  Color get cvText => isLightMode ? const Color(0xFF2A2A2A) : accentGrey;

  Color get cvFieldBorder => cvText.withValues(alpha: isLightMode ? 0.45 : 0.25);

  Color get cvCardBorder => cvText.withValues(alpha: isLightMode ? 0.3 : 0.2);

  Color get cvCardBackground =>
      isLightMode ? const Color(0xFFF0F0F0) : Colors.black;

  /// Bottom action bars (catalog add row, portfolio style row).
  Color get bottomBarBackground =>
      isLightMode ? const Color(0xFFE8E8E8) : const Color(0xFF141414);

  /// Portfolio card / placeholder surfaces (banner, about image, project grid).
  Color get portfolioSurface =>
      isLightMode ? Colors.white.withValues(alpha: 0.55) : Colors.black.withValues(alpha: 0.55);

  Color get portfolioSurfaceBorder => sidebarBorder.withValues(alpha: 0.4);

  /// Catalog cell chrome.
  Color get cellBackground =>
      isLightMode ? Colors.white.withValues(alpha: 0.72) : const Color(0xFF212121);

  Color get cellTextPrimary => textPrimary;

  Color get cellTextSecondary => textSecondary;

  Color get cellTextMuted => textMuted;

  /// Very light border on catalog cells in light mode.
  Color get cellBorder =>
      isLightMode ? const Color(0xFFE6E6E6) : Colors.transparent;

  Color cellBorderColor({required bool isHovered, required bool isEditing}) {
    if (isHovered && !isEditing) return hoverBorder;
    return cellBorder;
  }

  /// Bouncy button fill for catalog/portfolio actions.
  Color bouncyButtonFill(bool isHovered) => isHovered
      ? (isLightMode ? const Color(0xFFBDBDBD) : const Color(0xFF4A4A4A))
      : (isLightMode ? const Color(0xFFE0E0E0) : const Color(0xFF2A2A2A));

  Color bouncyButtonText(bool isHovered) =>
      isHovered ? (isLightMode ? Colors.black : Colors.white) : accentGreyMuted;
}
