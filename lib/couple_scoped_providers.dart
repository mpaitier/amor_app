// ============================================================================
// COUPLE SCOPED PROVIDERS
// ============================================================================
// ViewModels partagés par plusieurs écrans et propres à une relation. Ils
// sont recréés quand la relation active change (autre compte connecté) :
// sans cela, le journal continuerait d'écouter les souvenirs de la relation
// précédente. Placé au-dessus du Navigator, dans le builder de AmorApp.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/couple/presentation/viewmodels/couple_session_viewmodel.dart';
import 'features/timeline/presentation/viewmodels/timeline_viewmodel.dart';
import 'injection_container.dart';

class CoupleScopedProviders extends StatelessWidget {
  final Widget child;

  const CoupleScopedProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final coupleId = context.select<CoupleSessionViewModel, String?>(
      (session) => session.coupleId,
    );

    // --- Création paresseuse : le ViewModel n'est construit qu'à la
    // --- première lecture, depuis un écran qui exige une relation ---
    return ChangeNotifierProvider(
      key: ValueKey<String?>(coupleId),
      create: (_) => TimelineViewModel(
        watchTimelineEvents: sl.watchTimelineEvents,
        deleteTimelineEvent: sl.deleteTimelineEvent,
      ),
      child: child,
    );
  }
}
