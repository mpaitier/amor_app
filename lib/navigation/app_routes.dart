// ============================================================================
// APP ROUTES
// ============================================================================
// Route name constants used by GoRouter.

class AppRoutes {
  // --- Main route ---
  static const String mainMenu = '/';

  // --- Entrée dans l'app : chargement et connexion ---
  static const String splash = '/splash';
  static const String signIn = '/sign-in';

  // --- Timeline routes ---
  static const String addTimeline = '/add-timeline';
  static const String timelineDetail = '/timeline-detail/:id';

  // --- Calendar route ---
  static const String calendar = '/calendar';

  // --- Important dates route ---
  static const String addImportantDate = '/add-important-date';

  // --- Settings route ---
  static const String settings = '/settings';

  // --- Helper for the detail route with an id ---
  static String timelineDetailPath(String id) => '/timeline-detail/$id';
}