// ============================================================================
// APP ENTRY POINT
// ============================================================================
// Equivalent of MainActivity.kt — Firebase bootstrap and app launch.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'injection_container.dart';
import 'features/auth/presentation/viewmodels/auth_session_viewmodel.dart';
import 'features/timeline/presentation/viewmodels/timeline_viewmodel.dart';
import 'features/navigation/presentation/viewmodels/floating_buttons_viewmodel.dart';

void main() async {
  // --- Flutter bootstrap ---
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('fr_FR', null);

  // --- Firebase bootstrap ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- Permission + token FCM + enregistrement dans Firestore ---
  await sl.initializeNotifications();

  runApp(
    // --- Global ViewModel injection ---
    // --- TimelineViewModel lives at the app root so both the timeline
    // --- list screen and the event detail screen share the same instance.
    MultiProvider(
      providers: [
        // --- Session de connexion, lue par le routeur dès le lancement ---
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => AuthSessionViewModel(
            watchAuthState: sl.watchAuthState,
            signOut: sl.signOut,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TimelineViewModel(
            watchTimelineEvents: sl.watchTimelineEvents,
            deleteTimelineEvent: sl.deleteTimelineEvent,
          ),
        ),
        // --- Position des boutons flottants, partagée par tous les écrans
        // --- et oubliée à la fermeture de l'app ---
        ChangeNotifierProvider(create: (_) => FloatingButtonsViewModel()),
      ],
      child: const AmorApp(),
    ),
  );
}