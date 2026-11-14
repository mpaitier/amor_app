// ============================================================================
// ADD / EDIT EVENT VIEWMODEL
// ============================================================================
// Owns the add-event form state and orchestrates image upload + save.
// Images are uploaded ONLY when save() is called. L'auteur est la personne
// connectée ; en modification, l'auteur d'origine est conservé.

import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/timeline_event_entity.dart';
import '../../domain/usecases/add_timeline_event.dart';
import '../../domain/usecases/update_timeline_event.dart';
import '../../domain/usecases/pick_images_from_gallery.dart';
import '../../domain/usecases/take_photo.dart';
import '../../domain/usecases/upload_images.dart';
import '../models/image_item.dart';
import '../../../notifications/domain/usecases/get_device_id.dart';
import '../../../gif/domain/usecases/get_random_gif.dart';
import '../../../settings/domain/usecases/get_gif_search_term.dart';

class AddEditEventViewModel extends ChangeNotifier {
  final AddTimelineEvent _addTimelineEvent;
  final UpdateTimelineEvent _updateTimelineEvent;
  final PickImagesFromGallery _pickImagesFromGallery;
  final TakePhoto _takePhoto;
  final UploadImages _uploadImages;

  final TimelineEventEntity? eventToEdit;

  // --- uid de la personne connectée, auteur des nouveaux souvenirs ---
  final String currentUid;

  // --- Text controllers (owned by the ViewModel, disposed with it) ---
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  // --- Form state ---
  DateTime selectedDate = DateTime.now();
  String currentPlace = '';
  List<ImageItem> imageItems = [];

  // --- GIF du souvenir : repris à la modification, tiré au hasard sinon ---
  String gifUrl = '';
  bool isGifLoading = false;

  // --- Technical state ---
  bool isSaving = false;
  String? errorMessage;
  int _nextImageId = 1;
  bool _isDisposed = false;

  bool get isEditing => eventToEdit != null;
  int get pendingUploadCount =>
      imageItems.where((i) => i.isPendingUpload).length;

  final GetDeviceId _getDeviceId;
  final GetRandomGif _getRandomGif;
  final GetGifSearchTerm _getGifSearchTerm;

  AddEditEventViewModel({
    required AddTimelineEvent addTimelineEvent,
    required UpdateTimelineEvent updateTimelineEvent,
    required PickImagesFromGallery pickImagesFromGallery,
    required TakePhoto takePhoto,
    required UploadImages uploadImages,
    required GetDeviceId getDeviceId,
    required GetRandomGif getRandomGif,
    required GetGifSearchTerm getGifSearchTerm,
    required this.currentUid,
    this.eventToEdit,
  })  : _addTimelineEvent = addTimelineEvent,
        _updateTimelineEvent = updateTimelineEvent,
        _pickImagesFromGallery = pickImagesFromGallery,
        _takePhoto = takePhoto,
        _uploadImages = uploadImages,
        _getDeviceId = getDeviceId,
        _getRandomGif = getRandomGif,
        _getGifSearchTerm = getGifSearchTerm {
    _initFromEvent();
    if (gifUrl.isEmpty) loadRandomGif();
  }

  // --- Populate the form from an existing event, if any ---
  void _initFromEvent() {
    titleController = TextEditingController(text: eventToEdit?.title ?? '');
    descriptionController =
        TextEditingController(text: eventToEdit?.description ?? '');
    selectedDate = eventToEdit?.date ?? DateTime.now();
    currentPlace = eventToEdit?.place ?? '';
    gifUrl = eventToEdit?.gifUrl ?? '';

    imageItems = [];
    final existingImageUrl = eventToEdit?.imageUrl ?? '';
    if (existingImageUrl.isNotEmpty) {
      final urls = existingImageUrl.split('|');
      for (var i = 0; i < urls.length; i++) {
        imageItems.add(ImageItem(id: i + 1, url: urls[i].trim()));
      }
      _nextImageId = urls.length + 1;
    }
  }

  // --- Field setters ---
  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setPlace(String place) {
    currentPlace = place;
    notifyListeners();
  }

  // --- Tire un nouveau GIF au hasard, avec le terme des paramètres ---
  Future<void> loadRandomGif() async {
    isGifLoading = true;
    notifyListeners();

    final searchTerm = await _getGifSearchTerm();
    if (_isDisposed) return;
    final url = await _getRandomGif(searchTerm);
    if (_isDisposed) return;

    // --- En cas d'échec, on garde le GIF précédent ---
    if (url != null) gifUrl = url;
    isGifLoading = false;
    notifyListeners();
  }

  void setImageItems(List<ImageItem> updated) {
    imageItems = updated;
    notifyListeners();
  }

  // --- Pick images from the gallery, appended as pending uploads ---
  Future<void> pickFromGallery() async {
    final files = await _pickImagesFromGallery();
    _addLocalImages(files);
  }

  // --- Take a photo with the camera, appended as a pending upload ---
  Future<void> takePhotoFromCamera() async {
    final file = await _takePhoto();
    if (file != null) _addLocalImages([file]);
  }

  void _addLocalImages(List<File> files) {
    for (final file in files) {
      imageItems.add(ImageItem(id: _nextImageId++, localFile: file));
    }
    notifyListeners();
  }

  // --- Save: upload pending images then persist the event ---
  // --- Returns the saved event id, or null on failure ---
  Future<String?> save() async {
    if (titleController.text.trim().isEmpty) return null;

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final storageFolder = _buildStorageFolder(titleController.text);
      final updatedItems = <ImageItem>[];

      for (final item in imageItems) {
        if (item.isPendingUpload) {
          final url = await _uploadImages.uploadSingle(
            imageFile: item.localFile!,
            folder: storageFolder,
          );
          if (url != null) {
            updatedItems.add(ImageItem(id: item.id, url: url));
          }
          // --- Silently skip this image if the upload failed ---
        } else {
          updatedItems.add(item);
        }
      }

      final finalImageUrls = updatedItems.map((i) => i.url).join('|');

      final deviceId = await _getDeviceId();
      final originalCreator = eventToEdit?.creatorUid ?? '';

      final event = TimelineEventEntity(
        id: eventToEdit?.id ?? '',
        title: titleController.text.trim(),
        date: selectedDate,
        place: currentPlace,
        imageUrl: finalImageUrls,
        description: descriptionController.text.trim(),
        creatorUid: originalCreator.isNotEmpty ? originalCreator : currentUid,
        creatorDeviceId: deviceId,
        gifUrl: gifUrl,
      );

      String savedId;
      if (isEditing) {
        await _updateTimelineEvent(event);
        savedId = event.id;
      } else {
        savedId = await _addTimelineEvent(event);
      }

      return savedId;
    } catch (e) {
      errorMessage = 'Failed to save this memory: $e';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // --- Dossier Storage tiré du titre. Relatif à la relation : la data
  // --- source le range sous couples/{coupleId}/ ---
  String _buildStorageFolder(String title) {
    final folderName = title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9àâäéèêëîïôùûüç\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return 'events/$folderName';
  }

  @override
  void dispose() {
    _isDisposed = true;
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}