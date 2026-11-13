// ============================================================================
// IMPORTANT DATE PALETTE (UI MODEL)
// ============================================================================
// Choix proposés dans le formulaire : emojis, fréquences, couleurs de
// bordure et de fond. Les couleurs sont des entiers ARGB, tels qu'ils sont
// enregistrés.

import '../../domain/entities/important_date_entity.dart';

class ImportantDatePalette {
  const ImportantDatePalette._();

  static const List<String> emojis = [
    '❤️',
    '🎂',
    '💍',
    '🎉',
    '✈️',
    '🏖️',
    '🎄',
    '🎁',
    '🏠',
    '🎓',
    '👶',
    '🐾',
    '🍽️',
    '🎫',
    '⭐',
    '📅',
  ];

  // --- Fréquences proposées une fois la répétition activée. La première
  // --- est celle retenue par défaut ---
  static const List<ImportantDateRecurrence> recurrences = [
    ImportantDateRecurrence.yearly,
    ImportantDateRecurrence.monthly,
    ImportantDateRecurrence.weekly,
  ];

  // --- Bordures soutenues, pour se détacher du fond ---
  static const List<int> borderColors = [
    0xFF837377, // gris
    0xFFD32F2F, // rouge
    0xFFEF6C00, // orange
    0xFFE0A800, // jaune
    0xFF2E8B57, // vert
    0xFF00897B, // turquoise
    0xFF2F6FDE, // bleu
    0xFF7B4FD6, // violet
    0xFFE91E63, // rose vif
    0xFF703348, // rose foncé
    0xFF904B3C, // terracotta
    0xFF22191B, // noir
  ];

  // --- Fonds clairs, dans le même ordre, pour que l'emoji reste lisible ---
  static const List<int> backgroundColors = [
    0xFFECE6E8, // gris
    0xFFFFD6D6, // rouge
    0xFFFFE0C2, // orange
    0xFFFFF3C4, // jaune
    0xFFD9F2E0, // vert
    0xFFD0F0EC, // turquoise
    0xFFD9EAFF, // bleu
    0xFFE6D9FF, // violet
    0xFFFFD9E2, // rose
    0xFFFFDAD3, // pêche
    0xFFF1EBDF, // crème
    0xFFFFFFFF, // blanc
  ];
}
