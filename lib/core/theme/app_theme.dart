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
  colorScheme: const ColorScheme(
    brightness: Brightness.light,

    // <<--- Primaires --->
    primary: primaryLightMediumContrast,
    onPrimary: onPrimaryLightMediumContrast,
    primaryContainer: primaryContainerLightMediumContrast,
    onPrimaryContainer: onPrimaryContainerLightMediumContrast,

    // <<--- Secondaires --->
    secondary: secondaryLightMediumContrast,
    onSecondary: onSecondaryLightMediumContrast,
    secondaryContainer: secondaryContainerLightMediumContrast,
    onSecondaryContainer: onSecondaryContainerLightMediumContrast,

    // <<--- Tertiaires --->
    tertiary: tertiaryLightMediumContrast,
    onTertiary: onTertiaryLightMediumContrast,
    tertiaryContainer: tertiaryContainerLightMediumContrast,
    onTertiaryContainer: onTertiaryContainerLightMediumContrast,

    // <<--- Erreurs --->
    error: errorLight,
    onError: onErrorLight,
    errorContainer: errorContainerLight,
    onErrorContainer: onErrorContainerLight,

    // <<--- Surfaces --->
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