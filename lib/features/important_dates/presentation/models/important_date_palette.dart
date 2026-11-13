// ============================================================================
// IMPORTANT DATE PALETTE (UI MODEL)
// ============================================================================
// Choix proposés dans le formulaire : emojis, couleurs de fond et de bordure.
// Les couleurs sont des entiers ARGB, tels qu'ils sont enregistrés.

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

  // --- Fonds clairs, pour que l'emoji reste lisible ---
  static const List<int> backgroundColors = [
    0xFFFFD9E2, // rose
    0xFFE6D9FF, // violet
    0xFFFFF3C4, // jaune
    0xFFFFDAD3, // pêche
    0xFFD9F2E0, // vert
    0xFFD9EAFF, // bleu
    0xFFF1EBDF, // crème
    0xFFFFFFFF, // blanc
  ];

  // --- Bordures soutenues, pour se détacher du fond ---
  static const List<int> borderColors = [
    0xFF703348, // rose foncé
    0xFFE91E63, // rose vif
    0xFF7B4FD6, // violet
    0xFFE0A800, // jaune
    0xFF904B3C, // terracotta
    0xFF2E8B57, // vert
    0xFF2F6FDE, // bleu
    0xFF837377, // gris
  ];
}
