// <<===========================================================================>>
// <<====================== ÉCRAN AJOUT / ÉDITION ÉVÉNEMENT ====================>>
// <<===========================================================================>>
// <<--- L'upload des images se fait UNIQUEMENT au moment de "Enregistrer" --->
// <<--- Les images sont stockées dans : amor_events/{titre_event}/ --->

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/timeline_event.dart';
import '../../../data/services/photo_service.dart';
import '../../../navigation/screen.dart';
import '../../../ui/viewmodels/timeline_viewmodel.dart';
import '../../../widgets/random_gif.dart';
import '../../components/common/place_autocomplete_field.dart';
import '../../components/timeline/image_list_editor.dart';
import '../../components/timeline/image_picker_bar.dart';

class AddEventScreen extends StatefulWidget {
  final TimelineEvent? eventToEdit;

  const AddEventScreen({super.key, this.eventToEdit});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  // <<--- Contrôleurs --->
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  // <<--- Service photo --->
  final PhotoService _photoService = PhotoService();

  // <<--- États formulaire --->
  late DateTime _selectedDate;
  late String _selectedWho;
  late String _currentPlace;
  late List<ImageItem> _imageItems;

  // <<--- États techniques --->
  bool _isLoading = false;
  int _nextImageId = 1;

  static const Color _cardBackground = amorCream;

