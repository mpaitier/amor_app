// ============================================================================
// SPECIAL DAY STYLE ENTITY
// ============================================================================
// Apparence d'une case spéciale du calendrier : un emoji sur un fond et une
// bordure. Les couleurs sont des entiers ARGB, sans dépendance à Flutter.

class SpecialDayStyle {
  final String emoji;
  final int backgroundColor;
  final int borderColor;

  const SpecialDayStyle({
    required this.emoji,
    required this.backgroundColor,
    required this.borderColor,
  });

  SpecialDayStyle copyWith({
    String? emoji,
    int? backgroundColor,
    int? borderColor,
  }) {
    return SpecialDayStyle(
      emoji: emoji ?? this.emoji,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SpecialDayStyle &&
        other.emoji == emoji &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor;
  }

  @override
  int get hashCode => Object.hash(emoji, backgroundColor, borderColor);
}
