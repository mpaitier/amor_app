// <<===========================================================================>>
// <<====================== ÉCRAN AJOUT / ÉDITION ÉVÉNEMENT ====================>>
// <<===========================================================================>>
// Équivalent de AddEvent.kt — formulaire d'ajout et de modification

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/timeline_event.dart';
import '../../../data/services/place_service.dart';
import '../../../navigation/screen.dart';
import '../../../ui/viewmodels/timeline_viewmodel.dart';

// <<--- Modèle interne pour les images --->
class ImageItem {
  final int id;
  String url;
  ImageItem({required this.id, required this.url});
}

class AddEventScreen extends StatefulWidget {
  // <<--- Paramètres --->
  final TimelineEvent? eventToEdit;

  const AddEventScreen({
    super.key,
    this.eventToEdit,
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  // <<--- Contrôleurs de texte --->
  late final TextEditingController _titleController;
  late final TextEditingController _placeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;

  // <<--- États du formulaire --->
  late DateTime _selectedDate;
  late String _selectedWho;
  late List<ImageItem> _imageItems;

  // <<--- États techniques --->
  bool _isLoading = false;
  bool _isUserTyping = false;
  List<PlacePrediction> _predictions = [];
  int _nextImageId = 1;
  int _editingImageIndex = -1;

  // <<--- Couleurs --->
  static const Color _backgroundColor = amorCream;
  static const Color _cardBackground = amorCreamTransparent;

  @override
  void initState() {
    super.initState();

    final event = widget.eventToEdit;

    // <<--- Initialisation avec les données de l'événement à éditer --->
    _titleController = TextEditingController(text: event?.title ?? '');
    _placeController = TextEditingController(text: event?.place ?? '');
    _descriptionController = TextEditingController(text: event?.description ?? '');
    _imageUrlController = TextEditingController();
    _selectedDate = event?.date ?? DateTime.now();
    _selectedWho = event?.who ?? 'Lulu';

    // <<--- Initialisation des images --->
    _imageItems = [];
    if (event != null && event.imageUrl.isNotEmpty) {
      final urls = event.imageUrl.split('|');
      for (var i = 0; i < urls.length; i++) {
        _imageItems.add(ImageItem(id: i + 1, url: urls[i].trim()));
        _nextImageId = i + 2;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;

    return Scaffold(
      backgroundColor: _backgroundColor,

      // <<--- Barre du haut --->
      appBar: _buildAppBar(context, isEditing),

      body: Stack(
        children: [
          // <<--- Formulaire --->
          _buildForm(context),

          // <<--- Overlay de chargement --->
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // <<--- AppBar --->
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isEditing) {
    return AppBar(
      backgroundColor: _backgroundColor,
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
        // <<--- Bouton Enregistrer --->
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

  // <<--- Formulaire principal --->
  Widget _buildForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        // <<--- Titre --->
        _buildTitleField(),

        const SizedBox(height: 12),

        // <<--- Date et Lieu --->
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

  // <<--- Champ Titre --->
  Widget _buildTitleField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          hintText: 'Titre...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // <<--- Carte Date + Lieu --->
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
          // <<--- Sélecteur de date --->
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: const TextStyle(color: Color(0xFF616161)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // <<--- Champ Lieu --->
          TextField(
            controller: _placeController,
            onChanged: (value) {
              setState(() => _isUserTyping = true);
              _fetchPredictions(value);
            },
            decoration: const InputDecoration(
              hintText: 'Lieu...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              isDense: true,
            ),
          ),

          // <<--- Prédictions de lieux --->
          if (_predictions.isNotEmpty && _isUserTyping)
            ..._predictions.map(
              (p) => ListTile(
                dense: true,
                title: Text(p.description, style: const TextStyle(fontSize: 14)),
                onTap: () {
                  setState(() {
                    _placeController.text = p.description;
                    _predictions = [];
                    _isUserTyping = false;
                  });
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
        ],
      ),
    );
  }

  // <<--- Sélecteur Créé par --->
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

  // <<--- Champ Description --->
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images', style: TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 8),

        // <<--- Champ ajout URL --->
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    hintText: 'URL de l\'image...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _addImage,
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // <<--- Liste des images --->
        ..._imageItems.asMap().entries.map(
          (entry) => _buildImageItem(entry.key, entry.value),
        ),
      ],
    );
  }

  // <<--- Item individuel de la liste d'images --->
  Widget _buildImageItem(int index, ImageItem item) {
    final isEditing = _editingImageIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        // <<--- Correction : withOpacity -> withValues --->
        color: isEditing
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isEditing
            ? Border.all(color: amorDarkRose, width: 1.5)
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // <<--- Icône drag --->
          const Icon(Icons.menu, color: amorDarkRose, size: 20),

          // <<--- Numéro --->
          SizedBox(
            width: 28,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '${item.id}.',
                // <<--- Correction : fontWeight dans TextStyle --->
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // <<--- URL (éditable ou non) --->
          Expanded(
            child: isEditing
                ? TextField(
                    autofocus: true,
                    controller: TextEditingController(text: item.url),
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() => _imageItems[index].url = value);
                    },
                  )
                : Text(
                    item.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
          ),

          // <<--- Bouton édition --->
          IconButton(
            onPressed: () => setState(() {
              _editingImageIndex = isEditing ? -1 : index;
            }),
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: isEditing ? const Color(0xFF1EBA14) : Colors.black,
              size: 16,
            ),
          ),

          // <<--- Bouton suppression --->
          IconButton(
            onPressed: () => setState(() => _imageItems.removeAt(index)),
            icon: const Icon(Icons.close, color: Colors.red, size: 16),
          ),
        ],
      ),
    );
  }

  // <<--- Overlay chargement --->
  Widget _buildLoadingOverlay() {
    return Container(
      // <<--- Correction : withOpacity -> withValues --->
      color: Colors.black.withValues(alpha: 0.4),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: amorDarkRose),
                SizedBox(height: 16),
                Text('Synchronisation...', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
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

  // <<--- Récupération des prédictions de lieux --->
  Future<void> _fetchPredictions(String query) async {
    final results = await PlaceService.fetchPredictions(query);
    if (mounted) setState(() => _predictions = results);
  }

  // <<--- Ajout d'une image --->
  void _addImage() {
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _imageItems.add(ImageItem(id: _nextImageId++, url: url));
      _imageUrlController.clear();
    });
  }

  // <<--- Sauvegarde de l'événement --->
  Future<void> _handleSave(BuildContext context) async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    final viewModel = context.read<TimelineViewModel>();
    final finalImageUrls = _imageItems.map((i) => i.url).join('|');

    final newEvent = TimelineEvent(
      id: widget.eventToEdit?.id ?? '',
      title: _titleController.text.trim(),
      date: _selectedDate,
      place: _placeController.text.trim(),
      who: _selectedWho,
      imageUrl: finalImageUrls,
      description: _descriptionController.text.trim(),
    );

    String? savedId;

    if (widget.eventToEdit != null) {
      // <<--- Modification --->
      final success = await viewModel.updateEvent(newEvent);
      if (success) savedId = newEvent.id;
    } else {
      // <<--- Ajout --->
      savedId = await viewModel.addEvent(newEvent);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    // <<--- Correction : context utilisé après vérification mounted --->
    if (savedId != null && mounted) {
      context.pushReplacement(AppRoutes.timelineDetailPath(savedId));
    }
  }
}