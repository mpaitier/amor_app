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

void main() async {
  
  await initializeDateFormatting('fr_FR', null);
  // <<--- Initialisation Flutter --->
  WidgetsFlutterBinding.ensureInitialized();

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