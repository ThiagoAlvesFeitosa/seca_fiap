import 'package:flutter/material.dart';

class AppTheme {
  // ===== Paleta principal =====
  static const fernGreen     = Color(0xFF477023); // primary
  static const darkMoss      = Color(0xFF2D531A); // secondary
  static const pakistanGreen = Color(0xFF0D330E); // tertiary

  // Suportes
  static const bgLight      = Color(0xFFF5FAF3); // fundo claro
  static const surfaceLight = Colors.white;      // cards claros
  static const outlineLight = Color(0xFF95B08A); // bordas suaves

  // Containers claros/escuros (Material 3)
  static const primaryContainerLight   = Color(0xFF6A9447);
  static const secondaryContainerLight = Color(0xFF4B7A33);
  static const tertiaryContainerLight  = Color(0xFF1F4C16);

  static const primaryContainerDark    = Color(0xFF365719);
  static const secondaryContainerDark  = Color(0xFF1F3E13);
  static const tertiaryContainerDark   = Color(0xFF0B2609);

  // ===== ColorSchemes =====
  static final lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: fernGreen, onPrimary: Colors.white,
    primaryContainer: primaryContainerLight, onPrimaryContainer: Colors.white,
    secondary: darkMoss, onSecondary: Colors.white,
    secondaryContainer: secondaryContainerLight, onSecondaryContainer: Colors.white,
    tertiary: pakistanGreen, onTertiary: Colors.white,
    tertiaryContainer: tertiaryContainerLight, onTertiaryContainer: Colors.white,
    background: bgLight, onBackground: const Color(0xFF0A1A07),
    surface: surfaceLight, onSurface: const Color(0xFF10210A),
    surfaceVariant: const Color(0xFFE6EFE1), onSurfaceVariant: const Color(0xFF2E4427),
    outline: outlineLight,
    error: const Color(0xFFBA1A1A), onError: Colors.white,
  );

  static final darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: fernGreen, onPrimary: Colors.white,
    primaryContainer: primaryContainerDark, onPrimaryContainer: Colors.white,
    secondary: darkMoss, onSecondary: Colors.white,
    secondaryContainer: secondaryContainerDark, onSecondaryContainer: Colors.white,
    tertiary: pakistanGreen, onTertiary: Colors.white,
    tertiaryContainer: tertiaryContainerDark, onTertiaryContainer: Colors.white,
    background: const Color(0xFF0B1A09), onBackground: Colors.white,
    surface: const Color(0xFF122512), onSurface: Colors.white70,
    surfaceVariant: const Color(0xFF1C2F1A), onSurfaceVariant: const Color(0xFFC7D7C1),
    outline: const Color(0xFF4F6A4A),
    error: const Color(0xFFFFB4A9), onError: const Color(0xFF680003),
  );

  // ===== Themes (sem TabBarTheme global para evitar erro de tipo) =====
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: lightScheme,
    scaffoldBackgroundColor: lightScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: lightScheme.secondary,
      foregroundColor: lightScheme.onSecondary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: lightScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: lightScheme.outline.withOpacity(.45)),
      ),
      shadowColor: lightScheme.outline.withOpacity(.15),
      surfaceTintColor: lightScheme.primary, // Material 3
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightScheme.primary,
        foregroundColor: lightScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightScheme.primary,
        side: BorderSide(color: lightScheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightScheme.primaryContainer,
      selectedColor: lightScheme.secondaryContainer,
      labelStyle: TextStyle(color: lightScheme.onPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: pakistanGreen,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: darkScheme,
    scaffoldBackgroundColor: darkScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: darkScheme.secondary,
      foregroundColor: darkScheme.onSecondary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: darkScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: darkScheme.outline.withOpacity(.35)),
      ),
      shadowColor: darkScheme.outline.withOpacity(.2),
      surfaceTintColor: darkScheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkScheme.primary,
        foregroundColor: darkScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkScheme.primary,
        side: BorderSide(color: darkScheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkScheme.primaryContainer,
      selectedColor: darkScheme.secondaryContainer,
      labelStyle: TextStyle(color: darkScheme.onPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: pakistanGreen,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );
}
