// ============================================================================
// APP ROUTES
// ============================================================================
// Route name constants used by GoRouter.

class AppRoutes {
  // --- Main route ---
  static const String mainMenu = '/';

  // --- Onboarding questionnaire routes (first launch) ---
  static const String nameQuestion = '/name-question';
  static const String yearQuestion = '/year-question';
  static const String gift = '/gift';

  // --- Timeline routes ---
  static const String addTimeline = '/add-timeline';
  static const String timelineDetail = '/timeline-detail/:id';

  // --- Helper for the detail route with an id ---
  static String timelineDetailPath(String id) => '/timeline-detail/$id';
}