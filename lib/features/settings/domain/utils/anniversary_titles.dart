// ============================================================================
// ANNIVERSARY TITLES
// ============================================================================
// Intitulés des jours spéciaux tirés des réglages du couple. Partagés par le
// calendrier et par l'aperçu de l'écran des paramètres.

// --- "1er anniversaire", "3e anniversaire" ---
String anniversaryTitle(int years) {
  final ordinal = years == 1 ? '1er' : '${years}e';
  return '$ordinal anniversaire';
}

// --- "1 mois", "35 mois" ---
String monthAnniversaryTitle(int months) => '$months mois';
