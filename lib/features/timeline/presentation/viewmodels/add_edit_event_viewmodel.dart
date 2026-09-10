// ============================================================================
// ADD / EDIT EVENT VIEWMODEL
// ============================================================================
// Owns the add-event form state and orchestrates image upload + save.
// Images are uploaded ONLY when save() is called.

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

class AddEditEventViewModel extends ChangeNotifier {
  final AddTimelineEvent _addTimelineEvent;
  final UpdateTimelineEvent _updateTimelineEvent;
  final PickImagesFromGallery _pickImagesFromGallery;
  final TakePhoto _takePhoto;
  final UploadImages _uploadImages;

  final TimelineEventEntity? eventToEdit;

  // --- Text controllers (owned by the ViewModel, disposed with it) ---
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  // --- Form state ---
  DateTime selectedDate = DateTime.now();
  String selectedWho = 'Lulu';
  String currentPlace = '';
  List<ImageItem> imageItems = [];

  // --- Technical state ---
  bool isSaving = false;
  String? errorMessage;
  int _nextImageId = 1;

  bool get isEditing => eventToEdit != null;
  int get pendingUploadCount =>
      imageItems.where((i) => i.isPendingUpload).length;

  final GetDeviceId _getDeviceId;

  AddEditEventViewModel({
    required AddTimelineEvent addTimelineEvent,
    required UpdateTimelineEvent updateTimelineEvent,
    required PickImagesFromGallery pickImagesFromGallery,
    required TakePhoto takePhoto,
    required UploadImages uploadImages,
    required GetDeviceId getDeviceId,
    this.eventToEdit,
  })  : _addTimelineEvent = addTimelineEvent,
        _updateTimelineEvent = updateTimelineEvent,
        _pickImagesFromGallery = pickImagesFromGallery,
        _takePhoto = takePhoto,
        _uploadImages = uploadImages,
        _getDeviceId = getDeviceId {
    _initFromEvent();
  }

  // --- Populate the form from an existing event, if any ---
  void _initFromEvent() {
    titleController = TextEditingController(text: eventToEdit?.title ?? '');
    descriptionController =
        TextEditingController(text: eventToEdit?.description ?? '');
    selectedDate = eventToEdit?.date ?? DateTime.now();
    selectedWho = eventToEdit?.who ?? 'Lulu';
    currentPlace = eventToEdit?.place ?? '';

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

  void setWho(String who) {
    selectedWho = who;
    notifyListeners();
  }

  void setPlace(String place) {
    currentPlace = place;
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

      final event = TimelineEventEntity(
        id: eventToEdit?.id ?? '',
        title: titleController.text.trim(),
        date: selectedDate,
        place: currentPlace,
        who: selectedWho,
        imageUrl: finalImageUrls,
        description: descriptionController.text.trim(),
        creatorDeviceId: deviceId,
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

  // --- Build a clean Storage folder name from the event title ---
  String _buildStorageFolder(String title) {
    final folderName = title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9àâäéèêëîïôùûüç\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return 'amor_events/$folderName';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}