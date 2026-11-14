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
import 'features/couple/presentation/models/pending_invite.dart';
import 'features/couple/presentation/viewmodels/couple_session_viewmodel.dart';
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
    // --- Global ViewModel injection. Les ViewModels propres à une relation
    // --- (journal) vivent dans CoupleScopedProviders, sous AmorApp ---
    MultiProvider(
      providers: [
        // --- Session de connexion ---
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => AuthSessionViewModel(
            watchAuthState: sl.watchAuthState,
            signOut: sl.signOut,
          ),
        ),
        // --- Relation de la personne connectée, lue par le routeur dès le
        // --- lancement ---
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => CoupleSessionViewModel(
            authSession: context.read<AuthSessionViewModel>(),
            watchCurrentCouple: sl.watchCurrentCouple,
            onCoupleChanged: (coupleId) {
              // --- Les data sources rangent leurs données sous cette
              // --- relation ---
              sl.currentCouple.set(coupleId);
              // --- Le jeton du téléphone est rattaché au compte connecté ---
              if (coupleId != null) sl.registerDeviceToken();
            },
          ),
        ),
        // --- Code reçu par un lien d'invitation, en attente de connexion ---
        ChangeNotifierProvider(create: (_) => PendingInvite()),
        // --- Position des boutons flottants, partagée par tous les écrans
        // --- et oubliée à la fermeture de l'app ---
        ChangeNotifierProvider(create: (_) => FloatingButtonsViewModel()),
      ],
      child: const AmorApp(),
    ),
  );
}