// ============================================================================
// EVENT GIF FIELD
// ============================================================================
// GIF du souvenir dans le formulaire. Il vit dans le ViewModel : il ne
// change donc plus quand le formulaire défile, et il est enregistré avec
// le souvenir.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../gif/presentation/components/gif_view.dart';
import '../viewmodels/add_edit_event_viewmodel.dart';

class EventGifField extends StatelessWidget {
  const EventGifField({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditEventViewModel>();

    return GifView(
      gifUrl: viewModel.gifUrl,
      isLoading: viewModel.isGifLoading,
      onRefresh: viewModel.loadRandomGif,
    );
  }
}
