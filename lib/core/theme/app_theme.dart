// <<===========================================================================>>
// <<============================ THÈME DE L'APP ===============================>>
// <<===========================================================================>>

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

// <<--- Thème Light (Medium Contrast) --->
final ThemeData amorLightTheme = ThemeData(
  useMaterial3: true,
  textTheme: amorTextTheme,
  // <<--- Désactive globalement les décorations de texte héritées du système --->
  // <<--- Règle le soulignage jaune et la police rouge de Google Fonts / Lora --->
  textSelectionTheme: const TextSelectionThemeData(
    selectionColor: Color(0x44703348),
    cursorColor: amorDarkRose,
    selectionHandleColor: amorDarkRose,
  ),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,

    primary: primaryLightMediumContrast,
    onPrimary: onPrimaryLightMediumContrast,
    primaryContainer: primaryContainerLightMediumContrast,
    onPrimaryContainer: onPrimaryContainerLightMediumContrast,

    secondary: secondaryLightMediumContrast,
    onSecondary: onSecondaryLightMediumContrast,
    secondaryContainer: secondaryContainerLightMediumContrast,
    onSecondaryContainer: onSecondaryContainerLightMediumContrast,

    tertiary: tertiaryLightMediumContrast,
    onTertiary: onTertiaryLightMediumContrast,
    tertiaryContainer: tertiaryContainerLightMediumContrast,
    onTertiaryContainer: onTertiaryContainerLightMediumContrast,

    error: errorLight,
    onError: onErrorLight,
    errorContainer: errorContainerLight,
    onErrorContainer: onErrorContainerLight,

    surface: surfaceLightMediumContrast,
    onSurface: onSurfaceLightMediumContrast,
    surfaceContainerHighest: surfaceContainerHighestLightMediumContrast,
    outline: outlineLightMediumContrast,
    outlineVariant: outlineVariantLightMediumContrast,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: inverseSurfaceLight,
    onInverseSurface: inverseOnSurfaceLight,
    inversePrimary: inversePrimaryLight,
  ),
);

// <<--- Thème Dark --->
final ThemeData amorDarkTheme = ThemeData(
  useMaterial3: true,
  textTheme: amorTextTheme,
  textSelectionTheme: const TextSelectionThemeData(
    selectionColor: Color(0x44FFB1C8),
    cursorColor: primaryDark,
    selectionHandleColor: primaryDark,
  ),
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: primaryDark,
    onPrimary: onPrimaryDark,
    primaryContainer: primaryContainerDark,
    onPrimaryContainer: onPrimaryContainerDark,
    secondary: secondaryDark,
    onSecondary: onSecondaryDark,
    secondaryContainer: secondaryContainerDark,
    onSecondaryContainer: onSecondaryContainerDark,
    tertiary: tertiaryDark,
    onTertiary: onTertiaryDark,
    tertiaryContainer: tertiaryContainerDark,
    onTertiaryContainer: onTertiaryContainerDark,
    error: errorLight,
    onError: onErrorLight,
    errorContainer: errorContainerLight,
    onErrorContainer: onErrorContainerLight,
    surface: surfaceDark,
    onSurface: onSurfaceDark,
    surfaceContainerHighest: surfaceContainerHighestDark,
    outline: outlineDark,
    outlineVariant: outlineVariantDark,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: inverseSurfaceDark,
    onInverseSurface: inverseOnSurfaceDark,
    inversePrimary: inversePrimaryDark,
  ),
);