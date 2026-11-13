// ============================================================================
// EMOJI INPUT
// ============================================================================
// Extrait un emoji d'une saisie au clavier. Fonction pure.

// --- Les graphèmes (un emoji composé compte pour un seul caractère)
// --- viennent du package characters, réexporté par Flutter ---
import 'package:flutter/widgets.dart';

// --- Pictogrammes (😊, ❤️, 👩‍❤️‍👨...) et lettres de drapeau (🇫🇷) ---
final RegExp _emojiPattern = RegExp(
  r'\p{Extended_Pictographic}|\p{Regional_Indicator}',
  unicode: true,
);

// --- Premier emoji de la saisie, entier même s'il est composé. Null si
// --- la saisie ne commence pas par un emoji ---
String? extractEmoji(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final first = trimmed.characters.first;
  return _emojiPattern.hasMatch(first) ? first : null;
}
