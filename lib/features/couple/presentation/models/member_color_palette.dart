// ============================================================================
// MEMBER COLOR PALETTE (UI MODEL)
// ============================================================================
// Couleurs proposées pour chaque membre. Teintes soutenues : elles servent
// à repérer d'un coup d'œil qui a créé un souvenir. Entiers ARGB, tels
// qu'ils sont enregistrés.

class MemberColorPalette {
  const MemberColorPalette._();

  static const List<int> colors = [
    0xFF7B4FD6, // violet
    0xFFE0A800, // jaune
    0xFFE91E63, // rose vif
    0xFF2F6FDE, // bleu
    0xFF2E8B57, // vert
    0xFFEF6C00, // orange
    0xFF00897B, // turquoise
    0xFFD32F2F, // rouge
    0xFF703348, // rose foncé
  ];

  static int get defaultColor => colors.first;
}
