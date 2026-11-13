// ============================================================================
// SPECIAL DAY STYLE ENTITY
// ============================================================================
// Apparence d'un jour spécial : un emoji sur un fond et une bordure dans le
// calendrier, et un GIF dans sa fiche. Les couleurs sont des entiers ARGB, sans dépendance à Flutter.

class SpecialDayStyle {
  final String emoji;
  final int backgroundColor;
  final int borderColor;

  // --- Vide tant qu'aucun GIF n'a été tiré ---
  final String gifUrl;

  const SpecialDayStyle({
    required this.emoji,
    required this.backgroundColor,
    required this.borderColor,
    this.gifUrl = '',
  });

  SpecialDayStyle copyWith({
    String? emoji,
    int? backgroundColor,
    int? borderColor,
    String? gifUrl,
  }) {
    return SpecialDayStyle(
      emoji: emoji ?? this.emoji,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      gifUrl: gifUrl ?? this.gifUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SpecialDayStyle &&
        other.emoji == emoji &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        other.gifUrl == gifUrl;
  }

  @override
  int get hashCode =>
      Object.hash(emoji, backgroundColor, borderColor, gifUrl);
}
