// <<===========================================================================>>
// <<========================== VIEWMODEL TIMELINE =============================>>
// <<===========================================================================>>
// Équivalent de Timeline.kt (ViewModel) — gestion de l'état et des données

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/timeline_event.dart';

class TimelineViewModel extends ChangeNotifier {
  // <<--- Instance Firestore --->
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // <<--- État des données --->
  List<TimelineEvent> _events = [];
  bool _isLoading = false;
  TimelineEvent? _selectedEventForEdit;

  // <<--- Getters --->
  List<TimelineEvent> get events => _events;
  bool get isLoading => _isLoading;
  TimelineEvent? get selectedEventForEdit => _selectedEventForEdit;

  // <<--- Constructeur : écoute en temps réel Firestore --->
  TimelineViewModel() {
    _listenToEvents();
  }

  // <<--- Écoute temps réel (équivalent StateFlow de Room) --->
  void _listenToEvents() {
    _firestore
        .collection('timeline_events')
        .orderBy('date', descending: false)
        .snapshots()
        .listen((snapshot) {
      _events = snapshot.docs
          .map((doc) => TimelineEvent.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  // <<--- Sélectionner un événement pour édition --->
  void setSelectedEventForEdit(TimelineEvent? event) {
    _selectedEventForEdit = event;
    notifyListeners();
  }

  // <<--- Effacer la sélection --->
  void clearSelectedEvent() {
    _selectedEventForEdit = null;
    notifyListeners();
  }

  // <<--- Ajouter un événement --->
  Future<String?> addEvent(TimelineEvent event) async {
    try {
      _setLoading(true);
      final docRef = await _firestore
          .collection('timeline_events')
          .add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Erreur ajout événement : $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // <<--- Modifier un événement --->
  Future<bool> updateEvent(TimelineEvent event) async {
    try {
      _setLoading(true);
      await _firestore
          .collection('timeline_events')
          .doc(event.id)
          .update(event.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Erreur modification événement : $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // <<--- Supprimer un événement --->
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestore
          .collection('timeline_events')
          .doc(eventId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Erreur suppression événement : $e');
      return false;
    }
  }

  // <<--- Helper : état de chargement --->
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}