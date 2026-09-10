// ============================================================================
// ADD / EDIT EVENT SCREEN
// ============================================================================
// Images are uploaded ONLY when "Save" is pressed.
// Images are stored under: amor_events/{event_title}/
//
// NOTE: depends on RandomGif from the "gif" feature and PlaceAutocompleteField
// (via EventDatePlaceCard) from the "place" feature, both created in later
// steps of the refactor.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../navigation/app_routes.dart';
import '../../../gif/presentation/components/random_gif.dart';
import '../../domain/entities/timeline_event_entity.dart';
import '../viewmodels/add_edit_event_viewmodel.dart';
import '../components/event_title_field.dart';
import '../components/event_date_place_card.dart';
import '../components/event_who_selector.dart';
import '../components/event_description_field.dart';
import '../components/event_images_section.dart';
import '../components/event_save_loading_overlay.dart';

class AddEventScreen extends StatelessWidget {
  final TimelineEventEntity? eventToEdit;

  const AddEventScreen({super.key, this.eventToEdit});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddEditEventViewModel(
        addTimelineEvent: sl.addTimelineEvent,
        updateTimelineEvent: sl.updateTimelineEvent,
        pickImagesFromGallery: sl.pickImagesFromGallery,
        takePhoto: sl.takePhoto,
        uploadImages: sl.uploadImages,
        eventToEdit: eventToEdit,
        getDeviceId: sl.getDeviceId,
      ),
      child: const _AddEventView(),
    );
  }
}

class _AddEventView extends StatelessWidget {
  const _AddEventView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditEventViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, viewModel),
      body: Stack(
        children: [
          _buildForm(context),
          if (viewModel.isSaving) const EventSaveLoadingOverlay(),
        ],
      ),
    );
  }

  // --- App bar with the save action ---
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AddEditEventViewModel viewModel,
  ) {
    return AppBar(
      backgroundColor: amorCreamTransparent,
      title: Text(
        viewModel.isEditing ? 'Modifier le souvenir' : 'Ajouter un souvenir',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: amorDarkRose,
          fontSize: 18,
        ),
      ),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        TextButton(
          onPressed:
              viewModel.isSaving ? null : () => _handleSave(context, viewModel),
          child: Text(
            'Enregistrer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: viewModel.isSaving ? Colors.grey : amorDarkRose,
            ),
          ),
        ),
      ],
    );
  }

  // --- Scrollable form ---
  Widget _buildForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: const [
        Center(
          child: RandomGif(searchTerm: 'hedgehog cute', height: 100),
        ),
        SizedBox(height: 12),
        EventTitleField(),
        SizedBox(height: 12),
        EventDatePlaceCard(),
        SizedBox(height: 12),
        EventWhoSelector(),
        SizedBox(height: 12),
        EventDescriptionField(),
        SizedBox(height: 12),
        EventImagesSection(),
      ],
    );
  }

  // --- Save handler: upload then persist, then navigate to the detail screen ---
  Future<void> _handleSave(
    BuildContext context,
    AddEditEventViewModel viewModel,
  ) async {
    final savedId = await viewModel.save();
    if (!context.mounted) return;

    if (savedId != null) {
      context.pushReplacement(AppRoutes.timelineDetailPath(savedId));
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    }
  }
}