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
import 'features/timeline/presentation/viewmodels/timeline_viewmodel.dart';

void main() async {
  // --- Flutter bootstrap ---
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('fr_FR', null);

  // --- Firebase bootstrap ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // --- Global ViewModel injection ---
    // --- TimelineViewModel lives at the app root so both the timeline
    // --- list screen and the event detail screen share the same instance.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TimelineViewModel(
            watchTimelineEvents: sl.watchTimelineEvents,
            deleteTimelineEvent: sl.deleteTimelineEvent,
          ),
        ),
      ],
      child: const AmorApp(),
    ),
  );
}