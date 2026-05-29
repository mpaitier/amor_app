// <<===========================================================================>>
// <<============================ ROUTES DE L'APP ==============================>>
// <<===========================================================================>>
// Équivalent de Screen.kt — noms des routes de navigation

class AppRoutes {
  // <<--- Route principale --->
  static const String mainMenu = '/';

  // <<--- Routes questionnaire (premier lancement) --->
  static const String nameQuestion = '/name-question';
  static const String yearQuestion = '/year-question';
  static const String gift = '/gift';

  // <<--- Routes timeline --->
  static const String addTimeline = '/add-timeline';
  static const String timelineDetail = '/timeline-detail/:id';

  // <<--- Helper pour la route détail avec ID --->
  static String timelineDetailPath(String id) => '/timeline-detail/$id';
}