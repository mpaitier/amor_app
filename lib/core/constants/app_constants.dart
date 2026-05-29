// <<===========================================================================>>
// <<========================== CONSTANTES DE L'APP ============================>>
// <<===========================================================================>>

// <<--- Dates importantes --->
const int relationStartYear = 2023;
const int relationStartMonth = 12;
const int relationStartDay = 12;

// <<--- Calcul dynamique des années écoulées --->
int get anneesEcoulees {
  final debut = DateTime(relationStartYear, relationStartMonth, relationStartDay);
  final now = DateTime.now();

  int years = now.year - debut.year;
  if (now.month < debut.month ||
      (now.month == debut.month && now.day < debut.day)) {
    years--;
  }
  return years;
}