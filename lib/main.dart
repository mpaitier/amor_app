// <<===========================================================================>>
// <<============================== POINT D'ENTRÉE =============================>>
// <<===========================================================================>>
// Équivalent de MainActivity.kt — initialisation Firebase et lancement de l'app

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'ui/viewmodels/timeline_viewmodel.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  
  // <<--- Initialisation Flutter --->
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('fr_FR', null);

  // <<--- Initialisation Firebase --->
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // <<--- Injection du ViewModel global --->
    ChangeNotifierProvider(
      create: (_) => TimelineViewModel(),
      child: const AmorApp(),
    ),
  );
}