  @override
  void initState() {
    super.initState();
    final event = widget.eventToEdit;

    _titleController = TextEditingController(text: event?.title ?? '');
    _descriptionController =
        TextEditingController(text: event?.description ?? '');
    _selectedDate = event?.date ?? DateTime.now();
    _selectedWho = event?.who ?? 'Lulu';
    _currentPlace = event?.place ?? '';

    // <<--- Initialisation images existantes (déjà uploadées, on garde leur URL) --->
    _imageItems = [];
    if (event != null && event.imageUrl.isNotEmpty) {
      final urls = event.imageUrl.split('|');
      for (var i = 0; i < urls.length; i++) {
        _imageItems.add(ImageItem(
          id: i + 1,
          url: urls[i].trim(),
          // <<--- localFile est null : déjà sur Storage, pas à ré-uploader --->
        ));
        _nextImageId = i + 2;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, isEditing),
      body: Stack(
        children: [
          _buildForm(context),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // <<--- AppBar --->
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isEditing) {
    return AppBar(
      backgroundColor: amorCreamTransparent,
      title: Text(
        isEditing ? 'Modifier le souvenir' : 'Ajouter un souvenir',
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
          onPressed: _isLoading ? null : () => _handleSave(context),
          child: Text(
            'Enregistrer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isLoading ? Colors.grey : amorDarkRose,
            ),
          ),
        ),
      ],
    );
  }

  // <<--- Formulaire --->
  Widget _buildForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        // <<--- GIF hérisson --->
        const Center(
          child: RandomGif(searchTerm: 'hedgehog cute', height: 100),
        ),

        const SizedBox(height: 12),

        // <<--- Titre --->
        _buildTitleField(),

        const SizedBox(height: 12),

        // <<--- Date + Lieu --->
        _buildDatePlaceCard(context),

        const SizedBox(height: 12),

        // <<--- Créé par --->
        _buildWhoSelector(),

        const SizedBox(height: 12),

        // <<--- Description --->
        _buildDescriptionField(),

        const SizedBox(height: 12),

        // <<--- Section Images --->
        _buildImagesSection(),
      ],
    );
  }

  // <<--- Titre --->
  Widget _buildTitleField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          hintText: 'Titre...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // <<--- Date + Lieu --->
  Widget _buildDatePlaceCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}',
                  style: const TextStyle(color: Color(0xFF616161)),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          PlaceAutocompleteField(
            initialValue: _currentPlace,
            onPlaceSelected: (place) {
              setState(() => _currentPlace = place);
            },
          ),
        ],
      ),
    );
  }

  // <<--- Créé par --->
  Widget _buildWhoSelector() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Créé par : ',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          for (final option in ['Lulu', 'Titi'])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                selected: _selectedWho == option,
                label: Text(option),
                onSelected: (_) => setState(() => _selectedWho = option),
              ),
            ),
        ],
      ),
    );
  }

  // <<--- Description --->
  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _descriptionController,
        minLines: 4,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'Raconte-moi...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // <<--- Section Images --->
  Widget _buildImagesSection() {
    // <<--- Compte les images en attente d'upload --->
    final pendingCount = _imageItems.where((i) => i.isPendingUpload).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Images',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            // <<--- Badge indiquant les images en attente --->
            if (pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pendingCount en attente',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 10),

        // <<--- Boutons Galerie / Caméra — ne font QUE sélectionner --->
        ImagePickerBar(
          isLoading: _isLoading,
          onImagesPicked: _handleImagesPicked,
        ),

        const SizedBox(height: 12),

        // <<--- Éditeur visuel des images --->
        ImageListEditor(
          images: _imageItems,
          onImagesChanged: (updated) {
            setState(() => _imageItems = updated);
          },
        ),
      ],
    );
  }

  // <<--- Overlay chargement --->
  Widget _buildLoadingOverlay() {
    // <<--- Compte les images locales à uploader pour afficher la progression --->
    final pendingCount = _imageItems.where((i) => i.isPendingUpload).length;

    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: amorDarkRose),
                const SizedBox(height: 16),
                Text(
                  pendingCount > 0
                      ? 'Upload de $pendingCount image(s)...'
                      : 'Synchronisation...',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // <<--- Ajout à la liste locale SANS upload --->
  void _handleImagesPicked(List<File> files) {
    setState(() {
      for (final file in files) {
        _imageItems.add(ImageItem(
          id: _nextImageId++,
          localFile: file,
          // <<--- url reste vide : sera rempli au moment de l'enregistrement --->
        ));
      }
    });
  }

  // <<--- Sélecteur de date --->
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // <<===================================================================>>
  // <<========================== SAUVEGARDE ================================>>
  // <<===================================================================>>
  // <<--- Upload d'abord, puis save. Tout ce qui dépend du BuildContext   --->
  // <<--- est capturé AVANT le premier "await" pour éviter d'utiliser un --->
  // <<--- BuildContext après un "gap" asynchrone (use_build_context_     --->
  // <<--- synchronously). Un seul "context.mounted" check est fait juste --->
  // <<--- avant la dernière utilisation du context, sans autre await     --->
  // <<--- entre les deux.                                                --->
  // <<===================================================================>>
  Future<void> _handleSave(BuildContext context) async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    // <<--- On capture tout ce dont on a besoin du context AVANT les await --->
    final viewModel = context.read<TimelineViewModel>();
    final bool isEditing = widget.eventToEdit != null;

    // <<--- Nom du dossier Storage : amor_events/{titre_nettoyé}/ --->
    // <<--- On nettoie le titre pour éviter les caractères spéciaux dans le path --->
    final folderName = _titleController.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9àâäéèêëîïôùûüç\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final storageFolder = 'amor_events/$folderName';

    // <<--- Upload des images en attente (localFile != null) --->
    final updatedItems = <ImageItem>[];
    for (final item in _imageItems) {
      if (item.isPendingUpload) {
        // <<--- Upload vers amor_events/{titre}/{timestamp}.jpg --->
        final url = await _photoService.uploadPhoto(
          item.localFile!,
          dossier: storageFolder,
        );
        if (url != null) {
          // <<--- On remplace le fichier local par l'URL obtenue --->
          updatedItems.add(ImageItem(id: item.id, url: url));
        }
        // <<--- Si l'upload échoue, on ignore silencieusement ce fichier --->
      } else {
        // <<--- Image déjà uploadée : on garde l'URL telle quelle --->
        updatedItems.add(item);
      }
    }

    final finalImageUrls = updatedItems.map((i) => i.url).join('|');

    final newEvent = TimelineEvent(
      id: widget.eventToEdit?.id ?? '',
      title: _titleController.text.trim(),
      date: _selectedDate,
      place: _currentPlace,
      who: _selectedWho,
      imageUrl: finalImageUrls,
      description: _descriptionController.text.trim(),
    );

    String? savedId;
    bool success = false;

    if (isEditing) {
      success = await viewModel.updateEvent(newEvent);
      if (success) savedId = newEvent.id;
    } else {
      savedId = await viewModel.addEvent(newEvent);
      success = savedId != null;
    }

    // <<--- Seul check "mounted" : rien d'asynchrone après, donc il couvre --->
    // <<--- toutes les utilisations du context ci-dessous.                 --->
    if (!context.mounted) return;

    setState(() => _isLoading = false);

    if (!success || savedId == null) return;

    // <<===================================================================>>
    // <<===================== NAVIGATION DE RETOUR ==========================>>
    // <<===================================================================>>
    // <<--- ÉDITION : l'écran EventDetail existe déjà dans la pile         --->
    // <<--- (Timeline -> EventDetail -> AddEvent). Il est déjà connecté    --->
    // <<--- au TimelineViewModel via context.watch, donc il se mettra à   --->
    // <<--- jour automatiquement dès que Firestore renvoie les nouvelles  --->
    // <<--- données. Un simple pop() suffit : on évite d'empiler une      --->
    // <<--- deuxième couche d'EventDetail (ce qui obligeait à revenir en  --->
    // <<--- arrière deux fois).                                           --->
    //
    // <<--- CRÉATION : il n'y a pas encore d'écran détail dans la pile    --->
    // <<--- (Timeline -> AddEvent). On remplace donc AddEvent par le      --->
    // <<--- nouvel écran détail avec pushReplacement.                     --->
    // <<===================================================================>>
    if (isEditing) {
      context.pop();
    } else {
      context.pushReplacement(AppRoutes.timelineDetailPath(savedId));
    }
  }
}