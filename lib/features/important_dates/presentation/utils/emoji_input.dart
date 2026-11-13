// ============================================================================
// EMOJI INPUT
// ============================================================================
// Extrait un emoji d'une saisie au clavier. Fonction pure.

// --- Les graphèmes (un emoji composé compte pour un seul caractère)
// --- viennent du package characters, réexporté par Flutter ---
import 'package:flutter/widgets.dart';

// --- Plages Unicode où se trouvent les emojis. Un graphème est un emoji
// --- si son premier point de code tombe dedans : ça couvre les emojis
// --- composés (👩‍❤️‍👨), avec couleur de peau (👍🏽) ou sélecteur de
// --- variante (❤️), et les drapeaux (🇫🇷). On évite \p{...} dans une
// --- RegExp : ça marche à l'exécution mais l'analyseur ne sait pas le lire.
const List<(int, int)> _emojiRanges = [
  (0x00A9, 0x00A9), // ©
  (0x00AE, 0x00AE), // ®
  (0x203C, 0x203C), // ‼
  (0x2049, 0x2049), // ⁉
  (0x2122, 0x2122), // ™
  (0x2139, 0x2139), // ℹ
  (0x2194, 0x21AA), // flèches
  (0x231A, 0x23FF), // montres, sabliers, boutons média
  (0x24C2, 0x24C2), // Ⓜ
  (0x25AA, 0x25FE), // carrés, triangles
  (0x2600, 0x27BF), // symboles divers et dingbats (☀, ❤, ✨...)
  (0x2934, 0x2935), // flèches courbes
  (0x2B05, 0x2B55), // flèches, ⭐, ⭕
  (0x3030, 0x3030), // 〰
  (0x303D, 0x303D), // 〽
  (0x3297, 0x3299), // ㊗ ㊙
  (0x1F000, 0x1FAFF), // pictogrammes, drapeaux, visages, objets...
];

bool _isEmoji(String grapheme) {
  final rune = grapheme.runes.first;
  for (final (start, end) in _emojiRanges) {
    if (rune >= start && rune <= end) return true;
  }
  return false;
}

// --- Premier emoji de la saisie, entier même s'il est composé. Null si
// --- la saisie ne commence pas par un emoji ---
String? extractEmoji(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final first = trimmed.characters.first;
  return _isEmoji(first) ? first : null;
}

// --- Dernier emoji de la saisie. Sert quand on touche un emoji puis un
// --- autre : c'est le dernier touché qui compte ---
String? extractLastEmoji(String input) {
  for (final character in input.characters.toList().reversed) {
    if (_isEmoji(character)) return character;
  }
  return null;
}
