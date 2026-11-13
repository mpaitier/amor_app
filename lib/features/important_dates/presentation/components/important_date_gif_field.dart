// ============================================================================
// IMPORTANT DATE GIF FIELD
// ============================================================================
// GIF de la date importante dans le formulaire, tiré au hasard et enregistré
// avec elle. Le bouton à sa droite en tire un autre.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../gif/presentation/components/gif_view.dart';
import '../viewmodels/add_edit_important_date_viewmodel.dart';

class ImportantDateGifField extends StatelessWidget {
  const ImportantDateGifField({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditImportantDateViewModel>();

    return GifView(
      gifUrl: viewModel.gifUrl,
      isLoading: viewModel.isGifLoading,
      onRefresh: viewModel.loadRandomGif,
    );
  }
}
